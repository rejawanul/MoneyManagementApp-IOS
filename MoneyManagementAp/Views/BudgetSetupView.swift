import SwiftUI

struct BudgetSetupView: View {
    @Environment(BudgetManager.self) private var budgetManager
    
    @State private var treatAmount: String = ""
    @State private var personalAmount: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Monthly Setup")
                    .font(.title)
                    .bold()
                
                Text("Set your budget for this month.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Treat Budget (৳)")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        TextField("Amount", text: $treatAmount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Personal Budget (৳)")
                            .font(.headline)
                            .foregroundStyle(.green)
                        TextField("Amount", text: $personalAmount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Button(action: saveBudget) {
                    Text("Start Month")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isValid)
                
                Spacer()
            }
            .padding()
        }
    }
    
    var isValid: Bool {
        return !treatAmount.isEmpty && !personalAmount.isEmpty
    }
    
    func saveBudget() {
        guard let treat = Double(treatAmount), let personal = Double(personalAmount) else { return }
        budgetManager.createBudget(treat: treat, personal: personal)
    }
}
