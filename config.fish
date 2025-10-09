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


