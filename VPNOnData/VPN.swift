import Foundation
import CoreData
import VPNOnKit

open class VPNInfo {

    var title:          String = ""
    var server:         String = ""
    var account:        String = ""
    var password:       String = ""
    var group:          String = ""
    var secret:         String = ""
    var alwaysOn:       Bool   = false
    var countryCode:    String = ""
    var ikev2:          Bool   = false

}

open class VPN: NSManagedObject {
    
	@NSManaged var account:        String!
	@NSManaged var group:          String!
	@NSManaged var server:         String!
    @NSManaged var title:          String!
    @NSManaged var alwaysOn:       Bool
    @NSManaged var countryCode:    String?
    @NSManaged var ikev2:          Bool
    
    var ID: String {
        return objectID.uriRepresentation().absoluteString
    }
    
    override init(
        entity: NSEntityDescription,
        insertInto context: NSManagedObjectContext?
        ) {
            super.init(entity: entity, insertInto: context)
            setValue(account,        forKey: "account")
            setValue(group,          forKey: "group")
            setValue(server,         forKey: "server")
            setValue(title,          forKey: "title")
            setValue(alwaysOn,       forKey: "alwaysOn")
            setValue(countryCode,    forKey: "countryCode")
            setValue(ikev2,          forKey: "ikev2")
    }

	init(
        fromDictionary dictionary: NSDictionary,
        context: NSManagedObjectContext
        ) {
            let entity = NSEntityDescription
                .entity(forEntityName: "VPN", in: context)!
            
            super.init(entity: entity, insertInto: context)
            
            if let accountValue = dictionary["account"] as? String{
                account = accountValue
            }
            if let groupValue = dictionary["group"] as? String{
                group = groupValue
            }
            if let serverValue = dictionary["server"] as? String{
                server = serverValue
            }
            if let titleValue = dictionary["title"] as? String{
                title = titleValue
            }
            if let alwaysOnValue = dictionary["alwaysOn"] as? NSNumber {
                alwaysOn = alwaysOnValue.boolValue
            }
            if let countryCodeValue = dictionary["countryCode"] as? String {
                countryCode = countryCodeValue
            }
            if let ikev2Value = dictionary["ikev2"] as? NSNumber {
                ikev2 = ikev2Value.boolValue
            }
    }

	func toDictionary() -> NSDictionary {
		let dictionary = NSMutableDictionary()
        dictionary["ID"] = ID
		if account != nil {
			dictionary["account"] = account
		}
		if group != nil {
			dictionary["group"]  = group
		}
		if server != nil {
			dictionary["server"] = server
		}
		if title != nil {
			dictionary["title"]  = title
		}
        dictionary["alwaysOn"]   = NSNumber(value: alwaysOn)
        dictionary["ikev2"]      = NSNumber(value: ikev2)
        if countryCode != nil {
            dictionary["countryCode"] = countryCode
        }
		return dictionary
	}

}
