from fastapi import APIRouter, Depends, HTTPException, Query, Response, UploadFile, File
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from deps import get_db
from data_models.schemas import LeadCreate, LeadUpdate, LeadOut
from services.leads import LeadsService

router = APIRouter(prefix="/leads", tags=["Leads"])

@router.get("/sample-csv", tags=["Utility"])
def get_sample_csv():
    """
    Returns a sample CSV template for lead bulk upload.
    """
    csv_content = LeadsService.get_sample_csv_content()
    
    # Return the content as a FileResponse or just a Response with correct media type
    return Response(
        content=csv_content,
        media_type="text/csv",
        headers={
            "Content-Disposition": "attachment; filename=sample_leads_template.csv"
        }
    )

@router.post("", response_model=LeadOut, status_code=201)
def create_lead(payload: LeadCreate, db: Session = Depends(get_db)):
    return LeadsService.create(db, payload)

@router.get("", response_model=list[LeadOut])
def list_leads(tenant_id: int = Query(...), q: str | None = None, status: str | None = None, db: Session = Depends(get_db)):
    return LeadsService.list(db, tenant_id=tenant_id, q=q, status=status)

@router.get("/{lead_id}", response_model=LeadOut)
def get_lead(lead_id: int, db: Session = Depends(get_db)):
    lead = LeadsService.get(db, lead_id)
    if not lead:
        raise HTTPException(404, "Lead not found")
    return lead

@router.patch("/{lead_id}", response_model=LeadOut)
def update_lead(lead_id: int, payload: LeadUpdate, db: Session = Depends(get_db)):
    lead = LeadsService.get(db, lead_id)
    if not lead:
        raise HTTPException(404, "Lead not found")
    return LeadsService.update(db, lead, payload)

@router.post("/upload", status_code=202) # Use 202 Accepted for bulk operations
def bulk_upload_leads(
    tenant_id: int = Query(..., description="The ID of the tenant for the leads."),
    file: UploadFile = File(..., description="CSV file containing lead data."),
    db: Session = Depends(get_db)
):
    """
    Upload a CSV file to bulk-create leads.
    """
    if file.content_type != 'text/csv':
        raise HTTPException(status_code=400, detail="Invalid file type. Must be CSV.")
    
    try:
        # Read the file content as a string
        csv_data = file.file.read().decode('utf-8')
        
        # Pass data to service layer for processing
        created_leads = LeadsService.bulk_create_from_csv(db, tenant_id, csv_data)
        
        return JSONResponse(
            status_code=202,
            content={
                "message": f"Bulk upload accepted. {len(created_leads)} leads processed successfully.",
                "total_processed": len(created_leads)
            }
        )
    except Exception as e:
        print(f"Error during CSV upload: {e}")
        raise HTTPException(status_code=500, detail="Failed to process CSV file.")