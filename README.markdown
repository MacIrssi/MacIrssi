## Checking Out ##

To check out the MacIrssi code base, do the following

`# git clone <clone url>`
`# git checkout <desired branch>`
`# git submodule init`
`# git submodule update`

## Branching and Development ##

MacIrssi now uses the [GitFlow](http://github.com/nvie/gitflow) style of branching and code maintainance. This means the branches have specific names and uses:

* master: The current release branch. Check this out and build if you want the latest version.
* develop: The current development HEAD, this is meant to be buildable and runnable at all times.
* feature/*: Feature branches for new work in the develop tree, very unstable and only really to be built if you need the feature. They disappear after being merged into develop.
* hotfix/*: A hotfix for the master branch.

It's a good bet that you want the develop branch, unless you're specifically looking to build your own release version. Patches to develop will be gladly accepted if useful, tidy and neat.