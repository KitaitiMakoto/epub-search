EPUB Search
===========

Search engine for EPUB files on local machine

Installation
------------

    $ gem install epub-search

Usage
-----

    $ epub-search help
    Commands:
      epub-search add FILE                           # Add FILE to database
      epub-search help [COMMAND]                     # Describe available commands or one specific command
      epub-search init [DIR]                         # Setup database
      epub-search list                               # Show list of book titles in database
      epub-search remove FILE                        # Remove FILE from database
      epub-search search WORD [BOOK]                 # Search WORD in book whose title is like BOOK from database
      epub-search server                             # Run server
      epub-search watch [DIRECTORY [DIRECTORY ...]]  # Index all of EPUB files in DIRECTORY
    
    Options:
      -c, [--config=CONFIG]  # Path to config file

To watch directories in backend:

    $ epub-search watch --daemonize

Configuration
-------------

EPUB Search(`epub-search` command) detectes configuration file following by this order:

1. A file specified by `--config` global option
2. `.epub-searchrc` in current directory
3. `$HOME/.epub-search/config.yaml`

Configuration file should be written as YAML and you can set properties below:

* :dir: String. Directory for Groonga database and other files, defaults to $HOME/.epub-search/db
* :directories: Array of String. Directories `watch` subcommand watches.

ChangeLog
---------

### 0.0.3
* Specify the version of Listen gem

### 0.0.2
* Ruby vertion limited to 2.0
* Database directory changed
  * Exec `epub-search init` again
* Pid file is used to avoid multiple processes are running at once for epub-search watch

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
