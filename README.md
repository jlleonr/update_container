# Update Container
- Script to update a single Docker container.
- Usage: `./update_container.sh 'container name'`
  - Example: `./update_container.sh grafana`

## Workflow
1. Check that the container's directory exists.
2. Lookup the image tag within the docker-compose.yml file.
3. Pull the latest image.
4. If the container is not using the latest image, it will be rebuilt with the latest image.
5. Purge the old image from the filesystem.

