#!/bin/bash

# バックアップ設定
SOURCE_DIR="/home/pi/docker-services/homebridge/volumes/homebridge/"
BACKUP_DIR="/mnt/synology-backup/homebridge"
LOG_FILE="/mnt/synology-backup/homebridge/backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# SMBマウント確認
if ! mountpoint -q /mnt/synology-backup; then
    echo "$DATE - エラー: SMBがマウントされていません" >> $LOG_FILE
    sudo mount -t cifs //jey3dayo.synology.me/storage/backup /mnt/synology-backup -o credentials=/home/pi/.smbcredentials,iocharset=utf8,file_mode=0755,dir_mode=0755,vers=2.0
    if [ $? -ne 0 ]; then
        echo "$DATE - エラー: SMBマウントに失敗しました" >> $LOG_FILE
        exit 1
    fi
fi

# バックアップディレクトリ作成
mkdir -p $BACKUP_DIR

# バックアップ開始
echo "$DATE - バックアップ開始" >> $LOG_FILE

# 重要なファイルとディレクトリをバックアップ
rsync -av --delete \
    --include='config.json' \
    --include='auth.json' \
    --include='persist/***' \
    --include='plugin-persist/***' \
    --exclude='homebridge.log' \
    --exclude='node_modules/***' \
    --exclude='accessories/cachedAccessories.*' \
    --exclude='*' \
    $SOURCE_DIR $BACKUP_DIR/ >> $LOG_FILE 2>&1

# 最新のインスタンスバックアップファイルをコピー
LATEST_BACKUP=$(ls -t $SOURCE_DIR/backups/instance-backups/*.tar.gz 2>/dev/null | head -n 1)
if [ -n "$LATEST_BACKUP" ]; then
    mkdir -p $BACKUP_DIR/instance-backups
    cp -f "$LATEST_BACKUP" $BACKUP_DIR/instance-backups/
    echo "$DATE - 最新のインスタンスバックアップをコピー: $(basename $LATEST_BACKUP)" >> $LOG_FILE
fi

# 古いインスタンスバックアップを削除（最新の3つのみ保持）
cd $BACKUP_DIR/instance-backups 2>/dev/null && ls -t *.tar.gz 2>/dev/null | tail -n +4 | xargs -r rm -f

if [ $? -eq 0 ]; then
    echo "$DATE - バックアップ成功" >> $LOG_FILE
else
    echo "$DATE - バックアップ失敗" >> $LOG_FILE
    exit 1
fi

# ログファイルのサイズ管理（1000行を超えたら古い行を削除）
if [ -f "$LOG_FILE" ]; then
    tail -n 1000 $LOG_FILE > $LOG_FILE.tmp && mv $LOG_FILE.tmp $LOG_FILE
fi

echo "$DATE - バックアップ完了" >> $LOG_FILE