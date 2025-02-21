FROM ubuntu:24.04

# 基础系统配置
RUN cat /etc/os-release \
    && apt-get update \
    && apt-get install -y --reinstall ca-certificates \
    && update-ca-certificates \
    && sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources \
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo Asia/Shanghai > /etc/timezone \
    && apt-get update \
    && apt-get install -y \
    tzdata \
    curl \
    wget \
    xz-utils \
    unzip \
    build-essential \
    python3 \
    python3-pip \
    git \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 安装指定版本Node.js
RUN wget https://mirrors.aliyun.com/nodejs-release/v22.6.0/node-v22.6.0-linux-x64.tar.xz \
    && tar -xJf node-v22.6.0-linux-x64.tar.xz \
    && mv node-v22.6.0-linux-x64 /usr/local/node \
    && rm node-v22.6.0-linux-x64.tar.xz

ENV PATH="/usr/local/node/bin:$PATH"

# 安装Android NDK r27c
RUN wget https://googledownloads.cn/android/repository/android-ndk-r27c-linux.zip \
    && unzip android-ndk-r27c-linux.zip -d /usr/local \
    && mv /usr/local/android-ndk-r27c /usr/local/android-ndk \
    && rm android-ndk-r27c-linux.zip

ENV ANDROID_NDK_HOME=/usr/local/android-ndk
ENV PATH="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}"

# 配置npm镜像源
RUN npm config set registry https://registry.npmmirror.com/

# 安装编译依赖
RUN npm install -g node-gyp

# 创建工作目录
WORKDIR /app

# 编译sqlite3的Android arm64版本
RUN npm pack sqlite3@5.1.6 | xargs tar -zxvf \
    && cd package && npm install --ignore-scripts \
    && CC=aarch64-linux-android21-clang \
    CXX=aarch64-linux-android21-clang++ \
    node-gyp rebuild \
        --target=22.6.0 \
        --arch=arm64 \
        --platform=android \
        --dist-url=https://mirrors.aliyun.com/nodejs-release/ \
        --verbose \
        --module_name=node_sqlite3 \
        --module_path=./output/aarch64/

# podman build . -f ./Dockerfile -t node-android
## podman run -it --name node-android -d node-android
## podman exec -it node-android /bin/bash
# podman create --name temp node-android
# podman cp temp:/app/package ./
# podman rm temp