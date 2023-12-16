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
    return new_mission_ref.key


def update_mission(mission_id: str, mission: schemas.Mission):
    ref_mission = db.reference(f"missions/{mission_id}")
    ref_mission.update(mission.model_dump())


def delete_mission(mission_id: str):
    ref_mission = db.reference(f"missions/{mission_id}")
    ref_mission.delete()


def get_missions(limit: int = 10, start_after: str = "") -> schemas.MissionsResponse:
    ref_missions = db.reference("missions").order_by_key()
    if start_after:
        ref_missions = ref_missions.start_at(start_after)
    missions_snapshot = ref_missions.limit_to_first(limit + 1).get()

    if not missions_snapshot:
        raise HTTPException(status_code=404, detail="No missions found")

    missions = {
        key: value for key, value in missions_snapshot.items() if key != start_after
    }
    next_page_token = (
        list(missions_snapshot.keys())[-1] if len(missions_snapshot) > limit else None
    )

    # ページング情報を追加
    paging_info = {
        "current_page": start_after // limit + 1,
        "total_pages": (len(missions) + limit - 1) // limit,
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


# def get_mission(mission_id: str):
#     ref_mission = db.reference(f"missions/{mission_id}")
#     return ref_mission.get()


# def get_new_mission_id():
#     ref_deleted_missions = db.reference("deletedMissions")
#     deleted_missions = ref_deleted_missions.get() or []
#     ref_deleted_missions_count = db.reference("deletedMissionsCount")

#     if deleted_missions:
#         new_mission_id = deleted_missions.pop(0)
#         ref_deleted_missions.set(deleted_missions)
#         ref_deleted_missions_count.transaction(lambda count: (count or 0) - 1)
#     else:
#         ref_missions_count = db.reference("missionsCount")
#         new_mission_id = ref_missions_count.transaction(
#             lambda current_count: (current_count or 0) + 1
#         )

#     if new_mission_id is None:
#         raise HTTPException(status_code=500, detail="Failed to get a new mission ID")

#     return new_mission_id


# def update_mission(mission_id: str, mission: schemas.Mission):
#     ref_mission = db.reference(f"missions/{mission_id}")
#     ref_mission.update(mission.model_dump())


# def delete_mission(mission_id: str):
#     ref_mission = db.reference(f"missions/{mission_id}")
#     ref_mission.delete()

#     ref_deleted_missions = db.reference("deletedMissions")
#     deleted_missions = ref_deleted_missions.get() or []
#     deleted_missions.append(mission_id)
#     ref_deleted_missions.set(deleted_missions)

#     ref_deleted_missions_count = db.reference("deletedMissionsCount")
#     ref_deleted_missions_count.transaction(lambda count: (count or 0) + 1)


# def get_missions(limit: int = 10, start_after: int = 1) -> schemas.MissionsResponse:
#     missions = {}
#     ref_missions = db.reference("missions")
#     all_mission_ids = ref_missions.get(shallow=True)

#     if not all_mission_ids:
#         raise HTTPException(status_code=404, detail="No missions found")

#     sorted_mission_ids = sorted([int(id) for id in all_mission_ids.keys()])
#     total_missions = len(sorted_mission_ids)

#     for i in range(start_after, min(start_after + limit, total_missions)):
#         mission_id = sorted_mission_ids[i]
#         mission = db.reference(f"missions/{mission_id}").get()
#         if mission is not None:
#             missions[str(mission_id)] = mission

#     # ページング情報を追加
#     paging_info = {
#         "current_page": start_after // limit + 1,
#         "total_pages": (total_missions + limit - 1) // limit,
#     }

#     return {"missions": missions, "paging_info": paging_info}


# def get_all_missions() -> schemas.AllMissionsResponse:
#     ref_missions = db.reference("missions")
#     mission_ids = ref_missions.get(shallow=True)

#     if not mission_ids:
#         raise HTTPException(status_code=404, detail="No missions found")

#     missions = {}
#     for mission_id in mission_ids.keys():
#         mission = db.reference(f"missions/{mission_id}").get()
#         if mission is not None:
#             missions[mission_id] = schemas.Mission(**mission)

#     return schemas.AllMissionsResponse(missions=missions)
