#
# Scala, sbt and Selenium (with Firefox & geckodriver) Dockerfile
#
# https://github.com/pending...
#

# Pull base image
FROM hseeberger/scala-sbt

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV FIREFOX_VERSION 48.0.1
# We need to use this version (v0.10.0 will throw error: Found argument '--webdriver-port' which wasn't expected, or isn't valid in this context)
ENV GECKODRIVER_VERSION 0.9.0 

#==============
# VNC and Xvfb (Virtual Frame Buffer to run test headlessly)
#==============
RUN apt-get update -qqy \
  && apt-get -qqy install xvfb \
  && rm -rf /var/lib/apt/lists/*

#==============
# Firefox
#==============
RUN apt-get update -qqy \
  && rm -rf /var/lib/apt/lists/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

#==============
# GeckoDriver
#==============
RUN wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VERSION/geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz \
  && rm -rf /opt/geckodriver \
  && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
  && rm /tmp/geckodriver.tar.gz \
  && mv /opt/geckodriver /opt/geckodriver-$GECKODRIVER_VERSION \
  && chmod 755 /opt/geckodriver-$GECKODRIVER_VERSION \
  && ln -fs /opt/geckodriver-$GECKODRIVER_VERSION /usr/local/bin/geckodriver \
  && ln -fs /opt/geckodriver-$GECKODRIVER_VERSION /usr/local/bin/wires

#============================
# GTK3 (required by Firefox 46+)
#============================
RUN apt-get update -qqy \
    && apt-get install -qqy libgtk-3-0

# Define working directory
WORKDIR /root

#==============================
# Scripts to run Selenium Node
#==============================
COPY before_tests.sh /root
RUN chmod +x /root/before_tests.sh

