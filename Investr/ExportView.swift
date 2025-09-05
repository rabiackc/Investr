// Ayarlar Sayfası örneği (basitleştirilmiş)
import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var userProfiles: FetchedResults<UserProfile>
    
    @State private var startDay: Int = 1
    
    var body: some View {
        Form {
            Section(header: Text("Ayarları Yönet")) {
                Picker("Ayın Başlangıç Günü", selection: $startDay) {
                    ForEach(1...28, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
            }
            
            Button("Ayı Sıfırla") {
                // Tüm harcama verilerini silme
                resetMonth()
            }
            .foregroundColor(.red)
        }
        .onAppear {
            if let userProfile = userProfiles.first {
                startDay = Int(userProfile.startDayOfMonth)
            }
        }
    }
    
    private func resetMonth() {
        // Core Data'dan DailyExpense ve FixedExpense verilerini silme
    }
}
