//
//  Item.swift
//  MoneyManagementAp
//
//  Created by MD REJAWANUL HAQUE TONMOY on 19/2/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
