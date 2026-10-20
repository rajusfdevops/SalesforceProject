@RestResource(urlMapping='/recipe-react-app')
global with sharing class RecipeReactAppController {

    @HttpGet
    global static void getRecipeApp() {
        RestContext.response.addHeader('Content-Type', 'text/html; charset=UTF-8');
        RestContext.response.responseBody = Blob.valueOf(getReactAppHtml());
    }

    private static String getReactAppHtml() {
        return '<!DOCTYPE html>' +
            '<html lang="en">' +
            '<head>' +
            '  <meta charset="UTF-8" />' +
            '  <meta name="viewport" content="width=device-width, initial-scale=1.0" />' +
            '  <title>Recipe React App</title>' +
            '  <style>' +
            '    * { margin: 0; padding: 0; box-sizing: border-box; }' +
            '    html, body, #root { width: 100%; height: 100%; overflow: hidden; }' +
            '    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell"; background: #fff; }' +
            '    .loading { display: flex; align-items: center; justify-content: center; height: 100vh; font-size: 18px; color: #666; }' +
            '    .spinner { border: 4px solid #f3f3f3; border-top: 4px solid #667eea; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin-right: 15px; }' +
            '    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }' +
            '  </style>' +
            '</head>' +
            '<body>' +
            '  <div id="root">' +
            '    <div class="loading">' +
            '      <div class="spinner"></div>' +
            '      Loading Recipe Explorer...' +
            '    </div>' +
            '  </div>' +
            '  <script>' +
            '    console.log("Recipe App initializing...");' +
            '    ' +
            '    window.addEventListener("load", function() {' +
            '      console.log("Page loaded");' +
            '      const resourceUrl = "/resource/1791167985000/RecipeExplorer";' +
            '      console.log("Loading from:", resourceUrl);' +
            '      ' +
            '      const link = document.createElement("link");' +
            '      link.rel = "stylesheet";' +
            '      link.href = resourceUrl + "/static/css/main.6fcaddc8.css";' +
            '      link.onerror = function() { console.error("CSS failed"); };' +
            '      document.head.appendChild(link);' +
            '      ' +
            '      const script = document.createElement("script");' +
            '      script.src = resourceUrl + "/static/js/main.5b3dd956.js";' +
            '      script.type = "text/javascript";' +
            '      script.onerror = function() { console.error("JS failed"); };' +
            '      document.body.appendChild(script);' +
            '    });' +
            '  </script>' +
            '</body>' +
            '</html>';
    }
}
