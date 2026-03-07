#!/usr/bin/env bats
# Tests for Prompt Vault v2 ontology contract pack

load 'setup'

@test "pv-verify-ontology-contract validates the contract pack" {
    run "$SCRIPTS_DIR/pv-verify-ontology-contract"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Ontology contract verified"* ]]
}
