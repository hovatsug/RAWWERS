"""Admin: the camera reference table.

The table decides whether a body verifies on upload or waits for a person, and
a fresh production database has it empty: the seed script refuses to run
there. So the test that matters is the first one - an empty table sends a
real camera file to the review queue, and an import through the admin
endpoint is enough for the next one to verify with nobody looking.
"""
import uuid

from app.models.admin import AdminAuditLog
from app.models.gear_verification import CameraModelReference, SensorSize
from app.services.gear_verify import normalise_model
from sqlalchemy import select

from tests.test_gear_intake import _admin, _by_category, _fx, _h, _new_pro, _submit_frame, storage  # noqa: F401

URL = "/v1/admin/camera-models"


def _import(client, admin_id, text: str, *, apply: bool, reason: str | None = None):
    return client.post(f"{URL}/import", headers=_h(admin_id), json={"csv": text, "apply": apply, "reason": reason})


def _rows(db_session) -> dict[str, CameraModelReference]:
    db_session.expire_all()
    return {r.normalised_model: r for r in db_session.execute(select(CameraModelReference)).scalars()}


def _audit(db_session, action: str) -> list[AdminAuditLog]:
    db_session.expire_all()
    return list(db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == action)).scalars())


def _body_status(client, storage, pro_id) -> str:
    body = _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head")).json()
    return _by_category(body["items"], "camera_body")[0]["status"]


# ---------------------------------------------------------------------------
# The production blocker, end to end.
# ---------------------------------------------------------------------------


def test_with_the_table_empty_a_full_frame_body_waits_for_a_person(client, db_session, storage):
    assert _body_status(client, storage, _new_pro(db_session)) == "pending_review"


def test_an_import_through_the_admin_is_enough_for_the_next_body_to_verify_itself(client, db_session, storage):
    admin_id = _admin(db_session)
    resp = _import(client, admin_id, "make,model,display_name,sensor_size\nCanon,Canon EOS R5,Canon EOS R5,full_frame\n", apply=True)
    assert resp.status_code == 200, resp.text
    assert resp.json()["applied"] is True

    assert _body_status(client, storage, _new_pro(db_session)) == "verified"


def test_a_model_added_by_hand_is_found_however_the_camera_spells_it(client, db_session, storage):
    admin_id = _admin(db_session)
    resp = client.post(URL, headers=_h(admin_id), json={"model": "canon eos-r5", "sensor_size": "full_frame"})
    assert resp.status_code == 200, resp.text
    assert resp.json()["normalised_model"] == normalise_model("Canon EOS R5")

    assert _body_status(client, storage, _new_pro(db_session)) == "verified"


# ---------------------------------------------------------------------------
# Import: checked whole, then all or nothing.
# ---------------------------------------------------------------------------


def test_checking_an_import_writes_nothing_and_says_what_would_happen(client, db_session):
    admin_id = _admin(db_session)
    db_session.add(CameraModelReference(normalised_model="ilce7m4", make="Sony", display_name="Sony A7 IV", sensor_size=SensorSize.full_frame))
    db_session.commit()

    text = (
        "make,model,display_name,sensor_size\n"
        "Sony,ILCE-7M4,Sony A7 IV,full_frame\n"  # already there, the same
        "Sony,ILCE-7M3,Sony A7 III,full_frame\n"  # new
        "Fujifilm,X-T4,Fujifilm X-T4,crop\n"  # new
    )
    resp = _import(client, admin_id, text, apply=False)

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert (body["create"], body["update"], body["unchanged"], body["errors"]) == (2, 0, 1, 0)
    assert body["applied"] is False
    assert set(_rows(db_session)) == {"ilce7m4"}, "a check must not write"
    assert _audit(db_session, "camera_models_imported") == []


