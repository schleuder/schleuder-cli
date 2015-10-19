module SchleuderConf
  class Base < Thor
    include Helper

    class_option :port, aliases: '-p', default: 4567, banner: '<number>', desc: 'The port schleuderd is listening at.'

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
    desc 'version', "Show version of schleuder-conf or schleuderd."
    method_option :remote, aliases: '-r', banner: '', desc: "Show version of schleuderd at the server."
    def version
      if options.remote
        say get('/version')['version']
      else
        say VERSION
      end
    end
  end
end
