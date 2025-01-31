FROM tomcat:9.0.98 as tomcat

RUN mkdir -p /data/actone-workdir/config

# COPY acm.ini /usr/local/tomcat
COPY acm.ini /data/actone-workdir/config
COPY actone.lic /data/actone-workdir/config
COPY RCM.war /usr/local/tomcat/webapps

CMD ["catalina.sh", "run"]