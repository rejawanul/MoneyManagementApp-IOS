import SwiftUI

struct DashboardView: View {
    @Environment(BudgetManager.self) private var budgetManager
    @State private var showingAddTransaction = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Budget Cards
                    HStack(spacing: 15) {
                        BudgetCard(
                            title: "Treat",
                            spent: budgetManager.spent(category: .treat),
                            total: budgetManager.currentBudget?.treatBudgetTotal ?? 0,
                            color: .blue
                        )
                        
                        BudgetCard(
                            title: "Personal",
                            spent: budgetManager.spent(category: .personal),
                            total: budgetManager.currentBudget?.personalBudgetTotal ?? 0,
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Month & Summary Header
                    if let budget = budgetManager.currentBudget {
                        HStack {
                            Text(budget.monthYear.formatted(.dateTime.month().year()))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Saved: ৳\(budgetManager.totalSaved, specifier: "%.0f")")
                                .font(.subheadline)
                                .padding(6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Transaction List Preview (Last 5? or All?)
                    // For now, let's list all for "Transaction History" compliance on home screen
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if let transactions = budgetManager.currentBudget?.transactions.sorted(by: { $0.date > $1.date }), !transactions.isEmpty {
                            ForEach(transactions) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        } else {
                            ContentUnavailableView("No transactions yet", systemImage: "list.bullet.clipboard")
                                .frame(height: 200)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                }
                
                // Optional: Monthly Summary / Reset could be in a settings/menu
                ToolbarItem(placement: .topBarLeading) {
                   // Placeholder for Reset/Menu
                   Menu {
                       Button("End Date & Summary", action: { /* TODO */ })
                       Button("Reset Month", role: .destructive, action: { /* TODO */ })
                   } label: {
                       Image(systemName: "ellipsis.circle")
                   }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
        }
    }
}

struct BudgetCard: View {
    let title: String
    let spent: Double
    let total: Double
    let color: Color
    
    var remaining: Double {
        max(total - spent, 0)
    }
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return min(spent / total, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(color)
                Spacer()
                Image(systemName: title == "Treat" ? "gift.fill" : "person.fill")
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("৳\(remaining, specifier: "%.0f")")
                    .font(.system(size: 24, weight: .bold))
                Text("left of ৳\(total, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category == .treat ? "gift.circle.fill" : "person.circle.fill")
                .font(.title2)
                .foregroundStyle(transaction.category == .treat ? .blue : .green)
            
            VStack(alignment: .leading) {
                Text(transaction.note ?? transaction.category.rawValue)
                    .font(.body)
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("-৳\(transaction.amount, specifier: "%.0f")")
                .bold()
                .foregroundStyle(.primary)
        }
        .padding(.horizontal)
    }
}
