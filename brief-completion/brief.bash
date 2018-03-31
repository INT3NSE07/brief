function _brief_autocomplete {
    list=$(brief -a | sed -n '1,$p')
    COMPREPLY=()
    if [ $COMP_CWORD = 1 ]; then
    COMPREPLY=(`compgen -W "$list" -- $2`)
    fi
}

complete -F _brief_autocomplete brief
