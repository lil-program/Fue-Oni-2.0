from app.models import Mission
from fastapi import APIRouter, HTTPException
from firebase_admin import db

router = APIRouter()


def get_new_mission_id():
    ref_deleted_missions = db.reference("deletedMissions")
    deleted_missions = ref_deleted_missions.get() or []
    ref_deleted_missions_count = db.reference("deletedMissionsCount")

    if deleted_missions:
        new_mission_id = deleted_missions.pop(0)
        ref_deleted_missions.set(deleted_missions)
        ref_deleted_missions_count.transaction(lambda count: (count or 0) - 1)
    else:
        ref_missions_count = db.reference("missionsCount")
        new_mission_id = ref_missions_count.transaction(
            lambda current_count: (current_count or 0) + 1
        )

    if new_mission_id is None:
        raise HTTPException(status_code=500, detail="Failed to get a new mission ID")

    return new_mission_id


@router.post("/add_mission")
async def add_mission(mission: Mission):
    new_mission_id = get_new_mission_id()

    ref_mission = db.reference(f"missions/{new_mission_id}")
    ref_mission.set(mission.model_dump())

    return {"mission_id": f"mission{new_mission_id}"}


@router.put("/update_mission/{mission_id}")
async def update_mission(mission_id: str, mission: Mission):
    ref_mission = db.reference(f"missions/{mission_id}")

    if ref_mission.get() is None:
        raise HTTPException(status_code=404, detail="Mission not found")

    ref_mission.update(mission.model_dump())

    return {"status": "Mission updated"}


@router.delete("/delete_mission/{mission_id}")
async def delete_mission(mission_id: str):
    ref_mission = db.reference(f"missions/{mission_id}")

    if ref_mission.get() is None:
        raise HTTPException(status_code=404, detail="Mission not found")

    ref_mission.delete()

    ref_deleted_missions = db.reference("deletedMissions")
    deleted_missions = ref_deleted_missions.get() or []
    deleted_missions.append(mission_id)
    ref_deleted_missions.set(deleted_missions)

    ref_deleted_missions_count = db.reference("deletedMissionsCount")
    ref_deleted_missions_count.transaction(lambda count: (count or 0) + 1)

    return {"status": "Mission deleted"}


@router.get("/missions")
async def get_missions(limit: int = 10, start_after: int = 0):
    missions = {}
    total_missions = db.reference("missionsCount").get() or 0
    deleted_missions_count = db.reference("deletedMissionsCount").get() or 0

    total_missions -= deleted_missions_count

    for i in range(start_after + 1, min(start_after + limit + 1, total_missions + 1)):
        mission = db.reference(f"missions/{i}").get()
        if mission is not None:
            missions[str(i)] = mission

    if not missions:
        raise HTTPException(status_code=404, detail="No missions found")

    # ページング情報を追加
    paging_info = {
        "current_page": start_after // limit + 1,
        "total_pages": (total_missions + limit - 1) // limit,
    }

    return {"missions": missions, "paging_info": paging_info}


@router.get("/all_missions")
async def get_all_missions():
    ref_missions = db.reference("missions")
    mission_ids = ref_missions.get(shallow=True)

    if not mission_ids:
        raise HTTPException(status_code=404, detail="No missions found")

    missions = {}
    for mission_id in mission_ids.keys():
        mission = db.reference(f"missions/{mission_id}").get()
        if mission is not None:
            missions[mission_id] = mission

    return missions
