FROM ruby:3.3.0-alpine3.19

ENV REVIEWDOG_VERSION v0.10.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --update --no-cache build-base git
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ $REVIEWDOG_VERSION

COPY entrypoint.sh /entrypoint.sh
RUN mkdir -p /config
COPY .rubocop.yml /config/.rubocop.yml

ENTRYPOINT ["/entrypoint.sh"]
