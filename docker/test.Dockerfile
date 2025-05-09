FROM base
ARG DEBIAN_FRONTEND=noninteractive
ARG MUID
ARG MGID
ARG MUSER
ENV TZ=Etc/UTC


# Switch to user
USER $MUSER
# Install 
RUN /shell/install-rust.sh