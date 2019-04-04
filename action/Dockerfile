from debian:stretch-slim

LABEL "com.github.actions.name"="Universe Pull"
LABEL "com.github.actions.description"="Pulls from Universe for Pushers"
LABEL "com.github.actions.icon"="thumbs-up"
LABEL "com.github.actions.color"="purple"

LABEL "repository"="https://github.com/PushComedyTheater/PushComedyTheater.github.io"
LABEL "homepage"="https://github.com/PushComedyTheater/PushComedyTheater.github.io"
LABEL "maintainer"="Patrick Veverka <patrick@pushcomedytheater.com>"

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get update && apt-get install -y wget git

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
