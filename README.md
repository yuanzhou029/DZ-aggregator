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


## Docker 使用方法
本项目支持通过 Docker 运行，镜像内置了 `cron` 定时任务服务，可以实现周期性地自动执行代理聚合任务。

### 运行容器
您可以使用以下命令来运行 Docker 容器：
```bash
docker run -d \
  --name aggregator \
  -e CONFIG_FILE_PATH="https://your-config-url/config.json" \
  -e CRON_SCHEDULE="0 3 * * *" \
  -e EXTRA_ARGS="--overwrite" \
  your-dockerhub-username/dz-aggregator-main:latest
```

### 环境变量说明
| 环境变量 | 是否必需 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| `CONFIG_FILE_PATH` | **是** | (无) | 指定 `process.py` 使用的配置文件。可以是一个远程 URL，也可以是挂载到容器内的本地文件路径（例如 `/path/to/your/config.json`）。 |
| `CRON_SCHEDULE` | 否 | `"0 3 * * *"` | 定义 `cron` 定时任务的执行周期，格式为标准的 crontab 格式。默认为每天凌晨3点。 |
| `EXTRA_ARGS` | 否 | (无) | 传递给 `process.py` 脚本的额外命令行参数。例如，可以设置为 `"--overwrite --num 128"` 来覆盖旧代理并使用128个线程。 |

### 自动构建
本仓库已配置 GitHub Actions，可以手动触发工作流，自动构建 Docker 镜像并将其推送到 Docker Hub。

## 免责申明
+ 本项目仅用作学习爬虫技术，请勿滥用，不要通过此工具做任何违法乱纪或有损国家利益之事
+ 禁止使用该项目进行任何盈利活动，对一切非法使用所产生的后果，本人概不负责

## 致谢
1. <u>[Subconverter](https://github.com/asdlokj1qpi233/subconverter)</u>、<u>[Mihomo](https://github.com/MetaCubeX/mihomo)</u>

2. 感谢 [![YXVM](https://support.nodeget.com/page/promotion?id=250)](https://yxvm.com)
[NodeSupport](https://github.com/NodeSeekDev/NodeSupport) 赞助了本项目
