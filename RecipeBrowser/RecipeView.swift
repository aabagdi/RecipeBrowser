//
//  RecipeView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct RecipeView: View {
    @State private var recipeSteps = [String : String?]()
    @State private var servings : Int = 1
    @EnvironmentObject var favorites : Favorites
    
    
    let currentMeal : MealEntry
    let mealID : String
    
    var body: some View {
        let imageURL =  "\((recipeSteps["strSource"] ?? "unknown source")!)"
        let ingredients = extractIngredients().sorted(by: { $0.key < $1.key} )
        GeometryReader { g in
            List {
                Section {
                    VStack {
                        HStack {
                            Spacer()
                            AsyncImage(url: URL(string: (recipeSteps["strMealThumb"] ?? "https://htmlcolorcodes.com/assets/images/colors/gray-color-solid-background-1920x1080.png")!)!, scale: 50.0) { image in image.resizable() } placeholder: { Color.gray }
                                .frame(width: g.size.width * 0.7633587786, height: g.size.width * 0.7633587786) .clipShape(RoundedRectangle(cornerRadius: 10))
                            Spacer()
                        }
                        Text("A delicious \((recipeSteps["strArea"] ?? "loading")!) \((recipeSteps["strCategory"] ?? "loading")!.lowercased())!")
                            .font(.subheadline)
                        Text("Tags: \((recipeSteps["strTags"] ?? "N/A")!)")
                            .font(.caption)
                        Link("Tap here for recipe video!", destination: URL(string: (recipeSteps["strYoutube"] ?? "loading")!)!)
                    }
                }
                
                Section {
                    HStack{
                        Spacer()
                        Button(favorites.contains(currentMeal) ? "Remove from Favorites" : "Add to Favorites") {
                            if favorites.contains(currentMeal) {
                                favorites.remove(currentMeal)
                            } else {
                                favorites.add(currentMeal)
                            }
                        }
                        Spacer()
                    }
                }
                
                Section(header: Text("You will need:")) {
                    ForEach(ingredients, id: \.key) { ingredient, amount in
                        Text("**\(ingredient)**: \(amount)")
                    }
                }
                .headerProminence(.increased)
                
                Section {
                    Text((recipeSteps["strInstructions"] ?? "loading")!)
                } header: {
                    Text("Recipe:")
                        .headerProminence(.increased)
                } footer: {
                    Text("Recipe courtesy of \(try! AttributedString(markdown: imageURL))")
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



