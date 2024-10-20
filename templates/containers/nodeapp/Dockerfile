FROM --platform=linux/amd64 node:19-alpine

WORKDIR /app

COPY ./app/package.json /app/package.json

RUN npm i -g nodemon
RUN npm i -g webpack
RUN npm i -g express

RUN apk update && apk add bash

EXPOSE 4040

CMD npm run start