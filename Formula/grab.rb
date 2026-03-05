class Grab < Formula
  desc "Android UI grab CLI for CodeLocatorPRO"
  homepage "https://github.com/git54496/CodeLocatorPRO"
  version "main"
  url "https://github.com/git54496/CodeLocatorPRO.git", branch: "main", using: :git
  license "Apache-2.0"

  depends_on "openjdk@17"

  def install
    cd "adapter" do
      system "./gradlew", "installDist", "--no-daemon"
      install_root = if (Pathname("build/install/grab")).exist?
        "build/install/grab"
      else
        Dir["build/install/*"].first
      end
      odie "installDist output not found under adapter/build/install" if install_root.nil?
      libexec.install Dir["#{install_root}/*"]
    end

    env = Language::Java.overridable_java_home_env("17")
    target = if (libexec/"bin/grab").exist?
      libexec/"bin/grab"
    else
      libexec/"bin/codelocator-adapter"
    end
    odie "CLI entry not found under #{libexec}/bin" unless target.exist?
    (bin/"grab").write_env_script target, env
  end

  test do
    output = shell_output("#{bin}/grab list")
    assert_match "\"success\": true", output
  end

  def caveats
    <<~EOS
      `grab live` requires `adb` in PATH.
      Install it with:
        brew install --cask android-platform-tools
    EOS
  end
end
