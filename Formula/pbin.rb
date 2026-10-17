class Pbin < Formula
  desc "CLI for PrivateBin allowing easy pasting from the Terminal"
  homepage "https://github.com/fopina/privatebin"
  license "MIT"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.4/pbin_darwin_amd64.tar.gz"
    sha256 "5fb16300e5194d875a5b86af93e7dcaab7bd5c9b5d7df892682a72476bd700d4"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.4/pbin_darwin_arm64.tar.gz"
    sha256 "6d20346b6b00f3afd67b40f075a3a824d8f6a190301ed3f75e193cbe0cad3fb4"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.4/pbin_linux_amd64.tar.gz"
    sha256 "9338838c62fa3594adfba8a37d75ac0a7ca5580e6245b48a66eaae9c506d1106"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/fopina/privatebin/releases/download/v1.0.4/pbin_linux_arm64.tar.gz"
    sha256 "3717b26625d6977d2147875517a09e2afe88579473f5a47fe1cb3e07e96c1377"
  end

  def install
    bin.install "pbin"
  end
end
