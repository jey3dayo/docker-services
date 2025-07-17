# FreshRSS Docker Setup

FreshRSSとRSS-Bridgeを使用したRSSリーダー環境です。

## 構成

- **FreshRSS**: セルフホスト型RSSリーダー
- **RSS-Bridge**: 様々なサイトからRSSフィードを生成

## アクセス方法

### ローカルアクセス
- FreshRSS: `http://raspberrypi:8080`
- RSS-Bridge: `http://raspberrypi:8081`

### 外部アクセス（ポートフォワーディング設定済み）
- ルーターでポート8080, 8081をフォワーディング設定
- グローバルIPまたはDynamicDNSでアクセス

## バックアップ

### バックアップ構成
- **バックアップ先**: Synology NAS (`//jey3dayo.synology.me/storage/backup`)
- **マウントポイント**: `/mnt/synology-backup/`
- **バックアップフォルダ**: `/mnt/synology-backup/fresh-rss/`
- **方式**: rsyncによる差分バックアップ（SDカード書き込み最小化）

### 自動バックアップ
- 毎日午前3時に自動実行（crontab設定済み）
- ログファイルで実行状況を記録

### 手動バックアップ
```bash
# バックアップ実行
sudo /home/pi/docker-services/fresh-rss/backup-synology.sh
```

### リストア手順
```bash
# データをSynology NASから復元
/home/pi/docker-services/fresh-rss/restore-from-synology.sh
```
※ 実行前に現在のデータは完全に置き換えられます

### バックアップ状況確認
```bash
# バックアップファイル確認
ls -la /mnt/synology-backup/fresh-rss/

# 最新のバックアップ時刻確認
stat /mnt/synology-backup/fresh-rss/backup.log | grep Modify

# ログ確認（最新10件）
tail -10 /mnt/synology-backup/fresh-rss/backup.log

# リアルタイムログ監視
tail -f /mnt/synology-backup/fresh-rss/backup.log
```

### バックアップ対象
- ユーザーデータ（`users/`）
- 設定ファイル（`config.php`）
- データベース（`db.sqlite`）
- フィードアイコン（`favicons/`）
- 拡張機能データ（`extensions-data/`）

### バックアップ除外項目
- キャッシュファイル（`cache/*.spc`）
- ログファイル（`*.log`）

## Docker操作

### サービス起動
```bash
docker-compose up -d
```

### サービス停止
```bash
docker-compose down
```

### ログ確認
```bash
docker-compose logs -f
```

### 再起動
```bash
docker-compose restart
```

## 設定ファイル

- `docker-compose.yml`: Docker構成
- `.smbcredentials`: SMB認証情報（要権限設定）
- `backup-synology.sh`: バックアップスクリプト
- `restore-from-synology.sh`: リストアスクリプト

## トラブルシューティング

### SMBマウントエラーの場合
```bash
# 手動マウント
sudo mount -t cifs //jey3dayo.synology.me/storage/backup /mnt/synology-backup -o credentials=/home/pi/.smbcredentials,iocharset=utf8,file_mode=0755,dir_mode=0755,vers=2.0

# マウント状態確認
mountpoint /mnt/synology-backup

# 現在のマウント確認
mount | grep synology
```

### FreshRSSが起動しない場合
```bash
# コンテナの状態確認
docker-compose ps

# エラーログ確認
docker-compose logs freshrss
```

## メンテナンス

### アップデート
```bash
# 最新イメージ取得
docker-compose pull

# 再起動
docker-compose up -d
```

### キャッシュクリア
FreshRSSの管理画面から実行、または：
```bash
rm -rf freshrss/data/cache/*.spc
```

## セキュリティ

- FreshRSSは内蔵の認証機能でアクセス制御
- 強力なパスワードを設定すること
- 定期的なアップデートを推奨