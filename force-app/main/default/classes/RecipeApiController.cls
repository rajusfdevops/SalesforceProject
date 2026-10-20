public with sharing class RecipeApiController {
    private static final String SPOONACULAR_BASE_URL = 'https://api.spoonacular.com/recipes';
    private static final String NAMED_CREDENTIAL = 'Spoonacular_API';
    private static final Integer PAGE_SIZE = 10;

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getRandomRecipe() {
        try {
            String endpoint = SPOONACULAR_BASE_URL + '/random?number=1&addRecipeInformation=true&apiKey=a365ecb02c394193be7e9cb9af9f82d9';
            HttpResponse response = makeApiCall('GET', endpoint, null);

            System.debug('Response Status: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());

            if (response.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> recipes = (List<Object>) result.get('recipes');
                if (recipes != null && !recipes.isEmpty()) {
                    return (Map<String, Object>) recipes[0];
                }
            } else {
                throw new AuraHandledException('API Error: ' + response.getStatus() + ' - ' + response.getBody());
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching random recipe: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRecipeById(String recipeId) {
        try {
            String endpoint = SPOONACULAR_BASE_URL + '/' + recipeId + '/information?addWinePairing=false&apiKey=a365ecb02c394193be7e9cb9af9f82d9';
            HttpResponse response = makeApiCall('GET', endpoint, null);

            if (response.getStatusCode() == 200) {
                return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching recipe: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> searchRecipes(String query, String cuisine, String mealType, String diet, Integer offset) {
        try {
            Integer limitParam = PAGE_SIZE;
            Integer offsetParam = offset != null ? offset : 0;

            String endpoint = SPOONACULAR_BASE_URL + '/complexSearch?query=' + EncodingUtil.urlEncode(query, 'UTF-8');

            if (String.isNotBlank(cuisine)) {
                endpoint += '&cuisine=' + EncodingUtil.urlEncode(cuisine, 'UTF-8');
            }
            if (String.isNotBlank(mealType)) {
                endpoint += '&type=' + EncodingUtil.urlEncode(mealType, 'UTF-8');
            }
            if (String.isNotBlank(diet)) {
                endpoint += '&diet=' + EncodingUtil.urlEncode(diet, 'UTF-8');
            }

            endpoint += '&number=' + limitParam + '&offset=' + offsetParam + '&addRecipeInformation=true&apiKey=a365ecb02c394193be7e9cb9af9f82d9';

            HttpResponse response = makeApiCall('GET', endpoint, null);

            if (response.getStatusCode() == 200) {
                return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            }
            return new Map<String, Object>();
        } catch (Exception e) {
            throw new AuraHandledException('Error searching recipes: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRecipeNutrition(String recipeId) {
        try {
            String endpoint = SPOONACULAR_BASE_URL + '/' + recipeId + '/nutritionWidget.json?apiKey=a365ecb02c394193be7e9cb9af9f82d9';
            HttpResponse response = makeApiCall('GET', endpoint, null);

            if (response.getStatusCode() == 200) {
                return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching nutrition info: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveFavoriteRecipe(String recipeId, String recipeName, String imageUrl) {
        try {
            List<Favorite_Recipe__c> existing = [
                SELECT Id FROM Favorite_Recipe__c
                WHERE Recipe_ID__c = :recipeId AND OwnerId = :UserInfo.getUserId()
                LIMIT 1
            ];

            if (existing.isEmpty()) {
                Favorite_Recipe__c favorite = new Favorite_Recipe__c(
                    Recipe_ID__c = recipeId,
                    Recipe_Name__c = recipeName,
                    Image_URL__c = imageUrl,
                    OwnerId = UserInfo.getUserId()
                );
                insert favorite;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error saving favorite: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeFavoriteRecipe(String recipeId) {
        try {
            List<Favorite_Recipe__c> favorites = [
                SELECT Id FROM Favorite_Recipe__c
                WHERE Recipe_ID__c = :recipeId AND OwnerId = :UserInfo.getUserId()
            ];

            if (!favorites.isEmpty()) {
                delete favorites;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error removing favorite: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Favorite_Recipe__c> getFavoriteRecipes() {
        try {
            return [
                SELECT Id, Recipe_ID__c, Recipe_Name__c, Image_URL__c, CreatedDate
                FROM Favorite_Recipe__c
                WHERE OwnerId = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching favorites: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isFavorite(String recipeId) {
        try {
            List<Favorite_Recipe__c> favorites = [
                SELECT Id FROM Favorite_Recipe__c
                WHERE Recipe_ID__c = :recipeId AND OwnerId = :UserInfo.getUserId()
                LIMIT 1
            ];
            return !favorites.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    private static HttpResponse makeApiCall(String method, String endpoint, String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod(method);
        String calloutEndpoint = 'callout:' + NAMED_CREDENTIAL + endpoint.substringAfter('https://api.spoonacular.com');
        request.setEndpoint(calloutEndpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);

        if (body != null) {
            request.setBody(body);
        }

        HttpResponse response = http.send(request);
        System.debug('Callout Endpoint: ' + calloutEndpoint);
        System.debug('Response Status: ' + response.getStatusCode());
        System.debug('Response Body: ' + response.getBody());
        return response;
    }
}