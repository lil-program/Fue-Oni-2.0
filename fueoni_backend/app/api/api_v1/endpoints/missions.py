from fastapi import APIRouter, HTTPException

from app import crud, schemas

router = APIRouter()


@router.post("/add_mission")
async def add_mission(mission: schemas.Mission):
    new_mission_id = crud.create_mission(mission)

    return {"mission_id": new_mission_id}


@router.put("/update_mission/{mission_id}")
async def update_mission(mission_id: str, mission: schemas.Mission):
    existing_mission = crud.get_mission(mission_id)

    if existing_mission is None:
        raise HTTPException(status_code=404, detail="Mission not found")

    crud.update_mission(mission_id, mission)

    return {"status": "Mission updated"}


@router.delete("/delete_mission/{mission_id}")
async def delete_mission(mission_id: str):
    existing_mission = crud.get_mission(mission_id)

    if existing_mission is None:
        raise HTTPException(status_code=404, detail="Mission not found")

    crud.delete_mission(mission_id)

    return {"status": "Mission deleted"}


@router.get("/missions", response_model=schemas.MissionsResponse)
async def get_missions(limit: int = 10, start_at: str = ""):
    return crud.get_missions(limit, start_at)


@router.get("/all_missions", response_model=schemas.AllMissionsResponse)
async def get_all_missions():
    return crud.get_all_missions()


@router.get("/mission/{mission_id}", response_model=schemas.Mission)
async def get_mission(mission_id: str):
    mission = crud.get_mission(mission_id)

    if mission is None:
        raise HTTPException(status_code=404, detail="Mission not found")

    return mission
