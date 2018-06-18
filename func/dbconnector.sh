function db-get ()
{
    local matcher="$1" action="$2" _select _where _limit mysql_command="mysql-connect-slave" table display

    table="${DB_GET[$matcher:'table']:-$matcher}"

    _select="${DB_GET[$matcher:'column']:-*}"

    display="${DB_GET[$matcher:'display']:-$matcher}"

    if [[ ! -z "${DB_GET[$matcher:'selectfields']}" ]]
    then
	_select="${DB_GET[$matcher:'selectfields']%%;*}"
    fi

    if [[ -z "${DB_GET[$matcher:'where']}" ]]
    then
        _where=""
    else
        _where="where ${DB_GET[$matcher:'where']} like '$action'"
    fi

    ! [[ -z "${GET['limit']}" ]] && _limit="limit ${GET['limit']%%;*}"

    mysql-to-json "$display" "select $_select from $table $_where $_limit"
}

function db-put ()
{
    local matcher="$1" action="$2" _query _json _update value result table

    [[ -z "$action" ]] && return

    [[ -z "${POST['json']}" ]] && return

    [[ -z "${DB_PUT[$table:'where']}" ]] && return
    
    table="${DB_PUT[$matcher:'table']:-$matcher}"

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
    local matcher="$1" action="$2" table

    [[ -z "$action" ]] && return

    [[ -z "${DB_DELETE[$table:'where']}" ]] && return

    table="${DB_DELETE[$matcher:'table']:-$matcher}"

    mysql-connector-master "delete from $table where ${DB_DELETE[$table:'where']}='$action'" &>/dev/null && echo '{ "msg": "Sccesfully removed!" }'
}

function db-post ()
{
    local matcher="$1" _query _json _insert value result table

    [[ -z "$table" ]] && return
    
    [[ -z "${POST['json']}" ]] && return

    table="${DB_POST[$matcher:'table']:-$matcher}"

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
    local matcher action method

    matcher="${uri[1]%%;*}"
    action="$(urlencode -d "${uri[2]%%;*}")"
    method="$REQUEST_METHOD"

    printf -v matcher "%q" "$matcher"
    printf -v action "%q" "$action"

    case "$method" in
        GET)            db-get "$matcher" "$action"                                     ;;
        PUT)            db-put "$matcher" "$action"                                     ;;
        DELETE)         db-delete "$matcher" "$action"                                  ;;
        POST)           db-post "$matcher"                                              ;;
        *)              fail "Method not allowed!"                                      ;;
    esac

}

function fail()
{
    http::send::status 500
    echo '{ "msg": "Method not allowed!"'
}

