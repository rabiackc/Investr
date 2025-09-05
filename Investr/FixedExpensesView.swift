// FixedExpensesView.swift
import SwiftUI
import CoreData

struct FixedExpensesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: FixedExpense.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FixedExpense.createdAt, ascending: false)]
    ) private var expenses: FetchedResults<FixedExpense>

    @State private var showAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(expenses, id: \.objectID) { expense in
                    HStack {
                        Text(expense.name ?? "—")
                        Spacer()
                        // amount özelliğini doğru bir şekilde formatlamak için NumberFormatter kullanıldı
                        Text("\(expense.amount as? Double ?? 0, specifier: "%.2f") TL")
                    }
                }
                .onDelete(perform: deleteExpense)
            }
            .navigationTitle("Sabit Giderler")
            .toolbar {
                Button(action: { showAdd.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddExpenseView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteExpense(at offsets: IndexSet) {
        offsets.map { expenses[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
#Preview {
    FixedExpensesView()
}
