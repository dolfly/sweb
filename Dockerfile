FROM node:16
MAINTAINER dolfly <dolfly@foxmail.com>
ENV LANG C.UTF-8
WORKDIR /ws-scrcpy
RUN npm install -g node-gyp
RUN apt update;apt install android-tools-adb -y
RUN git clone https://github.com/NetrisTV/ws-scrcpy.git .
RUN npm install
RUN npm run dist
EXPOSE 8000
CMD ["node","dist/index.js"]
