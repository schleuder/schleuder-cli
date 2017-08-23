module SchleuderCli
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
        delivery_enabled = subscription['delivery_enabled'] ? '' : 'Delivery disabled!'
        say "#{email}\t#{fingerprint}\t#{admin}\t#{delivery_enabled}\n"
      end
      say "\n"
    end

    desc 'new <list@hostname> <user@example.org> [<fingerprint> | </path/to/public.key>]', 'Subscribe email-address to list.'
    long_desc 'Subscribe an email-address to a list, optionally setting the fingerprint and/or importing public keys from a file.'
    def new(listname, email, fingerprint_or_keyfile=nil)
      if fingerprint_or_keyfile =~ Conf::FINGERPRINT_REGEXP
        subscribe(listname, email, fingerprint_or_keyfile)
      else
        subscribe(listname, email, nil, nil, nil, fingerprint_or_keyfile)
      end
    end

    desc 'list-options', 'List available options for subscriptions.'
    def list_options()
      say get(url(:subscriptions, 'configurable_attributes')).join("\n")
    end

    desc 'show <list@hostname> <user@hostname> <option>', 'Get the value of a subscription-option'
    def show(listname, email, option)
      subscription = get(url(:subscriptions, email, {list_id: listname}))
      check_option_presence(subscription, option)
      show_value(subscription[option])
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
