class Pushit < Formula
  desc "Push notifications straight to your phone using multiple services"
  homepage "https://github.com/fopina/pushit"
  url "https://github.com/fopina/pushit/releases/download/v1.0.3/pushit_1.0.3_darwin_amd64.tar.gz"
  sha256 "92ff3f346181c3ea6fee907375e58f7af5de44882d5df70bf228907ea5a12ee3"
  license ""
  version "1.0.3"

  def install
    bin.install "pushit"
  end

  test do
    system "false"
  end
end
