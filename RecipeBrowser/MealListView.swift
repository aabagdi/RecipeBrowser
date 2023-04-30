//
//  ContentView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct MealListView: View {
    @ObservedObject var ViewModel : MealListViewModel = MealListViewModel()
    
    var body: some View {
        if !ViewModel.showingFaves {
            NavigationStack {
                List(ViewModel.searchResults, id: \.idMeal) { item in
                    let foodImage = URL(string: item.strMealThumb)!
                    NavigationLink(destination: RecipeView(currentMeal: item, mealID: item.idMeal).navigationTitle(item.strMeal).environmentObject(ViewModel.favorites)) {
                        HStack {
                            AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(item.strMeal)
                            Spacer()
                            Image(systemName: ViewModel.favorites.contains(item) ? "heart.fill" : "heart")
                                .foregroundColor(Color.red)
                        }
                    }
                }
                .navigationTitle(Text("Choose a recipe!"))
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
                    if ViewModel.favorites.contains(item) {
                        let foodImage = URL(string: item.strMealThumb)!
                        NavigationLink(destination: RecipeView(currentMeal: item, mealID: item.idMeal).navigationTitle(item.strMeal).environmentObject(ViewModel.favorites)) {
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
                .navigationTitle(Text("Choose a recipe!"))
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
                ViewModel.favorites.load()
            }
        }
    }
}
