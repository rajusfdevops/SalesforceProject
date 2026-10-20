import { LightningElement, track } from 'lwc';
import getRandomRecipe from '@salesforce/apex/RecipeApiController.getRandomRecipe';
import getRecipeById from '@salesforce/apex/RecipeApiController.getRecipeById';
import searchRecipes from '@salesforce/apex/RecipeApiController.searchRecipes';
import getRecipeNutrition from '@salesforce/apex/RecipeApiController.getRecipeNutrition';
import saveFavoriteRecipe from '@salesforce/apex/RecipeApiController.saveFavoriteRecipe';
import removeFavoriteRecipe from '@salesforce/apex/RecipeApiController.removeFavoriteRecipe';
import getFavoriteRecipes from '@salesforce/apex/RecipeApiController.getFavoriteRecipes';
import isFavorite from '@salesforce/apex/RecipeApiController.isFavorite';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecipeViewer extends LightningElement {
  @track activeTab = 'random';
  @track randomRecipe = null;
  @track searchRecipeId = '';
  @track recipeIdResult = null;
  @track searchQuery = '';
  @track selectedCuisine = '';
  @track selectedMealType = '';
  @track selectedDiet = '';
  @track searchResults = [];
  @track selectedRecipe = null;
  @track favorites = [];
  @track isLoading = false;
  @track totalResults = 0;
  @track currentOffset = 0;
  @track isFavorited = false;

  cuisineOptions = [
    { label: 'All', value: '' },
    { label: 'Italian', value: 'Italian' },
    { label: 'Indian', value: 'Indian' },
    { label: 'Chinese', value: 'Chinese' },
    { label: 'Mexican', value: 'Mexican' },
    { label: 'Japanese', value: 'Japanese' },
    { label: 'Mediterranean', value: 'Mediterranean' },
    { label: 'Thai', value: 'Thai' }
  ];

  mealTypeOptions = [
    { label: 'All', value: '' },
    { label: 'Breakfast', value: 'breakfast' },
    { label: 'Lunch', value: 'lunch' },
    { label: 'Dinner', value: 'dinner' },
    { label: 'Dessert', value: 'dessert' },
    { label: 'Snack', value: 'snack' }
  ];

  dietOptions = [
    { label: 'All', value: '' },
    { label: 'Vegetarian', value: 'vegetarian' },
    { label: 'Vegan', value: 'vegan' },
    { label: 'Gluten Free', value: 'gluten free' },
    { label: 'Ketogenic', value: 'ketogenic' },
    { label: 'Paleo', value: 'paleo' }
  ];

  connectedCallback() {
    this.loadFavorites();
  }

  handleTabChange(event) {
    this.activeTab = event.detail.value;
    this.selectedRecipe = null;
    this.recipeIdResult = null;
  }

  // Random Recipe Tab
  handleRandomRecipe() {
    this.isLoading = true;
    getRandomRecipe()
      .then((result) => {
        if (result) {
          this.randomRecipe = { ...result };
          if (this.randomRecipe.summary) {
            this.randomRecipe.summary = this.stripHtmlTags(this.randomRecipe.summary);
          }
          this.checkIfFavorite(result.id);
        }
        this.isLoading = false;
      })
      .catch((error) => {
        const errorMsg = error?.body?.message || error?.message || 'An error occurred';
        this.showToast('Error', errorMsg, 'error');
        this.isLoading = false;
      });
  }

  // Search by ID Tab
  handleSearchIdChange(event) {
    this.searchRecipeId = event.detail.value;
  }

  handleSearchById() {
    if (!this.searchRecipeId) {
      this.showToast('Warning', 'Please enter a Recipe ID', 'warning');
      return;
    }

    this.isLoading = true;
    getRecipeById({ recipeId: this.searchRecipeId })
      .then((result) => {
        if (result) {
          this.recipeIdResult = { ...result };
          if (this.recipeIdResult.summary) {
            this.recipeIdResult.summary = this.stripHtmlTags(this.recipeIdResult.summary);
          }
          this.checkIfFavorite(result.id);
        }
        this.isLoading = false;
      })
      .catch((error) => {
        this.showToast('Error', 'Recipe not found', 'error');
        this.isLoading = false;
      });
  }

  // Search Recipes Tab
  handleSearchChange(event) {
    this.searchQuery = event.detail.value;
  }

  handleCuisineChange(event) {
    this.selectedCuisine = event.detail.value;
  }

  handleMealTypeChange(event) {
    this.selectedMealType = event.detail.value;
  }

  handleDietChange(event) {
    this.selectedDiet = event.detail.value;
  }

  handleSearchRecipes() {
    if (!this.searchQuery) {
      this.showToast('Warning', 'Please enter a recipe name', 'warning');
      return;
    }

    this.isLoading = true;
    this.currentOffset = 0;
    this.performSearch();
  }

  performSearch() {
    searchRecipes({
      query: this.searchQuery,
      cuisine: this.selectedCuisine,
      mealType: this.selectedMealType,
      diet: this.selectedDiet,
      offset: this.currentOffset
    })
      .then((result) => {
        this.searchResults = result.results || [];
        this.totalResults = result.totalResults || 0;
        this.isLoading = false;
      })
      .catch((error) => {
        const errorMsg = error?.body?.message || error?.message || 'An error occurred';
        this.showToast('Error', errorMsg, 'error');
        this.isLoading = false;
      });
  }

  handleNextPage() {
    this.currentOffset += 10;
    this.isLoading = true;
    this.performSearch();
  }

  handlePreviousPage() {
    this.currentOffset = Math.max(0, this.currentOffset - 10);
    this.isLoading = true;
    this.performSearch();
  }

  // View Details
  handleViewDetails(event) {
    const recipeId = event.currentTarget.dataset.id;
    let recipe;

    if (this.activeTab === 'random' && this.randomRecipe) {
      recipe = this.randomRecipe;
    } else if (this.activeTab === 'searchId' && this.recipeIdResult) {
      recipe = this.recipeIdResult;
    } else {
      recipe = this.searchResults.find(r => r.id === parseInt(recipeId));
    }

    if (recipe) {
      this.selectedRecipe = recipe;
      this.loadRecipeNutrition(recipe.id);
    }
  }

  loadRecipeNutrition(recipeId) {
    getRecipeNutrition({ recipeId: String(recipeId) })
      .then((result) => {
        if (this.selectedRecipe) {
          this.selectedRecipe.nutrition = result;
        }
      })
      .catch(() => {
        // Nutrition data is optional
      });
  }

  handleCloseDetails() {
    this.selectedRecipe = null;
  }

  // Favorites
  loadFavorites() {
    getFavoriteRecipes()
      .then((result) => {
        this.favorites = result;
      })
      .catch(() => {
        this.favorites = [];
      });
  }

  checkIfFavorite(recipeId) {
    isFavorite({ recipeId: String(recipeId) })
      .then((result) => {
        this.isFavorited = result;
      })
      .catch(() => {
        this.isFavorited = false;
      });
  }

  handleAddFavorite() {
    const recipe = this.selectedRecipe || this.randomRecipe || this.recipeIdResult;
    if (!recipe) return;

    saveFavoriteRecipe({
      recipeId: String(recipe.id),
      recipeName: recipe.title,
      imageUrl: recipe.image
    })
      .then(() => {
        this.isFavorited = true;
        this.loadFavorites();
        this.showToast('Success', 'Recipe added to favorites', 'success');
      })
      .catch((error) => {
        const errorMsg = error?.body?.message || error?.message || 'An error occurred';
        this.showToast('Error', errorMsg, 'error');
      });
  }

  handleRemoveFavorite() {
    const recipe = this.selectedRecipe || this.randomRecipe || this.recipeIdResult;
    if (!recipe) return;

    removeFavoriteRecipe({ recipeId: String(recipe.id) })
      .then(() => {
        this.isFavorited = false;
        this.loadFavorites();
        this.showToast('Success', 'Recipe removed from favorites', 'success');
      })
      .catch((error) => {
        const errorMsg = error?.body?.message || error?.message || 'An error occurred';
        this.showToast('Error', errorMsg, 'error');
      });
  }

  handleRemoveFavoriteFromList(event) {
    const favoriteId = event.currentTarget.dataset.id;
    removeFavoriteRecipe({ recipeId: favoriteId })
      .then(() => {
        this.loadFavorites();
        this.showToast('Success', 'Recipe removed from favorites', 'success');
      })
      .catch((error) => {
        const errorMsg = error?.body?.message || error?.message || 'An error occurred';
        this.showToast('Error', errorMsg, 'error');
      });
  }

  get currentPage() {
    return Math.floor(this.currentOffset / 10) + 1;
  }

  get totalPages() {
    return Math.ceil(this.totalResults / 10);
  }

  get isFirstPage() {
    return this.currentOffset === 0;
  }

  get isLastPage() {
    return this.currentOffset + 10 >= this.totalResults;
  }

  stripHtmlTags(html) {
    if (!html) return '';
    return html.replace(/<[^>]*>/g, '').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#039;/g, "'");
  }

  handleImageError(event) {
    event.target.src = 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300"><rect fill="%23f3f3f3" width="300" height="300"/><text x="50%" y="50%" font-size="80" text-anchor="middle" dominant-baseline="middle" fill="%23999">🍳</text></svg>';
    event.target.style.backgroundColor = '#f3f3f3';
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(event);
  }
}