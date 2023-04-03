class GitGroup < Formula
  desc "Easily clone all the repositories from a group or organization"
  homepage "https://github.com/fopina/git-group"
  url "https://github.com/fopina/git-group/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a858d0c2a1308ff58acc730e6ff75ff18226640d8a9b3060970dd2420633f550"
  license "MIT"

  bottle do
    root_url "https://github.com/fopina/homebrew-tap/releases/download/git-group-0.1.0"
    sha256 cellar: :any_skip_relocation, monterey:     "c44737ce2ba013eb7a330609f3f175b994bf3b0c79828be550cb91b45764e778"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "93249822f5a33f731fa5e78be64d7489fda9afa54260f70a3df9c47b64cbe009"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/fopina/git-group/command.version=#{version}")
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/git-group -v 2>&1")
  end
end
