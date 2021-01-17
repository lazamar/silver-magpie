FROM node:10.23.1

COPY ./ /home/app/
WORKDIR /home/app

RUN apt-get update
RUN apt-get install zip

RUN yarn install

RUN yarn gulp build
