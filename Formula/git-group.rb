class GitGroup < Formula
  desc "Easily clone all the repositories from a group or organization"
  homepage "https://github.com/fopina/git-group"
  url "https://github.com/fopina/git-group/archive/refs/tags/v0.0.9.tar.gz"
  sha256 "f0ecbf813752be28a990d273c208335d02543fbcca3ff671f89fdba9099dd5bb"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/fopina/git-group/command.version=#{version}")
  end

  test do
    assert_match "0.0.9", shell_output("#{bin}/git-group -v 2>&1")
  end
end
