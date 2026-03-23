#!/usr/bin/env bats
# Tests for Prompt Vault ontology contract pack

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "pv-verify-ontology-contract validates the contract pack" {
    run "$SCRIPTS_DIR/pv-verify-ontology-contract"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Ontology contract verified"* ]]
}

@test "pv-verify-ontology-contract rejects prompt-body keys in seed prompt metadata" {
    tmpdir=$(make_test_tmpdir)
    cp "$BATS_TEST_DIRNAME/../ontology/v2-contract.json" "$tmpdir/v2-contract.json"
    cp "$BATS_TEST_DIRNAME/../ontology/controlled-vocabulary-contract.json" "$tmpdir/controlled-vocabulary-contract.json"
    cp "$BATS_TEST_DIRNAME/../ontology/company-visibility-contract.json" "$tmpdir/company-visibility-contract.json"
    cp "$BATS_TEST_DIRNAME/../ontology/index.md" "$tmpdir/index.md"

    python3 - "$tmpdir/v2-contract.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["seed_prompts"][0]["content"] = "DECIDE\nNEXT PROMPT: leaked body"
path.write_text(json.dumps(data, indent=2) + "\n")
PY

    run env \
        PV_ONTOLOGY_CONTRACT_PATH="$tmpdir/v2-contract.json" \
        PV_CONTROLLED_CONTRACT_PATH="$tmpdir/controlled-vocabulary-contract.json" \
        PV_COMPANY_CONTRACT_PATH="$tmpdir/company-visibility-contract.json" \
        PV_ONTOLOGY_INDEX_PATH="$tmpdir/index.md" \
        PV_VAULT_DIR="$VAULT_DIR" \
        "$SCRIPTS_DIR/pv-verify-ontology-contract"
    [ "$status" -ne 0 ]
    [[ "$output" == *"seed_prompts entries must stay metadata-only"* ]]
}

@test "pv-verify-ontology-contract rejects ontology index drift that hides the DB-only boundary" {
    tmpdir=$(make_test_tmpdir)
    cp "$BATS_TEST_DIRNAME/../ontology/v2-contract.json" "$tmpdir/v2-contract.json"
    cp "$BATS_TEST_DIRNAME/../ontology/controlled-vocabulary-contract.json" "$tmpdir/controlled-vocabulary-contract.json"
    cp "$BATS_TEST_DIRNAME/../ontology/company-visibility-contract.json" "$tmpdir/company-visibility-contract.json"
    cp "$BATS_TEST_DIRNAME/../ontology/index.md" "$tmpdir/index.md"

    python3 - "$tmpdir/index.md" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text()
text = text.replace(
    "- prompt bodies are **not** part of ontology; inspect the canonical DB content with `./scripts/pv show template <name>` when you need seeded router text\n",
    "",
)
path.write_text(text)
PY

    run env \
        PV_ONTOLOGY_CONTRACT_PATH="$tmpdir/v2-contract.json" \
        PV_CONTROLLED_CONTRACT_PATH="$tmpdir/controlled-vocabulary-contract.json" \
        PV_COMPANY_CONTRACT_PATH="$tmpdir/company-visibility-contract.json" \
        PV_ONTOLOGY_INDEX_PATH="$tmpdir/index.md" \
        PV_VAULT_DIR="$VAULT_DIR" \
        "$SCRIPTS_DIR/pv-verify-ontology-contract"
    [ "$status" -ne 0 ]
    [[ "$output" == *"ontology index must keep the DB-only authoring boundary explicit"* ]]
}
