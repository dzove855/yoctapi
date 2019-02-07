
audit::log(){
    local _msg="$1" _opts

    for key in "${AUDIT_CONTEXT[@]}"; do
        _opts+=("-C $key='${AUDIT_CONTEXT[$key]}'")
    done
    audit-client.sh -2 -U "${AUDIT['url']}" -l info -e "$(hostname -d)" -n "$application_name" -o "http" -b "${REQUEST_URI%%\?*}" \
        -c technical -m "$_msg" -C "Content-Type=${CONTENT_TYPE:-text/plain}" -s
}
