//
//  SegueHandlerType.swift
//  Tipi
//
//  Created by Ashkan Hesaraki on 14/6/17.
//  Copyright © 2017 Tipi. All rights reserved.
//

import Foundation
import UIKit

protocol SegueHandlerType {
	associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController,
	SegueIdentifier.RawValue == String {
	
	func performSegueWithIdentifier(segueIdentifier: SegueIdentifier,
	                                sender: AnyObject?) {
		
		performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
	}
	
	func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
		
		// still have to use guard stuff here, but at least you're
		// extracting it this time
		guard let identifier = segue.identifier,
			let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
				fatalError("Invalid segue identifier \(String(describing: segue.identifier)).") }
		
		return segueIdentifier
	}
  
  func segueIdentifierForIdentifier(identifier: String) -> SegueIdentifier {
    
    // still have to use guard stuff here, but at least you're
    // extracting it this time
      guard let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
        fatalError("Invalid segue identifier \(String(describing: identifier)).") }
    
    return segueIdentifier
  }
}
