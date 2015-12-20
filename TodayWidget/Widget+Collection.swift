//
//  Widget+Collection.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension Widget {
    
    // MARK: - Collection View Data source
    
    func collectionView(
        collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
            return vpns.count + 1
    }
    
    func collectionView(
        collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath
        ) -> UICollectionViewCell {
            
            if indexPath.row == vpns.count {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                    "addCell",
                    forIndexPath: indexPath
                    ) as! AddCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                    "vpnCell",
                    forIndexPath: indexPath
                    ) as! VPNCell
                let vpn = vpns[indexPath.row]
                let selected = VPNManager.sharedManager.selectedVPNID == vpn.ID
                cell.configureWithVPN(vpns[indexPath.row], selected: selected)
                if selected {
                    cell.status = VPNManager.sharedManager.status
                } else {
                    cell.status = .Disconnected
                }
                
                cell.latency = LTPingQueue.sharedQueue
                    .latencyForHostname(vpn.server)
                
                return cell
            }
            
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(
        collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath
        ) {
            
            if indexPath.row == vpns.count {
                didTapAdd()
                
                return
            }
            
            let vpn = vpns[indexPath.row]
            
            if VPNManager.sharedManager.status == .Connected {
                if VPNManager.sharedManager.selectedVPNID == vpn.ID {
                    // Do not connect it again if tap the same one
                    return
                }
            }
            
            var account = vpn.toAccount()
            account.title = "Widget - \(vpn.title)"
            
            VPNManager.sharedManager.selectedVPNID = vpn.ID
            VPNManager.sharedManager.saveAndConnect(account)
    }
    
    func collectionView(
        collectionView: UICollectionView,
        shouldHighlightItemAtIndexPath indexPath: NSIndexPath
        ) -> Bool {
            
            if indexPath.row == vpns.count {
                return true
            }
            switch VPNManager.sharedManager.status {
            case .Connected, .Connecting:
                VPNManager.sharedManager.disconnect()
            default: ()
            }
            return true

    }
    
}
