from sqlalchemy.orm import Session
from sqlalchemy import and_
from models import Workflow
from data_models.workflow_models import WorkflowCreate, WorkflowUpdate
from fastapi import HTTPException
from typing import Optional

def check_workflow_name_exists(db: Session, name: str, workflow_id: int):
    query = db.query(Workflow).filter(Workflow.name == name and Workflow.id != workflow_id)
    return query.first()

def create_workflow(db: Session, tenant_id: int, workflow: WorkflowCreate):
    query = db.query(Workflow).filter(Workflow.name == workflow.name and Workflow.tenant_id == tenant_id)
    if query.first():
        raise HTTPException(status_code=400, detail="Workflow with this name already exists for the tenant.")
    
    db_workflow = Workflow(
        tenant_id=tenant_id,
        name=workflow.name,
        json=workflow.json
    )
    db.add(db_workflow)
    db.commit()
    db.refresh(db_workflow)
    return db_workflow

def get_workflows_by_tenant(db: Session, tenant_id: int):
    return db.query(Workflow).filter(Workflow.tenant_id == tenant_id).all()

def get_workflow(db: Session, workflow_id: int):
    workflow = db.query(Workflow).filter(Workflow.id == workflow_id).first()
    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")
    return workflow

def update_workflow(db: Session, workflow_id: int, workflow: WorkflowUpdate):
    db_workflow = get_workflow(db, workflow_id)

    if workflow.name and workflow.name != db_workflow.name:
        if check_workflow_name_exists(db, workflow.name, workflow_id):
            raise HTTPException(status_code=400, detail="Workflow with this name already exists for the tenant.")
        db_workflow.name = workflow.name
    
    # Updated: Check if json_data was provided in the update payload
    if workflow.json is not None:
        db_workflow.json = workflow.json

    # Handle 'is_default' toggle logic
    if workflow.is_default is not None:
        if workflow.is_default is True:
            # Set all other workflows for this tenant to False
            tenant_id = db.query(Workflow).filter(Workflow.id == workflow_id).first().tenant_id
            db.query(Workflow).filter(
                and_(Workflow.tenant_id == tenant_id, Workflow.id != workflow_id)
            ).update({"is_default": False}, synchronize_session='fetch')
            
        db_workflow.is_default = workflow.is_default

    db.commit()
    db.refresh(db_workflow)
    return db_workflow

def delete_workflow(db: Session, workflow_id: int):
    db_workflow = get_workflow(db, workflow_id)
    db.delete(db_workflow)
    db.commit()
    return {"message": "Workflow deleted successfully"}

