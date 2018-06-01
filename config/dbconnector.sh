declare -A DB_GET
declare -A DB_PUT
declare -A DB_DELETE
declare -A DB_POST
declare -A DB_CONNECT

DB_CONNECT['config':'slave_mysql_dbname']="yoconf"
DB_CONNECT['config':'slave_mysql_host']="localhost"
DB_CONNECT['config':'slave_mysql_user']="root"
DB_CONNECT['config':'slave_mysql_port']="3306"
DB_CONNECT['config':'slave_mysql_password']="trakto"

DB_GET['config':'where']="service"

### Update ###
DB_PUT['config':'where']="id"
DB_DELETE['config':'where']="id"
