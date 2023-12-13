from fastapi import HTTPException
from firebase_admin import db


def get_mission(mission_id: str):
    ref_mission = db.reference(f"missions/{mission_id}")
    return ref_mission.get()


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


def update_mission(mission_id: str, mission):
    ref_mission = db.reference(f"missions/{mission_id}")
    ref_mission.update(mission.model_dump())


def delete_mission(mission_id: str):
    ref_mission = db.reference(f"missions/{mission_id}")
    ref_mission.delete()

    ref_deleted_missions = db.reference("deletedMissions")
    deleted_missions = ref_deleted_missions.get() or []
    deleted_missions.append(mission_id)
    ref_deleted_missions.set(deleted_missions)

    ref_deleted_missions_count = db.reference("deletedMissionsCount")
    ref_deleted_missions_count.transaction(lambda count: (count or 0) + 1)


def get_missions(limit: int = 10, start_after: int = 0):
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


def get_all_missions():
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
