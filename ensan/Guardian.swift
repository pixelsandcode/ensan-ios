//
//  Guardian.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 2/1/18.
//  Copyright © 2018 Ashkan Hesaraki. All rights reserved.
//

import Foundation

final class Guardian: NSObject, NSCoding, ResponseCollectionSerializable {
	
	var name: String = ""
	var mobile: String = ""
	var sent: Bool = true
	var state: String = "Pending"
	var id: String = ""
	
	override init() {
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.sent = aDecoder.decodeBool(forKey: "sent")
		self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
		self.mobile = aDecoder.decodeObject(forKey: "mobile") as? String ?? ""
		self.state = aDecoder.decodeObject(forKey: "state") as? String ?? ""
		self.id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(mobile, forKey: "mobile")
		aCoder.encode(state, forKey: "state")
		aCoder.encode(sent, forKey: "sent")
		aCoder.encode(id, forKey: "id")
	}
	
	init(name: String, mobile: String) {
		self.name = name
		self.mobile = mobile
	}
	
	required init?(response: HTTPURLResponse, representation: [String: AnyObject]) {
		self.name = representation["name"] as! String
		self.mobile = representation["mobile"] as! String
		self.state = representation["state"] as! String
		self.id = representation["docKey"] as! String
	}
	
	static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Guardian] {
		var guardians: [Guardian] = []
		
		guard let representation = representation as? [String: AnyObject] else {
			return []
		}
		
		if let data = representation["data"] as? [[String: AnyObject]] {
			for rep in data {
				if let guardian = Guardian(response: response, representation: rep) {
					guardians.append(guardian)
				}
			}
		}
		
		return guardians
	}
}
