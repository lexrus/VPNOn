//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Lex Tang on 12/10/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import NotificationCenter
import NetworkExtension
import VPNOnKit
import CoreData

private let kExpanedInToday = "kVPNOnExpanedInToday"
private let kWidgetNormalHeight: CGFloat = 82

final class Widget:
    UIViewController,
    NCWidgetProviding,
    UICollectionViewDelegate,
    UICollectionViewDataSource {
    
    @IBOutlet weak var leftMarginView: ModeButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!

    private var hasSignaled = false
    private var complitionHandler: (NCUpdateResult -> Void)?

    var marginLeft: CGFloat = 0 {
        didSet {
            self.leftConstraint.constant = marginLeft
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    var vpns: [VPN] {
        return VPNDataManager.sharedManager.allVPN()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(
            width: UIScreen.mainScreen().bounds.width,
            height: kWidgetNormalHeight
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(Widget.coreDataDidSave(_:)),
            name: NSManagedObjectContextDidSaveNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(Widget.VPNStatusDidChange(_:)),
            name: NEVPNStatusDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(Widget.pingDidUpdate(_:)),
            name: kPingDidUpdate,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: NSManagedObjectContextDidSaveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: NEVPNStatusDidChangeNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: kPingDidUpdate,
            object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
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
        leftMarginView.userInteractionEnabled = true
        leftMarginView.addGestureRecognizer(tapGesture)
        leftMarginView.backgroundColor = UIColor(white: 0.0, alpha: 0.005)
        leftMarginView.displayMode =
            VPNManager.sharedManager.displayFlags ? .FlagMode : .SwitchMode

        let longGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(Widget.didLongPress(_:))
        )
        longGesture.delaysTouchesBegan = true
        view.addGestureRecognizer(longGesture)

        widgetPerformUpdateWithCompletionHandler { _ in }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        leftMarginView.gestureRecognizers?.forEach {
            leftMarginView.removeGestureRecognizer($0)
        }
        view.gestureRecognizers?.forEach {
            view.removeGestureRecognizer($0)
        }
    }
    
    // Note: A workaround to ensure the widget is interactable.
    // @see: http://stackoverflow.com/questions/25961513/ios-8-today-widget-stops-working-after-a-while
    func singalComplete(updateResult: NCUpdateResult) {
        hasSignaled = true
        complitionHandler?(updateResult)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !hasSignaled {
            singalComplete(NCUpdateResult.Failed)
        }
    }
    
    func updateContent() {
        // Note: In order to get the latest data.
        // @see: http://stackoverflow.com/questions/25924223/core-data-ios-8-today-widget-issue
        VPNDataManager.sharedManager.managedObjectContext?.reset()
    }
    
    func widgetPerformUpdateWithCompletionHandler(
        completionHandler: ((NCUpdateResult) -> Void)
        ) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        self.complitionHandler = completionHandler
        completionHandler(NCUpdateResult.NewData)
    }
    
    // MARK: - Layout
    
    func widgetMarginInsetsForProposedMarginInsets(
        defaultMarginInsets: UIEdgeInsets
        ) -> UIEdgeInsets {
            marginLeft = defaultMarginInsets.left
            return UIEdgeInsetsZero
    }
    
    // MARK: - Left margin
    
    func didTapLeftMargin(gesture: UITapGestureRecognizer) {
        LTPingQueue.sharedQueue.restartPing()
        VPNManager.sharedManager.displayFlags =
            !VPNManager.sharedManager.displayFlags
        collectionView.reloadData()

        leftMarginView.displayMode =
            VPNManager.sharedManager.displayFlags
            ? .FlagMode
            : .SwitchMode
    }

    // MARK: - Open App

    func didLongPress(gesture: UITapGestureRecognizer) {
        didTapAdd()
    }
    
    func didTapAdd() {
        let appURL = NSURL(string: "vpnon://")!
        extensionContext?.openURL(appURL, completionHandler: nil)
    }
    
    // MARK: - Notification
    
    func pingDidUpdate(notification: NSNotification) {
        collectionView.reloadData()
    }
    
    func coreDataDidSave(notification: NSNotification) {
        VPNDataManager.sharedManager.managedObjectContext?
            .mergeChangesFromContextDidSaveNotification(notification)
        updateContent()
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        collectionView.reloadData()
        if VPNManager.sharedManager.status == .Disconnected {
            LTPingQueue.sharedQueue.restartPing()
        }
    }
    
}
