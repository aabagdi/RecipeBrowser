//
//  RecipeView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct RecipeView: View {
    @StateObject var ViewModel : RecipeViewModel
    @EnvironmentObject var favorites : Favorites
    @Binding var id: UUID
    
    var body: some View {
        let sourceURL =  "\((ViewModel.recipeSteps["strSource"] ?? "unknown source")!)"
        let ingredients = ViewModel.extractIngredients().sorted(by: { $0.ingredientName < $1.ingredientName} )
        GeometryReader { g in
            List {
                Section {
                    VStack {
                        HStack {
                            Spacer()
                            AsyncImage(url: URL(string: (ViewModel.recipeSteps["strMealThumb"] ?? "https://htmlcolorcodes.com/assets/images/colors/gray-color-solid-background-1920x1080.png")!)!, scale: 50.0) { image in image.resizable() } placeholder: { Color.gray }
                                .frame(width: g.size.width * 0.7633587786, height: g.size.width * 0.7633587786) .clipShape(RoundedRectangle(cornerRadius: 10))
                            Spacer()
                        }
                        Text("A delicious \((ViewModel.recipeSteps["strArea"] ?? "loading")!) \((ViewModel.recipeSteps["strCategory"] ?? "loading")!.lowercased())!")
                            .font(.subheadline)
                        Text("Tags: \((ViewModel.recipeSteps["strTags"] ?? "N/A")!)")
                            .font(.caption)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Link(destination: URL(string: (ViewModel.recipeSteps["strYoutube"] ?? "loading")!)!) {
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
                    Text((ViewModel.recipeSteps["strInstructions"] ?? "loading")!)
                        .textSelection(.enabled)
                } header: {
                    Text("Recipe:")
                        .headerProminence(.increased)
                } footer: {
                    Text("Recipe courtesy of \(try! AttributedString(markdown: sourceURL))")
                        .font(.caption)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if favorites.contains(ViewModel.currentMeal) {
                            favorites.remove(ViewModel.currentMeal)
                            id = UUID()
                        } else {
                            favorites.add(ViewModel.currentMeal)
                            id = UUID()
                        }
                    } label: {
                        Image(systemName: favorites.contains(ViewModel.currentMeal)  ? "heart.fill" : "heart")
                            .foregroundColor(Color.red)
                    }
                }
            }
            .task {
                await ViewModel.loadRecipe()
            }
        }
    }
}
