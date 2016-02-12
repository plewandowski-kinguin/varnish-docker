FROM        ubuntu:14.04.2
MAINTAINER  Paweł Lewandowski "pawel.lewandowski@kinguin.net"
ENV REFRESHED_AT 2015-10-08

# Update the package repository and install applications
RUN apt-get update -qq && \
  apt-get upgrade -yqq && \
  apt-get -yqq install varnish && \
  apt-get -yqq install telnet && \
  apt-get -yqq install git && \  
  apt-get -yqq install libvarnishapi-dev libgeoip-dev && \
  apt-get -yqq build-dep varnish && \
  apt-get -yqq clean

RUN mkdir ~/src
RUN cd ~/src && apt-get source varnish
RUN cd ~/src/varnish-3.0.5/ && \
  ./autogen.sh && ./configure --prefix=/usr && \
  make && \
  cd ~/src/ && \
  git clone https://github.com/varnish/libvmod-geoip && \
  cd ~/src/libvmod-geoip && \
  git checkout 3.0 && \
  ./autogen.sh && \
  ./configure VARNISHSRC=../varnish-3.0.5/ VMODDIR=/usr/lib/x86_64-linux-gnu/varnish/vmods/ && \
  make && \
  make install


# Make our custom VCLs available on the container
ADD default.vcl /etc/varnish/default.vcl

ENV VARNISH_BACKEND_PORT 80
ENV VARNISH_BACKEND_IP 172.17.42.1
ENV VARNISH_PORT 80

# Expose port 80
EXPOSE 80

# Expose volumes to be able to use data containers
VOLUME ["/var/lib/varnish", "/etc/varnish"]

ADD start.sh /start.sh
CMD ["/start.sh"]
