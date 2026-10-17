class SpeedtestCli < Formula
  desc "CLI for running internet speed tests against speedtest.net and fast.com"
  homepage "https://github.com/fopina/speedtest-cli"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.7/speedtest-cli_2.1.7_darwin_amd64"
    sha256 "5f3db80d8633903d344b96ae3c3c7906d34563b73044f5063ca465bfea05119f"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.7/speedtest-cli_2.1.7_darwin_arm64"
    sha256 "0e9d92788f0096c2ce7e49f2855b13813c6144b32ce400c7b967723412c389d7"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.7/speedtest-cli_2.1.7_linux_amd64"
    sha256 "7d652d1270f3db98f80d0157d7dad85af73a7abee31478f97810e03710b6b588"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.7/speedtest-cli_2.1.7_linux_arm64"
    sha256 "f3baee8c06a26c1d6204e2c7e0fc9b396e74a2ef56313f2c8dfd6e024664eb66"
  end

  def install
    binary = Dir["speedtest-cli*"].first
    if binary
      bin.install binary => "speedtest-cli"
    else
      bin.install "speedtest-cli"
    end
  end

  test do
    assert_match "version:", shell_output("#{bin}/speedtest-cli v")
  end
end
