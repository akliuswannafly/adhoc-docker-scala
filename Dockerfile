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
    && mkdir -p /release/${proj_name} \
    && mv /data/target/universal/${proj_name}* /release \
    && cd /release/${proj_name}*/bin \
    && ln -s `pwd`/$proj_name /entrypoint

ONBUILD RUN rm -r /data

ONBUILD CMD ["/entrypoint", "-Dconfig.resource=prod.conf", "-Dfile.encoding=UTF8"]
