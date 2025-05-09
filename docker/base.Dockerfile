#FROM ubuntu:20.04
ARG IMAGE
FROM $IMAGE 
ARG DEBIAN_FRONTEND=noninteractive
ARG MUID
ARG MGID
ARG MUSER
ENV TZ=Etc/UTC
# https://stackoverflow.com/questions/25899912/how-to-install-nvm-in-docker
# Replace shell with bash so we can source files
# RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Set user and group 
RUN echo  $MU $MG $MUSER

RUN groupadd -g $MGID $MUSER

# same uid with host user
RUN useradd -u $MUID -g $MGID -m -s /bin/bash $MUSER
RUN passwd -d $MUSER
RUN usermod -a -G sudo $MUSER

COPY --from=shell * /shell/

# Install 
RUN /shell/install-package.sh

