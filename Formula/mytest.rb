class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.1.tar.gz"
  sha256 "e18349cf8db2293b453a091ea30755b5d7996b09baadb7a57ca0253e302d95eb"
  revision 6

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "195105563cab45a78008f673b209b04ebfe517a76fc43029b0561185f1cda5de" => :mojave
    sha256 "bca8bd2b8f28f8e71537891ddae303623b7ca8a872826f950a59d2a91bf8440e" => :high_sierra
  end

  def install
    mkdir "completions"
    system "sh", "-c", "echo true >completions/tenpureto1"
    bash_completion.install "completions/tenpureto2"
  end

  test do
    system "true"
  end
end
