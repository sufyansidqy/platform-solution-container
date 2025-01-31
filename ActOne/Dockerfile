FROM tomcat:9.0.98 as tomcat

RUN mkdir -p /usr/local/tomcat/actone-workdir/config 

RUN apt-get update && apt-get install -y \
unzip \
telnet \
vim \
rsync 

COPY required/acm.ini /usr/local/tomcat
COPY required/actone.lic /usr/local/tomcat

COPY required/acm.ini /usr/local/tomcat/actone-workdir/config 
COPY required/actone.lic /usr/local/tomcat/actone-workdir/config 

COPY required/ACTONE.war /usr/local/tomcat/webapps

#CMD ["catalina.sh", "run"]
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
