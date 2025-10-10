if status is-interactive
    # Commands to run in interactive sessions can go here
    alias nvme 'sudo watch -n 0 nvme smart-log /dev/nvme0'
    alias nano 'vim'
    #alias zstd 'toolbox run --container work-stuff zstd'
    #alias zstdcat 'toolbox run --container work-stuff zstdcat'
    #alias lz4 'toolbox run --container work-stuff lz4'
    #alias lz4cat 'toolbox run --container work-stuff lz4cat'
    alias psql 'toolbox run --container work-stuff psql'
    alias pg_dump 'toolbox run --container work-stuff pg_dump'
    alias mysql 'toolbox run --container work-stuff mysql'
    alias mysqldump 'toolbox run --container work-stuff mysqldump'
    alias go 'toolbox run --container work-stuff go'
    alias neofetch 'fastfetch'
    alias cat='bat -pp'

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

    # Обёртка для sudo с поддержкой bat
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
                if test (count $rest) -gt 0
                    set -l filename
                    for arg in $rest
                        if not string match -q -- '-*' $arg
                            set filename $arg
                        end
                    end
                    if test -n "$filename"
                        command sudo tail $rest | bat --file-name="$filename" --paging=never --style=plain
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
                        command sudo head $rest | bat --file-name="$filename" --paging=never --style=plain
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

# --- Удобная работа с системным журналом (journalctl) ---
# Примеры использования:
# jlogs             - показать логи, начиная с самых новых (как journalctl -r)
# jfollow           - следить за логами в реальном времени (как journalctl -f)
# jerr              - следить только за ошибками
# jboot             - показать логи с момента последней загрузки системы
# junit <service>   - следить за логами конкретного сервиса, например: junit sshd

# Автоматический выбор между bat и batcat (для совместимости с Debian/Ubuntu)
if not command -v bat >/dev/null 2>&1; and command -v batcat >/dev/null 2>&1
  alias bat="batcat"
end

# Основная функция. По умолчанию показывает логи в обратном порядке (новые сверху).
# Автоматически отключает обратный порядок при слежении (-f), т.к. они несовместимы.
function jlogs --wraps='journalctl' --description 'View systemd journal with bat (newest first)'
    set -l bat_args --language=log --color=always --style=plain
    set -l jctl_args $argv

    if contains -- "-f" $jctl_args; or contains -- "--follow" $jctl_args
        set -a bat_args --paging=never
    else
        # Показываем новые логи первыми, но только если не в режиме слежения.
        set -a jctl_args -r
    end

    command journalctl --no-pager $jctl_args | bat $bat_args
end

# Короткий псевдоним для слежения за всеми логами.
function jfollow --wraps='jlogs -f' --description 'Follow systemd journal with bat'
    jlogs -f $argv
end

# Слежение только за ошибками (уровень 3) и выше.
function jerr --wraps='jlogs -p 3 -f' --description 'Follow systemd journal errors with bat'
    jlogs -p 3 -f $argv
end

# Просмотр логов для текущей сессии загрузки.
function jboot --wraps='jlogs -b 0' --description 'View logs for current boot with bat'
    jlogs -b 0 $argv
end

# Слежение за логами конкретного systemd-юнита.
function junit --wraps='jlogs -u ... -f' --description 'Follow logs for a specific unit'
    if test (count $argv) -eq 0
        echo "Использование: junit <имя_юнита> [другие_опции_journalctl]"
        return 1
    end
    jlogs -u $argv[1] -f $argv[2..-1]
end
