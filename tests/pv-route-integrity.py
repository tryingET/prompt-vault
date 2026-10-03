"""Behavioral regressions for missing, retired, hidden, and incidental references."""
import importlib.machinery
import importlib.util
from pathlib import Path
import unittest

path = Path(__file__).resolve().parents[1] / "scripts/pv-route-check"
loader = importlib.machinery.SourceFileLoader("routes", str(path))
spec = importlib.util.spec_from_loader(loader.name, loader)
routes = importlib.util.module_from_spec(spec)
loader.exec_module(routes)
POLICY = {"required_callers": ["front-door"], "route_table_headers": ["Detected state | Selected procedure / read path"]}


def row(name, content="", **changes):
    return {"name": name, "content": content, "status": "active", "export_to_pi": True,
            "visibility_companies": ["software"], **changes}


class RoutesTest(unittest.TestCase):
    def setUp(self):
        self.caller = row("front-door", "| Detected state | Selected procedure / read path |\n|---|---|\n| `review` | `review-next` |\n\nHistorical example: `retired-example`.\n")
        self.target = row("review-next")

    def test_available_route_and_incidental_prose(self):
        result = routes.validate([self.caller, self.target], POLICY)
        self.assertTrue(result["ok"])
        self.assertEqual(len(result["edges"]), 1)

    def test_missing_archived_or_unexported_target(self):
        for target in (None, row("review-next", status="archived"), row("review-next", export_to_pi=False)):
            with self.subTest(target=target):
                self.assertFalse(routes.validate([self.caller] + ([target] if target else []), POLICY)["ok"])

    def test_company_visibility(self):
        self.assertFalse(routes.validate([self.caller, row("review-next", visibility_companies=["core"])], POLICY)["ok"])

    def test_retirement_guard(self):
        self.assertFalse(routes.validate([self.caller, self.target], POLICY, "review-next")["ok"])
        self.assertTrue(routes.validate([self.caller, self.target], POLICY, "retired-example")["ok"])

    def test_removed_table_cannot_silently_erase_coverage(self):
        self.assertFalse(routes.validate([row("front-door"), self.target], POLICY)["ok"])

    def test_all_named_alternatives_are_checked(self):
        self.caller["content"] += "\n| Detected state | Selected procedure / read path |\n|---|---|\n| alternate | `review-next` or `missing-next` |\n"
        self.assertFalse(routes.validate([self.caller, self.target], POLICY)["ok"])


if __name__ == "__main__":
    unittest.main()
