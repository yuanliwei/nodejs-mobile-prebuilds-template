FROM ubuntu:24.04

RUN cat /etc/os-release \
    && apt-get update  \
    && apt-get install -y --reinstall ca-certificates  \
    && update-ca-certificates \
    && sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources \
    && cat /etc/apt/sources.list.d/ubuntu.sources \
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo Asia/Shanghai > /etc/timezone \
    && apt-get update \
    && apt-get install -y \
    tzdata \
    curl \
    wget \
    xz-utils \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* 

# install nodejs
RUN wget https://mirrors.aliyun.com/nodejs-release/v22.6.0/node-v22.6.0-linux-x64.tar.xz \
    && tar -xJf node-v22.6.0-linux-x64.tar.xz \
    && rm -rf node-v22.6.0-linux-x64.tar.xz \
    && mv node-v22.6.0-linux-x64 /usr/local/node

ENV PATH="/usr/local/node/bin:$PATH"

# Create app directory
WORKDIR /usr/project/app

# 配置Android环境 编译出 android-arm64 平台的 /node_modules/sqlite3/lib/binding/napi-v6-android-unknown-arm64/node_sqlite3.node 文件

# Install Android NDK
# RUN wget https://dl.google.com/android/repository/android-ndk-r25c-linux-x86_64.zip \
RUN wget https://googledownloads.cn/android/repository/android-ndk-r27c-linux.zip

# RUN unzip android-ndk-r27c-linux.zip -d /usr/local

# RUN mv /usr/local/android-ndk-r27c /usr/local/android-ndk

# ENV ANDROID_NDK_HOME=/usr/local/android-ndk
# ENV PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# # Install node-gyp
# RUN npm install -g node-gyp

# # Install sqlite3 and build for android-arm64
# RUN npm init -y \
#     && npm install sqlite3@5.1.6 \
#     && node-gyp rebuild --target=22.6.0 --arch=arm64 --platform=android --dist-url=https://mirrors.aliyun.com/nodejs-release/ --verbose

#  podman build .\Dockerfile -t node-android 

RUN apt install -y unzip
RUN unzip android-ndk-r27c-linux.zip
RUN mv /usr/local/android-ndk-r27c /usr/local/android-ndk
RUN mv android-ndk-r27c/ /usr/local/android-ndk

export ANDROID_NDK_HOME=/usr/local/android-ndk
export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

npm config set registry https://registry.npmmirror.com/
npm install -g node-gyp

apt install -y unzip build-essential python3 python3-pip git 

npm init -y
npm install sqlite3@5.1.6

cd /usr/project/app/node_modules/sqlite3

node-gyp rebuild --target=22.6.0 --arch=arm64 --platform=android --dist-url=https://mirrors.aliyun.com/nodejs-release/ --verbose

# RUN npm init -y \
#     && npm install sqlite3@5.1.6 \
#     && node-gyp rebuild --target=22.6.0 --arch=arm64 --platform=android --dist-url=https://mirrors.aliyun.com/nodejs-release/ --verbose

node-gyp rebuild --target=22.6.0 --arch=arm64 --platform=android --dist-url=https://mirrors.aliyun.com/nodejs-release/ --verbose --module_name=sqlite3 --module_path=sqlite3-path

# podman run -it --name node-android -d node-android
# podman exec -it node-android /bin/bash