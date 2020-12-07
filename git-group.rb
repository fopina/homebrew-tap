class "GitGroup" < Formula
  desc "Easily clone all the repositories from a group or organization"
  homepage "https://github.com/fopina/git-group"
  url "https://github.com/fopina/git-group/releases/download/v0.0.9/git-group_0.0.9_darwin_amd64.tar.gz"
  sha256 "ad1fd312888df4a4a8b631ab304c3b15df9639cdb25958ea812c32c41fd243b3"
  license "https://github.com/fopina/git-group/releases/download/v0.0.9/git-group_0.0.9_darwin_amd64.tar.gz"
  version "0.0.9"

  def install
    bin.install "git-group"
  end
  
  test do
    assert_match "0.0.9", shell_output("#{bin}/git-group -v 2>&1", 0)
  end
end
