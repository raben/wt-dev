class WtDev < Formula
  desc "Worktree x devcontainer parallel development environment"
  homepage "https://github.com/raben/wt-dev"
  head "https://github.com/raben/wt-dev.git", branch: "main"
  license "MIT"

  depends_on "jq"

  def install
    bin.install Dir["bin/*"]
  end

  test do
    system "#{bin}/wt-port-registry", "--help"
  end
end
