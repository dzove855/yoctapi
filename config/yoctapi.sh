[public:assoc] YOCTAPI

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
YOCTAPI['route':'MATCHER':'request':'get':'filter']="id,text"
YOCTAPI['route':'MATCHER':'request':'get':'display']="id"
YOCTAPI['route':'MATCHER':'request':'get':'search']="id"
YOCTAPI['route':'MATCHER':'request':'get':'table']="TABLE"

# POST FILTERS
YOCTAPI['route':'MATCHER':'request':'post':'table']="TABLE"

# PUT FILTERS
YOCTAPI['route':'MATCHER':'request':'put':'search']="id"
YOCTAPI['route':'MATCHER':'request':'put':'table']="TABLE"

# DELETE FILTERS
YOCTAPI['route':'MATCHER':'request':'delete':'search']="id"
YOCTAPI['route':'MATCHER':'request':'delete':'table']="TABLE"
