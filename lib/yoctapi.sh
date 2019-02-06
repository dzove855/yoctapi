[public:assoc] YOCTAPI
YOCTAPI['config':'get':'action']="read"
YOCTAPI['config':'post':'action']="write"
YOCTAPI['config':'put':'action']="write"
YOCTAPI['config':'delete':'action']="write"

Yoctapi::api::main(){
    [private:assoc] result
    [private] table="${uri[1]}"

    [[ -z "${YOCTAPI['route':$table:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']}" ]] && { Api::send::not_found; }

    # Build creadentials
    Yoctapi::build::credentials 

    DATA['matcher':$table]="${YOCTAPI['route':$table:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']}"
    
    # Run Request
    Yoctapi::${REQUEST_METHOD,,} "$table"
}

Yoctapi::build::credentials(){
    [public:map] array="${YOCTAPI['route':$table:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:'connector']^^}"
 
    while read line; do
        array[connection:$line]="${YOCTAPI[route:$table:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:credentials:$line]}"
    done < <(Type::array::get::key route:$table:${YOCTAPI['config':${REQUEST_METHOD,,}:'action']}:credentials YOCTAPI)

    return 
}

Yoctapi::get(){
    [private] table="$1"
    [private] search="${uri[2]//;/}"
    [private] display
    [private:assoc] result
    [private:assoc] output
    [private:assoc] query

    query['table']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'table']}"

    if ! [[ -z "$search" ]]; then 
        if [[ -z "${GET['data':'search']}" ]]; then
            query['search':'column']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'search']}"
            query['search':'key']="$search"
        else
            query['search':'column']="${GET['data':'search']}"
            query['search':'key']="$search"
        fi
    fi

    if [[ -z "${GET['data':'filter']}" ]]; then
        query['filter']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'filter']}"
    else
        query['filter']="${GET['data':'filter']}"
    fi

    if [[ -z "${GET['data':'object']}" ]]; then
        display="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'object']}"
    else
        display="${GET['data':'object']}"
    fi

    [[ -z "${GET['data':'limit']}" ]] || query['limit']="${GET['data':'limit']}"

    Data::get "result" "$(Data::build::query::get query $table)" "$table"

    while read line; do
        while read keys; do
            output[$table:${result['result':$line:$display]}:$keys]="${result[result:$line:$keys]}"
        done < <(Type::array::get::key result:$line result)
    done < <(Type::array::get::key result result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::get output
}

Yoctapi::post(){
    [private] table="$1"
    [private:assoc] query
    [private:assoc] result
    [private:assoc] output

    query['table']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'table']}"

    [[ -z "${POST[*]}" ]] && Api::send::fail

    Type::array::fusion POST query

    Data::post 'result' "$(Data::build::query::post query $table)" "$table"
   
    while read line; do
        output[$table:$line]="${result['result':'1':$line]}"
    done < <(Type::array::get::key result:1 result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::post output
}

Yoctapi::put(){
    [private] table="$1"
    [private] search="${uri[2]}"
    [private:assoc] query
    [private:assoc] result
    [private:assoc] output

    query['table']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'table']}"

    [[ -z "${POST[*]}" ]] && Api::send::fail
    [[ -z "${search}" ]] && Api::send::not_found

    Type::array::fusion POST query

    if ! [[ -z "$search" ]]; then
        if [[ -z "${GET['data':'search']}" ]]; then
            query['search':'column']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'search']}"
            query['search':'key']="$search"
        else
            query['search':'column']="${GET['data':'search']}"
            query['search':'key']="$search"
        fi
    fi

    Data::put 'result' "$(Data::build::query::put query $table)" "$table"

    while read line; do
        output[$table:$line]="${result['result':'1':$line]}"
    done < <(Type::array::get::key result:1 result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::put output
}

Yoctapi::delete(){
    [private] table="$1"
    [private] search="${uri[2]}"
    [private:assoc] query
    [private:assoc] result
    [private:assoc] output

    query['table']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'table']}"

    [[ -z "${search}" ]] && Api::send::not_found

    if ! [[ -z "$search" ]]; then
        if [[ -z "${GET['data':'search']}" ]]; then
            query['search':'column']="${YOCTAPI['route':$table:'request':${REQUEST_METHOD,,}:'search']}"
            query['search':'key']="$search"
        else
            query['search':'column']="${GET['data':'search']}"
            query['search':'key']="$search"
        fi
    fi

    Data::delete 'result' "$(Data::build::query::delete query $table)" "$table"

    while read line; do
        output[$table:$line]="${result['result':'1':$line]}"
    done < <(Type::array::get::key result:1 result)

    [[ -z "${output[*]}" ]] && Api::send::not_found

    Api::send::delete output
}

