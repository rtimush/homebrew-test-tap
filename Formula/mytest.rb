class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.2.tar.gz"
  sha256 "6c2cdf03c88cc012fb75a5c937fabd3b739cecccbd99e883375516e8dea2ea12"
  revision 1

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "728a76b134492b5219f3e8249a43310992fc25747b5d940653bb424b4d0bb65a" => :mojave
    sha256 "a27a3782c152bed6119c771886e874d7fd0265453345bfdf5f08bab27842287f" => :high_sierra
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
