//
//  MainViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI
import Alamofire
import UserNotifications
import SwiftSpinner
import CoreLocation

class MainViewController: UIViewController {
	
	@IBOutlet var mainView: UIView!
	@IBOutlet weak var plusButton: UIImageView!
	@IBOutlet weak var mainTitleLabel: UILabel!
	@IBOutlet weak var mainSubtitleLabel: UILabel!
	@IBOutlet weak var closeFriendListLabel: UILabel!
	@IBOutlet weak var closeFriendHintLabel: UILabel!
	@IBOutlet weak var viewImage: UIImageView!
	@IBOutlet weak var hurtImage: UIImageView!
	@IBOutlet weak var fineImage: UIImageView!
	@IBOutlet weak var actionContainer: UIStackView!
	
	var pickedContact: Guardian = Guardian()
	let gcmMessageIDKey = "gcm.message_id"
	let locationManager = CLLocationManager()
	var location: Location?
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on...
		if UserInfo.isUser() {
			Helpers.showLoading()
		}
		self.setupButtons()
		self.handleByGuardians()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.sendDeviceToken()
		
		if UserInfo.isUser() {
			self.getGuardians()
		}
		
		let guardiansCount = UserInfo.getGuardians().count
		if !UserInfo.notificationScheduled() && guardiansCount == 0 {
			self.setupNotification()
		}
		
