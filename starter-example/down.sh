
source ./_conf.sh


# keep stuff from build docker system prune

echo "${LB_ENV_data_folder}/${LB_PROJECT_prefix}_db"
cd ${LB_PROJECT_name}/

docker-compose down --volumes


