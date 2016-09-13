Schleuder-conf
==============

A command line tool to configure schleuder-lists.

Schleuder-conf enables creating, configuring, and deleting schleuder-lists, subscriptions, keys, etc. Currently it must be run on the same system that runs the schleuderd.

Requirements
------------
* ruby  >=2.1
* thor

Installation
------------

1. Download [the gem](https://git.codecoop.org/schleuder/schleuder-conf/raw/master/gems/schleuder-conf-0.0.1.beta4.gem) and [the OpenPGP-signature](https://git.codecoop.org/schleuder/schleuder-conf/raw/master/gems/schleuder-conf-0.0.1.beta4.gem.sig) and verify:
   ```
   gpg --recv-key 0x75C9B62688F93AC6574BDE7ED8A6EF816E1C6F25
   gpg --verify schleuder-conf-0.0.1.beta4.gem.sig
   ```

2. If all went well install the gem:
   ```
   gem install schleuder-conf-0.0.1.beta4.gem
   ```

You probably want to install [schleuder](https://git.codecoop.org/schleuder/schleuder3), too. Without schleuder, this software is very useless.

Usage
-----
See `schleuder-conf help`.

E.g.:

    Commands:
      schleuder-conf help [COMMAND]     # Describe available commands or one specific command
      schleuder-conf keys ...           # Manage OpenPGP-keys
      schleuder-conf lists ...          # Create and configure lists
      schleuder-conf subscriptions ...  # Create and manage subscriptions
      schleuder-conf version            # Show version of schleuder-conf or schleuderd.

    Options:
      -p, [--port=<number>]  # The port schleuderd is listening at.
                             # Default: 4567

