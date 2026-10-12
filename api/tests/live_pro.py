"""Making a test photographer live, for tests that book them.

Only a live photographer - onboarding approved for the public - may turn a
request into a booking (app/services/booking_answer.py). Activating is not
enough; that still waits on an admin. Tests about booking, rather than about
onboarding, make their photographer live with this.
"""
import uuid

from app.models.launch_ops import ProOnboarding, ProOnboardingStatus


def make_live(db_session, pro_user_id) -> None:
    pro_uuid = uuid.UUID(str(pro_user_id))
    onboarding = db_session.get(ProOnboarding, pro_uuid)
    if onboarding is None:
        onboarding = ProOnboarding(pro_user_id=pro_uuid, current_city={"city": "Lisbon", "country": "PT"})
        db_session.add(onboarding)
    onboarding.status = ProOnboardingStatus.approved_public
    db_session.commit()
