//
//  MealListViewModel.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/29/23.
//

import Foundation

extension MealListView {
    @MainActor class MealListViewModel : ObservableObject {
        @Published var meals = [MealEntry]()
        @Published var searchString = ""
        @Published var showingFaves = false
        
        var buttonTitle : String {showingFaves ? "Show all recipes" : "Show favorites"}
        
        var searchResults : [MealEntry] {
            if searchString.isEmpty {
                return meals
            }
            else {
                return meals.filter({ $0.strMeal.localizedCaseInsensitiveContains(searchString) })
            }
        }
        
        func loadList() async {
            guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
                print("Invalid URL")
                return
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let decodedResponse = try? JSONDecoder().decode(MealResult.self, from: data) {
                    meals = decodedResponse.meals
                }
            } catch {
                print("Invalid data")
            }
        }
        
        func returnMeals() -> [MealEntry] {
            return meals
        }
        
    }
}
