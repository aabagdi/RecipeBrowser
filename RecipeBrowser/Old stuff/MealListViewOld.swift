//
//  ContentView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct MealListViewOld: View {
    @State private var meals = [MealEntry]()
    @State private var searchString = ""
    @State private var showingFaves = false
    @StateObject var favorites = Favorites()
    
    var searchResults : [MealEntry] {
        if searchString.isEmpty {
            return meals
        }
        else {
            return meals.filter({ $0.strMeal.localizedCaseInsensitiveContains(searchString) })
        }
    }
    
    var body: some View {
        if !showingFaves {
            NavigationStack {
                List(searchResults, id: \.idMeal) { item in
                    let foodImage = URL(string: item.strMealThumb)!
                    NavigationLink(destination: RecipeView(currentMeal: item, mealID: item.idMeal).navigationTitle(item.strMeal).environmentObject(favorites)) {
                        HStack {
                            AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(item.strMeal)
                            if favorites.contains(item) {
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .accessibilityLabel("Favorite this recipe!")
                                    .foregroundColor(Color.red)
                                    .onTapGesture {
                                        favorites.remove(item)
                                    }
                            }
                            else {
                                Spacer()
                                Image(systemName: "heart")
                                    .accessibilityLabel("Favorite this recipe!")
                                    .foregroundColor(Color.red)
                                    .onTapGesture {
                                        favorites.add(item)
                                    }
                            }
                        }
                    }
                }
                .navigationTitle(Text("Choose a recipe!"))
                .searchable(text: $searchString,  placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for recipe...")
                .task {
                    await loadList()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(showingFaves ? "Show all recipes" : "Show favorites") {
                        showingFaves.toggle()
                    }
                }
            }
            .onDisappear {
                favorites.load()
            }
        }
        else {
            NavigationStack {
                List(searchResults, id: \.idMeal) { item in
                    if favorites.contains(item) {
                        let foodImage = URL(string: item.strMealThumb)!
                        NavigationLink(destination: RecipeView(currentMeal: item, mealID: item.idMeal).navigationTitle(item.strMeal).environmentObject(favorites)) {
                            HStack {
                                AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                                Text(item.strMeal)
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .accessibilityLabel("Favorite this recipe!")
                                    .foregroundColor(Color.red)
                                    .onTapGesture {
                                        favorites.remove(item)
                                    }
                            }
                        }
                    }
                }
                .navigationTitle(Text("Choose a recipe!"))
                .searchable(text: $searchString,  placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for recipe...")
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(showingFaves ? "Show all recipes" : "Show favorites") {
                        showingFaves.toggle()
                    }
                }
            }
            .onDisappear {
                favorites.load()
            }
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
}
