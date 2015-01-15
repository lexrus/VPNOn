# VPN On

[<img src="https://cloud.githubusercontent.com/assets/219689/5575342/963e0ee8-9013-11e4-8091-7ece67d64729.png" width="135" height="40" alt="AppStore"/>](https://itunes.apple.com/app/vpn-on/id951344279)

<img src="https://cloud.githubusercontent.com/assets/219689/5629161/7472c794-95eb-11e4-8042-90469c1586cd.gif" width="375" height="375" alt="Screencast"/>

Turning on a VPN is always a painful experience on an iOS device due to the deep nested menus. This App installs a Today Widget into Notification Center which make it possible to turn on a VPN in about 3 seconds(depends on the connection speed).

## Requirements

- An iPhone running iOS 8.1
- An IPSec IKEv1 VPN(create yours with [my Ansible Playbook](https://github.com/lexrus/vpn-deploy-playbook) or [deploy on DigitalOcean](http://installer.71m.us/install?url=https://github.com/lexrus/do-ikev1))
- Xcode 6.1.1
- An Apple iOS developer account

## Build with Xcode

To compile the project, you may temporarily modify the bundle_id after adding yours into the Apple Developer Center. And then activate the following capabilities of both the container App and the widget:

1. Personal VPN
2. Keychain Sharing
3. App Groups

Meanwhile, provisioning profiles are required for testing on iPhone.

## Usage

After creating a VPN configuration you can activate the Today Widget in Notification Center, then turn on the VPN by tapping the switch. You may be asked to allow the installation of a VPN profile for the first time.

## Contribution

TODOs and issues are [listed here](https://github.com/lexrus/VPNOn/issues).

This project follows the gitflow workflow. You'd better create a branch called `feature/sth_improved` before any major improvements. Meanwhile minor bug fixes are welcomed in the develop branch.

## URL Scheme

VPN service providers may list a link for their customers to efficiently add server configurations in VPN On. By register the `vpnon://`protocol, it supports the following URL scheme:

`vpnon://{account}:{password}@{server}/?title={title}&group={group}&secret={secret}`

Fields are optional except the server field. The following URLs are valid:

`vpnon://jony:ive@apple.com/?title=Apple&group=Design&secret=iPhone`
`vpnon://apple.com/`
`vpnon://admin@192.168.0.123/?group=devops`

## App Store Submission

Most likely, Apple allows "Today" related widgets and rejects the others. Although it's impossible to pass the submission, I've just submit the tag 0.1 to App Store and pray for a miracle.

...

At last, [VPN On is now available on App Store](https://itunes.apple.com/app/vpn-on/id951344279)!

## Donate

I'm a coffee addict, buy me a coffee via PayPal or Alipay: `lexrus@gmail.com`

## Credits

[KeychainWrapper](https://github.com/jrendel/KeychainWrapper)

Note: I set the optimization level of VPNOnKit to `None` in order to read Keychain properly due to [an issue of Swift](http://stackoverflow.com/questions/26355630/swift-keychain-and-provisioning-profiles).

## Contact

[Lex Tang](https://github.com/lexrus/) ([@lexrus on Twitter](https://twitter.com/lexrus/))

## License

This code is distributed under the terms and conditions of the MIT license.
