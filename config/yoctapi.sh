[public:assoc] YOCTAPI
[public:array] YOCTAPI_GET_PARAMS
[public:array] YOCTAPI_GET_CONFIG_PARAMS
YOCTAPI_GET_PARAMS=("data:limit" "data:search" "data:object" "data:filter")
YOCTAPI_GET_CONFIG_PARAMS=("config:audit")

# Read Credentials
YOCTAPI['route':'MATCHER':'read':'credentials':'host']="localhost"
YOCTAPI['route':'MATCHER':'read':'credentials':'user']="USER"
YOCTAPI['route':'MATCHER':'read':'credentials':'password']="PASSWORD"
YOCTAPI['route':'MATCHER':'read':'credentials':'database']="DATABASE"
YOCTAPI['route':'MATCHER':'read':'connector']="mysql"

# Write Credentials
YOCTAPI['route':'MATCHER':'write':'credentials':'host']="localhost"
YOCTAPI['route':'MATCHER':'write':'credentials':'user']="USER"
YOCTAPI['route':'MATCHER':'write':'credentials':'password']="PASSWORD"
YOCTAPI['route':'MATCHER':'write':'credentials':'database']="DATABASE"
YOCTAPI['route':'MATCHER':'write':'connector']="mysql"

# GET FILTERS
YOCTAPI['route':'MATCHER':'request':'get':'filter']="FILTER1,FILTER2"
YOCTAPI['route':'MATCHER':'request':'get':'object']="OBJECT"
YOCTAPI['route':'MATCHER':'request':'get':'search']="SEARCH"
YOCTAPI['route':'MATCHER':'request':'get':'table']="TABLE"
YOCTAPI['route':'MATCHER':'request':'get':'limit']="LIMIT"
YOCTAPI['route':'MATCHER':'request':'get':'config':'audit']="0=false 1=true"

# POST FILTERS
YOCTAPI['route':'MATCHER':'request':'post':'table']="TABLE"
YOCTAPI['route':'MATCHER':'request':'post':'config':'audit']="0=false 1=true"

# PUT FILTERS
YOCTAPI['route':'MATCHER':'request':'put':'search']="SEARCH"
YOCTAPI['route':'MATCHER':'request':'put':'table']="TABLE"
YOCTAPI['route':'MATCHER':'request':'put':'config':'audit']="0=false 1=true"

# DELETE FILTERS
YOCTAPI['route':'MATCHER':'request':'delete':'search']="SEARCH"
YOCTAPI['route':'MATCHER':'request':'delete':'table']="TABLE"
YOCTAPI['route':'MATCHER':'request':'delete':'config':'audit']="0=false 1=true"

