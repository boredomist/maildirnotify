using GLib;
using Gtk;

namespace MaildirNotify {
  public class TrayIcon : Object {

    // Check for new messages every 30 seconds.
    static const int UPDATE_SECONDS = 30;

    private Maildir maildir;
    private StatusIcon icon;
    private Gtk.Menu popup_menu;

    public TrayIcon(Maildir maildir) {
      this.maildir = maildir;

      popup_menu = new Gtk.Menu();

      build_icon();

      // Refresh the mail list on a predefined interval
      Timeout.add_seconds(UPDATE_SECONDS, () => {
          check_mail.begin();
          return true;
      });

      icon.set_visible(true);

      // Let's do an intial update
      check_mail.begin();
    }

    // Set up our systray icon and related menus / actions.
    private void build_icon() {
      icon = new StatusIcon.from_stock(Stock.YES);
      icon.set_tooltip_text("Updating...");

      var quit = new Gtk.MenuItem.with_label("Quit");
      quit.activate.connect(() => { Gtk.main_quit(); });

      var refresh_now = new Gtk.MenuItem.with_label("Refresh now");
      refresh_now.activate.connect(() => { check_mail.begin(); });

      popup_menu.append(refresh_now);
      popup_menu.append(quit);
      popup_menu.show_all();

      icon.popup_menu.connect((b, t) => {
          popup_menu.popup(null, null, icon.position_menu, b, t);
      });
    }

    private async void check_mail() {
      // Just quit if we don't see a new message
      if(!maildir.update()) {
        icon.set_tooltip_text("No new messages.");
        return;
      }

      int num_new = 0;

      foreach(var mailbox in maildir) {
        var msgs = mailbox.messages;
        num_new += msgs.size;
      }

      icon.set_tooltip_text(@"$num_new new emails.");
    }
  }
}