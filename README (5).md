# LIAS 10日ごと 仕入インデックス

BカートのCSVから、**10日ごと（上旬・中旬・下旬）に仕入れが必要な個数**を集計するシステム。
商品を独自の分類でグルーピングし、仕入先ごとの価格を各通貨で入力して**円換算で最安を比較**できます。

構成：GitHub Pages（静的ホスティング）＋ Supabase（DB）
ログインなしで、URLを開いたらすぐ使えます。

---

## セットアップ手順

### 1. Supabase プロジェクトを作る

1. [supabase.com](https://supabase.com) でプロジェクトを新規作成
2. 左メニュー **SQL Editor** → `schema.sql` の中身を全部貼り付けて **Run**
   - テーブル6つとRLS（ログイン必須の設定）が一度に作られます

### 2. 接続情報を設定する

1. 左メニュー **Project Settings → Data API**
2. **Project URL** と **anon public** キーをコピー
3. `config.js` を開いて貼り付け

```js
const SUPABASE_URL      = "https://あなたのID.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGci...";
```

### 3. GitHub Pages に上げる

```bash
git init
git add .
git commit -m "初回コミット"
git branch -M main
git remote add origin https://github.com/ユーザー名/lias-shiire.git
git push -u origin main
```

GitHubのリポジトリ → **Settings → Pages** →
Source を **Deploy from a branch**、Branch を **main / (root)** にして保存。

数分で `https://ユーザー名.github.io/lias-shiire/` で開けます。

### 4. 使い始める

1. URLを開く（ログインなしでそのまま使えます）
2. 左下 **CSV読込** からBカートの受注CSVを取り込む
3. **商品分類**タブで分類名を作り、商品に割り当てる
4. **仕入先価格**タブで仕入先（通貨つき）を登録し、為替レートと価格を入力

---

## 運用のしかた

### CSVの取り込み

Bカートから受注CSVをダウンロードして読み込むだけです。

**取り込みは「CSVに含まれる期間」を丸ごと置き換えます。**
たとえば 7/1〜7/21 のCSVを読むと、その期間の既存データが消えて新しい内容に入れ替わります。
同じCSVを何度読み込んでも二重にならないので、**受注が増えたら同じ期間のCSVを取り直して読み込めばOK**です。
別の月のデータはそのまま残ります。

- 文字コードはShift-JIS（Bカートの標準）とUTF-8のどちらでも自動判定
- 送料・値引き行は自動で除外されます

### 仕入期の区切り

受注日ベースで、上旬（1〜10日）・中旬（11〜20日）・下旬（21日〜末日）に自動で分かれます。

### 商品の名寄せ

**品番が同じものは同じ商品**として合算します（規格の表記ゆれで二重に出るのを防ぐため）。
品番が空の商品は「商品名＋規格」から空白を除いて突き合わせます。

### 分類・価格のデータ

すべてSupabaseに保存されるので、**別のPCやスマホから開いても同じ内容**が見えます。
変更すると右下に「保存中…」と出て、自動で反映されます。

---

## セキュリティについて（ここだけ目を通してください）

いまの設定は **ログインなし＝URLを知っている人は誰でも読み書きできる状態** です。

- `config.js` の anonキーはブラウザのソースに出るため、隠すことはできません。
- つまり、このページのURLがわかれば、取引クリニック名・受注数量・仕入先価格を
  第三者が取得できます。**URLを社外に出さない運用が前提**になります。
- リポジトリを Private にしても、GitHub Pages で公開したURL自体は誰でも開けます。

### あとでログインを付けたくなったら

1. `schema.sql` の RLS部分で `to anon, authenticated` を `to authenticated` に変えて実行
2. Supabase の **Authentication → Users** でユーザーを追加
3. ログイン画面を戻す（相談してもらえれば対応します）

社員が増えたり、社外の人にURLが渡る可能性が出てきたタイミングで
切り替えるのがおすすめです。

---

## ファイル構成

```
lias-shiire/
├─ index.html    アプリ本体（画面・集計ロジック・Supabase連携）
├─ config.js     Supabaseの接続情報（各自で書き換え）
├─ schema.sql    Supabaseのテーブル定義とRLS
└─ README.md     この説明
```

## テーブル

| テーブル | 中身 |
|---|---|
| `orders` | 受注明細（CSVから取り込み） |
| `categories` | 自分で作った分類名 |
| `product_categories` | 商品への分類の割り当て |
| `suppliers` | 仕入先と通貨 |
| `fx_rates` | 為替レート（手動入力） |
| `supplier_prices` | 仕入先ごとの商品価格 |
