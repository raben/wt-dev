dev-worktree のリリースフロー。VERSION bump → tag → push → Homebrew tap 更新まで実行。

## 引数
- `$ARGUMENTS`: バージョン番号（例: `0.9.4`）。省略時は現在の VERSION をパッチバンプ。

## リポジトリ情報
- メインリポ: `/Users/rabe/Workspaces/autor/dev-worktree`
- Homebrew tap: `/tmp/homebrew-dev-worktree`
- tap が存在しない場合: `git clone https://github.com/raben/homebrew-dev-worktree.git /tmp/homebrew-dev-worktree`

## フロー

### Step 1: バージョン決定
1. `$ARGUMENTS` があればそれを使用
2. なければ `bin/dev` の `VERSION="X.Y.Z"` を読み取り、パッチ番号を +1

### Step 2: 構文チェック & e2e テスト
1. `bash -n bin/dev` で構文エラーがないか確認
2. エラーがあれば中止
3. `/test` を実行（テスト失敗時はリリース中止）

### Step 3: VERSION 更新 & コミット
1. `bin/dev` の `VERSION="..."` を新バージョンに更新
2. `git add bin/dev` + 未コミットの変更があれば一緒にステージ
3. コミット（メッセージ例: `chore: bump VERSION to X.Y.Z`）

### Step 4: タグ & プッシュ
1. `git tag vX.Y.Z`
2. `git push origin main --tags`

### Step 5: SHA256 取得
1. `curl -sL https://github.com/raben/dev-worktree/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256`
2. SHA を記録

### Step 6: Formula 更新（メインリポ）
1. `Formula/dev-worktree.rb` の `url` と `sha256` を更新

### Step 7: Homebrew tap 更新
1. tap リポが `/tmp/homebrew-dev-worktree` に存在するか確認。なければ clone
2. `Formula/dev-worktree.rb` の `url` と `sha256` を更新
3. `git add && git commit -m "bump to vX.Y.Z" && git push origin main`

### Step 8: メインリポの Formula コミット
1. `git add Formula/dev-worktree.rb && git commit -m "chore: bump Formula to vX.Y.Z" && git push origin main`

### Step 9: 確認
1. リリース完了を報告
2. `brew upgrade dev-worktree` は `/brew-upgrade` で実行できることを案内

## 注意
- CWD が `/tmp/homebrew-dev-worktree` にリセットされることがある。コマンドは絶対パスか `cd` で対応
- タグの force-update は避ける（SHA 不一致の原因になる）
- VERSION の更新忘れに注意（過去に何度もハマった）
