class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  version "1.0.1"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.1/pbin_darwin_amd64.tar.gz"
    sha256 "1d9cc97d185be81d4171b2d6df38d5012cabfca3bb2d01316ac726fdc53210b5"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.1/pbin_darwin_arm64.tar.gz"
    sha256 "caef25673cc2f8fa8434eae9f31fb372622419cb0e00035189a1ab12f2c18bd6"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.1/pbin_linux_amd64.tar.gz"
    sha256 "71a3c2c99507b45fdaad2f2a403ea354e25da156e3f35df7b6c41c1e31e2dd82"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.1/pbin_linux_arm64.tar.gz"
    sha256 "3301016b83c76ded21f634d39ca80ebfc2d7a647b7a992fe74146789d30a899b"
  end

  def install
    bin.install "pbin"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/pbin -v")
    assert_match "https://privatebin.net/?", shell_output("echo test | #{bin}/pbin")
  end
end
