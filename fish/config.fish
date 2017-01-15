set -gx TERM "xterm-256color"
set -gx VISUAL "vim"
set -gx PATH "/home/sakiir/bin" $PATH
set -gx PATH "/home/sakiir/.gem/ruby/2.3.0/bin" $PATH # Gems 

set -gx BLIH_TOKEN ""
set -gx BLIH_USER "erwan.dupard@epitech.eu"
set -gx BLIH_GECKO_TOKEN ""
set -gx BLIH_GECKO_USER "gecko"

alias l "ls -lA"
alias md "mkdir -p"

function clean
	find . -name "*~" -print -delete -o -name "#*#" -print -delete -o -name ".gdb_history" -print -delete -o -name "peda-session*" -print -delete
end


function disas
    objdump -M intel -D $argv
end

function repo_list 
    blih -u $BLIH_USER -t $BLIH_TOKEN repository list
end

function repo_create
    if count $argv > /dev/null
        blih -u $BLIH_USER -t $BLIH_TOKEN repository create $argv
    else
        echo "[USAGE] : repo_create REPO_NAME"
    end
end

function repo_setacl
    if count $argv > /dev/null
        blih -u $BLIH_USER -t $BLIH_TOKEN repository setacl $argv
    else
        echo "[USAGE] : repo_setacl REPO_NAME USER [ACL]"
    end
end

function repo_getacl
    if count $argv > /dev/null
        blih -u $BLIH_USER -t $BLIH_TOKEN repository getacl $argv
    else
        echo "[USAGE] : repo_getacl REPO_NAME"
    end
end

function repo_info
    if count $argv > /dev/null
        blih -u $BLIH_USER -t $BLIH_TOKEN repository info $argv
    else
        echo "[USAGE] : repo_info REPO_NAME"
    end
end






