#
# Title: Dockerfile for Nagios XI
#
# Maintainer: Yongbok Kim (ruo91@yongbok.net)
#
# - Build
# docker build --rm -t nagios:xi .
#
# - Run
# docker run -d --name="nagiosxi" -h "nagiosxi" -p 80:80 -p 443:443 -p 5666:5666 -p 5667:5667 nagios:xi

# Base images
FROM     centos:centos10
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# WorkDIR
ENV SRC_DIR /opt
WORKDIR $SRC_DIR

# Nagios XI
RUN curl -LO "http://assets.nagios.com/downloads/nagiosxi/xi-latest.tar.gz" \
 && tar xzvf xi-latest.tar.gz

# Disable firewall
RUN cd nagiosxi \
&& touch installed.firewall

# Disable kernel parameter

#RUN cp -f mods/cfg/ndomod.cfg /usr/local/nagios/etc


# Build
#RUN cd nagiosxi \
 #&& ./fullinstall -n
RUN cd $SRC_DIR/nagiosxi/ && ./fullinstall -n
# Supervisor
RUN yum install -y python-setuptools python-meld3 \
 && easy_install pip \
 && pip install --upgrade pip \
 && pip install supervisor \
 && mkdir /etc/supervisord.d
ADD conf/supervisord.conf /etc/supervisord.d/supervisord.conf

# Ports
EXPOSE 80 443 5666 5667

# Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.d/supervisord.conf"]

VOLUME  "/usr/local/nagios/etc" 

COPY update_hosts.sh /usr/local/bin/
COPY update_ssh.sh /usr/local/bin/
# set startup script
ADD start.sh /start.sh
RUN chmod 755 /start.sh
RUN echo "Europe/Paris" > /etc/timezone
RUN echo "alias ssh='ssh -o StrictHostKeyChecking=accept-new'" >> /etc/bash.bashrc
RUN usermod --shell /bin/bash nagios
EXPOSE 80 5666 5667


CMD ["/start.sh"]











