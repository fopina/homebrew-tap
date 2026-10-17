class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  version "1.0.0"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.0/pbin_darwin_amd64.tar.gz"
    sha256 "32984644fd51550dfed4aa3be4e961190d1b8138a7599c39e1e0fb6d7fa2776d"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.0/pbin_darwin_arm64.tar.gz"
    sha256 "20266dbccd9d5bce3f394e0f2f607ff48b2ed55cdc3612d9025ddabaafab7b9f"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.0/pbin_linux_amd64.tar.gz"
    sha256 "9dbd92cc74a580a6ee7bb1577cadb0c6a6461774ae8387e0e6782a7e01d53838"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.0/pbin_linux_arm64.tar.gz"
    sha256 "725cc36d0ae62de9fac4b0e831a50c010a59524605b0cd1ca7356bb3ab3438f6"
  end

  license "MIT"

  def install
    bin.install "pbin"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
    assert_match "https://privatebin.net/?", shell_output("echo test | #{bin}/pbin")
  end
end
