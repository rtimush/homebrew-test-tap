class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.1.tar.gz"
  sha256 "e18349cf8db2293b453a091ea30755b5d7996b09baadb7a57ca0253e302d95eb"
  revision 6

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
