class {{FORMULA_CLASS}} < Formula
  desc {{DESCRIPTION}}
  homepage {{HOMEPAGE}}
  license {{LICENSE}}

  if OS.mac? && Hardware::CPU.intel?
    url {{MACOS_AMD64_URL}}
    sha256 {{MACOS_AMD64_SHA256}}
  end

  if OS.mac? && Hardware::CPU.arm?
    url {{MACOS_ARM64_URL}}
    sha256 {{MACOS_ARM64_SHA256}}
  end

  if OS.linux? && Hardware::CPU.intel?
    url {{LINUX_AMD64_URL}}
    sha256 {{LINUX_AMD64_SHA256}}
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url {{LINUX_ARM64_URL}}
    sha256 {{LINUX_ARM64_SHA256}}
  end

  def install
{{FORMULA_INSTALL}}
  end

  test do
{{FORMULA_TEST}}
  end
end
