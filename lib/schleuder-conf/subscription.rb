module SchleuderConf
  class Subscription < Thor
    include Helper
    extend SubcommandFix

    desc 'new list@hostname user@example.org [fingerprint] [/path/to/public.key]', 'Subscribe an email-address to a list.'
    def new(listname, email, fingerprint = nil, keyfile = nil)
      fatal "Not implemented"
    end

    desc 'configuration list@hostname user@hostname option [value]', 'Get or set the value of a subscription-option'
    def configuration(listname, email, option, value=nil)
      if value.nil?
        show_value get(url(listname, :subscriptions, email))[option]
      else
        put(url(listname, :subscriptions, email), {option => value})
        show_value(value)
      end
    end
  
    desc 'delete list@hostname user@example.org [fingerprint]', 'Unsubscribe user@example.org from list@hostname (and delete public key if fingerprint is given)'
    def delete(listname, email, fingerprint = nil)
      delete(url(listname, :subscriptions, email))
      say "#{email} unsubscribed."
    end

  end
end
