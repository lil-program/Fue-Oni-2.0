import random

from fastapi import HTTPException
from firebase_admin import db

from app import schemas


def get_mission(mission_id: str):
    ref_mission = db.reference(f"missions/{mission_id}")
    return ref_mission.get()


def create_mission(mission: schemas.Mission):
    ref_missions = db.reference("missions")
    mission_data = mission.model_dump()
    mission_data["random_number"] = random.random()
    new_mission_ref = ref_missions.push(mission_data)

    # Update missionsCount
    ref_missions_count = db.reference("missionsCount")
    ref_missions_count.transaction(lambda count: (count or 0) + 1)

    return new_mission_ref.key


def update_mission(mission_id: str, mission: schemas.Mission):
    ref_mission = db.reference(f"missions/{mission_id}")
    ref_mission.update(mission.model_dump())


def delete_mission(mission_id: str):
    ref_mission = db.reference(f"missions/{mission_id}")
    ref_mission.delete()

    # Update missionsCount
    ref_missions_count = db.reference("missionsCount")
    ref_missions_count.transaction(lambda count: (count or 0) - 1)


def get_missions(limit: int = 10, start_at: str = "") -> schemas.MissionsResponse:
    ref_missions = db.reference("missions").order_by_key()
    if start_at:
        ref_missions = ref_missions.start_at(start_at)
    missions_snapshot = ref_missions.limit_to_first(limit + 1).get()

    if not missions_snapshot:
        raise HTTPException(status_code=404, detail="No missions found")

    missions = {key: value for key, value in missions_snapshot.items()}
    next_page_token = (
        list(missions_snapshot.keys())[-1] if len(missions_snapshot) > limit else None
    )

    # If there is a next page, remove the last mission from the current page
    if next_page_token:
        missions.pop(next_page_token)

    # Get total missions count
    total_missions = db.reference("missionsCount").get() or 0

    # Calculate paging info
    total_pages = (total_missions + limit - 1) // limit
    current_page = total_pages if next_page_token is None else total_pages - 1

    paging_info = {
        "current_page": current_page,
        "total_pages": total_pages,
    }

    return {
        "missions": missions,
        "paging_info": paging_info,
        "next_page_token": next_page_token,
    }


def get_all_missions() -> schemas.AllMissionsResponse:
    ref_missions = db.reference("missions")
    mission_ids = ref_missions.get(shallow=True)

    if not mission_ids:
        raise HTTPException(status_code=404, detail="No missions found")

    missions = {}
    for mission_id in mission_ids.keys():
        mission = db.reference(f"missions/{mission_id}").get()
        if mission is not None:
            missions[mission_id] = schemas.Mission(**mission)

    return schemas.AllMissionsResponse(missions=missions)
