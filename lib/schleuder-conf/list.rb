module SchleuderConf
  class List < Thor
    include Helper
    extend SubcommandFix

    desc 'new list@hostname adminaddress [/path/to/publickeys.asc]', 'Create a new schleuder list.'
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

    desc 'configuration list@hostname option [value]', 'Get or set the value of a list-option.'
    def configuration(listname, option, value=nil)
      if value.nil?
        list = getlist(listname)
        show_value(list[option])
      else
        if put(url(listname), {option => value})
          show_value(value)
        end
      end
    end

    desc 'delete list@hostname', 'Delete the list.'
    def delete(listname)
      answer = ask "Really delete list including all its data? [yN] "
      if answer.downcase != 'y'
        exit 0
      end

      say delete(url(listname))
    end

    desc 'importkey list@hostname /path/to/public.key', "Import OpenPGP-key-material into the list's keyring."
    def import_key(listname, keyfile)
      if ! File.readable?(keyfile)
        fatal "File '#{keyfile}' not readable"
      end

      say post(url(listname, :keys), File.read(keyfile))
    end

    desc 'subscriptions list@hostname', 'List subscriptions to list.'
    def subscriptions(listname)
      subscriptions = get(url(listname, :subscriptions))

      subscriptions.each do |subscription|
        say "#{subscription['email']}\t#{subscription['fingerprint'] || 'N/A'}"
      end

    end

  end
end
