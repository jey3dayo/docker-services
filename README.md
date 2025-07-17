# Docker Services for Raspberry Pi

Raspberry Pi向けに用意したDockerサービス群です。各種サービスをDocker Composeで簡単に起動・管理できます。

## サービス一覧

### FreshRSS
セルフホスト型RSSリーダーサービス
- **ポート**: 8080
- **機能**: RSSフィードの購読・管理
- **データ保存先**: `./fresh-rss/freshrss/data/`
- **バックアップ**: Synology NASへの自動バックアップ対応

### Homebridge
HomeKit互換のスマートホームブリッジ
- **ポート**: 8581 (Web UI)
- **機能**: HomeKit非対応デバイスをApple HomeKitに接続
- **設定保存先**: `./homebridge/volumes/homebridge/`
- **バックアップ**: Synology NASへの自動バックアップ対応

### AirConnect
AirPlayデバイスをChromecast/UPnP/Sonosに接続するブリッジ
- **ネットワーク**: host mode
- **機能**: AirPlayストリーミングを他のプロトコルに変換
- **イメージ**: 1activegeek/airconnect:latest

### Portainer
Dockerコンテナ管理用Web UI
- **ポート**: 9000
- **機能**: Dockerコンテナ、イメージ、ボリューム、ネットワークの管理
- **データ保存先**: portainer_dataボリューム

### My Bolt App (Slack Bot - TypeScript)
TypeScriptで開発されたSlack Botアプリケーション
- **機能**:
  - キーワードに反応してリアクションを付与
  - ダイレクトメッセージへの自動返信
  - `/imagine`コマンドによる画像生成
- **技術スタック**: Node.js 20.x, TypeScript, @slack/bolt, OpenAI API

### My LLM Bot (Slack Bot - Python)
Pythonで開発されたLLM活用Slack Bot
- **機能**:
  - 特定キーワード（懇親会、飲み会等）への自動リアクション
  - DMへのAI返答
  - `/imagine`コマンドによる画像生成（複数枚対応）
- **技術スタック**: Python, Poetry, OpenAI API

## クイックスタート

各サービスディレクトリに移動して、以下のコマンドを実行:

```bash
docker-compose up -d
```

## バックアップ管理

FreshRSSとHomebridgeは、Synology NASへの自動バックアップをサポートしています。

### バックアップ設定
- **バックアップ先**: `//jey3dayo.synology.me/storage/backup`
- **マウントポイント**: `/mnt/synology-backup`
- **認証情報**: `/home/pi/.smbcredentials`

### 自動バックアップスケジュール（cron）
```
0 3 * * *   - FreshRSS (毎日午前3時)
30 3 * * *  - Homebridge (毎日午前3時30分)
```

詳細なバックアップ手順は[README-backup.md](./README-backup.md)を参照してください。

## ディレクトリ構造

```
/home/pi/docker-services/
├── fresh-rss/          # RSSリーダー
├── homebridge/         # HomeKitブリッジ
├── airconnect/         # AirPlayブリッジ
├── portainer/          # Docker管理UI
├── my-bolt-app/        # Slack Bot (TypeScript)
├── my-llm-bot/         # Slack Bot (Python)
└── README-backup.md    # バックアップ詳細ドキュメント
```

## 注意事項

- 各サービスの詳細な設定方法は、それぞれのディレクトリ内のREADMEファイルを参照してください
- ポート番号が競合しないよう注意してください
- Raspberry Piのリソースを考慮して、必要なサービスのみを起動することを推奨します
