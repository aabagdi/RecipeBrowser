//
//  RecipeViewModel.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/30/23.
//

import Foundation

extension RecipeView {
    @MainActor class RecipeViewModel : ObservableObject {
        @Published var recipeSteps = [String : String?]()
        
        let currentMeal : MealEntry
        
        init(currentMeal: MealEntry) {
            self.currentMeal = currentMeal

        }
        
        func loadRecipe() async {
            guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(currentMeal.idMeal)") else {
                print("Invalid URL")
                return
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let decodedResponse = try? JSONDecoder().decode(Recipe.self, from: data) {
                    let rawRecipe = decodedResponse.meals.first!
                    let cleanedRecipe = ((rawRecipe.compactMapValues({ $0 })).filter( { !$0.value.isEmpty })).filter( { !($0.value == " ") })
                    recipeSteps = cleanedRecipe
                }
            } catch {
                print("Invalid data")
            }
        }
        
        func extractIngredients() -> Set<Ingredient> {
            var ingredientSet = Set<Ingredient>()
            for i in 1...20 {
                if recipeSteps.keys.contains("strIngredient\(i)") {
                    let newIngredient = Ingredient(ingredientName: recipeSteps["strIngredient\(i)"]!!.capitalized, amount: (recipeSteps["strMeasure\(i)"])!!)
                    ingredientSet.insert(newIngredient)
                }
                else {
                    return ingredientSet
                }
            }
            return ingredientSet
        }
        
        func returnMeal() -> MealEntry {
            return currentMeal
        }
    }
}
