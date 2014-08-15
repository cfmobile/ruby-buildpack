require "language_pack"

class LanguagePack::AndroidSdk < LanguagePack::Base
  ANDROID_SDK_BASE_URL = "http://dl.google.com/android"
  ANDROID_SDK_PATH     = "vendor/android"
  ANDROID_HOME_PATH    = "vendor/android/android-sdk-linux"

  # changes directory to the build_path
  # @param [String] the path of the build dir
  # @param [String] the path of the cache dir this is nil during detect and release
  def initialize(build_path, cache_path=nil)
    super build_path, cache_path
    @fetchers[:android] = LanguagePack::Fetcher.new(ANDROID_SDK_BASE_URL)
  end

  def name
    "Android SDK"
  end

  def compile
    instrument "android_sdk.compile" do
      install_android_sdk
    end
  end

private

  def install_android_sdk
    instrument 'android_sdk.install_sdk' do
      topic "Installing Android SDK"

      FileUtils.mkdir_p(android_sdk_path)
      Dir.chdir(android_sdk_path) do
        @fetchers[:android].fetch_untar("android-sdk_r22.3-linux.tgz")
      end

      set_env_default  "ANDROID_HOME", android_home_path
      set_env_override "PATH", "#{android_home_path}/tools:#{android_home_path}/platform-tools:#{android_home_path}/build-tools/19.0.1:$PATH"

      pipe <<-CMD
        export ANDROID_HOME=#{android_home_path} &&
        export PATH=#{Dir.pwd}/bin:$PATH         &&
        echo y | #{android_home_path}/tools/android --silent update sdk #{default_android_sdk_options}
      CMD

      topic "Done installing SDK"
    end
  end

  def android_sdk_path
    "#{Dir.pwd}/#{ANDROID_SDK_PATH}"
  end

  def android_home_path
    "#{Dir.pwd}/#{ANDROID_HOME_PATH}"
  end

  def default_android_sdk_options
    "--all --no-ui --force --filter build-tools-19.0.1,android-19,extra-android-support"
  end
end
