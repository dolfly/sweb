FROM node:16 AS BUILD_IMAGE
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin
WORKDIR /app
RUN npm install -g node-gyp
RUN git clone --depth 1 https://github.com/dolfly/ws-scrcpy.git .
RUN git checkout -b v0.8.1
RUN npm install && npm run dist
RUN npm prune --production

FROM node:16-buster
ENV LANG C.UTF-8
COPY --from=BUILD_IMAGE /app/dist /app/dist
COPY --from=BUILD_IMAGE /app/node_modules /app/node_modules
COPY adbconnect /app/bin/adbconnect
COPY entrypoint /app/bin/entrypoint
COPY sources.list /etc/apt/sources.list
RUN apt-get update  && \
    apt-get install -y net-tools inetutils-tools bind9-dnsutils netcat socat curl wget vim cron android-tools-adb android-tools-fastboot bash nmap && \
    apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    npm install -g pm2 && \
    chmod +x /app/bin/adbconnect && chmod +x /app/bin/entrypoint && \
    echo '* * * * * /app/bin/adbconnect' > /tmp/crontab.tmp && crontab /tmp/crontab.tmp
WORKDIR /app
EXPOSE 8000
ENTRYPOINT [ "/app/bin/entrypoint" ]
CMD [ "/bin/bash" ]