//
//  RecipeView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct RecipeView: View {
    @State private var recipeSteps = [String: String?]()
    
    let mealID : String
    
    var body: some View {
        Text((recipeSteps["strMeal"] ?? "loading" )!)
            .font(.headline)
        List {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: (recipeSteps["strMealThumb"] ?? "loading" )!)!, scale: 50.0) { image in image.resizable() } placeholder: { Color.gray } .frame(width: 300, height: 300) .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                    }
                    Text("A delicious \((recipeSteps["strArea"] ?? "loading")!) \((recipeSteps["strCategory"] ?? "loading")!.lowercased())!")
                        .font(.caption)
                    Link("Click here for recipe video!", destination: URL(string: (recipeSteps["strYoutube"] ?? "loading" )!)!)

                }
            }
            ForEach(Array(recipeSteps.keys.enumerated()), id: \.element) { _, step in
                if let description = recipeSteps[step]! {
                    Text("Step \(step): \(description)")
                } else {
                    Text("no description")
                }
            }
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
                let rawRecipe = decodedResponse.meals.first!
                let cleanedRecipe = ((rawRecipe.compactMapValues({ $0 })).filter( { !$0.value.isEmpty })).filter( { !($0.value == " ") })
                recipeSteps = cleanedRecipe
            }
        } catch {
            print("Invalid data")
        }
    }
}
