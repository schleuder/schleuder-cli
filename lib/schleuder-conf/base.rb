module SchleuderConf
  class Base < Thor
    include Helper

    register(Subscriptions,
             'subscriptions',
             'subscriptions ...',
             'Create and manage subscriptions')

    register(Keys,
             'keys',
             'keys ...',
             'Manage OpenPGP-keys')

    register(Lists,
             'lists',
             'lists ...',
             'Create and configure lists')

    map '-v' => :version
    desc 'version', "Show version of schleuder-conf or Schleuder."
    method_option :remote, aliases: '-r', banner: '', desc: "Show version of Schleuder at the server."
    def version
      if options.remote
        say get('/version.json')['version']
      else
        say VERSION
      end
    end
  end
end
