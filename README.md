# Butter
[![Build Status](https://travis-ci.org/butterproject/butter-desktop-angular.svg?branch=master)](https://travis-ci.org/butterproject/butter-desktop-angular) [![Dependency Status](https://david-dm.org/butterproject/butter-desktop-angular.svg)](https://david-dm.org/butterproject/butter-desktop-angular) [![devDependency Status](https://david-dm.org/butterproject/butter-desktop-angular/dev-status.svg)](https://david-dm.org/butterproject/butter-desktop-angular#info=devDependencies)

Allow any computer user to watch movies easily streaming from torrents, without any particular knowledge.

Visit the project's website at <https://butterproject.org>.

***

__WARNING__ : This project is in very early stage development and almost nothing works yet ! It will someday replace the current `butter-desktop` app based on others techs. This project is using __Electron__ + __Angular__ + __Coffee__. If you want to help and have any skills in one of these techs, please submit a PR and give Butter some love :-)

***

![Screenshot of Butter app](screenshot.png)

## Getting Involved

Want to report a bug, request a feature, contribute or translate Butter? Check out our in-depth guide to [Contributing to Butter](CONTRIBUTING.md). We need all the help we can get! You can also join in with our [community](README.md#community) to keep up-to-date and meet other Butterrs.

## Getting Started

If you're comfortable getting up and running from a `git clone`, this method is for you.

If you clone the GitHub repository, you will need to build a number of assets using grunt.

The [master](https://github.com/butterproject/butter-desktop-angular) branch which contains the latest release.

### Quickstart:

Note that in Ubuntu (or derivative system) you probably need to upgrade `nodejs` and `npm` version. To do so, run the following :

1. `curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -`
1. `sudo apt-get --yes install nodejs && sudo npm -g install npm`

Then you can start building Butter :

1. `npm install -g grunt-cli bower` (Linux: you **need** to run with `sudo`)
1. `npm install ## Install local dependencies in node_modules/`
1. `grunt build ## Build the Butter application`
1. `grunt start ## Start the Butter application`

Optionally, you may simply run `./make_butter.sh` if you are on a linux or mac based operating system.

You can also have a look at the [Dockerfile](Dockerfile) as a build example.

Full instructions & troubleshooting tips can be found in the [Contributing Guide](CONTRIBUTING.md)

### Generate executable packages

You can generate executable packages for all platforms with `grunt package`. The packages are in `dist/`.

## Community

Keep track of Butter development and community activity.

* Follow Butter on [Twitter](https://twitter.com/butterproject), [Facebook](https://www.facebook.com/ButterProjectOrg/) and [Google+](https://plus.google.com/communities/111003619134556931561).
* Read and subscribe to [The Official Butter Blog](https://github.com/butterproject/blog).
* Join in discussions on the [Butter Forum](https://discuss.butterproject.org)
* Connect with us on IRC at `#butterproject` on freenode ([web access](http://webchat.freenode.net/?channels=butterproject))

## Versioning

For transparency and insight into our release cycle, and for striving to maintain backward compatibility, Butter will be maintained according to the [Semantic Versioning](http://semver.org/) guidelines as much as possible.

Releases will be numbered with the following format:

`<major>.<minor>.<patch>-<build>`

Constructed with the following guidelines:

* A new *major* release indicates a large change where backward compatibility is broken.
* A new *minor* release indicates a normal change that maintains backward compatibility.
* A new *patch* release indicates a bugfix or small change which does not affect compatibility.
* A new *build* release indicates this is a pre-release of the version.

***

## License

If you distribute a copy or make a fork of the project, you have to credit this project as the source.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/ .

***

Copyright (c) 2015 Butter Project - Released under the
[GPL v3 license](LICENSE.txt).
