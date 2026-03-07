dev-worktree の e2e テスト。テスト用 git リポを作成し、dev up/list/open/down/prune を順次実行して検証する。

## 実行方法

各テストを順番に実行し、成功/失敗を記録する。失敗時は即座に報告してクリーンアップに進む。
最後にサマリーを出力する。

## 前提条件チェック

以下を確認し、満たさない場合は中止：
1. Docker Desktop が起動しているか（`docker info` が成功するか）
2. `dev --version` が動作するか（PATH にあるか）
3. `devcontainer --version` が動作するか

## テスト環境セットアップ

`/tmp/dev-worktree-test` にテスト用 git リポを作成する：

```bash
rm -rf /tmp/dev-worktree-test
mkdir -p /tmp/dev-worktree-test
cd /tmp/dev-worktree-test
git init
git commit --allow-empty -m "initial"
mkdir -p .devcontainer
```

`.devcontainer/devcontainer.json` を作成（最小構成）：
```json
{
  "name": "dev-worktree-test",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "workspaceFolder": "/workspace"
}
```

`.devcontainer/.env.example` を作成：
```
WT_NAME=dev-worktree-test
COMPOSE_PROJECT_NAME=dev-worktree-test
WT_EXEC_CMD=echo ok
WT_APP_PORT=13100
```

作成したファイルをコミット：
```bash
git add -A
git commit -m "add devcontainer"
```

## テスト 1: dev up（新規ブランチ）

1. 実行: `cd /tmp/dev-worktree-test && dev up test-new-branch`
2. 検証:
   - exit code が 0
   - コンテナが起動している（`docker ps --filter "label=dev-worktree=dev-worktree-test/test-new-branch" --filter "status=running" -q` が非空）
   - `.devcontainer/.env` がワークツリー側に存在し、ポートが割り当てられている

## テスト 2: dev up（既存ブランチ）

v0.9.2 で発生したバグの再発防止。既存ブランチに対して `-b` なしで worktree add されるか。

1. 準備: `git -C /tmp/dev-worktree-test branch test-existing`
2. 実行: `cd /tmp/dev-worktree-test && dev up test-existing`
3. 検証:
   - exit code が 0
   - コンテナが起動している

## テスト 3: dev up（保護ブランチ: main）

main を指定すると自動でブランチが作成されることを検証。

1. 実行: `cd /tmp/dev-worktree-test && dev up main`
2. 検証:
   - exit code が 0
   - 出力に "Protected branch 'main'" が含まれる
   - `dev-main` ブランチのコンテナが起動している（`docker ps --filter "label=dev-worktree=dev-worktree-test/dev-main" --filter "status=running" -q` が非空）

## テスト 4: dev list

1. 実行: `dev list`
2. 検証:
   - exit code が 0
   - 出力に `dev-worktree-test/test-new-branch` が含まれる
   - 出力に `dev-worktree-test/test-existing` が含まれる

## テスト 5: dev open（名前指定）

v0.9.4 で発生したバグの再発防止。`--id-label` が正しく渡されているか。

1. 実行: `cd /tmp/dev-worktree-test && dev open test-new-branch`
2. 検証:
   - exit code が 0（WT_EXEC_CMD=echo ok なのですぐ返る）

## テスト 6: dev open（引数なし・複数コンテナ）

複数コンテナが存在する状態なのでインタラクティブ選択になる。
非インタラクティブ環境では stdin が閉じているため選択できない → これは想定通り。
**このテストはスキップする**（テスト5で open の動作は検証済み）。

## テスト 7: dev down

1. 実行: `cd /tmp/dev-worktree-test && dev down test-new-branch`
2. 検証:
   - exit code が 0
   - コンテナが停止している（running でない）

## テスト 8: dev prune

1. まず test-existing を prune: `cd /tmp/dev-worktree-test && dev prune test-existing --force`
2. 検証:
   - exit code が 0
   - コンテナが削除されている
   - ワークツリーディレクトリが存在しない
3. 次に test-new-branch を prune: `cd /tmp/dev-worktree-test && dev prune test-new-branch --force`
4. 検証: 同上
5. テスト 3 で作成された dev-main を prune: `cd /tmp/dev-worktree-test && dev prune dev-main --force`
6. 検証: 同上

## クリーンアップ

```bash
# 残ったコンテナを強制削除
docker ps -a --filter "label=dev-worktree" --format '{{.Label "dev-worktree"}}' | grep "^dev-worktree-test/" | while read key; do
  docker ps -a --filter "label=dev-worktree=$key" -q | xargs -r docker rm -f
done

# テストリポとワークツリーを削除
rm -rf /tmp/dev-worktree-test
rm -rf /tmp/dev-worktree-test-*

# git worktree の残骸をクリーン
cd /tmp/dev-worktree-test 2>/dev/null && git worktree prune 2>/dev/null || true
```

## サマリー出力

全テスト完了後、以下の形式でサマリーを出力：

```
=== dev-worktree e2e test results ===
Test 1 (dev up - new branch):       PASS/FAIL
Test 2 (dev up - existing branch):  PASS/FAIL
Test 3 (dev up - protected branch): PASS/FAIL
Test 4 (dev list):                  PASS/FAIL
Test 5 (dev open):                  PASS/FAIL
Test 7 (dev down):                  PASS/FAIL
Test 8 (dev prune):                 PASS/FAIL
=====================================
```

失敗したテストがある場合は、エラー内容と再現手順を付記する。
