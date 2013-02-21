using Gee;
using Gtk;

namespace MaildirNotify {
  public class Message : GLib.Object {
    public Message() {}
  }

  public class Mailbox : GLib.Object {
    public HashMap<string, Message> messages;

    public Mailbox() {}

    public bool update() { return false; }
  }

  public class Maildir : GLib.Object {
    public HashMap<string, Mailbox> mailboxes;

    public Maildir(string dir, string[] folders) {
      mailboxes = new HashMap<string, Mailbox>();
    }

    public async bool update() {
      var has_update = false;

      foreach(var box in mailboxes.values) {
        has_update |= box.update();
      }

      return has_update;
    }
  }
}