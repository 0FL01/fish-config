# =============================================================================
# ZSH Configuration with Oh-My-Zsh
# https://github.com/0FL01/fish-config
# =============================================================================

# --- Oh-My-Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"

# Theme (see https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    docker
    docker-compose
    kubectl
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)

# Load completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# =============================================================================
# Custom Configuration
# =============================================================================

# --- General Aliases ---
#alias nvme='sudo watch -n 0 nvme smart-log /dev/nvme0'
#alias vim='nvim'
#alias psql='toolbox run --container work-stuff psql'
#alias pg_dump='toolbox run --container work-stuff pg_dump'
#alias mysql='toolbox run --container work-stuff mysql'
#alias mysqldump='toolbox run --container work-stuff mysqldump'
#alias go='toolbox run --container work-stuff go'
#alias neofetch='fastfetch'

# --- Bat Setup ---
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
    alias bat='batcat'
fi
alias cat='bat -pp'

# --- Colored Output Functions ---

# Colored ps auxf tree view
psf() {
    ps auxf | bat -l sh --paging=never --color=always --style=plain "$@"
}

# Colored logs from docker-compose
dlogs() {
    docker compose logs -f -t --no-color | bat -l log --paging=never --color=always --style=plain "$@"
}

# Colored logs from a specific container
dl() {
    docker logs -f -t "$@" | bat -l log --paging=never --color=always --style=plain
}

# Tail with bat
tail() {
    command tail "$@" | bat -l log --paging=never --color=always --style=plain
}

# Head with bat
head() {
    command head "$@" | bat -l log --paging=never --color=always --style=plain
}

# =============================================================================
# Systemd Journal Helpers
# =============================================================================
# jlogs             - Показать логи, новые сверху (journalctl -r)
# jfollow           - Следить за логами в реальном времени (journalctl -f)
# jerr              - Следить только за ошибками
# jboot             - Показать логи с момента загрузки
# junit <service>   - Следить за логами конкретного сервиса

# View systemd journal with bat (newest first)
jlogs() {
    local bat_args=(--language=log --color=always --style=plain)
    local jctl_args=("$@")
    
    if [[ " ${jctl_args[*]} " =~ " -f " ]] || [[ " ${jctl_args[*]} " =~ " --follow " ]]; then
        bat_args+=(--paging=never)
    else
        jctl_args+=(-r)
    fi
    
    command journalctl --no-pager "${jctl_args[@]}" | bat "${bat_args[@]}"
}

# Follow systemd journal with bat
jfollow() {
    jlogs -f "$@"
}

# Follow systemd journal errors with bat
jerr() {
    jlogs -p 3 -f "$@"
}

# View logs for current boot with bat
jboot() {
    jlogs -b 0 "$@"
}

