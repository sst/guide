FROM ubuntu:18.04
MAINTAINER Frank Wang <frank@anoma.ly>

WORKDIR /tmp
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget texlive-xetex texlive-fonts-extra build-essential
RUN wget https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-linux-amd64.tar.gz
RUN tar xvzf pandoc-2.10.1-linux-amd64.tar.gz --strip-components 1 -C /usr

RUN mkdir -p /root/.fonts
COPY fonts/RobotoSlab/*.ttf /root/.fonts/
COPY fonts/SourceCodePro/*.ttf /root/.fonts/
COPY fonts/SourceSansPro/*.ttf /root/.fonts/

WORKDIR /data/etc/ebook
ENTRYPOINT /bin/bash
