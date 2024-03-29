//
//  AppDelegate.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import UserNotifications
import Alamofire
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	
	var window: UIWindow?
	let gcmMessageIDKey = "gcm.message_id"
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		// Use Firebase library to configure APIs
		FirebaseApp.configure()
		Messaging.messaging().delegate = self
		
		
		if #available(iOS 10.0, *) {
			// For iOS 10 display notification (sent via APNS)
			self.setCategories()
			UNUserNotificationCenter.current().delegate = self
			
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {_, _ in })
		} else {
			let settings: UIUserNotificationSettings =
				UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			UIApplication.shared.registerUserNotificationSettings(settings)
		}
		
		UIApplication.shared.registerForRemoteNotifications()
		
		return true
	}
	
	
	// [START receive_message]
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
									 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		completionHandler(UIBackgroundFetchResult.newData)
	}
	// [END receive_message]
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Unable to register for remote notifications: \(error.localizedDescription)")
	}
	
	// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
	// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
	// the FCM registration token.
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		print("APNs token retrieved: \(deviceToken)")
		
		// With swizzling disabled you must set the APNs token here.
		// Messaging.messaging().apnsToken = deviceToken
	}
	
	func setCategories(){
		if #available(iOS 10.0, *) {
			let callAction = UNNotificationAction(identifier: "call.action", title: "Call", options: [])
			let mapAction = UNNotificationAction(identifier: "map.action", title: "Map", options: [])
			let dangerCategory = UNNotificationCategory(identifier: "DANGER_CATEGORY", actions: [callAction, mapAction], intentIdentifiers: [], options: [])
			UNUserNotificationCenter.current().setNotificationCategories([dangerCategory])
		} else {
			// Fallback on earlier versions
		}
	}
	func openMapForPlace(lat: Double, lon: Double, name: String) {
		
		let latitude: CLLocationDegrees = lat
		let longitude: CLLocationDegrees = lon
		
		let regionDistance:CLLocationDistance = 10000
		let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
		let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
		let options = [
			MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
			MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
		]
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
		let mapItem = MKMapItem(placemark: placemark)
		mapItem.name = name
		mapItem.openInMaps(launchOptions: options)
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
	
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
															willPresent notification: UNNotification,
															withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		// Change this to your preferred presentation option
		
		completionHandler([.alert, .badge, .sound])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
															didReceive response: UNNotificationResponse,
															withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		let action = response.actionIdentifier
		let request = response.notification.request
		let _ = request.content
		
		if action == "call.action" {
			if let mobile = userInfo["mobile"] as? String {
				let url: NSURL = URL(string: "TEL://\(mobile)")! as NSURL
				UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
			}
		}
		
		if action == "map.action" {
			guard let lat = userInfo["lat"] as? String else {
				return
			}

			guard let lon = userInfo["lon"] as? String else {
				return
			}
			
			guard let name = userInfo["name"] as? String else {
				return
			}
			
			if let latitude = Double(lat), let longitude = Double(lon) {
				self.openMapForPlace(lat: latitude, lon: longitude, name: name)
			}
		}
		
		completionHandler()
	}
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
	// [START refresh_token]
	func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
		print("Firebase registration token: \(fcmToken)")
		UserInfo.setNotificationId(fcmToken)
		if UserInfo.isUser() {
			Alamofire.request(ApiRouter.Router.registerDevice()).log().validate().responseJSON() {
				response in
				
				if response.result.isSuccess {
					print("notification sent to api")
				} else {
					print(response.result.error.debugDescription)
				}
			}
		}
	}
	// [END refresh_token]
	// [START ios_10_data_message]
	// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
	// To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
	func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
		print("Received data message: \(remoteMessage.appData)")
	}
	// [END ios_10_data_message]
}

