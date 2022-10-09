//
//  Message.swift
//  Petfind
//
//  Created by Didami on 06/02/22.
//

import UIKit

class Message: NSObject {
    
    @objc var fromId: String?
    @objc var text: String?
    @objc var timestamp: NSNumber?
    @objc var toId: String?
    
    init(dict: [String: AnyObject]) {
        
        fromId = dict[MessageVars.fromId.rawValue] as? String
        text = dict[MessageVars.text.rawValue] as? String
        timestamp = dict[MessageVars.timestamp.rawValue] as? NSNumber
        toId = dict[MessageVars.toId.rawValue] as? String
        
    }
    
    func chatPartnerId() -> String? {
        
        guard let uid = currentUserUid else {
            return nil
        }
        
        return fromId == uid ? toId : fromId
    }
}

enum MessageVars: String {
    case fromId
    case text
    case timestamp
    case toId
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
