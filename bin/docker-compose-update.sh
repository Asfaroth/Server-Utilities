#!/bin/bash

docker compose pull
docker compose up --force-recreate --build -d

# ATTENTION: Comment out the following line if you do not wish to automatically clean up your images
docker image prune -f