# Follow logs for a specific unit
junit() {
    if [[ $# -eq 0 ]]; then
        echo "Использование: junit <имя_юнита> [другие_опции_journalctl]"
        return 1
    fi
    jlogs -u "$1" -f "${@:2}"
}

# =============================================================================
# Sudo Wrapper
# =============================================================================

sudo() {
    local cmd="$1"
    shift
    local rest=("$@")

    case "$cmd" in
        cat)
            if [[ ${#rest[@]} -gt 0 ]]; then
                command sudo cat "${rest[@]}" | bat --file-name="${rest[-1]}" --paging=never --style=plain
            else
                command sudo cat | bat --paging=never --style=plain
            fi
            ;;
        tail)
            command sudo tail "${rest[@]}" | bat -l log --paging=never --color=always --style=plain
            ;;
        head)
            command sudo head "${rest[@]}" | bat -l log --paging=never --color=always --style=plain
            ;;
        jlogs|jfollow|jerr|jboot|junit)
            local jctl_args=()
            case "$cmd" in
                jlogs)
                    jctl_args=("${rest[@]}")
                    ;;
                jfollow)
                    jctl_args=(-f "${rest[@]}")
                    ;;
                jerr)
                    jctl_args=(-p 3 -f "${rest[@]}")
                    ;;
                jboot)
                    jctl_args=(-b 0 "${rest[@]}")
                    ;;
                junit)
                    if [[ ${#rest[@]} -eq 0 ]]; then
                        echo "Использование: sudo junit <имя_юнита>" >&2
                        return 1
                    fi
                    jctl_args=(-u "${rest[1]}" -f "${rest[@]:1}")
                    ;;
            esac

            local bat_args=(--language=log --color=always --style=plain)
            if [[ " ${jctl_args[*]} " =~ " -f " ]] || [[ " ${jctl_args[*]} " =~ " --follow " ]]; then
                bat_args+=(--paging=never)
            elif [[ "$cmd" == "jlogs" ]]; then
                jctl_args+=(-r)
            fi

            command sudo journalctl --no-pager "${jctl_args[@]}" | bat "${bat_args[@]}"
            ;;
        *)
            command sudo "$cmd" "${rest[@]}"
            ;;
    esac
}

# =============================================================================
# Kubernetes Helpers
# =============================================================================

# kubectl with smart output formatting
k() {
    if [[ $# -gt 0 ]]; then
        case "$1" in
            logs)
                command kubectl "$@" | bat -l log --paging=never --color=always --style=plain
                return
                ;;
        esac
    fi

    local has_yaml=0
    local has_json=0

    for arg in "$@"; do
        if [[ "$arg" =~ (-o|--output=?)(yaml|ya?ml) ]]; then
            has_yaml=1
        elif [[ "$arg" =~ (-o|--output=?)(json) ]]; then
            has_json=1
        fi
    done

    if [[ $has_yaml -eq 1 ]]; then
        command kubectl "$@" | bat -l yaml --paging=never --style=plain
    elif [[ $has_json -eq 1 ]]; then
        command kubectl "$@" | bat -l json --paging=never --style=plain
    else
        command kubectl "$@"
    fi
}

# Colored logs from Kubernetes pods
kl() {
    kubectl logs "$@" --color=never | bat -l log --paging=never --color=always --style=plain
}

# --- Kubectl Aliases ---
alias ka='k apply -f'
alias kdel='k delete'
alias kdelp='k delete pod'
alias kdelf='k delete -f'
alias kdesc='k describe'
alias kedit='k edit'
alias kex='k exec -i -t'
alias kl='k logs -f'

alias kg='k get'
alias kgp='k get pods'
alias kgd='k get deployment'
alias kgs='k get service'
alias kgi='k get ingress'
alias kgn='k get nodes'
alias kgns='k get namespaces'
alias kgcm='k get configmap'

alias kgy='k get --output=yaml'
alias kgj='k get --output=json'

# =============================================================================
# FZF - Fuzzy Finder
# =============================================================================
# Ctrl+R - поиск по истории команд
# Ctrl+T - поиск файлов
# Alt+C  - переход в директорию

if command -v fzf &>/dev/null; then
    # Try modern zsh integration first (fzf 0.48+)
    if [[ $(fzf --version | cut -d. -f1-2 | tr -d .) -ge 048 ]] 2>/dev/null; then
        source <(fzf --zsh)
    elif [[ -f ~/.fzf.zsh ]]; then
        source ~/.fzf.zsh
    fi
    
    # FZF options
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
    
    # Use fd if available (faster than find)
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
fi

# =============================================================================
# Zoxide - Smarter cd
# =============================================================================
# z <query>  - перейти в директорию
# zi <query> - интерактивный выбор директории

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# =============================================================================
# Pay Respects - Press F to fix command
# =============================================================================
# f - исправить последнюю команду
# Нажми F чтобы отдать респект (и исправить ошибку)

if command -v pay-respects &>/dev/null; then
    eval "$(pay-respects zsh --alias)"
fi
