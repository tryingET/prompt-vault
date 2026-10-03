"""Discovery regressions for existing continuity methods and distinct custody."""
import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest

path = Path(__file__).resolve().parents[1] / "scripts/pv-discover"
loader = importlib.machinery.SourceFileLoader("discovery", str(path))
spec = importlib.util.spec_from_loader(loader.name, loader)
discovery = importlib.util.module_from_spec(spec)
loader.exec_module(discovery)


class DiscoveryTest(unittest.TestCase):
    def test_natural_continuity_finds_existing_workflow_and_exposes_gate(self):
        rows = [{"name": "repo-next-session", "description": "Repo continuity", "content": "Recover current truth.",
                 "version": 5, "status": "active", "export_to_pi": True,
                 "control_mode": "one_shot", "formalization_level": "workflow",
                 "owner_company": "core", "visibility_companies": ["core"]}]
        results = discovery.rank_rows("where did we leave off?", rows, [], "core")
        self.assertEqual(results[0]["name"], "repo-next-session")
        self.assertEqual(results[0]["dispatch_requirement"], "downstream_workflow_or_loop_gate")
        self.assertEqual(results[0]["runtime_binding"], "not_checked")
        self.assertEqual(results[0]["accepted_outcome"], "not_checked")

    def test_unpublished_and_archived_never_become_client_eligible(self):
        for status, exported in (("active", False), ("archived", True)):
            rows = [{"name": "napkin", "status": status, "export_to_pi": exported}]
            self.assertFalse(discovery.rank_rows("napkin", rows, [])[0]["client_lookup_eligible"])

    def test_explicit_company_filters_invisible_vault_entities(self):
        rows = [{"name": "napkin", "status": "active", "visibility_companies": ["software"]}]
        self.assertEqual(discovery.rank_rows("napkin", rows, [], "core"), [])

    def test_snapshot_and_template_are_distinct_matches(self):
        row = {"name": "napkin", "status": "active"}
        results = discovery.rank_rows("napkin", [row], [row])
        self.assertEqual({r["kind"] for r in results}, {"template", "skill_snapshot"})
        self.assertEqual(results[1]["installed"], "not_checked")

    def test_active_root_aliases_deduplicate_original_source(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            skill = root / "skills" / "napkin"
            skill.mkdir(parents=True)
            (skill / "SKILL.md").write_text("---\nname: napkin\ndescription: Explore a small idea.\n---\nBody\n")
            alias = root / "alias"
            alias.symlink_to(root / "skills", target_is_directory=True)
            results, errors = discovery.local_skills("napkin", [("pi", root / "skills"), ("codex", alias)])
            self.assertEqual(errors, [])
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0]["client_roots"], ["pi", "codex"])
            self.assertEqual(results[0]["custody"], "filesystem_package")
            self.assertEqual(results[0]["authoring_owner"], "not_checked")
            self.assertEqual(results[0]["installed"], "not_checked")


if __name__ == "__main__":
    unittest.main()
