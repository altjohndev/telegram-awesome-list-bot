FROM elixir:1.10.4-alpine AS release

ENV MIX_ENV=prod

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

RUN apk add --update git build-base nodejs yarn python

RUN mix archive.install hex --force phx_new 1.5.4

ARG SECRET_KEY_BASE

COPY . .

RUN mix deps.get && \
    mix deps.compile

RUN cd assets && \
    yarn install && \
    yarn run deploy

RUN mix phx.digest && \
    mix compile && \
    mix release talbot

FROM erlang:22.3.4-alpine

COPY --from=release /app/_build/prod/rel/talbot /app

CMD ["/app/bin/talbot", "start"]
