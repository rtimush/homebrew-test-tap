class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.2.tar.gz"
  sha256 "6c2cdf03c88cc012fb75a5c937fabd3b739cecccbd99e883375516e8dea2ea12"
  revision 1

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "7b6c0e0602a04c2c6a79c89135b0dda3525e59669430406295596fe26d16631f" => :mojave
    sha256 "f5779981d2c7d515399831f26cc0dfc53f70ac7c6a17a4adeaa5fd05f0863556" => :high_sierra
    sha256 "7f7f904abdde26401c7043b8436009f3ccab2d90bfbe64f79261b8ea4a310de8" => :sierra
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
