class IrcdHybrid < Formula
  desc "High-performance secure IRC server"
  homepage "http://www.ircd-hybrid.org/"
  url "https://downloads.sourceforge.net/project/ircd-hybrid/ircd-hybrid/ircd-hybrid-8.2.23/ircd-hybrid-8.2.23.tgz"
  sha256 "3a70bfbad56a6f58ec653b7fd3992c1ab75e4e7727a85ec1a9f73927196660b7"

  bottle do
    sha256 "9113d2a3fae2abbd0ed3f2c34d71d276a96f34de01703099dac22cfd9cac3d42" => :high_sierra
    sha256 "0af883166ec878a5e57b6a0200812e777fffa39ee95341f065ecde4d8aca0d61" => :sierra
    sha256 "5369177134d238aae8a496e10e086bc9f58b1b06f4a4e12b9399bab6df38118d" => :el_capitan
  end

  # ircd-hybrid needs the .la files
  skip_clean :la

  depends_on "openssl"

  conflicts_with "ircd-irc2", :because => "both install an `ircd` binary"

  def install
    ENV.deparallelize # build system trips over itself

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          "--enable-openssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
    etc.install "doc/reference.conf" => "ircd.conf"
  end

  def caveats; <<~EOS
    You'll more than likely need to edit the default settings in the config file:
      #{etc}/ircd.conf
    EOS
  end

  plist_options :manual => "ircd"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <false/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/ircd</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/ircd.log</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/ircd", "-version"
  end
end
