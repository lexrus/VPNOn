# VPN On

[<img src="https://cloud.githubusercontent.com/assets/219689/5575342/963e0ee8-9013-11e4-8091-7ece67d64729.png" width="135" height="40" alt="AppStore"/>](https://itunes.apple.com/app/vpn-on/id951344279)

<img src="https://cloud.githubusercontent.com/assets/219689/6800494/f6f98af4-d259-11e4-91c8-dc9d9ded3bfd.gif" width="375" height="375" alt="Screencast"/>

<img src="https://cloud.githubusercontent.com/assets/219689/6913597/e7849b08-d7b4-11e4-9c3d-728717b2ab96.jpg" width="400" height="300" alt="AppleWatch"/>

Turning on a VPN is always a painful experience on an iOS device due to the deep nested menus. This App installs a Today Widget into Notification Center which make it possible to turn on a VPN in about 3 seconds(depends on the connection speed). Furthermore, by turning on On Demand feature, the VPN could be automatically connected when you visit any domain specified in this App. One more thing... You can even turn on a VPN with your shiny WATCH!!!

## Requirements

- An iPhone/iPad running iOS 8.1+
- An IPSec IKEv1 / IKEv2 VPN(create yours with [my Ansible Playbook](https://github.com/lexrus/vpn-deploy-playbook) or [deploy on DigitalOcean](http://installer.71m.us/install?url=https://github.com/lexrus/do-ikev1))
- Xcode 6.2
- An Apple iOS developer account

## Build with Xcode

To compile the project, you may temporarily modify the bundle_id after adding yours into the Apple Developer Center. And then activate the following capabilities of the container App and the extensions(TodayWidget and WatchKitExtension):

1. Personal VPN
2. Keychain Sharing
3. App Groups

Meanwhile, provisioning profiles are required for testing on iPhone/iPad.

## Usage

After creating a VPN configuration you can activate the Today Widget in Notification Center, then turn on the VPN by tapping switches or flags. You may be asked to allow the installation of a VPN profile for the first time.

## Contribution

Issues and roadmap are [listed here](https://github.com/lexrus/VPNOn/issues).

This project follows the gitflow workflow. You'd better create a branch called `feature/sth_improved` before any major improvements. Meanwhile minor bug fixes are welcomed in the develop branch.

## Localization

Please contribute to [the Transifex project](https://www.transifex.com/projects/p/vpnon/).

![Transifex Progress](https://www.transifex.com/projects/p/vpnon/resource/vpnonxliff/chart/image_png)

## URL Scheme

VPN service providers may list a link for their customers to efficiently add server configurations in VPN On. By register the `vpnon://` protocol, it supports the following URL scheme:

`vpnon://{account}:{password}@{server}/?title={title}&group={group}&secret={secret}&alwayson=[yes|no]&ikev2=[yes|no]&certificate={certificate}`

`server` and `title` are required, other fields are optional. The following URLs are valid:

* `vpnon://jony:ive@apple.com/?title=Apple&group=Design&secret=iPhone`

* `vpnon://apple.com/?title=Apple`

* `vpnon://admin@192.168.0.123/?title=Google&group=devops`

* `vpnon://admin@202.96.209.6/?title=Yahoo&alwayson=no`

* `vpnon://jony:ive@202.96.209.5/?title=Twitter&ikev2=yes` 

## Donation

Although this App is 100% open-sourced, it may takes about 20~60 minutes to configure the environment. I'd appreciate it if you could [buy VPN On from App Store](https://itunes.apple.com/app/vpn-on/id951344279).

BTW. I'm a coffee addict, buy me a coffee via PayPal or Alipay: `lexrus@gmail.com`

## Credits

* Japanese translation - [Onevcat](https://github.com/onevcat)
* Polish translation - [Seb Kaczorowski](http://photographyservices.ie)

[KeychainWrapper](https://github.com/jrendel/KeychainWrapper)
Note: I set the optimization level of VPNOnKit to `None` in order to read Keychain properly due to [an issue of Swift](http://stackoverflow.com/questions/26355630/swift-keychain-and-provisioning-profiles).

Flags are rasterized from [flag-icon-css](https://github.com/lipis/flag-icon-css).

## Contact

[Lex Tang](https://github.com/lexrus/) ([@lexrus on Twitter](https://twitter.com/lexrus/))

## License

This code is distributed under the terms and conditions of the MIT license.
