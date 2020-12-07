class {{ "INPUT_FORMULA_CLASS" | env }} < Formula
  desc "{{ "INPUT_DESCRIPTION" | env }}"
  homepage "{{ if ne ("INPUT_HOMEPAGE"|env) "" }}{{ "INPUT_HOMEPAGE" | env }}{{ else }}https://github.com/{{ "GITHUB_REPOSITORY" | env }}{{ end }}"
  url "{{ "INPUT_URL" | env }}"
  sha256 "{{ "BINARY_SHASUM" | env }}"
  license "{{ "INPUT_LICENSE" | env }}"
  version "{{ "INPUT_VERSION" | env }}"

  def install
    bin.install "{{ "INPUT_BIN" | env }}"
  end
  
  test do
    assert_match "{{ "INPUT_VERSION" | env }}", shell_output("#{bin}/{{ "INPUT_BIN" | env }} -v 2>&1", 0)
  end
end
