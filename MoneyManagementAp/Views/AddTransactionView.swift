import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BudgetManager.self) private var budgetManager
    
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedCategory: TransactionCategory = .personal
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount (৳)", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        
                    Picker("Category", selection: $selectedCategory) {
                        Text("Personal").tag(TransactionCategory.personal)
                        Text("Treat").tag(TransactionCategory.treat)
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Note (Optional)", text: $note)
                } header: {
                    Text("Details")
                }
            }
            .navigationTitle("New Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    func saveTransaction() {
        guard let value = Double(amount) else { return }
        budgetManager.addTransaction(amount: value, category: selectedCategory, note: note.isEmpty ? nil : note)
        dismiss()
    }
}
