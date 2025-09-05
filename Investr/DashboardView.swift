//
//  DashboardView.swift
//  Investr
//
//  Created by Rabia Çakıcı on 1.09.2025.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var userProfiles: FetchedResults<UserProfile>
    @FetchRequest(sortDescriptors: []) private var fixedExpenses: FetchedResults<FixedExpense>
    @FetchRequest(sortDescriptors: []) private var dailyExpenses: FetchedResults<DailyExpense>

    // MARK: - Çözüm İçin Yeni Değişken
    @State private var showingAddDailyExpenseSheet = false

    // MARK: - Dashboard Metrics
    var monthlyIncome: Double {
        (userProfiles.first?.monthlyIncome as? NSDecimalNumber)?.doubleValue ?? 0
    }

    var totalFixedExpenses: Double {
        fixedExpenses.reduce(0) { $0 + (($1.amount as? NSDecimalNumber)?.doubleValue ?? 0) }
    }

    var totalDailyExpenses: Double {
        dailyExpenses.reduce(0) { $0 + (($1.amount as? NSDecimalNumber)?.doubleValue ?? 0) }
    }
    
    // Y_target
    var investmentTargetAmount: Double {
        let targetPercentage = (userProfiles.first?.investmentTargetPercentage as? NSDecimalNumber)?.doubleValue ?? 0
        return monthlyIncome * (targetPercentage / 100)
    }

    // S_left (Savings)
    var remainingBudget: Double {
        monthlyIncome - totalFixedExpenses - totalDailyExpenses
    }
    
    // D_left
    var daysLeftInMonth: Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let currentDay = calendar.component(.day, from: today)
        return range.count - currentDay
    }
    
    // Hedef göstergesi için çubuk rengi
    var progressBarColor: Color {
        remainingBudget >= investmentTargetAmount ? .green : .red
    }
    
    // Hedef göstergesi için metin
    var targetText: String {
        let difference = abs(investmentTargetAmount - remainingBudget)
        
        if remainingBudget >= investmentTargetAmount {
            return "Hedefinize ulaştınız! Hedefinizin \(String(format: "%.2f", difference)) TL üzerindesiniz."
        } else {
            return "Hedefinizden \(String(format: "%.2f", difference)) TL uzaktasınız."
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Özet Değerler Kartı
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mali Durum")
                            .font(.title2.bold())
                        
                        Divider()
                        
                        SummaryRow(title: "Aylık Gelir", value: monthlyIncome)
                        SummaryRow(title: "Sabit Giderler", value: totalFixedExpenses)
                        SummaryRow(title: "Günlük Harcamalar", value: totalDailyExpenses)
                        
                        Divider()
                        
                        SummaryRow(title: "Kalan Bütçe", value: remainingBudget, isPositive: remainingBudget > 0)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Ay sonuna kalan gün:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(daysLeftInMonth)")
                        }
                        .font(.footnote)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    // Yatırım Hedefi Göstergesi
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Yatırım Hedefi")
                            .font(.title2.bold())
                        
                        ProgressView(value: remainingBudget, total: investmentTargetAmount)
                            .tint(progressBarColor)
                            .scaleEffect(x: 1, y: 3, anchor: .center)
                            .padding(.vertical)
                        
                        Text(targetText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Dashboard")
                // Günlük Harcama Ekle butonu
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Yeni eklenen satır: showingAddDailyExpenseSheet değişkenini true yapar
                            self.showingAddDailyExpenseSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                // Yeni eklenen satır: showingAddDailyExpenseSheet true olduğunda DailyExpenseView'i açar
                .sheet(isPresented: $showingAddDailyExpenseSheet) {
                    DailyExpenseView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}

// Yardımcı View
struct SummaryRow: View {
    var title: String
    var value: Double
    var isPositive: Bool = true
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(value, specifier: "%.2f") TL")
                .font(.body)
                .foregroundColor(isPositive ? .primary : .red)
        }
    }
}

#Preview {
    DashboardView()
}
