<!--
 * @Author: wzdnzd
 * @Date: 2022-03-06 14:51:29
 * @Description: 
 * Copyright (c) 2022 by wzdnzd, All Rights Reserved.
-->

## 功能
打造免费代理池，爬一切可爬节点
> 拥有灵活的插件系统，如果目标网站特殊，现有功能未能覆盖，可针对性地通过插件实现

> 欢迎 Star 及 PR。对于质量较高且普适的爬取目标，亦可在 Issues 中列出，将在评估后选择性添加

## 使用方法
> 可前往 [Issue #91](https://github.com/wzdnzd/aggregator/issues/91) 食用**共享订阅**，量大质优。**请勿浪费**
 
略，自行探索。我才不会告诉你入口是 `collect.py` 和 `process.py`。**强烈建议使用后者，前者只是个小玩具**，配置参考 `subscribe/config/config.default.json`，详细文档见 [DeepWiki](https://deepwiki.com/wzdnzd/aggregator)


## Docker 一键启动 (推荐)
本项目支持通过 Docker 快速部署。镜像内置了 `cron` 定时任务服务，并能自动初始化配置文件，极大简化了首次部署的流程。

### 快速开始
只需两步，即可启动您的代理聚合服务。

**第一步：在您的电脑上创建一个空目录**
这个目录将用于存放由容器自动生成的配置文件。
```bash
# Linux / macOS
mkdir -p ~/docker/aggregator_config

# Windows (PowerShell)
mkdir -p D:\docker\aggregator_config
```

**第二步：运行 Docker 容器**
执行以下命令。容器在首次启动时，会自动在您创建的目录中生成一份 `config.json` 模板文件。

*   **Linux / macOS:**
    ```bash
    docker run -d \
      --name aggregator \
      -v ~/docker/aggregator_config:/aggregator/conf \
      -e EXTRA_ARGS="--overwrite" \
      yz029/dz-aggregator:latest
    ```

*   **Windows (PowerShell):**
    ```bash
    docker run -d `
      --name aggregator `
      -v D:\docker\aggregator_config:/aggregator/conf `
      -e EXTRA_ARGS="--overwrite" `
      yz029/dz-aggregator:latest
    ```

启动后，请检查您本地的 `~/docker/aggregator_config` 目录，会发现多了一个 `config.json` 文件。现在，您只需在本地修改这个文件（特别是 `update.cron_schedule` 字段），容器就会在下次启动时应用新的定时周期。

### 通过配置文件控制定时任务
定时任务的执行周期现在由 `config.json` 文件中的 `update.cron_schedule` 字段控制。
```json
{
  "...": "...",
  "update": {
    "cron_schedule": "0 3 * * *"
  },
  "...": "..."
}
```
修改该值后，**需要重启容器**才能使新的定时任务周期生效。

### 环境变量说明
| 环境变量 | 是否必需 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| `EXTRA_ARGS` | 否 | (无) | 传递给 `process.py` 脚本的额外命令行参数。例如，可以设置为 `"--overwrite --num 128"`。 |
| `CONFIG_FILE_PATH` | 否 | `/aggregator/conf/config.json` | **高级用法**。用于覆盖默认的配置文件路径。例如，您可以将其设置为一个远程 URL 来加载云端配置（此模式下无法从文件读取定时任务周期）。 |

### 自动构建
本仓库已配置 GitHub Actions，可以手动触发工作流，自动构建 Docker 镜像并将其推送到 Docker Hub。

### 国内用户部署提示
如果在中国大陆从 Docker Hub 拉取镜像速度较慢，可以配置 Docker 镜像加速器。

**1. 配置 `daemon.json` 文件**
打开或创建 Docker 的 `daemon.json` 文件（Linux: `/etc/docker/daemon.json`，Windows: `%programdata%\docker\config\daemon.json`），并添加以下内容：
```json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

**2. 重启 Docker 服务**
*   **Linux:** 执行 `sudo systemctl daemon-reload && sudo systemctl restart docker`。
*   **Windows / macOS:** 重启 Docker Desktop。

配置完成后，`docker pull` 命令将自动通过国内镜像源加速。

## 配置文件 (config.json) 详解
当您第一次运行 Docker 容器后，会在您挂载的目录（例如 `~/docker/aggregator_config`）下找到一个 `config.json` 文件。这是控制整个项目的核心，下面我们来详细讲解如何配置它。

我们主要关注以下几个部分：`update`, `crawl`, `groups`, 和 `storage`。

---

### 1. `update` - 设置定时任务
这是最简单的部分，用于控制任务的执行时间。
```json
"update": {
  "cron_schedule": "0 3 * * *"
},
```
*   `cron_schedule`: **定时任务周期**。格式是标准的 Crontab 表达式，由5个部分组成，分别代表：`分钟 小时 天 月 星期`。
    *   `"0 3 * * *"`: 默认值，表示“每天凌晨3点0分”执行一次。
    *   `"0 */6 * * *"`: 表示“每隔6小时”执行一次。
    *   `"*/30 * * * *"`: 表示“每隔30分钟”执行一次。
    *   **注意**：修改此值后，需要重启 Docker 容器才能生效。

---

### 2. `crawl` - 从哪里抓取免费节点
这是项目的核心功能，用于从各种公开渠道自动抓取订阅链接或节点信息。

```json
"crawl": {
  "enable": true,
  "telegram": { ... },
  "github": { ... },
  "scripts": [ ... ]
},
```
*   `enable`: **抓取功能的总开关**。设置为 `true` 表示开启；`false` 表示关闭。

#### (1) 从 Telegram 抓取 (`telegram`)
您可以让它监控指定的 Telegram 公开频道，从中发现订阅链接。
```json
"telegram": {
  "enable": true,
  "pages": 5,
  "users": {
    "wzdnzd": {
      "push_to": ["v2ray-group"]
    },
    "vpn_xw": {
      "push_to": ["v2ray-group"]
    }
  }
}
```
*   `enable`: Telegram 抓取功能的开关。
*   `pages`: 检查每个频道时，向前翻阅多少页的历史消息。
*   `users`: 在这里列出您想监控的 **Telegram 公开频道 ID** (不带 `@`)。
    *   `"wzdnzd": { ... }`: 这是一个例子，表示监控 ID 为 `wzdnzd` 的频道。
    *   `push_to`: 一个非常重要的设置，它告诉程序将从这个频道抓取到的节点放入哪个“分组”（我们将在第3部分讲解 `groups`）。这里的 `["v2ray-group"]` 意味着节点将被放入名为 `v2ray-group` 的分组中。

#### (2) 从 GitHub 抓取 (`github`)
它会自动搜索 GitHub 上包含订阅链接的仓库或代码片段。通常，您只需开启它即可。
```json
"github": {
  "enable": true,
  "pages": 2,
  "push_to": ["v2ray-group"]
}
```
*   `enable`: GitHub 抓取功能的开关。
*   `pages`: 搜索结果要翻多少页。
*   `push_to`: 同上，将从 GitHub 抓取到的节点放入指定的分组。

---

### 3. `groups` - 如何处理和输出节点
当从各个渠道收集到一大堆节点后，`groups` 的作用就是将它们进行**处理、筛选并转换成您需要的订阅格式**。

```json
"groups": {
  "v2ray-group": {
    "emoji": true,
    "targets": {
      "v2ray": "v2ray-subscribe"
    }
  }
}
```
*   `"v2ray-group": { ... }`: 定义了一个名为 `v2ray-group` 的分组。这个名字要和 `crawl` 部分的 `push_to` 设置对应起来。
*   `emoji`: 是否自动为节点名称添加国家/地区的旗帜 emoji，`true` 为是。
*   `targets`: **输出目标**，这是最关键的部分。它定义了要将这个分组的节点转换成哪种格式，并与 `storage`（存储）关联起来。
    *   `"v2ray": "v2ray-subscribe"`:
        *   键 `"v2ray"`: 表示您希望生成 **V2Ray** 格式的订阅链接 (Base64 编码)。其他可选值有 `"clash"`, `"singbox"` 等。
        *   值 `"v2ray-subscribe"`: 这是一个**存储名称**，它告诉程序在处理完后，去 `storage` 部分查找名为 `v2ray-subscribe` 的配置，以决定如何保存最终的订阅文件。

---

### 4. `storage` - 保存最终的订阅文件
当 `groups` 处理完节点并生成了 V2Ray 或 Clash 格式的内容后，`storage` 决定将这些内容存放到哪里。对于新手来说，最简单的方式是将其推送到一个私密的 GitHub Gist。

```json
"storage": {
  "engine": "gist",
  "items": {
    "v2ray-subscribe": {
      "fileid": "YOUR_GIST_FILE_ID"
    }
  }
}
```
*   `engine`: **存储引擎**。设置为 `"gist"` 表示您希望使用 GitHub Gist 来存储。
*   `items`: 存储项列表。
    *   `"v2ray-subscribe": { ... }`: 定义了一个名为 `v2ray-subscribe` 的存储配置，这个名字要和 `groups` 部分的 `targets` 设置对应起来。
    *   `fileid`: **您的 Gist 文件的 ID**。您需要先在 GitHub Gist 上创建一个文件（内容任意），然后将该文件的 ID 填在这里。

**要使用 Gist 存储，您还需要在 GitHub Actions 的 Secrets 中配置 `GIST_PAT`**，这是一个有 Gist 读写权限的 Personal Access Token。

### 总结一个最简配置
对于新手，您可以尝试以下最小配置：
1.  在 `crawl.telegram.users` 中添加一两个您知道的分享频道的 ID。
2.  将 `crawl` 和 `groups` 中的 `push_to` 和分组名称统一起来（例如都用 `"my-group"`）。
3.  将 `groups.targets` 的输出目标与 `storage.items` 的存储名称统一起来（例如都用 `"my-clash-sub"`）。
4.  配置好 `storage` 部分，例如使用 Gist。
5.  修改 `config.json` 后，重启 Docker 容器。等待下一个定时任务周期执行完毕后，您的 Gist 文件内容就会被自动更新为最新的订阅链接。

## 免责申明
+ 本项目仅用作学习爬虫技术，请勿滥用，不要通过此工具做任何违法乱纪或有损国家利益之事
+ 禁止使用该项目进行任何盈利活动，对一切非法使用所产生的后果，本人概不负责

## 致谢
1. <u>[Subconverter](https://github.com/asdlokj1qpi233/subconverter)</u>、<u>[Mihomo](https://github.com/MetaCubeX/mihomo)</u>

2. 感谢 [![YXVM](https://support.nodeget.com/page/promotion?id=250)](https://yxvm.com)
[NodeSupport](https://github.com/NodeSeekDev/NodeSupport) 赞助了本项目
