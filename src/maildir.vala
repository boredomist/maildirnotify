using Gee;
using Gtk;

namespace MaildirNotify {

  public class Message : GLib.Object {
    public string subject { get; private set; }
    public string from    { get; private set; }
    public string date    { get; private set; }

    public Message(string path) {
      Regex header = null;

      try {
        header = new Regex("^(?P<name>.*?):(?P<value>.*)$");
      } catch(RegexError re) {
        assert_not_reached();
      }

      date = "No time";
      from = "No sender";
      subject = "No subject.";

      var stream = FileStream.open(path, "r");
      assert(stream != null);

      var line = stream.read_line().strip();

      // Try to read the message line by line, getting the bits we care about
      while(line != "" && line != null) {
        MatchInfo info;
        if(header.match(line, 0, out info)) {
          var name = info.fetch_named("name").down();
          var value = info.fetch_named("value");

          switch(name) {
          case "subject":
            this.subject = value.strip();
            break;
          case "from":
            this.from = value.strip();
            break;
          case "date":
            this.date = value.strip();
            break;
          }
        }

        line = stream.read_line().strip();
      }
    }
  }

  public class Mailbox : GLib.Object {
    public ArrayList<Message> messages { get; private set; }
    public string name { get; private set; }
    public bool valid { get; private set; }

    private File mailbox_dir;

    public Mailbox(string maildir, string name) {
      this.name = name;
      this.messages = new ArrayList<Message>();

      this.valid = false;

      this.mailbox_dir = File.new_for_path(@"$maildir/$name/new");

      if(!mailbox_dir.query_exists()) {
        stdout.printf(@"$maildir/$name/new doesn't exist!\n");
        return;
      }

      if(mailbox_dir.query_file_type(FileQueryInfoFlags.NONE) !=
         FileType.DIRECTORY) {

        stdout.printf(@"$maildir/$name/new isn't a directory!\n");
        return;
      }

      valid = true;
    }

    public bool update() {
      messages.clear();

      var enumerator = mailbox_dir.enumerate_children(FileAttribute.STANDARD_NAME,
                                                      0);

      FileInfo file_info;
      while((file_info = enumerator.next_file()) != null) {
        var message = mailbox_dir.get_child(file_info.get_name());

        assert(message.query_exists());

        messages.add(new Message(message.get_path()));
      }

      return messages.size != 0;
    }
  }

  public class Maildir : GLib.Object, Iterable<Mailbox> {
    private HashMap<string, Mailbox> mailboxes;
    private string maildir;

    public bool valid { get; private set; }

    public Maildir(string dir, string[] folders) {
      mailboxes = new HashMap<string, Mailbox>();
      maildir = dir;

      valid = false;

      if(!File.new_for_path(@"$maildir/").query_exists()) {
        stdout.printf(@"Maildir doesn't seem to exist at $maildir\n");
        return;
      }

      valid = true;

      foreach(var folder in folders) {
        // We get a null-delimited array from option parsing
        if(folder == null)
          break;

        var mailbox = new Mailbox(dir, folder);

        if(mailbox.valid) {
          mailboxes[folder] = mailbox;
          stdout.printf("Adding mailbox: %s/%s...\n", dir, folder);
        }
      }

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