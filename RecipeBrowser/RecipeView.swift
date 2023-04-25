//
//  RecipeView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct RecipeView: View {
    @State private var RecipeDetails : [[String : String?]] = []
    let mealID : String
    var body: some View {
        List(RecipeDetails.first!.keys, id: \.self) { value in
            Text(value)
        }
        .task {
            await loadRecipe()
        }
    }
    
    func loadRecipe() async {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(mealID)") else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(Recipe.self, from: data) {
                print("Woo")
                RecipeDetails = decodedResponse.meals
            }
        } catch {
            print("Invalid data")
        }
    }
}
