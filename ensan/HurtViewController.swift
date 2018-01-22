//
//  HurtViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 31/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit
import MessageUI

class HurtViewController: UIViewController {
	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var hurtImageView: UIImageView!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on ...
		let guardiansCount = UserInfo.getGuardians().filter({$0.state == "joined"}).count
		self.descriptionLabel.text = "\(guardiansCount) \(MainStrings.notifiedHurt)"
		
		let guardians = UserInfo.getGuardians()
		let numbers = guardians.map({$0.mobile})
		self.sendMessage(numbers)
	}
	
	@IBAction func imageTapped(_ sender: Any) {
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
		messageComposeVC.body = "\(UserInfo.getUsername()!) \(MainStrings.inDanger)"
		return messageComposeVC
	}
	
	func sendMessage(_ numbers: [String]) {
		let messageComposeVC = self.configuredMessageComposeViewController(numbers)
		self.present(messageComposeVC, animated: true, completion: nil)
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

//MARK: - MFMessageComposerDelegate Method
extension HurtViewController: MFMessageComposeViewControllerDelegate {
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		if result == MessageComposeResult.sent {
			controller.dismiss(animated: true) {
				finished in
				
				for controller in self.navigationController!.viewControllers as Array {
					if controller.isKind(of: MainViewController.self) {
						self.navigationController!.popToViewController(controller, animated: true)
						break
					}
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
