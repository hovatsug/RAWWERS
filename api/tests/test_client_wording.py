"""Client credit is shown in euros ("€5.00 credit"), never as RAW, RAWW or
points (owner's decision, 2026-11-07). RAWW is the photographers' unit and
stays in the pro app. This guards every string the client can be shown from
the modules that talk to clients about credit: error messages, notification
titles and bodies. Docstrings and identifier-like strings (keys, event
names) are not shown to anyone and are skipped."""
import ast
import re
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
CLIENT_BOUND = [
    "app/services/rewards.py",
    "app/services/client_credit.py",
    "app/services/client_rewards_pricing.py",
    "app/services/marketing_consent.py",
    "app/services/selection_addons.py",
    "app/services/notifications.py",
    "app/api/v1/rewards.py",
    "app/api/v1/gigs.py",
    "app/api/v1/client_launch.py",
    "app/api/v1/client_credit.py",
    "app/api/v1/marketing_consent.py",
    "app/api/v1/proof_galleries.py",
]
FORBIDDEN = re.compile(r"\b(RAW|RAWW|RAWWs|points?)\b", re.IGNORECASE)


def shown_strings(source: str):
    tree = ast.parse(source)
    docstrings = {
        id(node.body[0].value)
        for node in ast.walk(tree)
        if isinstance(node, (ast.Module, ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef))
        and node.body and isinstance(node.body[0], ast.Expr) and isinstance(node.body[0].value, ast.Constant)
    }
    for node in ast.walk(tree):
        if isinstance(node, ast.Constant) and isinstance(node.value, str) and id(node) not in docstrings:
            if not re.fullmatch(r"[a-z0-9_.:\-]+", node.value):
                yield node.lineno, node.value


@pytest.mark.parametrize("path", CLIENT_BOUND)
def test_no_client_bound_text_says_raw_raww_or_points(path):
    hits = [f"{path}:{line}: {text!r}" for line, text in shown_strings((ROOT / path).read_text()) if FORBIDDEN.search(text)]
    assert hits == [], "client credit is euros:\n" + "\n".join(hits)


def test_the_guard_catches_the_words_and_spares_rawwers():
    found = [t for _l, t in shown_strings('X = "Not enough points"\nY = "Earn RAW credit"\nZ = "RAWWERS"\nW = "100 RAWW"')]
    assert [t for t in found if FORBIDDEN.search(t)] == ["Not enough points", "Earn RAW credit", "100 RAWW"]


def test_a_credit_taken_back_is_told_in_euros(db_session):
    from app.services.client_rewards_pricing import _credit_eur

    assert str(_credit_eur(db_session, 150)) == "1.50"
