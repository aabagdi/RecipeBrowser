//
//  Favorites.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/27/23.
//

import Foundation
import SwiftUI

class Favorites : ObservableObject {
    private var meals : Set<String>
    
    private let key = "FAVES"
    
    init() {
        if let data = UserDefaults.standard.object(forKey: key) {
            do {
                let decoder = JSONDecoder()
                meals = try decoder.decode(Set<String>.self, from: data as! Data)
                return
            } catch {
                print("Error loading")
            }
        }
        meals = []
    }
    
    func contains(_ meal : MealEntry) -> Bool {
        meals.contains(meal.idMeal)
    }
    
    func add(_ meal: MealEntry) {
        objectWillChange.send()
        meals.insert(meal.idMeal)
        save()
    }
    
    func remove(_ meal: MealEntry) {
        objectWillChange.send()
        meals.remove(meal.idMeal)
        save()
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(meals)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error saving")
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.object(forKey: key) {
            do {
                let decoder = JSONDecoder()
                meals = try decoder.decode(Set<String>.self, from: data as! Data)
                return
            } catch {
                print("Error loading")
            }
        }
    }
}
