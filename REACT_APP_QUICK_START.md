# React Recipe App - Quick Start Guide

## 🚀 Getting Started

Your new React Recipe Explorer app is ready! Here's how to run it.

### Step 1: Navigate to the App Directory
```bash
cd recipes-react-app
```

### Step 2: Install Dependencies (if not already done)
```bash
npm install
```

### Step 3: Start the Development Server
```bash
npm start
```

The app will automatically open in your browser at `http://localhost:3000`

## 📋 What You Have

A fully functional React recipe discovery app with:

✅ **Random Recipe Discovery** - Get random recipes with one click
✅ **Search by Recipe ID** - Find specific recipes
✅ **Advanced Search** - Filter by cuisine, meal type, and diet
✅ **Recipe Details Modal** - View comprehensive recipe information
✅ **Favorites Management** - Save recipes locally
✅ **Pagination** - Browse through search results
✅ **Responsive Design** - Works on desktop, tablet, and mobile

## 📁 Project Structure

```
recipes-react-app/
├── src/
│   ├── RecipeViewer.jsx       ← Main recipe component
│   ├── RecipeViewer.css       ← Component styles
│   ├── App.js                 ← App wrapper
│   └── ...
├── public/
│   └── index.html
├── package.json
└── RECIPE_APP_README.md       ← Full documentation
```

## 🎨 Features at a Glance

### Tab 1: Random Recipe
- Click button to get a random recipe
- View key details (cooking time, servings, cuisine)
- Add to favorites

### Tab 2: Search by ID
- Enter a Spoonacular Recipe ID
- View full recipe with ingredients and instructions

### Tab 3: Search Recipes
- Search by name
- Filter by cuisine, meal type, diet
- Browse paginated results
- Click "View Details" for full recipe

### Tab 4: My Favorites
- View all saved recipes
- Remove recipes from favorites
- Data persists in browser

## 🔧 Configuration

### API Key
The app uses Spoonacular API (API key is included for demo purposes).

For production, consider:
1. Creating a `.env` file in `recipes-react-app/`
2. Adding: `REACT_APP_SPOONACULAR_API_KEY=your_key_here`
3. Updating the component to use environment variable

## 📱 Browser Compatibility

Works on:
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## 🆘 Troubleshooting

### Port 3000 Already in Use
```bash
npm start -- --port 3001
```

### Dependencies Not Installed
```bash
rm -rf node_modules package-lock.json
npm install
```

### Clear Cache and Restart
```bash
npm start --reset-cache
```

## 📚 Full Documentation

See `RECIPE_APP_README.md` for:
- Detailed feature documentation
- API information
- Component architecture
- Styling and responsive design
- Known limitations and future enhancements

## 🎯 Next Steps

1. **Run the app:** `npm start`
2. **Try all features:** Navigate through each tab
3. **Test search:** Try different cuisines and meal types
4. **Save favorites:** Add recipes to favorites
5. **Explore code:** Check `RecipeViewer.jsx` for component logic

## 📞 Support

If you encounter issues:
1. Check browser console (F12 → Console tab)
2. Verify internet connection
3. Check Spoonacular API status
4. Refer to full README for troubleshooting section

## 🎉 Enjoy!

Your React Recipe Explorer is ready to use!
