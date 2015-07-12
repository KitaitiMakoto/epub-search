Change Log
==========

0.0.6
-----

* Lock Celluloid version to prevent compatibility breaking
* Remove server feature

0.0.5
-----

* Remove version specification for Listen gem

0.0.4
-----

* Remove recored which book was removed during sleeping

0.0.3
-----
* Specify the version of Listen gem as '>= 1.0.0' to aopt to changed API
* Use monitor for thread safety
* Remove record for book which was removed during watcher was sleeping
* Add recored of book which was added during watcher was sleeping

0.0.2
-----
* Ruby vertion limited to 2.0
* Database directory changed
  * Exec `epub-search init` again
* Pid file is used to avoid multiple processes are running at once for epub-search watch

0.0.1
-----
* First release
