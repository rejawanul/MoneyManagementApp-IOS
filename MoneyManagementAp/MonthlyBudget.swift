import Foundation
import SwiftData

@Model
final class MonthlyBudget {
    var id: UUID
    var monthYear: Date
    var treatBudgetTotal: Double
    var personalBudgetTotal: Double
    var isArchived: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.budget)
    var transactions: [Transaction] = []
    
    init(monthYear: Date, treatBudgetTotal: Double, personalBudgetTotal: Double, isArchived: Bool = false) {
        self.id = UUID()
        self.monthYear = monthYear
        self.treatBudgetTotal = treatBudgetTotal
        self.personalBudgetTotal = personalBudgetTotal
        self.isArchived = isArchived
    }
}
