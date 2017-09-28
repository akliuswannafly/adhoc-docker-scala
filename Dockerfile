FROM java:8-jdk

RUN ln -sf /usr/share/zoneinfo/posix/Asia/Harbin /etc/localtime

ONBUILD COPY /target/universal/*.zip /data

ONBUILD RUN cd /data && unzip *.zip

ONBUILD RUN cd /data && export proj_name=`pwd | awk -F '/' '{print &NF}'` && \
    mkdir -p /release/${proj_name} && mv /data/${proj_name}* /release && \
    cd /release/${proj_name}*/bin && \
    ln -s `pwd`/$proj_name /entrypoint

ONBUILD RUN rm -r /data

ONBUILD CMD ["/entrypoint", "-Dconfig.resource=prod.conf", "-Dfile.encoding=UTF8"]
