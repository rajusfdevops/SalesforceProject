# Recipe Viewer LWC - Complete Setup Guide

## 📋 Overview
A comprehensive Lightning Web Component that integrates with Spoonacular API to browse, search, and save favorite recipes.

---

## 🔧 Prerequisites

- Salesforce Org (Developer, Sandbox, or Production)
- Spoonacular API Key: `a365ecb02c394193be7e9cb9af9f82d9`
- Salesforce CLI installed
- Appropriate permissions to create custom objects, classes, and LWC components

---

## ✅ Step 1: Create Named Credential (IMPORTANT)

**Named Credentials** securely store the API key in Salesforce.

### Steps:

1. Go to **Setup** → Search for **Named Credentials**
2. Click **New Named Credential**
3. Fill in the following details:

   | Field | Value |
   |-------|-------|
   | **Label** | `Spoonacular_API` |
   | **Name** | `Spoonacular_API` (auto-filled) |
   | **URL** | `https://api.spoonacular.com/recipes` |
   | **Identity Type** | Named Principal |
   | **Authentication Protocol** | API Key |
   | **API Key** | `` |

4. In "Generate Authorization Header" section:
   - Authorization Header Format: `apiKey: {0}`
   - API Key: ``

5. Check: ✅ **"Allow HTTP"** (for local testing if needed)
6. Click **Save**

---

## 📦 Step 2: Deploy Components

### Option A: Using Salesforce CLI (Recommended)

```bash
cd "C:\Important documents\Code Setup\Headless360_sf\15th_Sep_Batch\AIForce_Proj\SalesforceProject"

# Deploy Apex Controller
sf project deploy start --source-dir force-app/main/default/classes/RecipeApiController.cls -o AIForce_dev

# Deploy Custom Object
sf project deploy start --source-dir force-app/main/default/objects/Favorite_Recipe__c -o AIForce_dev

# Deploy LWC Component
sf project deploy start --source-dir force-app/main/default/lwc/recipeViewer -o AIForce_dev
```

### Option B: Manual Deployment via VS Code

1. Open your Salesforce project in VS Code
2. Right-click on the file/folder
3. Select **SFDX: Deploy Source to Org**
4. Select `AIForce_dev` org
5. Wait for deployment to complete

---

## 🔐 Step 3: Verify Deployment

In Salesforce Setup:

1. **Apex Classes**: Search "Apex Classes" → Verify `RecipeApiController` exists
2. **Custom Objects**: Search "Custom Objects" → Verify `Favorite Recipe` exists
3. **Lightning Components**: Search "Lightning Components" → Verify `recipeViewer` exists
4. **Named Credentials**: Verify `Spoonacular_API` is created and active

---

## 📱 Step 4: Add Component to a Lightning Page

### Method 1: Create a New Lightning Page

1. Go to **Setup** → **Lightning App Builder**
2. Click **New** → Select **App Page**
3. Name it: `"Recipe Explorer"`
4. Select layout: **Single Column** (or your preference)
5. Click **Create**
6. In the left panel, search for **"Recipe Viewer"**
7. **Drag** it onto the canvas
8. Click **Save**
9. Click **Activate** to make it available

### Method 2: Add to App Home

