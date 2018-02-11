//
//  AdamantAccountService.swift
//  Adamant
//
//  Created by Anokhov Pavel on 07.01.2018.
//  Copyright © 2018 Adamant. All rights reserved.
//

import Foundation
import UIKit

private struct Constants {
	static let loginStoryboard = "Login"
	
	private init() {}
}

class AdamantAccountService: AccountService {
	
	// MARK: Dependencies
	
	var apiService: ApiService!
	var adamantCore: AdamantCore!
	var router: Router!
	var dialogService: DialogService!
	
	
	// MARK: Properties
	var autoupdateInterval: TimeInterval = 3.0
	var autoupdate: Bool = true {
		didSet {
			if autoupdate {
				start()
			} else {
				stop()
			}
		}
	}
	
	private(set) var updating = false
	
	private(set) var status: AccountStatus = .notLogged
	private(set) var account: Account?
	private(set) var keypair: Keypair?
	
	private var loginViewController: UIViewController? = nil
	private var storyboardAuthorizationFinishedCallbacks: [(() -> Void)]?
	private var timer: Timer?
	
	// MARK: Lifecycle
	deinit {
		stop()
	}
}


// MARK: - Login&Logout functions
extension AdamantAccountService {
	func createAccount(with passphrase: String, completionHandler: ((Account?, AdamantError?) -> Void)?) {
		switch status {
		// Is logging in, return
		case .isLoggingIn:
			completionHandler?(nil, AdamantError(message: "Service is busy"))
			return
			
		// Logout first
		case .loggedIn:
			logout(stopAutoupdate: false)
			
		// Go login
		case .notLogged:
			break
		}
		
		status = .isLoggingIn
		guard let publicKey = adamantCore.createKeypairFor(passphrase: passphrase)?.publicKey else {
			completionHandler?(nil, AdamantError(message: "Can't create key for passphrase"))
			return
		}
		
		self.apiService.getAccount(byPublicKey: publicKey) { result in
			switch result {
			case .success(_):
				self.login(with: passphrase, completionHandler: completionHandler)
				
			case .failure(_):
				self.apiService.newAccount(byPublicKey: publicKey) { result in
					switch result {
					case .success(let account):
						self.setLoggedInWith(account: account, passphrase: passphrase)
						completionHandler?(account, nil)
						
					case .failure(let error):
						self.status = .notLogged
						completionHandler?(nil, AdamantError(message: String(describing: error), error: error))
					}
				}
			}
		}
	}
	
	func login(with passphrase: String, completionHandler: ((Account?, AdamantError?) -> Void)?) {
		switch status {
		// Is logging in, return
		case .isLoggingIn:
			completionHandler?(nil, AdamantError(message: "Service is busy"))
			return
			
		// Logout first
		case .loggedIn:
			logout(stopAutoupdate: false)
			
		// Go login
		case .notLogged:
			break
		}
		
		status = .isLoggingIn
		self.apiService.getAccount(byPassphrase: passphrase) { result in
			switch result {
			case .success(let account):
				self.setLoggedInWith(account: account, passphrase: passphrase)
				completionHandler?(account, nil)
				
			case .failure(let error):
				self.status = .notLogged
				completionHandler?(nil, AdamantError(message: String(describing: error), error: error))
			}
		}
	}
	
	func logout(stopAutoupdate: Bool = true) {
		if stopAutoupdate && autoupdate {
			stop()
		}
		
		let wasLogged = account != nil
		account = nil
		keypair = nil
		status = .notLogged
		
		if wasLogged {
			NotificationCenter.default.post(name: Notification.Name.adamantUserLoggedOut, object: nil)
		}
	}
	
	private func setLoggedInWith(account: Account, passphrase: String) {
		self.account = account
		keypair = adamantCore.createKeypairFor(passphrase: passphrase)
		
		NotificationCenter.default.post(name: Notification.Name.adamantUserLoggedIn, object: nil)
		
		if let vc = loginViewController {
			DispatchQueue.main.async {
				vc.dismiss(animated: true, completion: nil)
			}
			loginViewController = nil
		}
		
		if let callbacks = self.storyboardAuthorizationFinishedCallbacks {
			for	aCallback in callbacks {
				aCallback()
			}
			
			self.storyboardAuthorizationFinishedCallbacks = nil
		}
		
		self.status = .loggedIn
		if self.autoupdate {
			self.start()
		}
	}
}


// MARK: - Update
extension AdamantAccountService {
	private func start() {
		if let timer = timer {
			timer.invalidate()
			self.timer = nil
		}
		
		timer = Timer(timeInterval: autoupdateInterval, repeats: true, block: { _ in
			if self.status != .loggedIn {
				return
			}
			
			if !self.updating {
				self.updateAccountData()
			}
		})
		DispatchQueue.main.async {
			guard let timer = self.timer else {
				return
			}
			RunLoop.current.add(timer, forMode: .commonModes)
			timer.fire()
		}
	}
	
	private func stop() {
		timer?.invalidate()
		timer = nil
	}
	
	func updateAccountData() {
		guard !updating else {
			return
		}
		
		updating = true
		
		guard let loggedAccount = account else {
			stop()
			return
		}
		
		apiService.getAccount(byPublicKey: loggedAccount.publicKey) { result in
			switch result {
			case .success(let account):
				var hasChanges = false
				
				if loggedAccount.balance != account.balance { hasChanges = true }
				
				if hasChanges {
					self.account = account
					NotificationCenter.default.post(name: Notification.Name.adamantAccountDataUpdated, object: nil)
				}
				
				self.updating = false
				
			case .failure(let error):
				print("Error update account: \(String(describing: error))")
			}
		}
	}
}


// MARK: - AccountService
extension AdamantAccountService {
	func logoutAndPresentLoginStoryboard(animated: Bool, authorizationFinishedHandler: (() -> Void)?) {
		logout(stopAutoupdate: false)
		
		if loginViewController != nil {	// Already presenting view controller. We will add you to a list, and call you back later. Maybe.
			if let aCallback = authorizationFinishedHandler {
				if var callbacks = storyboardAuthorizationFinishedCallbacks {
					callbacks.append(aCallback)
				} else {
					storyboardAuthorizationFinishedCallbacks = [aCallback]
				}
			}
		} else {	// Not presenting. Create and present.
			guard let vc = router.get(story: .Login).instantiateInitialViewController() else {
				fatalError("Failed to get LoginStory")
			}
			
			loginViewController = vc
			dialogService.presentModallyViewController(vc, animated: animated, completion: nil)
			
			if let callback = authorizationFinishedHandler {
				storyboardAuthorizationFinishedCallbacks = [callback]
			}
		}
	}
}
