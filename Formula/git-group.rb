class GitGroup < Formula
  desc "Easily clone all the repositories from a group or organization"
  homepage "https://github.com/fopina/git-group"
  url "https://github.com/fopina/git-group/releases/download/v0.0.9/git-group_0.0.9_darwin_amd64.tar.gz"
  sha256 "7c62077f52b201b0c493d19dc90344712702caf3e5bb427a0c3b02c6dce52499"
  license "https://github.com/fopina/git-group/releases/download/v0.0.9/git-group_0.0.9_darwin_amd64.tar.gz"
  version "0.0.9"

  def install
    bin.install "git-group"
  end
  
  test do
    assert_match "0.0.9", shell_output("#{bin}/git-group -v 2>&1", 0)
  end
end
