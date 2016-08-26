# Firebase-VideoLibraryIOS
Netflix style Video Library app that shows and plays a video library curated from a firebase server database.

![appscreenshot1](https://cloud.githubusercontent.com/assets/12164753/18022636/13cd8dfa-6bb6-11e6-86bd-7b5d11a7477b.png)

Key Features
- Video Carousel Menu.
- It supports 2 types of Carousels: A featured menu and a regular menu. 
- You can add unlimited menu's and also add unlimited menu items.
- Works for Iphone/Ipad
- It also supports Picture in Picture of newer Ipad models.
- It can play locally uploaded videos from your firebase storage directory or youtube videos. 
- Supports Airplay 
- Updates Now Playing album art on Lockscreen.

I had put this together as a quick demonstration for a presentation of Firebase capabilites I did at the Houston IOS developer meetup. 
https://www.meetup.com/Houston-iPhone-Developers-Meetup/events/233135448/
I wanted to show more of a full fleged app, vs little codebit samples just so that people can see a realistic app to believe in. 

Once you run the app it will connect to a demo firebase server account I created. If you are in the group, send me a ping and I'll send you the login for the backend. 
To set it up with your own firebase backend just swap out the GoogleService-Info.plist with yours, and see the additional config steps below.

If you are looking for an introduction to firebase/intro sample code, I suggest you look at the demos on the firebase site, they are the best.
https://firebase.google.com/docs/samples/

CONFIGURE WITH YOUR OWN FIREBASE BACKEND.
You will need these setup.
1. Auth - Enable Email Auth and Anonymous Auth: The app doesn't have a login, but it uses Anonymous auth to track and show user activity in the app. 

![firebase2](https://cloud.githubusercontent.com/assets/12164753/18022507/11b04d4c-6bb5-11e6-8705-e60730e339e2.png)

2. RemoteConfig - The app uses remote config to choose different landing screens, for now it has only one but the code is setup for that if you use remote config to swap screens based on config settings on the server.

![firebase1](https://cloud.githubusercontent.com/assets/12164753/18022508/11b2ac40-6bb5-11e6-97fe-2dfdc00131a8.png)
Setup remote config and add one parameter called "app_default_homescreen" and value should be "region1" (without quotes)

![firebase4](https://cloud.githubusercontent.com/assets/12164753/18022505/11aacc3c-6bb5-11e6-9010-eef8d608301b.png)
Don't forget to publish changes.

![firebase3](https://cloud.githubusercontent.com/assets/12164753/18022506/11ac323e-6bb5-11e6-8936-f5ad5b7b2881.png)

3. DATABASE
The database is structured as shown in this picture. You will need to match the same node names of the structures as thats whats hardcoded in the app, or change it in your own app.

![dbstructure1](https://cloud.githubusercontent.com/assets/12164753/18023284/f4fa9cea-6bbc-11e6-8580-ba4a351e2f90.png)
Root Node for the app is the FirebaseTV (child node from your db root)
  - Inside we have "homePageCarousel" that controls the home page.
    - Inside we have regions, for now "region1" is the default. (configurable from remote config settings)
  - We also have a "videos" node that stores all the video information that the regions will use
   
![dbstructure2](https://cloud.githubusercontent.com/assets/12164753/18023283/f4f84eb8-6bbc-11e6-9de6-ea153e36d55f.png)

- Inside the region we have menus, the menus are the top-bottom menus in the app. i.e the menus create vertical rows in the table. The content inside the menus drives the horizontal content/menu

![dbstructure3](https://cloud.githubusercontent.com/assets/12164753/18023282/f4f78cf8-6bbc-11e6-931f-d594c198538b.png)

- Inside the menu, we have video items. The app sorts the order by the string item1, item2 e.t.c and the value is the video node from the videos node (video table for sql type thinking)

You can import the json structure using this file.
[fir-media-app-521e6-FirebaseTV-export.txt](https://github.com/dexyjones/Firebase-VideoLibraryIOS/files/440328/fir-media-app-521e6-FirebaseTV-export.txt)


For the video nodes, if you are uploading your own videos to firebase storage, also upload the album art, and then put the firebase storage urls in the video nodes. If you are using youtube videos, all you need is the youtube url as the phone app will pull the thumbnail from youtube. Thanks to HCYoutubeParser library

