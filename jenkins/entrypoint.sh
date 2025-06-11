#!/bin/bash
if [ ! -f /var/jenkins_home/.initialized ]; then
    cp -r /var/jenkins_home_init/* /var/jenkins_home/
    touch /var/jenkins_home/.initialized
fi
exec /usr/local/bin/jenkins.sh "$@"
