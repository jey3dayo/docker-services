#!/bin/bash

# バックアップ設定
SOURCE_DIR="/home/pi/docker-services/fresh-rss/freshrss/data/"
BACKUP_DIR="/mnt/synology-backup/fresh-rss"
LOG_FILE="/mnt/synology-backup/fresh-rss/backup.log"
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

# バックアップ開始
echo "$DATE - バックアップ開始" >> $LOG_FILE

# rsyncで差分バックアップ（SDカードへの書き込みを最小化）
rsync -av --delete \
    --exclude='cache/*.spc' \
    --exclude='*.log' \
    $SOURCE_DIR $BACKUP_DIR/ >> $LOG_FILE 2>&1

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