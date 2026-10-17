class SpeedtestCli < Formula
  desc "CLI for running internet speed tests against speedtest.net and fast.com"
  homepage "https://github.com/fopina/speedtest-cli"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.8/speedtest-cli_2.1.8_darwin_amd64"
    sha256 "ae54959e62883cbf36f3db3882e39bdf687e7afc3c938e4f1944862f61dd5c1a"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.8/speedtest-cli_2.1.8_darwin_arm64"
    sha256 "b6507d22cc6cb553065866c6ae59befa48a4735943adb43135a807baae20fe83"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.8/speedtest-cli_2.1.8_linux_amd64"
    sha256 "bb149192f895fc57b36ce7c81fab3d0d113fb6dfa05c9b05472a880c156fd899"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/speedtest-cli/releases/download/v2.1.8/speedtest-cli_2.1.8_linux_arm64"
    sha256 "dee03c12706b4f189cb7b6419c1cf61f015cb43a9706c35892568d0ad252c6cc"
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
