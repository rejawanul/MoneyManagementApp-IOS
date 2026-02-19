import SwiftUI
import Charts

struct MonthlySummaryView: View {
    @Environment(BudgetManager.self) private var budgetManager
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Charts Section
                    if let budget = budgetManager.currentBudget, !budget.transactions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Spending Breakdown")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                SectorMark(
                                    angle: .value("Amount", budgetManager.spent(category: .treat)),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(.blue)
                                .annotation(position: .overlay) {
                                    Text("Treat")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                                
                                SectorMark(
                                    angle: .value("Amount", budgetManager.spent(category: .personal)),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(.green)
                                .annotation(position: .overlay) {
                                    Text("Personal")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            
                            Text("Daily Trend")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            Chart {
                                ForEach(dailySpending(transactions: budget.transactions), id: \.date) { item in
                                    BarMark(
                                        x: .value("Day", item.date, unit: .day),
                                        y: .value("Amount", item.amount)
                                    )
                                    .foregroundStyle(.orange)
                                }
                            }
                            .frame(height: 200)
                            .padding()
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Summary Cards
                    VStack(spacing: 15) {
                        SummaryRow(title: "Total Treat Spent", amount: budgetManager.spent(category: .treat), color: .blue)
                        SummaryRow(title: "Total Personal Spent", amount: budgetManager.spent(category: .personal), color: .green)
                        
                        Divider()
                        
                        SummaryRow(title: "Total Saved", amount: budgetManager.totalSaved, color: .purple)
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Reset Action
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "archivebox.fill")
                            Text("End Month & Reset")
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Text("This will archive the current month's budget and start a fresh one.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Summary")
            .alert("End Current Month?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("End & Archive", role: .destructive) {
                    budgetManager.archiveCurrentBudget()
                }
            } message: {
                Text("Are you sure you want to end this month's budget? This action cannot be undone.")
            }
        }
    }
    
    // Helper to group transactions by day
    func dailySpending(transactions: [Transaction]) -> [(date: Date, amount: Double)] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        
        return grouped.map { (key, value) in
            (date: key, amount: value.reduce(0) { $0 + $1.amount })
        }.sorted { $0.date < $1.date }
    }
}

struct SummaryRow: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text("৳\(amount, specifier: "%.2f")")
                .bold()
                .foregroundStyle(color)
        }
    }
}
