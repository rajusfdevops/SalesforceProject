import { LightningElement } from 'lwc';

export default class RecipeReactApp extends LightningElement {
    get recipeAppUrl() {
        // Use Salesforce REST API endpoint to serve the React app
        // This avoids cross-origin and static resource loading issues
        const baseUrl = window.location.origin;
        return baseUrl + '/services/apexrest/recipe-react-app';
    }
}
