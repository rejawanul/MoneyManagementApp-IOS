import Foundation
import SwiftData
import SwiftUI

@Observable
class BudgetManager {
    var modelContext: ModelContext?
    var currentBudget: MonthlyBudget?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        fetchCurrentBudget()
    }
    
    func fetchCurrentBudget() {
        guard let context = modelContext else { return }
        
        // Fetch logic would go here. For now we just check if we have one for this month/year that isn't archived?
        // Or simply get the active one.
        // For simplicity in this demo, we can assume we fetch the *latest* unarchived budget.
        
        let descriptor = FetchDescriptor<MonthlyBudget>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\.monthYear, order: .reverse)]
        )
        
        do {
            let budgets = try context.fetch(descriptor)
            currentBudget = budgets.first
        } catch {
            print("Failed to fetch budget: \(error)")
        }
    }
    
    func createBudget(treat: Double, personal: Double) {
        guard let context = modelContext else { return }
        
        let newBudget = MonthlyBudget(monthYear: Date(), treatBudgetTotal: treat, personalBudgetTotal: personal)
        context.insert(newBudget)
        
        do {
            try context.save()
            currentBudget = newBudget
        } catch {
            print("Failed to save new budget: \(error)")
        }
    }
    
    func addTransaction(amount: Double, category: TransactionCategory, note: String?) {
        guard let budget = currentBudget, let context = modelContext else { return }
        
        let transaction = Transaction(amount: amount, category: category, note: note)
        transaction.budget = budget
        // Adding to the transaction list is handled by the relationship inverse usually,
        // but often good to append explicitly or let SwiftData handle it via the `budget` property.
        // Setting `transaction.budget = budget` is sufficient.
        
        context.insert(transaction)
        
        do {
            try context.save()
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }
    
    func archiveCurrentBudget() {
        guard let budget = currentBudget, let context = modelContext else { return }
        
        budget.isArchived = true
        
        do {
            try context.save()
            currentBudget = nil
        } catch {
            print("Failed to archive budget: \(error)")
        }
    }
    
    // Helpers for specific spending calculation
    func spent(category: TransactionCategory) -> Double {
        guard let budget = currentBudget else { return 0 }
        return budget.transactions
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    func remaining(category: TransactionCategory) -> Double {
        guard let budget = currentBudget else { return 0 }
        let budgetAmount = (category == .treat) ? budget.treatBudgetTotal : budget.personalBudgetTotal
        return budgetAmount - spent(category: category)
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        guard let context = modelContext else { return }
        context.delete(transaction)
        do {
            try context.save()
        } catch {
            print("Failed to delete transaction: \(error)")
        }
    }
    
    var totalSaved: Double {
        guard let budget = currentBudget else { return 0 }
        let totalBudget = budget.treatBudgetTotal + budget.personalBudgetTotal
        let totalSpent = spent(category: .treat) + spent(category: .personal)
        return totalBudget - totalSpent
    }
}
