## Checking Out ##

To check out the MacIrssi code base, do the following

	# git clone <clone url>
	# git checkout <desired branch>
	# git submodule init
	# git submodule update

## Branching and Development ##

MacIrssi now uses the [GitFlow](http://github.com/nvie/gitflow) style of branching and code maintainance. This means the branches have specific names and uses:

* master: The current release branch. Check this out and build if you want the latest version.
* develop: The current development HEAD, this is meant to be buildable and runnable at all times.
* feature/*: Feature branches for new work in the develop tree, very unstable and only really to be built if you need the feature. They disappear after being merged into develop.
* hotfix/*: A hotfix for the master branch.

It's a good bet that you want the develop branch, unless you're specifically looking to build your own release version. Patches to develop will be gladly accepted if useful, tidy and neat.

## Compiling ##

Compiling MacIrssi is a tricky beast. The plain Irssi core that powers MacIrssi requires glib in order to function. This means compiling up a bunch of GNU libraries in order to build the glib dylib, amongst others, needed to run MacIrssi.

To this end, there is a submodule in MacIrssi called MILibs. There is a target in the main project called "Build MILibs", this target does not get run automatically. You need to forcibly invoke this target, from the top level Xcode project, to build the required libraries. After that, you never need to run it again unless the version of MILibs changes.

Keep an eye out, if the Frameworks/MILibs subproject starts showing up in your diffs after you've checked out then you likely need to update the submodule checkout for that branch.

	# git submodule update

## Not-really-nightlies ##

Builds as-and-when I'm working on MacIrssi will tend to appear in the [Downloads](http://github.com/daagaak/MacIrssi/downloads) section of the Github project. I don't have any machines I can build this on automatically, so there are no 'real' nighties.