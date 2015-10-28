# VPN On

[![Travis](https://img.shields.io/travis/lexrus/VPNOn.svg)](https://travis-ci.org/lexrus/VPNOn)
![Language](https://img.shields.io/badge/language-Swift%202-orange.svg)
![License](https://img.shields.io/github/license/lexrus/VPNOn.svg?style=flat)

[<img src="https://cloud.githubusercontent.com/assets/219689/5575342/963e0ee8-9013-11e4-8091-7ece67d64729.png" width="135" height="40" alt="AppStore"/>](https://itunes.apple.com/app/vpn-on/id951344279)

<img src="https://cloud.githubusercontent.com/assets/219689/6800494/f6f98af4-d259-11e4-91c8-dc9d9ded3bfd.gif" width="375" height="375" alt="Screencast"/>

Turning on a VPN is always a painful experience on an iOS device due to the deep nested menus. This App installs a Today Widget into Notification Center which make it possible to turn on a VPN in about 3 seconds(depends on the connection speed). Furthermore, by turning on On Demand feature, the VPN could be automatically connected when you visit any domain specified in this App.

## Requirements

- An iPhone/iPad running iOS 8.0+
- An IPSec IKEv1 / IKEv2 VPN(create yours with [my Ansible Playbook](https://github.com/lexrus/vpn-deploy-playbook) or [deploy on DigitalOcean](http://installer.71m.us/install?url=https://github.com/lexrus/do-ikev1))
- Xcode 7+
- An Apple iOS developer account

## Build with Xcode

To compile the project, you may temporarily modify the bundle_id after adding yours into the Apple Developer Center. And then activate the following capabilities of the container App and the Today extension:

1. Personal VPN
2. Keychain Sharing
3. App Groups

Meanwhile, provisioning profiles are required for testing on iPhone/iPad.

## Usage

After creating a VPN configuration you can activate the Today Widget in Notification Center, then turn on the VPN by tapping switches or flags. You may be asked to allow the installation of a VPN profile for the first time.

## Contribution

Issues and roadmap are [listed here](https://github.com/lexrus/VPNOn/issues).

This project follows the [gitflow](https://github.com/nvie/gitflow) workflow. You'd better create a branch called `feature/sth_improved` before any major improvements. Meanwhile minor bug fixes are welcomed in the develop branch.

## Localization

Please contribute to [the Transifex project](https://www.transifex.com/projects/p/vpnon/).

![Transifex Progress](https://www.transifex.com/projects/p/vpnon/resource/vpnonxliff/chart/image_png)

## URL Scheme

### Add configuration with URL

VPN service providers may list a link for their customers to efficiently add server configurations in VPN On. By register the `vpnon://` protocol, it supports the following URL scheme:

`vpnon://{account}:{password}@{server}/?title={title}&group={group}&secret={secret}&alwayson=[yes|no]&ikev2=[yes|no]`

`server` and `title` are required, other fields are optional. The following URLs are valid:

* `vpnon://jony:ive@apple.com/?title=Apple&group=Design&secret=iPhone`

* `vpnon://apple.com/?title=Apple`

* `vpnon://admin@192.168.0.123/?title=Google&group=devops`

* `vpnon://admin@202.96.209.6/?title=Yahoo&alwayson=no`

* `vpnon://jony:ive@202.96.209.5/?title=Twitter&ikev2=yes`

### Establish connection with URL

* `vpnon://VPNTitle/?connect`
* `vpnon://VPNTitle/?connect&callback=https://twitter.com`

## Donation

Although this App is 100% open-sourced, it may takes about 20~60 minutes to configure the environment. I'd appreciate it if you could [buy VPN On from App Store](https://itunes.apple.com/app/vpn-on/id951344279).


## Credits

* Japanese translation - [Onevcat](https://github.com/onevcat)
* Polish translation - [Seb Kaczorowski](http://photographyservices.ie)
* Turkish - Ozancan Karataş
* Dutch (Netherlands) translation - [Niels Peen](https://github.com/nielspeen)

## License

This code is distributed under the terms and conditions of the MIT license.

```
Copyright (C) 2015 lexrus.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```