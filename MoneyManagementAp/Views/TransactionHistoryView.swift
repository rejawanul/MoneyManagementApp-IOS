import SwiftUI

struct TransactionHistoryView: View {
    @Environment(BudgetManager.self) private var budgetManager
    
    var body: some View {
        NavigationStack {
            List {
                if let transactions = budgetManager.currentBudget?.transactions {
                    if transactions.isEmpty {
                        ContentUnavailableView("No transactions", systemImage: "list.bullet")
                    } else {
                        Section("Treat") {
                            ForEach(transactions.filter { $0.category == .treat }.sorted(by: { $0.date > $1.date })) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                        
                        Section("Personal") {
                            ForEach(transactions.filter { $0.category == .personal }.sorted(by: { $0.date > $1.date })) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}
