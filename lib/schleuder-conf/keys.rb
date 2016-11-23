module SchleuderConf
  class Keys < Thor
    extend SubcommandFix
    include Helper

    desc 'import <list@hostname> </path/to/keyfile>', "Import a key into a list's keyring."
    def import(listname, keyfile)
      import_result = import_key(listname, keyfile)
      if import_result['considered'] < 1
        say "#{keyfile} did not contain any keys!"
      else
        import_result['imports'].each do |import_status|
          say "Key 0x#{import_status['fpr']}: #{import_status['action']}"
        end
      end
    end

    desc 'list <list@hostname>', "List keys available to list."
    def list(listname)
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
      say resp['result']
    end
  end
end

