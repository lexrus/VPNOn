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

final class Widget:
    UIViewController,
    NCWidgetProviding {
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellSize: CGSize {
        let width: CGFloat
        let maxWidth = collectionView.bounds.width - 20
        
        if UIScreen.main.bounds.width <= 414 {
            width = maxWidth / 4
        } else {
            width = 90
        }
        
        return CGSize(width: width, height: 100)
    }
    
    var vpns: [VPN] {
        return VPNDataManager.sharedManager.allVPN()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .compact
        } else {
            preferredContentSize = CGSize(
                width: collectionView.bounds.width,
                height: cellSize.height
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateContent()
        collectionView.reloadData()
        LTPingQueue.sharedQueue.restartPing()

        // NOTE: Must remove the profile when there're no VPNs
        // otherwise there'll be a immutable profile live in system forever.
        if vpns.count == 0 {
            VPNManager.sharedManager.removeProfile()
        } else if vpns.count > 4 {
            if #available(iOSApplicationExtension 10.0, *) {
                extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            }
        }

        let longGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(Widget.didLongPress(_:))
        )
        longGesture.delaysTouchesBegan = true
        view.addGestureRecognizer(longGesture)
        
        widgetPerformUpdate { _ in }
        
        var width = UIScreen.main.bounds.width
        
        if #available(iOSApplicationExtension 10.0, *) {
            if let context = extensionContext {
                context.widgetLargestAvailableDisplayMode = .expanded
                width = context.widgetMaximumSize(for: .compact).width
            }
            preferredContentSize = CGSize(
                width:  width,
                height: cellSize.height
            )
        } else {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.collectionViewLayout.prepare()
            preferredContentSize = collectionView.collectionViewLayout.collectionViewContentSize
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
    }
    
    func updateContent() {
        // Note: In order to get the latest data.
        // @see: http://stackoverflow.com/questions/25924223/core-data-ios-8-today-widget-issue
        VPNDataManager.sharedManager.managedObjectContext?.reset()
    }
    
    private func widgetPerformUpdate(
        completionHandler: ((NCUpdateResult) -> Void)
        ) {
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Layout
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if activeDisplayMode == .compact {
            preferredContentSize = CGSize(width: maxSize.width, height: cellSize.height)
        } else {
            preferredContentSize = CGSize(width: maxSize.width, height: collectionView.contentSize.height)
        }
    }

    func widgetMarginInsets(
        forProposedMarginInsets defaultMarginInsets: UIEdgeInsets
        ) -> UIEdgeInsets {
            return .zero
    }
    // MARK: - Open App

    func didLongPress(_ gesture: UITapGestureRecognizer) {
        didTapAdd()
    }
    
    func didTapAdd() {
        let appURL = URL(string: "vpnon://your.server/?title=MyVPN")!
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
