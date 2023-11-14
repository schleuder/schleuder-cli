module SchleuderCli
  class Keys < Thor
    extend SubcommandFix
    include Helper

    desc 'import <list@hostname> </path/to/keyfile>', "Import a key into a list's keyring."
    def import(listname, keyfile)
      import_result = import_key(listname, keyfile)
      if import_result['considered'] < 1
        say "#{keyfile} did not contain any keys!"
      else
        say_key_import_stati(import_result['imports'])
      end
    end

    desc 'export <list@hostname> <fingerprint>', "Get the key exported from the list's keyring."
    def export(listname, fingerprint)
      if hash = get(url(:keys, fingerprint, {list_id: listname}))
        say hash['ascii']
      end
    end

    desc 'list <list@hostname>', "List keys available to list."
    def list(listname)
      if keys = get(url(:keys, {list_id: listname}))
        keys.each do |hash|
          say "#{hash['fingerprint']} #{hash['email']}"
        end
      end
    end

    desc 'delete <list@hostname> <fingerprint>', "Delete key from list."
    def delete(listname, fingerprint)
      delete_req(url(:keys, fingerprint, {list_id: listname})) || ok
    end

    desc 'check <list@hostname>', "Check for expiring or unusable keys."
    def check(listname)
      resp = get(url(:keys, :check_keys, {list_id: listname}))
      say resp['result']
    end
  end
end

