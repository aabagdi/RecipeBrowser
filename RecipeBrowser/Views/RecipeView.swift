//
//  RecipeView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct RecipeView: View {
    @State private var recipeSteps = [String : String?]()
    @EnvironmentObject var favorites : Favorites
    @Binding var id: UUID
    
    let currentMeal : MealEntry
    let mealID : String
    
    var body: some View {
        let imageURL =  "\((recipeSteps["strSource"] ?? "unknown source")!)"
        let ingredients = extractIngredients().sorted(by: { $0.ingredientName < $1.ingredientName} )
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
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Link(destination: URL(string: (recipeSteps["strYoutube"] ?? "loading")!)!) {
                            HStack {
                                Spacer()
                                Image(systemName: "play.rectangle.fill")
                                    .foregroundColor(Color.red)
                                    .font(.headline)
                                Text("Recipe Video")
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
                
                Section(header: Text("You will need:")) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        Text("**\(ingredient.ingredientName)**: \(ingredient.amount)")
                    }
                }
                .headerProminence(.increased)
                
                Section {
                    Text((recipeSteps["strInstructions"] ?? "loading")!)
                        .textSelection(.enabled)
                } header: {
                    Text("Recipe:")
                        .headerProminence(.increased)
                } footer: {
                    Text("Recipe courtesy of \(try! AttributedString(markdown: imageURL))")
                        .font(.caption)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if favorites.contains(currentMeal) {
                            favorites.remove(currentMeal)
                            id = UUID()
                        } else {
                            favorites.add(currentMeal)
                            id = UUID()
                        }
                    } label: {
                        Image(systemName: favorites.contains(currentMeal)  ? "heart.fill" : "heart")
                            .foregroundColor(Color.red)
                    }
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
    
    func extractIngredients() -> [Ingredient] {
        var ingredientList = [Ingredient]()
        for i in 1...20 {
            if recipeSteps.keys.contains("strIngredient\(i)") {
                let newIngredient = Ingredient(ingredientName: recipeSteps["strIngredient\(i)"]!!.capitalized, amount: (recipeSteps["strMeasure\(i)"])!!)
                ingredientList.append(newIngredient)
            }
            else {
                return Array(Set(ingredientList))
            }
        }
        return Array(Set(ingredientList))
    }
    
    func returnMeal() -> MealEntry {
        return currentMeal
    }
}
