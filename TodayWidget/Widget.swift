//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Lex Tang on 12/10/14.
//  Copyright (c) 2014 lexrus.com. All rights reserved.
//

import UIKit
import NotificationCenter
import NetworkExtension
import VPNOnKit
import CoreData

private let kWidgetNormalHeight: CGFloat = 60

final class Widget:
    UIViewController,
    NCWidgetProviding {
    
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!

    fileprivate var marginLeft: CGFloat = 0 {
        didSet {
            leftConstraint.constant = marginLeft
            view.setNeedsUpdateConstraints()
        }
    }
    
    var vpns: [VPN] {
        return VPNDataManager.sharedManager.allVPN()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: kWidgetNormalHeight
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Widget.coreDataDidSave(_:)),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Widget.VPNStatusDidChange(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Widget.pingDidUpdate(_:)),
            name: NSNotification.Name(rawValue: kPingDidUpdate),
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: kPingDidUpdate),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateContent()
        collectionView.reloadData()
        LTPingQueue.sharedQueue.restartPing()

        preferredContentSize = CGSize(
            width: collectionView.contentSize.width,
            height: max(kWidgetNormalHeight, collectionView.contentSize.height)
        )

        // NOTE: Must remove the profile when there're no VPNs
        // otherwise there'll be a immutable profile live in system forever.
        if vpns.count == 0 {
            VPNManager.sharedManager.removeProfile()
        }

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(Widget.didTapLeftMargin(_:))
        )
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        leftMarginView.isUserInteractionEnabled = true
        leftMarginView.addGestureRecognizer(tapGesture)
        leftMarginView.backgroundColor = UIColor(white: 0.0, alpha: 0.005)

        let longGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(Widget.didLongPress(_:))
        )
        longGesture.delaysTouchesBegan = true
        view.addGestureRecognizer(longGesture)

        widgetPerformUpdate { _ in }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        leftMarginView.gestureRecognizers?.forEach {
            leftMarginView.removeGestureRecognizer($0)
        }
        view.gestureRecognizers?.forEach {
            view.removeGestureRecognizer($0)
        }
    }
    
    func updateContent() {
        // Note: In order to get the latest data.
        // @see: http://stackoverflow.com/questions/25924223/core-data-ios-8-today-widget-issue
        VPNDataManager.sharedManager.managedObjectContext?.reset()
    }
    
    func widgetPerformUpdate(
        completionHandler: ((NCUpdateResult) -> Void)
        ) {
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Layout
    
    func widgetMarginInsets(
        forProposedMarginInsets defaultMarginInsets: UIEdgeInsets
        ) -> UIEdgeInsets {
            marginLeft = defaultMarginInsets.left
            return .zero
    }
    
    // MARK: - Left margin
    
    func didTapLeftMargin(_ gesture: UITapGestureRecognizer) {
        LTPingQueue.sharedQueue.restartPing()
        collectionView.reloadData()
    }

    // MARK: - Open App

    func didLongPress(_ gesture: UITapGestureRecognizer) {
        didTapAdd()
    }
    
    func didTapAdd() {
        let appURL = URL(string: "vpnon://YOUR_SERVER_DOMAIN_OR_IP/?title=My VPN Server")!
        extensionContext?.open(appURL, completionHandler: nil)
    }
    
    // MARK: - Notification
    
    func pingDidUpdate(_ notification: Notification) {
        collectionView.reloadData()
    }
    
    func coreDataDidSave(_ notification: Notification) {
        VPNDataManager.sharedManager.managedObjectContext?
            .mergeChanges(fromContextDidSave: notification)
        updateContent()
    }
    
    func VPNStatusDidChange(_ notification: Notification?) {
        collectionView.reloadData()
        if VPNManager.sharedManager.status == .disconnected {
            LTPingQueue.sharedQueue.restartPing()
        }
    }
    
}
