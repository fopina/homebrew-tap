class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  url "https://github.com/fopina/privatebin/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "5ba5af3d0c8e70e3d42dc5d2f5af2ae3477a211161487e65d9034151849c6921"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}")
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
    assert_match "https://privatebin.net/?", shell_output("echo test | #{bin}/pbin")
  end
end
