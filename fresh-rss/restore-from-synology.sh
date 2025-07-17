#!/bin/bash

# リストアスクリプト
BACKUP_DIR="/mnt/synology-backup/fresh-rss/data"
RESTORE_DIR="/home/pi/docker-services/fresh-rss/freshrss/data"

echo "警告: このスクリプトは現在のFreshRSSデータを完全に置き換えます。"
echo "続行しますか？ (y/N)"
read -r response

if [[ "$response" != "y" && "$response" != "Y" ]]; then
    echo "リストアをキャンセルしました。"
    exit 0
fi

# SMBマウント確認
if ! mountpoint -q /mnt/synology-backup; then
    echo "SMBをマウントしています..."
    sudo mount -t cifs //jey3dayo.synology.me/storage/backup /mnt/synology-backup -o credentials=/home/pi/.smbcredentials,iocharset=utf8,file_mode=0755,dir_mode=0755,vers=2.0
    if [ $? -ne 0 ]; then
        echo "エラー: SMBマウントに失敗しました"
        exit 1
    fi
fi

# Dockerコンテナを停止
echo "FreshRSSを停止しています..."
cd /home/pi/docker-services/fresh-rss
docker-compose down

# データをリストア
echo "データをリストアしています..."
rsync -av --delete $BACKUP_DIR/ $RESTORE_DIR/

# 権限を修正
sudo chown -R www-data:www-data $RESTORE_DIR

# Dockerコンテナを起動
echo "FreshRSSを起動しています..."
docker-compose up -d

echo "リストア完了！"