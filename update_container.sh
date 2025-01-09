#!/bin/bash

lookupDir="/home/jleon/applications/docker/containers/"

usage(){
    echo "Usage: ${0} [container_name]" >&2
}

if [[ "${#}" -lt 1 ]];
then
    usage
    exit 1
fi

for i in "$@"
do

    ## Check that the container's directory exists
    if [[ ! -d "${lookupDir}${i}" ]];
    then
        echo "No container with name: ${i} found in: ${lookupDir}" >&2
        continue
    fi

    # Move to lookup dir, exit if error
    cd ${lookupDir}"${i}" || exit 1
    echo "Checking for latest image for ${i} ..."
    echo ""

    # Lookup the image tag within the docker-compose.yml file
    imageTag=$(grep image: docker-compose.yml | grep "${i}")
    imageTag="${imageTag#*image: }"

    # Remove whitespace from image tag
    imageTag="${imageTag#[[:space:]]}"
    imageTag="${imageTag%[[:space:]]}"

    # Pull the latest image for the image tag on the compose file
    docker pull "${imageTag}"

    # Get the image id of the latest image (the one just pulled)
    # Remove extra characters from latestImageId
    latestImageId=$(docker image inspect "${imageTag}" --format "{{json .Id}}" | tr -d \" | cut -d: -f2 )

    isInUse=$(docker container ls --all --filter=ancestor="${latestImageId}" --format "{{.ID}}")

    # Check if isInUse is empty
    if [[ -z "${isInUse}" ]];
    then
        echo ""
        echo "${i} is not using the latest image, rebuilding..."
        echo ""

        docker compose up -d --build

        echo ""
        echo "${i} has been updated to the latest image."
    fi

    echo ""
    echo "${i} is using the latest image. No update needed at this time."

done    # end for loop

danglingImagesCheck=$(docker image ls | grep "<none>" | awk '{ print $3 }')

if [[ -n "${danglingImagesCheck}" ]];
then
    echo ""
    echo "Removing old images..."
    echo ""

    docker image prune -fa
fi

exit 0