module SchleuderConf
  class Subscriptions < Thor
    include Helper
    extend SubcommandFix

    desc 'list <list@hostname>', 'List subscriptions to list.'
    def list(listname)
      subscriptions = get(url(:subscriptions, {list_id: listname}))
      subscriptions.each do |subscription|
        email = subscription['email']
        fingerprint = subscription['fingerprint'].empty? ? 'N/A' : subscription['fingerprint']
        admin = subscription['admin'] ? 'admin' : ''
        say "#{email}\t#{fingerprint}\t#{admin}\n"
      end
      say "\n"
    end

    desc 'new <list@hostname> <user@example.org> [<fingerprint>] [</path/to/public.key>]', 'Subscribe email-address to list.'
    long_desc 'Subscribe an email-address to a list, optionally setting the fingerprint and importing public keys from a file.'
    def new(listname, email, fingerprint=nil, keyfile=nil)
      if keyfile
        test_file(keyfile)
      end

      subscribe(listname, email, fingerprint)

      text = "#{email} subscribed to #{listname} "
      if fingerprint
        text << "with fingerprint #{fingerprint}."
      else
        text << "without setting a fingerprint."
      end
      say text

      if keyfile
        import_result = import_key(listname, keyfile)
        if import_result['considered'] < 1
          say "#{keyfile} did not contain any keys!"
        else
          import_result['imports'].each do |import_status|
            say "Key #{import_status['fpr']}: #{import_status['action']}"
          end
        end
      end

    end

    desc 'list-options', 'List available options for subscriptions.'
    def list_options()
      say get(url(:subscriptions, 'configurable_attributes')).join("\n")
    end

    desc 'show <list@hostname> <user@hostname> <option>', 'Get the value of a subscription-option'
    def show(listname, email, option)
      show_value get(url(:subscriptions, email, {list_id: listname}))[option]
    end

    desc 'set <list@hostname> <user@hostname> <option> <value>', 'Set the value of a subscription-option'
    def set(listname, email, option, value=nil)
      patch(url(:subscriptions, email, {list_id: listname}), {option => value})
      show_value(value)
    end

    desc 'delete <list@hostname> <user@example.org>', 'Unsubscribe user@example.org from list@hostname.'
    def delete(listname, email)
      delete_req(url(:subscriptions, email, {list_id: listname}))
      say "#{email} unsubscribed from #{listname}."
    end

  end
end
