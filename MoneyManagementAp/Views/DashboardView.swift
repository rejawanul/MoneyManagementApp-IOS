import SwiftUI

struct DashboardView: View {
    @Environment(BudgetManager.self) private var budgetManager
    @State private var showingAddTransaction = false
    @State private var showingResetConfirmation = false
    @Binding var selectedTab: Int
    
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
                    
                    // Transaction List Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if let transactions = budgetManager.currentBudget?.transactions.sorted(by: { $0.date > $1.date }), !transactions.isEmpty {
                            List {
                                ForEach(transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                                .onDelete { indexSet in
                                    indexSet.forEach { budgetManager.deleteTransaction(transactions[$0]) }
                                }
                            }
                            .listStyle(.plain)
                            .frame(height: CGFloat(transactions.count) * 60)
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
                       Button("End Date & Summary") {
                           selectedTab = 2
                       }
                       Button("Reset Month", role: .destructive) {
                           showingResetConfirmation = true
                       }
                   } label: {
                       Image(systemName: "ellipsis.circle")
                   }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
            .alert("Reset Month?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    budgetManager.archiveCurrentBudget()
                }
            } message: {
                Text("This will archive the current month's budget. You'll need to set up a new one.")
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
        total - spent
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
                    .foregroundStyle(remaining < 0 ? .red : .primary)
                Text(remaining < 0 ? "over budget" : "left of ৳\(total, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundStyle(remaining < 0 ? .red : .secondary)
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
