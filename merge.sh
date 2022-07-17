#!/bin/sh

source ./clean-merged.sh

# src/index.yaml, **/*.yaml -> src/merged.yaml
docker run --rm -v ${PWD}/src:/src -v ${PWD}/dest:/dest jeanberu/swagger-cli swagger-cli bundle -t yaml -r src/index.yaml src/**/*.yaml -o dest/merged.yaml
mv dest/merged.yaml src

# src/merged.yaml           -> src/index.html
docker-compose run --rm redoc-cli build merged.yaml -o index.html

# src/merge.yaml            -> dest/openapi/index.html
docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate -g openapi-yaml -i /local/src/merged.yaml -o /local/dest
# dest/openapi/openapi.yaml -> dest/index.html
docker-compose run --rm redoc-cli build /dest/openapi/openapi.yaml -o /dest/index.html


