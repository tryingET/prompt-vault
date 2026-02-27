# Bash completion for pv CLI
# Source this file: source /path/to/prompt-vault/scripts/pv-completion.bash

_pv() {
    local cur prev words cword
    _init_completion || return

    local VAULT_DIR="${VAULT_DIR:-$(dirname "${BASH_SOURCE[0]}")/../prompt-vault-db}"
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Main commands
    local commands="
        init clone migrate
        import export watch
        templates skills
        new-template new-skill
        edit-template show history
        search stats analytics
        exec rate
        collection lint backup integrate tui
        branch merge log diff rollback
        status commit activate deprecate
        push pull sql
        help --help --version
    "

    # Subcommand completions
    case ${COMP_WORDS[1]} in
        show|history|activate|deprecate|edit-template)
            # Complete template/skill name
            if [[ ${COMP_WORDS[2]} == template ]] && [ ${COMP_CWORD} -eq 3 ]; then
                local templates=$(cd "$VAULT_DIR" 2>/dev/null && dolt sql -r csv -q "SELECT name FROM prompt_templates WHERE status = 'active'" 2>/dev/null | tail -n +2)
                COMPREPLY=($(compgen -W "$templates" -- "$cur"))
                return
            fi
            if [[ ${COMP_WORDS[2]} == skill ]] && [ ${COMP_CWORD} -eq 3 ]; then
                local skills=$(cd "$VAULT_DIR" 2>/dev/null && dolt sql -r csv -q "SELECT name FROM skills WHERE status = 'active'" 2>/dev/null | tail -n +2)
                COMPREPLY=($(compgen -W "$skills" -- "$cur"))
                return
            fi
            COMPREPLY=($(compgen -W "template skill" -- "$cur"))
            return
            ;;

        collection)
            local collection_cmds="list create delete show add-template add-skill remove-template export"
            if [ ${COMP_CWORD} -eq 2 ]; then
                COMPREPLY=($(compgen -W "$collection_cmds" -- "$cur"))
                return
            fi
            if [[ ${COMP_WORDS[2]} == show || ${COMP_WORDS[2]} == delete || ${COMP_WORDS[2]} == add-template ]]; then
                local collections=$(cd "$VAULT_DIR" 2>/dev/null && dolt sql -r csv -q "SELECT name FROM collections" 2>/dev/null | tail -n +2)
                COMPREPLY=($(compgen -W "$collections" -- "$cur"))
                return
            fi
            ;;

        analytics)
            local analytics_cmds="overview top-templates ratings issues trends template skill recent compare export"
            COMPREPLY=($(compgen -W "$analytics_cmds" -- "$cur"))
            return
            ;;

        backup)
            local backup_cmds="create list restore schedule unschedule prune verify cloud-sync"
            COMPREPLY=($(compgen -W "$backup_cmds" -- "$cur"))
            return
            ;;

        integrate)
            local integrate_cmds="langchain openai-functions semantic-kernel embeddings obsidian api-server webhook"
            COMPREPLY=($(compgen -W "$integrate_cmds" -- "$cur"))
            return
            ;;

        branch|merge)
            local branches=$(cd "$VAULT_DIR" 2>/dev/null && dolt branch -a 2>/dev/null | sed 's/\*//;s/^  //' | grep -v '^$')
            COMPREPLY=($(compgen -W "$branches" -- "$cur"))
            return
            ;;

        migrate)
            COMPREPLY=($(compgen -W "up down status create" -- "$cur"))
            return
            ;;

        exec)
            local templates=$(cd "$VAULT_DIR" 2>/dev/null && dolt sql -r csv -q "SELECT name FROM prompt_templates WHERE status = 'active'" 2>/dev/null | tail -n +2)
            COMPREPLY=($(compgen -W "$templates" -- "$cur"))
            return
            ;;

        lint)
            local all_items=$(cd "$VAULT_DIR" 2>/dev/null && {
                dolt sql -r csv -q "SELECT name FROM prompt_templates WHERE status = 'active'" 2>/dev/null | tail -n +2
                dolt sql -r csv -q "SELECT name FROM skills WHERE status = 'active'" 2>/dev/null | tail -n +2
            })
            COMPREPLY=($(compgen -W "$all_items" -- "$cur"))
            return
            ;;

        rollback)
            # rollback template|skill <name> <version>
            case ${COMP_CWORD} in
                2) COMPREPLY=($(compgen -W "template skill" -- "$cur")) ;;
                3)
                    if [[ ${COMP_WORDS[2]} == template ]]; then
                        local templates=$(cd "$VAULT_DIR" 2>/dev/null && dolt sql -r csv -q "SELECT name FROM prompt_templates WHERE status = 'active'" 2>/dev/null | tail -n +2)
                        COMPREPLY=($(compgen -W "$templates" -- "$cur"))
                    else
                        local skills=$(cd "$VAULT_DIR" 2>/dev/null && dolt sql -r csv -q "SELECT name FROM skills WHERE status = 'active'" 2>/dev/null | tail -n +2)
                        COMPREPLY=($(compgen -W "$skills" -- "$cur"))
                    fi
                    ;;
            esac
            return
            ;;

        rate)
            # Complete execution IDs
            local exec_ids=$(cd "$VAULT_DIR" 2>/dev/null && dolt sql -r csv -q "SELECT id FROM executions ORDER BY created_at DESC LIMIT 20" 2>/dev/null | tail -n +2)
            COMPREPLY=($(compgen -W "$exec_ids" -- "$cur"))
            return
            ;;

        diff)
            local refs=$(cd "$VAULT_DIR" 2>/dev/null && {
                echo "HEAD HEAD~1 HEAD~2 HEAD~5"
                dolt branch -a 2>/dev/null | sed 's/\*//;s/^  //'
            })
            COMPREPLY=($(compgen -W "$refs" -- "$cur"))
            return
            ;;
    esac

    # Complete main commands
    if [ ${COMP_CWORD} -eq 1 ]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    fi
}

complete -F _pv pv 2>/dev/null || true
