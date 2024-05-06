FROM node:16-alpine AS BUILD_IMAGE
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN wget -qO- https://gobinaries.com/tj/node-prune | ash -s
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk --no-cache add coreutils git python3 make gcc g++
WORKDIR /app
RUN npm config set registry https://registry.npmmirror.com && npm install -g node-gyp
RUN git clone --depth 1 https://github.com/dolfly/ws-scrcpy.git .
RUN git checkout -b v0.8.2
RUN npm install && npm run dist
RUN npm prune --production

FROM node:16-alpine
ENV LANG C.UTF-8
COPY --from=BUILD_IMAGE /app/dist /app/dist
COPY --from=BUILD_IMAGE /app/node_modules /app/node_modules
COPY adbconnect /app/bin/adbconnect
COPY entrypoint /app/bin/entrypoint
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk --no-cache add coreutils android-tools bash nmap && \
    npm install -g pm2 && \
    chmod +x /app/bin/adbconnect && chmod +x /app/bin/entrypoint && \
    echo '* * * * * /app/bin/adbconnect' > /tmp/crontab.tmp && crontab /tmp/crontab.tmp
WORKDIR /app
EXPOSE 8000
ENTRYPOINT [ "/app/bin/entrypoint" ]
CMD [ "/usr/sbin/crond", "-f", "-d", "0" ]