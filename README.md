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
`gem install schleuder-conf`

or

`cd schleuder-conf && bundle install`

You probably want to install schleuder, too. Without schleuder, this software is very useless.

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

