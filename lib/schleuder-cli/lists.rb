module SchleuderCli
  class Lists < Thor
    include Helper
    extend SubcommandFix

    desc 'list', 'List all known lists.'
    def list
      get(url(:lists)).each do |list|
        say list['email']
      end
    end

    desc 'new <list@hostname> <adminaddress> [</path/to/publickeys.asc>]', 'Create a new schleuder list.'
    def new(listname, adminaddress, keyfile=nil)
      res = post(url(:lists), {email: listname}) do |http, request|
        http.read_timeout = 120
        begin
          http.request(request)
        rescue Net::ReadTimeout
          fatal "Error: Timeout while waiting for Schleuder API!\n\nThe Schleuder API didn't answer in time. This happens sometimes when creating a new list because generating a new OpenPGP key-pair requires a lot of randomness — if that's not given, GnuPG just waits until there's more.\nUnfortunately we can't know what the issue really is. But chances are that the list was created just fine and in a few minutes the new OpenPGP key-pair will have been generated, too. So please wait a little while and then have a look if your list was created."
        end
      end

      if res && res['errors']
        show_errors(res['errors'])
      else
        say "List #{listname} successfully created! Don't forget to hook it into your MTA."
      end

      fingerprint = import_key_and_find_fingerprint(listname, keyfile)
      subscribe(listname, adminaddress, fingerprint, true)
    end

    desc 'list-options', 'List available options for lists.'
    def list_options()
      say get(url(:lists, 'configurable_attributes')).join("\n")
    end

    desc 'show <list@hostname> <option>', 'Get the value of a list-option.'
    def show(listname, option)
      list = get(url(:lists, listname))
      check_option_presence(list, option)
      show_value(list[option])
    end

    desc 'set <list@hostname> <option> <value>', 'Get or set the value of a list-option.'
    def set(listname, option, value)
      if option.start_with?('headers_to_meta', 'keywords_admin_notify', 'keywords_admin_only', 'bounces_drop_on_headers')
        begin
          value = JSON.parse(value)
        rescue => exc
          error "Parsing value as JSON failed: #{exc.message}"
          fatal "Input must be valid JSON."
        end
      end
      patch(url(:lists, listname), {option => value})
      show_value(value)
    end

    desc 'delete <list@hostname> [--YES]', "Delete the list. To skip confirmation use --YES"
    def delete(listname, dontask=nil)
      if dontask != '--YES'
        answer = ask "Really delete list including all its data? [yN] "
        if answer.downcase != 'y'
          say "Not deleted."
          exit 0
        end
      end
      say delete_req(url(:lists, listname))
    end

    desc 'send-list-key-to-subscriptions <list@hostname>', "Triggers the sending of the list's public key to all subscriptions."
    def send_list_key_to_subscriptions(listname)
      response = post(url(:lists, :send_list_key_to_subscriptions, {list_id: listname}), :irrelevant)
      say response['result']
    end

  end
end
