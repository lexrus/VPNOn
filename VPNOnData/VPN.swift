import Foundation
import CoreData
import VPNOnKit

public class VPNInfo {
    var title:          String = ""
    var server:         String = ""
    var account:        String = ""
    var password:       String = ""
    var group:          String = ""
    var secret:         String = ""
    var alwaysOn:       Bool   = false
    var enabled:        Bool   = true
    var latency:        Int    = -1
    var latitude:       Float  = 0.0
    var longitude:      Float  = 0.0
    var countryCode:    String = ""
    var isp:            String = ""
    var ikev2:          Bool   = false
    var certificateURL: String = ""
    var domains:        String = ""
    var onDemand:       Bool   = false
}

@objc(VPN)
public class VPN : NSManagedObject{
    
	@NSManaged var account:        String!
	@NSManaged var group:          String!
	@NSManaged var server:         String!
    @NSManaged var title:          String!
    @NSManaged var alwaysOn:       Bool
    @NSManaged var enabled:        Bool
    @NSManaged var latency:        Int
    @NSManaged var latitude:       Float
    @NSManaged var longitude:      Float
    @NSManaged var countryCode:    String!
    @NSManaged var isp:            String!
    @NSManaged var ikev2:          Bool
    @NSManaged var certificateURL: String!
    @NSManaged var domains:        String!
    @NSManaged var onDemand:       Bool
    
    var ID : String {
        if let id = objectID.URIRepresentation().absoluteString {
            return id
        }
        return ""
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        setValue(account,        forKey: "account")
        setValue(group,          forKey: "group")
        setValue(server,         forKey: "server")
        setValue(title,          forKey: "title")
        setValue(alwaysOn,       forKey: "alwaysOn")
        setValue(enabled,        forKey: "enabled")
        setValue(latency,        forKey: "latency")
        setValue(latitude,       forKey: "latitude")
        setValue(longitude,      forKey: "longitude")
        setValue(countryCode,    forKey: "countryCode")
        setValue(isp,            forKey: "isp")
        setValue(ikev2,          forKey: "ikev2")
        setValue(certificateURL, forKey: "certificateURL")
        setValue(domains,        forKey: "domains")
        setValue(onDemand,       forKey: "onDemand")
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
        if let alwaysOnValue = dictionary["alwaysOn"] as? NSNumber {
            alwaysOn = alwaysOnValue.boolValue
        }
        if let enabledValue = dictionary["enabled"] as? NSNumber {
            enabled = enabledValue.boolValue
        }
        if let latencyValue = dictionary["latency"] as? NSNumber {
            latency = latencyValue.integerValue
        }
        if let latitudeValue = dictionary["latitude"] as? NSNumber {
            latitude = latitudeValue.floatValue
        }
        if let longitudeValue = dictionary["longitude"] as? NSNumber {
            longitude = longitudeValue.floatValue
        }
        if let countryCodeValue = dictionary["countryCode"] as? String {
            countryCode = countryCodeValue
        }
        if let ispValue = dictionary["isp"] as? String {
            isp = ispValue
        }
        if let ikev2Value = dictionary["ikev2"] as? NSNumber {
            ikev2 = ikev2Value.boolValue
        }
        if let certificateURLValue = dictionary["certificateURL"] as? String{
            certificateURL = certificateURLValue
        }
        if let domainsValue = dictionary["domains"] as? String{
            domains = domainsValue
        }
        if let onDemandValue = dictionary["onDemand"] as? NSNumber {
            onDemand = onDemandValue.boolValue
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
			dictionary["group"]  = group
		}
		if server != nil {
			dictionary["server"] = server
		}
		if title != nil {
			dictionary["title"]  = title
		}
        dictionary["alwaysOn"]   = NSNumber(bool: alwaysOn)
        dictionary["enabled"]    = NSNumber(bool: enabled)
        dictionary["latency"]    = NSNumber(integer: latency)
        dictionary["latitude"]   = NSNumber(float: latitude)
        dictionary["longitude"]  = NSNumber(float: longitude)
        dictionary["ikev2"]      = NSNumber(bool: ikev2)
        dictionary["onDemand"]   = NSNumber(bool: onDemand)
        if countryCode != nil {
            dictionary["countryCode"] = countryCode
        }
        if isp != nil {
            dictionary["isp"] = isp
        }
        if certificateURL != nil {
            dictionary["certificateURL"]  = certificateURL
        }
        if domains != nil {
            dictionary["domains"]  = domains
        }
		return dictionary
	}
}