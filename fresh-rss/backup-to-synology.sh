#!/bin/bash

# Synology NASの設定
SYNOLOGY_HOST="your-synology-ip"
SYNOLOGY_USER="your-username"
SYNOLOGY_PATH="/volume1/backup/freshrss"

# バックアップ元
SOURCE_DIR="/home/pi/docker-services/fresh-rss/freshrss/data/"

# ログファイル
LOG_FILE="/home/pi/docker-services/fresh-rss/backup.log"

# バックアップ実行
echo "$(date '+%Y-%m-%d %H:%M:%S') - バックアップ開始" >> $LOG_FILE

rsync -avz --delete \
  $SOURCE_DIR \
  $SYNOLOGY_USER@$SYNOLOGY_HOST:$SYNOLOGY_PATH/ \
  >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - バックアップ成功" >> $LOG_FILE
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - バックアップ失敗" >> $LOG_FILE
fi

# 古いログを削除（30日以上前の行を削除）
tail -n 1000 $LOG_FILE > $LOG_FILE.tmp && mv $LOG_FILE.tmp $LOG_FILE