import os
import time
from multiprocessing import Pool, cpu_count
import traceback
from services.rag import rag
from deps import SessionLocal, get_db # Your db.py file
from models import KnowledgeSource # Your models.py file
from sqlalchemy import func, or_, select
from utils.enums import ProcessingStatusEnum ,SourceTypeEnum
from utils.file_analyzer import analyze_file_from_bytes
from utils.media import download_file


def process_url_job(id:int):
    """
    This is the "Poller" job function you are asking about.
    
    Instead of being given one ID, this function *queries the database*
    to find 5 'PENDING' or 'FAILED' jobs and processes them in a loop.
    """
    pid = os.getpid()
    print(f"POLLER WORKER (PID {pid}): Starting batch. Looking for jobs...")
    
    db = SessionLocal()
    
    # 1. This is the query you were asking for:
    #    Select 5 sources that are 'PENDING' or 'FAILED'
    try:
        source = db.query(KnowledgeSource).filter(
            KnowledgeSource.id == id).first()

        if not source:
            print(f"POLLER WORKER (PID {pid}): No pending/failed jobs found. Sleeping.")
            return

        print(f"POLLER WORKER (PID {pid}): Found job. Starting batch...")
       
        source.processing_status = ProcessingStatusEnum.PROCESSING
        source.processing_error = None
        db.commit() # Commit the "PROCESSING" status update

    except Exception as e:
        print(f"POLLER WORKER (PID {pid}): Error during job selection. {e}")
        db.rollback()
        return
    finally:
        db.close() # Close the selection session
        
    
    # 3. Process each job one-by-one (in this single worker)
    #    You could also use multiprocessing here (Solution 2 from before)
    #    but a simple loop is fine for I/O-bound tasks.

        job_db = SessionLocal()
        try:
            
            summary = _process_url_and_update_rag(job_db, source)
           
            # --- Update to COMPLETED ---
            source.processing_status = ProcessingStatusEnum.COMPLETED
            source.summary = summary
            source.last_processed_at = func.now()
            job_db.commit()
            print(f"POLLER WORKER (PID {pid}): Successfully processed {source.id}.")
            processed_count += 1

        except Exception as e:
            # --- Handle FAILED status ---
            print(f"POLLER WORKER (PID {pid}): FAILED to process. Error: {e}")
            traceback.print_exc()
            job_db.rollback()
            
            # Use a *new* session for the error update
            db_fail_session = SessionLocal()
            try:
                source_to_fail = db_fail_session.execute(
                    select(KnowledgeSource).where(KnowledgeSource.id == id)
                ).scalar_one_or_none()
                if source_to_fail:
                    source_to_fail.processing_status = ProcessingStatusEnum.FAILED
                    source_to_fail.processing_error = str(e)
                    db_fail_session.commit()
            finally:
                db_fail_session.close()
        finally:
            job_db.close() # MUST close the session for this job

    print(f"POLLER WORKER (PID {pid}): Batch finished. Processed.")


async def process_file_job(id: int):
    pid = os.getpid()
    print(f"POLLER WORKER (PID {pid}): Starting job for KnowledgeSource ID {id}")

    # --- 1. Fetch and mark as PROCESSING ---
    db = SessionLocal()
    try:
        source = db.query(KnowledgeSource).filter(KnowledgeSource.id == id).first()
        if not source:
            print(f"POLLER WORKER (PID {pid}): Source ID {id} not found.")
            db.close()
            return

        # if source.processing_status not in (ProcessingStatusEnum.PENDING, ProcessingStatusEnum.FAILED):
        #     print(f"POLLER WORKER (PID {pid}): Source ID {id} is already being processed.")
        #     db.close()
        #     return

        # Mark as processing
        source.processing_status = ProcessingStatusEnum.PROCESSING
        source.processing_error = None
        db.commit()

        # Capture needed values before closing session
        tenant_id = source.tenant_id
        filename = source.name

    except Exception as e:
        print(f"POLLER WORKER (PID {pid}): Error preparing job: {e}")
        traceback.print_exc()
        db.rollback()
        db.close()
        return
    finally:
        db.close()

    # --- 2. Do async work (no DB session here) ---
    response_obj = None
    try:
        # Assuming this function only uses primitive data (not ORM objects)
        response_obj = await _process_pdf_and_update_rag(source)
        summary = response_obj.get("summary", "No summary generated.")
        tags = response_obj.get("tags", [])
    except Exception as e:
        error_msg = str(e)
        print(f"POLLER WORKER (PID {pid}): Processing failed: {error_msg}")
        traceback.print_exc()

        # --- Update to FAILED in a new session ---
        db_fail = SessionLocal()
        try:
            source_fail = db_fail.query(KnowledgeSource).filter(KnowledgeSource.id == id).first()
            if source_fail:
                source_fail.processing_status = ProcessingStatusEnum.FAILED
                source_fail.processing_error = error_msg
                db_fail.commit()
        finally:
            db_fail.close()
        return

    # --- 3. Update to COMPLETED in a new session ---
    db_complete = SessionLocal()
    try:
        source_complete = db_complete.query(KnowledgeSource).filter(KnowledgeSource.id == id).first()
        if source_complete:
            source_complete.processing_status = ProcessingStatusEnum.COMPLETED
            source_complete.summary = summary
            source_complete.tags = tags
            source_complete.last_processed_at = func.now()
            db_complete.commit()
            print(f"POLLER WORKER (PID {pid}): Successfully completed job {id}.")
    except Exception as e:
        print(f"POLLER WORKER (PID {pid}): Error saving COMPLETED status: {e}")
        db_complete.rollback()
    finally:
        db_complete.close()


async def _process_pdf_and_update_rag(source: KnowledgeSource) -> str:
    """
    Process a single URL KnowledgeSource:
    - Fetch content from the URL
    - Summarize content
    - Update RAG system
    - Return summary text
    """
    
    download_result = await download_file(source.source_uri)
    if not download_result.get("success"):
        raise ValueError(f"Failed to download file for source ID {source.id}: {download_result.get('error')}")

    file_bytes = download_result["data"]

    response_obj = await analyze_file_from_bytes(
        tenant_id=source.tenant_id,file_bytes=file_bytes,file_name=source.name)
    
    documents = response_obj.get("document", [])
    # 2. Update RAG system with the URL content
    metadatas= [(d.get("metadata" ,{})) for d in documents]
    await rag.add_documents_rag(source.tenant_id, documents,metadatas)

    return response_obj

async def _process_url_and_update_rag(source: KnowledgeSource) -> str:
    """
    Process a single URL KnowledgeSource:
    - Fetch content from the URL
    - Summarize content
    - Update RAG system
    - Return summary text
    """
    
    # 1. Fetch content from the URL and summarize
    # (You need to implement fetch_and_summarize_url)
    summary = f"Summary of content from {source.url}"
    
    # 2. Update RAG system with the URL content
    documents = [{
        "id": str(source.id),
        "text": summary,
        "source_url": source.url,
        "version": "1.0",
        "language": "en",
    }]
    await rag.add_documents(source.tenant_id, documents)

    return summary