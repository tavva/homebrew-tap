# ABOUTME: tmux 3.7c built from source with the upstream fix for tmux issue 5664.
# ABOUTME: Copies homebrew-core's 3.7c formula and adds the fix as an inline patch.
class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.7c/tmux-3.7c.tar.gz"
  sha256 "7c60cae9a0e25288e2e24750aafc9e8800fc7fd4555e447e1b29ee4201cfb3bf"
  license "ISC"
  compatibility_version 1

  depends_on "pkgconf" => :build
  depends_on "libevent"
  depends_on "ncurses"
  depends_on "utf8proc"

  uses_from_macos "bison" => :build # for yacc

  on_macos do
    # https://github.com/tmux/tmux/blob/62044f02dff22d304da78ac81b69afcf84872ac7/CHANGES#L169-L170
    # https://github.com/tmux/tmux/issues/5385
    depends_on "jemalloc"
  end

  # runs a server as a test
  allow_network_access! :test

  # The server spins in screen_redraw_screen when a client is narrower than a
  # window with pane-border-status. Fixed upstream on the release_3.7d branch:
  # https://github.com/tmux/tmux/issues/5664
  # https://github.com/tmux/tmux/commit/0750e649eda0de089f94249a87476b1839fcb785
  patch :DATA

  def install
    args = %W[
      --enable-sixel
      --sysconfdir=#{etc}
      --enable-utf8proc
    ]

    # tmux finds the `tmux-256color` terminfo provided by our ncurses
    # and uses that as the default `TERM`, but this causes issues for
    # tools that link with the very old ncurses provided by macOS.
    # https://github.com/Homebrew/homebrew-core/issues/102748
    args << "--with-TERM=screen-256color" if OS.mac? && MacOS.version < :sonoma

    system "./configure", *args, *std_configure_args
    system "make", "install"

    pkgshare.install "example_tmux.conf"
  end

  def caveats
    <<~EOS
      Example configuration has been installed to:
        #{opt_pkgshare}
    EOS
  end

  test do
    system bin/"tmux", "-V"

    require "pty"

    socket = testpath/tap.user
    PTY.spawn bin/"tmux", "-S", socket, "-f", File::NULL
    sleep 10

    assert_path_exists socket
    assert_predicate socket, :socket?
    assert_equal "no server running on #{socket}", shell_output("#{bin}/tmux -S#{socket} list-sessions 2>&1", 1).chomp
  end
end

__END__
diff --git a/screen-redraw.c b/screen-redraw.c
index a5496e1b14..332b3cf03c 100644
--- a/screen-redraw.c
+++ b/screen-redraw.c
@@ -713,7 +713,7 @@ screen_redraw_draw_pane_status(struct screen_redraw_ctx *ctx)
 			/* Right not visible. */
 			l = 0;
 			x = xoff - ctx->ox;
-			width = size - x;
+			width = ctx->sx - x;
 		}
 
 		r = tty_check_overlay_range(tty, x, yoff, width);
