import csv
from io import StringIO
from sqlalchemy.orm import Session
from typing import Any, Dict, List, Optional
from models import Lead
from services.metrics import leads_ingested_total

class LeadsService:
    @staticmethod
    def create(db: Session, data) -> Lead:
        lead = Lead(**data.model_dump())
        db.add(lead)
        db.commit()
        db.refresh(lead)
        leads_ingested_total.labels(source="api").inc()
        return lead

    @staticmethod
    def list(db: Session, tenant_id: int, q: Optional[str]=None, tags: Optional[List[str]]=None, status: Optional[str]=None):
        query = db.query(Lead).filter(Lead.tenant_id==tenant_id)
        if q:
            like = f"%{q}%"
            query = query.filter((Lead.name.ilike(like)) | (Lead.phone.ilike(like)) | (Lead.email.ilike(like)))
        if tags:
            # naive tags contains
            query = query.filter(Lead.tags.contains(tags))
        if status:
            query = query.filter(Lead.status==status)
        return query.order_by(Lead.created_at.desc()).all()

    @staticmethod
    def get(db: Session, lead_id: int) -> Optional[Lead]:
        return db.query(Lead).get(lead_id)

    @staticmethod
    def update(db: Session, lead: Lead, data) -> Lead:
        for k,v in data.model_dump(exclude_unset=True).items():
            setattr(lead, k, v)
        db.commit()
        db.refresh(lead)
        return lead
    
    @staticmethod
    def bulk_create_from_csv(db: Session, tenant_id: int, csv_data: str) -> List[Lead]:
        """Reads CSV data and creates multiple Lead records."""
        # Use StringIO to treat the string data as a file
        f = StringIO(csv_data)
        reader = csv.DictReader(f)
        
        leads_to_create = []
        successful_leads = []
        
        for row in reader:
            # Prepare data, assuming column names match model fields 
            # and handling mandatory fields (like phone)
            try:
                lead_data: Dict[str, Any] = {
                    "tenant_id": tenant_id,
                    "name": row.get("name"),
                    "phone": row["phone"], # Assuming 'phone' is mandatory
                    "email": row.get("email"),
                    "product_service": row.get("product_service"),
                    "pitch": row.get("pitch"),
                    # Set initial status
                    "status": row.get("status", "New"), 
                    # Tags logic might need refinement depending on how CSV handles it (e.g., comma-separated)
                    "tags": [tag.strip() for tag in row.get("tags", "").split(',')] if row.get("tags") else []
                }
                
                # Simple validation for mandatory phone field
                if not lead_data["phone"]:
                    print(f"Skipping row due to missing phone: {row}")
                    continue

                lead = Lead(**lead_data)
                leads_to_create.append(lead)
            except KeyError as e:
                # Handle missing mandatory fields (e.g., if 'phone' is missing from CSV)
                print(f"Skipping row due to missing mandatory field: {e} in row: {row}")
                continue
        
        # Bulk insert
        if leads_to_create:
            db.bulk_save_objects(leads_to_create)
            db.commit()
            # Since bulk_save_objects doesn't return objects, 
            # we'll query the newly created ones or rely on the commit.
            # For simplicity, we just return a status of success. 
            # A robust implementation might return IDs or a success/failure report.
            
            # Increment metric for each lead created
            leads_ingested_total.labels(source="csv").inc(len(leads_to_create))
            
            # A simple way to get the created objects (less efficient than needed for a real bulk API)
            # For this example, we'll just acknowledge the count
            # A more advanced approach would use a transaction and get the IDs back.
            # For now, we'll return an empty list or modify the return type of the API.
            
            # To get a list of created leads, you might need another query or a more complex bulk insert method.
            # For now, let's just return the created objects for demonstration.
            successful_leads = leads_to_create 
            
        return successful_leads
    
    @staticmethod
    def get_sample_csv_content() -> str:
        """Generates and returns a sample CSV file content."""
        fieldnames = ["name", "phone", "email", "tags", "product_service", "pitch", "status"]
        
        output = StringIO()
        # Note: By default, csv.DictWriter adds an extra blank row after the header/data.
        # This is often harmless but can be controlled by dialect or row writing.
        writer = csv.DictWriter(output, fieldnames=fieldnames)

        writer.writeheader()
        writer.writerow({
            "name": "Jane Doe",
            "phone": "9876543210",
            "email": "jane.doe@example.com",
            "tags": "VIP, Marketing",
            "product_service": "Enterprise Tier",
            "pitch": "Needs a demo of the new features.",
            "status": "Contacted"
        })
        writer.writerow({
            "name": "John Smith",
            "phone": "5551234567",
            "email": "john.smith@corp.com",
            "tags": "New",
            "product_service": "Basic Plan",
            "pitch": "Interested in pricing.",
            "status": "New"
        })
        
        # 🔑 CRITICAL FIX: Move the cursor back to the start of the buffer.
        output.seek(0)
        
        # Now getvalue() reads from the beginning to the end, capturing all data.
        return output.getvalue()
