//
//  SignUpViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 31/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var mobileTextField: UITextField!
	@IBOutlet weak var backContainer: UIStackView!
	@IBOutlet weak var buttonContainerBottomConst: NSLayoutConstraint!
	
	var enteredName = ""
	var enteredMobile = ""
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// game is on ...
		
		self.backContainer.isUserInteractionEnabled = true
		let backTGR = UITapGestureRecognizer(target: self, action: #selector(self.back))
		self.backContainer.addGestureRecognizer(backTGR)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.registerForKeyboardNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.deregisterFromKeyboardNotifications()
	}
	
	// MARK: - Validations
	func isMobileNumberValid(mobile: String) -> Bool {
		let PHONE_REGEX = "^[0-9]{6,14}$"
		let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
		let result = phoneTest.evaluate(with: mobile)
		print(result.description)
		return result
	}
	
	func isNameValid(name: String) -> Bool {
		let result = name.contains(" ")
		return result
	}
	
	func alertWithTitle(_ viewController: UIViewController, title: String!, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
			UIAlertAction in
		}
		
		alert.addAction(action)
		viewController.present(alert, animated: true, completion:nil)
	}
	
	// MARK: - Actions
	@IBAction func sendTapped(_ sender: Any) {
		self.signUp()
	}
	
	// MARK: - Internal
	func signUp() {
		if !isError() {
			if let name = UserInfo.getUsername(), let mobile = UserInfo.getMobile() {
				
				if !Reachability.connectedToNetwork() {
					Helpers.alertWithTitle(self, title: MainStrings.error, message: MainStrings.networkError)
					return
				}
				
				Helpers.showLoading()
				Alamofire.request(ApiRouter.Router.signup(name: name, mobile: mobile)).log().validate().responseObject() {
					
					(response: DataResponse<User>) in
					
					if response.result.isSuccess {
						Helpers.hideLoading()
						let _ = Helpers.getAndSaveToken(response: response.response!)
						let user = response.result.value
						if let user = user {
							User.saveUser(user)
							self.sendDeviceToken()
						}
						
						self.back()
						print(user.debugDescription)
					}  else if response.response?.statusCode == 409 {
						Alamofire.request(ApiRouter.Router.generatePin()).log().validate().responseJSON() {
							response in
							
							Helpers.hideLoading()
							if response.result.isSuccess {
								self.performSegueWithIdentifier(segueIdentifier: .showPin, sender: self)
							} else {
								// TODO: show error
							}
						}
						
					} else {
						Helpers.hideLoading()
						// TODO: show error
					}
				}
			}
		}
	}
	
	func sendDeviceToken() {
		if UserInfo.isUser() && UserInfo.getNotificationId() != nil {
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
	
	func isError() -> Bool {
		var error = false
		
		var errorMessage = ""
		self.enteredName = self.nameTextField.text!
		self.enteredMobile = self.mobileTextField.text!
		
		if (self.enteredName.isEmpty) {
			error = true
			errorMessage = ValidationErrors.nameRequired
		} else if !self.isNameValid(name: self.enteredName) {
			error = true
			errorMessage = ValidationErrors.incorrectNameFormat
		} else if self.enteredMobile.isEmpty {
			error = true
			errorMessage = ValidationErrors.mobileRequired
		} else if (!self.isMobileNumberValid(mobile: self.enteredMobile)) {
			error = true
			errorMessage = ValidationErrors.incorrectMobileFormat
		}
		
		if error {
			self.alertWithTitle(self, title: MainStrings.error, message: errorMessage)
		} else {
			UserInfo.setUsername(self.enteredName.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines))
			UserInfo.setMobile(self.enteredMobile.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines))
		}
		
		return error
	}
	
	func back() {
		guard let _ = (navigationController?.popViewController(animated: true)) else {
			dismiss(animated: true, completion: nil)
			return
		}
	}
	
	// MARK: - Keyboard Helpers
	func registerForKeyboardNotifications() {
		//Adding notifies on keyboard appearing
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
	}
	
	func deregisterFromKeyboardNotifications() {
		//Removing notifies on keyboard appearing
		NotificationCenter.default.removeObserver(self)
	}
	
	func keyboardNotification(_ notification: Foundation.Notification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
			let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
			if let endFrameHeight = endFrame?.origin.y, endFrameHeight >= UIScreen.main.bounds.size.height {
				self.buttonContainerBottomConst?.constant = 0.0
			} else {
				self.buttonContainerBottomConst?.constant = endFrame!.size.height
			}
			UIView.animate(withDuration: duration,
										 delay: TimeInterval(0),
										 options: animationCurve,
										 animations: { self.view.layoutIfNeeded() },
										 completion: nil)
		}
	}
}

// MARK: - Navigation
extension SignUpViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case showPin
	}
}

// MARK: - TextField Delegate
extension SignUpViewController: UITextFieldDelegate {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == self.nameTextField {
			self.mobileTextField.becomeFirstResponder()
		} else if textField == self.mobileTextField {
			textField.resignFirstResponder()
			self.signUp()
		}
		
		return true
	}
}
