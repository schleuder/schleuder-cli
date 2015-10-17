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
      schleuder-conf check_keys list@hostname  # Check for expiring or unusable keys.
      schleuder-conf help [COMMAND]            # Describe available commands or one specific command
      schleuder-conf list ...                  # Create and manage lists
      schleuder-conf schleuder_version         # Show version of schleuder at the server.
      schleuder-conf subscription ...          # Create and manage subscriptions
      schleuder-conf version                   # Show version of h

    Options:
      -p, [--port=PORT]  # The port schleuderd is listening at.
                         # Default: 4567

