"""Two names ruff found undefined (2026-11-17), each shown failing first.

- `score_summary` (services/search_indexing.py): the repair-partner index
  document's `return` had ended up, unreachable, at the end of the content
  pack builder, so `build_repair_partner_document` always returned None and
  every repair partner was deleted from the search index instead of written.
- `CertificateView` (api/v1/courses.py): `GET /v1/learn/certificates/mine`
  answered 500 for anyone holding a certificate (never imported).
"""
import uuid

from app.models.admin import UserRoleType
from app.models.learning import Certificate, CertificateType, CurriculumPath
from app.services.search_indexing import build_content_pack_document, build_repair_partner_document
from tests.test_repairs_v0 import _create_partner
from tests.test_niche_skill_matrix_v2 import _ensure_user_role


def test_an_active_repair_partner_gets_a_search_document(db_session):
    partner = _create_partner(db_session, city="Porto")
    doc = build_repair_partner_document(db_session, partner.id)
    assert doc is not None, "an active partner was indexed as deleted"
    assert doc["id"] == str(partner.id) and doc["name"] == "Partner Porto" and doc["city"] == "Porto"
    assert set(doc["score_summary"]) == {"avg_quote_hours", "avg_turnaround_days", "loaner_fulfillment_rate"}


def test_an_inactive_repair_partner_has_none(db_session):
    partner = _create_partner(db_session)
    partner.is_active = False
    db_session.commit()
    assert build_repair_partner_document(db_session, partner.id) is None


def test_a_missing_content_pack_has_none(db_session):
    assert build_content_pack_document(db_session, uuid.uuid4()) is None


def test_my_certificates_lists_a_certificate(client, db_session):
    user_id = uuid.uuid4()
    _ensure_user_role(db_session, user_id, UserRoleType.pro)
    path = CurriculumPath(niche_slug="portraits", name="Path", is_active=True)
    db_session.add(path)
    db_session.flush()
    db_session.add(Certificate(user_id=user_id, certificate_type=CertificateType.curriculum, curriculum_path_id=path.id,
                               course_id=None, niche_slug="portraits", certificate_code=f"CUR-{uuid.uuid4().hex[:8]}",
                               verification_code=f"VC-{uuid.uuid4().hex[:8]}", meta={}))
    db_session.commit()
    resp = client.get("/v1/learn/certificates/mine", headers={"X-User-Id": str(user_id)})
    assert resp.status_code == 200, resp.text
    assert resp.json()["total"] == 1
