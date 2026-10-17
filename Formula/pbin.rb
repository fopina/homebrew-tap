class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.9/pbin_darwin_amd64.tar.gz"
    sha256 "d59acf2f1cfde23fc772ddff16fd68f260642784cf484e7c9e4f725179572c20"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.9/pbin_darwin_arm64.tar.gz"
    sha256 "ea14651703b215abf741cddf4891830dc43ecdd3191f7b21656562c39f0c8190"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.9/pbin_linux_amd64.tar.gz"
    sha256 "5b21d0e13947ae0000e57bd77b4be0bfe342a84fd323abd01799c0770e130115"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.9/pbin_linux_arm64.tar.gz"
    sha256 "0a345d9dc92265e26a143d43dc34a764b8ef9e0b28f2db24fc2a91faf1fbc5b9"
  end

  def install
    bin.install "pbin"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
  end
end
