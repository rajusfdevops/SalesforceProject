# React Recipe Explorer - Salesforce Deployment Guide

## 📋 What Was Created

Your React Recipe Explorer app has been prepared for Salesforce deployment with the following components:

### 1. **Static Resource**
- **File:** `RecipeExplorer.zip`
- **Location:** `force-app/main/default/staticresources/`
- **Contents:** Production build of React app (~365 KB)
- **Type:** Application archive (ZIP)

### 2. **Visualforce Page**
- **File:** `RecipeExplorer.page`
- **Location:** `force-app/main/default/pages/`
- **Purpose:** Hosts the React app
- **Access URL:** `/apex/RecipeExplorer` in your org

### 3. **Metadata Files**
- `RecipeExplorer.resource-meta.xml` - Static resource configuration
- `RecipeExplorer.page-meta.xml` - Visualforce page configuration

---

## 🚀 Deployment Steps

### Option 1: Deploy with SFDX (Recommended)

#### Step 1: Verify Org Connection
```bash
sfdx force:org:list
```
This shows your authenticated orgs. Note the username/alias of your target org.

#### Step 2: Deploy Using SFDX
```bash
cd "C:\Important documents\Code Setup\Headless360_sf\15th_Sep_Batch\AIForce_Proj\SalesforceProject"

# Deploy all new components (static resource + Visualforce page)
sfdx force:source:deploy -p force-app/main/default/staticresources/RecipeExplorer.zip -u your-org-username
sfdx force:source:deploy -p force-app/main/default/pages/RecipeExplorer.page -u your-org-username
sfdx force:source:deploy -p force-app/main/default/pages/RecipeExplorer.page-meta.xml -u your-org-username

# Or deploy everything at once
sfdx force:source:deploy -p force-app -u your-org-username
```

#### Step 3: Verify Deployment
```bash
# Check deployment status
sfdx force:source:status -u your-org-username
```

### Option 2: Manual Deployment (Via UI)

1. **Upload Static Resource:**
   - Go to Setup → Static Resources
   - Click "New"
   - Name: `RecipeExplorer`
   - Upload file: `RecipeExplorer.zip`
   - Public Cacheable: ✅ (check)
   - Save

2. **Create Visualforce Page:**
   - Go to Setup → Visualforce Pages
   - Click "New"
   - Copy content from `RecipeExplorer.page`
   - Name: `RecipeExplorer`
   - Label: `Recipe Explorer`
   - Save

3. **Assign Permission:**
   - Go to Setup → Profiles
   - Edit relevant profiles
   - Visualforce Page Access → Add `RecipeExplorer`
   - Save

---

## 🌐 Accessing the App

### After Deployment:

1. **In Your Org:**
   - Navigate to: `https://your-org.salesforce.com/apex/RecipeExplorer`
   - Or add to App Launcher

2. **Add to Lightning App:**
   - Go to Setup → App Manager
   - Create New Lightning App → Add Visualforce page
   - Add `RecipeExplorer` page to app
   - Save and assign to users

3. **Add to Home Page:**
   - Setup → Home → Home Layout
   - Add Visualforce page component
   - Select `RecipeExplorer`
   - Save

4. **Create Custom Tab:**
   - Setup → Create → Tabs
   - Click "New"
   - Object: Visualforce Page
   - Select: `RecipeExplorer`
   - Save and add to desired app

---

## ⚙️ Configuration

### API Key Management (Security Best Practice)

The app currently has the Spoonacular API key embedded. For production, consider:

#### 1. **Using Custom Settings:**

Create a Custom Setting:
```
Setup → Custom Settings → New

Name: RecipeExplorerConfig
Field:
- API_Key__c (Text, 255)
- API_Base_URL__c (Text, 255)
```

#### 2. **Update Visualforce Page:**
```apex
<c:RecipeExplorerComponent apiKey="{!RecipeExplorerConfig__c.getInstance('default').API_Key__c}" />
```

#### 3. **Update React Component:**
Fetch from Salesforce Apex instead of hardcoding API key.

### Create Apex Controller (Optional - For Better Security):

```apex
public with sharing class RecipeApiProxy {
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> callSpoonacularAPI(String endpoint) {
        try {
            String apiKey = RecipeExplorerConfig__c.getInstance('default').API_Key__c;
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.spoonacular.com' + endpoint + '&apiKey=' + apiKey);
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } catch (Exception e) {
            throw new AuraHandledException('API Error: ' + e.getMessage());
        }
    }
}
```

---

## 📊 File Structure Deployed

```
force-app/main/default/
├── staticresources/
│   ├── RecipeExplorer.zip          ← React build files
│   └── RecipeExplorer.resource-meta.xml
├── pages/
│   ├── RecipeExplorer.page          ← Visualforce host page
│   └── RecipeExplorer.page-meta.xml
└── classes/
    └── RecipeApiController.cls      ← Existing Apex controller
```

---

## 🔍 Troubleshooting Deployment

