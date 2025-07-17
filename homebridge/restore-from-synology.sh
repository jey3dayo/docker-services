#!/bin/bash

# リストア設定
BACKUP_DIR="/mnt/synology-backup/homebridge"
RESTORE_DIR="/home/pi/docker-services/homebridge/volumes/homebridge"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# SMBマウント確認
if ! mountpoint -q /mnt/synology-backup; then
    echo -e "${YELLOW}SMBがマウントされていません。マウントを試みます...${NC}"
    sudo mount -t cifs //jey3dayo.synology.me/storage/backup /mnt/synology-backup -o credentials=/home/pi/.smbcredentials,iocharset=utf8,file_mode=0755,dir_mode=0755,vers=2.0
    if [ $? -ne 0 ]; then
        echo -e "${RED}エラー: SMBマウントに失敗しました${NC}"
        exit 1
    fi
fi

# バックアップの存在確認
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}エラー: バックアップディレクトリが存在しません: $BACKUP_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}=== Homebridge リストア ===${NC}"
echo -e "バックアップ元: $BACKUP_DIR"
echo -e "リストア先: $RESTORE_DIR"
echo ""

# バックアップ情報表示
echo -e "${GREEN}バックアップ内容:${NC}"
if [ -f "$BACKUP_DIR/config.json" ]; then
    echo "  - config.json ($(stat -c %y "$BACKUP_DIR/config.json" | cut -d' ' -f1,2))"
fi
if [ -f "$BACKUP_DIR/auth.json" ]; then
    echo "  - auth.json"
fi
if [ -d "$BACKUP_DIR/persist" ]; then
    echo "  - persist/ (デバイス情報)"
fi
if [ -d "$BACKUP_DIR/plugin-persist" ]; then
    echo "  - plugin-persist/ (プラグイン設定)"
fi
if [ -d "$BACKUP_DIR/instance-backups" ]; then
    LATEST_BACKUP=$(ls -t $BACKUP_DIR/instance-backups/*.tar.gz 2>/dev/null | head -n 1)
    if [ -n "$LATEST_BACKUP" ]; then
        echo "  - 最新のインスタンスバックアップ: $(basename $LATEST_BACKUP)"
    fi
fi

echo ""
echo -e "${RED}警告: この操作により現在の設定が上書きされます！${NC}"
echo -n "続行しますか？ (y/N): "
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "リストアを中止しました。"
    exit 0
fi

# Homebridgeサービス停止
echo -e "${YELLOW}Homebridgeサービスを停止しています...${NC}"
cd /home/pi/docker-services/homebridge && docker-compose down

# 現在の設定をバックアップ
BACKUP_TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
echo -e "${YELLOW}現在の設定をバックアップしています...${NC}"
mkdir -p "$RESTORE_DIR/backups/restore-backups"
tar -czf "$RESTORE_DIR/backups/restore-backups/pre-restore-$BACKUP_TIMESTAMP.tar.gz" \
    -C "$RESTORE_DIR" \
    config.json auth.json persist plugin-persist 2>/dev/null

# リストア実行
echo -e "${YELLOW}リストアを実行しています...${NC}"

# 設定ファイルのリストア
if [ -f "$BACKUP_DIR/config.json" ]; then
    cp -f "$BACKUP_DIR/config.json" "$RESTORE_DIR/"
    echo "  - config.json をリストアしました"
fi

if [ -f "$BACKUP_DIR/auth.json" ]; then
    cp -f "$BACKUP_DIR/auth.json" "$RESTORE_DIR/"
    echo "  - auth.json をリストアしました"
fi

# ディレクトリのリストア
if [ -d "$BACKUP_DIR/persist" ]; then
    rm -rf "$RESTORE_DIR/persist"
    cp -r "$BACKUP_DIR/persist" "$RESTORE_DIR/"
    echo "  - persist/ をリストアしました"
fi

if [ -d "$BACKUP_DIR/plugin-persist" ]; then
    rm -rf "$RESTORE_DIR/plugin-persist"
    cp -r "$BACKUP_DIR/plugin-persist" "$RESTORE_DIR/"
    echo "  - plugin-persist/ をリストアしました"
fi

# Homebridgeサービス起動
echo -e "${YELLOW}Homebridgeサービスを起動しています...${NC}"
cd /home/pi/docker-services/homebridge && docker-compose up -d

echo ""
echo -e "${GREEN}リストアが完了しました！${NC}"
echo -e "Homebridgeが起動するまで少々お待ちください..."
echo -e "Web UI: http://$(hostname -I | awk '{print $1}'):8581"
echo ""
echo -e "問題が発生した場合は、以下のファイルから復元できます:"
echo -e "  $RESTORE_DIR/backups/restore-backups/pre-restore-$BACKUP_TIMESTAMP.tar.gz"