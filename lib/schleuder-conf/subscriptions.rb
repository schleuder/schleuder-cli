module SchleuderConf
  class Subscriptions < Thor
    include Helper
    extend SubcommandFix

    desc 'list <list@hostname>', 'List subscriptions to list.'
    def list(listname)
      subscriptions = get(url(listname, :subscriptions))
      subscriptions.each do |subscription|
        say "#{subscription['email']}\t#{subscription['fingerprint'] || 'N/A'}"
      end
    end

    desc 'new <list@hostname> <user@example.org> [<fingerprint>] [</path/to/public.key>]', 'Subscribe email-address to list.'
    long_desc 'Subscribe an email-address to a list, optionally setting the fingerprint and importing public keys from a file.'
    def new(listname, email, fingerprint=nil, keyfile=nil)
      if ! File.readable?(keyfile)
        fatal "File not found: #{keyfile}"
      end
      post(url(listname, :subscriptions), {
          email: email,
          fingerprint: fingerprint,
          key: File.read(keyfile)
        })
      say "#{email} subscribed to #{listname}"
    end

    desc 'show <list@hostname> <user@hostname> <option>', 'Get the value of a subscription-option'
    def show(listname, email, option)
      show_value get(url(listname, :subscriptions, email))[option]
    end

    desc 'set <list@hostname> <user@hostname> <option> <value>', 'Set the value of a subscription-option'
    def set(listname, email, option, value=nil)
      put(url(listname, :subscriptions, email), {option => value})
      show_value(value)
    end

    desc 'delete <list@hostname> <user@example.org>', 'Unsubscribe user@example.org from list@hostname.'
    def delete(listname, email)
      delete(url(listname, :subscriptions, email))
      say "#{email} unsubscribed from #{listname}."
    end

  end
end
