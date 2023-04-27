//
//  Favorites.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/27/23.
//

import Foundation

class Favorites : ObservableObject {
    private var meals : Set<String>
    
    private let key = "FAVES"
    
    init() {
        meals = []
    }
    
    func contains(_ meal : MealEntry) -> Bool {
        meals.contains(meal.idMeal)
    }
    
    func add(_ meal: MealEntry) {
        objectWillChange.send()
        meals.insert(meal.idMeal)
    }
    
    func remove(_ meal: MealEntry) {
        objectWillChange.send()
        meals.remove(meal.idMeal)
        save()
    }
    
    func save() {
        
    }
    
}
