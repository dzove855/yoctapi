[public:assoc] YOCTAPI
YOCTAPI['config':'get':'action']="read"
YOCTAPI['config':'post':'action']="write"
YOCTAPI['config':'put':'action']="write"
YOCTAPI['config':'delete':'action']="write"

Yoctapi::api::main(){
    [private:assoc] result
    [private] matcher="${uri[1]}"

    [[ "$REQUEST_METHOD" == "OPTIONS" ]] && { Yoctapi::options "$matcher"; exit; }

    [[ -z "${YOCTAPI['route':$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']}" ]] && { Api::send::not_found; }

    Api::check::content_type

    # Build creadentials
    Yoctapi::build::credentials 

    DATA['matcher':$matcher]="${YOCTAPI['route':$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']}"

    Yoctapi::parse::get::options "$matcher"
    
    # Run Request
    Yoctapi::${REQUEST_METHOD,,} "$matcher"
}

Yoctapi::parse::get::options(){
    [private] matcher="$1"
    [private] key

    for key in "${YOCTAPI_GET_PARAMS[@]}"; do
        if ! [[ -z "${GET[$key]}" ]]; then
            YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:${key#*:}]="${GET[$key]}"
        fi
    done

    for key in "${YOCTAPI_GET_CONFIG_PARAMS[@]}"; do
        if ! [[ -z "${GET[$key]}" ]]; then
            YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'config':${key#*:}]="${GET[$key]}"
        fi
    done
}

Yoctapi::build::credentials(){
    [public:map] array="${YOCTAPI['route':$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']^^}"
 
    while read line; do
        array[connection:$line]="${YOCTAPI[route:$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:credentials:$line]}"
    done < <(Type::array::get::key route:$matcher:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:credentials: YOCTAPI)

    return 
}

Yoctapi::audit(){
    Audit::set::message "Request $REQUEST_METHOND on $(printf '/%s' "${uri[@]}")"
    Audit::set::namespace
    Audit::set::command "$(printf '/%s' "${uri[@]}")"

    [[ -z "${GET[@]}" ]] || Audit::set::context GET "$(Json::create GET)"
    [[ -z "${POST[@]}" ]] || Audit::set::context POST "$(Json::create POST)"
}

Yoctapi::options(){
    [private] matcher="$1"    

    unset HTTP_METHODS

    for key in "GET" "POST" "PUT" "DELETE"; do
        if ! [[ -z "${YOCTAPI['route':$matcher:'request':${key,,}:'table']}" ]]; then
            HTTP_METHODS+=("$key")
            Yoctapi::options::get
        fi
    done

    Http::send::options
}

Yoctapi::options::get(){
    echo 'Not done yet'
}

Yoctapi::get(){
    [private] matcher="$1"
    [private] search="${uri[2]//;/}"
    [private] display
    [private:assoc] result
    [private:assoc] output
    [private:assoc] query
    [private:array] key1
    [private:array] key2
    [private:array] key3

    query['table']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'table']}"

    if ! [[ -z "$search" ]]; then 
        query['search':'column']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'search']}"
        query['search':'key']="$search"
    fi

    query['filter']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'filter']}"

    display="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'object']}"

    [[ -z "${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'limit']}" ]] || query['limit']="${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'limit']}"

    Data::get "result" "$(Data::build::query::get query $matcher)" "$matcher"

    key1=($(Type::array::get::key "result:" result))
    key2=($(Type::array::get::key "result:${key1[0]}" result))
    key3=($(Type::array::get::key "result:*:*" result))

    for line in "${key1[@]}"; do
        for keys in "${key2[@]}"; do
            if [[ -z "${result[result:$line:$keys]}" ]]; then 
                for keys2 in "${key3[@]}"; do
                    if ! [[ -z "${result[result:$line:$keys:$keys2]}" ]]; then
                        output[$matcher:${result['result':$line:$display]}:$keys:$keys2]="${result[result:$line:$keys:$keys2]}"
                        break
                    fi
                done
            else
                output[$matcher:${result['result':$line:$display]}:$keys]="${result[result:$line:$keys]}"
            fi
        done
    done

    [[ -z "${output[*]}" ]] && Api::send::not_found

    if (( ${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'config':'audit']} )); then
        Yoctapi::audit
        Audit::set::context "Selected" "$(Json::create output)"
        Audit::sent
    fi

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

    if (( ${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'config':'audit']} )); then
        Yoctapi::audit
        Audit::set::context INSERT "$(Json::create output)"
        Audit::sent
    fi

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

    if (( ${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'config':'audit']} )); then
        Yoctapi::audit
        Audot::set::context "Modified" "$(Json::create output)"
        Audit::sent
    fi

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

    if (( ${YOCTAPI['route':$matcher:'request':${REQUEST_METHOD,,}:'config':'audit']} )); then
        Yoctapi::audit
        Audit::set::context "Deleted" "$(Json::create output)"
        Audit::sent
    fi

    Api::send::delete output
}

