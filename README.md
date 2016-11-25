Schleuder-cli
==============

A command line tool to configure schleuder-lists.

Schleuder-cli enables creating, configuring, and deleting schleuder-lists, subscriptions, keys, etc.

Requirements
------------
* ruby  >=2.1
* thor

Installation
------------

1. Download [the gem](https://git.codecoop.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.0.1.beta9.gem) and [the OpenPGP-signature](https://git.codecoop.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.0.1.beta9.gem.sig) and verify:
   ```
   gpg --recv-key 0x75C9B62688F93AC6574BDE7ED8A6EF816E1C6F25
   gpg --verify schleuder-cli-0.0.1.beta9.gem.sig
   ```

2. If all went well install the gem:
   ```
   gem install schleuder-cli-0.0.1.beta9.gem
   ```

You probably want to install [schleuder](https://git.codecoop.org/schleuder/schleuder3), too. Without schleuder, this software is very useless.

Configuration
-------------

SchleuderConf reads its settings from a file that it by default expects at `$HOME/.schleuder-cli/schleuder-cli.yml`. To make it read a different file set the environment variable `SCHLEUDER_CLI_CONFIG` to the path to your file. E.g.:

    SCHLEUDER_CLI_CONFIG=/usr/local/etc/schleuder-cli.yml schleuder-cli ...

The configuration file specifies how to connect to the Schleuder API. To see an example have a look at the [defaults file](/etc/schleuder-cli.yml).

If you didn't change the defaults in the Schleuder configuration file you don't need a configuration file for SchleuderConf.

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
