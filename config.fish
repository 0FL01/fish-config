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
end

