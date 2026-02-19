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
                        let treatList = transactions.filter { $0.category == .treat }.sorted(by: { $0.date > $1.date })
                        let personalList = transactions.filter { $0.category == .personal }.sorted(by: { $0.date > $1.date })
                        
                        Section("Treat") {
                            ForEach(treatList) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { budgetManager.deleteTransaction(treatList[$0]) }
                            }
                        }
                        
                        Section("Personal") {
                            ForEach(personalList) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { budgetManager.deleteTransaction(personalList[$0]) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                EditButton()
            }
        }
    }
}
