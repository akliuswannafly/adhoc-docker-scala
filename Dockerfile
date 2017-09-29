FROM java:8-jdk

RUN ln -sf /usr/share/zoneinfo/posix/Asia/Harbin /etc/localtime

ONBUILD COPY ./target/universal/*.zip /data/

ONBUILD RUN cd /data \
    && unzip *.zip \
    && rm *.zip \
    && export proj_name=`ls` \
    && cd `ls`/bin \
    && ln -s `pwd`/`ls | sed -n '1p'` /entrypoint

ONBUILD CMD ["/entrypoint", "-Dconfig.resource=prod.conf", "-Dfile.encoding=UTF8"]
