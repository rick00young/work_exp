    # sshd
    #
    # VERSION               0.0.1

    FROM     ubuntu:14.04
    MAINTAINER Thatcher R. Peskens "thatcher@dotcloud.com"

    # make sure the package repository is up to date
    RUN apt-get update

    RUN apt-get install -y openssh-server
    RUN mkdir /var/run/sshd
    RUN echo 'root:root' |chpasswd

    EXPOSE 22
    CMD    ["/usr/sbin/sshd", "-D"]
