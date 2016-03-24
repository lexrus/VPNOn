//
//  MMDB.swift
//  MMDB
//
//  Created by Lex on 12/16/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import Foundation

public struct MMDBContinent {
    public var code: String?
    public var names: [String: String]?
}

public struct MMDBCountry: CustomStringConvertible {
    public var continent = MMDBContinent()
    public var isoCode = ""
    public var names = [String: String]()

    init(dictionary: NSDictionary) {
        if let dict = dictionary["continent"],
            code = dict["code"] as? String,
            continentNames = dict["names"] as? [String: String] {
            continent.code = code
            continent.names = continentNames
        }
        if let dict = dictionary["country"],
            iso = dict["iso_code"] as? String,
            countryNames = dict["names"] as? [String: String] {
            self.isoCode = iso
            self.names = countryNames
        }
    }
    
    public var description: String {
        var s = "{\n"
        s += "  \"continent\": {\n"
        s += "    \"code\": \"" + (self.continent.code ?? "") + "\",\n"
        s += "    \"names\": {\n"
        var i = self.continent.names?.count ?? 0
        self.continent.names?.forEach {
            s += "      \""
                + $0.0 + ": \""
                + $0.1 + "\""
                + (i > 1 ? "," : "")
                + "\n"
            i -= 1
        }
        s += "    }\n"
        s += "  },\n"
        s += "  \"isoCode\": \"" + self.isoCode + "\",\n"
        s += "  \"names\": {\n"
        i = self.names.count
        self.names.forEach {
            s += "    \""
                + $0.0 + ": \""
                + $0.1 + "\""
                + (i > 1 ? "," : "")
                + "\n"
            i -= 1
        }
        s += "  }\n}"
        return s
    }
}

final public class MMDB {

    private var db = MMDB_s()

    private typealias ListPtr = UnsafeMutablePointer<MMDB_entry_data_list_s>
    private typealias StringPtr = UnsafeMutablePointer<String>

    public init?(_ filename: String = "") {
        var cfilename = (filename as NSString).UTF8String
        var cfilenamePtr = UnsafePointer<Int8>(cfilename)

        var status = MMDB_open(cfilenamePtr, UInt32(MMDB_MODE_MASK), &db)
        if status != MMDB_SUCCESS {
            print(String.fromCString(MMDB_strerror(errno)))
            // Failover to db in bundle
            let bundle = NSBundle(forClass: MMDB.self)
            guard let path =
                bundle.pathForResource("GeoLite2-Country", ofType: "mmdb") else {
                    return nil
            }
            cfilename = (path as NSString).UTF8String
            cfilenamePtr = UnsafePointer<Int8>(cfilename)
            status = MMDB_open(cfilenamePtr, UInt32(MMDB_MODE_MASK), &db)
            if status != MMDB_SUCCESS {
                print(String.fromCString(MMDB_strerror(errno)))
                return nil
            }
        }
    }

    private func lookupString(s: String) -> MMDB_lookup_result_s? {
        let string = (s as NSString).UTF8String
        let stringPtr = UnsafePointer<Int8>(string)

        var gaiError: Int32 = 0
        var error: Int32 = 0

        let result = MMDB_lookup_string(&db, stringPtr, &gaiError, &error)
        if gaiError == noErr && error == noErr {
            return result
        }
        return nil
    }


    private func getString(list: ListPtr) -> String {
        var data = list.memory.entry_data
        let type = (Int32)(data.type)

        // Ignore other useless keys
        guard data.has_data && type == MMDB_DATA_TYPE_UTF8_STRING else {
            return ""
        }

        let str = MMDB_get_entry_data_char(&data)
        let size = size_t(data.data_size)
        let cKey = mmdb_strndup(str, size)
        let key = String.fromCString(cKey)
        free(cKey)

        return key ?? ""
    }

    private func getType(list: ListPtr) -> Int32 {
        let data = list.memory.entry_data
        return (Int32)(data.type)
    }

    private func getSize(list: ListPtr) -> UInt32 {
        return list.memory.entry_data.data_size
    }

    private func dumpList(var list: ListPtr, toS: StringPtr) -> ListPtr {
        switch getType(list) {

        case MMDB_DATA_TYPE_MAP:
            toS.memory += "{\n"
            var size = getSize(list)

            list = list.memory.next
            while size != 0 && list != nil {
                toS.memory += "\"" + getString(list) + "\":"

                list = list.memory.next
                list = dumpList(list, toS: toS)
                size -= 1
            }
            toS.memory += "},"
            break

        case MMDB_DATA_TYPE_UTF8_STRING:
            toS.memory += "\"" + getString(list) + "\","
            list = list.memory.next
            break

        case MMDB_DATA_TYPE_UINT32:
            toS.memory += String(
                format: "%u",
                MMDB_get_entry_data_uint32(&list.memory.entry_data)
                ) + ","
            list = list.memory.next
            break

        default:
            ()

        }

        return list
    }

    private func lookupJSON(s: String) -> String? {
        guard let result = lookupString(s) else {
            return nil
        }

        var entry = result.entry
        var list = ListPtr()

        let status = MMDB_get_entry_data_list(&entry, &list)
        if status != MMDB_SUCCESS {
            return nil
        }

        var JSONString = ""
        dumpList(list, toS: &JSONString)

        JSONString = JSONString.stringByReplacingOccurrencesOfString(
            "},},},",
            withString: "}}}"
        )

        MMDB_free_entry_data_list(list)

        return JSONString
    }

    public func lookup(IPString: String) -> MMDBCountry? {
        guard let s = lookupJSON(IPString) else {
            return nil
        }

        guard let data = s.dataUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }

        let JSON = try? NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions.AllowFragments)

        guard let dict = JSON as? NSDictionary else {
            return nil
        }

        let country = MMDBCountry(dictionary: dict)

        return country
    }

    deinit {
        MMDB_close(&db)
    }

}
