# iOS-GreenRecipes

## Introduction

This iOS app built using Swift 5 and Xcode 12 is designed for improving one's  Vegan and Vegetarian cooking skills by browsing recipes
in various categories.

The app consumes [Spoonacular API](https://spoonacular.com/food-api) which is a well known Food and Meal API.

## Installation

Simple clone the current repository as follows,

`git clone git@github.com:anupamberi/iOS-GreenRecipes.git`

Once the repository is cloned, the application can be launched using the normal Xcode app launch button and by selecting an IPhone
simulator.


## Details and Usage

### App Launch

On launching the app, a splash screen is presented.

![LaunchScreen](screenshots/LaunchScreen.png)

### Home

After the launch screen,  a tabbed view controller is then presented that contains three tabs

- Home
- Search
- Profile

The home tab then shows the recommended recipes after downloading the latest recipes across different recipe categories e.g recommendations,
main course, desserts etc.

![RecicpesHome](screenshots/RecipesHomeViewController1.png)

Each sections of the Home View contains horizontally scrollable views of different recipes.

![RecicpesHome](screenshots/RecipesHomeViewController2.png)

### Search Recipes

The users can search recipes using the search bar based on any keyword eg. tofu, hummus etc.
By default, some recipe categories are offered and presented in a horizontally scrolling view.
Some of these categories are cuisine specific and others are general.

![RecipesSearch](screenshots/RecipesSearchViewController1.png)

On clicking the search bar, the recipe search categories view is hidden and the user can type and search any recipes.
These are then presented as shown below,

![RecipesSearch](screenshots/RecipesSearchViewController2.png)

On clicking the cancel button, the previous view and recipe category and its recipes are presented to the user.

The user can subsequently re-search another recipe and the same UI behaviour repeats.

### Recipe Details

For viewing the recipe details, from any view the user can simply click on the recipe and the recipe details view is presented.

![RecipeDetails](screenshots/RecipeDetailsViewController1.png)

![RecipeDetails](screenshots/RecipeDetailsViewController2.png)

The recipe nutrition information, ingredients and detailed step by step instructions are presented to the user.


## Motivation

This small app was built from a personal ambition to improve my cooking skills.
