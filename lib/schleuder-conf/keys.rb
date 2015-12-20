module SchleuderConf
  class Keys < Thor
    extend SubcommandFix
    include Helper

    desc 'import <list@hostname> </path/to/keyfile>', "Import a key into a list's keyring."
    def import(listname, keyfile)
      if ! File.readable?(keyfile)
        fatal "File '#{keyfile}' not readable"
      end

      res = post(url(:keys, {list_id: listname}), {ascii: File.read(keyfile)})
      if res.is_a?(Hash)
        if res.empty?
          say 'No keys found in input'
        else
          res.each do |fpr, status|
            say "0x#{fpr}: #{status}"
          end
        end
      else
        say res
      end
    end

    desc 'show <list@hostname>', "List keys available to list."
    def show(listname)
      if keys = get(url(:keys, {list_id: listname}))
        keys.each do |hash|
          say "0x#{hash['fingerprint']} #{hash['email']}"
        end
      end
    end

    desc 'delete <list@hostname> <fingerprint>', "Delete key from list."
    def delete(listname, fingerprint)
      delete_req(url(:keys, fingerprint, {list_id: listname})) || ok
    end

    desc 'check <list@hostname>', "Check for expiring or unusable keys."
    def check(listname)
      resp = get(url(:check_keys, {list_id: listname}))
      puts resp['result']
    end
  end
end

