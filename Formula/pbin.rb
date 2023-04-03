class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  url "https://github.com/fopina/privatebin/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "5ba5af3d0c8e70e3d42dc5d2f5af2ae3477a211161487e65d9034151849c6921"
  license "MIT"

  bottle do
    root_url "https://github.com/fopina/homebrew-tap/releases/download/pbin-1.0.0"
    sha256 cellar: :any_skip_relocation, monterey:     "a9c4986abb2d72fdadb47c7577fbb51fa7890d5f6873d0f82762ae51137d1432"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9ce79205fec2f2d9855513e27bc90c0438f04f2e5891dbbc2cb0a32dd53cfe02"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}")
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
    assert_match "https://privatebin.net/?", shell_output("echo test | #{bin}/pbin")
  end
end