### Issue: "Static Resource Not Found"
**Solution:**
- Verify RecipeExplorer.zip exists in staticresources folder
- Check file size: should be ~365 KB
- Re-deploy static resource

### Issue: "Visualforce Page Shows Blank"
**Solution:**
- Check browser console (F12) for errors
- Verify static resource is deployed and active
- Try hard refresh (Ctrl+Shift+R)
- Check resource permissions in profiles

### Issue: "CORS Error" or "Network Error"
**Solution:**
- Spoonacular API should be accessible from browser
- Check org's CORS whitelist settings
- Consider using Apex proxy instead

### Issue: "Permission Denied"
**Solution:**
- User profile needs "Visualforce Page Access"
- Add RecipeExplorer page to user's profile
- Or assign relevant permission set

---

## 🧪 Testing After Deployment

1. **Load the Page:**
   - Navigate to `/apex/RecipeExplorer`
   - Should load within 5-10 seconds

2. **Test Features:**
   - [ ] Random Recipe loads
   - [ ] Search by ID works
   - [ ] Advanced search functions
   - [ ] View Details modal displays
   - [ ] Ingredients & Instructions visible
   - [ ] Favorites save (if using localStorage alternative)

3. **Mobile Test:**
   - [ ] App is responsive on mobile
   - [ ] Buttons and inputs aligned
   - [ ] Touch interactions work

4. **Browser Console:**
   - [ ] No errors (F12 → Console)
   - [ ] No failed resource loads

---

## 📱 Alternative: Lightning Web Component Wrapper

For better Salesforce integration, you can wrap this in an LWC:

**`recipeExplorer.js`:**
```javascript
import { LightningElement } from 'lwc';

export default class RecipeExplorer extends LightningElement {
    get iframeUrl() {
        return '/apex/RecipeExplorer';
    }
}
```

**`recipeExplorer.html`:**
```html
<template>
    <div style="width:100%; height:100vh;">
        <iframe src={iframeUrl} style="width:100%; height:100%; border:none;"></iframe>
    </div>
</template>
```

---

## 🔐 Security Considerations

1. **API Key:**
   - Never commit API keys to repository
   - Use Custom Settings or Secrets Manager
   - Rotate keys periodically

2. **Data Access:**
   - Recipes are public data (no auth needed)
   - Favorites stored in browser (localStorage)
   - Consider using Salesforce objects for favorites persistence

3. **Permissions:**
   - Assign Visualforce page access per profile
   - Create permission sets for specific users
   - Monitor access via Salesforce logs

4. **CSP (Content Security Policy):**
   - Allow Spoonacular API domain if needed
   - Setup → CSP Trusted Sites
   - Add: `https://api.spoonacular.com`

---

## 📈 Performance Notes

**Build Statistics:**
- Main JS: 72.87 KB (gzipped)
- Main CSS: 2.6 KB (gzipped)
- Total: ~365 KB (zip file)
- Load time: 2-5 seconds

**Optimization Tips:**
- Gzip is enabled (supports browser decompression)
- Static files cached by Salesforce CDN
- React chunks loaded on demand

---

## 🔄 Updating the App

When you make changes to the React app:

1. **Rebuild:**
   ```bash
   cd recipes-react-app
   npm run build
   ```

2. **Re-zip build folder:**
   ```bash
   Compress-Archive -Path "build\*" -DestinationPath "..\force-app\main\default\staticresources\RecipeExplorer.zip" -Force
   ```

3. **Re-deploy:**
   ```bash
   sfdx force:source:deploy -p force-app/main/default/staticresources -u org-username
   ```

4. **Clear cache:**
   - Static resources cache for 1 hour
   - Users may need to hard refresh (Ctrl+Shift+R)

---

## 📞 Support & Troubleshooting

**Common Issues:**

| Issue | Solution |
|-------|----------|
| Blank page | Check static resource, clear cache, hard refresh |
| No recipes load | Check API key, verify Spoonacular access, check console errors |
| Alignment issues | Update CSS in source, rebuild, re-deploy |
| Favorites not saving | Check localStorage availability in org context |

**For More Help:**
- Check Spoonacular API docs: https://spoonacular.com/food-api
- Salesforce Static Resources: https://help.salesforce.com/s/articleView?id=sf.pages_resources_static.htm
- React deployment: https://create-react-app.dev/deployment/

---

## ✅ Deployment Checklist

- [ ] Static Resource (RecipeExplorer.zip) uploaded
- [ ] Visualforce Page (RecipeExplorer) created
- [ ] Permissions assigned to users
- [ ] Page loads at `/apex/RecipeExplorer`
- [ ] All features tested
- [ ] API key is secure
- [ ] Mobile responsiveness verified
- [ ] No console errors
- [ ] Added to App/Home as needed

---

## 🎉 Next Steps

1. **Choose deployment method** (SFDX or Manual)
2. **Execute deployment**
3. **Test thoroughly**
4. **Assign to users**
5. **Monitor performance**
6. **Gather feedback**

Your React Recipe Explorer is ready to serve your Salesforce Org! 🍳
