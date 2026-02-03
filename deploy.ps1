flutter clean
flutter pub get
flutter build web --release

copy web\sitemap.xml build\web\sitemap.xml
copy web\_redirects build\web\_redirects
copy web\robots.txt build\web\robots.txt

Write-Host "✅ Build Ready for Netlify Deploy"
