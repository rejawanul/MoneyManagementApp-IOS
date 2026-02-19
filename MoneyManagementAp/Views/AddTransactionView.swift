import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BudgetManager.self) private var budgetManager

    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedCategory: TransactionCategory = .personal
    @State private var amountScale: CGFloat = 1.0
    @FocusState private var amountFocused: Bool

    // Dynamic gradient based on selected category
    var categoryGradient: LinearGradient {
        switch selectedCategory {
        case .personal:
            return LinearGradient(
                colors: [Color(hue: 0.38, saturation: 0.72, brightness: 0.72),
                         Color(hue: 0.52, saturation: 0.80, brightness: 0.60)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .treat:
            return LinearGradient(
                colors: [Color(hue: 0.60, saturation: 0.72, brightness: 0.82),
                         Color(hue: 0.73, saturation: 0.80, brightness: 0.65)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var categoryIcon: String {
        selectedCategory == .treat ? "gift.fill" : "person.fill"
    }

    var isValid: Bool {
        guard let val = Double(amount) else { return false }
        return val > 0
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Gradient Header ──────────────────────────────────
                ZStack {
                    categoryGradient
                        .ignoresSafeArea(edges: .top)

                    VStack(spacing: 16) {
                        // Dismiss handle
                        Capsule()
                            .fill(.white.opacity(0.4))
                            .frame(width: 40, height: 5)
                            .padding(.top, 12)

                        // Icon bubble
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 70, height: 70)
                            Image(systemName: categoryIcon)
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                        }
                        .animation(.spring(response: 0.4), value: selectedCategory)

                        // Amount field
                        HStack(alignment: .center, spacing: 4) {
                            Text("৳")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white.opacity(0.85))
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad)
                                .focused($amountFocused)
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 220)
                                .tint(.white)
                                .onChange(of: amount) { _, _ in
                                    withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                                        amountScale = 1.05
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                        withAnimation(.spring(response: 0.15)) {
                                            amountScale = 1.0
                                        }
                                    }
                                }
                                .scaleEffect(amountScale)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // ── Body ─────────────────────────────────────────────
                ScrollView {
                    VStack(spacing: 20) {

                        // Category Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Category", systemImage: "tag.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                ForEach(TransactionCategory.allCases, id: \.self) { cat in
                                    CategoryPill(
                                        category: cat,
                                        isSelected: selectedCategory == cat,
                                        gradient: selectedCategory == cat ? categoryGradient : nil
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            selectedCategory = cat
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        // Note Field
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Note", systemImage: "text.bubble.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField("What was it for? (optional)", text: $note)
                                .font(.body)
                                .padding(.vertical, 4)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        // Save Button
                        Button(action: saveTransaction) {
                            ZStack {
                                if isValid {
                                    categoryGradient
                                } else {
                                    LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                                                   startPoint: .leading, endPoint: .trailing)
                                }
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                    Text("Save Transaction")
                                        .font(.headline)
                                }
                                .foregroundStyle(.white)
                                .padding(.vertical, 18)
                            }
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: isValid ? .black.opacity(0.2) : .clear, radius: 12, x: 0, y: 6)
                        }
                        .disabled(!isValid)
                        .animation(.easeInOut(duration: 0.2), value: isValid)

                        // Cancel
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
        }
        .onAppear { amountFocused = true }
    }

    func saveTransaction() {
        guard let value = Double(amount), value > 0 else { return }
        budgetManager.addTransaction(amount: value, category: selectedCategory, note: note.isEmpty ? nil : note)
        dismiss()
    }
}

// ── Category Pill ─────────────────────────────────────────────────────────────

struct CategoryPill: View {
    let category: TransactionCategory
    let isSelected: Bool
    let gradient: LinearGradient?

    var icon: String { category == .treat ? "gift.fill" : "person.fill" }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
            Text(category.rawValue)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(isSelected ? .white : .primary)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background {
            if isSelected, let g = gradient {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(g)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            } else {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))
            }
        }
        .scaleEffect(isSelected ? 1.04 : 1.0)
    }
}
