"""No module may use a name it never binds.

Four separate outages have now had this shape: a helper called or a type
referenced in a module that never imported it. The KYC 500, the
GearCategory one, log_event in media_rights.py (every GET on a public
share link answered 500), and CurrentUser in i18n.py - the last latent
only because `from __future__ import annotations` defers evaluation and
FastAPI tolerates the unresolved ForwardRef.

Python does not catch these at import time when the name sits inside a
function body or a deferred annotation, so nothing fails until the line
actually runs. This checks the class rather than the instances.
"""
import ast
import builtins
import pathlib

BUILTINS = set(dir(builtins))
APP = pathlib.Path(__file__).resolve().parents[1] / "app"


class _Bound(ast.NodeVisitor):
    """Every name bound anywhere in the module, at any scope.

    Deliberately over-broad - a name bound in some inner scope is not what
    this is hunting, and being generous here keeps the check free of the
    false positives that would get it disabled.
    """

    def __init__(self) -> None:
        self.names: set[str] = set()

    def visit_Import(self, node):
        for alias in node.names:
            self.names.add((alias.asname or alias.name).split(".")[0])

    def visit_ImportFrom(self, node):
        for alias in node.names:
            self.names.add(alias.asname or alias.name)

    def visit_FunctionDef(self, node):
        self.names.add(node.name)
        self._args(node.args)
        self.generic_visit(node)

    visit_AsyncFunctionDef = visit_FunctionDef

    def visit_Lambda(self, node):
        self._args(node.args)
        self.generic_visit(node)

    def _args(self, args):
        for arg in [*args.args, *args.posonlyargs, *args.kwonlyargs]:
            self.names.add(arg.arg)
        if args.vararg:
            self.names.add(args.vararg.arg)
        if args.kwarg:
            self.names.add(args.kwarg.arg)

    def visit_ClassDef(self, node):
        self.names.add(node.name)
        self.generic_visit(node)

    def visit_Name(self, node):
        if isinstance(node.ctx, (ast.Store, ast.Del)):
            self.names.add(node.id)

    def visit_ExceptHandler(self, node):
        if node.name:
            self.names.add(node.name)
        self.generic_visit(node)

    def visit_Global(self, node):
        self.names.update(node.names)

    def visit_Nonlocal(self, node):
        self.names.update(node.names)


def _unbound(path: pathlib.Path) -> list[tuple[int, str]]:
    tree = ast.parse(path.read_text())
    bound = _Bound()
    bound.visit(tree)
    seen: dict[str, int] = {}
    for node in ast.walk(tree):
        if isinstance(node, ast.Name) and isinstance(node.ctx, ast.Load):
            if node.id not in bound.names and node.id not in BUILTINS:
                seen.setdefault(node.id, node.lineno)
    return sorted((line, name) for name, line in seen.items())


def test_no_module_uses_a_name_it_never_binds():
    problems = [
        f"{path.relative_to(APP.parent)}:{line} uses {name!r} but never binds it"
        for path in sorted(APP.rglob("*.py"))
        for line, name in _unbound(path)
    ]
    assert not problems, "\n".join(problems)


def test_the_check_catches_a_missing_import(tmp_path):
    """Break it deliberately: the shape of the real bug must be rejected."""
    module = tmp_path / "broken.py"
    module.write_text("def handler(db):\n    log_event(db, event_name='x')\n")
    assert _unbound(module) == [(2, "log_event")]

    module.write_text("from app.services.analytics import log_event\n\n\ndef handler(db):\n    log_event(db)\n")
    assert _unbound(module) == []
