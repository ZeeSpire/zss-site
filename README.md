# zss One - One theme fits all 

<img src="assets/css/icons/check.png" alt="check" width="32"/><font size="5">Premium theme using Jekyll version 4.1.2 & Bootstrap 5</font>

<img src="assets/css/icons/check.png" alt="check" width="32"/><font size="5">Multipurpose (multiple homepage layouts)</font>

<img src="assets/css/icons/check.png" alt="check" width="32"/><font size="5">Fully ready for production within minutes</font> 

<img src="assets/css/icons/check.png" alt="check" width="32"/><font size="5">Responsive, SEO Friendly and Mobile optimized with GitHub Pages Support</font>

<img src="assets/css/icons/check.png" alt="check" width="32"/><font size="5">Step by step documentation</font>

<img src="assets/css/icons/support.png" alt="check" width="16"/><font size="5"> Detailed features</font>

    - 3 homepage designs which you can choose from 
    - Easily create and use your own with Bootstrap designs 
    - Includes multiple blog posts and frontpage as sample content 
    - Customizable through config files and properties:
        - show/hide authors
        - show/hide dates
        - show/hide social integrations
        - show/hide watermark
        - show/hide selected posts on the front page
        - change footer color 
    - Has Authors, Posts, Categories features 
    - Supports multiple image sizes for fast loading 
    - Lightbox and Image galleries support 
    - Code snippets highlight 
    - Git helper scripts (.bat) for easy GIT interaction 
    - Jekyll helper scripts (.bat) to easily build or start HTTP server locally 
    - 100% Responsive 
    - Many SEO features; Open Graph protocol; schema.org using Microdata; meta tags. 
    - No dependency on external resources 
    - Push on GitHub and it's live 
    - Track your visitors with Google Tag Manager or Google Analytics integration 
    - YouTube and other video website support for embeded videos
    - Pinterest integration 
    - Links and icons to other social platforms like YouTube, Facebook, Instagram, Medium, TikTok, Pinterest (hidden if not needed) 
    - Search feature 
    - Clean code 
    - Favicons for all types of devices
    - .htaccess redirects with HTTPS support 
    - Minimized HTML CSS and JS code on build for super speed 
    - Sitemap with latest modification date 
    - RSS feed 
    - Great documentation and support in max. 48 hours 
    - Easy to upgrade Jekyll and Bootstrap version
    - Easy to deploy, customize and extend 

<img src="assets/css/icons/support.png" alt="check" width="16"/><font size="5"> Documentation</font>

### Initial settings 
    - Open _config.yml and customize settings. 
    - Replace the logo in ./assets/images and size in _config.yml 
    - Replace favicons in root folder and site.webmanifest. https://favicon.io/favicon-converter/ 
    - Edit .htaccess. 
    - Run clean.bat to delete temporary files. 
    - Run develop.bat to start the development server. 
    - Run build.bat to create the _site folder and prepare for production. 
    - Run git init and add your remote repository before using git-push.bat to clean the project, stage all files, commit and push. 
    - Change the text in ./includes/footer.html and ./includes/header.html to change the menu content
    - Move your enabled social icons on the same row in ./includes/footer.html if needed 

### How to add a post 
    1. Go to _posts folder 
    2. Create a new file following the name convention from the old posts from _posts folder. 
    3. Add images into ./assets/images/posts/number/full/ full size, 1200px width thumbnails into ./assets/images/posts/number/1200/ and 600px size in ./assets/images/posts/number/600/. You can create thumbnails using https://picresize.com/en/batch and convert them to webp for better compression with https://cloudconvert.com/. For better speed use .webp extension 
    3. Look at the example posts to see how you can add a featured image, featured image thumbnail, featured image style, add an image gallery inside the post and add more images inside the post. 
    4. Use Bootstrap 5 to customize your posts. https://getbootstrap.com/docs/5.0/getting-started/introduction/ 

### How to add an author 
    - Create a new page into the ./_authors folder similar to author-voicu.md

### How to customize pages 
    - Change homepage style: edit index.html and switch between homepage-style-1, homepage-style-2 and homepage-style-3
    - Change posts style: ./_layouts/post-style-1.html 
    - For Contact and About page edit: ./about.markdown, ./contact.markdown 

### How to host on GitHub pages 
    - Create a new repository on GitHub named <your_repo_name>.github.io 
    - Build using: build.bat 
    - Push the project in the new repo. 

### How to host on your HTTP server and upload through FTP 
    - After customization run build.bat
    - Copy the content of ./_site folder to your FTP account
 