//
//  RecipeView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct RecipeView: View {
    @State private var recipeSteps = [String : String?]()
    @State private var ingredients = [String : String]()
    
    let mealID : String
    
    var body: some View {
        let imageURL =  "\((recipeSteps["strSource"] ?? "unknown")!)"
        
        Text((recipeSteps["strMeal"] ?? "loading" )!)
            .font(.headline)
        GeometryReader { g in
            List {
                Section {
                    VStack {
                        HStack {
                            Spacer()
                            AsyncImage(url: URL(string: (recipeSteps["strMealThumb"] ?? "https://user-images.githubusercontent.com/42506001/221354918-01bf0e89-48be-4df7-85bb-cdf5d0136f2a.png" )!)!, scale: 50.0) { image in image.resizable() } placeholder: { Color.gray } .frame(width: g.size.width * 0.7633587786, height: g.size.width * 0.7633587786) .clipShape(RoundedRectangle(cornerRadius: 10))
                            Spacer()
                        }
                        Text("A delicious \((recipeSteps["strArea"] ?? "loading")!) \((recipeSteps["strCategory"] ?? "loading")!.lowercased())!")
                            .font(.caption)
                        Link("Click here for recipe video!", destination: URL(string: (recipeSteps["strYoutube"] ?? "loading")!)!)
                    }
                }
                
                Section(header: Text("You will need:")) {
                    ForEach(Array(ingredients.keys.enumerated()), id: \.element) { _, ingredient in
                        if let amount = ingredients[ingredient] {
                            Text("**\(ingredient)**: \(amount)")
                        } else {
                            Text("no description")
                        }
                    }
                }
                .headerProminence(.increased)
                
                Section {
                    Text((recipeSteps["strInstructions"] ?? "loading")!)
                } header: {
                    Text("Recipe:")
                        .headerProminence(.increased)
                } footer: {
                    Text("Recipe courtesy of: \(try! AttributedString(markdown: imageURL))")
                        .font(.caption)
                }
            }
            .task {
                await loadRecipe()
            }
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
                ingredients = extractIngredients()
            }
        } catch {
            print("Invalid data")
        }
    }
    
    func extractIngredients() -> [String : String] {
        var blankDict = [String : String]()
        for i in 1...20 {
            if recipeSteps.keys.contains("strIngredient\(i)") {
                blankDict[recipeSteps["strIngredient\(i)"]!!.capitalized] = (recipeSteps["strMeasure\(i)"])!!
            }
            else {
                return blankDict
            }
        }
        return blankDict
    }
}



