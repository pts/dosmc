FROM scratch
#MAINTAINER user@email.com
#LABEL version=1
CMD ["sh"]
ADD busybox /bin/
RUN ["busybox", "ln", "-s", "/", "/usr"]
RUN ["busybox", "--install", "-s"]
WORKDIR /workdir
