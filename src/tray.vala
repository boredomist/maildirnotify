using GLib;
using Gtk;

namespace MaildirNotify {
  public class TrayIcon : Object {

    private Maildir maildir;
    private StatusIcon icon;
    private Gtk.Menu popup_menu;


    public TrayIcon(string dir, string[] folders) {

      maildir = new Maildir(dir, folders);
      popup_menu = new Gtk.Menu();

      build_icon();

      icon.set_visible(true);
    }

    private void build_icon() {
      icon = new StatusIcon.from_stock(Stock.YES);
      icon.set_tooltip_text("Hold up.");

      var quit = new Gtk.MenuItem.with_label("Quit");
      quit.activate.connect(() => { Gtk.main_quit(); });

      popup_menu.append(quit);
      popup_menu.show_all();

      icon.popup_menu.connect((b, t) => {
          popup_menu.popup(null, null, icon.position_menu, b, t);
      });
    }

    public void update() {
    }

  }
}