class SpeedtestCli < Formula
  desc "CLI for running internet speed tests against speedtest.net and fast.com"
  homepage "https://github.com/fopina/speedtest-cli"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.5/speedtest-cli_2.1.5_darwin_amd64"
    sha256 "0d5e32ad44bca68033ca7e6303dc59c49907e0302b9dfcc4a6a7166f8f4bceec"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.5/speedtest-cli_2.1.5_darwin_arm64"
    sha256 "43db88470cf88d1bc9350b264cc1082e5426163f08b975866069f45b985c2f13"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.5/speedtest-cli_2.1.5_linux_amd64"
    sha256 "5bc664bbbbe12625f3d97487fc63aec6f3f65e60eb086c1d3f3579f8c46a6410"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.5/speedtest-cli_2.1.5_linux_arm64"
    sha256 "821a0f7abcea205b4bbbb1f5bbfa0305b8ce947c155393399982956445113093"
  end

  def install
    binary = Dir["speedtest-cli_*"].first
    bin.install binary => "speedtest-cli"
  end

  test do
    assert_match "version:", shell_output("#{bin}/speedtest-cli v")
  end
end
