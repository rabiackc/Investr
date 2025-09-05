import SwiftUI
import CoreData
import Foundation
import UIKit // UIActivityViewController için UIKit'i import etmemiz gerekiyor.

// MARK: - CSV Exporter
class CSVExporter {
    static func generateCSV(dailyExpenses: [DailyExpense], fixedExpenses: [FixedExpense]) -> URL? {
        // Dosya adı ve yolu
        let fileName = "investr_harcamalar.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        // CSV başlık satırı
        var csvText = "Tarih,Ad,Kategori,Tutar,Tür\n"
        
        // Günlük harcamaları CSV metnine ekle
        for expense in dailyExpenses {
            let dateString = expense.createdAt?.formatted(date: .numeric, time: .omitted) ?? ""
            let name = expense.name ?? ""
            let category = expense.category ?? ""
            let amount = String(format: "%.2f", expense.amount)
            let newLine = "\(dateString),\"\(name)\",\"\(category)\",\(amount),Günlük\n"
            csvText.append(newLine)
        }
        
        // Sabit harcamaları CSV metnine ekle
        for expense in fixedExpenses {
            let dateString = expense.createdAt?.formatted(date: .numeric, time: .omitted) ?? ""
            let name = expense.name ?? ""
            let amount = String(format: "%.2f", expense.amount)
            // Sabit giderlerin kategorisi olmadığı için boş bırakıldı
            let newLine = "\(dateString),\"\(name)\",,\"\(amount)\",Sabit\n"
            csvText.append(newLine)
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("CSV dosyası oluşturulamadı: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Settings View
struct settingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var userProfiles: FetchedResults<UserProfile>
    
    // CoreData'dan günlük ve sabit harcamaları çeker.
    @FetchRequest(sortDescriptors: []) private var dailyExpenses: FetchedResults<DailyExpense>
    @FetchRequest(sortDescriptors: []) private var fixedExpenses: FetchedResults<FixedExpense>

    @State private var startDay: Int = 1
    
    var body: some View {
        Form {
            // Ayarları Yönet bölümü
            Section(header: Text("Ayarları Yönet")) {
                Picker("Ayın Başlangıç Günü", selection: $startDay) {
                    ForEach(1...28, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
            }
            
            // Harcamaları Dışa Aktar butonu bölümü
            Section {
                Button("Harcamaları Dışa Aktar") {
                    if let fileURL = CSVExporter.generateCSV(dailyExpenses: Array(dailyExpenses), fixedExpenses: Array(fixedExpenses)) {
                        // Paylaşım menüsünü UIKit aracılığıyla açar
                        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                        // Ana pencerenin root view controller'ını kullanarak menüyü sunar
                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                    }
                }
            }
            
            // Ayı Sıfırla butonu bölümü
            Section {
                Button("Ayı Sıfırla") {
                    // Tüm harcama verilerini silme
                    resetMonth()
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            if let userProfile = userProfiles.first {
                startDay = Int(userProfile.startDayOfMonth)
            }
        }
    }
    
    private func resetMonth() {
        // Core Data'dan DailyExpense ve FixedExpense verilerini silme
        dailyExpenses.forEach(viewContext.delete)
        fixedExpenses.forEach(viewContext.delete)
        try? viewContext.save()
    }
}

