//
//  NotifyRequest.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 22/1/18.
//  Copyright © 2018 Ashkan Hesaraki. All rights reserved.
//

import Foundation

protocol JSONAble {}

class NotifyRequest: JSONAble {
	var type: String!
	
	init(type: String) {
		self.type = type
	}
}

extension JSONAble {
	func toDict() -> [String: Any] {
		var dict = [String: Any]()
		let otherSelf = Mirror(reflecting: self)
		for child in otherSelf.children {
			if let key = child.label {
				dict[key] = child.value
			}
		}
		return dict
	}
}
