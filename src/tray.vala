using GLib;
using Gtk;

namespace MaildirNotify {
  public class TrayIcon : Object {

    // Check for new messages every 30 seconds.
    static const int UPDATE_SECONDS = 30;

    static const string NO_UNREAD_MESSAGES = "mail-read";
    static const string UNREAD_MESSAGES = "mail-unread";

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
      icon = new StatusIcon.from_icon_name(NO_UNREAD_MESSAGES);
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
        icon.set_from_icon_name(NO_UNREAD_MESSAGES);
        icon.set_tooltip_text("No new messages.");
        return;
      }

      int num_new = 0;
      string tooltip = "";
      foreach(var mailbox in maildir) {
        var new_messages = mailbox.messages.size;
        if(new_messages != 0) {
          tooltip += @"\n<u>$(mailbox.name):\t$(new_messages) new</u>";

          foreach(var msg in mailbox.messages) {
            // Truncate the subjects and senders to a somewhat sensible size
            var from = msg.from;
            if(from.length > 25) {
              from = from.substring(0, 21) + "...";
            }

            var subject = msg.subject;
            if(subject.length > 25) {
              subject = subject.substring(0, 21) + "...";
            }

            from = Markup.escape_text(from);
            subject = Markup.escape_text(subject);

            tooltip += @"\n» <tt><i>$from</i>\t<span>$subject</span></tt>";
          }
        }

        num_new += new_messages;
      }

      icon.set_from_icon_name(UNREAD_MESSAGES);
      icon.set_tooltip_markup(@"<b>$num_new</b> new emails.$tooltip");
    }
  }
}