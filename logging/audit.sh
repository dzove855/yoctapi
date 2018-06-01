# audit

function audit::log ()
{
    local context

    case "$_level" in
        crit)   auditlevel="panic"     ;;
    esac

    # Parse Message

    IFS='|' read -a _data <<< $_message

    for data in "${_data[@]}"
    do
        context+=" -C $data"
    done

    audit-client.sh -U $auditurl -l ${auditlevel:-$_level} -o http -b "$uri" -m "$application_name : $_level : ${REQUEST_URI%\?*}" $context -2 &>/dev/null
}