1. Go to **Setup** → **Lightning App Builder**
2. Click **Home Page** (or select a specific app's home)
3. Click **Edit**
4. Search for **"Recipe Viewer"**
5. Drag it onto the page
6. Click **Save** and **Activate**

### Method 3: Add to Custom Tab

1. Go to **Setup** → **Tabs**
2. Click **New** under "Lightning Page Tabs"
3. Select **Recipe Viewer** as the component
4. Name it: `"Recipes"`
5. Click **Save**
6. Add to your app navigation

---

## 🚀 Component Features

### Tab 1: Random Recipe ⚡
- **Button**: Show Random Recipe
- **Displays**:
  - Recipe image
  - Recipe name
  - Ready time (minutes)
  - Servings
  - Cuisine type
  - Recipe summary
  - View Details button
  - Add/Remove from Favorites

### Tab 2: Search by Recipe ID 🔍
- **Input**: Recipe ID (numeric)
- **Displays**:
  - Full recipe details
  - Image
  - Ingredients with quantities
  - Step-by-step instructions
  - Nutrition information
  - Add/Remove from Favorites

### Tab 3: Search Recipes 🔎
- **Filters**:
  - Recipe name (text search)
  - Cuisine (dropdown)
  - Meal type (breakfast, lunch, dinner, etc.)
  - Diet type (vegetarian, vegan, etc.)
- **Results**:
  - Recipe cards with images
  - Recipe names
  - Recipe IDs
  - View Details button
  - **Pagination** (10 results per page)

### Tab 4: My Favorites ⭐
- **Displays**: All saved favorite recipes
- **Features**:
  - Recipe images
  - Recipe names
  - Recipe IDs
  - Remove button
  - Completely customizable per user

### Recipe Details Modal
- **Shows**:
  - Full recipe name
  - Recipe image
  - Servings
  - Cooking time
  - Complete ingredients list
  - Step-by-step instructions
  - Nutrition information (when available)

---

## 📊 Objects & Classes

### Apex Classes:
- **RecipeApiController.cls** - Handles all Spoonacular API calls with:
  - Random recipe fetching
  - ID-based recipe search
  - Complex recipe search with filters
  - Nutrition data retrieval
  - Favorite recipe management (CRUD)

### Custom Object:
- **Favorite_Recipe__c** - Stores user favorite recipes with fields:
  - `Recipe_ID__c` (Text) - Spoonacular recipe ID
  - `Recipe_Name__c` (Text) - Recipe name
  - `Image_URL__c` (URL) - Recipe image URL
  - Auto-number Name field (FAV-0001, FAV-0002, etc.)

### LWC Component:
- **recipeViewer** - Main component with:
  - 4 tabs for different features
  - API integration via Apex
  - Favorite management
  - Modal for recipe details
  - Pagination support
  - Rate limiting handling
  - Mobile responsive design

---

## 🎨 Design Features

✅ **Professional UI**:
- Modern gradient header
- Color-coded cards and sections
- Interactive buttons and modals
- Smooth hover effects

✅ **Mobile Responsive**:
- Works on all screen sizes
- Optimized layouts for mobile devices
- Touch-friendly buttons

✅ **User Experience**:
- Loading indicators
- Success/error toast messages
- Intuitive navigation
- Clear data hierarchy

---

## 🧪 Testing Guide

### Test Case 1: Random Recipe
1. Open Recipe Explorer component
2. Click "Show Random Recipe"
3. **Expected**: Recipe details load with image, name, time, servings, cuisine, summary
4. Click "Add to Favorites"
5. Go to "My Favorites" tab - recipe should appear

### Test Case 2: Search by ID
1. Go to "Search by ID" tab
2. Enter Recipe ID: `716627`
3. Click "Search"
4. **Expected**: Full recipe details load including ingredients, instructions, nutrition

### Test Case 3: Search with Filters
1. Go to "Search Recipes" tab
2. Enter name: `pasta`
3. Select cuisine: `Italian`
4. Click "Search Recipes"
5. **Expected**: Recipe cards load with pagination
6. Click "Next" to see more results
7. Click "View Details" on any recipe

### Test Case 4: Pagination
1. Perform a search (e.g., "chicken")
2. Verify "Previous" button is disabled on page 1
3. Click "Next"
4. Verify "Previous" is now enabled
5. Verify page counter shows correct page

### Test Case 5: Save Favorites
1. Open any recipe
2. Click "Add to Favorites"
3. **Expected**: Toast message "Recipe added to favorites"
4. Go to "My Favorites" tab
5. **Expected**: Recipe appears in favorites list
6. Click "Remove" on favorite
7. **Expected**: Toast message "Recipe removed from favorites"
8. Recipe disappears from list

---

## 🔒 Security Notes

✅ **API Key Security**:
- API key stored in Named Credential (not in code)
- Salesforce encrypts Named Credentials
- Only accessible to authorized users

✅ **CRUD Permissions**:
- Favorite recipes are private by default
- Each user sees only their own favorites
- Salesforce enforces org-level sharing rules

---

## 📈 Rate Limiting

The Spoonacular API has rate limits:
- **Free Plan**: 150 requests/day
- **Premium Plan**: Higher limits

**Handled by**:
- Caching on read operations (using `@AuraEnabled(cacheable=true)`)
- Pagination to reduce data load
- Error handling for rate limit exceeded

---

## 🐛 Troubleshooting

### Issue: "Named Credential not found"
**Solution**: Verify Named Credential name is exactly `Spoonacular_API` in Apex code

### Issue: API calls returning 401 Unauthorized
**Solution**: 
1. Verify API key in Named Credential
2. Check "Allow HTTP" is enabled
3. Verify `callout:Spoonacular_API` syntax in Apex

### Issue: Component not showing in Lightning App Builder
**Solution**:
1. Verify component is deployed successfully
2. Clear browser cache
3. Refresh page
4. Verify `isExposed: true` in metadata

### Issue: Favorites not saving
**Solution**:
1. Verify `Favorite_Recipe__c` custom object is created
2. Check user has create permissions on object
3. Verify `OwnerId` field is set correctly

---

## 📞 Support

For issues:
1. Check deployment logs: `sf project deploy report --deploy-id <ID>`
2. Check browser console for errors: F12 → Console
3. Verify Salesforce org logs: Setup → Debug Logs

---

## 📝 Notes

- Component uses API version 57.0
- Tested with Spoonacular API v2
- Rate limit: 150 requests/day (free plan)
- Cache enabled for search and random recipe (improves performance)
- All user data is securely stored in Salesforce

---

**Status**: ✅ Ready for Deployment

**Last Updated**: 2026-09-29

**Created By**: Claude Haiku 4.5