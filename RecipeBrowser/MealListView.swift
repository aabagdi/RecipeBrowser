//
//  ContentView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct MealListView: View {
    @State private var meals = [MealEntry]()
    @State private var searchString = ""
    
    var searchResults : [MealEntry] {
        if searchString.isEmpty {
            return meals
        }
        else {
            return meals.filter({ $0.strMeal.localizedCaseInsensitiveContains(searchString) })
        }
    }
    
    var body: some View {
        NavigationStack {

            List(searchResults, id: \.idMeal) { item in
                let foodImage = URL(string: item.strMealThumb)!
                NavigationLink(destination: RecipeView(mealID: item.idMeal).navigationTitle(item.strMeal)) {
                    HStack {
                        AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(item.strMeal)
                    }
                }
            }
            .navigationTitle(Text("Choose a recipe!"))
            .searchable(text: $searchString,  placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for recipe...")
            .task {
                await loadList()
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