		self.manageLocationPermission()
	}
	
	// MARK: Local notification
	func setupNotification() {
		let firstNotification = UILocalNotification()
		firstNotification.alertBody = MainStrings.localNotificationAlert
		firstNotification.alertAction = MainStrings.ok
		let firstDate = Date().addDays(1)
		firstNotification.fireDate = firstDate
		firstNotification.soundName = UILocalNotificationDefaultSoundName
		let firstUuid = UUID().uuidString
		firstNotification.userInfo = ["title": ValidationErrors.alert, "UUID": firstUuid]
		UIApplication.shared.scheduleLocalNotification(firstNotification)
		
		let secondNotification = UILocalNotification()
		secondNotification.alertBody = MainStrings.localNotificationAlert
		secondNotification.alertAction = MainStrings.ok
		let secondDate = Date().addDays(3)
		secondNotification.soundName = UILocalNotificationDefaultSoundName
		secondNotification.fireDate = secondDate
		let secondUuid = UUID().uuidString
		secondNotification.userInfo = ["title": ValidationErrors.alert, "UUID": secondUuid]
		UIApplication.shared.scheduleLocalNotification(secondNotification)
		
		let thirdNotification = UILocalNotification()
		thirdNotification.alertBody = MainStrings.localNotificationAlert
		thirdNotification.alertAction = MainStrings.ok
		let thirdDate = Date().addDays(7)
		thirdNotification.soundName = UILocalNotificationDefaultSoundName
		thirdNotification.fireDate = thirdDate
		let thirdUuid = UUID().uuidString
		thirdNotification.userInfo = ["title": ValidationErrors.alert, "UUID": thirdUuid]
		UIApplication.shared.scheduleLocalNotification(thirdNotification)
		
		UserInfo.setUuids([firstUuid, secondUuid, thirdUuid])
		UserInfo.setNotificationSchedule(value: true)
	}
	
	func removeNotifications(uuid: String) {
		let scheduledNotifications: [UILocalNotification]? = UIApplication.shared.scheduledLocalNotifications
		guard scheduledNotifications != nil else {return} // Nothing to remove, so return
		
		for notification in scheduledNotifications! { // loop through notifications...
			if (notification.userInfo!["UUID"] as! String == uuid) {
				UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on UUID
				break
			}
		}
	}
	
	// MARK: - Actions
	func plusTapped() {
		if UserInfo.isUser() {
			self.selectContact()
		} else {
			self.pickedContact.sent = false
			self.performSegueWithIdentifier(segueIdentifier: .showSignUp, sender: self)
		}
	}
	
	func viewGuardianTapped() {
		self.performSegueWithIdentifier(segueIdentifier: .showGuardians, sender: self)
	}
	
	func showFine() {
		
		self.notifyGuardians(type: "healthy")
		self.performSegueWithIdentifier(segueIdentifier: .showFine, sender: self)
	}
	
	func showHurt() {
		if UserInfo.hasSent() {
			self.notifyGuardians(type: "inDanger")
			self.performSegueWithIdentifier(segueIdentifier: .showHurt, sender: self)
		} else {
			UserInfo.setHasSent(value: true)
			self.alertWithTitle(self, title: ValidationErrors.alert, message: ValidationErrors.sendAlertHint)
		}
	}
	
	// MARK: - Message
	func configuredMessageComposeViewController(_ phoneNumbers: [String]) -> MFMessageComposeViewController {
		let messageComposeVC = MFMessageComposeViewController()
		messageComposeVC.messageComposeDelegate = self
		messageComposeVC.recipients = phoneNumbers
		messageComposeVC.body = "\(MainStrings.addGuardianText) \(MainStrings.appLink)"
		return messageComposeVC
	}
	
	func sendMessage(_ numbers: [String]) {
		let messageComposeVC = self.configuredMessageComposeViewController(numbers)
		self.present(messageComposeVC, animated: true, completion: nil)
	}
	
	// MARK: - Contacts
	func selectContact() {
		let contactPicker = CNContactPickerViewController()
		contactPicker.delegate = self
		present(contactPicker, animated: true, completion: nil)
	}
	
	// MARK: - Buttons
	func setupButtons() {
		self.plusButton.isUserInteractionEnabled = true
		let plusTGR = UITapGestureRecognizer(target: self, action: #selector(self.plusTapped))
		self.plusButton.addGestureRecognizer(plusTGR)
		
		self.viewImage.isUserInteractionEnabled = true
		let viewTGR = UITapGestureRecognizer(target: self, action: #selector(self.viewGuardianTapped))
		self.viewImage.addGestureRecognizer(viewTGR)
		
		self.fineImage.isUserInteractionEnabled = true
		let fineTGR = UITapGestureRecognizer(target: self, action: #selector(self.showFine))
		self.fineImage.addGestureRecognizer(fineTGR)
		
		self.hurtImage.isUserInteractionEnabled = true
		let hurtTGR = UITapGestureRecognizer(target: self, action: #selector(self.showHurt))
		self.hurtImage.addGestureRecognizer(hurtTGR)
		
		self.closeFriendListLabel.isUserInteractionEnabled = true
		let showTGR = UITapGestureRecognizer(target: self, action: #selector(self.viewGuardianTapped))
		self.closeFriendListLabel.addGestureRecognizer(showTGR)
	}
	
	@IBAction func viewAddedGuardiansTapped(_ sender: Any) {
		self.viewGuardianTapped()
	}
	
	// MARK: - Handle Guardians
	func handleByGuardians() {
		let guardiansCount = UserInfo.getGuardians().count
		self.viewImage.isHidden = false
		self.closeFriendListLabel.isHidden = false
		self.mainTitleLabel.isHidden = false
		self.mainSubtitleLabel.isHidden = false
		self.actionContainer.isHidden = true
		switch guardiansCount {
		case 0:
			self.mainView.backgroundColor = UIColor.dangerRed
			self.viewImage.isHidden = true
			self.closeFriendListLabel.isHidden = true
			self.closeFriendHintLabel.text = MainStrings.dangerFriendListHint
		case 1:
			self.mainView.backgroundColor = UIColor.dangerOrange
			self.closeFriendHintLabel.text = MainStrings.addTwoMore
		case 2:
			self.mainView.backgroundColor = UIColor.dangerBlue
			self.closeFriendHintLabel.text = MainStrings.addOneMore
		case 3:
			self.mainView.backgroundColor = UIColor.safeGreen
			self.closeFriendHintLabel.text = MainStrings.threeAdded
			self.mainTitleLabel.isHidden = true
			self.mainSubtitleLabel.isHidden = true
			self.actionContainer.isHidden = false
		default:
			self.mainView.backgroundColor = UIColor.safeGreen
			self.closeFriendHintLabel.text = "شما \(guardiansCount) نفر افزوده اید"
			self.mainTitleLabel.isHidden = true
			self.mainSubtitleLabel.isHidden = true
			self.actionContainer.isHidden = false
		}
	}
	
	func sendGuardian() {
		
		if !Reachability.connectedToNetwork() {
			Helpers.alertWithTitle(self, title: MainStrings.error, message: MainStrings.networkError)
			return
		}
		
		Helpers.showLoading()
		Alamofire.request(ApiRouter.Router.addGuardian(name: self.pickedContact.name, mobile: self.pickedContact.mobile)).log(.verbose).validate().responseJSON() {
			response in
			
			if response.result.isSuccess {
				Helpers.hideLoading()
				var guardians = UserInfo.getGuardians()
				guardians.append(self.pickedContact)
				UserInfo.setGuardians(guardians)
				
				self.handleByGuardians()
				
				let uuids = UserInfo.getUuids()
				if uuids.count > 0 {
					for item in uuids {
						self.removeNotifications(uuid: item)
						UserInfo.setUuids([])
					}
				}
				self.alertWithTitle(self, title: MainStrings.success, message: MainStrings.invitationSent)
			} else if response.response?.statusCode == 401 {
				Helpers.hideLoading()
				Helpers.login() {
					success in
					
					if success {
						self.sendGuardian()
					}
				}
			} else {
				Helpers.hideLoading()
				self.alertWithTitle(self, title: MainStrings.error, message: MainStrings.notSent)
			}
		}
	}
	
	func getGuardians() {
		
		if !Reachability.connectedToNetwork() {
			return
		}
		
		Alamofire.request(ApiRouter.Router.getGuardians()).log(.verbose).validate().responseCollection() {
			(response: DataResponse<[Guardian]>) in
			
			Helpers.hideLoading()
			if response.result.isSuccess {
				if let guardians = response.result.value {
					UserInfo.setGuardians(guardians)
					self.handleByGuardians()
				}
			}
		}
	}
	
	func notifyGuardians(type: String) {
		var requestBody = NotifyRequest(type: type)
		if UserInfo.getCurrentLocation()[UserDefaultTag.lat] != 0 {
			let lat = UserInfo.getCurrentLocation()[UserDefaultTag.lat]!
			let lon = UserInfo.getCurrentLocation()[UserDefaultTag.lon]!
			var location = [String: String]()
			location.updateValue(String(lat), forKey: "lat")
			location.updateValue(String(lon), forKey: "lon")
			requestBody = NotifyRequest(type: type, location: location)
		} else {
			requestBody = NotifyRequest(type: type)
		}
		
		var request = URLRequest(url: URL(string: "http://api.ensanapp.ir/v1/user/notify")!)
		
		request.httpMethod = HTTPMethod.post.rawValue
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.timeoutInterval = 180
		if let token = UserInfo.getToken() {
			request.setValue(token, forHTTPHeaderField: "Authorization")
		}
		let json = requestBody.toDict()
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: json)
		} catch {
			print("error")
		}
		
		let httpRequest = Alamofire.request(request).log(.verbose).validate().responseJSON() {
			response in
			
			if response.result.isSuccess {
				print("sent")
			} else {
				self.alertWithTitle(self, title: MainStrings.error, message: "")
			}
		}
		
		print(httpRequest)
	}
	
	func sendDeviceToken() {
		if UserInfo.isUser() && UserInfo.getNotificationId() != nil {
			Alamofire.request(ApiRouter.Router.registerDevice()).log().validate().responseJSON() {
				response in
				
				if response.result.isSuccess {
					print("notification sent to api")
					print(UserInfo.getNotificationId() ?? "nothing")
				} else {
					print(response.result.error.debugDescription)
				}
			}
		}
	}
	
	// MARK: - Location
	func manageLocationPermission() {
		switch CLLocationManager.authorizationStatus() {
		case .restricted, .denied:
			let locationAlert = UIAlertController(title: MainStrings.alert, message: MainStrings.needLocation, preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: MainStrings.cancel, style: .cancel)
			let settingAction = UIAlertAction(title: "تنظیمات", style: .default) {
				action in
				
				self.enableLocation()
			}
			
			locationAlert.addAction(cancelAction)
			locationAlert.addAction(settingAction)
			self.present(locationAlert, animated: true, completion: nil)
			return
		case .notDetermined:
			self.getLocationPermission()
			return
		case .authorizedWhenInUse:
			if self.location == nil || self.location?.lat == 0 {
				self.getLocation()
			}
			
			return
		default:
			return
		}
	}
	
	func getLocationPermission() {
		locationManager.requestWhenInUseAuthorization()
		
		self.getLocation()
	}
	
	func enableLocation() {
		if let url = URL(string:UIApplicationOpenSettingsURLString) {
			UIApplication.shared.openURL(url)
		}
	}
	
	func getLocation() {
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
			locationManager.startUpdatingLocation()
		}
	}
	
	func showAlreadyAddedAlert(_ number: String) {
		let message = "\(MainStrings.guardianAlreadyAdded): \(number)"
		self.alertWithTitle(self, title: MainStrings.error, message: message)
	}
	
	func alertWithTitle(_ viewController: UIViewController, title: String!, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
			UIAlertAction in
		}
		
		alert.addAction(action)
		viewController.present(alert, animated: true, completion:nil)
	}
}

