FROM adhocrepo/debian-oraclejdk8

ONBUILD COPY . /data
ONBUILD RUN service mongod restart \
    && service redis-server restart \
    && cd /data \
    && sbt -Dfile.encoding=UTF-8 test \
    && sbt -Dfile.encoding=UTF-8 dist \
    && cd /data/target/universal/ \
    && unzip *.zip \
    && rm *.zip \
    && cd /data \
    && export proj_name=`sbt settings name | tail -1 | cut -d' ' -f2 | tr -dc [:print:] | sed 's/\[0m//g'` \
    && ln -s /data/target/universal/${proj_name}*/bin/$proj_name /entrypoint

ONBUILD CMD ["/entrypoint", "-Dconfig.resource=prod.conf", "-Dfile.encoding=UTF8"]
