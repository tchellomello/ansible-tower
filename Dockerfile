# Ansible Tower Dockerfie
FROM ubuntu:trusty

LABEL maintainer mittell@gmail.com, reuben.stump@gmail.com, ybaltouski@gmail.com 

WORKDIR /opt

ENV ANSIBLE_TOWER_VER 3.2.5
ENV PG_DATA /var/lib/postgresql/9.6/main
ENV AWX_PROJECTS /var/lib/awx/projects

RUN apt-get update \
    && apt-get upgrade -y  \
    && apt-get install -y locales \
    && apt-get install -y software-properties-common apt-transport-https ca-certificates

# Set locale
RUN locale-gen "en_US.UTF-8" \
	&& export LC_ALL="en_US.UTF-8" \
	&& dpkg-reconfigure locales

# Use python >= 2.7.9
RUN apt-add-repository -y ppa:fkrull/deadsnakes-python2.7 \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv 5BB92C09DB82666C
	
# Install libpython2.7; missing dependency in Tower setup
RUN apt-get install -y libpython2.7

# create /var/log/tower
RUN mkdir -p /var/log/tower

# Download & extract Tower tarball
ADD http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
RUN tar xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz \
    && rm -f ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz

WORKDIR /opt/ansible-tower-setup-${ANSIBLE_TOWER_VER}
ADD inventory inventory

# Tower setup
RUN ./setup.sh

# Docker entrypoint script
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# volumes and ports
VOLUME ["${PG_DATA}", "${AWX_PROJECTS}", "/certs",]
EXPOSE 443

CMD ["/docker-entrypoint.sh", "ansible-tower"]
