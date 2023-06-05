# iWalle

This app generates wallpapers using math operations like multiplication, cos, sin, and average.
I also experimented with other math operations like tan and division, but cos, sin and average
are the operations where I get the best results.
The name of the app is called iWalle. The canvas has a slider that represents the complexity of the 
wallpaper and a save button in the top right corner that saves the generated wallpaper to the user's
photo library. 

<img src="Images/screens.png" alt="drawing" width="600"/>

## How to Run the Project

Since the project already have all necessary CocoaPods files, we just need to clone and run a project 
in Xcode. Follow these steps:

* Clone the project: Open Terminal and navigate to the directory where you want to clone the project. 
Then run the following command: 
`git clone https://github.com/raguerraa/wally.git`

* Navigate to the project directory: Use the cd command in Terminal to navigate to the project's directory:
`cd wally`

* Open the project: Launch Xcode and select "Open" from the File menu. Navigate to the cloned project 
directory and select the file `RandomArt.xcworkspace` to open the project. The .xcworkspace file is 
used for projects that include CocoaPods dependencies.

* Select a target device: In Xcode, select the target device (simulator or physical device) you want 
to run the project on. You can choose the device from the scheme dropdown menu in the top left corner
of the Xcode window.

* Build and run the project: Click the "Run" button in Xcode or use the "Command + R" shortcut to build 
and run the project. Xcode will automatically handle the installation of CocoaPods dependencies and 
compile the project. The app will then launch on the selected target device.

By following these steps, you should be able to clone the project, open it in Xcode using the 
.xcworkspace file, select a target device, and build and run the project with the CocoaPods 
dependencies already set up.

## Simple Wallpapers:
<img src="Images/relationalArt.png" alt="drawing" width="350"/>
<img src="Images/russetPopArt.png" alt="drawing" width="350"/>


## More Complex Wallpapers:
<img src="Images/gothicArt.png" alt="drawing" width="350"/>
<img src="Images/formalism.png" alt="drawing" width="350"/>

This project attempts to resemble the MVC architectural pattern where the folder called 
`ViewControllers` is the controller, the `DataStructures` folder is the model, and the `StoryBoards`
folder is the view. The `MathBinaryTree` in the `DataStructures` folder is where the random math 
expressions are generated and evaluated. The `CanvasV` in the `ViewControllers` folder is where 
the wallpaper is drawn. 


## Rules to Contribute in the project:
* No changes should be committed directly to the master without approval. At least one person 
 has to approve each pull request before committing to the master.
* We will be using pull requests and code reviews.
* Let's be polite and respectful when writing code reviews.


## Some wallpapers generated:

<img src="Images/IMG_51.jpg" alt="drawing" width="350"/>
<img src="Images/IMG_52.jpg" alt="drawing" width="350"/>
<img src="Images/IMG_54.jpg" alt="drawing" width="350"/>
<img src="Images/IMG_66.jpg" alt="drawing" width="350"/>
 
