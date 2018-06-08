function db-get ()
{
    local table="${1%%;*}" action="$(urlencode -d "${2%%;*}")" _select _where _limit mysql_command="mysql-connect-slave"

    printf -v action "%q" "$action"
    printf -v table "%q" "$table"

    if [[ -z "${DB_GET[$table:'column']}" ]]
    then
        _select="*"
    else
        _select="${DB_GET[$table:'column']}"
    fi

    if [[ ! -z "${GET['selectfields']}" ]]
    then
	_select="$(url_decode ${GET['selectfields']%%;*})"
    fi

    if [[ -z "${DB_GET[$table:'where']}" ]]
    then
        _where=""
    else
        _where="where ${DB_GET[$table:'where']} like '$action'"
    fi

    ! [[ -z "${GET['limit']}" ]] && _limit="limit $(url_decode ${GET['limit']%%;*})"

    mysql-to-json "select $_select from $table $_where $_limit"
}

function db-put ()
{
    local table="${1%%;*}" action="$(urlencode -d "${2%%;*}")" _query _json _update value result

    printf -v action "%q" "$action"
    printf -v table "%q" "$table"

    [[ -z "$action" ]] && return

    [[ -z "${POST['json']}" ]] && return

    [[ -z "${DB_PUT[$table:'where']}" ]] && return

    _json="$(echo "${POST['json']}" | jq .data)"

    [[ -z "$_json" ]] && return

    json-to-array arr "$_json"

    _query="update $table set"

    for value in "${!arr[@]}"
    do
        result="${arr[$value]}"

        # escape ;
        value="${value%%;*}"
        result="${result%%;*}"

        printf -v value "%q" "$value"
        printf -v result "%q" "$result"

        _update+="\`${value}\`='$result',"
    done

    _query+=" ${_update%,} where ${DB_PUT[$table:'where']}='$action'"

    mysql-connector-master "$_query" &>/dev/null && echo "{ \"msg\": \"Succesfully updated!\", \"${DB_PUT[$table:'where']}\": \"$action\", \"status\":\"$?\" }"

}

function db-delete ()
{
    local table="${1%%;*}" action="$(urlencode -d "${2%%;*}")"

    printf -v action "%q" "$action"
    printf -v table "%q" "$table"

    [[ -z "$action" ]] && return

    [[ -z "${DB_DELETE[$table:'where']}" ]] && return

    mysql-connector-master "delete from $table where ${DB_DELETE[$table:'where']}='$action'" &>/dev/null && echo '{ "msg": "Sccesfully removed!" }'
}

function db-post ()
{
    local table="${1%%;*}" _query _json _insert value result

    [[ -z "$table" ]] && return

    printf -v table "%q" "$table"
    
    [[ -z "${POST['json']}" ]] && return

    _json="$(echo "${POST['json']}" | jq .data)"

    json-to-array arr "$_json"

    _query="insert into $table set"
    
    for value in "${!arr[@]}"
    do
        result="${arr[$value]}"

        # escape ;
        value="${value%%;*}"
        result="${result%%;*}"

        printf -v value "%q" "$value"
        printf -v result "%q" "$result"

        _insert+="\`${value}\`='$result',"
    done

    _query+=" ${_insert%,}"

    mysql-connector-master "$_query" &>/dev/null && echo '{ "msg": "Succesfully added!" }'
}

function dbconnector ()
{
    local table action method

    table="${uri[1]}"
    action="${uri[2]}"
    method="$REQUEST_METHOD"

    case "$method" in
        GET)            db-get "$table" "$action"                                       ;;
        PUT)            db-put "$table" "$action"                                       ;;
        DELETE)         db-delete "$table" "$action"                                    ;;
        POST)           db-post "$table"                                                ;;
        *)              preordreMessage 500 "Method not allowed!"                       ;;
    esac

}

