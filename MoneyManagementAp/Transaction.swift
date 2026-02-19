import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var categoryRawValue: String
    var date: Date
    var note: String?
    var budget: MonthlyBudget?
    
    var category: TransactionCategory {
        get { TransactionCategory(rawValue: categoryRawValue) ?? .personal }
        set { categoryRawValue = newValue.rawValue }
    }
    
    init(amount: Double, category: TransactionCategory, date: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.categoryRawValue = category.rawValue
        self.date = date
        self.note = note
    }
}

enum TransactionCategory: String, Codable, CaseIterable {
    case treat = "Treat"
    case personal = "Personal"
}
