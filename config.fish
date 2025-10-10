if status is-interactive
    # --- General Aliases ---
    alias nvme 'sudo watch -n 0 nvme smart-log /dev/nvme0'
    alias vim 'nvim'
    alias psql 'toolbox run --container work-stuff psql'
    alias pg_dump 'toolbox run --container work-stuff pg_dump'
    alias mysql 'toolbox run --container work-stuff mysql'
    alias mysqldump 'toolbox run --container work-stuff mysqldump'
    alias go 'toolbox run --container work-stuff go'
    alias neofetch 'fastfetch'
    alias cat='bat -pp'

    # --- Bat Helpers ---
    if not command -v bat >/dev/null 2>&1; and command -v batcat >/dev/null 2>&1
      alias bat="batcat"
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
end
