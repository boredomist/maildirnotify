using Gee;
using Gtk;

namespace MaildirNotify {
  public class Message : GLib.Object {
    public Message() {}
  }

  public class Mailbox : GLib.Object {
    public ArrayList<Message> messages { get; private set; }
    public string name { get; private set; }

    public Mailbox(string name) {
      this.name = name;
      this.messages = new ArrayList<Message>();
    }

    public bool update() {
      messages.clear();



      return messages.size != 0;
    }
  }

  public class Maildir : GLib.Object, Iterable<Mailbox> {
    private HashMap<string, Mailbox> mailboxes;

    public Maildir(string dir, string[] folders) {
      mailboxes = new HashMap<string, Mailbox>();
    }

    public bool update() {
      // Have we seen a new message on this update?
      var has_new = false;

      foreach(var box in mailboxes.values) {
        has_new |= box.update();
      }

      return has_new;
    }

    public Type element_type { get { return typeof(Mailbox); } }

    // Return an iterator over the mailbox objects. Because laziness.
    public Iterator<Mailbox> iterator() {
      return mailboxes.values.iterator();
    }
  }

}