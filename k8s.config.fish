if status is-interactive
    alias bat='batcat'
    alias cat='bat -pp'

    # --- Systemd Journal Helpers ---
    # jlogs             - Показать логи, новые сверху (journalctl -r)
    # jfollow           - Следить за логами в реальном времени (journalctl -f)
    # jerr              - Следить только за ошибками
    # jboot             - Показать логи с момента загрузки
    # junit <service>   - Следить за логами конкретного сервиса
    function jlogs --wraps='journalctl' --description 'View systemd journal with bat (newest first)'
        set -l bat_args --language=log --color=always --style=plain
        set -l jctl_args $argv
        if contains -- "-f" $jctl_args; or contains -- "--follow" $jctl_args
            set -a bat_args --paging=never
        else
            set -a jctl_args -r
        end
        command journalctl --no-pager $jctl_args | bat $bat_args
    end

    function jfollow --wraps='jlogs -f' --description 'Follow systemd journal with bat'
        jlogs -f $argv
    end

    function jerr --wraps='jlogs -p 3 -f' --description 'Follow systemd journal errors with bat'
        jlogs -p 3 -f $argv
    end

    function jboot --wraps='jlogs -b 0' --description 'View logs for current boot with bat'
        jlogs -b 0 $argv
    end

    function junit --wraps='jlogs -u ... -f' --description 'Follow logs for a specific unit'
        if test (count $argv) -eq 0
            echo "Использование: junit <имя_юнита> [другие_опции_journalctl]"
            return 1
        end
        jlogs -u $argv[1] -f $argv[2..-1]
    end

    # --- Sudo Wrapper ---
    function sudo --wraps=sudo --description 'Sudo wrapper with bat support'
        set -l cmd $argv[1]
        set -l rest $argv[2..]

        switch $cmd
            case cat
                if test (count $rest) -gt 0
                    command sudo cat $rest | bat --file-name="$rest[-1]" --paging=never --style=plain
                else
                    command sudo cat | bat --paging=never --style=plain
                end
            case tail
                command sudo tail $rest | bat -l log --paging=never --color=always --style=plain
            case head
                command sudo head $rest | bat -l log --paging=never --color=always --style=plain

            # --- Sudo integration for journalctl functions ---
            case jlogs jfollow jerr jboot junit
                set -l jctl_args
                switch $cmd
                    case jlogs
                        set jctl_args $rest
                    case jfollow
                        set jctl_args -f $rest
                    case jerr
                        set jctl_args -p 3 -f $rest
                    case jboot
                        set jctl_args -b 0 $rest
                    case junit
                        if test (count $rest) -eq 0
                            echo "Использование: sudo junit <имя_юнита>" >&2
                            return 1
                        end
                        set jctl_args -u $rest[1] -f $rest[2..-1]
                end

                set -l bat_args --language=log --color=always --style=plain
                if contains -- "-f" $jctl_args; or contains -- "--follow" $jctl_args
                    set -a bat_args --paging=never
                else if test "$cmd" = "jlogs"
                    set -a jctl_args -r
                end

                command sudo journalctl --no-pager $jctl_args | bat $bat_args

            case '*'
                command sudo $argv
        end
    end

    function psf --wraps='ps auxf' --description 'Colored ps auxf tree view'
        ps auxf | bat -l sh --paging=never --color=always --style=plain $argv
    end

    function dlogs --wraps='docker compose logs -f -t' --description 'Colored logs from docker-compose'
        docker compose logs -f -t --no-color | bat -l log --paging=never --color=always --style=plain $argv
    end

    function dl --wraps='docker logs -f -t' --description 'Colored logs from a specific container'
        docker logs -f -t $argv | bat -l log --paging=never --color=always --style=plain
    end

    function tail --wraps=tail --description 'Alias for tail | bat'
        command tail $argv | bat -l log --paging=never --color=always --style=plain
    end

    function head --wraps=head --description 'Alias for head | bat'
        command head $argv | bat -l log --paging=never --color=always --style=plain
    end

    function sudo --wraps=sudo --description 'Sudo wrapper with bat support'
        set -l cmd $argv[1]
        set -l rest $argv[2..]
        
        switch $cmd
            case cat
                if test (count $rest) -gt 0
                    command sudo cat $rest | batcat --file-name="$rest[-1]" --paging=never --style=plain
                else
                    command sudo cat | batcat --paging=never --style=plain
                end
            case tail
                if test (count $rest) -gt 0
                    set -l filename
                    for arg in $rest
                        if not string match -q -- '-*' $arg
                            set filename $arg
                        end
                    end
                    if test -n "$filename"
                        command sudo tail $rest | batcat --file-name="$filename" --paging=never --style=plain
                    else
                        command sudo tail $rest | bat -l log --paging=never --color=always --style=plain
                    end
                else
                    command sudo tail | bat -l log --paging=never --color=always --style=plain
                end
            case head
                if test (count $rest) -gt 0
                    set -l filename
                    for arg in $rest
                        if not string match -q -- '-*' $arg
                            set filename $arg
                        end
                    end
                    if test -n "$filename"
                        command sudo head $rest | batcat --file-name="$filename" --paging=never --style=plain
                    else
                        command sudo head $rest | bat -l log --paging=never --color=always --style=plain
                    end
                else
                    command sudo head | bat -l log --paging=never --color=always --style=plain
                end
            case '*'
                command sudo $argv
        end
    end
end

function k --wraps=kubectl --description 'kubectl with smart output formatting'
    if test (count $argv) -gt 0
        switch $argv[1]
            case 'logs'
                command kubectl $argv | bat -l log --paging=never --color=always --style=plain
                return
        end
    end

    set -l has_yaml 0
    set -l has_json 0

    for arg in $argv
        if string match -qr -- '(-o|--output=?)(yaml|ya?ml)' $arg
            set has_yaml 1
        else if string match -qr -- '(-o|--output=?)(json)' $arg
            set has_json 1
        end
    end

    if test $has_yaml -eq 1
        command kubectl $argv | bat -l yaml --paging=never --style=plain
    else if test $has_json -eq 1
        command kubectl $argv | bat -l json --paging=never --style=plain
    else
        command kubectl $argv
    end
end

function kl --wraps='kubectl logs' --description 'Colored logs from Kubernetes pods'
    set -l has_follow 0
    for arg in $argv
        if string match -qr -- '^(-f|--follow)$' $arg
            set has_follow 1
            break
        end
    end
    
    if test $has_follow -eq 1
        kubectl logs $argv --color=never | bat -l log --paging=never --color=always --style=plain
    else
        kubectl logs $argv --color=never | bat -l log --paging=never --color=always --style=plain
    end
end

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
