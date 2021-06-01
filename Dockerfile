# Liferay 6.2
#

FROM debian:stable

MAINTAINER Kevin Jiménez <kjimenez@infosgroup.cr>

########################################################################
# INSTALAR Y CONFIGURAR JAVA
########################################################################
RUN apt-get update
RUN apt-get install -y curl tar unzip 
#RUN apt-get install -y curl tar nano 
RUN apt-get install -y curl tar wget 
RUN apt-get install -y curl tar mailutils


RUN wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz


RUN tar xzf jdk-8u131-linux-x64.tar.gz -C /opt
RUN mv /opt/jdk1.8.0_131/jre /opt/jre1.8.0_131 
RUN mv /opt/jdk1.8.0_131/lib/tools.jar /opt/jre1.8.0_131/lib/ext 
RUN rm -Rf /opt/jdk1.8.0_131 
RUN ln -s /opt/jre1.8.0_131 /opt/java

# Set JAVA_HOME
ENV JAVA_HOME /opt/java


########################################################################
# FIN JAVA
########################################################################


########################################################################
# INSTALAR Y CONFIGURAR LIFERAY
########################################################################
RUN curl -O -s -k -L -C - http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.2.5%20GA6/liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip \
	&& unzip liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip -d /opt \
	&& rm liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip


###################################
# Add configuration liferay file
###################################

# add config for bdd
RUN /bin/echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -Dexternal-properties=portal-bd-MYSQL.properties"' >> /opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/bin/setenv.sh

###################################
# ADD LIFERAY CONFIGS
###################################
COPY lep/Configs/portal-ext.properties /opt/liferay-portal-6.2-ce-ga6/
COPY lep/Configs/portal-bundle.properties /opt/liferay-portal-6.2-ce-ga6/
COPY lep/Configs/portal-bd-MYSQL.properties /opt/liferay-portal-6.2-ce-ga6/
COPY lep/Configs/logging.properties /opt/liferay-portal-6.2-ce-ga6/tomcat-9.0.17/conf/logging.properties

###################################
# ADD HEALTH CHECKS
###################################

COPY lep/Checks/. /usr/local/sbin/

###################################
# ADD CRONTAB FOR CHECKS
###################################

*/10 * * * * root /usr/local/sbin/check_liferay /opt/liferay-ce-portal-7.2.0-ga1/tomcat-9.0.17/ root  liferay-portal /opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/logs/catalina.out no-responder@infosgroup.cr kjimenez@infosgroup.cr  300 >> /etc/crontab
*/1440 * * * * root /usr/local/sbin/check_disk_usage no-responder@infosgroup.cr kjimenez@infosgroup.cr 90 >> /etc/crontab

###################################
# RELOAD CRONTAB
###################################
RUN service cron reload

###################################
# ADD TOMCAT CONFIGS
###################################
COPY lep/Configs/setenv.sh /opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/bin/setenv.sh
COPY lep/Configs/context.xml /opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/config/context.xml


###################################
# Porlet Installation
###################################
COPY lep/Portlets/. /var/liferay-home/deploy/


###################################
# ADD DATABASES CONNECTOR(JARS)
###################################
COPY lep/Misc/Connectors/. /opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/lib/ext/

# volumes
VOLUME ["/var/liferay-home", "/opt/liferay-portal-6.2-ce-ga6/"]

# Ports
EXPOSE 8080

# EXEC
CMD ["run"]
ENTRYPOINT ["/opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/bin/catalina.sh"]
