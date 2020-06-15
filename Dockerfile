# Use latest jboss/base-jdk:11 image as the base
FROM jboss/base-jdk:11

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 19.1.0.Final
ENV WILDFLY_SHA1 6883125745a62b598659ea351f5b1706aff53955
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080
EXPOSE 9990

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
RUN /opt/jboss/wildfly/bin/add-user.sh -m -u hnu -p hnu -g admin,developer --silent
# CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement","0.0.0.0"]
