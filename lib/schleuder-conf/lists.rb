module SchleuderConf
  class Lists < Thor
    include Helper
    extend SubcommandFix

    desc 'list', 'List all known lists.'
    def list
      get(url(:lists)).each do |list|
        say list['email']
      end
    end

    desc 'new <list@hostname> <adminaddress> </path/to/publickeys.asc>', 'Create a new schleuder list.'
    def new(listname, adminaddress, keyfile)
      test_file(keyfile)

      res = post(url(:lists), {email: listname})
      if res && res['errors']
        show_errors(res['errors'])
      else
        say "List #{listname} successfully created! Don't forget to hook it into your MTA."
      end

      import_result = import_key(listname, keyfile)
      case import_result['considered']
      when 1
        fingerprint = import_result['imports'].first['fpr']
        say "Key 0x#{fingerprint} imported."
      when 0
        fingerprint = nil
        say "#{keyfile} did not contain any keys!"
      else
        fingerprint = nil
        say "#{keyfile} contains more than one key, cannot derive fingerprint for #{adminaddress}. Please set it manually!"
      end

      subscribe(listname, adminaddress, fingerprint, true)
      say "#{adminaddress} subscribed to #{listname}."
    end

    desc 'list-options', 'List available options for lists.'
    def list_options()
      say options_req(url(:lists)).join("\n")
    end

    desc 'show <list@hostname> <option>', 'Get the value of a list-option.'
    def show(listname, option)
      list = get(url(:lists, listname))
      show_value(list[option])
    end

    desc 'set <list@hostname> <option> <value>', 'Get or set the value of a list-option.'
    def set(listname, option, value)
      if patch(url(:lists, listname, {option => value}))
        show_value(value)
      end
    end

    desc 'delete <list@hostname>', 'Delete the list.'
    def delete(listname)
      answer = ask "Really delete list including all its data? [yN] "
      if answer.downcase != 'y'
        exit 0
      end
      say delete_req(url(:lists, listname))
    end


  end
end
