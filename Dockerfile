FROM bitnami/minideb:stretch
LABEL maintainer "Tom Xiong <tom.xiong@quest.com>"

# copy from bitnami/minideb-extra Dockerfile and change user bitnami to fms
RUN install_packages curl ca-certificates sudo locales procps libaio1 gnupg dirmngr bzip2 && \
  update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
  locale-gen en_US.UTF-8 && \
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# The following security actions are recommended by some security scans.
# https://console.bluemix.net/docs/services/va/va_index.html
RUN  sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS    90/' /etc/login.defs && \
  sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS    1/' /etc/login.defs && \
  sed -i 's/sha512/sha512 minlen=8/' /etc/pam.d/common-password

ENV TINI_VERSION v0.18.0
ENV TINI_GPG_KEY 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7

RUN cd /tmp && \    
  curl -sSL https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc -o tini.asc && \
  curl -sSL https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini -o /usr/local/bin/tini && \
  gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && \
  gpg --verify tini.asc /usr/local/bin/tini && \
  chmod +x /usr/local/bin/tini && \
  rm tini.asc

ENTRYPOINT ["tini", "--"]