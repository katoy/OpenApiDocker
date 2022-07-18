#!/bin/sh

source ./clean-merged.sh

# src/index.yaml, **/*.yaml -> dest/merged.yaml
docker run --rm -v ${PWD}/src:/src -v ${PWD}/dest:/dest jeanberu/swagger-cli swagger-cli bundle -t yaml -r src/index.yaml src/**/*.yaml -o dest/merged.yaml

# dest/merge.yaml            -> dest/openapi/index.html
sleep 3
docker run --rm -v ${PWD}/dest:/dest openapitools/openapi-generator-cli generate -g openapi-yaml -i /dest/merged.yaml -o /dest

# dest/openapi/openapi.yaml -> dest/index.html
docker-compose run --rm redoc-cli build /dest/openapi/openapi.yaml -o /dest/index.html

# src/merged.yaml           -> src/index.html
# docker-compose run --rm redoc-cli build merged.yaml -o index.html

# dest/merged.yaml           -> src/index.html
# docker-compose run --rm redoc-cli build merged.yaml -o index.html

# dest/merged.yaml  -> dest/schemas.plantuml (スキーマの図示) // 出力結果の 先頭上を編集する必要がある。
docker run --rm -v ${PWD}/dest:/dest openapitools/openapi-generator-cli generate -g plantuml -i /dest/merged.yaml -o /dest

# dest/merged.yaml  -> dev/index.pdf
docker run --rm -v ${PWD}/dest:/dest openapitools/openapi-generator-cli generate -g asciidoc -i /dest/merged.yaml -o dest
asciidoctor-pdf -a scripts=cjk -a pdf-theme=default-with-fallback-font dest/index.adoc -o dest/index.pdf

### dest/merged.yaml  -> rails
###   ほとんど使いものにはならない
### docker run --rm -v ${PWD}/dest:/dest openapitools/openapi-generator-cli generate -g ruby-on-rails -i dest/merged.yaml -o dest/rails
