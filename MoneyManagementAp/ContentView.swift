import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var budgetManager: BudgetManager?
    @State private var selectedTab: Int = 0
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if let manager = budgetManager {
                if manager.currentBudget != nil {
                    TabView(selection: $selectedTab) {
                        DashboardView(selectedTab: $selectedTab)
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }
                            .tag(0)
                        
                        TransactionHistoryView()
                            .tabItem {
                                Label("History", systemImage: "list.bullet")
                            }
                            .tag(1)
                        
                        MonthlySummaryView()
                            .tabItem {
                                Label("Summary", systemImage: "chart.pie.fill")
                            }
                            .tag(2)
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
