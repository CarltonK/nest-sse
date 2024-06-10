FROM node:20.12.1-alpine

# Alpine node image doesn't come with bash
RUN apk --no-cache add \
    curl \
    bash \
    make \ 
    python3

RUN mkdir -p /app
RUN mkdir -p /app/dist

WORKDIR /app

# install and cache app dependencies
COPY package*.json ./
RUN npm i

COPY . /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

CMD [ "npm", "run", "start:dev" ] 