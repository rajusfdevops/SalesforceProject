import { LightningElement, track } from 'lwc';
import getRandomRecipe from '@salesforce/apex/RecipeApiController.getRandomRecipe';
import searchRecipes from '@salesforce/apex/RecipeApiController.searchRecipes';

export default class RecipeApp extends LightningElement {
    @track recipes = null;
    @track loading = false;
    @track error = null;
    @track searchQuery = '';

    handleSearchChange(event) {
        this.searchQuery = event.detail.value;
    }

    handleSearch() {
        if (!this.searchQuery.trim()) {
            this.error = 'Please enter a recipe name';
            return;
        }
        this.loading = true;
        this.error = null;

        searchRecipes({ query: this.searchQuery, cuisine: null, mealType: null, diet: null, offset: 0 })
            .then(result => {
                console.log('Search result:', result);
                if (result && result.results) {
                    this.recipes = result.results.slice(0, 6);
                } else {
                    this.error = 'No recipes found';
                }
            })
            .catch(error => {
                console.error('Search error:', error);
                this.error = 'Error searching recipes: ' + error.body?.message || error.message;
            })
            .finally(() => {
                this.loading = false;
            });
    }

    handleRandomRecipe() {
        this.loading = true;
        this.error = null;

        getRandomRecipe()
            .then(result => {
                console.log('Random recipe:', result);
                if (result) {
                    this.recipes = [result];
                } else {
                    this.error = 'Could not fetch random recipe';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                this.error = 'Error fetching recipe: ' + error.body?.message || error.message;
            })
            .finally(() => {
                this.loading = false;
            });
    }

    handleViewDetails(event) {
        const recipeId = event.target.dataset.id;
        console.log('View details for recipe:', recipeId);
        alert('Recipe ID: ' + recipeId + '\n\nFull details view coming soon!');
    }
}
