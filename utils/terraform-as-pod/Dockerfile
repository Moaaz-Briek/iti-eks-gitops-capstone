FROM hashicorp/terraform:latest

RUN apk add --no-cache git bash

COPY pipeline.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]