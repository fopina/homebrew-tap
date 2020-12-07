class Privatebin < Formula
  desc "PrivateBin CLI written in Golang"
  homepage "https://github.com/fopina/privatebin"
  url "https://github.com/fopina/privatebin/releases/download/0.2.2/pbin_darwin_x86_64.tar.gz"
  sha256 "ed84dcdeada8f9e0820ce62d3a4711a681ce24adb4e138b082f7b589cd0586e3"
  license ""
  version "0.2.2"

  def install
    bin.install "pbin"
  end
  
  test do
    assert_match "0.2.2", shell_output("#{bin}/pbin -v 2>&1", 0)
  end
end
