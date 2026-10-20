import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import recipeResource from '@salesforce/resourceUrl/RecipeExplorer';

export default class RecipeExplorerApp extends LightningElement {
    selectedApp = 'recipeReact';

    appOptions = [
        { label: 'Recipe React App', value: 'recipeReact' },
        { label: 'Recipe Viewer', value: 'recipeViewer' }
    ];

    get isReactApp() {
        return this.selectedApp === 'recipeReact';
    }

    get iframeUrl() {
        if (this.selectedApp === 'recipeReact') {
            return recipeResource + '/index.html';
        }
        return '';
    }

    handleAppChange(event) {
        this.selectedApp = event.detail.value;
    }
}
