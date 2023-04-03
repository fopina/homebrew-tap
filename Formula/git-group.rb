class GitGroup < Formula
  desc "Easily clone Xall the repositories from a group or organization"
  homepage "https://github.com/fopina/git-group"
  url "https://github.com/fopina/git-group/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a858d0c2a1308ff58acc730e6ff75ff18226640d8a9b3060970dd2420633f550"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/fopina/git-group/command.version=#{version}")
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/git-group -v 2>&1")
  end
end
