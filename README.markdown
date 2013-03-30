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
      epub-search init [DB_DIR]                      # Setup database
      epub-search list                               # Show list of book titles in database
      epub-search remove FILE                        # Remove FILE from database
      epub-search search WORD [BOOK]                 # Search WORD in book whose title is like BOOK from database
      epub-search server                             # Run server
      epub-search watch [DIRECTORY [DIRECTORY ...]]  # Index all of EPUB files in DIRECTORY
    
    Options:
      -c, [--config=CONFIG]  # Path to config file

To watch directories in backend:

    $ epub-search watch >/dev/null 2>&1 &

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
