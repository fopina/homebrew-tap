class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.1.0/pbin_darwin_amd64.tar.gz"
    sha256 "dc770d277e0ad5511c405559aaee852251788738e3d932d600ab642c4df89c1a"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.1.0/pbin_darwin_arm64.tar.gz"
    sha256 "1b4311c356c33f429e8360e8f2a8e5b16ccce7fb84e388fce4d59a8440b66664"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.1.0/pbin_linux_amd64.tar.gz"
    sha256 "c871e1650f58b04f4e6a13ac274af21ed42cc898feb825b35a24dc31f2fb0115"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.1.0/pbin_linux_arm64.tar.gz"
    sha256 "454a9c85d470b3cc16eabd37c9451e0dc7c2e47b72963d20c61fc460cac1d308"
  end

  def install
    bin.install "pbin"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
  end
end
