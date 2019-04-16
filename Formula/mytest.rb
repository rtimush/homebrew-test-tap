class Mytest < Formula
  desc "Test formula 1"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.1.tar.gz"
  sha256 "e18349cf8db2293b453a091ea30755b5d7996b09baadb7a57ca0253e302d95eb"
  revision 2

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "af7c9826a7ce8f3405d9610259e76a14aa33845c360a0a8f1eb5a403b4753bc3" => :mojave
    sha256 "1aab0f2a79ae9a3f9369720075e80d9429d39f6eb7916bb28758bd4ca39dda36" => :high_sierra
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
