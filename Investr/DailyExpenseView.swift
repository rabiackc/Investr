import SwiftUI
import CoreData
import Charts
import UserNotifications

// MARK: - DailyExpenseView
struct DailyExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    // MARK: - State Değişkenleri
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var category: String = "Yiyecek"
    @State private var selectedDate: Date = Date()
    
    // Son kullanılan kategorileri kaydetmek ve okumak için AppStorage
    @AppStorage("lastUsedCategories") private var lastUsedCategoriesData: String = ""
    
    private let categories = ["Yiyecek", "Ulaşım", "Giyim", "Eğlence", "Fatura", "Sağlık", "Eğitim", "Diğer"]
    private let dailyLimit: Double = 200

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Harcama Formu
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Harcama Adı").font(.headline).foregroundColor(.gray)
                        TextField("Örn: Kahve, Market Alışverişi", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocorrectionDisabled(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tutar (₺)").font(.headline).foregroundColor(.gray)
                        TextField("0,00", text: $amount)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kategori").font(.headline).foregroundColor(.gray)
                        Picker("Kategori", selection: $category) {
                            ForEach(categories, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // MARK: - Son Kullanılan Kategoriler
                    HStack {
                        ForEach(recentCategories, id: \.self) { cat in
                            Button(cat) {
                                category = cat
                            }
                            .buttonStyle(.bordered)
                            .cornerRadius(15)
                            .tint(cat == category ? .blue : .gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Kaydet Butonu
                    Button("Kaydet") {
                        saveExpense()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.isEmpty || amount.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(name.isEmpty || amount.isEmpty)
                    
                    // MARK: - Harcama Grafiği
                    VStack(alignment: .leading) {
                        Text("Son Harcamalar").font(.headline)
                        
                        Chart {
                            ForEach(weeklyExpenses, id: \.objectID) { expense in
                                BarMark(
                                    x: .value("Gün", expense.createdAt ?? Date(), unit: .day),
                                    y: .value("Tutar", expense.amount)
                                )
                                .foregroundStyle(by: .value("Kategori", expense.category ?? "Diğer"))
                            }
                            RuleMark(y: .value("Günlük Limit", dailyLimit))
                                .foregroundStyle(.red)
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // MARK: - Kategori Dağılımı
                    VStack(alignment: .leading) {
                        Text("Kategori Dağılımı").font(.headline)
                        
                        Chart {
                            ForEach(categoriesTotals(), id: \.0) { item in
                                SectorMark(
                                    angle: .value("Toplam", item.1),
                                    innerRadius: 60,
                                    angularInset: 1.0
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("Kategori", item.0))
                                .annotation(position: .overlay) {
                                    Text("\(item.1, specifier: "%.0f") TL")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Günlük Harcama")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Fonksiyonlar
    
    private func saveExpense() {
        let expense = DailyExpense(context: viewContext)
        expense.name = name
        expense.amount = Double(amount) ?? 0
        expense.category = category
        expense.createdAt = Date()
        
        // Son kullanılan kategorileri güncelle
        updateLastUsedCategories(with: category)
        
        try? viewContext.save()
        dismiss()
    }

    private func updateLastUsedCategories(with newCategory: String) {
        var categories = lastUsedCategoriesData.components(separatedBy: ",")
        if let index = categories.firstIndex(of: newCategory) {
            categories.remove(at: index)
        }
        categories.insert(newCategory, at: 0)
        
        if categories.count > 4 {
            categories.removeLast(categories.count - 4)
        }
        
        lastUsedCategoriesData = categories.joined(separator: ",")
    }

    private var recentCategories: [String] {
        lastUsedCategoriesData.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyExpense.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@", Calendar.current.date(byAdding: .day, value: -6, to: Date())! as NSDate)
    ) private var weeklyExpenses: FetchedResults<DailyExpense>
    
    private func categoriesTotals() -> [(String, Double)] {
        let categoriesSet = Set(weeklyExpenses.compactMap { $0.category })
        return categoriesSet.map { category in
            let total = weeklyExpenses
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
            return (category, total)
        }
    }
}

// MARK: - Preview
struct DailyExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        for i in 1...5 {
            let expense = DailyExpense(context: context)
            expense.name = "Gider \(i)"
            expense.amount = Double(i * 10)
            expense.createdAt = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            expense.category = ["Yiyecek","Ulaşım","Giyim","Eğlence","Diğer"].randomElement()
        }
        
        return NavigationView {
            DailyExpenseView()
        }
        .tabItem {
            Label("Harcama", systemImage: "plus.circle")
        }
        .environment(\.managedObjectContext, context)
    }
}
