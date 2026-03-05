from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from deps import get_db
from data_models.workflow_models import WorkflowCreate, WorkflowUpdate, WorkflowResponse
from services import workflow as workflow_service
from services import llm

router = APIRouter(
    prefix="/workflows",
    tags=["workflows"],
    responses={404: {"description": "Not found"}},
)

@router.post("/", response_model=WorkflowResponse)
def create_workflow(
    tenant_id: str,
    workflow: WorkflowCreate,
    db: Session = Depends(get_db),
):
    """
    Create a new workflow for the current tenant.
    """
    return workflow_service.create_workflow(db=db, tenant_id=tenant_id, workflow=workflow)

@router.get("/", response_model=List[WorkflowResponse])
def read_workflows( tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    Retrieve all workflows for the current tenant.
    """
    return workflow_service.get_workflows_by_tenant(db=db, tenant_id=tenant_id)

@router.post("/workflow_optimizer")
async def workflow_optimizer(
    tenant_id: int ,
    query: str = None,
):
    query_prompt = f"""
            You are a WhatsApp AI workflow optimizer. Given the owner's goal.Create minimal, practical conversation flow for a WhatsApp agent.

            Rules:
            - Use plain text and next line — no markdown, no headings, no bullet symbols.
            - Keep every message under 15 words.
            - Ask at most few short qualifying questions if owner specify in gole.
            - Use simple "if-then" logic (e.g., "If X, say Y").
            - End with one clear closing or handoff line.

            Output format:
            Start: [opening message]
            optional second question if any needed
            If [condition]: [reply]
            If [condition]: [reply]
            ...
            End: [final message or handoff]
            """
    return await llm.analysis(tenant_id, query, query_prompt)

@router.get("/{workflow_id}", response_model=WorkflowResponse)
def read_workflow(
    workflow_id: int,
    db: Session = Depends(get_db),
):
    """
    Retrieve a specific workflow by ID.
    """
    return workflow_service.get_workflow(db=db, workflow_id=workflow_id)

@router.put("/{workflow_id}", response_model=WorkflowResponse)
def update_workflow(
    workflow_id: int,
    workflow: WorkflowUpdate,
    db: Session = Depends(get_db),
):
    """
    Update a workflow.
    """
    return workflow_service.update_workflow(db=db, workflow_id=workflow_id, workflow=workflow)

@router.delete("/{workflow_id}")
def delete_workflow(
    workflow_id: int,
    db: Session = Depends(get_db),
):
    """
    Delete a workflow.
    """
    return workflow_service.delete_workflow(db=db, workflow_id=workflow_id)
