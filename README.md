Schleuder-cli
==============

A command line tool to create and manage schleuder-lists.

Schleuder-cli enables creating, configuring, and deleting lists, subscriptions, keys, etc. It uses the Schleuder API, provided by schleuder-api-daemon (part of Schleuder).

Authentication and TLS-verification are mandatory. You need an API-key and the fingerprint of the TLS-certificate of the Schleuder API, respectively. Both should be provided by the API operators.

schleuder-cli does *not* authorize access. Only people who are supposed to have full access to all lists should be allowed to use it on/with your server.


Requirements
------------
* ruby  >=2.7
* thor

Installation
------------

1. Download [the gem](https://0xacab.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.1.0.gem) and [the OpenPGP-signature](https://0xacab.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.1.0.gem.sig) and verify:
   ```
   gpg --recv-key 0xB3D190D5235C74E1907EACFE898F2C91E2E6E1F3
   gpg --verify schleuder-cli-0.1.0.gem.sig
   ```

2. If all went well install the gem:
   ```
   gem install schleuder-cli-0.1.0.gem
   ```

You probably want to install [schleuder](https://0xacab.org/schleuder/schleuder), too. Without schleuder, this software is very useless.

Configuration
-------------

SchleuderCli reads its settings from a file that it by default expects at `$HOME/.schleuder-cli/schleuder-cli.yml`. To make it read a different file set the environment variable `SCHLEUDER_CLI_CONFIG` to the path to your file. E.g.:

    SCHLEUDER_CLI_CONFIG=/usr/local/etc/schleuder-cli.yml schleuder-cli ...

The configuration file specifies how to connect to the Schleuder API. If it doesn't exist, it will be filled with the default settings.

The default settings will work out of the box with the default settings of Schleuder if both are running on the same host.

**Options**

These are the configuration file options and their default values:

 * `host`: The hostname (or IP-address) to connect to. Default: `localhost`.
 * `port`: The port to connect to. Default: `4443`.
 * `tls_fingerprint`: TLS-fingerprint of the Schleuder API. To be fetched from the API operators. Default: empty.
 * `api_key`: Key to authenticate with against the Schleuder API. To be fetched from the API operators. Default: empty.


Usage
-----
See `schleuder-cli help`.

E.g.:

    Commands:
      schleuder-cli help [COMMAND]     # Describe available commands or one specific command
      schleuder-cli keys ...           # Manage OpenPGP-keys
      schleuder-cli lists ...          # Create and configure lists
      schleuder-cli subscriptions ...  # Create and manage subscriptions
      schleuder-cli version            # Show version of schleuder-cli or Schleuder.



Contributing
------------

Please see [CONTRIBUTING.md](CONTRIBUTING.md).


Mission statement
-----------------

We summarized our motivation in [MISSION_STATEMENT.md](MISSION_STATEMENT.md).


Code of Conduct
---------------

We adopted a code of conduct. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).


License
-------

GNU GPL 3.0. Please see [LICENSE.txt](LICENSE.txt).


Alternative Download
--------------------

Alternatively to the gem-files you can download the latest release as [a tarball](https://0xacab.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.1.0.tar.gz) and [its OpenPGP-signature](https://0xacab.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.1.0.tar.gz.sig).
