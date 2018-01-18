//
//  JSTransaction.swift
//  Adamant
//
//  Created by Anokhov Pavel on 11.01.2018.
//  Copyright © 2018 Adamant. All rights reserved.
//

import Foundation
import JavaScriptCore


// MARK: Keypair

@objc protocol JSKeypairProtocol: JSExport {
	var publicKey: String { get set }
	var privateKey: String { get set }
}

@objc class JSKeypair: NSObject, JSKeypairProtocol {
	dynamic var publicKey: String
	dynamic var privateKey: String
	
	init(publicKey: String, privateKey: String) {
		self.publicKey = publicKey
		self.privateKey = privateKey
	}
	
	init(keypair: Keypair) {
		self.publicKey = keypair.publicKey
		self.privateKey = keypair.privateKey
	}
}


// MARK: - Transaction Asset

@objc protocol JSAssetProtocol: JSExport {
	var chat: JSChat? { get set }
}

@objc class JSAsset: NSObject, JSAssetProtocol {
	dynamic var chat: JSChat?
	
	init(chat: JSChat?) {
		self.chat = chat
	}
}


// MARK: - Chat

@objc protocol JSChatProtocol: JSExport {
	var message: String { get set }
	var own_message: String { get set }
	var type: Int { get set }
}

@objc class JSChat: NSObject, JSChatProtocol {
	dynamic var message: String
	dynamic var own_message: String
	dynamic var type: Int
	
	init(type: Int, message: String, own_message: String) {
		self.message = message
		self.own_message = own_message
		self.type = type
	}
}


// MARK: - Transaction

@objc protocol JSTransactionProtocol: JSExport {
	var id: UInt { get set }
	var height: UInt { get set }
	var blockId: UInt { get set }
	var type: Int { get set }
	var timestamp: UInt { get set }
	var senderPublicKey: String? { get set }
	var senderId: String? { get set }
	var recipientId: String? { get set }
	var recipientPublicKey: String? { get set }
	var amount: UInt { get set }
	var fee: UInt { get set }
	var signature: String? { get set }
	var confirmations: UInt { get set }
	var asset: JSAsset { get set }
}

@objc class JSTransaction: NSObject, JSTransactionProtocol {
	dynamic var id: UInt
	dynamic var height: UInt
	dynamic var blockId: UInt
	dynamic var type: Int
	dynamic var timestamp: UInt
	dynamic var senderPublicKey: String?
	dynamic var senderId: String?
	dynamic var recipientId: String?
	dynamic var recipientPublicKey: String?
	dynamic var amount: UInt
	dynamic var fee: UInt
	dynamic var signature: String?
	dynamic var confirmations: UInt
	dynamic var asset: JSAsset

	init(id: UInt, height: UInt, blockId: UInt, type: Int, timestamp: UInt, senderPublicKey: String?, senderId: String?, recipientId: String?, recipientPublicKey: String?, amount: UInt, fee: UInt, signature: String?, confirmations: UInt, asset: JSAsset) {
		self.id = id
		self.height = height
		self.blockId = blockId
		self.type = type
		self.timestamp = timestamp
		self.senderPublicKey = senderPublicKey
		self.senderId = senderId
		self.recipientId = recipientId
		self.recipientPublicKey = recipientPublicKey
		self.amount = amount
		self.fee = fee
		self.signature = signature
		self.confirmations = confirmations
		self.asset = asset
	}
}
