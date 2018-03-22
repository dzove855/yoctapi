declare -A DB_GET
declare -A DB_PUT
declare -A DB_DELETE
declare -A DB_POST
declare -A DB_CONNECT

DB_CONNECT['table':'slave_mysql_dbname']=""
DB_CONNECT['table':'slave_mysql_host']=""
DB_CONNECT['table':'slave_mysql_user']=""
DB_CONNECT['table':'slave_mysql_port']=""
DB_CONNECT['table':'slave_mysql_password']=""

DB_GET['table':'where']="id"

### Update ###
DB_PUT['table':'where']="id"
DB_DELETE['table':'where']="id"
