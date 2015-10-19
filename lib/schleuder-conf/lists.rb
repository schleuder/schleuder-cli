module SchleuderConf
  class Lists < Thor
    include Helper
    extend SubcommandFix

    desc 'list', 'List all known lists.'
    def list
      get(url()).each do |list|
        say list['email']
      end
    end

    desc 'new <list@hostname> <adminaddress> [</path/to/publickeys.asc>]', 'Create a new schleuder list.'
    def new(listname, adminaddress, adminkeypath)
      if ! File.readable?(adminkeypath)
        fatal "File not found: #{adminkeypath}"
      end

      post(url(), {
          listname: listname,
          adminaddress: adminaddress,
          adminkey: File.read(adminkeypath)
        })

      say "List #{listname} successfully created, #{adminaddress} subscribed!\nDon't forget to hook it into your MTA."
    end

    desc 'show <list@hostname> <option>', 'Get the value of a list-option.'
    def show(listname, option)
      list = getlist(listname)
      show_value(list[option])
    end

    desc 'set <list@hostname> <option> <value>', 'Get or set the value of a list-option.'
    def set(listname, option, value)
      if put(url(listname), {option => value})
        show_value(value)
      end
    end

    desc 'delete <list@hostname>', 'Delete the list.'
    def delete(listname)
      answer = ask "Really delete list including all its data? [yN] "
      if answer.downcase != 'y'
        exit 0
      end
      say delete(url(listname))
    end


  end
end
