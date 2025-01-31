FROM tomcat:9.0.98 as tomcat

RUN mkdir -p /usr/local/tomcat/actone-workdir \
&& mkdir /usr/local/tomcat/actone-workdir/config 

COPY acm.ini /usr/local/tomcat
COPY acm.ini /usr/local/tomcat/actone-workdir/config 
COPY actone.lic /usr/local/tomcat/actone-workdir/config 
COPY required/ACTONE.war /usr/local/tomcat/webapps

CMD ["catalina.sh", "run"]