# FreshRSS 拡張機能管理ガイド

## 導入済み拡張機能

### 1. ThreePanesView
- **説明**: Inoreader風の3ペインUIレイアウト
- **タイプ**: User
- **設定**: 管理画面から有効化後、個人設定で調整可能

### 2. Af_Readability
- **説明**: 記事本文の全文取得機能
- **タイプ**: System
- **設定**: 
  - 管理者権限で有効化
  - 必要に応じてReadability APIキーを設定

### 3. ArticleSummary
- **説明**: AI/LLMを使用した記事要約機能
- **タイプ**: User
- **設定**:
  - OpenAI APIキーまたは他のLLM APIキーが必要
  - 要約の長さや言語設定が可能

### 4. WordHighlighter
- **説明**: 重要キーワードのハイライト表示
- **タイプ**: User
- **設定**:
  - ハイライトしたいキーワードをカンマ区切りで入力
  - ハイライト色のカスタマイズ可能

### 5. PocketButton
- **説明**: Pocketへの記事保存ボタン
- **タイプ**: User
- **設定**:
  - Pocketアカウントとの連携が必要
  - 認証トークンを設定

## 拡張機能の有効化手順

1. FreshRSS管理画面にアクセス（http://localhost:8080）
2. 管理者アカウントでログイン
3. メニューから「拡張機能」を選択
4. 各拡張機能の「有効化」ボタンをクリック
5. 歯車アイコンから個別設定を行う

## 新しい拡張機能の追加方法

```bash
# 1. 拡張機能ディレクトリに移動
cd /home/pi/docker-services/fresh-rss/freshrss/data/extensions

# 2. 拡張機能をクローン
git clone https://github.com/[user]/[extension-name]

# 3. コンテナを再起動
cd /home/pi/docker-services/fresh-rss
docker-compose restart freshrss
```

## 拡張機能の削除方法

```bash
# 1. 拡張機能ディレクトリから削除
cd /home/pi/docker-services/fresh-rss/freshrss/data/extensions
rm -rf [extension-name]

# 2. コンテナを再起動
cd /home/pi/docker-services/fresh-rss
docker-compose restart freshrss
```

## トラブルシューティング

### 拡張機能が表示されない場合
1. ディレクトリ権限を確認：
   ```bash
   ls -la freshrss/data/extensions/
   ```
2. metadata.jsonファイルが存在するか確認
3. docker-compose.ymlのボリュームマウントを確認

### 拡張機能が動作しない場合
1. FreshRSSのログを確認：
   ```bash
   docker-compose logs freshrss
   ```
2. ブラウザの開発者ツールでJavaScriptエラーを確認
3. 拡張機能の互換性（FreshRSSバージョン）を確認

## 推奨される追加拡張機能

- **CustomCSS**: UIのカスタマイズ
- **AutoTTL**: フィードごとの更新間隔自動調整
- **ImageProxy**: 画像のプロキシ経由読み込み（プライバシー保護）
- **MarkPreviousAsRead**: 既読記事の一括処理

## バックアップと復元

拡張機能の設定は`freshrss/data/extensions-data/`に保存されます。
バックアップ時はこのディレクトリも含めることを推奨します。

```bash
# バックアップ
tar -czf freshrss-extensions-backup.tar.gz freshrss/data/extensions freshrss/data/extensions-data

# 復元
tar -xzf freshrss-extensions-backup.tar.gz
```