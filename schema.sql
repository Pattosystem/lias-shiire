-- ============================================================
--  LIAS 仕入管理システム / Supabase スキーマ
--  Supabase ダッシュボード > SQL Editor に貼り付けて実行してください。
-- ============================================================

-- ------------------------------------------------------------
-- 1. 受注データ（BカートCSVから取り込む商品明細）
-- ------------------------------------------------------------
create table if not exists orders (
  id          bigserial primary key,
  order_no    text        not null,           -- 受注番号
  order_date  date        not null,           -- 受注日
  clinic      text,                           -- 会社名（クリニック）
  code        text        default '',         -- 品番
  name        text        not null,           -- 商品名
  spec        text        default '',         -- 製品規格
  qty         integer     not null,           -- 受注数
  price       integer     not null,           -- 受注単価（売価）
  pkey        text        not null,           -- 名寄せキー（品番優先）
  imported_at timestamptz default now()
);
create index if not exists orders_date_idx on orders (order_date);
create index if not exists orders_pkey_idx on orders (pkey);

-- ------------------------------------------------------------
-- 2. 分類（自分で作る分類名）
-- ------------------------------------------------------------
create table if not exists categories (
  name       text primary key,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 3. 商品への分類の割り当て
-- ------------------------------------------------------------
create table if not exists product_categories (
  pkey       text primary key,
  category   text,
  updated_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 4. 仕入先（通貨つき）
-- ------------------------------------------------------------
create table if not exists suppliers (
  name       text primary key,
  currency   text not null default 'JPY',     -- JPY / USD / EUR / GBP / KRW
  sort       integer default 0,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 5. 為替レート（手動入力：1通貨あたりの円）
-- ------------------------------------------------------------
create table if not exists fx_rates (
  currency   text primary key,
  rate       numeric not null,
  updated_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 6. 仕入先ごとの商品価格（各仕入先の通貨で保持）
-- ------------------------------------------------------------
create table if not exists supplier_prices (
  pkey       text    not null,
  supplier   text    not null references suppliers(name) on update cascade on delete cascade,
  price      numeric not null,
  updated_at timestamptz default now(),
  primary key (pkey, supplier)
);
create index if not exists supplier_prices_pkey_idx on supplier_prices (pkey);

-- ============================================================
--  RLS（行レベルセキュリティ）
--
--  ★ 現在の設定：ログインなしで読み書きできる状態です。
--    URLとanonキー（ブラウザのソースに出ます）を知っている人は
--    誰でもデータを読める、という点だけ理解して使ってください。
--
--  ★ あとでログイン必須に戻したい場合：
--    下の `to anon, authenticated` を `to authenticated` に変えて
--    もう一度実行し、index.html のログイン処理を戻すだけです。
-- ============================================================
alter table orders             enable row level security;
alter table categories         enable row level security;
alter table product_categories enable row level security;
alter table suppliers          enable row level security;
alter table fx_rates           enable row level security;
alter table supplier_prices    enable row level security;

do $$
declare t text;
begin
  foreach t in array array['orders','categories','product_categories','suppliers','fx_rates','supplier_prices']
  loop
    execute format('drop policy if exists "authenticated_all" on %I', t);
    execute format('drop policy if exists "public_all" on %I', t);
    execute format(
      'create policy "public_all" on %I
         for all
         to anon, authenticated
         using (true)
         with check (true)', t);
  end loop;
end $$;
