class GitGroup < Formula
  desc "Easily clone all the repositories from a group or organization"
  homepage "https://github.com/fopina/git-group/"
  url "https://github.com/fopina/git-group/releases/download/v0.0.8/git-group_0.0.8_darwin_amd64.tar.gz"
  sha256 "64ab5fcea620d445c3ed4ee3c179bac29567ca4712ddb9c443196d0074c26ef1"
  license "MIT"

  def install
    bin.install "git-group"
  end
  
  test do
    assert_match "0.0.8", shell_output("#{bin}/git-group -v 2>&1", 0)
  end
end