// MARK: - Navigation
extension MainViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case showGuardians
		case showFine
		case showHurt
		case showSignUp
	}
}

//MARK: - MFMessageComposerDelegate Method
extension MainViewController: MFMessageComposeViewControllerDelegate {
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		if result == MessageComposeResult.sent {
			controller.dismiss(animated: true) {
				finished in
				
				self.sendGuardian()
			}
		} else {
			controller.dismiss(animated: true) {
				finished in
				
				self.alertWithTitle(self, title: MainStrings.error, message: MainStrings.notSent)
			}
		}
	}
}

//MARK: - CNContactPickerDelegate Method
extension MainViewController: CNContactPickerDelegate {
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
		self.pickedContact = Guardian()
		self.pickedContact.name = contact.givenName
		if let mobile = contact.phoneNumbers.first?.value.stringValue {
			let fixedMobile = mobile.replacingOccurrences(of: " ", with: "")
			self.pickedContact.mobile = fixedMobile
		} else {
			self.alertWithTitle(self, title: MainStrings.error, message: MainStrings.badNumber)
			return
		}
		
		let guardians = UserInfo.getGuardians()
		
		if guardians.count > 0 {
			for guardian in guardians {
				if guardian.mobile == pickedContact.mobile {
					picker.dismiss(animated: true, completion: nil)
					self.showAlreadyAddedAlert(self.pickedContact.mobile)
					return
				}
			}
		}
		
		let phoneNumbers = [pickedContact.mobile]
		let messageComposeVC = self.configuredMessageComposeViewController(phoneNumbers)
		
		picker.dismiss(animated: true) {
			completed in
			self.present(messageComposeVC, animated: true, completion: nil)
		}
	}
	
	func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
		print("contact picker cancelled")
	}
}

//MARK: - Location Delegate
extension MainViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let currentLocation: CLLocationCoordinate2D = manager.location!.coordinate
		self.location = Location(lat: currentLocation.latitude, lon: currentLocation.longitude)
		UserInfo.setCurrentLocation(currentLocation.latitude, longitude: currentLocation.longitude)
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
}

