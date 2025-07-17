# Homebridge Docker Service

HomebridgeをDockerで運用するための設定とバックアップスクリプトです。

## バックアップとリストア

### 自動バックアップ
Synology NASへの自動バックアップが設定されています。

#### バックアップ対象
- `config.json` - Homebridgeの設定ファイル
- `auth.json` - 認証情報
- `persist/` - デバイス情報
- `plugin-persist/` - プラグイン設定
- 最新のインスタンスバックアップ（.tar.gz）

#### バックアップ先
- マウントポイント: `/mnt/synology-backup`
- バックアップディレクトリ: `/mnt/synology-backup/homebridge/`

### 手動バックアップ
```bash
sudo ./backup-synology.sh
```

### リストア
```bash
sudo ./restore-from-synology.sh
```
リストア実行時は、現在の設定が自動的にバックアップされます。

### バックアップログ
バックアップの実行履歴は以下で確認できます：
```bash
tail -f /mnt/synology-backup/homebridge/backup.log
```

### cron設定（推奨）
毎日午前3時に自動バックアップを実行する場合：
```bash
sudo crontab -e
```
以下を追加：
```
0 3 * * * /home/pi/docker-services/homebridge/backup-synology.sh
```