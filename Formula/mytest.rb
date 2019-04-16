class Mytest < Formula
  desc "Test formula"
  homepage "https://github.com/rtimush/tenpureto"

  url "https://github.com/rtimush/tenpureto/archive/v0.1.1.tar.gz"
  sha256 "e18349cf8db2293b453a091ea30755b5d7996b09baadb7a57ca0253e302d95eb"
  revision 5

  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "a50ea60dd79ce9cb14ed9d34729cb528089a18c1017d80b99043d9a4cac70e34" => :mojave
    sha256 "5506c87865bbf7789a7f2c8eb45c749136eff1895bece6a797985c6e2b2ee216" => :high_sierra
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
