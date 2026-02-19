import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var budgetManager: BudgetManager?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if let manager = budgetManager {
                if manager.currentBudget != nil {
                    TabView {
                        DashboardView()
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }
                        
                        TransactionHistoryView()
                            .tabItem {
                                Label("History", systemImage: "list.bullet")
                            }
                        
                        MonthlySummaryView()
                            .tabItem {
                                Label("Summary", systemImage: "chart.pie.fill")
                            }
                    }
                    .environment(manager)
                } else {
                    BudgetSetupView()
                        .environment(manager)
                }
            } else {
                ProgressView()
                    .onAppear {
                        budgetManager = BudgetManager(modelContext: modelContext)
                    }
            }
        }
    }
}
