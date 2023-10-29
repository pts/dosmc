FROM bitnami/git

RUN apt update
RUN apt install wget
RUN apt install unzip

WORKDIR /home
RUN git clone --depth 1 https://github.com/pts/dosmc

WORKDIR /home/dosmc
RUN ./download_openwatcom.sh
RUN rm -R /usr/local/bin
RUN mv binl /usr/local/bin
RUN ./dosmc --prepare

ENTRYPOINT ["tail", "-f", "/dev/null"]
