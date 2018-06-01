# logger

function logger::log ()
{
    case "$_level" in
        crit)   loggerlevel="panic"     ;;
    esac

    logger-client.sh -U $loggerurl -l ${loggerlevel:-$_level} -o http -b "$REQUEST_URI" -m "ESM : $_level : ${REQUEST_URI%\?*}" -C "msg=$_message" &>/dev/null
}
