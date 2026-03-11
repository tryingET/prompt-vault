---
summary: "Generated codemap-style documentation inventory and structure snapshot."
read_when:
  - "Needing a broad structural snapshot of the repo"
  - "Auditing generated codemap outputs"
---

# `/home/tryinget/ai-society/core/prompt-vault` Documentation

Generated on: 2026-03-04 01:36:28

## Document Statistics
- Total files scanned: 122
- Total lines of code: 2612
- Languages: python

## Directory Structure
```
prompt-vault
├── .dolt/
│   └── tmp/
├── .gitlab/
│   ├── issue_templates/
│   │   └── SLICE.md
│   └── merge_request_templates/
│       └── CHANGE.md
├── .pi-subagent-sessions/
├── diary/
│   ├── 2026-03-03--ops-vault-recovery-checkpoint.md
│   ├── 2026-03-04--vault-client-hardening-closeout.md
│   └── README.md
├── docs/
│   ├── _core/
│   │   └── README.md
│   ├── decisions/
│   │   ├── ADR-0001-unified-fzf-selection-ptx-vault-client.md
│   │   └── README.md
│   ├── dev/
│   │   ├── fzf-spike-slice0.md
│   │   ├── slice4-validation-matrix.md
│   │   └── status.md
│   ├── learnings/
│   │   ├── .gitkeep
│   │   └── README.md
│   ├── org_context/
│   │   ├── org-summary.md
│   │   └── README.md
│   ├── project/
│   │   ├── mission.md
│   │   ├── model.md
│   │   ├── purpose.md
│   │   ├── strategic_goals.md
│   │   └── vision.md
│   ├── reference/
│   │   ├── fuzzy-selector-troubleshooting.md
│   │   └── prompt-snippets.md
│   ├── system4d/
│   │   ├── compass.md
│   │   ├── container.md
│   │   ├── engine.md
│   │   └── fog.md
│   ├── COMPARISON.md
│   ├── CRYSTALLIZED.md
│   └── WORKFLOWS.md
├── gitlab/
│   └── ci/
│       └── rocs.yml
├── governance/
│   ├── README.md
│   ├── work-items.cue
│   └── work-items.json
├── migrations/
│   └── .gitkeep
├── ontology/
│   ├── src/
│   │   ├── bridge/
│   │   │   ├── mapping.yaml
│   │   │   └── README.md
│   │   ├── reference/
│   │   │   └── concepts/
│   │   │       └── README.md
│   │   └── system4d.yaml
│   ├── index.md
│   └── manifest.yaml
├── policy/
│   └── .gitkeep
├── prompt-vault-db/
│   └── vault.yaml
├── schema/
│   └── schema.sql
├── scripts/
│   ├── ci/
│   │   ├── full.sh
│   │   └── smoke.sh
│   ├── .gitkeep
│   ├── export-to-pi.sh
│   ├── import-cognitive-tools.sh
│   ├── import-from-pi.sh
│   ├── init-vault.sh
│   ├── pv
│   ├── pv-analytics
│   ├── pv-backup
│   ├── pv-batch
│   ├── pv-collection
│   ├── pv-completion.bash
│   ├── pv-diff
│   ├── pv-exec
│   ├── pv-export-formats
│   ├── pv-hooks
│   ├── pv-integrate
│   ├── pv-lib.sh
│   ├── pv-lint
│   ├── pv-merge-conflicts
│   ├── pv-migrate
│   ├── pv-quality
│   ├── pv-quick
│   ├── pv-rate
│   ├── pv-scaffold
│   ├── pv-search
│   ├── pv-tag
│   ├── pv-tag-templates
│   ├── pv-template-vars
│   ├── pv-test
│   ├── pv-tui
│   └── rocs.sh
├── src/
│   └── .gitkeep
├── tests/
│   ├── .gitkeep
│   ├── pv-commands.bats
│   ├── pv-import.bats
│   ├── pv-lib.bats
│   ├── pv-lint.bats
│   ├── pv-scaffold.bats
│   └── setup.bash
├── tools/
│   └── rocs-cli/
│       ├── src/
│       │   └── rocs_cli/
│       │       ├── __init__.py
│       │       ├── __main__.py
│       │       ├── cache.py
│       │       ├── cli.py
│       │       ├── cli_signature.py
│       │       ├── frontmatter.py
│       │       ├── gitlab.py
│       │       ├── graph.py
│       │       ├── id_index.py
│       │       ├── inverses.py
│       │       ├── layers.py
│       │       ├── lint.py
│       │       ├── model.py
│       │       ├── normalize.py
│       │       ├── pack.py
│       │       ├── rules.py
│       │       ├── validate.py
│       │       └── vendored.py
│       ├── .gitignore
│       ├── pyproject.toml
│       ├── README.md
│       └── VENDORED_HASHES.json
├── .codemap.yml
├── .copier-answers.yml
├── .gitignore
├── .gitlab-ci.yml
├── AGENTS.md
├── CHANGELOG.md
├── codemap.txt
├── codemap_level3.txt
├── CODEOWNERS
├── LICENSE
├── next_session_prompt.md
├── QUICKSTART.md
├── README.md
├── SKILL.md
└── verify.sh
```

