//
//  LoginViewController.swift
//  Adamant-ios
//
//  Created by Павел Анохов on 05.01.2018.
//  Copyright © 2018 adamant. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	@IBOutlet weak var passphraseTextField: UITextField!
	@IBOutlet weak var newPassphraseTextArea: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		passphraseTextField.text = ""
		newPassphraseTextArea.text = ""
    }

	@IBAction func login(_ sender: Any) {
//		guard let passphrase = passphraseTextField?.text else {
//			return
//		}
//
//		let api = AdamantApiService()
//		api.adamantCore = try! JSAdamantCore(coreJsUrl: Bundle.main.url(forResource: "adamant-core", withExtension: "js")!,
//										utilitiesJsUrl:  Bundle.main.url(forResource: "utilites", withExtension: "js")!)
//
//		api.getAccount(byPassphrase: passphrase) { (account, error) in
//
//		}
	}
	
	@IBAction func createNewPassphrase(_ sender: Any) {
		
	}
}
