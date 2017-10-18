FROM adhocrepo/debian-oraclejdk8

ONBUILD COPY . /data
ONBUILD RUN cd /data \
    && sbt -Dfile.encoding=UTF-8 test \
    && sbt -Dfile.encoding=UTF-8 dist \
    && cd /data/target/universal/ \
    && unzip *.zip \
    && rm *.zip \
    && export proj_name=`ls` \
    && cd `ls`/bin \
    && ln -s `pwd`/`ls | sed -n '1p'` /entrypoint

ONBUILD CMD ["/entrypoint", "-Dconfig.resource=prod.conf", "-Dfile.encoding=UTF8"]
