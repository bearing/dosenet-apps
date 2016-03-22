# Mobile Apps for Dosenet!

## Author(s)
- Navrit Bal [@navrit](https://github.com/navrit)
- Joseph Curtis [@jccurtis](https://github.com/jccurtis)

## Alamofire

The iOS app uses the [Alamofire](https://github.com/Alamofire/Alamofire) library for HTTP networking in Swift. In order to stay up-to-date with the Development of Alamofire, we have [submoduled](https://git-scm.com/book/en/v2/Git-Tools-Submodules) Alamofire in the iOS directory.

To clone this repo: `git clone --recursive https://github.com/bearing/dosenet-apps`

To update Alamofire to its master branch: `git submodule update --remote`.

## Android SDK

Some notes from installing on OSX:

- Bug: `Unable to obtain debug bridge`
- Install `Android SDK Platform Tools` and `Android Support Library` from the SDK manager (`Tools>Android>SDK Manager`)
