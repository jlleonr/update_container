#!/bin/bash

lookupDir="/home/jleon/applications/docker/containers/"

usage(){
    echo "Usage: ${0} container_name" >&2
}

if [[ "${#}" -lt 1 ]];
then
    usage
    exit 1
fi

## Check that the container's directory exists
if [[ ! -d "${lookupDir}${1}" ]];
then
    echo "No container with name: ${1} found in: ${lookupDir}" >&2
    exit 1
fi

# Move to lookup directory, exit if error
cd ${lookupDir}"${1}" || exit 1
echo "Checking for latest image for ${1} ..."
echo ""

# Lookup the image tag within the docker-compose.yml file
imageTag=$(grep image: docker-compose.yml | grep "${1}")
imageTag="${imageTag#*image: }"

# Remove whitespace from image tag
imageTag="${imageTag#[[:space:]]}"
imageTag="${imageTag%[[:space:]]}"

# Pull the latest image
docker pull "${imageTag}"

# Get the image id of the latest image (the one just pulled)
# Remove extra characters from latestImageId
latestImageId=$(docker image inspect "${imageTag}" --format "{{json .Id}}" | tr -d \" | cut -d: -f2 )

isInUse=$(docker container ls --all --filter=ancestor="${latestImageId}" --format "{{.ID}}")

# Check if isInUse is empty
if [[ -z "${isInUse}" ]];
then
    echo ""
    echo "${1} is not using the latest image, rebuilding..."
    echo ""

    docker compose up -d --build

    echo ""
    echo "Removing old image..."
    echo ""

    docker image prune -fa

    echo ""
    echo "${1} has been updated to the latest image."
    exit 0
fi

echo ""
echo "${1} is using the latest image. Not update needed at this time."
exit 0
