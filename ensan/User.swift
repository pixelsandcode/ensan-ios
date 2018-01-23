//
//  User.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 15/1/18.
//  Copyright © 2018 Ashkan Hesaraki. All rights reserved.
//

import Foundation

final class User: ResponseObjectSerializable {
	
	var name: String!
	var mobile: String!
	var docKey: String?
	var auth: String?
	var state: String?
	
	init?(response: HTTPURLResponse, representation: Any) {
		guard let data = (representation as AnyObject)["data"] as? [String: AnyObject] else {
			return
		}
		
		self.name = data["name"] as? String
		self.auth = data["auth"] as? String
		self.docKey = data["docKey"] as? String
		self.state = data["state"] as? String
	}
	
	static func saveUser(_ user: User) {
		if let auth = user.auth {
			UserInfo.setUserAuth(auth)
		}
		
		if let id = user.docKey {
			UserInfo.setUserId(id: id)
		}
	}
}
