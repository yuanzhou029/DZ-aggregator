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
      -v volume1/docker/aggregator_config:/aggregator/conf \
      -e EXTRA_ARGS="--overwrite" \
      registry.cyou/yz029/dz-aggregator:main
    ```

*   **Windows (PowerShell):**
    ```bash
    docker run -d `
      --name aggregator `
      -v D:\docker\aggregator_config:/aggregator/conf `
      -e EXTRA_ARGS="--overwrite" `
      yz029/dz-aggregator:main
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

## 免责申明
+ 本项目仅用作学习爬虫技术，请勿滥用，不要通过此工具做任何违法乱纪或有损国家利益之事
+ 禁止使用该项目进行任何盈利活动，对一切非法使用所产生的后果，本人概不负责

## 致谢
1. <u>[Subconverter](https://github.com/asdlokj1qpi233/subconverter)</u>、<u>[Mihomo](https://github.com/MetaCubeX/mihomo)</u>

2. 感谢 [![YXVM](https://support.nodeget.com/page/promotion?id=250)](https://yxvm.com)
[NodeSupport](https://github.com/NodeSeekDev/NodeSupport) 赞助了本项目
