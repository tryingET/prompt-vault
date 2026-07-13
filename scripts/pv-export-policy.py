#!/usr/bin/env python3
"""Classify active Prompt Vault Pi-export candidates for raw-file projection."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

SAFE_NAME = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")
ARTIFACT_KINDS = {"cognitive", "procedure"}  # session has no raw-execution contract
CONTROL_MODES = {"one_shot", "router", "loop"}
FORMALIZATION_LEVELS = {"napkin", "bounded", "structured", "workflow"}
COMPANIES = {"core", "software", "finance", "house", "health", "teaching", "holding"}
DEFAULT_DIMENSIONS = {
    "routing_context": ["analysis_followup", "review_followup", "review_closeout"],
    "activity_phase": ["post_analysis", "post_review", "closeout"],
    "input_artifact": ["analysis_output", "review_findings", "review_summary"],
    "transition_target_type": ["framework_mode"],
    "selection_principles": ["evidence_based", "constraint_preserving", "minimal_change"],
    "output_commitment": ["exact_next_prompt"],
}


def parse_json_value(value: Any) -> Any:
    if not isinstance(value, str):
        return value
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return object()


def load_contract(path: str | None) -> tuple[dict[str, set[str]], list[str]]:
    if path:
        payload = json.loads(Path(path).read_text())
        dimensions = payload.get("dimensions", {})
        required = payload.get("router_required_dimensions", list(dimensions))
    else:
        dimensions = DEFAULT_DIMENSIONS
        required = list(DEFAULT_DIMENSIONS)
    return ({key: set(values) for key, values in dimensions.items()}, list(required))


def valid_vocabulary(control: str, value: Any, dimensions: dict[str, set[str]], required: list[str]) -> bool:
    value = parse_json_value(value)
    if value is None:
        return control != "router"
    if not isinstance(value, dict) or any(key not in dimensions for key in value):
        return False
    if control == "router" and any(key not in value for key in required):
        return False
    for key, candidate in value.items():
        allowed = dimensions[key]
        if key == "selection_principles":
            if not isinstance(candidate, list) or not candidate or any(not isinstance(item, str) or item not in allowed for item in candidate):
                return False
        elif not isinstance(candidate, str) or candidate not in allowed:
            return False
    return True


def content_bytes(content: str) -> bytes:
    return (content.rstrip("\n") + "\n").encode("utf-8")


def classify(row: dict[str, Any], dimensions: dict[str, set[str]], required: list[str]) -> dict[str, Any]:
    name = row.get("name")
    content = row.get("content")
    artifact = row.get("artifact_kind")
    control = row.get("control_mode")
    formalization = row.get("formalization_level")
    owner = row.get("owner_company")
    visibility = parse_json_value(row.get("visibility_companies"))
    vocabulary = parse_json_value(row.get("controlled_vocabulary"))
    try:
        version = int(row.get("version") or 0)
    except (TypeError, ValueError):
        version = 0

    malformed = (
        not isinstance(name, str)
        or not SAFE_NAME.fullmatch(name)
        or not isinstance(content, str)
        or not content.strip()
        or version <= 0
        or not isinstance(artifact, str)
        or not isinstance(control, str)
        or not isinstance(formalization, str)
        or not isinstance(owner, str)
        or not isinstance(visibility, list)
    )
    unknown = (
        not malformed
        and (
            artifact not in ARTIFACT_KINDS
            or control not in CONTROL_MODES
            or formalization not in FORMALIZATION_LEVELS
            or owner not in COMPANIES
            or not visibility
            or owner not in visibility
            or any(company not in COMPANIES for company in visibility)
            or not valid_vocabulary(control, vocabulary, dimensions, required)
        )
    )
    reason = None
    if malformed:
        reason = "malformed"
    elif unknown:
        reason = "unknown"
    elif control == "loop":
        reason = "unbound"
    elif formalization == "workflow":
        reason = "gated"

    source = content if isinstance(content, str) else ""
    result = {
        "name": name if isinstance(name, str) else "",
        "version": version,
        "content_sha256": hashlib.sha256(source.encode("utf-8")).hexdigest(),
        "facets": {
            "artifact_kind": artifact,
            "control_mode": control,
            "formalization_level": formalization,
            "owner_company": owner,
            "visibility_companies": visibility if isinstance(visibility, list) else None,
            "controlled_vocabulary": vocabulary if isinstance(vocabulary, dict) else None,
        },
        "disposition": "quarantined" if reason else "exported",
    }
    if reason:
        result["reason"] = reason
    else:
        result.update({"path": f"{name}.md", "projected_sha256": hashlib.sha256(content_bytes(source)).hexdigest(), "content": source})
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--controlled-vocabulary-contract")
    args = parser.parse_args()
    dimensions, required = load_contract(args.controlled_vocabulary_contract)
    payload = json.load(sys.stdin)
    rows = payload.get("rows", []) if isinstance(payload, dict) else []
    if not isinstance(rows, list):
        raise SystemExit("Prompt Vault query JSON must contain a rows array")
    candidates = sorted((classify(row, dimensions, required) for row in rows if isinstance(row, dict)), key=lambda item: item["name"])
    exported = [item for item in candidates if item["disposition"] == "exported"]
    quarantined = [item for item in candidates if item["disposition"] == "quarantined"]
    json.dump({"policy": "prompt-vault/raw-pi-projection-policy/v1", "candidate_count": len(candidates), "exported_count": len(exported), "quarantined_count": len(quarantined), "exported": exported, "quarantined": quarantined}, sys.stdout, sort_keys=True, separators=(",", ":"))
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
