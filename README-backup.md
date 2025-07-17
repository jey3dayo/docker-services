# Docker Services バックアップ設定

Raspberry Pi上で動作する各種Dockerサービスの設定とバックアップ管理

## サービス一覧

### FreshRSS
セルフホスト型RSSリーダーサービス
- ポート: 8080
- データ: `/home/pi/docker-services/fresh-rss/freshrss/data/`

### Homebridge
HomeKit互換のスマートホームブリッジ
- ポート: 8581 (Web UI)
- 設定: `/home/pi/docker-services/homebridge/volumes/homebridge/`

### AirConnect
AirPlayデバイスをChromecast/UPnP/Sonosに接続するブリッジ
- ネットワーク: host mode
- 機能: AirPlayストリーミングを他のプロトコルに変換

### Portainer
Dockerコンテナ管理用Web UI
- ポート: 9000
- データ: Dockerボリューム（portainer_data）

### My Bolt App (Slack Bot - TypeScript)
TypeScriptで開発されたSlack Botアプリケーション
- 機能: キーワードリアクション、DM自動返信、画像生成

### My LLM Bot (Slack Bot - Python)
Pythonで開発されたLLM活用Slack Bot
- 機能: 特定キーワードへの自動リアクション、AI返答、画像生成（複数枚対応）

## バックアップ設定

### 共通設定
- バックアップ先: Synology NAS (`//jey3dayo.synology.me/storage/backup`)
- マウントポイント: `/mnt/synology-backup`
- 認証情報: `/home/pi/.smbcredentials`

### 自動バックアップスケジュール
```
0 3 * * *   - FreshRSS (毎日午前3時)
30 3 * * *  - Homebridge (毎日午前3時30分)
```

### 手動バックアップ
```bash
# FreshRSS
sudo /home/pi/docker-services/fresh-rss/backup-synology.sh

# Homebridge
sudo /home/pi/docker-services/homebridge/backup-synology.sh
```

### リストア
```bash
# FreshRSS
/home/pi/docker-services/fresh-rss/restore-from-synology.sh

# Homebridge
/home/pi/docker-services/homebridge/restore-from-synology.sh
```

### バックアップ内容確認
```bash
# バックアップディレクトリを確認
ls -la /mnt/synology-backup/

# FreshRSSのバックアップ
ls -la /mnt/synology-backup/fresh-rss/

# Homebridgeのバックアップ
ls -la /mnt/synology-backup/homebridge/
```

## ディレクトリ構造

```
/mnt/synology-backup/
├── fresh-rss/
│   ├── data/           # FreshRSSのデータファイル
│   └── backup.log      # バックアップログ
└── homebridge/
    ├── config.json     # Homebridge設定
    ├── auth.json       # 認証情報
    ├── persist/        # デバイス情報
    ├── plugin-persist/ # プラグイン設定
    ├── instance-backups/ # 自動バックアップファイル
    └── backup.log      # バックアップログ

/home/pi/docker-services/
├── fresh-rss/          # RSSリーダー（バックアップ対応）
├── homebridge/         # HomeKitブリッジ（バックアップ対応）
├── airconnect/         # AirPlayブリッジ
├── portainer/          # Docker管理UI
├── my-bolt-app/        # Slack Bot (TypeScript)
└── my-llm-bot/         # Slack Bot (Python)
```

## トラブルシューティング

### SMBマウントエラー
```bash
# 手動マウント
sudo mount -t cifs //jey3dayo.synology.me/storage/backup /mnt/synology-backup -o credentials=/home/pi/.smbcredentials,iocharset=utf8,file_mode=0755,dir_mode=0755,vers=2.0

# マウント確認
mountpoint -q /mnt/synology-backup && echo "マウント済み" || echo "マウントされていません"
```

### バックアップログ確認
```bash
# FreshRSS
tail -20 /mnt/synology-backup/fresh-rss/backup.log

# Homebridge
tail -20 /mnt/synology-backup/homebridge/backup.log
```