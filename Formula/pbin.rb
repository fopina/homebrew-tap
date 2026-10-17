class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.6/pbin_darwin_amd64.tar.gz"
    sha256 "26f30cb12e80e34e22069bf53f8e674c5070b77817b993628218c583681913a1"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.6/pbin_darwin_arm64.tar.gz"
    sha256 "49d867650c794778d7284891ee77dee5a26e02a20e4e803c9a0d98a59fba221d"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.6/pbin_linux_amd64.tar.gz"
    sha256 "bf4ca090869574457ce950890e63588903ca8e8e975970a56fd4c83508e8b96e"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.6/pbin_linux_arm64.tar.gz"
    sha256 "5955f172206af54dd550160164a469daa6b9d9dfd79f0b7f00d95ede72084a31"
  end

  def install
    bin.install "pbin"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
  end
end
