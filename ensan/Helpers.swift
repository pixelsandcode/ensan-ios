//
//  Helpers.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 15/1/18.
//  Copyright © 2018 Ashkan Hesaraki. All rights reserved.
//

import Foundation
import Alamofire

class Helpers {
	static func getAndSaveToken(response: HTTPURLResponse) -> Bool {
		let headerFields = response.allHeaderFields
		let token = headerFields["Authorization"]
		if let token = token {
			UserInfo.setToken(token: token as! String)
			print("\(token)")
			return true
		} else {
			return false
		}
	}
	
	static func login(completion: @escaping (Bool) -> ()) {
		Alamofire.request(ApiRouter.Router.login()).log().validate().responseJSON() {
			response in
			
			if response.result.isSuccess {
				let saved: Bool = Helpers.getAndSaveToken(response: response.response!)
				completion(saved)
				
			} else {
				completion(false)
			}
		}
	}
}