def test_one_bad_row_stops_the_whole_import_and_names_the_line(client, db_session):
    admin_id = _admin(db_session)
    text = (
        "model,sensor_size\n"
        "ILCE-7M3,full_frame\n"
        "ILCE-7M4,full frame\n"  # a space is forgiven
        "X-T4,aps-c\n"  # not a sensor size we know
        ",crop\n"  # no model
        "ilce 7m3,crop\n"  # the same body as line 2
    )
    check = _import(client, admin_id, text, apply=False).json()
    errors = {line["line"]: line["error"] for line in check["lines"] if line["outcome"] == "error"}
    assert set(errors) == {4, 5, 6}
    assert "full_frame" in errors[4]
    assert "line 2" in errors[6]
    assert check["create"] == 2

    applied = _import(client, admin_id, text, apply=True)
    assert applied.status_code == 422
    assert _rows(db_session) == {}, "an import with a bad row must write none of its rows"


def test_a_file_without_the_columns_is_refused(client, db_session):
    resp = _import(client, _admin(db_session), "camera,size\nILCE-7M4,full_frame\n", apply=False)
    assert resp.status_code == 422
    assert "model" in resp.json()["error"]["message"]


def test_an_import_that_changes_a_sensor_size_needs_a_reason_and_records_the_old_one(client, db_session):
    admin_id = _admin(db_session)
    db_session.add(CameraModelReference(normalised_model="ilce7m4", make="Sony", display_name="Sony A7 IV", sensor_size=SensorSize.crop))
    db_session.commit()
    text = "make,model,display_name,sensor_size\nSony,ILCE-7M4,Sony A7 IV,full_frame\n"

    check = _import(client, admin_id, text, apply=False).json()
    assert check["changes_sensor_size"] is True
    assert check["lines"][0]["before"]["sensor_size"] == "crop"

    assert _import(client, admin_id, text, apply=True).status_code == 422
    assert _rows(db_session)["ilce7m4"].sensor_size == SensorSize.crop

    done = _import(client, admin_id, text, apply=True, reason="The A7 IV is full-frame; the row was wrong")
    assert done.status_code == 200, done.text
    assert _rows(db_session)["ilce7m4"].sensor_size == SensorSize.full_frame
    [entry] = _audit(db_session, "camera_models_imported")
    assert entry.reason == "The A7 IV is full-frame; the row was wrong"
    assert entry.meta["updated"][0]["before"]["sensor_size"] == "crop"
    assert entry.actor_user_id == admin_id


def test_the_downloaded_list_imports_back_unchanged(client, db_session):
    """The way production gets the list: download it from a database that has
    it, import it into one that does not. The two must agree on the format."""
    admin_id = _admin(db_session)
    for key, make, name, sensor in [
        ("ilce7m4", "Sony", "Sony A7 IV", SensorSize.full_frame),
        ("xt4", "Fujifilm", "Fujifilm X-T4, \"crop\"", SensorSize.crop),
        ("gfx100s", None, "Fujifilm GFX100S", SensorSize.medium_format),
    ]:
        db_session.add(CameraModelReference(normalised_model=key, make=make, display_name=name, sensor_size=sensor))
    db_session.commit()

    items = client.get(URL, headers=_h(admin_id)).json()["items"]
    # The page writes exactly these columns, quoting as CSV does.
    import csv
    import io

    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(["make", "model", "display_name", "sensor_size"])
    for item in items:
        writer.writerow([item["make"] or "", item["normalised_model"], item["display_name"], item["sensor_size"]])

    check = _import(client, admin_id, out.getvalue(), apply=False).json()
    assert (check["create"], check["update"], check["unchanged"], check["errors"]) == (0, 0, 3, 0)


# ---------------------------------------------------------------------------
# Adding and editing by hand.
# ---------------------------------------------------------------------------


def test_adding_a_model_already_listed_is_refused_and_overwrites_nothing(client, db_session):
    admin_id = _admin(db_session)
    db_session.add(CameraModelReference(normalised_model="ilce7m4", make="Sony", display_name="Sony A7 IV", sensor_size=SensorSize.full_frame))
    db_session.commit()

    resp = client.post(URL, headers=_h(admin_id), json={"model": "ILCE-7M4", "sensor_size": "crop"})

    assert resp.status_code == 409
    assert "Sony A7 IV" in resp.json()["error"]["message"]
    assert _rows(db_session)["ilce7m4"].sensor_size == SensorSize.full_frame


