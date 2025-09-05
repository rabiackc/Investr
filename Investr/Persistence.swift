import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // Önizleme ve test için in-memory Core Data
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Investr")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // ❌ fatalError yerine sadece logla
                print("⚠️ Core Data yüklenemedi: \(error), \(error.userInfo)")
            }
        }
    }
}

