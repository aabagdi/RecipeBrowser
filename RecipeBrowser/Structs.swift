//
//  Structs.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import Foundation

struct MealEntry : Codable {
    let strMeal : String
    let strMealThumb : String
    let idMeal : String
    
}

struct MealResult : Codable {
    let meals : [MealEntry]
}

struct Recipe: Codable {
    let meals: [[String: String?]]
}

