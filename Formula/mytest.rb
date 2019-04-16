class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.1.tar.gz"
  sha256 "e18349cf8db2293b453a091ea30755b5d7996b09baadb7a57ca0253e302d95eb"
  revision 3

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "ba200855f81279a4574478fe17ff8936bae29ef1f901e5b379344eab327b3752" => :mojave
    sha256 "5ae360ec5f9c3063462bb49574dcd5651033caa0060d3d3e3a4d029724d9c9dd" => :high_sierra
  end

  def install
    mkdir "completions"
    system "sh", "-c", "echo true >completions/tenpureto1"
    bash_completion.install "completions/tenpureto1"
  end

  test do
    system "true"
  end
end
