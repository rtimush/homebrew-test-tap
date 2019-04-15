class Mytest < Formula
    desc "Test formula"
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
