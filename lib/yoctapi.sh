[public:assoc] YOCTAPI
YOCTAPI['config':'get':'action']="read"
YOCTAPI['config':'post':'action']="write"
YOCTAPI['config':'put':'action']="write"
YOCTAPI['config':'delete':'action']="write"

Yoctapi::api::main(){
    [private:assoc] result
    [private] matcher="${uri[1]}"

    [[ -z "${YOCTAPI['route':$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']}" ]] && { Api::send::not_found; }

    # Build creadentials
    Yoctapi::build::credentials 

    DATA['matcher':$matcher]="${YOCTAPI['route':$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']}"

    Yoctapi::parse::get::options "$matcher"
    
    # Run Request
    Yoctapi::${REQUEST_METHOD,,} "$matcher"
    
    [public:assoc] AUDIT_CONTEXT
    AUDIT_CONTEXT['GET']="$(Json::create GET)"
    audit::log
}

Yoctapi::parse::get::options(){
    [private] matcher="$1"
    [private] key

    for key in "${YOCTAPI_GET_PARAMS[@]}"; do
        if ! [[ -z "${GET[$key]}" ]]; then
            YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:${key#*:}]="${GET[$key]}"
        fi
    done
}

Yoctapi::build::credentials(){
    [public:map] array="${YOCTAPI['route':$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']^^}"
 
    while read line; do
        array[connection:$line]="${YOCTAPI[route:$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:credentials:$line]}"
    done < <(Type::array::get::key route:$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:credentials YOCTAPI)

    return 
}

Yoctapi::get(){
    [private] matcher="$1"
    [private] search="${uri[2]//;/}"
    [private] display
    [private:assoc] result
    [private:assoc] output
    [private:assoc] query

    query['table']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'table']}"

    if ! [[ -z "$search" ]]; then 
        query['search':'column']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'search']}"
        query['search':'key']="$search"
    fi

    query['filter']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'filter']}"

    display="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'object']}"

    [[ -z "${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'limit']}" ]] || query['limit']="${GET['data':'limit']}"

    Data::get "result" "$(Data::build::query::get query $matcher)" "$matcher"

    while read line; do
        while read keys; do
            output[$matcher:${result['result':$line:$display]}:$keys]="${result[result:$line:$keys]}"
        done < <(Type::array::get::key result:$line result)
    done < <(Type::array::get::key result result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::get output
}

Yoctapi::post(){
    [private] matcher="$1"
    [private:assoc] query
    [private:assoc] result
    [private:assoc] output

    query['table']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'table']}"

    [[ -z "${POST[*]}" ]] && Api::send::fail

    Type::array::fusion POST query

    Data::post 'result' "$(Data::build::query::post query $matcher)" "$matcher"
   
    while read line; do
        output[$matcher:$line]="${result['result':'1':$line]}"
    done < <(Type::array::get::key result:1 result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::post output
}

Yoctapi::put(){
    [private] matcher="$1"
    [private] search="${uri[2]}"
    [private:assoc] query
    [private:assoc] result
    [private:assoc] output

    query['table']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'table']}"

    [[ -z "${POST[*]}" ]] && Api::send::fail
    [[ -z "${search}" ]] && Api::send::not_found

    Type::array::fusion POST query

    if ! [[ -z "$search" ]]; then
        query['search':'column']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'search']}"
        query['search':'key']="$search"
    fi

    Data::put 'result' "$(Data::build::query::put query $matcher)" "$matcher"

    while read line; do
        output[$matcher:$line]="${result['result':'1':$line]}"
    done < <(Type::array::get::key result:1 result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::put output
}

Yoctapi::delete(){
    [private] matcher="$1"
    [private] search="${uri[2]}"
    [private:assoc] query
    [private:assoc] result
    [private:assoc] output

    query['table']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'table']}"

    [[ -z "${search}" ]] && Api::send::not_found

    if ! [[ -z "$search" ]]; then
        query['search':'column']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'search']}"
        query['search':'key']="$search"
    fi

    Data::delete 'result' "$(Data::build::query::delete query $matcher)" "$matcher"

    while read line; do
        output[$matcher:$line]="${result['result':'1':$line]}"
    done < <(Type::array::get::key result:1 result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::delete output
}

