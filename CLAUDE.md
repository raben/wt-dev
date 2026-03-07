# dev-worktree — CLAUDE.md

## 概要
git worktree + devcontainer + AI CLI で、ブランチごとの独立開発環境をワンコマンドで立ち上げる CLI ツール。
単一 Bash スクリプト（`bin/dev`）で完結。

## 開発ルール
- 変更後は `bash -n bin/dev` で構文チェック必須
- リリースは `/release` スキルで実行（e2e テスト → VERSION bump → tag → push → Homebrew tap 更新）
- スキル一覧は `.claude/commands/` を参照

## コミュニケーション
- 日本語で回答
- 簡潔に
