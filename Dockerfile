FROM debian:7

# install jdk1.8
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
	echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 99E82A75642AC823 && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
	apt-get install -f && rm -rf /var/lib/apt/lists/* && \
	echo "deb http://packages.dotdeb.org wheezy all" | tee -a /etc/apt/sources.list.d/dotdeb.list && \
	echo "deb-src http://packages.dotdeb.org wheezy all" | tee -a /etc/apt/sources.list.d/dotdeb.list && \
	wget http://www.dotdeb.org/dotdeb.gpg && \
	apt-key add dotdeb.gpg && \
	echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
	apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default unzip wget procps

RUN echo "Asia/Harbin" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ONBUILD COPY /target/universal/*.zip /data

ONBUILD RUN cd /data && unzip *.zip

# run cron and project
ONBUILD RUN cd /data && export proj_name=`sbt settings name | tail -1 | cut -d' ' -f2 |tr -dc [:print:] | sed 's/\[0m//g'` && \
	mkdir -p /release/${proj_name} && mv /data/${proj_name}* /release && \
	cd /release/${proj_name}*/bin && \
	ln -s `pwd`/$proj_name /entrypoint

# cleanup
# ONBUILD RUN rm -r /data

ONBUILD CMD ["/entrypoint", "-Dconfig.resource=prod.conf", "-Dfile.encoding=UTF8"]
