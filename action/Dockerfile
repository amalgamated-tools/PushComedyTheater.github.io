FROM debian:9.5-slim

LABEL "com.github.actions.name"="Universe Pull"
LABEL "com.github.actions.description"="Pulls from Universe for Pushers"
LABEL "com.github.actions.icon"="mic"
LABEL "com.github.actions.color"="purple"

LABEL "repository"="https://github.com/PushComedyTheater/PushComedyTheater.github.io"
LABEL "homepage"="https://github.com/PushComedyTheater/PushComedyTheater.github.io"
LABEL "maintainer"="Patrick Veverka <patrick@pushcomedytheater.com>"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
