class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.2.tar.gz"
  sha256 "6c2cdf03c88cc012fb75a5c937fabd3b739cecccbd99e883375516e8dea2ea12"
  revision 3

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "6401614803ea9a1dd2f46c6a33281a335a9a8b06454ef3628e452e3dc9646d7d" => :mojave
    sha256 "2cc9836da58c5e3fd5476d95873874d0afeecb6c8e7671de26a9910bde49ccc3" => :high_sierra
    sha256 "047b14721771d8666eacee9bb6ec3e73785f15d4b3cd114fb2d0a3c980a33f11" => :sierra
  end

  def install
    mkdir "completions"
    system "sh", "-c", "echo true >completions/tenpureto2"
    bash_completion.install "completions/tenpureto2"
  end

  test do
    system "true"
  end
end
