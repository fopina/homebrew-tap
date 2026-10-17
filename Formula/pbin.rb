class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  version "1.0.3"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.3/pbin_darwin_amd64.tar.gz"
    sha256 "132b9c06ac42e971ed5b14e265cd278ce4dc67812b761cc8db95fc4f594b9e42"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.3/pbin_darwin_arm64.tar.gz"
    sha256 "b912957b3cecf0a26a4be0a8765c21e213cc292ab9bbd1e17a9ff7391d0afe2d"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.3/pbin_linux_amd64.tar.gz"
    sha256 "d93dd097aca77a951db9ad92ea2f7051f4476b69446e327ac350c3535e5e851e"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.3/pbin_linux_arm64.tar.gz"
    sha256 "0632394d385f8a54d7ea8a36c05403f4aae456ef6809f582b79e676011ade1ce"
  end

  def install
    bin.install "pbin"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
    assert_match "https://privatebin.net/?", shell_output("echo test | #{bin}/pbin")
  end
end
