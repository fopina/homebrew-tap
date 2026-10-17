class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.8/pbin_darwin_amd64.tar.gz"
    sha256 "ae478aaa8499011f39c22cd9ebc2cd89698c8553fb0d12320460e3cbade4d8aa"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.8/pbin_darwin_arm64.tar.gz"
    sha256 "b057d309e962ff1c41ad0f1b807ab3f16ea4600d97755f8cfb54d95e2e819899"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.8/pbin_linux_amd64.tar.gz"
    sha256 "f8a8e6efd3895ae57389aa24e6aedd626e234ba70607bcdb857d5d2283b1511d"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.8/pbin_linux_arm64.tar.gz"
    sha256 "4bb380fa6d24d6713d9f61b4e94ef21ea0969cb7332510200436e3cf549a709c"
  end

  def install
    bin.install "pbin"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
    
  end
end
