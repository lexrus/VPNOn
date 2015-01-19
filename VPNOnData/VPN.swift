import Foundation
import CoreData
import VPNOnKit

class VPNInfo {
    var title: String = ""
    var server: String = ""
    var account: String = ""
    var password: String = ""
    var group: String = ""
    var secret: String = ""
    var alwaysOn: Bool = false
}

@objc(VPN)
class VPN : NSManagedObject{
    
	@NSManaged var account : String!
	@NSManaged var group : String!
	@NSManaged var server : String!
    @NSManaged var title : String!
    @NSManaged var alwaysOn : Bool
    
    var ID : String {
        if let id = objectID.URIRepresentation().lastPathComponent {
            return id
        }
        return ""
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        setValue(account, forKey: "account")
        setValue(group, forKey: "group")
        setValue(server, forKey: "server")
        setValue(title, forKey: "title")
        setValue(alwaysOn, forKey: "alwaysOn")
    }

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary, context: NSManagedObjectContext)	{
		let entity = NSEntityDescription.entityForName("VPN", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
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
        if let alwaysOnValue = dictionary["alwaysOn"] as? Bool {
            alwaysOn = alwaysOnValue
        }
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		var dictionary = NSMutableDictionary()
        dictionary["ID"] = ID
		if account != nil {
			dictionary["account"] = account
		}
		if group != nil {
			dictionary["group"] = group
		}
		if server != nil {
			dictionary["server"] = server
		}
		if title != nil {
			dictionary["title"] = title
		}
        dictionary["alwaysOn"] = alwaysOn
		return dictionary
	}
    
    func destroy() {
        VPNManager.sharedManager().removeProfile()
        
        self.managedObjectContext!.deleteObject(self)
    }
}