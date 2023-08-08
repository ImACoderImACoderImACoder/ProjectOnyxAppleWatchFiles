d o# ProjectOnyxAppleWatchFiles
Files used to add project onyx code to the Apple Watch

Start by opening xcode and creating a new project for Watch OS.  Select the type "App"

Try to build the app.  If you get a build error becuase no profiles for .watchkitapp click on the error and rename it after the project with a dot before it.  this will sign the app and allow it to build

Then Add the files in this github to the project. You can replace the content of ContentView instead of copying the file since that file is generated for you

Open the info tab on the root level project and add two keys by click + on any of the rows
key 1: Required background modes -> item0 app communicates uses coreBluetooth
key 2: Privacy - Bluetooth Always Usage Description -> type "This is required" in the value column

Click the build button and with a little luck things should work out.  

Known issues:
Sometimes the bluetooth gets into a weird state with the volcano because of the watch.  To get out of the state turn the Volcano's bluetooth off and on by holding the minus button and the fan on button on the device.
