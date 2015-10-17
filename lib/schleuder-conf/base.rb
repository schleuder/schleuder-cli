module SchleuderConf
  class Base < Thor
    include Helper

    class_option :port, default: 4567, desc: 'The port schleuderd is listening at.', aliases: '-p'

    register(Subscription,
             'subscription',
             'subscription ...',
             'Create and manage subscriptions')

    register(List,
             'list',
             'list ...',
             'Create and manage lists')

    desc 'version', "Show version of #{ARGV[0]}"
    def version
      say VERSION
    end

    desc 'schleuder_version', 'Show version of schleuder at the server.'
    def schleuder_version
      say get('/version')['version']
    end

    desc 'check_keys list@hostname', "Check for expiring or unusable keys."
    def check_keys(listname)
      resp = get(url(listname, :check_keys))
      puts resp['result']
    end
  end
end
