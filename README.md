# journey
Journey is an iOS app that allows you to store the various locations that you want to visit alongside with some details such as: the approximate price, notes, the date until you want to visit that location, a picture and others.

# purpose
Journey was implemented out of a desire to create a beneficial example of an application that respects the iOS architecture, uses API calls, accesses system features, connects to APIs provided by Apple (such as Maps).

# functionalities
1. Login
2. Visualize & filter locations (aka Points of Interest)
3. View POI details
4. Add/Edit/Remove POI
5. Open POI in Maps and automatically calculate the proper route 
6. Logout

# explore
App Flow:

![App flow](https://i.postimg.cc/8c9fw9Px/image.png)

Adding a new POI:

![Adding a POI](https://s9.gifyu.com/images/ezgif.com-gif-maker9dc9d74ce111e63d.gif)

# notes
- The server does not provide enough information in order to create a proper *MKPlacemark* in the app. Hence, the functionality no. 5 won’t work unless the user creates a new POI or edit the current location using the search bar. 
- If you are using Apple M1 you might have some problems on logging out. It seems like the *SQLite delete statement* is not gracefully fulfilled. 
- If you prefer to be automatically logged in when the application starts, feel free to uncomment lines 35 -> 45 from *LoginViewController.swift*
