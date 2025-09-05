import SwiftUI
import CoreData

struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Uygulama genelinde onboarding durumunu saklar.
    @AppStorage("isOnboarded") private var isOnboarded: Bool = false
    
    @State private var monthlyIncome: String = ""
    @State private var investmentTargetPercentage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aylık Gelir ve Yatırım Hedefi")) {
                    TextField("Aylık Gelir (₺)", text: $monthlyIncome)
                        .keyboardType(.decimalPad)
                    
                    TextField("Yatırım Hedef Yüzdesi (%)", text: $investmentTargetPercentage)
                        .keyboardType(.decimalPad)
                }
                
                // MARK: - Başla Butonu Eklendi
                Button("Başla") {
                    // Bu butona basıldığında onboarding'i tamamla
                    isOnboarded = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .listRowBackground(Color.clear)
                
            }
            .navigationTitle("Kurulum")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveUserProfile()
                    }
                    .disabled(monthlyIncome.isEmpty || investmentTargetPercentage.isEmpty)
                }
            }
        }
    }
    
    private func saveUserProfile() {
        // Kullanıcının girdiği değerler sayıya çevrilemezse kaydetme
        guard let incomeValue = Decimal(string: monthlyIncome),
              let targetValue = Decimal(string: investmentTargetPercentage) else {
            print("⚠️ Geçersiz giriş: Gelir veya hedef yüzdesi sayı değil.")
            return
        }
        
        let newUserProfile = UserProfile(context: viewContext)
        newUserProfile.monthlyIncome = NSDecimalNumber(decimal: incomeValue)
        newUserProfile.investmentTargetPercentage = NSDecimalNumber(decimal: targetValue)
        newUserProfile.startDayOfMonth = 1
        
        do {
            try viewContext.save()
            // ✅ Onboarding tamamlandı → RootView ana ekrana yönlendirecek
            isOnboarded = true
        } catch {
            // ❌ fatalError yerine sadece hata logla
            print("⚠️ Kullanıcı profili kaydedilemedi: \(error.localizedDescription)")
        }
    }
}

// Önizleme
#Preview {
    OnboardingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
