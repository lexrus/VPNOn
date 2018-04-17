//
//  VPN+URLScheme.swift
//  VPNOn
//
//  Created by Lex on 1/23/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import Foundation

extension VPN {

    public class func parseURL(_ url: URL) -> VPNInfo? {
        var title = ""
        let server = url.host ?? ""
        let account = url.user ?? ""
        let password = url.password ?? ""
        var group = ""
        var secret = ""
        var alwaysOn = true
        var ikev2 = false
        var remoteID = ""
        
        // The server is required, otherwise we just open the container app.
        if server.count == 0 {
            return nil
        }
        
        // Parse the query string.
        if let params = url.query {
            for paramString in params.components(separatedBy: "&") {
                let param = paramString.components(separatedBy: "=")
                if param.count != 2 {
                    continue
                }
                
                let value = param[1]
                switch param[0] {
                case "title":
                    title = value

                case "group":
                    group = value

                case "secret":
                    secret = value

                case "alwayson":
                    alwaysOn = value.isLiteralTrue()

                case "ikev2":
                    ikev2 = value.isLiteralTrue()

                case "remoteid":
                    remoteID = value

                default: ()
                }
            }
        }
        
        let info = VPNInfo()
        info.title = title
        info.server = server
        info.account = account
        info.password = password
        info.group = group
        info.secret = secret
        info.alwaysOn = alwaysOn
        info.ikev2 = ikev2
        info.remoteID = remoteID
        
        return info
    }

}

extension String {

    fileprivate func isLiteralTrue() -> Bool {
        switch self.lowercased() {
        case "1", "true", "yes", "on": return true
        default: return false
        }
    }
}
