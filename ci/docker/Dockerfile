#FROM ubuntu:14.04
FROM openjdk:8-jdk

MAINTAINER Morgan Stake, morgan.stake@cgi.com
#
RUN apt-get update
RUN apt-get install -y software-properties-common
# # Install Java.
# RUN \
#   echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
#   add-apt-repository -y ppa:webupd8team/java && \
#   apt-get update && \
#   apt-get install -y oracle-java8-installer && \
#   rm -rf /var/lib/apt/lists/* && \
#   rm -rf /var/cache/oracle-jdk8-installer
#
# # Define commonly used JAVA_HOME variable
# ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Maven
ARG MAVEN_VERSION=3.5.2
ARG USER_HOME_DIR="/root"
ARG SHA=707b1f6e390a65bde4af4cdaf2a24d45fc19a6ded00fff02e91626e3e42ceaff
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update && apt-get install -y curl \
  && mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Install node
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get install -y nodejs

# Install phantomjs
RUN apt-get install -y build-essential chrpath libssl-dev libxft-dev libfreetype6-dev libfreetype6 libfontconfig1-dev libfontconfig1
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
RUN ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update 
RUN apt-get install yarn

# Install cf cli
RUN wget "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" -O cf.tgz
RUN tar -xvzf cf.tgz
RUN mv cf /usr/local/bin
RUN rm cf.tgz

# Install jq cli
RUN apt-get install jq -y

# Install aws cli
RUN apt-get install awscli -y

# install CAST Highlight Agent
ENV CAST_HOME /usr/local/cast
ENV CAST_WORK ${CAST_HOME}/work
ENV CAST_AGENT_JAR ${CAST_HOME}/Highlight-Automation-Command/HighlightAutomation.jar
ENV CAST_AGENT_PERL ${CAST_HOME}/Highlight-Automation-Command/perl

RUN mkdir $CAST_HOME
RUN mkdir $CAST_HOME/working
RUN curl -X GET https://casthighlight.com/tools/cli/Highlight-Automation-Command.tar.gz > $CAST_HOME/Highlight-Automation-Command.tar.gz
RUN cd $CAST_HOME/ && tar -zxvf $CAST_HOME/Highlight-Automation-Command.tar.gz
RUN cpan JSON
RUN cpan XML::Twig

#
## Install jmeter for load test
#ENV JMETER_HOME    /opt/jmeter
#ENV JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-3.2.tgz

#RUN apt-get update && apt-get install -y --no-install-recommends \
#     libxml-xpath-perl bash curl tar git ca-certificates unzip

#RUN mkdir -p ${JMETER_HOME}
#RUN curl -L --silent ${JMETER_DOWNLOAD_URL}
#RUN wget -O apache-jmeter-3.2.tgz ${JMETER_DOWNLOAD_URL}
#RUN tar xvzf apache-jmeter-3.2.tgz --strip=1 -C ${JMETER_HOME}
#RUN wget -O jmeter-plugins-standard.zip http://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.2.1.zip
#RUN ls -ltr
#RUN curl -L --silent http://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.2.1.zip -o /tmp/jmeter-plugins-standard.zip 
#RUN unzip -o -d /opt/jmeter/ jmeter-plugins-standard.zip
#RUN rm jmeter-plugins-standard.zip

#ADD ./lib/jmeter-plugins-senseuploader-2.4.jar /opt/jmeter/lib/ext/jmeter-plugins-senseuploader-2.4.jar
#ENV PATH "${JMETER_HOME}/bin:${PATH}"