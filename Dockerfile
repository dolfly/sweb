FROM node:16 AS BUILD_IMAGE
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin
WORKDIR /app
RUN npm install -g node-gyp
RUN git clone https://github.com/NetrisTV/ws-scrcpy.git .
RUN npm install && npm run dist
RUN npm prune --production


FROM node:16-alpine
MAINTAINER dolfly <dolfly@foxmail.com>
ENV LANG C.UTF-8
COPY --from=BUILD_IMAGE /app/dist ./dist
COPY --from=BUILD_IMAGE /app/node_modules ./node_modules
RUN apk --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ add android-tools
EXPOSE 8000
CMD ["node","dist/index.js"]
