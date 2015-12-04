module SchleuderConf
  class Keys < Thor
    extend SubcommandFix
    include Helper

    desc 'import <list@hostname> </path/to/keyfile>', "Import a key into a list's keyring."
    def import(listname, keyfile)
      if ! File.readable?(keyfile)
        fatal "File '#{keyfile}' not readable"
      end

      say post(url(:keys, {list_id: listname}), File.read(keyfile))
    end

    desc 'show <list@hostname>', "List keys available to list."
    def show(listname)
      say get(url(:keys, {list_id: listname}))
    end

    desc 'delete <list@hostname> <fingerprint>', "Delete key from list."
    def delete(listname, fingerprint)
      say delete(url(:keys, fingerprint, {list_id: listname}))
    end

    desc 'check <list@hostname>', "Check for expiring or unusable keys."
    def check(listname)
      resp = get(url(:check_keys, {list_id: listname}))
      puts resp['result']
    end
  end
end

