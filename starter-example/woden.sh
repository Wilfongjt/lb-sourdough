
# fireup Docker-compose
###############
# Curl a woden
###############
export WODEN=\
$(curl http://localhost:3100/rpc/woden -X GET \
     -H "Content-Type: application/json")
###############
#Set WODEN environment variable:
###############
# extract the woden value
export WODEN=$(echo $WODEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
# cleanup: remove starting and ending double quotes
export WODEN=$(echo $WODEN | sed 's/"//g' )
echo "Woden is $WODEN"
###############
# add an application to db
###############
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app", "name": "request@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'

###############
# Set Application Token
###############
export APPTOKEN=\
$(curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $APPTOKEN"   \
     -H "Content-Type: application/json" \
     -d '{"id": "request@1.0.0"}')
     # extract the woden value
     export APPTOKEN=$(echo $APPTOKEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
     # cleanup: remove starting and ending double quotes
     export APPTOKEN=$(echo $APPTOKEN | sed 's/"//g' )
echo "AppToken is $APPTOKEN"


##############
# Register an Application User
##############
curl http://localhost:3100/rpc/actor -X POST \
     -H "Authorization: Bearer $APPTOKEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "actor", "app_name": "request@1.0.0", "name": "me@someplace.com", "password": "a1A!aaaa"}'

##
##
##
