//
//  UserInfo.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import Foundation

class UserInfo {
	
	static func setIntroSeen(value: Bool) {
		UserDefaults.standard.set(value, forKey: UserDefaultTag.hasSeenIntro)
	}
	
	static func getIntroSeen() -> Bool {
		return UserDefaults.standard.bool(forKey: UserDefaultTag.hasSeenIntro)
	}
	
	static func setGuardians(_ dict: [String: String]) {
		UserDefaults.standard.set(dict, forKey: UserDefaultTag.guardinas)
	}
	
	static func getGuardians() -> [String: String] {
		let guardians =  UserDefaults.standard.dictionary(forKey: UserDefaultTag.guardinas)
		if guardians != nil {
			return guardians as! [String: String]
		} else {
			return [:] as! [String: String]
		}
	}
	
	static func setUsername(_ value: String) {
		UserDefaults.standard.set(value, forKey: UserDefaultTag.username)
	}
	
	static func getUsername() -> String? {
		return UserDefaults.standard.string(forKey: UserDefaultTag.username)
	}
	
	static func setMobile(_ value: String) {
		UserDefaults.standard.set(value, forKey: UserDefaultTag.mobile)
	}
	
	static func getMobile() -> String? {
		return UserDefaults.standard.string(forKey: UserDefaultTag.mobile)
	}
	
	static func isUser() -> Bool {
		return getMobile() != nil && getUsername() != nil
	}
}
