/* ============================================================
   Supabase 接続設定
   Supabase ダッシュボード > Project Settings > Data API から
   「Project URL」と「anon public」キーをコピーして貼り付けてください。
   ※ anonキーはブラウザに配られる公開用のキーです。
      安全性は schema.sql の RLS（ログイン必須）で担保しています。
   ============================================================ */
const SUPABASE_URL     = "https://xxxxxxxxxxxxxxxx.supabase.co";
const SUPABASE_ANON_KEY = "ここに anon public キーを貼り付け";
