#!/usr/bin/env bats
# Verify the canonical teacher-prep media prompt layer remains anchored in Prompt Vault

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "teacher-prep media templates exist with canonical metadata" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "
        SELECT COUNT(*)
        FROM prompt_templates
        WHERE name IN (
            'teacher-prep-media-image-pack',
            'teacher-prep-media-storyboard',
            'teacher-prep-media-video-prompt'
        )
          AND artifact_kind = 'procedure'
          AND control_mode = 'one_shot'
          AND formalization_level = 'structured'
          AND owner_company = 'software'
          AND status = 'active'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *$'3' ]]
}

@test "teacher-prep image-pack template keeps image-first Teaching Pack planning visible" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT content FROM prompt_templates WHERE name = 'teacher-prep-media-image-pack' LIMIT 1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"image-first"* ]]
    [[ "$output" == *"Teaching Pack"* ]]
    [[ "$output" == *"Do not assume video generation happened."* ]]
}

@test "teacher-prep storyboard template keeps zero-clip honesty visible" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT content FROM prompt_templates WHERE name = 'teacher-prep-media-storyboard' LIMIT 1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Keep the storyboard usable even when no video clips exist."* ]]
    [[ "$output" == *"Do not invent runtime receipts or generated assets."* ]]
    [[ "$output" == *"Degraded-Mode Honesty Note"* ]]
}

@test "teacher-prep video-prompt template keeps clip optionality and honesty visible" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT content FROM prompt_templates WHERE name = 'teacher-prep-media-video-prompt' LIMIT 1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Treat clips as optional follow-on outputs."* ]]
    [[ "$output" == *"Do not claim clips were generated."* ]]
    [[ "$output" == *"Degraded-Mode Honesty Note"* ]]
}
