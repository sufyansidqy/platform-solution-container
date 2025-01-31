FROM tomcat:9.0.98 as tomcat

RUN mkdir -p /actone-workdir \
&& cd /actone-workdir \
&& mkdir config

COPY acm.ini /usr/local/tomcat
COPY acm.ini /actone-workdir/config
COPY actone.lic /actone-workdir/config
COPY required/RCM.war /usr/local/tomcat/webapps

CMD ["catalina.sh", "run"]