from fastapi import APIRouter, HTTPException
from firebase_admin import db

from app import crud, schemas

router = APIRouter()


@router.post("/add_mission")
async def add_mission(mission: schemas.Mission):
    new_mission_id = crud.get_new_mission_id()

    ref_mission = db.reference(f"missions/{new_mission_id}")
    ref_mission.set(mission.model_dump())

    return {"mission_id": f"mission{new_mission_id}"}


@router.put("/update_mission/{mission_id}")
async def update_mission(mission_id: str, mission: schemas.Mission):
    mission = crud.get_mission(mission_id)

    if mission is None:
        raise HTTPException(status_code=404, detail="Mission not found")

    crud.update_mission(mission_id, mission)

    return {"status": "Mission updated"}


@router.delete("/delete_mission/{mission_id}")
async def delete_mission(mission_id: str):
    mission = crud.get_mission(mission_id)

    if mission is None:
        raise HTTPException(status_code=404, detail="Mission not found")

    crud.delete_mission(mission_id)

    return {"status": "Mission deleted"}


@router.get("/missions", response_model=schemas.MissionsResponse)
async def get_missions(limit: int = 10, start_after: int = 0):
    return crud.get_missions(limit, start_after)


@router.get("/all_missions", response_model=schemas.AllMissionsResponse)
async def get_all_missions():
    return crud.get_all_missions()
