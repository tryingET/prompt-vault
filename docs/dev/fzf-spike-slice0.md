---
summary: "Slice 0 viability spike for unified PTX + vault-client FZF transition."
read_when:
  - "Before changing selector runtime assumptions"
  - "When validating fallback behavior for non-interactive fzf"
---

# Slice 0 Spike — FZF Viability

Date: 2026-03-03

## Contexts tested

1. `~/ai-society/core/prompt-vault`
2. `~/programming/pi-extensions/pi-autonomous-session-control`

## Probe commands

```bash
printf 'alpha\nbeta\n' | fzf
printf 'alpha\nbeta\n' | fzf --filter be
```

## Results

| Context | Interactive (`fzf`) | Filter (`fzf --filter be`) |
|---|---|---|
| prompt-vault | exit `2`, stderr `inappropriate ioctl for device` | exit `0`, stdout `beta` |
| pi-autonomous-session-control | exit `2`, stderr `inappropriate ioctl for device` | exit `0`, stdout `beta` |

## Interpretation

- Interactive fzf invocation from the extension execution path is **not reliable** (TTY mismatch).
- Non-interactive filter mode is reliable and can be used for ranking.
- Selector UX should therefore be:
  1. try `fzf --filter` for ranking (`mode=fzf`)
  2. use deterministic in-app chooser for final user pick
  3. fall back to deterministic in-app ranking when fzf binary/path fails (`mode=fallback`)
