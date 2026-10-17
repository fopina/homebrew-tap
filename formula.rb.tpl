class {{ "INPUT_FORMULA_CLASS" | env }} < Formula
  desc "{{ "INPUT_DESCRIPTION" | env }}"
  homepage "{{ if ne ("INPUT_HOMEPAGE"|env) "" }}{{ "INPUT_HOMEPAGE" | env }}{{ else }}https://github.com/{{ "GITHUB_REPOSITORY" | env }}{{ end }}"
  version "{{ "INPUT_FORMULA_VERSION" | env }}"
  license "{{ "INPUT_LICENSE" | env }}"

  if OS.mac? && Hardware::CPU.intel?
    url "{{ "MACOS_AMD64_URL" | env }}"
    sha256 "{{ "MACOS_AMD64_SHA256" | env }}"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "{{ "MACOS_ARM64_URL" | env }}"
    sha256 "{{ "MACOS_ARM64_SHA256" | env }}"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "{{ "LINUX_AMD64_URL" | env }}"
    sha256 "{{ "LINUX_AMD64_SHA256" | env }}"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "{{ "LINUX_ARM64_URL" | env }}"
    sha256 "{{ "LINUX_ARM64_SHA256" | env }}"
  end

  def install
    bin.install "{{ "INPUT_BIN" | env }}"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/{{ "INPUT_BIN" | env }} -v")
    assert_match "https://privatebin.net/?", shell_output("echo test | #{bin}/{{ "INPUT_BIN" | env }}")
  end
end
