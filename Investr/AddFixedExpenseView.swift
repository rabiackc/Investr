import SwiftUI
import CoreData

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) { // Form yerine VStack kullanarak daha esnek bir düzenleme
                
                // Gider Adı Alanı
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gider Adı")
                        .font(.headline)
                    TextField("Örn: Kira, Market", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocorrectionDisabled(true)
                }
                
                // Tutar Alanı
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tutar (₺)")
                        .font(.headline)
                    TextField("0,00", text: $amount)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.decimalPad)
                }
                
                Spacer() // Sayfanın üst kısmında kalmasını sağlar
                
                // Kaydet Butonu
                Button("Kaydet") {
                    saveExpense()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(name.isEmpty || amount.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(name.isEmpty || amount.isEmpty)
                
            }
            .padding()
            .navigationTitle("Yeni Sabit Gider")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveExpense() {
        let expense = FixedExpense(context: viewContext)
        expense.name = name
        expense.amount = Double(amount) ?? 0
        expense.createdAt = Date()
        
        try? viewContext.save()
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
