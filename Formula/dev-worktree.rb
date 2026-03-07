class DevWorktree < Formula
  desc "Isolated parallel development environments with worktree + devcontainer"
  homepage "https://github.com/raben/dev-worktree"
  url "https://github.com/raben/dev-worktree/archive/refs/tags/v0.9.4.tar.gz"
  sha256 "827f2f7c0697cd9267e213c3a2381bdecfd7902995793db2ffd10ab4a96e2871"
  license "MIT"
  head "https://github.com/raben/dev-worktree.git", branch: "main"

  depends_on "jq"

  def install
    bin.install Dir["bin/*"]
  end

  test do
    system "#{bin}/dev", "--version"
  end
end
