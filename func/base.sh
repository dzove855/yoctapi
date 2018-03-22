searchFunction ()
{
    local uri_parsed 

    IFS='/' read api table action <<<$uri

    http::send::content-type application/json

    dbconnector "$table" "$action" "$REQUEST_METHOD"
}

