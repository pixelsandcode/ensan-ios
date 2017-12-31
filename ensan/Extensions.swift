//
//  Extensions.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	func fadeTransition(_ duration:CFTimeInterval) {
		let animation = CATransition()
		animation.timingFunction = CAMediaTimingFunction(name:
			kCAMediaTimingFunctionEaseInEaseOut)
		animation.type = kCATransitionFade
		animation.duration = duration
		layer.add(animation, forKey: kCATransitionFade)
	}
}

extension Dictionary {
	mutating func update(other:Dictionary) {
		for (key,value) in other {
			self.updateValue(value, forKey:key)
		}
	}
}
