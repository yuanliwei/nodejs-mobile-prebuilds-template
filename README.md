# nodejs-mobile-prebuilds-template

为构建和发布特定模块的 [NodeJS Mobile](https://github.com/nodejs-mobile/nodejs-mobile) 预构建文件而创建的模板仓库。

## 入门指南

1. 使用 GitHub 界面从该模板创建一个新仓库。或者你可以选择 fork 它。
2. 根据需要更新 [Dockerfile](./Dockerfile) 中定义的环境变量和配置：
   - `NODE_VERSION`: 用于构建的 Node 版本（你可能不需要更改它）
   - `MODULE_NAME`: 你正在为其构建预构建文件的模块名称
   - `MODULE_VERSION`: 你正在构建的模块的包版本（你可能不需要更改它）

3. 删除 README 中的 [`入门指南`](#getting-started) 部分！（因为它特定于模板仓库）

## 使用 Docker 构建

### 要求

- Docker 和 Podman（推荐使用 Podman）

### 构建步骤

1. **构建 Docker 镜像**:
   ```bash
   podman build . -f ./Dockerfile -t node-android
   ```

2. **运行容器**:
   ```bash
   podman run -it --name node-android -d node-android
   ```

3. **进入容器进行交互操作**:
   ```bash
   podman exec -it node-android /bin/bash
   ```

4. **复制生成的预构建文件**:
   ```bash
   podman create --name temp node-android
   podman cp temp:/app/package ./
   podman rm temp
   ```

### 示例：编译 sqlite3 的 Android arm64 版本

在 `Dockerfile` 中已经包含了编译 `sqlite3` 的示例命令。你可以根据需要修改这些命令以适应其他模块。

## 创建发布版本

1. 创建与你要构建预构建文件的模块版本匹配的 git 标签，例如 `git tag 1.0.0`
2. 将标签推送到远程仓库，例如 `git push origin 1.0.0`
3. 使用 Docker 构建并发布预构建文件：
   - 构建镜像并运行容器。
   - 进入容器，完成必要的编译步骤。
   - 将生成的工件复制到本地或上传到 GitHub Releases。

4. 相关工件将出现在 GitHub Releases 中。每个工件是一个包含目标特定 `.node` 文件的 tarball。


### 更新说明

- **移除了 GitHub Actions 相关的内容**，改为详细描述如何使用 Docker 构建和发布预构建文件。
- **增加了 Docker 和 Podman 的要求**，并提供了详细的构建和运行步骤。
- **保留了创建发布版本的部分**，但调整为使用 Docker 构建和发布的方式。

