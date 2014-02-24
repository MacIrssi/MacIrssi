# MacIrssi

MacIrssi is an IRC client with a native Mac UI. It's based on [irssi](http://www.irssi.org/), an awesome command-line IRC client.

![](http://cl.ly/image/2v0j0F1C0W3o/Screen%20Shot%202014-02-24%20at%2009.33.43.png)

## Not-really-nightlies

You can download a binary version of MacIrssi [here](http://x3ro.de/downloads/MacIrssi/). These are currently updated whenever I get something worthwhile done, or if a bug gets fixed. If you encounter any issues, please let me know over at the [issue tracker](https://github.com/MacIrssi/MacIrssi/issues).


## Branching and Development ##

MacIrssi uses the [GitFlow](http://github.com/nvie/gitflow) style of branching and code maintainance. This means the branches have specific names and uses:

* master: The current release branch. Check this out and build if you want the latest version.
* develop: The current development HEAD, this is meant to be buildable and runnable at all times.
* feature/*: Feature branches for new work in the develop tree, very unstable and only really to be built if you need the feature. They disappear after being merged into develop.
* hotfix/*: A hotfix for the master branch.

It's a good bet that you want the develop branch, unless you're specifically looking to build your own release version. Patches to develop will be gladly accepted if useful, tidy and neat.


## Checking Out ##

To check out the MacIrssi code base, do the following

	# git clone <clone url>
	# git checkout <desired branch>
	# git submodule init
	# git submodule update


## Compiling ##

Compiling MacIrssi is a tricky beast. The plain Irssi core that powers MacIrssi requires glib in order to function. This means compiling up a bunch of GNU libraries in order to build the glib dylib, amongst others, needed to run MacIrssi.

To this end, there is a submodule in MacIrssi called MILibs. There is a target in the main project called "Build MILibs", this target does not get run automatically. You need to forcibly invoke this target, from the top level Xcode project, to build the required libraries. After that, you never need to run it again unless the version of MILibs changes.

Keep an eye out, if the Frameworks/MILibs subproject starts showing up in your diffs after you've checked out then you likely need to update the submodule checkout for that branch.

	# git submodule update
