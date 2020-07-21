
# fireup Docker-compose
###############
# Configure a woden
# make your own woden at https://jwt.io
# at a minimum include the claim {"role": "app_guest"}
# you can reverse engineer the WODEN token below to gain some understanding
###############
#curl http://localhost:3100/rpc/woden -X GET \
#     -H "Content-Type: application/json"
#echo ""
#export WODEN=$(curl http://localhost:3100/rpc/woden -X GET \
#     -H "Content-Type: application/json")
#export WODEN=$(echo $WODEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
#echo "woden is $WODEN"
echo ""
# good woden
export WODEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiYXBwX2d1ZXN0IiwidHlwZSI6Im93bmVyIn0.W9ozQBzeP0veEMX4x8Mue8r4437_yOj0LNLixNkGZJw
# bad woden
#export WODEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYmFkX3JvbGUiLCJ0eXBlIjoiYmFkX3R5cGUifQ.Hhs_kC0xypud3AhjGIlLO35xEVAtl4_QwP02gR25lPE"

echo "Woden is $WODEN"
###############
#Set WODEN environment variable:
###############
# extract the woden value
#export WODEN=$(echo $WODEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
# cleanup: remove starting and ending double quotes
#export WODEN=$(echo $WODEN | sed 's/"//g' )
#echo "Woden is $WODEN"
###############
# add owner aka user
###############
curl http://localhost:3100/rpc/owner -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type":"owner", "email":"me@someplace.com", "name":"me@someplace.com", "password":"a1A!aaaa"}'
echo "---"
################
# Signin and get owner-token
################
#curl http://localhost:3100/rpc/signin -X POST \
#    -H "Authorization: Bearer $WODEN"   \
#    -H "Content-Type: application/json" \
#    -H "Prefer: params=single-object"\
#    -d '{"name":"me@someplace.com", "password":"a1A!aaaa"}'
echo "---"
export AUTHORIZED_USER=$(curl http://localhost:3100/rpc/signin -X POST \
        -H "Authorization: Bearer $WODEN"   \
        -H "Content-Type: application/json" \
        -H "Prefer: params=single-object" \
        -d '{"name":"me@someplace.com", "password":"a1A!aaaa"}')

echo "AUTHORIZED_USER is $AUTHORIZED_USER"

export AUTHORIZED_USER=$(echo $AUTHORIZED_USER | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')

echo "---"
echo "AUTHORIZED_USER is $AUTHORIZED_USER"

###############
# add an application to db
###############
#curl http://localhost:3100/rpc/app -X POST \
#     -H "Authorization: Bearer $WODEN"   \
#     -H "Content-Type: application/json" \
#     -H "Prefer: params=single-object"\
#     -d '{"type": "app", "id":"woden@1.0.0", "name":"request", "owner_id":"me@someplace.com"}'

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
