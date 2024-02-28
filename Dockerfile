FROM node:16 AS BUILD_IMAGE
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin
WORKDIR /app
RUN npm install -g node-gyp
RUN git clone https://github.com/NetrisTV/ws-scrcpy.git .
RUN npm install && npm run dist
RUN npm prune --production


FROM node:16-alpine
ENV LANG C.UTF-8
COPY --from=BUILD_IMAGE /app/dist ./dist
COPY --from=BUILD_IMAGE /app/node_modules ./node_modules
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY adbconnect /app/bin/adbconnect
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk --update-cache add coreutils android-tools bash nmap 
EXPOSE 8000
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "node", "dist/index.js" ]
