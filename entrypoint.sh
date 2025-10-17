#!/bin/bash

# --- 默认设置 ---
# 默认定时周期：每天凌晨3点
CRON_SCHEDULE=${CRON_SCHEDULE:-"0 3 * * *"}

# 容器内配置文件的默认路径
# 如果用户将一个目录挂载到 /aggregator/conf，那么这个文件将位于宿主机上
DEFAULT_CONFIG_PATH="/aggregator/conf/config.json"

# 如果用户提供了 CONFIG_FILE_PATH 环境变量，则使用它；否则，使用默认路径
# 这允许用户继续使用远程 URL 或其他自定义路径
CONFIG_FILE_PATH=${CONFIG_FILE_PATH:-$DEFAULT_CONFIG_PATH}

# 传递给 process.py 脚本的额外参数
EXTRA_ARGS=${EXTRA_ARGS:-""}


# --- 如果使用默认本地路径，则自动初始化配置 ---
if [ "$CONFIG_FILE_PATH" == "$DEFAULT_CONFIG_PATH" ]; then
    # 检查挂载的目录中是否存在 config.json 文件
    if [ ! -f "$DEFAULT_CONFIG_PATH" ]; then
        echo "未在挂载目录 /aggregator/conf 中找到 config.json。"
        echo "正在从模板创建新的配置文件..."
        
        # 从镜像内部将默认配置文件复制到挂载目录中
        cp /aggregator/subscribe/config/config.default.json "$DEFAULT_CONFIG_PATH"
        
        if [ $? -eq 0 ]; then
            echo "已成功创建默认配置文件于: $DEFAULT_CONFIG_PATH"
            echo "请根据您的需求修改此文件。"
        else
            echo "错误：无法创建默认配置文件。请检查挂载的 /aggregator/conf 目录的权限。"
            exit 1
        fi
    else
        echo "在挂载目录中找到现有配置文件，将使用它。"
    fi
fi

# --- 启动定时任务 ---
echo "使用的定时任务周期: $CRON_SCHEDULE"
echo "使用的配置文件路径: $CONFIG_FILE_PATH"
echo "使用的额外参数: $EXTRA_ARGS"

# 将环境变量传递给 cron
printenv | grep -v "no_proxy" >> /etc/environment

# 创建 cron 任务，并将日志输出到 Docker logs
echo "${CRON_SCHEDULE} python -u /aggregator/subscribe/process.py -s ${CONFIG_FILE_PATH} ${EXTRA_ARGS} > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/aggregator-cron

# 应用 cron 任务并启动服务
chmod 0644 /etc/cron.d/aggregator-cron
crontab /etc/cron.d/aggregator-cron
cron -f
