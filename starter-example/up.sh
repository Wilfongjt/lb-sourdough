
source ./_conf.sh
env

# keep stuff from build docker system prune

db_name="${LB_PROJECT_prefix}_db"
#echo "${LB_ENV_data_folder}/${LB_PROJECT_prefix}_db"
echo "${LB_ENV_data_folder}/${db_name}"

cd ${LB_PROJECT_name}/
docker-compose down
docker system prune

docker images
ls

#if [ ! -f 'web/.env' ] ; then
#  echo "  "
#  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#  echo "   You must setup an .env file in ${LB_PROJECT_name}/"
#  echo "       Terminating script."
#  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#  echo "  "
#  exit 1
#fi

#docker-compose down

echo "${LB_ENV_data_folder}/${db_name}"
if [ -d "${LB_ENV_data_folder}/${db_name}" ]; then
  echo "Deleting... ${LB_ENV_data_folder}/${db_name}"
  rm -rv "${LB_ENV_data_folder}/${db_name}"
  echo "... Deleted ${LB_ENV_data_folder}/${db_name}"
else
  echo "Not found ${LB_ENV_data_folder}/${db_name}"
fi

# build everything from scratch...slow but works
echo "Ready to start app"

docker-compose build

docker-compose up


# show the environment variables
# docker-compose exec web env

