class Mytest < Formula
    desc "Test formula"
  bottle do
    root_url "https://dl.bintray.com/rtimush/bottles-test-tap"
    cellar :any_skip_relocation
    sha256 "ebf7aef04f3463cc09b6bb85fdb8c11c919ef234953984da4cd8acd14a3728da" => :mojave
    sha256 "ef97611b7ae2736b5ddfc1d44f8003f9a7bf4761bb4528d2fb96e11434ce534a" => :high_sierra
  end

    homepage "https://github.com/rtimush/tenpureto"

    url "https://github.com/rtimush/tenpureto/archive/v0.1.1.tar.gz"
    sha256 "e18349cf8db2293b453a091ea30755b5d7996b09baadb7a57ca0253e302d95eb"

    def install
        mkdir "completions"
        system "sh", "-c", "echo true >completions/tenpureto"
        bash_completion.install "completions/tenpureto"
    end

    test do
        system "true"
    end
end
