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

class GuardianViewController: UIViewController {
	
	@IBOutlet weak var backContainer: UIStackView!
	@IBOutlet weak var tableView: UITableView!
	
	var pickedContacts: [String: String] = [:]
	var guardians = UserInfo.getGuardians()
	var names: [String] = []
	var mobiles: [String] = []
	
	let cellIdentifier = "GuardianCell"
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on ...
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.mobiles = Array(self.guardians.values)
		self.names = Array(self.guardians.keys)
		
		self.backContainer.isUserInteractionEnabled = true
		let backTGR = UITapGestureRecognizer(target: self, action: #selector(self.back))
		self.backContainer.addGestureRecognizer(backTGR)
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
}

// MARK: - TableView DataSource and Delegate
extension GuardianViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == self.guardians.count {
			self.selectContact()
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
			cell.mobileLabel.removeFromSuperview()
			cell.statusLabel.removeFromSuperview()
		} else {
			cell.nameLabel.text = self.names[position]
			cell.mobileLabel.text = self.mobiles[position]
			cell.statusLabel.isHidden = true
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
				
				var guardians = UserInfo.getGuardians()
				guardians.update(other: self.pickedContacts)
				UserInfo.setGuardians(guardians)
				self.guardians = guardians
				self.tableView.reloadData()
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
extension GuardianViewController: CNContactPickerDelegate {
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
		
		self.pickedContacts = [:]
		for item in contacts {
			pickedContacts.updateValue((item.phoneNumbers.first?.value.stringValue)!, forKey: item.givenName)
			print((item.phoneNumbers.first?.value.stringValue)!)
			print(item.givenName)
		}
		
		print(pickedContacts.debugDescription)
		let guardians = UserInfo.getGuardians()
		
		if guardians.count > 0 {
			for guardian in pickedContacts {
				if guardians.values.contains(guardian.value) {
					picker.dismiss(animated: true, completion: nil)
					self.showAlreadyAddedAlert(guardian.value)
					return
				}
			}
		}
		
		let phoneNumbers = Array(pickedContacts.values)
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
