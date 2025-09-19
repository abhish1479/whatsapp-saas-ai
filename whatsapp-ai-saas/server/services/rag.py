
import os, uuid
import chromadb
from chromadb.config import Settings as ChromaSettings

CHROMA_DIR = os.path.join(os.path.dirname(__file__), "..", "chroma_db")
client = chromadb.PersistentClient(path=CHROMA_DIR, settings=ChromaSettings(allow_reset=True))

def _collection(tenant_id:int):
    name = f"kb_{tenant_id}"
    try:
        return client.get_collection(name)
    except:
        return client.create_collection(name)

def ingest_text(tenant_id:int, text:str, meta:dict):
    col = _collection(tenant_id)
    doc_id = str(uuid.uuid4())
    col.add(ids=[doc_id], documents=[text], metadatas=[meta])
    return doc_id

def query_kb(tenant_id:int, q:str, top_k:int=4):
    col = _collection(tenant_id)
    return col.query(query_texts=[q], n_results=top_k)
