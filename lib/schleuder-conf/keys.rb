module SchleuderConf
  class Keys < Thor
    extend SubcommandFix
    include Helper

    desc 'import <list@hostname> </path/to/keyfile>', "Import a key into a list's keyring."
    def import(listname, keyfile)
      if ! File.readable?(keyfile)
        fatal "File '#{keyfile}' not readable"
      end

      say post(url(listname, :keys), File.read(keyfile))
    end

    desc 'show <list@hostname>', "List keys available to list."
    def show(listname)
      say get(url(options.list, :keys))
    end

    desc 'delete <list@hostname> <fingerprint>', "Delete key from list."
    def delete(listname, fingerprint)
      say delete(url(listname, :keys, fingerprint))
    end

    desc 'check <list@hostname>', "Check for expiring or unusable keys."
    def check(listname)
      resp = get(url(listname, :check_keys))
      puts resp['result']
    end
  end
end

