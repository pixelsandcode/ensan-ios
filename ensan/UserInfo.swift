//
//  UserInfo.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import Foundation

class UserInfo {
	
	static func setNotificationSchedule(value: Bool) {
		UserDefaults.standard.set(value, forKey: UserDefaultTag.notificationScheduled)
	}
	
	static func notificationScheduled() -> Bool {
		return UserDefaults.standard.bool(forKey: UserDefaultTag.notificationScheduled)
	}
	
	static func setIntroSeen(value: Bool) {
		UserDefaults.standard.set(value, forKey: UserDefaultTag.hasSeenIntro)
	}
	
	static func getIntroSeen() -> Bool {
		return UserDefaults.standard.bool(forKey: UserDefaultTag.hasSeenIntro)
	}
	
	static func setHasSent(value: Bool) {
		UserDefaults.standard.set(value, forKey: UserDefaultTag.hasSent)
	}
	
	static func hasSent() -> Bool {
		return UserDefaults.standard.bool(forKey: UserDefaultTag.hasSent)
	}
	
	static func setGuardians(_ guardians: [Guardian]) {
		let guardiansData = NSKeyedArchiver.archivedData(withRootObject: guardians)
		UserDefaults.standard.set(guardiansData, forKey: UserDefaultTag.guardinas)
	}
	
	static func getGuardians() -> [Guardian] {
		let guardiansData = UserDefaults.standard.object(forKey: UserDefaultTag.guardinas) as? NSData
		
		if let guardiansData = guardiansData {
			let guardians = NSKeyedUnarchiver.unarchiveObject(with: guardiansData as Data) as? [Guardian]
			
			if let guardians = guardians {
				return guardians
			}
		}
		
		return []
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
		print(getMobile()?.debugDescription)
		print(getUsername().debugDescription)
		print(getUserAuth().debugDescription)
		return getMobile() != nil && getUsername() != nil && getUserAuth() != nil
	}
	
	static func setUuids(_ uuids: [String]) {
		UserDefaults.standard.set(uuids, forKey: UserDefaultTag.uuids)
	}
	
	static func getUuids() -> [String] {
		return UserDefaults.standard.array(forKey: UserDefaultTag.uuids) as! [String]
	}
	
	static func setToken(token: String) {
		UserDefaults.standard.setValue(token, forKey: UserDefaultTag.token)
	}
	
	static func getToken() -> String? {
		return UserDefaults.standard.object(forKey: UserDefaultTag.token) as? String
	}
	
	static func getNotificationId() -> String? {
		return UserDefaults.standard.object(forKey: UserDefaultTag.notificationId) as? String
	}
	
	static func setNotificationId(_ id: String) {
		UserDefaults.standard.set(id, forKey: UserDefaultTag.notificationId)
	}
	
	static func setUserAuth(_ auth: String) {
		UserDefaults.standard.set(auth, forKey: UserDefaultTag.auth)
	}
	
	static func getUserAuth() -> String? {
		return UserDefaults.standard.object(forKey: UserDefaultTag.auth) as? String
	}
	
	static func setUserId(id: String) {
		UserDefaults.standard.set(id, forKey: UserDefaultTag.userId)
	}
	
	static func getUserId() -> String? {
		return UserDefaults.standard.object(forKey: UserDefaultTag.userId) as? String
	}
	
	static func getCurrentLocation() -> [String: Double] {
		let latitude = UserDefaults.standard.double(forKey: UserDefaultTag.lat)
		let longitude = UserDefaults.standard.double(forKey: UserDefaultTag.lon)
		return [UserDefaultTag.lat: latitude, UserDefaultTag.lon: longitude]
	}
	
	static func setCurrentLocation(_ latitude: Double, longitude: Double) {
		UserDefaults.standard.set(latitude, forKey: UserDefaultTag.lat)
		UserDefaults.standard.set(longitude, forKey: UserDefaultTag.lon)
	}
}
