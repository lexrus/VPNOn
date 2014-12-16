//
//  LTVPNTableViewController.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData
import NetworkExtension
import VPNOnKit

let kVPNListSectionIndex = 0
let kVPNAddSection = 1
let kAddCellID = "AddCell"
let kVPNCellID = "VPNCell"

class LTVPNTableViewController: UITableViewController
{
    var vpns = [VPN]()
    var selectedRow = -1
    var activatedVPNID = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        vpns = VPNDataManager.sharedManager.allVPN()
        
        if let activatedVPN = VPNManager.sharedManager().activatedVPNDict as NSDictionary? {
            activatedVPNID = activatedVPN.objectForKey("ID") as String
        } else if vpns.count == 1 {
            activatedVPNID = vpns.first!.ID
            VPNManager.sharedManager().activatedVPNDict = vpns.first!.toDictionary()
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kVPNAddSection:
            return 1
        default:
            return vpns.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == kVPNAddSection {
            return tableView.dequeueReusableCellWithIdentifier(kAddCellID, forIndexPath: indexPath) as UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(kVPNCellID, forIndexPath: indexPath) as UITableViewCell
            
            cell.textLabel?.text = vpns[indexPath.row].title
            cell.detailTextLabel?.text = vpns[indexPath.row].server
            
            if activatedVPNID == vpns[indexPath.row].ID {
                cell.imageView!.image = UIImage(named: "CheckMark")
            } else {
                cell.imageView!.image = UIImage(named: "CheckMarkUnchecked")
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == kVPNListSectionIndex {
            activatedVPNID = vpns[indexPath.row].ID
            VPNManager.sharedManager().activatedVPNDict = vpns[indexPath.row].toDictionary()
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case kVPNListSectionIndex:
            return 60
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == kVPNListSectionIndex {
            return 30
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == kVPNListSectionIndex {
            return "VPN CONFIGURATIONS"
        }
        
        return .None
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC: AnyObject = segue.destinationViewController
        if destinationVC.isKindOfClass(LTVPNEditViewController)
        {
            if selectedRow != -1 {
                let VPNID = vpns[selectedRow].objectID
                let editVC = destinationVC as LTVPNEditViewController
                editVC.VPNObjectID = VPNID
                selectedRow = -1
            }
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if indexPath.section == kVPNListSectionIndex {
            selectedRow = indexPath.row
            performSegueWithIdentifier("edit", sender: self)
        }
    }
    
    // MARK: Navigation
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        
    }

}