## Entity Relationships
```mermaid
graph LR

  %% Legend
  subgraph Legend
    direction LR
    legend_module["Module/File"]
    legend_func("Function/Method")
    legend_const["Constant"]
    legend_import_ext(("External Import"))
  end


  %% Global Nodes
  dep_argparse(("argparse"))
  dep_hashlib(("hashlib"))
  dep_json(("json"))
  dep_os(("os"))
  dep_re(("re"))
  dep_shutil(("shutil"))
  dep_tarfile(("tarfile"))
  dep_tempfile(("tempfile"))
  dep_time(("time"))
  dep_yaml(("yaml"))

  %% Subgraphs
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli___init___py_1__anonymous_module_["<anonymous-module>"]
  direction LR
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli___main___py_1__anonymous_module_["<anonymous-module>"]
  direction LR
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_10_cache_dir("cache_dir")
  unknown_file_20_CacheEntry("CacheEntry")
  unknown_file_26__dir_size_bytes("_dir_size_bytes")
  unknown_file_37_list_cache_entries("list_cache_entries")
  unknown_file_51_clear_cache("clear_cache")
  unknown_file_57_prune_cache("prune_cache")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_35__filter_layers("_filter_layers")
  unknown_file_46__maybe_load_env_file("_maybe_load_env_file")
  unknown_file_54__findings_to_json("_findings_to_json")
  unknown_file_58__print_findings("_print_findings")
  unknown_file_67__write_resolve_artifact("_write_resolve_artifact")
  unknown_file_97_cmd_version("cmd_version")
  unknown_file_102_cmd_resolve("cmd_resolve")
  unknown_file_124_cmd_summary("cmd_summary")
  unknown_file_147_cmd_validate("cmd_validate")
  unknown_file_200_cmd_build("cmd_build")
  unknown_file_226_cmd_pack("cmd_pack")
  unknown_file_277_cmd_lint("cmd_lint")
  unknown_file_305_cmd_check_inverses("cmd_check_inverses")
  unknown_file_325_cmd_graph("cmd_graph")
  unknown_file_358_cmd_cache("cmd_cache")
  unknown_file_378_cmd_vendored_check("cmd_vendored_check")
  unknown_file_392_cmd_normalize("cmd_normalize")
  unknown_file_419__diff_sets("_diff_sets")
  unknown_file_425_cmd_diff("cmd_diff")
  unknown_file_493_build_parser("build_parser")
  unknown_file_642_main("main")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_signature_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_8_CliCommandSig("CliCommandSig")
  unknown_file_14__sorted_unique("_sorted_unique")
  unknown_file_25_cli_signature("cli_signature")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_9_FRONT_RE["FRONT_RE"]
  unknown_file_12_split_frontmatter("split_frontmatter")
  unknown_file_20_load_frontmatter("load_frontmatter")
  unknown_file_28_dump_frontmatter("dump_frontmatter")
  unknown_file_35_write_doc("write_doc")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_14_load_env_file("load_env_file")
  unknown_file_37_gitlab_base_url("gitlab_base_url")
  unknown_file_46_gitlab_headers("gitlab_headers")
  unknown_file_56_fetch_repo_archive("fetch_repo_archive")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_10_GraphEdge("GraphEdge")
  unknown_file_17_build_edges("build_edges")
  unknown_file_36_collapse_nodes("collapse_nodes")
  unknown_file_43_map_id("map_id")
  unknown_file_57_compute_layout("compute_layout")
  unknown_file_116_export_dot("export_dot")
  unknown_file_126_export_excalidraw("export_excalidraw")
  unknown_file_243_export_excalidraw_cli_json("export_excalidraw_cli_json")
  unknown_file_249_write_graph("write_graph")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_id_index_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_6__path_in_layer("_path_in_layer")
  unknown_file_15_build_id_index("build_id_index")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_inverses_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_8_check_inverses("check_inverses")
  unknown_file_16_first_label("first_label")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_12_GITLAB_REF_RE["GITLAB_REF_RE"]
  unknown_file_15_LayerSpec("LayerSpec")
  unknown_file_23_repo_root("repo_root")
  unknown_file_27_ontology_root("ontology_root")
  unknown_file_31_manifest_path("manifest_path")
  unknown_file_35_dist_dir("dist_dir")
  unknown_file_39_load_manifest("load_manifest")
  unknown_file_46_parse_gitlab_ref("parse_gitlab_ref")
  unknown_file_53__src_root_for_ref("_src_root_for_ref")
  unknown_file_66_resolve_layers("resolve_layers")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_lint_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_9_PLACEHOLDER_RE["PLACEHOLDER_RE"]
  unknown_file_12__ignored("_ignored")
  unknown_file_19_lint_docs("lint_docs")
  unknown_file_22_has_placeholder("has_placeholder")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_10_OntDoc("OntDoc")
  unknown_file_31_iter_reference_md("iter_reference_md")
  unknown_file_43_iter_md("iter_md")
  unknown_file_52_load_doc("load_doc")
  unknown_file_57_collect_docs("collect_docs")
  unknown_file_78_relation_label_index("relation_label_index")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_9_CONCEPT_KEY_ORDER["CONCEPT_KEY_ORDER"]
  unknown_file_23_RELATION_KEY_ORDER["RELATION_KEY_ORDER"]
  unknown_file_38_NormalizeChange("NormalizeChange")
  unknown_file_44__reorder_keys("_reorder_keys")
  unknown_file_55_normalize_doc("normalize_doc")
  unknown_file_93_normalize_tree("normalize_tree")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_8_PackConfig("PackConfig")
  unknown_file_17_PackedDoc("PackedDoc")
  unknown_file_25__parse_profile_pack_cfg("_parse_profile_pack_cfg")
  unknown_file_47__maybe_int("_maybe_int")
  unknown_file_64_build_pack("build_pack")
  unknown_file_77_add_doc("add_doc")
  unknown_file_178_pack_config_from_profile("pack_config_from_profile")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_9_Rule("Rule")
  unknown_file_16_RULES["RULES"]
  unknown_file_19_register_rule("register_rule")
  unknown_file_25_Finding("Finding")
  unknown_file_33_to_dict("to_dict")
  unknown_file_37_is_severity("is_severity")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_13_PLACEHOLDER_RE["PLACEHOLDER_RE"]
  unknown_file_14_GITLAB_REF_RE["GITLAB_REF_RE"]
  unknown_file_16__ALLOWED_CONCEPT_KEYS["_ALLOWED_CONCEPT_KEYS"]
  unknown_file_29__ALLOWED_RELATION_KEYS["_ALLOWED_RELATION_KEYS"]
  unknown_file_44__id_ok("_id_ok")
  unknown_file_48_validate_repo_structure("validate_repo_structure")
  unknown_file_55_validate_layers_exist("validate_layers_exist")
  unknown_file_82_validate_manifest_placeholders("validate_manifest_placeholders")
  unknown_file_105_validate_reference_schema("validate_reference_schema")
  unknown_file_393_dfs("dfs")
  unknown_file_417_enforce_budget("enforce_budget")
end
subgraph _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_vendored_py_1__anonymous_module_["<anonymous-module>"]
  direction LR
  unknown_file_8_sha256_file("sha256_file")
  unknown_file_16_compute_expected_hashes("compute_expected_hashes")
  unknown_file_32_read_vendored_hashes("read_vendored_hashes")
  unknown_file_39_verify_vendored_hashes("verify_vendored_hashes")
end

  %% Edges
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ --- unknown_file_10_cache_dir
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ --- unknown_file_20_CacheEntry
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ --- unknown_file_26__dir_size_bytes
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ --- unknown_file_37_list_cache_entries
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ --- unknown_file_51_clear_cache
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ --- unknown_file_57_prune_cache
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ -.->|imports| dep_time
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_102_cmd_resolve
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_124_cmd_summary
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_147_cmd_validate
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_200_cmd_build
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_226_cmd_pack
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_277_cmd_lint
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_305_cmd_check_inverses
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_325_cmd_graph
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_358_cmd_cache
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_35__filter_layers
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_378_cmd_vendored_check
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_392_cmd_normalize
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_419__diff_sets
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_425_cmd_diff
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_46__maybe_load_env_file
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_493_build_parser
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_54__findings_to_json
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_58__print_findings
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_642_main
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_67__write_resolve_artifact
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ --- unknown_file_97_cmd_version
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ -.->|imports| dep_argparse
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ -.->|imports| dep_json
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ -.->|imports| dep_shutil
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ -.->|imports| dep_time
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_signature_py_1__anonymous_module_ --- unknown_file_14__sorted_unique
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_signature_py_1__anonymous_module_ --- unknown_file_25_cli_signature
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_signature_py_1__anonymous_module_ --- unknown_file_8_CliCommandSig
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_ --- unknown_file_12_split_frontmatter
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_ --- unknown_file_20_load_frontmatter
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_ --- unknown_file_28_dump_frontmatter
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_ --- unknown_file_35_write_doc
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_ --- unknown_file_9_FRONT_RE
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_ -.->|imports| dep_yaml
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ --- unknown_file_14_load_env_file
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ --- unknown_file_37_gitlab_base_url
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ --- unknown_file_46_gitlab_headers
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ --- unknown_file_56_fetch_repo_archive
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ -.->|imports| dep_os
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ -.->|imports| dep_shutil
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ -.->|imports| dep_tarfile
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ -.->|imports| dep_tempfile
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_10_GraphEdge
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_116_export_dot
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_126_export_excalidraw
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_17_build_edges
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_243_export_excalidraw_cli_json
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_249_write_graph
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_36_collapse_nodes
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_43_map_id
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ --- unknown_file_57_compute_layout
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ -.->|imports| dep_json
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_id_index_py_1__anonymous_module_ --- unknown_file_15_build_id_index
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_id_index_py_1__anonymous_module_ --- unknown_file_6__path_in_layer
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_inverses_py_1__anonymous_module_ --- unknown_file_16_first_label
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_inverses_py_1__anonymous_module_ --- unknown_file_8_check_inverses
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_12_GITLAB_REF_RE
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_15_LayerSpec
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_23_repo_root
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_27_ontology_root
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_31_manifest_path
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_35_dist_dir
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_39_load_manifest
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_46_parse_gitlab_ref
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_53__src_root_for_ref
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ --- unknown_file_66_resolve_layers
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ -.->|imports| dep_re
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ -.->|imports| dep_yaml
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_lint_py_1__anonymous_module_ --- unknown_file_12__ignored
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_lint_py_1__anonymous_module_ --- unknown_file_19_lint_docs
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_lint_py_1__anonymous_module_ --- unknown_file_22_has_placeholder
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_lint_py_1__anonymous_module_ --- unknown_file_9_PLACEHOLDER_RE
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_ --- unknown_file_10_OntDoc
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_ --- unknown_file_31_iter_reference_md
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_ --- unknown_file_43_iter_md
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_ --- unknown_file_52_load_doc
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_ --- unknown_file_57_collect_docs
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_ --- unknown_file_78_relation_label_index
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_ --- unknown_file_23_RELATION_KEY_ORDER
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_ --- unknown_file_38_NormalizeChange
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_ --- unknown_file_44__reorder_keys
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_ --- unknown_file_55_normalize_doc
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_ --- unknown_file_93_normalize_tree
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_ --- unknown_file_9_CONCEPT_KEY_ORDER
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ --- unknown_file_178_pack_config_from_profile
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ --- unknown_file_17_PackedDoc
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ --- unknown_file_25__parse_profile_pack_cfg
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ --- unknown_file_47__maybe_int
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ --- unknown_file_64_build_pack
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ --- unknown_file_77_add_doc
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ --- unknown_file_8_PackConfig
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_ --- unknown_file_16_RULES
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_ --- unknown_file_19_register_rule
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_ --- unknown_file_25_Finding
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_ --- unknown_file_33_to_dict
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_ --- unknown_file_37_is_severity
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_ --- unknown_file_9_Rule
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_105_validate_reference_schema
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_13_PLACEHOLDER_RE
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_14_GITLAB_REF_RE
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_16__ALLOWED_CONCEPT_KEYS
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_29__ALLOWED_RELATION_KEYS
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_393_dfs
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_417_enforce_budget
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_44__id_ok
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_48_validate_repo_structure
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_55_validate_layers_exist
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ --- unknown_file_82_validate_manifest_placeholders
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ -.->|imports| dep_re
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_vendored_py_1__anonymous_module_ --- unknown_file_16_compute_expected_hashes
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_vendored_py_1__anonymous_module_ --- unknown_file_32_read_vendored_hashes
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_vendored_py_1__anonymous_module_ --- unknown_file_39_verify_vendored_hashes
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_vendored_py_1__anonymous_module_ --- unknown_file_8_sha256_file
  _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_vendored_py_1__anonymous_module_ -.->|imports| dep_hashlib
  unknown_file_102_cmd_resolve -->|calls| unknown_file_35__filter_layers
  unknown_file_102_cmd_resolve -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_102_cmd_resolve -->|calls| unknown_file_66_resolve_layers
  unknown_file_102_cmd_resolve -->|calls| unknown_file_67__write_resolve_artifact
  unknown_file_105_validate_reference_schema -->|calls| unknown_file_393_dfs
  unknown_file_105_validate_reference_schema -->|calls| unknown_file_43_iter_md
  unknown_file_105_validate_reference_schema -->|calls| unknown_file_44__id_ok
  unknown_file_105_validate_reference_schema -->|calls| unknown_file_57_collect_docs
  unknown_file_105_validate_reference_schema -->|calls| unknown_file_78_relation_label_index
  unknown_file_124_cmd_summary -->|calls| unknown_file_35__filter_layers
  unknown_file_124_cmd_summary -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_124_cmd_summary -->|calls| unknown_file_57_collect_docs
  unknown_file_124_cmd_summary -->|calls| unknown_file_66_resolve_layers
  unknown_file_147_cmd_validate -->|calls| unknown_file_105_validate_reference_schema
  unknown_file_147_cmd_validate -->|calls| unknown_file_35__filter_layers
  unknown_file_147_cmd_validate -->|calls| unknown_file_417_enforce_budget
  unknown_file_147_cmd_validate -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_147_cmd_validate -->|calls| unknown_file_57_collect_docs
  unknown_file_147_cmd_validate -->|calls| unknown_file_58__print_findings
  unknown_file_147_cmd_validate -->|calls| unknown_file_66_resolve_layers
  unknown_file_16_compute_expected_hashes -->|calls| unknown_file_8_sha256_file
  unknown_file_178_pack_config_from_profile -->|calls| unknown_file_25__parse_profile_pack_cfg
  unknown_file_178_pack_config_from_profile -->|calls| unknown_file_8_PackConfig
  unknown_file_19_lint_docs -->|calls| unknown_file_12__ignored
  unknown_file_19_lint_docs -->|calls| unknown_file_22_has_placeholder
  unknown_file_19_register_rule -->|calls| unknown_file_9_Rule
  unknown_file_200_cmd_build -->|calls| unknown_file_35__filter_layers
  unknown_file_200_cmd_build -->|calls| unknown_file_35_dist_dir
  unknown_file_200_cmd_build -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_200_cmd_build -->|calls| unknown_file_57_collect_docs
  unknown_file_200_cmd_build -->|calls| unknown_file_66_resolve_layers
  unknown_file_200_cmd_build -->|calls| unknown_file_67__write_resolve_artifact
  unknown_file_20_load_frontmatter -->|calls| unknown_file_12_split_frontmatter
  unknown_file_226_cmd_pack -->|calls| unknown_file_178_pack_config_from_profile
  unknown_file_226_cmd_pack -->|calls| unknown_file_35__filter_layers
  unknown_file_226_cmd_pack -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_226_cmd_pack -->|calls| unknown_file_57_collect_docs
  unknown_file_226_cmd_pack -->|calls| unknown_file_64_build_pack
  unknown_file_226_cmd_pack -->|calls| unknown_file_66_resolve_layers
  unknown_file_25__parse_profile_pack_cfg -->|calls| unknown_file_8_PackConfig
  unknown_file_25_cli_signature -->|calls| unknown_file_14__sorted_unique
  unknown_file_25_cli_signature -->|calls| unknown_file_493_build_parser
  unknown_file_25_cli_signature -->|calls| unknown_file_8_CliCommandSig
  unknown_file_277_cmd_lint -->|calls| unknown_file_19_lint_docs
  unknown_file_277_cmd_lint -->|calls| unknown_file_35__filter_layers
  unknown_file_277_cmd_lint -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_277_cmd_lint -->|calls| unknown_file_57_collect_docs
  unknown_file_277_cmd_lint -->|calls| unknown_file_58__print_findings
  unknown_file_277_cmd_lint -->|calls| unknown_file_66_resolve_layers
  unknown_file_305_cmd_check_inverses -->|calls| unknown_file_35__filter_layers
  unknown_file_305_cmd_check_inverses -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_305_cmd_check_inverses -->|calls| unknown_file_57_collect_docs
  unknown_file_305_cmd_check_inverses -->|calls| unknown_file_58__print_findings
  unknown_file_305_cmd_check_inverses -->|calls| unknown_file_66_resolve_layers
  unknown_file_305_cmd_check_inverses -->|calls| unknown_file_8_check_inverses
  unknown_file_31_manifest_path -->|calls| unknown_file_27_ontology_root
  unknown_file_325_cmd_graph -->|calls| unknown_file_17_build_edges
  unknown_file_325_cmd_graph -->|calls| unknown_file_249_write_graph
  unknown_file_325_cmd_graph -->|calls| unknown_file_35__filter_layers
  unknown_file_325_cmd_graph -->|calls| unknown_file_35_dist_dir
  unknown_file_325_cmd_graph -->|calls| unknown_file_36_collapse_nodes
  unknown_file_325_cmd_graph -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_325_cmd_graph -->|calls| unknown_file_57_collect_docs
  unknown_file_325_cmd_graph -->|calls| unknown_file_57_compute_layout
  unknown_file_325_cmd_graph -->|calls| unknown_file_66_resolve_layers
  unknown_file_358_cmd_cache -->|calls| unknown_file_37_list_cache_entries
  unknown_file_358_cmd_cache -->|calls| unknown_file_51_clear_cache
  unknown_file_358_cmd_cache -->|calls| unknown_file_57_prune_cache
  unknown_file_35_dist_dir -->|calls| unknown_file_27_ontology_root
  unknown_file_35_write_doc -->|calls| unknown_file_28_dump_frontmatter
  unknown_file_36_collapse_nodes -->|calls| unknown_file_10_GraphEdge
  unknown_file_36_collapse_nodes -->|calls| unknown_file_43_map_id
  unknown_file_378_cmd_vendored_check -->|calls| unknown_file_39_verify_vendored_hashes
  unknown_file_37_list_cache_entries -->|calls| unknown_file_10_cache_dir
  unknown_file_392_cmd_normalize -->|calls| unknown_file_35__filter_layers
  unknown_file_392_cmd_normalize -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_392_cmd_normalize -->|calls| unknown_file_66_resolve_layers
  unknown_file_392_cmd_normalize -->|calls| unknown_file_93_normalize_tree
  unknown_file_39_load_manifest -->|calls| unknown_file_31_manifest_path
  unknown_file_39_verify_vendored_hashes -->|calls| unknown_file_32_read_vendored_hashes
  unknown_file_39_verify_vendored_hashes -->|calls| unknown_file_8_sha256_file
  unknown_file_425_cmd_diff -->|calls| unknown_file_17_build_edges
  unknown_file_425_cmd_diff -->|calls| unknown_file_35__filter_layers
  unknown_file_425_cmd_diff -->|calls| unknown_file_35_dist_dir
  unknown_file_425_cmd_diff -->|calls| unknown_file_419__diff_sets
  unknown_file_425_cmd_diff -->|calls| unknown_file_46__maybe_load_env_file
  unknown_file_425_cmd_diff -->|calls| unknown_file_46_parse_gitlab_ref
  unknown_file_425_cmd_diff -->|calls| unknown_file_56_fetch_repo_archive
  unknown_file_425_cmd_diff -->|calls| unknown_file_57_collect_docs
  unknown_file_425_cmd_diff -->|calls| unknown_file_66_resolve_layers
  unknown_file_46__maybe_load_env_file -->|calls| unknown_file_14_load_env_file
  unknown_file_51_clear_cache -->|calls| unknown_file_10_cache_dir
  unknown_file_52_load_doc -->|calls| unknown_file_10_OntDoc
  unknown_file_52_load_doc -->|calls| unknown_file_20_load_frontmatter
  unknown_file_53__src_root_for_ref -->|calls| unknown_file_46_parse_gitlab_ref
  unknown_file_53__src_root_for_ref -->|calls| unknown_file_56_fetch_repo_archive
  unknown_file_54__findings_to_json -->|calls| unknown_file_33_to_dict
  unknown_file_55_normalize_doc -->|calls| unknown_file_20_load_frontmatter
  unknown_file_55_normalize_doc -->|calls| unknown_file_35_write_doc
  unknown_file_55_normalize_doc -->|calls| unknown_file_44__reorder_keys
  unknown_file_56_fetch_repo_archive -->|calls| unknown_file_10_cache_dir
  unknown_file_57_collect_docs -->|calls| unknown_file_31_iter_reference_md
  unknown_file_57_collect_docs -->|calls| unknown_file_52_load_doc
  unknown_file_57_prune_cache -->|calls| unknown_file_10_cache_dir
  unknown_file_642_main -->|calls| unknown_file_493_build_parser
  unknown_file_64_build_pack -->|calls| unknown_file_77_add_doc
  unknown_file_64_build_pack -->|calls| unknown_file_78_relation_label_index
  unknown_file_66_resolve_layers -->|calls| unknown_file_39_load_manifest
  unknown_file_66_resolve_layers -->|calls| unknown_file_53__src_root_for_ref
  unknown_file_67__write_resolve_artifact -->|calls| unknown_file_35_dist_dir
  unknown_file_82_validate_manifest_placeholders -->|calls| unknown_file_31_manifest_path
  unknown_file_8_check_inverses -->|calls| unknown_file_16_first_label
  unknown_file_8_check_inverses -->|calls| unknown_file_35_write_doc
  unknown_file_8_check_inverses -->|calls| unknown_file_78_relation_label_index
  unknown_file_93_normalize_tree -->|calls| unknown_file_55_normalize_doc

  %% Link Styles
  linkStyle 121 stroke:#28a745,stroke-width:2px;
  linkStyle 122 stroke:#28a745,stroke-width:2px;
  linkStyle 123 stroke:#28a745,stroke-width:2px;
  linkStyle 124 stroke:#28a745,stroke-width:2px;
  linkStyle 125 stroke:#28a745,stroke-width:2px;
  linkStyle 126 stroke:#28a745,stroke-width:2px;
  linkStyle 127 stroke:#28a745,stroke-width:2px;
  linkStyle 128 stroke:#28a745,stroke-width:2px;
  linkStyle 129 stroke:#28a745,stroke-width:2px;
  linkStyle 130 stroke:#28a745,stroke-width:2px;
  linkStyle 131 stroke:#28a745,stroke-width:2px;
  linkStyle 132 stroke:#28a745,stroke-width:2px;
  linkStyle 133 stroke:#28a745,stroke-width:2px;
  linkStyle 134 stroke:#28a745,stroke-width:2px;
  linkStyle 135 stroke:#28a745,stroke-width:2px;
  linkStyle 136 stroke:#28a745,stroke-width:2px;
  linkStyle 137 stroke:#28a745,stroke-width:2px;
  linkStyle 138 stroke:#28a745,stroke-width:2px;
  linkStyle 139 stroke:#28a745,stroke-width:2px;
  linkStyle 140 stroke:#28a745,stroke-width:2px;
  linkStyle 141 stroke:#28a745,stroke-width:2px;
  linkStyle 142 stroke:#28a745,stroke-width:2px;
  linkStyle 143 stroke:#28a745,stroke-width:2px;
  linkStyle 144 stroke:#28a745,stroke-width:2px;
  linkStyle 145 stroke:#28a745,stroke-width:2px;
  linkStyle 146 stroke:#28a745,stroke-width:2px;
  linkStyle 147 stroke:#28a745,stroke-width:2px;
  linkStyle 148 stroke:#28a745,stroke-width:2px;
  linkStyle 149 stroke:#28a745,stroke-width:2px;
  linkStyle 150 stroke:#28a745,stroke-width:2px;
  linkStyle 151 stroke:#28a745,stroke-width:2px;
  linkStyle 152 stroke:#28a745,stroke-width:2px;
  linkStyle 153 stroke:#28a745,stroke-width:2px;
  linkStyle 154 stroke:#28a745,stroke-width:2px;
  linkStyle 155 stroke:#28a745,stroke-width:2px;
  linkStyle 156 stroke:#28a745,stroke-width:2px;
  linkStyle 157 stroke:#28a745,stroke-width:2px;
  linkStyle 158 stroke:#28a745,stroke-width:2px;
  linkStyle 159 stroke:#28a745,stroke-width:2px;
  linkStyle 160 stroke:#28a745,stroke-width:2px;
  linkStyle 161 stroke:#28a745,stroke-width:2px;
  linkStyle 162 stroke:#28a745,stroke-width:2px;
  linkStyle 163 stroke:#28a745,stroke-width:2px;
  linkStyle 164 stroke:#28a745,stroke-width:2px;
  linkStyle 165 stroke:#28a745,stroke-width:2px;
  linkStyle 166 stroke:#28a745,stroke-width:2px;
  linkStyle 167 stroke:#28a745,stroke-width:2px;
  linkStyle 168 stroke:#28a745,stroke-width:2px;
  linkStyle 169 stroke:#28a745,stroke-width:2px;
  linkStyle 170 stroke:#28a745,stroke-width:2px;
  linkStyle 171 stroke:#28a745,stroke-width:2px;
  linkStyle 172 stroke:#28a745,stroke-width:2px;
  linkStyle 173 stroke:#28a745,stroke-width:2px;
  linkStyle 174 stroke:#28a745,stroke-width:2px;
  linkStyle 175 stroke:#28a745,stroke-width:2px;
  linkStyle 176 stroke:#28a745,stroke-width:2px;
  linkStyle 177 stroke:#28a745,stroke-width:2px;
  linkStyle 178 stroke:#28a745,stroke-width:2px;
  linkStyle 179 stroke:#28a745,stroke-width:2px;
  linkStyle 180 stroke:#28a745,stroke-width:2px;
  linkStyle 181 stroke:#28a745,stroke-width:2px;
  linkStyle 182 stroke:#28a745,stroke-width:2px;
  linkStyle 183 stroke:#28a745,stroke-width:2px;
  linkStyle 184 stroke:#28a745,stroke-width:2px;
  linkStyle 185 stroke:#28a745,stroke-width:2px;
  linkStyle 186 stroke:#28a745,stroke-width:2px;
  linkStyle 187 stroke:#28a745,stroke-width:2px;
  linkStyle 188 stroke:#28a745,stroke-width:2px;
  linkStyle 189 stroke:#28a745,stroke-width:2px;
  linkStyle 190 stroke:#28a745,stroke-width:2px;
  linkStyle 191 stroke:#28a745,stroke-width:2px;
  linkStyle 192 stroke:#28a745,stroke-width:2px;
  linkStyle 193 stroke:#28a745,stroke-width:2px;
  linkStyle 194 stroke:#28a745,stroke-width:2px;
  linkStyle 195 stroke:#28a745,stroke-width:2px;
  linkStyle 196 stroke:#28a745,stroke-width:2px;
  linkStyle 197 stroke:#28a745,stroke-width:2px;
  linkStyle 198 stroke:#28a745,stroke-width:2px;
  linkStyle 199 stroke:#28a745,stroke-width:2px;
  linkStyle 200 stroke:#28a745,stroke-width:2px;
  linkStyle 201 stroke:#28a745,stroke-width:2px;
  linkStyle 202 stroke:#28a745,stroke-width:2px;
  linkStyle 203 stroke:#28a745,stroke-width:2px;
  linkStyle 204 stroke:#28a745,stroke-width:2px;
  linkStyle 205 stroke:#28a745,stroke-width:2px;
  linkStyle 206 stroke:#28a745,stroke-width:2px;
  linkStyle 207 stroke:#28a745,stroke-width:2px;
  linkStyle 208 stroke:#28a745,stroke-width:2px;
  linkStyle 209 stroke:#28a745,stroke-width:2px;
  linkStyle 210 stroke:#28a745,stroke-width:2px;
  linkStyle 211 stroke:#28a745,stroke-width:2px;
  linkStyle 212 stroke:#28a745,stroke-width:2px;
  linkStyle 213 stroke:#28a745,stroke-width:2px;
  linkStyle 214 stroke:#28a745,stroke-width:2px;
  linkStyle 215 stroke:#28a745,stroke-width:2px;
  linkStyle 216 stroke:#28a745,stroke-width:2px;
  linkStyle 217 stroke:#28a745,stroke-width:2px;
  linkStyle 218 stroke:#28a745,stroke-width:2px;
  linkStyle 219 stroke:#28a745,stroke-width:2px;
  linkStyle 220 stroke:#28a745,stroke-width:2px;
  linkStyle 221 stroke:#28a745,stroke-width:2px;
  linkStyle 222 stroke:#28a745,stroke-width:2px;
  linkStyle 223 stroke:#28a745,stroke-width:2px;
  linkStyle 224 stroke:#28a745,stroke-width:2px;
  linkStyle 225 stroke:#28a745,stroke-width:2px;
  linkStyle 226 stroke:#28a745,stroke-width:2px;
  linkStyle 227 stroke:#28a745,stroke-width:2px;
  linkStyle 228 stroke:#28a745,stroke-width:2px;
  linkStyle 229 stroke:#28a745,stroke-width:2px;
  linkStyle 230 stroke:#28a745,stroke-width:2px;
  linkStyle 231 stroke:#28a745,stroke-width:2px;
  linkStyle 232 stroke:#28a745,stroke-width:2px;
  linkStyle 233 stroke:#28a745,stroke-width:2px;
  linkStyle 234 stroke:#28a745,stroke-width:2px;
  linkStyle 235 stroke:#28a745,stroke-width:2px;
  linkStyle 6 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 7 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 8 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 9 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 14 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 28 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 46 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 47 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 48 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 49 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 71 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 72 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 83 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 97 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 115 stroke:#ffc107,stroke-width:1px,stroke-dasharray: 5 5;
  linkStyle 0 stroke:#adb5bd,stroke-width:1px;
  linkStyle 1 stroke:#adb5bd,stroke-width:1px;
  linkStyle 2 stroke:#adb5bd,stroke-width:1px;
  linkStyle 3 stroke:#adb5bd,stroke-width:1px;
  linkStyle 4 stroke:#adb5bd,stroke-width:1px;
  linkStyle 5 stroke:#adb5bd,stroke-width:1px;
  linkStyle 10 stroke:#adb5bd,stroke-width:1px;
  linkStyle 11 stroke:#adb5bd,stroke-width:1px;
  linkStyle 12 stroke:#adb5bd,stroke-width:1px;
  linkStyle 13 stroke:#adb5bd,stroke-width:1px;
  linkStyle 15 stroke:#adb5bd,stroke-width:1px;
  linkStyle 16 stroke:#adb5bd,stroke-width:1px;
  linkStyle 17 stroke:#adb5bd,stroke-width:1px;
  linkStyle 18 stroke:#adb5bd,stroke-width:1px;
  linkStyle 19 stroke:#adb5bd,stroke-width:1px;
  linkStyle 20 stroke:#adb5bd,stroke-width:1px;
  linkStyle 21 stroke:#adb5bd,stroke-width:1px;
  linkStyle 22 stroke:#adb5bd,stroke-width:1px;
  linkStyle 23 stroke:#adb5bd,stroke-width:1px;
  linkStyle 24 stroke:#adb5bd,stroke-width:1px;
  linkStyle 25 stroke:#adb5bd,stroke-width:1px;
  linkStyle 26 stroke:#adb5bd,stroke-width:1px;
  linkStyle 27 stroke:#adb5bd,stroke-width:1px;
  linkStyle 29 stroke:#adb5bd,stroke-width:1px;
  linkStyle 30 stroke:#adb5bd,stroke-width:1px;
  linkStyle 31 stroke:#adb5bd,stroke-width:1px;
  linkStyle 32 stroke:#adb5bd,stroke-width:1px;
  linkStyle 33 stroke:#adb5bd,stroke-width:1px;
  linkStyle 34 stroke:#adb5bd,stroke-width:1px;
  linkStyle 35 stroke:#adb5bd,stroke-width:1px;
  linkStyle 36 stroke:#adb5bd,stroke-width:1px;
  linkStyle 37 stroke:#adb5bd,stroke-width:1px;
  linkStyle 38 stroke:#adb5bd,stroke-width:1px;
  linkStyle 39 stroke:#adb5bd,stroke-width:1px;
  linkStyle 40 stroke:#adb5bd,stroke-width:1px;
  linkStyle 41 stroke:#adb5bd,stroke-width:1px;
  linkStyle 42 stroke:#adb5bd,stroke-width:1px;
  linkStyle 43 stroke:#adb5bd,stroke-width:1px;
  linkStyle 44 stroke:#adb5bd,stroke-width:1px;
  linkStyle 45 stroke:#adb5bd,stroke-width:1px;
  linkStyle 50 stroke:#adb5bd,stroke-width:1px;
  linkStyle 51 stroke:#adb5bd,stroke-width:1px;
  linkStyle 52 stroke:#adb5bd,stroke-width:1px;
  linkStyle 53 stroke:#adb5bd,stroke-width:1px;
  linkStyle 54 stroke:#adb5bd,stroke-width:1px;
  linkStyle 55 stroke:#adb5bd,stroke-width:1px;
  linkStyle 56 stroke:#adb5bd,stroke-width:1px;
  linkStyle 57 stroke:#adb5bd,stroke-width:1px;
  linkStyle 58 stroke:#adb5bd,stroke-width:1px;
  linkStyle 59 stroke:#adb5bd,stroke-width:1px;
  linkStyle 60 stroke:#adb5bd,stroke-width:1px;
  linkStyle 61 stroke:#adb5bd,stroke-width:1px;
  linkStyle 62 stroke:#adb5bd,stroke-width:1px;
  linkStyle 63 stroke:#adb5bd,stroke-width:1px;
  linkStyle 64 stroke:#adb5bd,stroke-width:1px;
  linkStyle 65 stroke:#adb5bd,stroke-width:1px;
  linkStyle 66 stroke:#adb5bd,stroke-width:1px;
  linkStyle 67 stroke:#adb5bd,stroke-width:1px;
  linkStyle 68 stroke:#adb5bd,stroke-width:1px;
  linkStyle 69 stroke:#adb5bd,stroke-width:1px;
  linkStyle 70 stroke:#adb5bd,stroke-width:1px;
  linkStyle 73 stroke:#adb5bd,stroke-width:1px;
  linkStyle 74 stroke:#adb5bd,stroke-width:1px;
  linkStyle 75 stroke:#adb5bd,stroke-width:1px;
  linkStyle 76 stroke:#adb5bd,stroke-width:1px;
  linkStyle 77 stroke:#adb5bd,stroke-width:1px;
  linkStyle 78 stroke:#adb5bd,stroke-width:1px;
  linkStyle 79 stroke:#adb5bd,stroke-width:1px;
  linkStyle 80 stroke:#adb5bd,stroke-width:1px;
  linkStyle 81 stroke:#adb5bd,stroke-width:1px;
  linkStyle 82 stroke:#adb5bd,stroke-width:1px;
  linkStyle 84 stroke:#adb5bd,stroke-width:1px;
  linkStyle 85 stroke:#adb5bd,stroke-width:1px;
  linkStyle 86 stroke:#adb5bd,stroke-width:1px;
  linkStyle 87 stroke:#adb5bd,stroke-width:1px;
  linkStyle 88 stroke:#adb5bd,stroke-width:1px;
  linkStyle 89 stroke:#adb5bd,stroke-width:1px;
  linkStyle 90 stroke:#adb5bd,stroke-width:1px;
  linkStyle 91 stroke:#adb5bd,stroke-width:1px;
  linkStyle 92 stroke:#adb5bd,stroke-width:1px;
  linkStyle 93 stroke:#adb5bd,stroke-width:1px;
  linkStyle 94 stroke:#adb5bd,stroke-width:1px;
  linkStyle 95 stroke:#adb5bd,stroke-width:1px;
  linkStyle 96 stroke:#adb5bd,stroke-width:1px;
  linkStyle 98 stroke:#adb5bd,stroke-width:1px;
  linkStyle 99 stroke:#adb5bd,stroke-width:1px;
  linkStyle 100 stroke:#adb5bd,stroke-width:1px;
  linkStyle 101 stroke:#adb5bd,stroke-width:1px;
  linkStyle 102 stroke:#adb5bd,stroke-width:1px;
  linkStyle 103 stroke:#adb5bd,stroke-width:1px;
  linkStyle 104 stroke:#adb5bd,stroke-width:1px;
  linkStyle 105 stroke:#adb5bd,stroke-width:1px;
  linkStyle 106 stroke:#adb5bd,stroke-width:1px;
  linkStyle 107 stroke:#adb5bd,stroke-width:1px;
  linkStyle 108 stroke:#adb5bd,stroke-width:1px;
  linkStyle 109 stroke:#adb5bd,stroke-width:1px;
  linkStyle 110 stroke:#adb5bd,stroke-width:1px;
  linkStyle 111 stroke:#adb5bd,stroke-width:1px;
  linkStyle 112 stroke:#adb5bd,stroke-width:1px;
  linkStyle 113 stroke:#adb5bd,stroke-width:1px;
  linkStyle 114 stroke:#adb5bd,stroke-width:1px;
  linkStyle 116 stroke:#adb5bd,stroke-width:1px;
  linkStyle 117 stroke:#adb5bd,stroke-width:1px;
  linkStyle 118 stroke:#adb5bd,stroke-width:1px;
  linkStyle 119 stroke:#adb5bd,stroke-width:1px;
  linkStyle 120 stroke:#adb5bd,stroke-width:1px;

  %% Styles
  style dep_argparse fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_hashlib fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_json fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_os fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_re fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_shutil fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_tarfile fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_tempfile fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_time fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style dep_yaml fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style legend_const fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style legend_func fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style legend_import_ext fill:#ffc107,stroke:#333,stroke-width:1px,color:#333
  style legend_module fill:#121630,color:#FFF
  style unknown_file_102_cmd_resolve fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_105_validate_reference_schema fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_10_GraphEdge fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_10_OntDoc fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_10_cache_dir fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_116_export_dot fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_124_cmd_summary fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_126_export_excalidraw fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_12_GITLAB_REF_RE fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_12__ignored fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_12_split_frontmatter fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_13_PLACEHOLDER_RE fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_147_cmd_validate fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_14_GITLAB_REF_RE fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_14__sorted_unique fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_14_load_env_file fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_15_LayerSpec fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_15_build_id_index fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_16_RULES fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_16__ALLOWED_CONCEPT_KEYS fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_16_compute_expected_hashes fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_16_first_label fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_178_pack_config_from_profile fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_17_PackedDoc fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_17_build_edges fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_19_lint_docs fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_19_register_rule fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_200_cmd_build fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_20_CacheEntry fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_20_load_frontmatter fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_226_cmd_pack fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_22_has_placeholder fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_23_RELATION_KEY_ORDER fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_23_repo_root fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_243_export_excalidraw_cli_json fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_249_write_graph fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_25_Finding fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_25__parse_profile_pack_cfg fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_25_cli_signature fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_26__dir_size_bytes fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_277_cmd_lint fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_27_ontology_root fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_28_dump_frontmatter fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_29__ALLOWED_RELATION_KEYS fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_305_cmd_check_inverses fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_31_iter_reference_md fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_31_manifest_path fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_325_cmd_graph fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_32_read_vendored_hashes fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_33_to_dict fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_358_cmd_cache fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_35__filter_layers fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_35_dist_dir fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_35_write_doc fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_36_collapse_nodes fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_378_cmd_vendored_check fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_37_gitlab_base_url fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_37_is_severity fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_37_list_cache_entries fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_38_NormalizeChange fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_392_cmd_normalize fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_393_dfs fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_39_load_manifest fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_39_verify_vendored_hashes fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_417_enforce_budget fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_419__diff_sets fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_425_cmd_diff fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_43_iter_md fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_43_map_id fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_44__id_ok fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_44__reorder_keys fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_46__maybe_load_env_file fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_46_gitlab_headers fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_46_parse_gitlab_ref fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_47__maybe_int fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_48_validate_repo_structure fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_493_build_parser fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_51_clear_cache fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_52_load_doc fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_53__src_root_for_ref fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_54__findings_to_json fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_55_normalize_doc fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_55_validate_layers_exist fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_56_fetch_repo_archive fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_57_collect_docs fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_57_compute_layout fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_57_prune_cache fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_58__print_findings fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_642_main fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_64_build_pack fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_66_resolve_layers fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_67__write_resolve_artifact fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_6__path_in_layer fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_77_add_doc fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_78_relation_label_index fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_82_validate_manifest_placeholders fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_8_CliCommandSig fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_8_PackConfig fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_8_check_inverses fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_8_sha256_file fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_93_normalize_tree fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_97_cmd_version fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_9_CONCEPT_KEY_ORDER fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_9_FRONT_RE fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_9_PLACEHOLDER_RE fill:#6f42c1,stroke:#FFF,stroke-width:1px,color:white
  style unknown_file_9_Rule fill:#007bff,stroke:#FFF,stroke-width:1px,color:white
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli___init___py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli___main___py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cache_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_cli_signature_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_frontmatter_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_gitlab_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_graph_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_id_index_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_inverses_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_layers_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_lint_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_model_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_normalize_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_pack_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_rules_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_validate_py_1__anonymous_module_ fill:#121630,color:#FFF
style _home_tryinget_ai_society_core_prompt_vault_tools_rocs_cli_src_rocs_cli_vendored_py_1__anonymous_module_ fill:#121630,color:#FFF
```

