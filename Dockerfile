# Liferay 6.2
#
# VERSION 0.0.9
#

# 0.0.1 : initial file with java 7u60
# 0.0.2 : change base image : java 7u71
# 0.0.3 : chain run commande to reduce image size (from 1.175 GB to 883.5MB), add JAVA_HOME env
# 0.0.4 : change to debian:wheezy in order to reduce image size (883.5MB -> 664.1 MB)
# 0.0.5 : bug with echo on setenv.sh
# 0.0.6 : liferay 6.2-ce-ga3 + java 7u79
# 0.0.7 : liferay 6.2-ce-ga4
# 0.0.8 : liferay 6.2-ce-ga5
# 0.0.9 : liferay 6.2-ce-ga6

FROM debian

MAINTAINER Samuel Nasello <samuel.nasello@elosi.com>

########################################################################
# INSTALAR Y CONFIGURAR JAVA
########################################################################
RUN apt-get update \
	&& apt-get install -y curl tar unzip \
	&& (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz | tar xfz - -C /opt) \
	&& mv /opt/jdk1.7.0_79/jre /opt/jre1.7.0_79 \
	&& mv /opt/jdk1.7.0_79/lib/tools.jar /opt/jre1.7.0_79/lib/ext \
	&& rm -Rf /opt/jdk1.7.0_79 \
	&& ln -s /opt/jre1.7.0_79 /opt/java

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

# add config for bdd
RUN /bin/echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -Dexternal-properties=portal-bd-${DB_TYPE}.properties"' >> /opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/bin/setenv.sh

# add configuration liferay file
ADD lep/portal-bundle.properties /opt/liferay-portal-6.2-ce-ga6/portal-bundle.properties
ADD lep/portal-bd-MYSQL.properties /opt/liferay-portal-6.2-ce-ga6/portal-bd-MYSQL.properties
ADD lep/portal-bd-POSTGRESQL.properties /opt/liferay-portal-6.2-ce-ga6/portal-bd-POSTGRESQL.properties

# volumes
VOLUME ["/var/liferay-home", "/opt/liferay-portal-6.2-ce-ga6/"]

# Ports
EXPOSE 8080

# Set JAVA_HOME
ENV JAVA_HOME /opt/java

# EXEC
CMD ["run"]
ENTRYPOINT ["/opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/bin/catalina.sh"]
