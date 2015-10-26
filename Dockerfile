FROM ubuntu:14.04

RUN apt-get --yes update && apt-get --yes upgrade
RUN apt-get --yes install -y curl git python

RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
RUN apt-get --yes install -y nodejs
RUN sudo npm install -g npm

RUN nodejs --version
RUN npm --version

RUN git clone https://github.com/butterproject/butter-desktop-angular.git /opt/butter

WORKDIR /opt/butter
RUN npm install -g bower grunt-cli
RUN npm install
RUN grunt build

