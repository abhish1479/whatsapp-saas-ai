import base64
import uuid
import mimetypes
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from redis import Redis
from sqlalchemy.orm import Session
from sqlalchemy import select

# Local module imports
from models import KnowledgeSource, SourceTypeEnum, ProcessingStatusEnum
from data_models.knowledge_models import KnowledgeSourceResponse, UrlUploadRequest
from services.knowledge_executor import process_file_job, process_url_job
from deps import get_db
from utils.responses import StandardResponse # Import the global response model
from utils.media import upload_file_cloud
from workers.queue_manager import QueueManager

# Create a new router. This is the "route file" you wanted.
router = APIRouter(
    prefix="/knowledge", # All routes in this file will start with /knowledge
    tags=["Knowledge Base"] # Group these routes in the /docs UI
)

queue_manager = QueueManager()

@router.post("/upload_file", response_model=StandardResponse[KnowledgeSourceResponse])
async def upload_file(
    tenant_id: int = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    """
    Uploads a file, saves its metadata to the DB, and enqueues
    a background job for processing.
    """
    
    # Placeholder for file storage
    # storage_path = f"s3://my-bucket/{tenant_id}/{uuid.uuid4()}-{file.filename}"
    # print(f"Simulating file save to: {storage_path}")
    knowledge_sources = db.query(KnowledgeSource).filter(
        KnowledgeSource.tenant_id == tenant_id,
        KnowledgeSource.name == file.filename).all()
    
    if knowledge_sources:
        raise HTTPException(
            status_code=400,
            detail="This file has already been uploaded."
        )

    try:
        file_bytes = await file.read()
        base64_string = base64.b64encode(file_bytes).decode('utf-8')
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to read or encode file: {e}")

    # --- 2. Call the external Azure upload function ---
    # This key will be the unique identifier in your Azure storage.
    file_key = f"{tenant_id}-{file.filename}"
    
    upload_result = await upload_file_cloud(
        key=file_key,
        base64_string=base64_string
    )

    # --- 3. Check if upload was successful before proceeding ---
    if not upload_result.get("success"):
        # Pass the error from the storage service to the client
        error_detail = upload_result.get("details", "Unknown upload error")
        raise HTTPException(status_code=502, detail=f"Failed to upload file to storage: {error_detail}")

    # 1. Create the KnowledgeSource record
    db_source = KnowledgeSource(
        tenant_id=tenant_id,
        source_type=SourceTypeEnum.FILE,
        name=file.filename,
        source_uri=file_key,
        size_bytes=file.size,
        processing_status=ProcessingStatusEnum.PENDING
    )
    
    db.add(db_source)
    db.commit()
    db.refresh(db_source)
    
    # 2. Add the processing job to the Redis Queue
    file_queue = queue_manager.get_queue("file_processing")

    file_queue.enqueue(
        process_file_job,
        id=db_source.id
    )
    
    # Return the standardized response
    return StandardResponse(
        success=True,
        data=db_source,
        message="File uploaded successfully and processing started."
    )

@router.post("/web_crawl", response_model=StandardResponse[KnowledgeSourceResponse])
async def upload_url(
    payload: UrlUploadRequest,
    db: Session = Depends(get_db),
):
    """
    Uploads a URL, saves its metadata to the DB, and enqueues
    a background job for scraping and processing.
    """
    if payload.name.strip() == "":
        payload.name = payload.url.host or "Unnamed URL"
    
    knowledge_sources = db.query(KnowledgeSource).filter(
        KnowledgeSource.tenant_id == payload.tenant_id,
        KnowledgeSource.source_uri == str(payload.url)).all()

    if knowledge_sources:
        return HTTPException(
            status_code=400,
            detail="This URL has already been submitted."
        )
    # 1. Create the KnowledgeSource record
    db_source = KnowledgeSource(
        tenant_id=payload.tenant_id,
        source_type=SourceTypeEnum.URL,
        name=payload.name,
        source_uri=str(payload.url),
        size_bytes=None,
        processing_status=ProcessingStatusEnum.PENDING
    )
    
    db.add(db_source)
    db.commit()
    db.refresh(db_source)
    
    # 2. Add the scraping job to the Redis Queue
    # web_queue = queue_manager.get_queue("web_crwalling")
    web_queue = queue_manager.get_queue("file_processing")

    web_queue.enqueue(
        process_url_job,
        id=db_source.id
    )
    
    # Return the standardized response
    return StandardResponse(
        success=True,
        data=db_source,
        message="URL submitted successfully and scraping started."
    )


@router.get("/get_knowledge_sources", response_model=StandardResponse[list[KnowledgeSourceResponse]])
async def get_knowledge_sources(
    tenant_id: int,
    db: Session = Depends(get_db)
):
    """
    Gets all knowledge source records for a specific tenant.
    """
    sources = db.execute(
        select(KnowledgeSource)
        .where(KnowledgeSource.tenant_id == tenant_id)
        .order_by(KnowledgeSource.created_at.desc())
    ).scalars().all()
    
    # Return the standardized response
    return StandardResponse(
        success=True,
        data=sources,
        message=f"Found {len(sources)} knowledge sources." if sources else "No knowledge sources found."
    )


@router.post("/test")
async def upload_url(
    id: int
):
    await process_url_job(id)
    

@router.post("/upload_file_test")
async def upload_file_test(file: UploadFile = File(...)):
    from utils.file_extractor import FileExtractor

    # Read file content as bytes
    file_bytes = await file.read()
    
    # Extract text using both bytes and filename
    extracted_text = FileExtractor.extract_text(file_bytes, file.filename)
    
    return {"text": extracted_text}


@router.post("/web_crawl_test")
async def web_crawl_test(url: str):
    from utils.web_crawler import scrape_single_page
    extracted_text = await scrape_single_page(url)
    return {"text": extracted_text}