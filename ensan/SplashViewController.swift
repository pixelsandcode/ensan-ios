//
//  SplashViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit
import RevealingSplashView

class SplashViewController: UIViewController {
	
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	
	let mainIdentifier = "MainViewController"
	
	var index = 0
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on ...
		if  UserInfo.isUser() {
			Helpers.login() {
				success in
				if success {
					print("logged in")
				} else {
					print("can't login")
				}
			}
		}
		
		self.loadAnimation()
	}
	
	// MARK: - Animation
	func loadAnimation() {
		let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "splash_logo.png"),iconInitialSize: CGSize(width: 300, height: 280), backgroundColor: UIColor.white)
		self.view.addSubview(revealingSplashView)
		
		revealingSplashView.animationType = SplashAnimationType.heartBeat
		revealingSplashView.duration = 3.0
		revealingSplashView.startAnimation(){
			print("Completed")
		}
		
		let when = DispatchTime.now() + 3
		DispatchQueue.main.asyncAfter(deadline: when) {
			revealingSplashView.finishHeartBeatAnimation()
			if !UserInfo.getIntroSeen() {
				self.reset()
			} else {
				self.performSegueWithIdentifier(segueIdentifier: .showMain, sender: self)
			}
		}
	}
	
	// MARK: - Actions
	@IBAction func backTapped(_ sender: Any) {
		if self.index == 0 {
			return
		}
		
		self.index -= 1
		self.handleTexts()
	}
	
	@IBAction func nextTapped(_ sender: Any) {
		if self.index == 2 {
			self.performSegueWithIdentifier(segueIdentifier: .showMain, sender: self)
			return
		}
		
		self.index += 1
		self.handleTexts()
	}
	
	// Mark: - Internal
	func handleTexts() {
		if self.index == 0 {
			self.backButton.isHidden = true
		} else {
			self.backButton.isHidden = false
		}
		
		if self.index == 2 {
			self.nextButton.setTitle("ادامه", for: .normal)
		} else {
			self.nextButton.setTitle("بعدی", for: .normal)
		}
		
		self.titleLabel.fadeTransition(0.4)
		self.subtitleLabel.fadeTransition(0.4)
		self.titleLabel.text = Intro.pageTitle[self.index]
		self.subtitleLabel.text = Intro.pageDescriptions[self.index]
	}
	
	func reset() {
		self.backButton.isHidden = true
		self.titleLabel.text = Intro.firstTitle
		self.subtitleLabel.text = Intro.firstText
		UserInfo.setIntroSeen(value: true)
	}
}

// MARK: - Navigation
extension SplashViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case showMain
	}
}
