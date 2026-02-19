import SwiftUI
import Charts

struct MonthlySummaryView: View {
    @Environment(BudgetManager.self) private var budgetManager
    @State private var showingResetConfirmation = false

    // Gradient used across the view
    private let accentGradient = LinearGradient(
        colors: [Color(hue: 0.60, saturation: 0.70, brightness: 0.85),
                 Color(hue: 0.73, saturation: 0.75, brightness: 0.65)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // ── Top Stats Cards ───────────────────────────────
                        HStack(spacing: 14) {
                            StatMiniCard(
                                title: "Treat Spent",
                                amount: budgetManager.spent(category: .treat),
                                icon: "gift.fill",
                                color: Color(hue: 0.60, saturation: 0.70, brightness: 0.82)
                            )
                            StatMiniCard(
                                title: "Personal Spent",
                                amount: budgetManager.spent(category: .personal),
                                icon: "person.fill",
                                color: Color(hue: 0.38, saturation: 0.65, brightness: 0.68)
                            )
                        }
                        .padding(.horizontal)

                        // Saved card
                        SavedBannerCard(amount: budgetManager.totalSaved, gradient: accentGradient)
                            .padding(.horizontal)

                        // ── Spending Breakdown Pie ────────────────────────
                        if let budget = budgetManager.currentBudget, !budget.transactions.isEmpty {
                            PremiumCard(title: "Spending Breakdown", icon: "chart.pie.fill") {
                                Chart {
                                    SectorMark(
                                        angle: .value("Amount", budgetManager.spent(category: .treat)),
                                        innerRadius: .ratio(0.55),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(Color(hue: 0.60, saturation: 0.70, brightness: 0.82))
                                    .cornerRadius(6)

                                    SectorMark(
                                        angle: .value("Amount", budgetManager.spent(category: .personal)),
                                        innerRadius: .ratio(0.55),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(Color(hue: 0.38, saturation: 0.65, brightness: 0.68))
                                    .cornerRadius(6)
                                }
                                .frame(height: 200)
                                .padding(.vertical, 8)

                                // Legend
                                HStack(spacing: 24) {
                                    LegendDot(color: Color(hue: 0.60, saturation: 0.70, brightness: 0.82), label: "Treat")
                                    LegendDot(color: Color(hue: 0.38, saturation: 0.65, brightness: 0.68), label: "Personal")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)

                            // ── Daily Trend Line Chart ────────────────────
                            let daily = dailySpending(transactions: budget.transactions)

                            PremiumCard(title: "Daily Trend", icon: "chart.line.uptrend.xyaxis") {
                                Chart {
                                    ForEach(daily, id: \.date) { item in
                                        LineMark(
                                            x: .value("Day", item.date, unit: .day),
                                            y: .value("Amount", item.amount)
                                        )
                                        .foregroundStyle(accentGradient)
                                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                                        .interpolationMethod(.catmullRom)

                                        AreaMark(
                                            x: .value("Day", item.date, unit: .day),
                                            y: .value("Amount", item.amount)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(hue: 0.60, saturation: 0.70, brightness: 0.85).opacity(0.35),
                                                    Color(hue: 0.73, saturation: 0.75, brightness: 0.65).opacity(0.0)
                                                ],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                        )
                                        .interpolationMethod(.catmullRom)

                                        PointMark(
                                            x: .value("Day", item.date, unit: .day),
                                            y: .value("Amount", item.amount)
                                        )
                                        .foregroundStyle(Color(hue: 0.60, saturation: 0.70, brightness: 0.85))
                                        .symbolSize(40)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) {
                                        AxisValueLabel(format: .dateTime.day(), centered: true)
                                            .font(.caption2)
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                            .foregroundStyle(Color.secondary.opacity(0.3))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisValueLabel {
                                            if let v = value.as(Double.self) {
                                                Text("৳\(Int(v))")
                                                    .font(.caption2)
                                            }
                                        }
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                            .foregroundStyle(Color.secondary.opacity(0.3))
                                    }
                                }
                                .frame(height: 210)
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                        }

                        // ── Reset Button ─────────────────────────────────
                        Button(role: .destructive) {
                            showingResetConfirmation = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "archivebox.fill")
                                Text("End Month & Reset")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [Color(hue: 0.0, saturation: 0.75, brightness: 0.75),
                                                        Color(hue: 0.05, saturation: 0.80, brightness: 0.65)],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: .red.opacity(0.25), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal)

                        Text("This will archive the current month and start fresh.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Summary")
            .alert("End Current Month?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("End & Archive", role: .destructive) {
                    budgetManager.archiveCurrentBudget()
                }
            } message: {
                Text("Are you sure? This action cannot be undone.")
            }
        }
    }

    func dailySpending(transactions: [Transaction]) -> [(date: Date, amount: Double)] {
        let grouped = Dictionary(grouping: transactions) {
            Calendar.current.startOfDay(for: $0.date)
        }
        return grouped.map { (key, value) in
            (date: key, amount: value.reduce(0) { $0 + $1.amount })
        }.sorted { $0.date < $1.date }
    }
}

// ── Supporting Views ──────────────────────────────────────────────────────────

struct StatMiniCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.subheadline)
                Spacer()
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(Image(systemName: icon).font(.caption).foregroundStyle(color))
            }
            Text("৳\(amount, specifier: "%.0f")")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct SavedBannerCard: View {
    let amount: Double
    let gradient: LinearGradient

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(amount >= 0 ? "Total Saved" : "Over Budget")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text("৳\(abs(amount), specifier: "%.0f")")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Image(systemName: amount >= 0 ? "banknote.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(20)
        .background(amount >= 0 ? gradient : LinearGradient(colors: [.red.opacity(0.8), .orange.opacity(0.7)],
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 14, x: 0, y: 7)
    }
}

struct PremiumCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
