FROM tomcat:9.0.98 as tomcat

WORKDIR /data/actone-workdir

RUN mkdir -p config

COPY acm.ini /usr/local/tomcat
#COPY acm.ini /data/actone-workdir/config
COPY actone.lic config/*
COPY required/RCM.war /usr/local/tomcat/webapps

CMD ["catalina.sh", "run"]