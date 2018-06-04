declare -A DB_GET
declare -A DB_PUT
declare -A DB_DELETE
declare -A DB_POST
declare -A DB_CONNECT

DB_CONNECT['table':'slave_mysql_dbname']="dbname"
DB_CONNECT['table':'slave_mysql_host']="host"
DB_CONNECT['table':'slave_mysql_user']="user"
DB_CONNECT['table':'slave_mysql_port']="3306"
DB_CONNECT['table':'slave_mysql_password']="password"

DB_GET['table':'where']="service"

### Update ###
DB_PUT['table':'where']="id"
DB_DELETE['table':'where']="id"
