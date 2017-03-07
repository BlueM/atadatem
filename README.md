atadatem Overview
=================

Purpose
-------

Atadatem (“metadata” backwards) is a tiny macOS / OS X / Mac OS X command-line tool for recursively removing certain types of metadata files from one or more directories.

Using atadatem, you can remove any combination or all of the following:
* `.DS_Store` files
* Git-related metadata: `.git`, `.gitattributes`, `.gitmodules`, `.gitignore`, `.gitkeep`
* `.svn` directories
* Mac Icon files (actually, the name is `Icon\r`)
* JavaScript-related configuration/metadata: `.jshintrc`, `.jslintrc`, `.babelrc`
* Editor/IDE metadata: `.idea`, `.editorconfig`
* Integration/analysis tools’ metadata: `.travis.yml`, `.scrutinizer.yml`, `.coveralls.yml`, `.codeclimate.yml`


Usage
-----
Invoke `atadatem` without any options or arguments or with option `-h` to see usage information.


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
Project website: [www.bluem.net/jump/atadatem](www.bluem.net/jump/atadatem)


License
----------
[BSD License](http://www.opensource.org/licenses/bsd-license.php)
