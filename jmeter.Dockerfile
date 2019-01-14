# JMeter BASE image
# Use Java 8 slim JRE
FROM jenkins/ssh-slave as jmeter-base
LABEL maintainer="cosmap@mediamarktsaturn.com"

# JMeter version
ARG JMETER_VERSION=5.0

# Install utilities
RUN apt-get clean && \
    apt-get update && \
    apt-get -qy install \
                wget \
                telnet \
                iputils-ping \
                unzip   \
    && rm -rf /var/lib/apt/lists/*

# Install JMeter
RUN mkdir /jmeter \
    && cd /jmeter/ \
    && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz \
    && tar -xzf apache-jmeter-$JMETER_VERSION.tgz \
    && rm apache-jmeter-$JMETER_VERSION.tgz \
    && mv apache-jmeter-$JMETER_VERSION apache-jmeter

# Don't use SSL for RMI
#RUN echo server.rmi.ssl.disable=true >> /jmeter/apache-jmeter/bin/jmeter.properties

# ADD all the plugins
ADD jmeter-plugins/lib /jmeter/apache-jmeter/lib

# ADD Dashboard Save Service Configuration to enable generator to operate the CSV files
ADD provision/DashboardSaveServiceConfiguration.properties /jmeter/apache-jmeter/bin/DashboardSaveServiceConfiguration.properties

# Configuring Dashboard Generation
RUN cat /jmeter/apache-jmeter/bin/reportgenerator.properties >> /jmeter/apache-jmeter/bin/user.properties \
    && cat /jmeter/apache-jmeter/bin/DashboardSaveServiceConfiguration.properties >> /jmeter/apache-jmeter/bin/user.properties

# Set JMeter Home
ENV JMETER_HOME /jmeter/apache-jmeter/

# Add JMeter to the Path
ENV PATH $JMETER_HOME/bin:$PATH

# Copy setup-sshd script
COPY --from=jenkinsci/ssh-slave /usr/local/bin/setup-sshd /usr/local/bin/setup-sshd

# JMeter MASTER image
# Use jmeter-base image
FROM jmeter-base as jmeter-master
LABEL maintainer="cosmap@mediamarktsaturn.com"

# Ports to be exposed from the container for JMeter Master
EXPOSE 60000

# Start JMeter
RUN $JMETER_HOME/bin/jmeter \
                        -client.rmi.localport=60000

# Copy setup-sshd script
COPY --from=jmeter-base /usr/local/bin/setup-sshd /usr/local/bin/setup-sshd

# Expose environment variables to ssh session
ENTRYPOINT ["setup-sshd"]

# JMeter SLAVE image
# Use jmeter-base image
# ToDo use a supervisord for slave image to start both, ssh and jmeter
#FROM jmeter-base as jmeter-slave
#LABEL maintainer="cosmap@mediamarktsaturn.com"

# Ports to be exposed from the container for JMeter Slaves/Server
#EXPOSE 1099 50000

# Start Jmeter Server
#RUN $JMETER_HOME/bin/jmeter-server \
#                        -Dserver.rmi.localport=50000 \
#                        -Dserver_port=1099 \
#                        -Jserver.rmi.ssl.disable=true

# Copy setup-sshd script
#COPY --from=jmeter-base /usr/local/bin/setup-sshd /usr/local/bin/setup-sshd

# Expose environment variables to ssh session
#ENTRYPOINT ["setup-sshd"]
