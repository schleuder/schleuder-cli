module SchleuderConf
  class Subscriptions < Thor
    include Helper
    extend SubcommandFix

    desc 'list <list@hostname>', 'List subscriptions to list.'
    def list(listname)
      subscriptions = get(url(:subscriptions, {list_id: listname}))
      subscriptions.each do |subscription|
        say "#{subscription['email']}\t#{subscription['fingerprint'] || 'N/A'}"
      end
    end

    desc 'new <list@hostname> <user@example.org> [<fingerprint>] [</path/to/public.key>]', 'Subscribe email-address to list.'
    long_desc 'Subscribe an email-address to a list, optionally setting the fingerprint and importing public keys from a file.'
    def new(listname, email, fingerprint=nil, keyfile=nil)
      if keyfile
        if ! File.readable?(keyfile)
          fatal "File not found: #{keyfile}"
        else
          keydata = File.read(keyfile)
        end
      end
      res = post(url(:subscriptions, {list_id: listname}), {
          email: email,
          fingerprint: fingerprint.to_s
        })
      if res && res['errors']
        res['errors'].each do |k,v|
          say "#{k.capitalize} #{v.join(', ')}"
        end
        exit 1
      end

      say "#{email} subscribed to #{listname}"
      if keydata
        res = post(url(:keys, {list_id: listname}), {ascii: keydata})
        say res if res
      end
    end

    desc 'list-options', 'List available options for subscriptions.'
    def list_options()
      say options_req(url(:subscriptions)).join("\n")
    end

    desc 'show <list@hostname> <user@hostname> <option>', 'Get the value of a subscription-option'
    def show(listname, email, option)
      show_value get(url(:subscriptions, email, {list_id: listname}))[option]
    end

    desc 'set <list@hostname> <user@hostname> <option> <value>', 'Set the value of a subscription-option'
    def set(listname, email, option, value=nil)
      put(url(:subscriptions, email, {list_id: listname}), {option => value})
      show_value(value)
    end

    desc 'delete <list@hostname> <user@example.org>', 'Unsubscribe user@example.org from list@hostname.'
    def delete(listname, email)
      delete_req(url(:subscriptions, email, {list_id: listname}))
      say "#{email} unsubscribed from #{listname}."
    end

  end
end
