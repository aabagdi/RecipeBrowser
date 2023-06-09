//
//  RecipeBrowserTests.swift
//  RecipeBrowserTests
//
//  Created by Aadit Bagdi on 4/29/23.
//

import XCTest
@testable import RecipeBrowser
import SwiftUI

final class RecipeBrowserTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadMealList() async {
        let viewModel = await MealListView.MealListViewModel()
        await viewModel.loadList()
        let mealList = await viewModel.returnMeals()
        XCTAssertEqual(mealList.count, 64)
    }
    
    func testLoadRecipe() async {
        let view = await MealListView()
        let viewModel = await MealListView.MealListViewModel()
        await viewModel.loadList()
        let mealList = await viewModel.returnMeals()
        let recipe = await RecipeView.RecipeViewModel(currentMeal: viewModel.returnMeals().first!)
        await recipe.loadRecipe()
        let currentRecipe = await recipe.returnMeal()
        XCTAssertEqual(currentRecipe.strMeal, "Apam balik")
    }
    
    func testExtractIngredients() async {
        let view = await MealListView()
        let viewModel = await MealListView.MealListViewModel()
        await viewModel.loadList()
        let mealList = await viewModel.returnMeals()
        let recipe = await RecipeView.RecipeViewModel(currentMeal: viewModel.returnMeals().first!)
        await recipe.loadRecipe()
        let ingredientsList = await recipe.extractIngredients()
        XCTAssertEqual(ingredientsList.count, 9)
    }
}
