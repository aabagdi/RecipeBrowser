//
//  ContentView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct MealListView: View {
    @ObservedObject var ViewModel : MealListViewModel = MealListViewModel()
    @StateObject var favorites = Favorites()

    var body: some View {
        if !ViewModel.showingFaves {
            NavigationStack {
                List(ViewModel.searchResults, id: \.idMeal) { item in
                    let foodImage = URL(string: item.strMealThumb)!
                    NavigationLink(destination: RecipeView(currentMeal: item, mealID: item.idMeal).navigationBarTitle(item.strMeal, displayMode: .inline).environmentObject(favorites)) {
                        HStack {
                            AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(item.strMeal)
                            Spacer()
                            Image(systemName: favorites.contains(item) ? "heart.fill" : "heart")
                                .foregroundColor(Color.red)
                        }
                    }
                }
                .navigationBarTitle(Text("Choose a recipe!"), displayMode: .inline)
                .searchable(text: $ViewModel.searchString,  placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for recipe...")
                .task {
                    await ViewModel.loadList()
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(ViewModel.buttonTitle) {
                            ViewModel.showingFaves.toggle()
                        }
                    }
                }
            }
        }
        else {
            NavigationStack {
                List(ViewModel.searchResults, id: \.idMeal) { item in
                    if favorites.contains(item) {
                        let foodImage = URL(string: item.strMealThumb)!
                        NavigationLink(destination: RecipeView(currentMeal: item, mealID: item.idMeal).navigationBarTitle(item.strMeal, displayMode: .inline).environmentObject(favorites)) {
                            HStack {
                                AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                                Text(item.strMeal)
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                }
                .navigationBarTitle(Text("Choose a recipe!"), displayMode: .inline)
                .searchable(text: $ViewModel.searchString,  placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for recipe...")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(ViewModel.buttonTitle) {
                            ViewModel.showingFaves.toggle()
                        }
                    }
                }
            }
            .onAppear {
                favorites.load()
            }
        }
    }
}
