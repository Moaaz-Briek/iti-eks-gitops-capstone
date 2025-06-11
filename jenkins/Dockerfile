FROM jenkins/jenkins:lts

COPY --chown=jenkins:jenkins jenkins-backup/ /var/jenkins_home_init/

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]
