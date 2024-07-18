## Jarvis Continuous Integration
This folder will contain files related to the building and testing of draft releases of Jarvis.

### Updating the Docker container to use a new Dyalog APL version
1. Ensure there's a public Docker container for the Dyalog version.<br>[Check the tags for the dyalog/dyalog container.](https://hub.docker.com/r/dyalog/dyalog/tags)
2. Modify the FROM statement in the Dockerfile file to use the new Dyalog version 
3. Modify the "export DYALOG" and "export WSPATH" statements in the entrypoint file in the Docker folder to use the new Dyalog version