def test_adding_is_audited(client, db_session):
    admin_id = _admin(db_session)
    client.post(URL, headers=_h(admin_id), json={"model": "ILCE-7M3", "make": "Sony", "display_name": "Sony A7 III", "sensor_size": "full_frame"})

    [entry] = _audit(db_session, "camera_model_added")
    assert entry.target_id == "ilce7m3"
    assert entry.meta["sensor_size"] == "full_frame"
    assert entry.actor_user_id == admin_id


def test_changing_a_sensor_size_by_hand_needs_a_reason_and_is_audited(client, db_session):
    admin_id = _admin(db_session)
    db_session.add(CameraModelReference(normalised_model="ilce7m4", make="Sony", display_name="Sony A7 IV", sensor_size=SensorSize.full_frame))
    db_session.commit()
    change = {"make": "Sony", "display_name": "Sony A7 IV", "sensor_size": "crop"}

    refused = client.put(f"{URL}/ilce7m4", headers=_h(admin_id), json=change)
    assert refused.status_code == 422
    assert _rows(db_session)["ilce7m4"].sensor_size == SensorSize.full_frame

    done = client.put(f"{URL}/ilce7m4", headers=_h(admin_id), json={**change, "reason": "Testing a correction"})
    assert done.status_code == 200, done.text
    assert _rows(db_session)["ilce7m4"].sensor_size == SensorSize.crop
    [entry] = _audit(db_session, "camera_model_edited")
    assert entry.reason == "Testing a correction"
    assert entry.meta["before"]["sensor_size"] == "full_frame"
    assert entry.meta["after"]["sensor_size"] == "crop"


def test_renaming_needs_no_reason(client, db_session):
    admin_id = _admin(db_session)
    db_session.add(CameraModelReference(normalised_model="ilce7m4", make="Sony", display_name="ILCE-7M4", sensor_size=SensorSize.full_frame))
    db_session.commit()

    resp = client.put(f"{URL}/ilce7m4", headers=_h(admin_id), json={"make": "Sony", "display_name": "Sony A7 IV", "sensor_size": "full_frame"})

    assert resp.status_code == 200, resp.text
    assert _rows(db_session)["ilce7m4"].display_name == "Sony A7 IV"


def test_editing_a_model_that_is_not_listed_is_a_404(client, db_session):
    resp = client.put(f"{URL}/nosuchcamera", headers=_h(_admin(db_session)), json={"display_name": "X", "sensor_size": "crop"})
    assert resp.status_code == 404


# ---------------------------------------------------------------------------
# Listing.
# ---------------------------------------------------------------------------


def test_search_finds_a_body_by_its_name_or_by_how_the_camera_spells_it(client, db_session):
    admin_id = _admin(db_session)
    for key, make, name, sensor in [
        ("ilce7m4", "Sony", "Sony A7 IV", SensorSize.full_frame),
        ("canoneosr5", "Canon", "Canon EOS R5", SensorSize.full_frame),
        ("xt4", "Fujifilm", "Fujifilm X-T4", SensorSize.crop),
    ]:
        db_session.add(CameraModelReference(normalised_model=key, make=make, display_name=name, sensor_size=sensor))
    db_session.commit()

    def names(**params):
        body = client.get(URL, headers=_h(admin_id), params=params).json()
        return [item["display_name"] for item in body["items"]], body["total"], body["full_frame"]

    assert names(q="a7 iv")[0] == ["Sony A7 IV"]
    assert names(q="ILCE 7M4")[0] == ["Sony A7 IV"]
    assert names(q="fujifilm")[0] == ["Fujifilm X-T4"]
    assert names(sensor_size="crop")[0] == ["Fujifilm X-T4"]
    # The totals describe the table, not the search.
    assert names(q="a7 iv")[1:] == (3, 2)


def test_only_an_admin_can_read_or_change_the_list(client, db_session):
    someone = uuid.uuid4()
    assert client.get(URL, headers=_h(someone)).status_code == 403
    assert client.post(URL, headers=_h(someone), json={"model": "ILCE-7M4", "sensor_size": "full_frame"}).status_code == 403
    assert _import(client, someone, "model,sensor_size\nILCE-7M4,full_frame\n", apply=True).status_code == 403
    assert client.put(f"{URL}/ilce7m4", headers=_h(someone), json={"display_name": "X", "sensor_size": "crop"}).status_code == 403
    assert _rows(db_session) == {}
