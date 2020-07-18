
# fireup Docker-compose
###############
# Configure a woden
###############
export WODEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiYXBwX2d1ZXN0IiwidHlwZSI6Im93bmVyIn0.W9ozQBzeP0veEMX4x8Mue8r4437_yOj0LNLixNkGZJw

#export WODEN=\
#$(curl http://localhost:3100/rpc/woden -X GET \
#     -H "Content-Type: application/json")
###############
#Set WODEN environment variable:
###############
# extract the woden value
#export WODEN=$(echo $WODEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
# cleanup: remove starting and ending double quotes
#export WODEN=$(echo $WODEN | sed 's/"//g' )
echo "Woden is $WODEN"
###############
# add owner aka user
###############
curl http://localhost:3100/rpc/owner -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type":"owner", "email":"me@someplace.com", "name":"me@someplace.com", "password":"a1A!aaaa"}'

###############
# add an application to db
###############
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app", "id":"woden@1.0.0", "name":"request", "owner_id":"me@someplace.com"}'

###############
# Set Application Token
###############
#export APPTOKEN=\
#$(curl http://localhost:3100/rpc/app -X POST \
#     -H "Authorization: Bearer $APPTOKEN"   \
#     -H "Content-Type: application/json" \
#     -d '{"id": "request@1.0.0"}')
#     # extract the woden value
#     export APPTOKEN=$(echo $APPTOKEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
#     # cleanup: remove starting and ending double quotes
#     export APPTOKEN=$(echo $APPTOKEN | sed 's/"//g' )
#echo "AppToken is $APPTOKEN"


##############
# Register an Application User
##############
#curl http://localhost:3100/rpc/actor -X POST \
#     -H "Authorization: Bearer $APPTOKEN"   \
#     -H "Content-Type: application/json" \
#     -H "Prefer: params=single-object"\
#     -d '{"type": "actor", "app_id": "request@1.0.0", "name": "me@someplace.com", "password": "a1A!aaaa"}'

##
##
##
