class GitGroup < Formula
  desc "Easily clone all the repositories from a group or organization"
  homepage "https://github.com/fopina/git-group"
  url "https://github.com/fopina/git-group/releases/download/v0.0.9/git-group_0.0.9_darwin_amd64.tar.gz"
  sha256 "6b52fb9c1e1198c41a96c8ee3b63f71f94d5645a37e36f97cf41967e0b2508e4"
  license "MIT"
  version "0.0.9"

  def install
    bin.install "git-group"
  end
  
  test do
    assert_match "0.0.9", shell_output("#{bin}/git-group -v 2>&1", 0)
  end
end
