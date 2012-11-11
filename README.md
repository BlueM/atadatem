atadatem Overview
=================

Purpose
-------

Atadatem (“metadata” backwards) is a tiny (Mac) OS X command-line tool for recursively removing certain types of metadata files from one or more directories.

Using atadatem, you can remove any combination or all of the following:
* Remove .git directories
* Remove .svn directories
* Remove .DS_Store files
* Remove Icon files (actually, the name is “Icon\r”)

Usage
-----

Invoke atadatem without any options or arguments or with option -h to see usage information.

Examples
--------

Removing all .DS_Store files below a directory:

	atadatem -d /path/to/directory

Removing all the file and directory types listed above from two directories:

	atadatem -a /path/to/directory1 /path/to/directory2

Testing what would have been removed if you selected to remove all:

	atadatem -t -a /path/to/directory

Testing what Git and Subversion directories in your home directory would be removed:

    atadatem -gst ~

Compiling
---------
The repository contains an Xcode 3.2 project which should compile out of the box.

Author
-----
Carsten Blüm, [www.bluem.net](http://www.bluem.net/)

License
----------
[BSD License](http://www.opensource.org/licenses/bsd-license.php)
