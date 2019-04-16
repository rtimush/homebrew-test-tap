class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.1.tar.gz"
  sha256 "e18349cf8db2293b453a091ea30755b5d7996b09baadb7a57ca0253e302d95eb"
  revision 3

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "17c443846929ed1553b89f879ba605cc573a4fc23796edbf123fc5ca905f777c" => :mojave
    sha256 "26528f92c87a42fa9d0064b7dabdb4c57608435deb8462f95ca71431922748bf" => :high_sierra
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
