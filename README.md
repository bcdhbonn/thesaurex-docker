# What is ThesauRex?
ThesauRex is a leightweight [SKOS](https://www.w3.org/2004/02/skos/) editor developed by the [Digital Humanities Center (formerly eScience-Center)](https://dh-center.uni-tuebingen.de/) at the  University of Tübingen.
The current version can be found at [https://github.com/DH-Center-Tuebingen/ThesauRex](https://github.com/DH-Center-Tuebingen/ThesauRex).
# How to use this repo
## Quick start
Copy the .env and docker-compose.yml into a folder and start the containers with 
```
docker-compose up -d
```
You can now access Thesaurex at [http://localhost:8000](http://localhost:8000).
## Build the Thesaurex image from scratch
You can fetch the current image from the [Docker Hub](https://hub.docker.com/r/bcdhbonn/thesaurex).
If you want to build it for yourself, consider the following:

- Simply comment the production container in the docker-compose.yml and uncomment the dev one.
- The Thesaurex image is built in a builder stage and then served via a php-alpine image.
- During the builder stage the contents of config/php and config/app will be copied into the Thesaurex folder.
    - 2021_07_21_070235_replace_lasteditor.php was changed to include a necessary null check
    - 2022_03_24_090658_restructure_permissions.php needs to be added to include some tables from Spacialist, that are required but missing in the standalone version of Thesaurex
    - helpers.php needs to be amended with the sp_get_permission_groups function, which is required for the previous migration
- During the production stage the config/apache/httpd-vhosts.conf needs to be copied

