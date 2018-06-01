FROM adhocrepo/linux-openjdk8-slim:v2.0.0

RUN apt-get install locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen en_US.UTF-8
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV TZ=Asia/Harbin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

ONBUILD COPY ./project /data/project
ONBUILD COPY ./build.sbt /data/build.sbt
ONBUILD COPY ./script/sbt-repositories /root/.sbt/repositories
ONBUILD RUN cd /data && sbt update -Dsbt.override.build.repos=true
ONBUILD COPY . /data

ONBUILD RUN service mongodb restart \
    && service redis-server restart \
    && cd /data \
    && sbt -Dsbt.override.build.repos=true -Dfile.encoding=UTF-8 -Duser.timezone=Asia/Harbin test \
    && sbt -Dsbt.override.build.repos=true -Dfile.encoding=UTF-8 -Duser.timezone=Asia/Harbin dist \
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

ONBUILD CMD ["/entrypoint", "-Dconfig.resource=prod.conf", "-Dfile.encoding=UTF8", "-Duser.timezone=Asia/Harbin"]
