//
//  GuardianViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 31/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI
import Alamofire

class GuardianViewController: UIViewController {
	
	@IBOutlet weak var backContainer: UIStackView!
	@IBOutlet weak var tableView: UITableView!
	
	var pickedContact: Guardian = Guardian()
	var guardians: [Guardian] = []
	
	let cellIdentifier = "GuardianCell"
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on ...
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		self.getGuardians()
		
		self.backContainer.isUserInteractionEnabled = true
		let backTGR = UITapGestureRecognizer(target: self, action: #selector(self.back))
		self.backContainer.addGestureRecognizer(backTGR)
		self.pickedContact = Guardian()
	}
	
	func back() {
		guard let _ = (navigationController?.popViewController(animated: true)) else {
			dismiss(animated: true, completion: nil)
			return
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
	
	// MARK: - Internal
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
	
	func getGuardians() {
		Alamofire.request(ApiRouter.Router.getGuardians()).log(.verbose).validate().responseCollection() {
			(response: DataResponse<[Guardian]>) in
			
			if response.result.isSuccess {
				if let guardians = response.result.value {
					self.guardians = guardians
					self.tableView.reloadData()
					let pendings = guardians.filter({$0.state == "pending"})
					if pendings.count > 0 {
						self.alertIfPending()
					}
				}
			}
		}
	}
	
	func sendGuardian() {
		Alamofire.request(ApiRouter.Router.addGuardian(name: self.pickedContact.name, mobile: self.pickedContact.mobile)).log().validate().responseJSON() {
			response in
			
			if response.result.isSuccess {
				self.guardians = UserInfo.getGuardians()
				self.guardians.append(self.pickedContact)
				UserInfo.setGuardians(self.guardians)
				
				self.tableView.reloadData()
				self.alertWithTitle(self, title: MainStrings.success, message: MainStrings.invitationSent)
			} else if response.response?.statusCode == 401 {
				Helpers.login() {
					success in
					
					if success {
						self.sendGuardian()
					}
				}
			} else {
				self.alertWithTitle(self, title: MainStrings.error, message: MainStrings.messageNotSent)
			}
		}
	}
	
	func alertIfPending() {
		self.alertWithTitle(self, title: MainStrings.alert, message: "برای ارسال دوباره دعوت روی اسم شخص کلیک کنید")
	}
}

// MARK: - TableView DataSource and Delegate
extension GuardianViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == self.guardians.count {
			self.selectContact()
			return
		}
		
		let position = indexPath.row
		let obj = self.guardians[position]
		if obj.state == "pending" {
			let alert = UIAlertController(title: "ارسال مجدد", message: "آیا میخواهید مجددا دعوت کنید؟", preferredStyle: .alert)
			let sendAction = UIAlertAction(title: "بله", style: .default) {
				action in
				
				self.sendMessage([obj.mobile])
			}
			let cancelAction = UIAlertAction(title: MainStrings.cancel, style: .cancel)
			alert.addAction(sendAction)
			alert.addAction(cancelAction)
			self.present(alert, animated: true, completion: nil)
			
		}
	}
}

extension GuardianViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.guardians.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! GuardianCell
		let position = indexPath.row
		let lastIndex = self.guardians.count
		
		if position == lastIndex {
			cell.statusImageView.image = #imageLiteral(resourceName: "plus.png")
			cell.nameLabel.text = MainStrings.addMoreGuardian
			cell.mobileLabel.isHidden = true
			cell.statusLabel.isHidden = true
		} else {
			let obj = self.guardians[position]
			cell.nameLabel.text = obj.name
			cell.mobileLabel.text = obj.mobile
			if obj.state == "pending" {
				cell.statusLabel.isHidden = false
				cell.statusImageView.image = #imageLiteral(resourceName: "alert.png")
			} else {
				cell.statusLabel.isHidden = true
				cell.statusImageView.image = #imageLiteral(resourceName: "guardian_accepted.png")
			}
		}
		
		return cell
	}
}

//MARK: - MFMessageComposerDelegate Method
extension GuardianViewController: MFMessageComposeViewControllerDelegate {
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		if result == MessageComposeResult.sent {
			controller.dismiss(animated: true) {
				finished in
				
				if !self.pickedContact.mobile.isEmpty {
					self.sendGuardian()
				} else {
					self.alertWithTitle(self, title: MainStrings.success, message: MainStrings.invitationSent)
				}
			}
		} else {
			controller.dismiss(animated: true) {
				finished in
				
				self.alertWithTitle(self, title: MainStrings.error, message: MainStrings.messageNotSent)
			}
		}
	}
}

//MARK: - CNContactPickerDelegate Method
extension GuardianViewController: CNContactPickerDelegate {
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
			if UserInfo.isUser() {
				self.present(messageComposeVC, animated: true, completion: nil)
			} else {
				self.pickedContact.sent = false
				self.back()
			}
		}
	}
	
	func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
		print("contact picker cancelled")
	}
}
