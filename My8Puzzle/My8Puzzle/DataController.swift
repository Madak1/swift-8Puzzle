
import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "PuzzleDatabase")
    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Set the default settings
        if !UserDefaults.standard.bool(forKey: "DefaultValuesAdded") {
            addDefaultValues(context: container.viewContext)
            UserDefaults.standard.set(true, forKey: "DefaultValuesAdded")
        }
        
        // Add test users to see the leaderboards
        // TODO: Uncomment the following line to add some radom test user
        if !UserDefaults.standard.bool(forKey: "TestUsersAdded") {
            // addTestUsers(context: container.viewContext, num: 99)
            UserDefaults.standard.set(true, forKey: "TestUsersAdded")
        }
    }
    
    // Add the settings (Music and tilt control)
    private func addDefaultValues(context: NSManagedObjectContext) {
        
        let tiltControlSetting = Setting(context: context)
        tiltControlSetting.id = UUID()
        tiltControlSetting.name = "Tilt control"
        tiltControlSetting.value = false
        
        let musicSetting = Setting(context: context)
        musicSetting.id = UUID()
        musicSetting.name = "Music"
        musicSetting.value = true
        
        do {
            try context.save()
        } catch {
            print("Core Data failed to add default values: \(error)")
        }
    }
    
    // If we want to test the leaderboard we can add some test user
    private func addTestUsers(context: NSManagedObjectContext, num: Int) {
        let names = ["testuser", "gamer123", "asdfgh", "h3lloW", "w1n3r", "mike22", "12345678", "username", "realname", "test", "MAD", "myName"]
        for _ in 0..<num {
            let score = Score(context: context)
            score.id = UUID()
            score.username = names.randomElement()
            score.score = Int16.random(in: 0...900)
            try? context.save()
        }
    }
    
}