## Scanned Files
1. [/tools/rocs-cli/src/rocs_cli/__init__.py](#rocs_cliinitpy)
2. [/tools/rocs-cli/src/rocs_cli/__main__.py](#rocs_climainpy)
3. [/tools/rocs-cli/src/rocs_cli/cache.py](#rocs_clicachepy)
4. [/tools/rocs-cli/src/rocs_cli/cli.py](#rocs_cliclipy)
5. [/tools/rocs-cli/src/rocs_cli/cli_signature.py](#rocs_cliclisignaturepy)
6. [/tools/rocs-cli/src/rocs_cli/frontmatter.py](#rocs_clifrontmatterpy)
7. [/tools/rocs-cli/src/rocs_cli/gitlab.py](#rocs_cligitlabpy)
8. [/tools/rocs-cli/src/rocs_cli/graph.py](#rocs_cligraphpy)
9. [/tools/rocs-cli/src/rocs_cli/id_index.py](#rocs_cliidindexpy)
10. [/tools/rocs-cli/src/rocs_cli/inverses.py](#rocs_cliinversespy)
11. [/tools/rocs-cli/src/rocs_cli/layers.py](#rocs_clilayerspy)
12. [/tools/rocs-cli/src/rocs_cli/lint.py](#rocs_clilintpy)
13. [/tools/rocs-cli/src/rocs_cli/model.py](#rocs_climodelpy)
14. [/tools/rocs-cli/src/rocs_cli/normalize.py](#rocs_clinormalizepy)
15. [/tools/rocs-cli/src/rocs_cli/pack.py](#rocs_clipackpy)
16. [/tools/rocs-cli/src/rocs_cli/rules.py](#rocs_clirulespy)
17. [/tools/rocs-cli/src/rocs_cli/validate.py](#rocs_clivalidatepy)
18. [/tools/rocs-cli/src/rocs_cli/vendored.py](#rocs_clivendoredpy)

## Code Documentation

### 1. /tools/rocs-cli/src/rocs_cli/__init__.py
- **Type_alias**: `__all__`
- **Type_alias**: `__version__`

---

### 2. /tools/rocs-cli/src/rocs_cli/__main__.py
- **Import**: `main`

---

### 3. /tools/rocs-cli/src/rocs_cli/cache.py
- **Import**: `os`
- **Import**: `shutil`
- **Import**: `time`
- **Import**: `dataclass`
- **Import**: `Path`
- **Function**: `def cache_dir() -> Path`
  - **Type_alias**: `p`
  - **Type_alias**: `xdg`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `path`
  - **Type_alias**: `bytes`
- **Function**: `def _dir_size_bytes(root: Path) -> int`
  - **Type_alias**: `total`
- **Function**: `def list_cache_entries() -> list[CacheEntry]`
  - **Type_alias**: `root`
  - **Type_alias**: `entries`
  - **Type_alias**: `gitlab_root`
- **Function**: `def clear_cache() -> None`
  - **Type_alias**: `root`
- **Function**: `def prune_cache(*, max_age_days: int) -> int`
  - **Type_alias**: `root`
  - **Type_alias**: `cutoff`
  - **Type_alias**: `removed`
  - **Type_alias**: `now`
  - **Type_alias**: `gitlab_root`

---

### 4. /tools/rocs-cli/src/rocs_cli/cli.py
- **Import**: `argparse`
- **Import**: `json`
- **Import**: `shutil`
- **Import**: `time`
- **Import**: `Path`
- **Import**: `Console`
- **Import**: `__version__`
- **Import**: `cache_dir`
- **Import**: `build_edges`
- **Import**: `build_id_index`
- **Import**: `check_inverses`
- **Import**: `dist_dir`
- **Import**: `lint_docs`
- **Import**: `collect_docs`
- **Import**: `normalize_tree`
- **Import**: `build_pack`
- **Import**: `Finding`
- **Import**: `enforce_budget`
- **Import**: `verify_vendored_hashes`
- **Type_alias**: `console`
- **Function**: `def _filter_layers(layers, *, only: str | None, layer: str | None)`
  - **Type_alias**: `out`
- **Function**: `def _maybe_load_env_file(env_file: str | None) -> None`
  - **Import**: `load_env_file`
- **Function**: `def _findings_to_json(findings: list[Finding]) -> list[dict]`
- **Function**: `def _print_findings(findings: list[Finding]) -> None`
- **Function**: `def _write_resolve_artifact(repo: Path, *, layers, profile: str | None) -> Path`
  - **Type_alias**: `dist`
  - **Type_alias**: `entries`
  - **Type_alias**: `payload`
  - **Type_alias**: `out`
- **Function**: `def cmd_version(_args: argparse.Namespace) -> int`
- **Function**: `def cmd_resolve(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `layers, meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `payload`
- **Function**: `def cmd_summary(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `layers, meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `concepts, relations`
  - **Type_alias**: `payload`
- **Function**: `def cmd_validate(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `findings`
  - **Type_alias**: `layers, meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `schema_findings, _meta2`
  - **Type_alias**: `concepts, relations`
  - **Type_alias**: `budget`
  - **Type_alias**: `profile_def`
  - **Type_alias**: `ok_budget, budget_payload`
- **Function**: `def cmd_build(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `dist`
  - **Type_alias**: `layers, meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `concepts, relations`
  - **Type_alias**: `payload`
- **Function**: `def cmd_pack(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `layers, meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `concepts, relations`
  - **Type_alias**: `cid`
  - **Type_alias**: `doc`
  - **Type_alias**: `rel_types`
  - **Type_alias**: `cfg`
  - **Type_alias**: `packed, pack_meta`
  - **Type_alias**: `first`
- **Function**: `def cmd_lint(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `layers, _meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `concepts, relations`
  - **Type_alias**: `findings`
  - **Type_alias**: `rule_filter`
- **Function**: `def cmd_check_inverses(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `layers, _meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `_concepts, relations`
  - **Type_alias**: `findings`
- **Function**: `def cmd_graph(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `layers, _meta`
  - **Type_alias**: `layers`
  - **Type_alias**: `concepts, _relations`
  - **Type_alias**: `rel_filter`
  - **Type_alias**: `edges`
  - **Type_alias**: `nodes`
  - **Type_alias**: `layout`
  - **Type_alias**: `direction`
- **Function**: `def cmd_cache(args: argparse.Namespace) -> int`
- **Function**: `def cmd_vendored_check(args: argparse.Namespace) -> int`
  - **Type_alias**: `vendored_dir`
  - **Type_alias**: `ok, lines`
- **Function**: `def cmd_normalize(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `layers, _meta`
  > *# normalize never touches ref layers*
  - **Type_alias**: `layers`
  - **Type_alias**: `changed_paths`
- **Function**: `def _diff_sets(a: set[str], b: set[str]) -> tuple[list[str], list[str]]`
  - **Type_alias**: `removed`
  - **Type_alias**: `added`
- **Function**: `def cmd_diff(args: argparse.Namespace) -> int`
  - **Type_alias**: `repo`
  - **Type_alias**: `baseline`
  - **Type_alias**: `parsed`
  > *# Treat baseline as repo archive root; then diff its resolved view against current.*
  - **Import**: `fetch_repo_archive`
  - **Type_alias**: `project_path, ref`
  - **Type_alias**: `base_repo`
  - **Type_alias**: `cur_layers, cur_meta`
  - **Type_alias**: `base_layers, base_meta`
  - **Type_alias**: `cur_layers`
  - **Type_alias**: `base_layers`
  - **Type_alias**: `cur_concepts, cur_relations`
  - **Type_alias**: `base_concepts, base_relations`
  - **Type_alias**: `cur_edges`
  - **Type_alias**: `base_edges`
  - **Type_alias**: `removed_concepts, added_concepts`
  - **Type_alias**: `removed_relations, added_relations`
  - **Type_alias**: `removed_edges, added_edges`
  - **Type_alias**: `breaking`
  - **Type_alias**: `payload`
  - **Type_alias**: `dist`
  - **Type_alias**: `out`
- **Function**: `def build_parser() -> argparse.ArgumentParser`
  - **Type_alias**: `parser`
  - **Type_alias**: `sub`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `p`
  - **Type_alias**: `sub2`
  - **Type_alias**: `p2`
  - **Type_alias**: `p2`
  - **Type_alias**: `p2`
  - **Type_alias**: `p2`
  - **Type_alias**: `p`
- **Function**: `def main(argv: list[str] | None = None) -> None`
  - **Type_alias**: `parser`
  - **Type_alias**: `args`

---

### 5. /tools/rocs-cli/src/rocs_cli/cli_signature.py
- **Import**: `dataclass`
- **Import**: `build_parser`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `name`
  - **Type_alias**: `option_strings`
- **Function**: `def _sorted_unique(xs: list[str]) -> tuple[str, ...]`
  - **Type_alias**: `seen`
  - **Type_alias**: `out`
- **Function**: `def cli_signature() -> dict`
  >
  > Deterministic, machine-readable CLI signature for doc/tests.
  > 
  >     Intent:
  >     - validate docs against *actual* argparse wiring
  >     - avoid parsing terminal output (too platform/version fragile)
  - **Type_alias**: `parser`
  - **Type_alias**: `global_opts`
  - **Type_alias**: `subcommands`
  - **Type_alias**: `subparsers_action`

---

### 6. /tools/rocs-cli/src/rocs_cli/frontmatter.py
- **Import**: `re`
- **Import**: `Path`
- **Import**: `yaml`
- **Constant**: `FRONT_RE`
- **Function**: `def split_frontmatter(text: str) -> tuple[dict | None, str]`
  - **Type_alias**: `m`
  - **Type_alias**: `fm`
- **Function**: `def load_frontmatter(path: Path) -> tuple[dict, str]`
  - **Type_alias**: `text`
  - **Type_alias**: `fm, body`
- **Function**: `def dump_frontmatter(fm: dict) -> str`
  - **Type_alias**: `y`
- **Function**: `def write_doc(path: Path, fm: dict, body: str) -> None`
  - **Type_alias**: `front`

---

### 7. /tools/rocs-cli/src/rocs_cli/gitlab.py
- **Import**: `os`
- **Import**: `shutil`
- **Import**: `tarfile`
- **Import**: `tempfile`
- **Import**: `Path`
- **Import**: `quote`
- **Import**: `Request`
- **Import**: `cache_dir`
- **Function**: `def load_env_file(path: Path, *, override: bool = False) -> None`
  >
  > Minimal dotenv loader (KEY=VALUE). Used to support local workflows where `.env`
  >     is sourced without exporting variables.
- **Function**: `def gitlab_base_url() -> str`
- **Function**: `def gitlab_headers() -> dict[str, str]`
  - **Type_alias**: `tok`
  - **Type_alias**: `job`
- **Function**: `def fetch_repo_archive(project_path: str, ref: str, *, base_url: str, headers: dict[str, str]) -> Path`
  - **Type_alias**: `safe_project`
  - **Type_alias**: `safe_ref`
  - **Type_alias**: `dest`
  - **Type_alias**: `archive_url`

---

### 8. /tools/rocs-cli/src/rocs_cli/graph.py
- **Import**: `json`
- **Import**: `dataclass`
- **Import**: `Path`
- **Import**: `OntDoc`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `src`
  - **Type_alias**: `rel`
  - **Type_alias**: `dst`
- **Function**: `def build_edges(concepts: dict[str, OntDoc], *, rel_filter: set[str] | None) -> list[GraphEdge]`
  - **Type_alias**: `edges`
- **Function**: `def collapse_nodes(nodes: list[str], edges: list[GraphEdge], *, prefixes: list[str]) -> tuple[list[str], list[GraphEdge]]`
  - **Type_alias**: `prefixes`
  - **Function**: `def map_id(cid: str) -> str`
  - **Type_alias**: `mapped_nodes`
  - **Type_alias**: `mapped_edges`
  - **Type_alias**: `out_edges`
- **Function**: `def compute_layout(nodes: list[str], edges: list[GraphEdge], *, layout: str) -> dict[str, tuple[float, float]]`
  > *# dag: best-effort layering using is_a edges; fallback to grid if cyclic.*
  - **Type_alias**: `parents`
  - **Type_alias**: `children`
  - **Type_alias**: `indeg`
  - **Type_alias**: `queue`
  - **Type_alias**: `topo`
  - **Type_alias**: `depth`
  - **Type_alias**: `layers`
  - **Type_alias**: `dx, dy`
  - **Type_alias**: `out`
- **Function**: `def export_dot(nodes: list[str], edges: list[GraphEdge]) -> str`
  - **Type_alias**: `lines`
- **Function**: `def export_excalidraw(nodes: list[str], edges: list[GraphEdge], *, layout: dict[str, tuple[float, float]]) -> dict`
  - **Type_alias**: `elements`
- **Function**: `def export_excalidraw_cli_json(nodes: list[str], edges: list[GraphEdge], *, direction: str) -> dict`
  - **Type_alias**: `out_nodes`
  - **Type_alias**: `out_edges`
- **Function**: `def write_graph(`

---

### 9. /tools/rocs-cli/src/rocs_cli/id_index.py
- **Import**: `OntDoc`
- **Function**: `def _path_in_layer(doc: OntDoc) -> str`
  - **Type_alias**: `parts`
- **Function**: `def build_id_index(*, concepts: dict[str, OntDoc], relations: dict[str, OntDoc]) -> dict`
  - **Type_alias**: `items`

---

### 10. /tools/rocs-cli/src/rocs_cli/inverses.py
- **Import**: `write_doc`
- **Import**: `OntDoc`
- **Import**: `Finding`
- **Function**: `def check_inverses(`
  - **Type_alias**: `findings`
  - **Type_alias**: `rel_label_to_ids`
  - **Function**: `def first_label(doc: OntDoc) -> str | None`
    - **Type_alias**: `labels`

---

### 11. /tools/rocs-cli/src/rocs_cli/layers.py
- **Import**: `re`
- **Import**: `dataclass`
- **Import**: `Path`
- **Import**: `yaml`
- **Import**: `fetch_repo_archive`
- **Constant**: `GITLAB_REF_RE`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `name`
  - **Type_alias**: `src_root`
  - **Type_alias**: `origin`
  > *# path or ref locator*
  - **Type_alias**: `kind`
  > *# path|ref*
- **Function**: `def repo_root(repo: str) -> Path`
- **Function**: `def ontology_root(repo_root: Path) -> Path`
- **Function**: `def manifest_path(repo_root: Path) -> Path`
- **Function**: `def dist_dir(repo_root: Path) -> Path`
- **Function**: `def load_manifest(repo_root: Path) -> dict`
  - **Type_alias**: `p`
- **Function**: `def parse_gitlab_ref(locator: str) -> tuple[str, str] | None`
  - **Type_alias**: `m`
- **Function**: `def _src_root_for_ref(locator: str, *, resolve_refs: bool) -> tuple[Path, str]`
  - **Type_alias**: `parsed`
  - **Type_alias**: `project_path, ref`
  - **Type_alias**: `repo`
- **Function**: `def resolve_layers(repo_root: Path, *, profile: str | None, resolve_refs: bool) -> tuple[list[LayerSpec], dict]`
  - **Type_alias**: `manifest`
  - **Type_alias**: `rocs`
  - **Type_alias**: `profiles`
  - **Type_alias**: `default_profile`
  - **Type_alias**: `layer_cfgs`
  - **Type_alias**: `include`
  - **Type_alias**: `exclude`
  - **Type_alias**: `profile_def`
  - **Type_alias**: `layers`
  - **Type_alias**: `meta`

---

### 12. /tools/rocs-cli/src/rocs_cli/lint.py
- **Import**: `re`
- **Import**: `OntDoc`
- **Import**: `Finding`
- **Constant**: `PLACEHOLDER_RE`
- **Function**: `def _ignored(doc: OntDoc) -> set[str]`
  - **Type_alias**: `ig`
- **Function**: `def lint_docs(concepts: dict[str, OntDoc], relations: dict[str, OntDoc], *, strict_placeholders: bool) -> list[Finding]`
  - **Type_alias**: `findings`
  - **Function**: `def has_placeholder(val: object) -> bool`

---

### 13. /tools/rocs-cli/src/rocs_cli/model.py
- **Import**: `dataclass`
- **Import**: `Path`
- **Import**: `load_frontmatter`
- **Import**: `LayerSpec`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `path`
  - **Type_alias**: `fm`
  - **Type_alias**: `body`
  - **Type_alias**: `layer_name`
  - **Type_alias**: `layer_kind`
  > *# path|ref*
  - **Property**: `ont`
  - **Property**: `ont_id`
  - **Property**: `ont_type`
- **Function**: `def iter_reference_md(src_root: Path) -> list[Path]`
  - **Type_alias**: `ref`
  - **Type_alias**: `out`
- **Function**: `def iter_md(src_root: Path) -> list[Path]`
  - **Type_alias**: `out`
- **Function**: `def load_doc(path: Path, *, layer: LayerSpec) -> OntDoc`
  - **Type_alias**: `fm, body`
- **Function**: `def collect_docs(layers: list[LayerSpec]) -> tuple[dict[str, OntDoc], dict[str, OntDoc]]`
  - **Type_alias**: `concepts`
  - **Type_alias**: `relations`
- **Function**: `def relation_label_index(relations: dict[str, OntDoc]) -> dict[str, set[str]]`
  - **Type_alias**: `rel_label_to_ids`

---

### 14. /tools/rocs-cli/src/rocs_cli/normalize.py
- **Import**: `dataclass`
- **Import**: `Path`
- **Import**: `load_frontmatter`
- **Constant**: `CONCEPT_KEY_ORDER`
- **Constant**: `RELATION_KEY_ORDER`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `path`
  - **Type_alias**: `changed`
- **Function**: `def _reorder_keys(d: dict, order: list[str]) -> dict`
  - **Type_alias**: `out`
- **Function**: `def normalize_doc(path: Path, *, apply: bool) -> bool`
  - **Type_alias**: `fm, body`
  - **Type_alias**: `ont`
  - **Type_alias**: `changed`
  > *# Ensure relations list exists for concepts.*
- **Function**: `def normalize_tree(src_root: Path, *, apply: bool) -> list[NormalizeChange]`
  - **Type_alias**: `changes`

---

### 15. /tools/rocs-cli/src/rocs_cli/pack.py
- **Import**: `dataclass`
- **Import**: `OntDoc`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `max_depth`
  - **Type_alias**: `rel_types`
  - **Type_alias**: `include_relation_defs`
  - **Type_alias**: `max_docs`
  - **Type_alias**: `max_bytes`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `ont_id`
  - **Type_alias**: `kind`
  > *# concept|relation*
  - **Type_alias**: `path`
  - **Type_alias**: `text`
- **Function**: `def _parse_profile_pack_cfg(profile_def: dict | None) -> PackConfig`
  - **Type_alias**: `pack`
  - **Type_alias**: `max_depth`
  - **Type_alias**: `rel_types`
  - **Type_alias**: `raw_rel_types`
  - **Type_alias**: `include_relation_defs`
  - **Function**: `def _maybe_int(v) -> int | None`
- **Function**: `def build_pack(`
  - **Type_alias**: `packed`
  - **Type_alias**: `bytes_used`
  - **Function**: `def add_doc(ont_id: str, kind: str, doc: OntDoc) -> None`
    - **Type_alias**: `text`
    - **Type_alias**: `b`
  > *# Concepts first: root, then BFS expansion.*
  - **Type_alias**: `included_concepts`
  - **Type_alias**: `frontier`
  > *# Deterministic order: root, then other concepts, then relation defs (optional).*
  - **Type_alias**: `ordered_concepts`
  - **Type_alias**: `included_relation_labels`
  - **Type_alias**: `rel_label_to_ids`
  - **Type_alias**: `included_relation_ids`
  - **Type_alias**: `meta`
- **Function**: `def pack_config_from_profile(*, profile_def: dict | None, overrides: dict) -> PackConfig`
  - **Type_alias**: `cfg`
  - **Type_alias**: `max_depth`
  - **Type_alias**: `rel_types`
  - **Type_alias**: `include_relation_defs`
  - **Type_alias**: `max_docs`
  - **Type_alias**: `max_bytes`

---

### 16. /tools/rocs-cli/src/rocs_cli/rules.py
- **Import**: `asdict`
- **Type_alias**: `Severity`
> *# "error" | "warn" | "info"*
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `rule_id`
  - **Type_alias**: `default_severity`
  - **Type_alias**: `summary`
- **Constant**: `RULES`
- **Function**: `def register_rule(rule_id: str, *, default_severity: Severity, summary: str) -> None`
  - **Type_alias**: `RULES[rule_id]`
- **Function**: `@dataclass(frozen=True)`
  - **Type_alias**: `rule_id`
  - **Type_alias**: `severity`
  - **Type_alias**: `message`
  - **Type_alias**: `path`
  - **Type_alias**: `layer`
  - **Method**: `def to_dict(self) -> dict`
- **Function**: `def is_severity(value: str) -> bool`
> *# Core registry (kept intentionally small + boring; add as checks grow).*

---

### 17. /tools/rocs-cli/src/rocs_cli/validate.py
- **Import**: `Path`
- **Import**: `LayerSpec`
- **Import**: `collect_docs`
- **Import**: `Finding`
- **Import**: `re`
- **Constant**: `PLACEHOLDER_RE`
- **Constant**: `GITLAB_REF_RE`
- **Constant**: `_ALLOWED_CONCEPT_KEYS`
- **Constant**: `_ALLOWED_RELATION_KEYS`
- **Function**: `def _id_ok(ont_id: str) -> bool`
- **Function**: `def validate_repo_structure(repo_root: Path) -> list[Finding]`
  - **Type_alias**: `findings`
- **Function**: `def validate_layers_exist(layers: list[LayerSpec]) -> list[Finding]`
  - **Type_alias**: `findings`
- **Function**: `def validate_manifest_placeholders(repo_root: Path, strict_placeholders: bool) -> list[Finding]`
  - **Type_alias**: `mp`
  - **Type_alias**: `text`
  - **Type_alias**: `findings`
- **Function**: `def validate_reference_schema(`
  - **Type_alias**: `findings`
  - **Type_alias**: `concepts, relations`
  - **Type_alias**: `rel_label_to_ids`
  > *# taxonomy cycles on is_a*
  - **Type_alias**: `is_a_edges`
  - **Type_alias**: `graph`
  - **Type_alias**: `state`
  - **Type_alias**: `stack`
  - **Function**: `def dfs(n: str) -> None`
    - **Type_alias**: `state[n]`
    - **Type_alias**: `state[n]`
  - **Type_alias**: `meta`
- **Function**: `def enforce_budget(concepts: dict, relations: dict, *, budget: int | None) -> tuple[bool, dict]`
  - **Type_alias**: `edges`
  - **Type_alias**: `units`
  - **Type_alias**: `payload`

---

### 18. /tools/rocs-cli/src/rocs_cli/vendored.py
- **Import**: `hashlib`
- **Import**: `json`
- **Import**: `Path`
- **Function**: `def sha256_file(path: Path) -> str`
  - **Type_alias**: `h`
- **Function**: `def compute_expected_hashes(vendored_dir: Path) -> dict[str, str]`
  - **Type_alias**: `files`
  - **Type_alias**: `src_root`
  - **Type_alias**: `out`
- **Function**: `def read_vendored_hashes(vendored_dir: Path) -> dict`
  - **Type_alias**: `p`
- **Function**: `def verify_vendored_hashes(vendored_dir: Path) -> tuple[bool, list[str]]`
  - **Type_alias**: `data`
  - **Type_alias**: `expected`
  - **Type_alias**: `ok`
  - **Type_alias**: `lines`