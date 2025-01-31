FROM tomcat:9.0.98 as tomcat

RUN MKDIR /data/actone-working-dir/config

RUN COPY acm.ini /data/actone-working-dir/config
RUN COPY actone.lic /data/actone-working-dir/config
RUN COPY F:\Installer CB\ACTONE\809A7210-78-ActOne 10.1.0\ActOne-10.1.0\RCM\RCM.war /usr/local/tomcat/webapps

CMD ["catalina.sh", "run"]