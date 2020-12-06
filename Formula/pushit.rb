class Pushit < Formula
  desc "Push notifications straight to your phone using multiple services"
  homepage "https://github.com/fopina/pushit"
  url "https://github.com/fopina/pushit/releases/download/v1.0.4/pushit_1.0.4_darwin_amd64.tar.gz"
  sha256 "f77409fa7ab02b588b48bb22eb140e810c1b832a7dfc70cc2cc0be74b4075d0a"
  license ""
  version "1.0.4"

  def install
    bin.install "pushit"
  end

  test do
    system "false"
  end
end
