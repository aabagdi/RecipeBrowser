//
//  ContentView.swift
//  RecipeBrowser
//
//  Created by Aadit Bagdi on 4/24/23.
//

import SwiftUI

struct MealListView: View {
    @StateObject var ViewModel : MealListViewModel = MealListViewModel()
    @StateObject var favorites = Favorites()
    @State var id = UUID()

    var body: some View {
        switch ViewModel.showingFaves {
        case false:
            NavigationStack {
                List(ViewModel.searchResults, id: \.idMeal) { item in
                    let foodImage = URL(string: item.strMealThumb)!
                    NavigationLink(destination: RecipeView(ViewModel: RecipeView.RecipeViewModel(currentMeal: item), id: $id).navigationTitle(item.strMeal).environmentObject(favorites)) {
                        HStack {
                            AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(item.strMeal)
                            Spacer()
                            Image(systemName: favorites.contains(item) ? "heart.fill" : "heart")
                                .foregroundColor(Color.red)
                                .onTapGesture {
                                    favorites.contains(item) ? favorites.remove(item) : favorites.add(item)
                                }
                        }
                    }
                }
                .navigationTitle(Text("Choose a recipe!"))
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $ViewModel.searchString,  placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for recipe...")
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
        case true:
            NavigationStack {
                List(ViewModel.searchResults, id: \.idMeal) { item in
                    if favorites.contains(item) {
                        let foodImage = URL(string: item.strMealThumb)!
                        NavigationLink(destination: RecipeView(ViewModel: RecipeView.RecipeViewModel(currentMeal: item), id: $id).navigationTitle(item.strMeal).environmentObject(favorites)) {
                            HStack {
                                AsyncImage(url: foodImage, scale: 30.0){ image in image.resizable() } placeholder: { Color.gray } .frame(width: 75, height: 75) .clipShape(RoundedRectangle(cornerRadius: 10))
                                Text(item.strMeal)
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color.red)
                                    .onTapGesture {
                                        favorites.contains(item) ? favorites.remove(item) : favorites.add(item)
                                    }
                            }
                        }
                    }
                }
                .id(id)
                .navigationTitle(Text("Choose a recipe!"))
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $ViewModel.searchString,  placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for recipe...")
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
    }
}
