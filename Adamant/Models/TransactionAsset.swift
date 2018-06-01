//
//  TransactionAsset.swift
//  Adamant
//
//  Created by Anokhov Pavel on 25.05.2018.
//  Copyright © 2018 Adamant. All rights reserved.
//

import Foundation

struct TransactionAsset: Codable {
	let chat: ChatAsset?
	let state: StateAsset?
}
