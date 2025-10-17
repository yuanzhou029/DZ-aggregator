#!/bin/bash

# 设置默认值
CRON_SCHEDULE=${CRON_SCHEDULE:-"0 3 * * *"}
CONFIG_FILE_PATH=${CONFIG_FILE_PATH:-""}
EXTRA_ARGS=${EXTRA_ARGS:-""}

# 检查 CONFIG_FILE_PATH 是否设置，-s 参数是 process.py 用来指定配置文件的
if [ -z "$CONFIG_FILE_PATH" ]; then
  echo "错误：必须设置 CONFIG_FILE_PATH 环境变量来指定配置文件的 URL 或本地路径。"
  exit 1
fi

echo "使用的定时任务周期: $CRON_SCHEDULE"
echo "使用的配置文件路径: $CONFIG_FILE_PATH"
echo "使用的额外参数: $EXTRA_ARGS"

# 创建 crontab 文件
# 将环境变量写入文件，以便 cron 任务可以访问它们
printenv | grep -v "no_proxy" >> /etc/environment

# 创建 crontab 任务，并将标准输出和错误输出重定向到 Docker 日志
echo "${CRON_SCHEDULE} python -u /aggregator/subscribe/process.py -s ${CONFIG_FILE_PATH} ${EXTRA_ARGS} > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/aggregator-cron

# 赋予 crontab 文件正确的权限
chmod 0644 /etc/cron.d/aggregator-cron

# 应用 cron 任务
crontab /etc/cron.d/aggregator-cron

# 以前台模式启动 cron 服务
cron -f
