// Change Log

// Version 8.11
	// As descritbed in Version 8.10, in this version, I am applying an Array.sort() command
	// to every array created by the getFileList() command as inconsistent array order
	// has caused a run-time error as described in Version 8.10

// Version 8.10
	// When testing the program on image set "CZI Zoe Images for NMJ Analyser"
	// In Part 5, we get an out-of-bounds error for line 1077 of version 8.9 for variable l
	// I think the reason this happens is that the CSV files containing the puncta measurements
	// are being saved in the wrong directory.
	
	// The problem occurs with the CSV directory J:\Sync\Test run\Results 10 Zoe Images\04 Puncta Measurements\Ch1\070619 C9-F3-3\0920-0465
	// If you go to the corresponding slice directory J:\Sync\Test run\Results 10 Zoe Images\01 Slices\Ch1\070619 C9-F3-3
	// In the slice directory, you see 4 tif images
	// but in the CSV directory, there are only 3 files
	// And that's because the wrong image's csv files were saved there.
		// The files are 
			// 070619 C9-F3-2 000.csv
			// 070619 C9-F3-2 001.csv
			// 070619 C9-F3-2 002.csv
			//              ^
	// The CSV of F3-2 are being saved in the directory of F3-3
	// In fact, there are problems with these folders
		// 070619 C9-F3			(got files from F3-5)
		// 070619 C9-F3-2		(got files from F3)
		// 070619 C9-F3-3		(got files from F3-2)
		// 070619 C9-F3-4		(got files from F3-3)
		// 070619 C9-F3-3		(got files from F3-4)
	// It looks like there's some sort of wrap-around error here
	// None of the other file names have caused problems
	
	// The problem exists for these subdirectories also in the "05 Puncta ROIs" folder
	// But it does not exists for the "03 Binary" directory
	
	// Part 2 generates the binary images, so it is probably fine
	// Part 3 and 4 deal with the Puncta Measurements and Puncta ROIs
	// so problem is likely there
	
	// The program uses the getFileList() command a lot and maybe in some cases,
	// the list returned is not in the correct order? I don't understand why it sometimes happens
	// and sometimes not.
	
	// using Array.sort() on each array created by the getFileList() command in Part 3 solved the problem
		// I forgot this quirk of imageJ where arrays made by the getFileList() command can be in a different order than in file explorer
		// Will save this version.
		
		// In version 8.11, I will sort every array created by getFileList() to get ahead of any other such problems

// Version 8.9
	// Bug Correction
		// variables on lines 468 to 476 were undefined if running in "Default Mode"
		// assigned them a value on lines 255 to 264

// Version 8.4
	// Added 2 new variables
		// dontSegmentCh1
		// dontSegmentCh2
	// These variables are defined in Part 0 where we ask user for program mode
	// And they are used in the first for loop of Part 5
	// dontSegmentCh1 = 1 if the user wishes to not segment the puncta in ch1
		// it gets added to the initial index value of the loop
		// since index = 0 is ch1, we skip ch1
	// dontSegmentCh2 = 1 if the user wishes to not segment the puncta in ch2
		// it gets subtracted from the upper limit value of the loop such that <2 becomes <1
		// since index = 1 is ch2, a limit of <1 will prevent the loop from processing ch2
	// if both dontSegmentCh1 and dontSegmentCh2 are 1
		// then the initial index is 1 and the limit is <1
		// meaning the loop will not run at all, skipping the segmentation for both channels
		
	// on Line 970, in the print statement, "-1" added after "rowCount" to print
		// the actual number of puncta detected. It was 1 too high before

// Version 8.3
	// In Part 4 and 5, where we determine whether a particular puncta needs to be segmented, 
	// we currently hard-coded the criteria as follow:
		//1. Area>4
		//2. Circularity<0.65
		//3. Aspect ratio>2.5
	// In this version, we are changing 2 things
		// 1) We are allowing the users to change the threshold values for the 3 criteria
			// The previous values will be kept on as "default" values
		// 2) We are going to allow channel 1 and 2 to have different thresholds for these 3 criteria
		// 3) Create an "Advanced Settings" where users can determine the thresholds for the 3 criteria

// Version 8.2
	// In Part 5 (Segmented), Line 670
	// Changed Sigma width from 0.7 to 1
	// We decided to do this to make the blurring consistent between Part 2 where we deliniate the punta
	// and Part 5 where we look for the local maxima inside those puncta

// Version 8.1
	// Will change, in Part 2 (Apply Brightness, Gaussian Blur, and Threshold),
	// how the images are pre-processed before ROI detection is done in part 3
	// Brightness & Contrast
		// Will change from hard coding min = 31 and max = 146 to:
			// Apply Gaussian Blur of 1px (may change that to be per distance, not pixel in future revision)
			// Measure min and max, calculate max-min = range
			// newMin = min+(range/10) and newMax = max-(range/10)
		// Apply Otsu thresholding like before
		// Run Despeckle
	// Remove 2 blocks of copy-pasted code (1 per channel) into a block of code with a for loop for to iterate through channels





function openCSV(csvPath) { 
	requires("1.35r");
	lineseparator = "\n";
	cellseparator = ",\t";
	
	// copies the whole RT to an array of lines
	lines=split(File.openAsString(csvPath), lineseparator);
	if (lines.length == 0) { // if CSV is empty
		return 0;
	}
	if (lines.length > 0) { // if CSV is not empty
		// recreates the columns headers
	     labels=split(lines[0], cellseparator);
	     if (labels[0]==" "){
	        p=1; // it is an ImageJ Results table, skip first column
	     }
	     else{
	        p=0; // it is not a Results table, load all columns
	     }
	     for (o=p; o<labels.length; o++){
	        setResult(labels[o],0,0);
	     }			
	     // dispatches the data into the new RT
	     run("Clear Results");
	     for (n=1; n<lines.length; n++) {
	        items=split(lines[n], cellseparator);
	        for (o=p; o<items.length; o++)
	           setResult(labels[o],n-1,items[o]);
	     }
	     updateResults();
	     return lines.length;
	}
}




print("\\Clear");
print("Neuromuscular Junction Colocalization Analyser v.1.0.0");
close("*");

// Ask user for which mode
Dialog.create("NMJ Analyser");
Dialog.addMessage("Before you begin, ensure you have the following 2 folders ready" +
					"\n " +
					"\n A folder containing only the the images you wish to analyze " + 
					"\n with no other files nor folders inside" +
					"\n " + 
					"\n An empty folder within which the results of the analysis" +
					"\n will be saved");
Dialog.show();
















setBatchMode(true);

close("*");
roiManager("reset");

// Part 0 Get Folders and Make Folders

// Ask user for files we need for program
cziDirectory = getDirectory("Image Folder is");
//hemisomitesDir=getDirectory("Hemisomites from");
resultsDir = getDirectory("Results Folder is");




// Create folders where we save results

// Z-Projection Directory
File.makeDirectory(resultsDir + "00 Z-Proj Channel1");
zProjectionDirectory = resultsDir + "00 Z-Proj Channel1\\";
//print(zProjectionDirectory);

// Slices Directory + subDir
File.makeDirectory(resultsDir + "01 Slices");
File.makeDirectory(resultsDir + "01 Slices\\" + "Ch1");
File.makeDirectory(resultsDir + "01 Slices\\" + "Ch2");
sliceDir = resultsDir + "01 Slices\\";
ch1SliceDir= resultsDir + "01 Slices\\" + "Ch1\\";
ch2SliceDir= resultsDir + "01 Slices\\" + "Ch2\\";
sliceChDirList = newArray(ch1SliceDir, ch2SliceDir);

File.makeDirectory(resultsDir + "01b Slices with ROI");
File.makeDirectory(resultsDir + "01 Slices with ROI\\" + "Ch1");
File.makeDirectory(resultsDir + "01 Slices with ROI\\" + "Ch2");
sliceWithROIDir = resultsDir + "01b Slices with ROI";
sliceWithROIChList = getFileList(sliceWithROIDir);
Array.sort(sliceWithROIChList);

// Hemisomites Directory
File.makeDirectory(resultsDir + "02 Hemisomites");
hemisomitesDir = resultsDir + "02 Hemisomites\\";
cziList = getFileList(cziDirectory);
Array.sort(cziList);
for (a = 0; a < cziList.length; a++) {
	File.makeDirectory(hemisomitesDir + cziList[a] + "\\");
}

// Binary Slices Directory + subDir
File.makeDirectory(resultsDir + "03 Binary");
File.makeDirectory(resultsDir + "03 Binary\\" + "Ch1");
File.makeDirectory(resultsDir + "03 Binary\\" + "Ch2");
binarySliceDir = resultsDir + "03 Binary\\";
binaryCh1SliceDir=resultsDir + "03 Binary\\" + "Ch1\\";
binaryCh2SliceDir=resultsDir + "03 Binary\\" + "Ch2\\";
binaryChSliceDirList = newArray(binaryCh1SliceDir, binaryCh2SliceDir);

//Puncta Measuements
File.makeDirectory(resultsDir + "04 Puncta Measurements");
punctaMeasureDir=resultsDir + "04 Puncta Measurements\\";
File.makeDirectory(resultsDir + "04 Puncta Measurements\\" + "Ch1");
File.makeDirectory(resultsDir + "04 Puncta Measurements\\" + "Ch2"); 
punctaMeasureCh1Dir=resultsDir + "04 Puncta Measurements\\" + "Ch1\\";
punctaMeasureCh2Dir=resultsDir + "04 Puncta Measurements\\" + "Ch2\\";

//Puncta ROIs
File.makeDirectory(resultsDir + "05 Puncta ROIs");
File.makeDirectory(resultsDir + "05 Puncta ROIs\\"+ "Ch1");
File.makeDirectory(resultsDir + "05 Puncta ROIs\\"+ "Ch2");
punctaRoiDir = resultsDir + "05 Puncta ROIs\\";
punctaRoiCh1Dir=resultsDir + "05 Puncta ROIs\\" + "Ch1\\";
punctaRoiCh2Dir=resultsDir + "05 Puncta ROIs\\" + "Ch2\\";

//Colocalization Measurements
File.makeDirectory(resultsDir + "06 Colocalization Results");
coloResultDir = resultsDir + "06 Colocalization Results/";
hemisomitesDirImages = getFileList(hemisomitesDir);
Array.sort(hemisomitesDirImages);
cziList=getFileList(cziDirectory);
Array.sort(cziList);
for (a = 0; a < cziList.length; a++) {
	File.makeDirectory(coloResultDir + cziList[a]);
	hemisomiteList = getFileList(hemisomitesDir + hemisomitesDirImages[a]);
	Array.sort(hemisomiteList);

	for (b = 0; b < hemisomiteList.length; b++) {
		File.makeDirectory(coloResultDir + cziList[a]);
		
	}

}

// Directory for analysis settings save-file
File.makeDirectory(resultsDir + "07 Settings and Logs\\");
settingsAndLogsDir = resultsDir + "07 Settings and Logs\\";



Dialog.create("Have ROIs already been defined?");
//Dialog.addMessage("Choose a program mode");
userOptions = newArray("1. Regions of Interest (ROIs) have not yet been drawn", "2. ROIs have already been drawn");
Dialog.addRadioButtonGroup("Mode", userOptions, 2, 1, "1. Regions of Interest (ROIs) have not yet been drawn");
Dialog.addMessage("1. Regions of Interest (ROIs) have not yet been drawn" +
					"\n Choose this mode if you are running the program for the first time and" +
					"\n the regions of interest in each image have not yet been drawn" + 
					"\n or if you want the whole image area to be analyzed." + 
					"\n " +
					"\n2. ROIs have already been drawn" + 
					"\n Choose this mode if you have already drawn the ROIs for each image and saved them in:" +
					"\n " + resultsDir + "02 Hemisomites\\" +
					"\n and you wish to proceed with the colocalization analysis");
Dialog.show();

userChoice = Dialog.getRadioButton();
if (userChoice == "1. Regions of Interest (ROIs) have not yet been drawn") {
	programMode = 1;
}
if (userChoice == "2. ROIs have already been drawn") {
	programMode = 2;
}


// Ask user if they want to change settings for punctum segmentation in advanced mode
Dialog.create("Segmentation: Default or Advanced Mode");
userOptions = newArray("Default Mode", "Advanced Mode");
Dialog.addRadioButtonGroup("Mode", userOptions, 1, 2, "Default Mode");

Dialog.addMessage("Default mode will segment clustered punctae into single punctae if they" +
				"\nmeet the following criteria:" +
				"\n    Area > 4 um^2" + 
				"\n    Circularity < 0.65" + 
				"\n    Aspect ratio > 2.5" + 
				"\nThese settings are well suited if for the detection" +
				"\nof neuromuscular junctions.");
				
Dialog.addMessage("Advanced Mode let's the user modify the settings used to" +
				"\ndetermine whether and which punctum must be segmented" + 
				"\ninto smaller punctae.");
Dialog.show();

advancedSegmentationChoice = Dialog.getRadioButton();
if (advancedSegmentationChoice == "Default Mode") {
	advancedSegmentationMode = false;
}
if (advancedSegmentationChoice == "Advanced Mode") {
	advancedSegmentationMode = true;
}

if (advancedSegmentationMode == false) { // run in default mode
	segmentCh1Default = "Yes";
	segmentCh1User = segmentCh1Default;
	areaCh1User = areaCh1Default = 4;
	circCh1User = circCh1Default = 0.65;
	arCh1User = arCh1Default = 2.5;
	segmentCh2Default = "Yes";
	segmentCh2User = segmentCh2Default;
	areaCh2User = areaCh2Default = 4;
	circCh2User = circCh2Default = 0.65;
	arCh2User = arCh2Default = 2.5;
	
	dontSegmentCh1 = 0;
	dontSegmentCh2 = 0;
	
	// Put user setting values into convenient variables
		// area, circ, and AR will all be array of length 2
		// index 0 will be channel 1 value
		// index 1 will be channel 2 value
	areaUserSetting = newArray(areaCh1Default, areaCh2Default);
	circUserSetting = newArray(circCh1Default, circCh2Default);
	arUserSetting = newArray(arCh1Default, arCh2Default);
}

if (advancedSegmentationMode == true) {
	previousSettingsExist = File.exists(settingsAndLogsDir + "segmentationSettings.csv");
	
	Dialog.create("Segmentation Settings");
	
	
	
	if (previousSettingsExist == 1) { // If previous settings exist in the form of a csv file, then load the settings into the current dialog as default settings
		Table.open(settingsAndLogsDir + "segmentationSettings.csv"); // open csv file with segmentations setting values
		
		Dialog.addMessage("NOTE: Settings from a previous analysis were detected and were autofilled into the settings");
		
		segmentCh1Default = Table.get("Segment Ch1", 0); 	// To segment ch1 or not is saved as an int because strings loaded using the Table.get() command return null
		if (segmentCh1Default == 1) {						// set segmentCh1Default to "Yes" or "No" based on int saved
			segmentCh1Default = "Yes";						// Need a string "Yes" or "No" because the Dialog default values need to match string
		}
		if (segmentCh1Default == 0) {
			segmentCh1Default = "No";
		}
		areaCh1Default = Table.get("Area Ch1", 0);
		circCh1Default = Table.get("Circularity Ch1", 0);
		arCh1Default = Table.get("Aspect Ratio Ch1", 0);
		
		segmentCh2Default = Table.get("Segment Ch2", 0);
		if (segmentCh2Default == 1) {
			segmentCh2Default = "Yes";
		}
		if (segmentCh2Default == 0) {
			segmentCh2Default = "No";
		}
		areaCh2Default = Table.get("Area Ch2", 0);
		circCh2Default = Table.get("Circularity Ch2", 0);
		arCh2Default = Table.get("Aspect Ratio Ch2", 0);
		
		
		// print("segmentCh1Default: " + segmentCh1Default);
		// print("areaCh1Default: " + areaCh1Default);
		// print("circCh1Default: " + circCh1Default);
		// print("arCh1Default: " + arCh1Default);
		// print("");
		// print("segmentCh2Default: " + segmentCh2Default);
		// print("areaCh2Default: " + areaCh2Default);
		// print("circCh2Default: " + circCh2Default);
		// print("arCh2Default: " + arCh2Default);
		
		close("segmentationSettings.csv");
		
		
	}
	if (previousSettingsExist == 0) {	// If no previous settings have been saved, load the default settings into the dialog box
		segmentCh1Default = "Yes";
		areaCh1Default = 4;
		circCh1Default = 0.65;
		arCh1Default = 2.5;
		segmentCh2Default = "Yes";
		areaCh2Default = 4;
		circCh2Default = 0.65;
		arCh2Default = 2.5;
	}
	
	
	yesNoChoice = newArray("Yes", "No");
	Dialog.addRadioButtonGroup("Segment Punctae in Channel 1?", yesNoChoice, 1, 2, segmentCh1Default); 	// Radio Button 1
	Dialog.addMessage("Segment a punctum if its:");
	Dialog.addNumber("Area is greater than", areaCh1Default, 3, 10, "um^2");						// Number 1 (Area ch1)
	Dialog.addSlider("Circularity is lesser than", 0, 1, circCh1Default);							// Number 2 (Circularity ch1)
	Dialog.addNumber("Aspect Ratio is greater than", arCh1Default, 3, 10, "");						// Number 3 (Aspect Ratio ch1)
	
	Dialog.addMessage("");
	Dialog.addRadioButtonGroup("Segment Punctae in Channel 2?", yesNoChoice, 1, 2, segmentCh2Default); 	// Radio Button 2
	Dialog.addMessage("Segment a punctum if its:");
	Dialog.addNumber("Area is greater than", areaCh2Default, 3, 10, "um^2");						// Number 4 (Area ch2)
	Dialog.addSlider("Circularity is lesser than", 0, 1, circCh2Default);							// Number 5 (Circularity ch2)
	Dialog.addNumber("Aspect Ratio is greater than", arCh2Default, 3, 10, "");						// Number 6 (Aspect Ratio ch2)
	
	Dialog.addCheckbox("Ignore previous settings and apply default settings", false);			// Checkbox 1		Ask user if they want to ignore previously saved settings and revert to defaults
	
	
	Dialog.show();
	
	segmentCh1User = Dialog.getRadioButton();										// Get Radio Button 1
	areaCh1User = Dialog.getNumber();												// Get Number 1 (Area ch1)
	circCh1User = Dialog.getNumber();												// Get Number 2 (Circularity ch1)
	arCh1User = Dialog.getNumber();													// Get Number 3 (Aspect Ratio ch1)
	
	segmentCh2User = Dialog.getRadioButton();										// Get Radio Button 2
	areaCh2User = Dialog.getNumber();												// Get Number 4 (Area ch2)
	circCh2User = Dialog.getNumber();												// Get Number 5 (Circularity ch2)
	arCh2User = Dialog.getNumber();													// Get Number 6 (Aspect Ratio ch2)
	
	useDefaultSet = Dialog.getCheckbox();											// Get Checkbox 1
	
	if (useDefaultSet == true) {	// If user wants us to revert to default settings, ignore what the user entered in the dialog box and use default settings
		segmentCh1User = "Yes";
		areaCh1User = 4;
		circCh1User = 0.65;
		arCh1User = 2.5;
		segmentCh2User = "Yes";
		areaCh2User = 4;
		circCh2User = 0.65;
		arCh2User = 2.5;
	}
	
	
	
	
	// print("segmentCh1User: " + segmentCh1User);
	// print("areaCh1User: " + areaCh1User);
	// print("circCh1User: " + circCh1User);
	// print("arCh1User: " + arCh1User);
	// print("");
	// print("segmentCh2User: " + segmentCh2User);
	// print("areaCh2User: " + areaCh2User);
	// print("circCh2User: " + circCh2User);
	// print("arCh2User: " + arCh2User);
	
	if (segmentCh1User == "Yes") { // Can't read strings out of csv. So converting "yes" to 1 and "no" to 0 for segment y/n option
		segmentCh1UserNum = 1;
		dontSegmentCh1 = 0;		// Used in the channel for-loop of Part 5: Segmentation
									// If we want to segment the puncta in ch1, 
									// then we add 0 to the index of the for loop 
									// so that it starts at 0 which is Ch1
									
									// If we do not want to segment the puncta of ch1, 
									// then we add 1 to the index of the for loop 
									// so that it starts at 1 which is ch2
	}
	if (segmentCh1User == "No") {
		segmentCh1UserNum = 0;
		dontSegmentCh1 = 1;
	}
	if (segmentCh2User == "Yes") {
		segmentCh2UserNum = 1;
		dontSegmentCh2 = 0;		// Used in the channel for-loop of Part 5 Segmentation
									// If we want to segment the puncta in ch2
									// then we subtract 0 from the < max value of the loop
									// so that it stays at <2, meaning ch2 (index = 1)
									// will be segmented
									
									// If we do not want to segment the puncta of ch2
									// then we subtract 1 from the < max value of the loop
									// so that it becomes < 1, meaning ch2 (index = 1)
									// will not be segmented
									
									// If we do not want to segment the puncta in ch1 nor 2
									// then dontSegmentCh1 = 1 such that the initial index = 1
									// and dontSegmentCh2 = 1, such that loop limit is <1
									// thus the for loop will not be entered and neither
									// channel will have their puncta segmented
	}
	if (segmentCh2User == "No") {
		segmentCh2UserNum = 0;
		dontSegmentCh2 = 1;
	}
	
	
	// Put user setting values into convenient variables
		// area, circ, and AR will all be array of length 2
		// index 0 will be channel 1 value
		// index 1 will be channel 2 value
	areaUserSetting = newArray(areaCh1User, areaCh2User);
	circUserSetting = newArray(circCh1User, circCh2User);
	arUserSetting = newArray(arCh1User, arCh2User);
	
	
	
	
	segmentationSettings = newArray(segmentCh1UserNum, areaCh1User, circCh1User, arCh1User, segmentCh2UserNum,areaCh2User, circCh2User, arCh2User);
	segSetColName = newArray("Segment Ch1", "Area Ch1", "Circularity Ch1", "Aspect Ratio Ch1", "Segment Ch2","Area Ch2", "Circularity Ch2", "Aspect Ratio Ch2");
	// Array.print(segmentationSettings);
	// Array.print(segSetColName);
	
	
	// Save settings in a csv
	Table.create("segmentationSettings");
	for (i = 0; i < segmentationSettings.length; i++) {
		Table.set(segSetColName[i], 0, segmentationSettings[i]);
	}
	
	Table.save(settingsAndLogsDir + "segmentationSettings.csv");
	close("segmentationSettings");
	
	if (useDefaultSet == true) {
		File.delete(settingsAndLogsDir + "segmentationSettings.csv");
	}
}


print("");
print("Images to be analyzed from: " + cziDirectory);
for (i = 0; i < cziList.length; i++) {
	print("    " + cziList[i]);
}
print("");
print("Analysis Settings");
print("    Channel 1");
print("        Segment: " + segmentCh1User);
print("        Segmentation Criteria: ");
print("        Area is greater than: " + areaCh1User);
print("        Circularity is lesser than: " + circCh1User);
print("        Aspect Ratio is greater than: " + arCh1User);
print("    Channel 2");
print("        Segment: " + segmentCh2User);
print("        Segmentation Criteria: ");
print("        Area is greater than: " + areaCh2User);
print("        Circularity is less than: " + circCh2User);
print("        Aspect Ratio is greater than: " + arCh2User);
print("");

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
startYear = year;
startMonth = month;
startDayOfMonth = dayOfMonth;
startHour = hour;
startMinute = minute;
startSecond = second;
print("Analysis started on: " + startYear + "-" + startMonth + "-" + startDayOfMonth + " at " + startHour + ":" + startMinute + ":" + startSecond);


// waitForUser("Finished Part 0: Setup");







if (programMode == 1) {
	//PART 1 Get CZI and save Z-Projection and Slices
	print("");
	print("Part 1: Create Z-Projections and Extract slices from image files");


	// get all the czi files in the directory
	cziList = getFileList(cziDirectory);
	Array.sort(cziList);
	
//	print("Debug 1.0");
	for (i = 0; i < cziList.length; i++) { 
//		print("Debug 1.1");
//		print("Debug 1.1 i = " + i);
		print("    Processing file " + i+1 + " of " + cziList.length);
		showProgress(i, cziList.length);
	
	
	
		// Split Channels and Z-projection
		run("Bio-Formats Importer", "open=[" + cziDirectory + cziList[i] + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT"); // open complex image using Bio-Format Importer
		run("Split Channels"); // Complex image gets separated into 2 Z-stacks, one for channel 1, one for channel 2
		windowsList = getList("image.titles"); // windowList now contains the name of the 2 z-stacks currently open
//		Array.print(windowsList);
	
		// Perform Z-Projection for channel 1
		selectWindow(windowsList[0]); 						// select z-stack for channel 1
		run("Z Project...", "projection=[Max Intensity]"); 	// creates a 3rd image window
		windowsList = getList("image.titles"); 				// Update windowList to include 3rd image (Z-Projection of ch=0) 
//		Array.print(windowsList);
		tempFileName = windowsList[2];
		tempFileName = replace(tempFileName, "czi", "tif");
		saveAs("Tiff", zProjectionDirectory+tempFileName);	// Saves 3rd image window as a tif
		close(tempFileName);								// Close 3rd image window containing the Z-Projection
		
		
		//Save Slices for Ch-1 and Ch-2
		windowsList=getList("image.titles");	// Update windowList to remove the now closed 3rd image window
//		Array.print(windowsList);
		
		currentImageName = cziList[i];
		currentImageName = replace(currentImageName, ".czi", "");
		
		//Channel 1 slices
		selectWindow(windowsList[0]);
		File.makeDirectory(ch1SliceDir + currentImageName);
		currentImageCh1Dir = ch1SliceDir + currentImageName;
	
		run("Image Sequence... ", "select=[" + currentImageCh1Dir + "] dir=[" + currentImageCh1Dir + "] format=TIFF name=[" + currentImageName + " ] digits=3");
	
		//Channel 2 slices
		selectWindow(windowsList[1]);
		File.makeDirectory(ch2SliceDir + currentImageName);
		currentImageCh2Dir = ch2SliceDir + currentImageName;
	
		run("Image Sequence... ", "select=[" + currentImageCh2Dir + "] dir=[" + currentImageCh2Dir + "] format=TIFF name=[" + currentImageName + " ] digits=3");
	
		close("*");
		
		
	}
	
	
	// Part 1.1 Showing users the Z-Projections so they can draw the hemisomites
		// Goal is to save the hemisomites automatically into correct directory
	
	Dialog.create("Define the Regions of Interest (ROIs)");
	userOptions = newArray("Assisted Mode", "Manual Mode");
	Dialog.addRadioButtonGroup("Mode", userOptions, 2, 1, "Assisted Mode");
	Dialog.addMessage("Assisted Mode:" + 
						"\nEach Z-Projection will appear on screen." + 
						"\nThe user will be prompted to draw 1 or more ROI using a selection tool" + 
						"\nand name them appropriately. The ROIs will then be saved automatically" +
						"\nin the appropriate folder");
	Dialog.addMessage("Manual Mode: " +
						"\nThe program will end. The user will have to open the images from" +
						"\n" + zProjectionDirectory +
						"\ndraw ROIs, and will have to save them in a the folder matching the image name in" + 
						"\n" + hemisomitesDir + 
						"\nAfter drawing and saving the ROIs, the user will need to relaunch this" + 
						"\nprogram but select '2. ROIs have already been drawn' in the first options window");
	Dialog.show();
	
	userChoice = Dialog.getRadioButton();
	// print("userChoice: " + userChoice);
	if (userChoice == "Assisted Mode") {
		setBatchMode(false);
		for (i = 0; i < cziList.length; i++) {
			zProjectionList = getFileList(zProjectionDirectory);
			Array.sort(zProjectionList);
			open(zProjectionDirectory + zProjectionList[i]);
			setTool("polygon");
			waitForUser("Draw your ROI(s) in " + cziList[i] + " ( " + i+1 + " of " + cziList.length + " )", "Move this window out of the way of the image window if necessary." + 
											"\nFor each ROI you wish to draw:" +
											"\n1. Left click on the image window to draw the shape of your region of interest" + 
											"\n2. Right click to seal your region of interest" +
											"\n3. Press the 't' key on the keyboard to add the region of interest to the ROI manager" + 
											"\n4. Select the ROI and then on 'Rename' to give it a descriptive name" + 
											"\n5. Repeat for each ROI within this image." + 
											"\n " + 
											"\n Once you drew all the ROI for this image, click the 'OK' button on this window" +
											"\n The program will save your ROI in the correct folder automatically" +
											"\n and will show you the next image to analyze" +
											"\n " +
											"\n If you wish to analyze the whole image, click the 'OK' button on this window");
			
			roiCount = roiManager("count");
			for (j = 0; j < roiCount; j++) {
				roiManager("select", j);
				roiName = call("ij.plugin.frame.RoiManager.getName", j);
				roiManager("save", hemisomitesDir + hemisomitesDirImages[i] + roiName + ".roi");
				
			}
			
			if (roiCount == 0) { // if the user does not draw an ROI, then the whole image will be analyzed
									// To analyze whole image, we are creating a ROI that covers the whole image and saving it
									// This is so that we don't have to change the code in part 3 and 4, which always assume there is at least one roi
				
				run("Select All"); // selects whole image as ROI
				roiManager("add"); // Adds ROI to roiManager
				roiManager("select", 0);
				roiManager("rename", "wholeImage");
				roiManager("save", hemisomitesDir + hemisomitesDirImages[i] + "wholeImage.roi");
			}
			
			roiManager("reset");
			close();
			
		}
		

		programMode = 2;
	}
	
	print("Part 1 Complete");
	print("");
	
}



if (programMode == 2) {


	// PART 2 Apply Brightness, Gaussian Blur, and Threshold
	print("Part 2: Apply Brightness, Gaussian Blur, and Threshold to each slice");
	setBatchMode(true);
	ch1SliceDirImages = getFileList(ch1SliceDir);
	Array.sort(ch1SliceDirImages);
//	Array.print(ch1SliceDirImages);

	// Calculate total number of slices	
	sliceCount = 0;
	// Number of slices across all images in ONE channel
	for (i = 0; i < ch1SliceDirImages.length; i++) {
		ch1SliceDirImgSlice = getFileList(ch1SliceDir + ch1SliceDirImages[i]);
		Array.sort(ch1SliceDirImgSlice);
		newSliceCount = ch1SliceDirImgSlice.length;
		sliceCount = sliceCount + newSliceCount;
	}
	sliceCount = sliceCount *2; // for 2 channels worth of slices
	
	sliceTicker = 0;
	
	// print("Debug 2.1: sliceChDirList.length: " + sliceChDirList.length);
	for (i = 0; i < sliceChDirList.length; i++) { // for every channel
		sliceChImgList = getFileList(sliceChDirList[i]);
		Array.sort(sliceChImgList);
		
		// print("Debug 2.2 sliceChImgList.length: " + sliceChImgList.length);
		
		for (j = 0; j < sliceChImgList.length; j++) {
			sliceChImgSliceList = getFileList(sliceChDirList[i] + sliceChImgList[j]);
			Array.sort(sliceChImgSliceList);
			
			// print("Debug 2.3 sliceChImgSliceList.length: " + sliceChImgSliceList.length);
			
			for (k = 0; k < sliceChImgSliceList.length; k++) {
				open(sliceChDirList[i] + sliceChImgList[j] + sliceChImgSliceList[k]); // open current slice
				setOption("ScaleConversions", true);
				run("8-bit");
				run("Gaussian Blur...", "sigma=1"); // Apply Gaussian Blur with sigma = 1
				
				// Get min and max brightness from blurred image
				run("Measure");
				minBright = getResult("Min", 0);
				maxBright = getResult("Max", 0);
				run("Clear Results");
				//close("Results");
				
				// calculate new min and max brightness and apply it
				brightRange = maxBright-minBright;
				newMinBright = minBright + round(brightRange / 10);
				newMaxBright = maxBright - round(brightRange / 10);
				setMinAndMax(newMinBright, newMaxBright);
				run("Apply LUT"); // applies the settings from setMinAndMax to the image
				
				// Apply Otsu thresholding
				setAutoThreshold("Otsu dark no-reset");
				
				
				// Generate mask image
				setOption("BlackBackground", true);
				run("Convert to Mask");
				
				// Despeckle image
				run("Despeckle");
				if (maxBright<35) {
					run("Set...", "value=0");
					updateDisplay();
				}

				// Create new subdiretories in binary slice directory
				File.makeDirectory(binaryChSliceDirList[i] + sliceChImgList[j]);
				// Save masks to that image
				saveAs("Tiff", binaryChSliceDirList[i] + sliceChImgList[j] + sliceChImgSliceList[k]);
				
				// Close image
				close();
				
				// Print Progress
				print("    Processing Slice " + sliceTicker+1 + " of " + sliceCount);
				sliceTicker = sliceTicker+1;
			}
		}
	}
	
	
	
	
	
	print("Part 2 Complete");
	print("");
	
	// waitForUser("Part 2 Complete");
	
	
	
	
	
	
	
	
	
	
	
	
	// PART 3 Create ROIs for each punctum
	
	print("Part 3: Create an ROI for each punctum in slices");
	
	
	hemisomitesDirImages=getFileList(hemisomitesDir);
	Array.sort(hemisomitesDirImages);
//	Array.print(hemisomitesDirImages);
	
	
	
	// Calculating total number of slices
	tickerTotal = 0;
	for (i = 0; i < hemisomitesDirImages.length; i++) {
		hemisomiteList=getFileList(hemisomitesDir+hemisomitesDirImages[i]);
		Array.sort(hemisomiteList);
		for (j = 0; j < hemisomiteList.length; j++) {
			binaryChList = getFileList(binarySliceDir);
			Array.sort(binaryChList);
			for (m = 0; m < binaryChList.length; m++) {
				binaryChImgList = getFileList(binarySliceDir + binaryChList[m]);
				Array.sort(binaryChImgList);
				binaryChImgSliceList = getFileList(binarySliceDir + binaryChList[m] + binaryChImgList[i]);
				Array.sort(binaryChImgSliceList);
				newTickerTotal = binaryChImgSliceList.length;
				tickerTotal = tickerTotal + newTickerTotal;
			}
		}
	}	
	
	
//	print("Debug 3.1");
	tempTicker = 0;
	for (i = 0; i < hemisomitesDirImages.length; i++) {
		hemisomiteList=getFileList(hemisomitesDir+hemisomitesDirImages[i]);
		Array.sort(hemisomiteList);
	//	print("Debug 3.2");
		for (j = 0; j < hemisomiteList.length; j++) {
			binaryChList = getFileList(binarySliceDir);
			Array.sort(binaryChList);
			
			for (m = 0; m < binaryChList.length; m++) {
//				print("Debug 3.2b");
				
				binaryChImgList = getFileList(binarySliceDir + binaryChList[m]);
				Array.sort(binaryChImgList);
				
//				Array.print(binaryChList);
//				Array.print(binaryChImgList);
				
				binaryChImgSliceList = getFileList(binarySliceDir + binaryChList[m] + binaryChImgList[i]);
				Array.sort(binaryChImgSliceList);
//				print("binaryChImgSliceList.length: " + binaryChImgSliceList.length);
				
	//			print("Debug 3.3");
				for (k = 0; k < binaryChImgSliceList.length; k++) {
					roiManager("Open",hemisomitesDir+hemisomitesDirImages[i]+hemisomiteList[j]);
					
	//				print("Debug 3.4");
					open(binarySliceDir + binaryChList[m] + binaryChImgList[i] + binaryChImgSliceList[k]);
					
					
	//				print("Debug 3.5");			
					roiManager("Select", 0);
					run("Make Inverse");
					run("Set...", "value=0");
					
	//				print("Debug 3.6");
					roiManager("Delete");
					run("Select None");
					
	//				print("Debug 3.7");
					
					Table.create("Results");
					
					run("Set Measurements...", "area mean min fit shape area_fraction redirect=None decimal=3");
					run("Analyze Particles...", "display clear add");
					
					
					rowCount = nResults();
					for (l = 0; l < rowCount; l++) {
						setResult("Segment", l, l);
					}
					
	//				print("Debug 3.8");
					
					
	//				print("Debug 3.9");
					currentImageName = cziList[i];
					currentImageName = replace(currentImageName, ".czi", "");
					File.makeDirectory(punctaMeasureCh1Dir + currentImageName);
					
					currentHemiSomiteName = hemisomiteList[j];
					currentHemiSomiteName = replace(currentHemiSomiteName, ".roi", "");
					
					punctaMeasureDirChList = getFileList(punctaMeasureDir);
					Array.sort(punctaMeasureDirChList);
					File.makeDirectory(punctaMeasureDir + punctaMeasureDirChList[m] + currentImageName);
					
					File.makeDirectory(punctaMeasureDir + punctaMeasureDirChList[m] + currentImageName + "\\" + currentHemiSomiteName);
					
					windowsList = getList("image.titles");
					measurementName = replace(windowsList[0], ".tif", ".csv");
					
					saveAs("Results", punctaMeasureDir + punctaMeasureDirChList[m] + currentImageName + "\\" + currentHemiSomiteName + "\\" + measurementName);
	//				print("Debug 3.9  " + punctaMeasureDir + punctaMeasureDirChList[m] + currentImageName + "\\" + currentHemiSomiteName + "\\" + measurementName);
					
					
					
	//				print("Debug 3.10");
					
					
					// Save ROIs as ZIP
					punctaRoiDirChList = getFileList(punctaRoiDir);
					Array.sort(punctaRoiDirChList);
					File.makeDirectory(punctaRoiDir + punctaRoiDirChList[m] + currentImageName);
					
					
					currentSliceName = getList("image.titles");
					currentSliceName = currentSliceName[0];
					currentSliceName = replace(currentSliceName, ".tif", "");
					
					File.makeDirectory(punctaRoiDir + punctaRoiDirChList[m] + currentImageName  + "\\" + currentHemiSomiteName);
					File.makeDirectory(punctaRoiDir + punctaRoiDirChList[m] + currentImageName  + "\\" + currentHemiSomiteName + "\\" + currentSliceName);
					
					roiCount = roiManager("count");
					if (roiCount > 0) {
						
						savePathAndName = punctaRoiDir + punctaRoiDirChList[m] + currentImageName  + "\\" + currentHemiSomiteName + "\\" + currentSliceName + "\\" + currentSliceName + ".zip";
						roiManager("save", savePathAndName);
						roiManager("reset");
					}
					
					
					print("    Detecting puncta in slice: '" + windowsList[0] + "'  ( " + tempTicker+1 + " of " + tickerTotal + " )");
					tempTicker++; 
					
					
					// When saving ROIs, use one folder per slice in the "04 Puncta ROI" folder
					// This is for the case where a slice has 0 punctum
					// This way, the list of ROIs and list of slices maintain a 1-to-1 correspondance
					
					
					
					close("*");
				}
			}
		}
	}

	close("Results");
	//close("ROI Manager");
	print("Part 3 Complete");
	print("");	
	
	
	
	
	
	
	
	
	

	
	
	
	// Part 4 Determine which ROIs need to be segmented
	print("Part 4: Determine which ROIs in each slice need to be segmented");
	
	// parameters for bad puncta:
	//1. Area>4
	//2. Circularity<0.65
	//3. Aspect ratio>2.5
	channelList=getFileList(punctaMeasureDir);
	Array.sort(channelList);
//	print("channelList[0]: " + channelList[0]);
	
	tempTicker = 0;
	tickerTotal = 0;
	// Calculate the total number of slices
	for (i = 0; i < channelList.length; i++) {
		imageFolderList=getFileList(punctaMeasureDir + channelList[i]);
		Array.sort(imageFolderList);
		for (j = 0; j < imageFolderList.length ; j++) {
			hemisomiteList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j]);
			Array.sort(hemisomiteList);
			for (k = 0; k < hemisomiteList.length; k++) {
				csvList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k]);
				Array.sort(csvList);
				newTickerTotal = csvList.length;
				tickerTotal = tickerTotal + newTickerTotal;
			}
		}
	}
	
	
	
	for (i = 0; i < channelList.length; i++) {
// 		print("Debug 4.1");
//		print("channelList.length: " + channelList.length);
		
		imageFolderList=getFileList(punctaMeasureDir + channelList[i]);
		Array.sort(imageFolderList);
		// print("channelList["+i+"]: " + channelList[i]);
		
		for (j = 0; j <imageFolderList.length ; j++) {
 			// print("Debug 4.2");
			hemisomiteList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j]);
			Array.sort(hemisomiteList);
			// print("imageFolderList["+j+"]: " + imageFolderList[j]);
			
			for (k = 0; k < hemisomiteList.length; k++) {
 				// print("Debug 4.3");
				csvList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k]);
				Array.sort(csvList);
				// print("hemisomiteList["+k+"]: " + hemisomiteList[k]);
				for (l = 0; l < csvList.length; l++) {
 					// print("Debug 4.4");
					
					
					linesInCSV = openCSV(punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + csvList[l]);
					
					if (linesInCSV == 0) {
 						// print("Debug 4.5 empty CSV");
					}
					if (linesInCSV > 0) {
 						// print("Debug 4.6 CSV > 0");
						// open(punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + csvList[l]);
						latestCSV = punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + csvList[l];
						// print("open: " + punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + csvList[l]);
						// print("csvList["+l+"]: " + csvList[l]);
		
						
						tableLength = nResults();
						for (m = 0; m < tableLength; m++) {
 							// print("Debug 4.6");
							
							setResult("Bad Puncta", m, 0);
							
							area = getResult("Area", m);
							circ = getResult("Circ.", m);
							AR = getResult("AR", m);
							
							// print("area: " + area);
							// print("circ: " + circ);
							// print("AR: " + AR);
							// print("areaUserSetting[" + i + "]: " + areaUserSetting[i]);
							// print("circUserSetting[" + i + "]: " + circUserSetting[i]);
							// print("arUserSetting[" + i + "]: " + arUserSetting[i]);
							
							
							if (area > areaUserSetting[i] || circ < circUserSetting[i] || AR > arUserSetting[i]) {
								// print("Debug 4.7 Set as bad punctum");
								// print("");
								setResult("Bad Puncta", m , 1);
							}
							else {
								
							}
							
						}
						
						// print("Debug 4.8");
						saveAs("Results", punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + csvList[l]);
						//print("current csvList[l]: " + csvList[l]);
						close(csvList[l]);
						//close("*.csv");
						
						print("     Analyzing puncta in slice: '" + csvList[l] + "'  ( " + tempTicker+1 + " of " + tickerTotal + " )");
					}
					tempTicker++;
				}
			}
	
		}
	}
	
	print("Part 4 Complete");
	print("");
	
	
	
	// waitForUser("Part 4 Complete");
	
	
	
	
	
	
	
	
	
	// Part 5 Segmenter
	close("*");
	print("Part 5: Segmenting ROIs tagged in Part 4");
	setBatchMode(false);
	
	// parameters for bad puncta:
	//1. Area>4
	//2. Circularity<0.65
	//3. Aspect ratio>2.5
	channelList=getFileList(punctaMeasureDir);
	Array.sort(channelList);
	
	totalExpansionRounds = 0;
	
	
	tempTicker = 0;
	tickerTotal = 0;
	// Calculate the total number of slices
	for (i = 0 + dontSegmentCh1; i < channelList.length - dontSegmentCh2; i++) {
		imageFolderList=getFileList(punctaMeasureDir + channelList[i]);
		Array.sort(imageFolderList);
		
		for (j = 0; j < imageFolderList.length ; j++) {
			hemisomiteList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j]);
			Array.sort(hemisomiteList);
			
			for (k = 0; k < hemisomiteList.length; k++) {
				csvList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k]);
				Array.sort(csvList);
				
				newTickerTotal = csvList.length;
				tickerTotal = tickerTotal + newTickerTotal;
			}
		}
	}
	
	for (i = 0 + dontSegmentCh1; i < channelList.length - dontSegmentCh2; i++) { // Loop through the channels
		// print("Debug 5.1 i= " + i);
		imageFolderList=getFileList(punctaMeasureDir + channelList[i]);
		Array.sort(imageFolderList);
		
		for (j = 0; j <imageFolderList.length ; j++) { // Loop through the images
			// print("Debug 5.2 j= " + j);
			hemisomiteList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j]);
			Array.sort(hemisomiteList);
			
			for (k = 0; k < hemisomiteList.length; k++) { // Loop through the hemisomites
				// print("Debug 5.3 k= " + k);
				csvList=getFileList(punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k]);
				Array.sort(csvList);
				
				for (l = 0; l < csvList.length; l++) { // Loop through each CSV (list of puncta)
					// print("Debug 5.4 l= " + l);
					
					
					
					
					rowCount = openCSV(punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + csvList[l]);
					
					getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
					
					if (rowCount == 0) { // If there are no rows in the CSV, then there are no puncta to analyze in the image, and no roi.zip to open
						// print("Debug 5.5");
						print("     Slice: '" + csvList[l] + "'  ( " + tempTicker+1 + " of " + tickerTotal + " ): No Puncta ( " + hour + ":" + minute + ":" + second + " )");
					}
					if (rowCount > 0) { // If there are  rows in the CSV, then there are puncta to analyze in the image, and a roi.zip to open
						// print("Debug 5.6");
						print("     Slice: '" + csvList[l] + "'  ( " + tempTicker+1 + " of " + tickerTotal + " ): " + rowCount -1 + " Puncta detected ( " + hour + ":" + minute + ":" + second + " )");
						Table.rename("Results", csvList[l]); // The csv opened by "openCSV" is called "Results" and is being renamed to csvList[l]
						punctaCount = Table.size;
						
						// Open current image ("Slice")
						sliceList = getFileList(sliceDir + channelList[i] + imageFolderList[j]);
						Array.sort(sliceList);
						open(sliceDir + channelList[i] + imageFolderList[j] + sliceList[l]);
						run("Gaussian Blur...", "sigma=1");
						
						// Open current ROI list
						roiList = getFileList(punctaRoiDir + channelList[i] + imageFolderList[j] + hemisomiteList[k]);
						Array.sort(roiList);
						currentRoi = getFileList(punctaRoiDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + roiList[l]);
						Array.sort(currentRoi);
						roiManager("open", punctaRoiDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + roiList[l] + currentRoi[0]);
						
						
						
						for (q = 0; q < punctaCount; q++) { // Process each puncta in the current CSV file (which lists the puncta)
															// punctaCount for a specific CSV file can grow as "bad puncta" are segmented into daughter puncta
															// punctaCount will be updated near the end of this for loop
							// print("Debug 5.7 q= " + q);
							selectWindow(csvList[l]);
							
							punctaState = Table.get("Bad Puncta", q); // Column "Bad Puncta" tags each puncta as "good" (==0) or "bad" (==1)
							
							if (punctaState == 0) { // found good puncta
								// print("Debug 5.8");
								// Good puncta don't need to be processed.
								getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
								print("          Punctum " + q + ": Segmentation not required ( " + hour + ":" + minute + ":" + second + " )");
							}
							
							if (punctaState == 1) { // found bad puncta. Bad Puncta need to be segmented
								// print("Debug 5.9");
								
								
								
								selectWindow(sliceList[l]);	// Select current slide's image
								roiManager("select", q);	// highlight ROI in ROI Manager matching our found bad puncta in the CSV
								
								// Count the maxima
								run("Clear Results");
								run("Find Maxima...", "prominence=10 output=List"); 	// "Find Maxima" with "output=Lists" returns a Results Table with coordinates of each maxima it found within our ROI
																						// Don't know what prominence=10 is, but it's default, so leave for now
								
								// The new results table lists the coordinates of the maxima within the bad puncta 
									// rename it to "Maxima List" and get the number of daughter pixels
								selectWindow("Results");
								Table.rename("Results", "Maxima List");
								selectWindow("Maxima List");
								daughterCount = Table.size;
								
								// print("Debug 5.9b daughterCount = " + daughterCount);
								
								
								if (daughterCount == 0 || daughterCount == 1) { // If 0 or only 1 maxima are detected within this punctum
																				// then overwrite it as a "good" one since it can't be segmented further
									// print("Debug 5.10");
									selectWindow(csvList[l]);
									Table.set("Bad Puncta", q, 0); 
									close("Maxima List"); // Close the "Maxima List" window since we won't need it any more
									getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
									print("          Punctum " + q + ": Segmentation not possible ( " + hour + ":" + minute + ":" + second + " )");
								}
								
								if (daughterCount >1) { // daughterCount > 1 means the current puncta CAN be segmented further. 
									// print("Debug 5.11");
									getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
									print("          Punctum " + q + ": Segmentation into " + daughterCount + " ( " + hour + ":" + minute + ":" + second + " )");
									
									
									selectWindow(csvList[l]);
									Table.set("Bad Puncta", q, 2); // Tag current puncta for deletion later (==2) after its daughter puncta are added to the CSV
										// Table = csvList[l]
									
									
									
									Table.create("Daughter Puncta"); 
									// Create 1 Table to store the coordinates of the pixels that make up each daughter puncta
										// 2 columns per daughter puncta, one for X coordinates, other for Y coordinate
										// Columns: X Daughter 1 | Y Daughter 1 | ... | X Daughter n | Y Daughter n
										// Row 0 is coordinates of the local maximum that defines the daughter puncta
										// Initially Row 1 will contain string "End" as End marker (think stop codon)
										// As daugther puncta expands, new X and Y coordiates are added to the column
										// while the "End" marker shifts down
									
									// Initialize "Daughter Puncta" table
									for (r = 0; r < daughterCount; r++) { // For each daughter punctum
										// print("Debug 5.12 r= " + r);
										// Get local maximum coordinates from "Maxima List"
										selectWindow("Maxima List");
										tempMaxX = Table.get("X", r); // Table = "Maxima List"
										tempMaxY = Table.get("Y", r); // Table = "Maxima List"
										
										
										// At Row 0 or "Daughter Puncta", store the coordinates of the local maximum coordinates for this daughter punctum
										selectWindow("Daughter Puncta");
										Table.set("X Daughter " + r, 0, tempMaxX);
										Table.set("Y Daughter " + r, 0, tempMaxY);
										Table.update;
										
										
										// At row 1, add an "End" tag for every column
										Table.set("X Daughter " + r, 1, "End");
										Table.set("Y Daughter " + r, 1, "End");
										Table.update;
										
										// Create an array with n indices for n daugher puncta
										daughterIndeces = newArray(daughterCount);
											// I think this can be deleted.
										
									}
									
									
									
									// Do Segmentation here
									
									// Algorithm segment the cluster region into individual "daughter puncta":
										// The cluster region ("bad roi") is the region of interest
										// Within it, each maxima defines the nucleation point from which a daughter puncta expand
										// according to the expansion algorithm
										
									// The expansion algorithm:
										// The expansion algorithm first loops through each neighbouring pixel,
										// then through every daughter pixel as a subloop.
										// In other words, 
									
									
									
									// Create temp image of same size as current image								
										// Fill image with white pixel
										// Fill bad puncta ROI with black
										// Set daughter maxima to different gray values
									// print("Debug 5.13");
									selectWindow(sliceList[l]);
									Stack.getDimensions(width, height, channels, slices, frames);
									getPixelSize(unit, pixelWidth, pixelHeight);
									pxPerMicron= 1/pixelWidth;
									newImage("Expansion Image", "8-bit white", width, height, 1);
									run("Set Scale...", "distance=" + pxPerMicron + " known=1 unit=micron");
									selectWindow("Expansion Image");
									roiManager("select", q);
									run("Set...", "value=0");
									for (u = 0; u < daughterCount; u++) {
										// print("Debug 5.14 u= " + u);
										selectWindow("Maxima List");
										tempMaxX = Table.get("X", u);
										tempMaxY = Table.get("Y", u);
										
										selectWindow("Expansion Image");
										setPixel(tempMaxX, tempMaxY, (u*5)+100);
										updateDisplay();
									}
									
									
									// print("Debug 5.15");
									// Expansion Vector Lists
										// adding these moderators to the currentX and currentY coordinates
										// will drive the expansionPixel to circle around the current pixel
										// clockwise, starting from top left
									expandVectorListX = newArray(-1, 0, 1, 1, 1, 0, -1, -1);
									expandVectorListY = newArray(-1, -1, -1, 0, 1, 1, 1, 0);
									expandVectorListName = newArray("Top Left", "Top", "Top Right", "Right", "Bottom Right", "Bottom", "Bottom Left", "Left");
									
									// index:				 0	 1	 2	 3	 4	 5	 6	 7
									// expandVectorListX	-1	 0	 1	 1	 1	 0	-1	-1
									// expandVectorListY	-1	-1	-1	 0	 1	 1	 1	 0
									// vector to not scan	 4	 5	 6	 7	 0	 1	 2	 3
									doNotScanList = newArray(4, 5, 6, 7, 0, 1, 2, 3);
									
									// about "doNotScanList"
									// Except for the pixels in row 0 of the "Daughter Puncta" table, each pixel is the result of an expansion
									// from a previous pixel that was part of that daughter pixel.
									// When we expand the from the current pixel, we should not check the pixel from which the current pixel originated
									// This done in the hopes that scanning only 7 of the 8 pixels around the current pixel will let the program run a bit faster 
									
									
									
									// Set initial Expansion Vector value for all maxima
									selectWindow("Daughter Puncta");
									for (u = 0; u < daughterCount; u++) { 
										// print("Debug 5.16 u = " + u);
										Table.set("Expand Vector Daughter " + u, 0, expandVectorListX.length); 
											// The "Expand Vector Daughter #" column records which of the 8 directions was used to expand into the current pixel
											// Since the maxima are not the result of an expansion, they are being set to =8, 
											
											// set Expand Vector Daughter s value for mother pixel as none of the listed indices 
											// Record expansion pixel's direction relative to current pixel
											// This is so that the initial pixel will scan all around itself
										Table.update;
									}
									// print("Debug 5.17");
									listEndTracker = newArray(daughterCount);
									// listEndTracker is an array that keeps track of the index where the "End" marker is located in the "Daughter Puncta" table for each daughter puncta
									// ex: listEndTracker[0] returns in which row the "End" marker is located for daughter punctum index 0
									
									
									// Initialize values for segmentation algorithm
									// Segmentation ends when canContinueList == 0;
											// As each daughter puncta grows, the pixels making up the daughter puncta are added to the list and the "End" marker shifts down
											// Segmentation ends when canContinueList == 0
											// This condition will be reached when the "End" marker is reached for all daughter puncta coordinate lists
									
									canContinueList = 1;
									listPosition = 0;
									while (canContinueList == 1) { // Segment the current punctum
										// print("Debug 5.18");
										canContinueList = 0; // Assume we reached the end of all Daughter Lists until we check them one by one
										expandVectorTicker = 0;
										
										for (expandVectorTicker = 0; expandVectorTicker < 8; expandVectorTicker++) {
											// print("Debug 5.19 expandVectorTicker = " + expandVectorTicker);
											expandModX = expandVectorListX[expandVectorTicker];
											expandModY = expandVectorListY[expandVectorTicker];
										
											// Scan and expand into surrounding pixels
											for (s = 0; s < daughterCount; s++) {
												// print("Debug 5.20 s = " + s);
												selectWindow("Daughter Puncta");
												
												atEnd = Table.get("X Daughter " + s, listPosition);
												
												if (isNaN(atEnd) == 0) { // if we have not reached the "End" of the list for daughter punctum n
													// print("Debug 5.21");
													canContinueList = 1; // If we are not at the end of any daughter Puncta, continue down the list
													
													selectWindow("Daughter Puncta");
													currentX = Table.get("X Daughter " + s, listPosition);
													currentY = Table.get("Y Daughter " + s, listPosition);
													currentDaughterExpandVector = Table.get("Expand Vector Daughter " + s, listPosition);
													selectWindow("Expansion Image");
													
													
													if (currentDaughterExpandVector == doNotScanList[expandVectorTicker]) { // do not scan the parent pixel of current pixel
														// print("Debug 5.22");
													}
													if (currentDaughterExpandVector != doNotScanList[expandVectorTicker]) { // Scan pixels that are not parent pixel of current pixel
														// print("Debug 5.23");
														// Check for for current pixel being on an edge
														if (currentX-1 > -1 && currentY-1 > -1 && currentX+1 < width && currentY+1 < height)  {
															// print("Debug 5.24");
															expansionPixel = getPixel(currentX+expandModX, currentY+expandModY);
															
															if (expansionPixel == 0) { // If expansionPixel is black (==0), expand into it and add it to the daughter puncta list
																// print("Debug 5.25");
																setPixel(currentX+expandModX, currentY+expandModY, (s*5)+100); // Colour the pixel we are expanding into the same colour as the daughter puncta
																updateDisplay();
																
																// Find the position in current column with "End" in it
																	// Replace "End" with newest expansion pixel
																	// Add "End" after the newest pixel
																selectWindow("Daughter Puncta");
																//foundEndTicker = 1;
																lookForEnd = 1;
																
																
																// Adding newest pixel coordinates to the correct columns in "Daughter Puncta" table
																while (lookForEnd == 1) {
																	// print("Debug 5.26");
																	foundEndVar = Table.get("X Daughter " + s, listEndTracker[s]);
																	
																	if(isNaN(foundEndVar)){ // if we found the "End" marker
																		// print("Debug 5.27");
																		lookForEnd = 0; // then stop the while loop that looks for the "End" marker
																		
																		Table.set("X Daughter " + s, listEndTracker[s], currentX+expandModX); // Add expansionPixel's X-coordinate to list
																		Table.set("Y Daughter " + s, listEndTracker[s], currentY+expandModY); // Add expansionPixel's Y-coordinate to list
																		Table.set("Expand Vector Daughter " + s, listEndTracker[s], expandVectorTicker); // Record expansion pixel's direction relative to current pixel
																		
																		Table.set("X Daughter " + s, listEndTracker[s] + 1, "End"); // Add new "End" marker
																		Table.set("Y Daughter " + s, listEndTracker[s] + 1, "End"); // Add new "End" marker
																		Table.update;
																	}
																	// print("Debug 5.28");
																	listEndTracker[s] = listEndTracker[s]+1; // Update the record on in which row the "End" marker is located for Daughter Punctum s in "listEndTracker[s]"
																}
																// print("Debug 5.29");
															}
															// print("Debut 5.30");
														}
														// print("Debug 5.31");
													}
													// print("Debug 5.32");
												}
												// print("Debug 5.33");
											}
											// print("Debug 5.34");
										
										}
										// print("Debug 5.35");
										listPosition = listPosition + 1;
										
										
										
										// Check if we should expand further
											// Continue expanding if "Bad puncta" still contains black pixel
										run("Measure"); 							// "Measure" command performed on the ROI being segmented and creates a results table with a single row
										minInMotherPuncta = getResult("Min", 0); 	// "Min" in row 0 contains brightness value of dimmest pixel in the ROI
										run("Clear Results"); 						// Clear results table to avoid conflicting with future measurements
										
										if (minInMotherPuncta > 0) {	// If the dimmest pixel is brighter than 0 (black), there is no more space to expand into within the ROI
											// print("Debug 5.36");
											canContinueList = 0;		// Stop the expansion while-loop
										}
										// print("Debug 5.37");
									} // Segmentation of current punctum is done
									
									// print("Debug 5.38");
									
									
									// Extract the ROI of the daughter puncta
										// Add them to ROI manager
										// Add them to CSV list of Puncta
											// Measure ROI (Especially: Area, Aspect Ratio, Circularity)
											// Assign them "Bad Puncta" status of 1 or 0
									for (v = 0; v < daughterCount; v++) {
										// print("Debug 5.39");
										// Get Dauther_n's centre of expansion
										selectWindow("Maxima List");						
										currentX= Table.get("X", v);
										currentY= Table.get("Y", v);
										
										// Select Daughter ROI
										selectWindow("Expansion Image");
										doWand(currentX, currentY);
										
										
										// Measure relevant properties and create a new row in CSV
										run("Clear Results");
										run("Measure");
										currentArea = getResult("Area", 0);
										currentCirc = getResult("Circ.", 0);
										currentAR = getResult("AR", 0);
										selectWindow(csvList[l]);
										currentTableLength = Table.size;
										Table.set("Area", currentTableLength, currentArea);
										Table.set("Circ.", currentTableLength, currentCirc);
										Table.set("AR", currentTableLength, currentAR);
										close("Results");
										
										// Assign a "Bad Puncta" Status to newest Daughter Puncta if they meet criteria
										if (currentArea > areaUserSetting[i] || currentCirc < circUserSetting[i] || currentAR > arUserSetting[i]) {
											// print("Debug 5.40");
											selectWindow(csvList[l]);
											Table.set("Bad Puncta", currentTableLength, 1);
										}
										
										// print("Debug 5.41");
										// Add to ROI Manager
										roiManager("add");
									}
									// print("Debug 5.42");
									close("Expansion Image");
								}
								// print("Debug 5.43");
							}
							// print("Debug 5.44");
							
							
							if (punctaState == 1) { // Close all daugher list tables
								// print("Debug 5.45");
								if (daughterCount > 1) {
									// print("Debug 5.46");
									selectWindow("Maxima List"); // Close Maxima List table
									run("Close");
									close("Maxima List");
									close("Daughter Puncta");
								}
								// print("Debug 5.47");
							}
							// print("Debug 5.48");
							
							// Update the "punctaCount" variable to reflect the current number of puncta in the CSV list
								// Includes the puncta that have been marked for deletion later and the new daughter puncta
							selectWindow(csvList[l]);
							punctaCount = Table.size; // updates Puncta count when adding daughter ROIs from segmentation
							
							totalExpansionRounds = totalExpansionRounds + 1;
						
						} // Repeat loop to analyze the next puncta on the list in this CSV
						
						// print("Debug 5.49");
						
						
						
						
						
						
						
						// All rows in CSV have now been analyzed.
							// From ROIManager, delete the ROIs that have been segmented.
						
						
						
						selectWindow(csvList[l]);
						Table.update;
						currentTableLength = Table.size;
						
						
						
						
						selectWindow(csvList[l]);
						wOffset = 0;
						
						columnList = newArray("Area", "Mean", "Min", "Max", "Major", "Minor", "Angle", "Circ.", "%Area", "AR", "Round", "Solidity", "Segment", "Bad Puncta");
						columnCount = columnList.length;
						// For use later to replace those repeating blocks of code and feed in elements of this array into Table.get and Table.set functions as column name 
						
						
						for (w = 0; w < currentTableLength; w++) { // Go down all rows in table
							selectWindow(csvList[l]);
							punctaState = Table.get("Bad Puncta", w);
							
							
							if (punctaState == 2) { // Row with bad punctum: do not copy row to new temp Table, delete ROI from roi manager, increase offset ticker
								roiManager("select", w);
								roiManager("delete");
								wOffset = wOffset + 1;
							}
						}
						
						// Save updated CSV
						selectWindow(csvList[l]);
						saveAs("Results", punctaMeasureDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + csvList[l]);
						
						
						// Save updated ROI List
						roiManager("deselect");
						roiManager("save", punctaRoiDir + channelList[i] + imageFolderList[j] + hemisomiteList[k] + roiList[l] + currentRoi[0]);
						roiManager("reset");
						
						
						// Close ROI Manager, images, and CSV
						roiManager("reset");
						close(sliceList[l]); // close current image
						close(csvList[l]);   // close current csv
					}
					tempTicker++;
				}
			}
		}
	}
	
	print("Part 5 Complete");
	print("");
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	// Part 6 Colocalization Counter
	print("Part 6: Calculating Colocalization");
	
	
	
	// Folder Hierarchy
	// Channel > Image > Hemisomite > Slices
	
	// Processing Hierarchy
	// Image > Hemisomite > Slice > Channel
	
	
	// print("Debug 6.0");
	
	tempTicker = 0;
	tickerTotal = 0;
	// Calculate the total number of slices
	
	imageList = getFileList(ch1SliceDir);
	Array.sort(imageList);
	for (a = 0; a < imageList.length; a++) {
		sliceList = getFileList(ch1SliceDir + imageList[a]);
		Array.sort(sliceList);
		newTickerTotal = sliceList.length;
		tickerTotal = tickerTotal + newTickerTotal;
	}
	
	roiManager("reset");
	
	run("Set Measurements...", "area mean min fit shape integrated area_fraction redirect=None decimal=3");
	
	
	for (a = 0; a < cziList.length; a++) { // Cycle through images
		hemisomiteList = getFileList(hemisomitesDir + hemisomitesDirImages[a]);
		Array.sort(hemisomiteList);
		
		// Get parameters from the original CZI files
		run("Bio-Formats Importer", "open=[" + cziDirectory + cziList[a] + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		Stack.getDimensions(width, height, channels, slices, frames);
		close("*");
		
		for (b = 0; b < hemisomiteList.length; b++) { // Cycle through hemisomites
			// print("Debug 6.2");
			// print("b = " + b + " of hemisomiteList.length = " + hemisomiteList.length);
			
			
			// Create a results with the following structure
				// Set all initial values to 0
				// Table with have the name of the hemisomite
			// Table Structure: 		
			// Colo Threshold 		|| Ch1_Single || Ch1_Colo || Ch1_Total || Ch2_Single || Ch2_Colo || Ch2_Total
			// Row0 (Colo > 0%)		|| 0		  || 0		  || 0		   || 0			 || 0		 || 0
			// Row1	(colo > 10%)	|| 0		  || 0		  || 0		   || 0			 || 0		 || 0
			// Row2 (Colo > 20%)	|| 0		  || 0		  || 0		   || 0			 || 0		 || 0
			// ...
			// Row10 (Colo = 100%)	|| 0		  || 0		  || 0		   || 0			 || 0		 || 0
				// The different rows list different "thresholds" at which a punctum is considered to be colocalized
				// The threshold is based on the area of a punctum that is covered by the other channel
				// At Row0 (Colo > 0%), a single pixel covered by the other channel counts as colocalization
				// At Row10 (Colo == 100%), the punctum is considered colocalized only if it is entirely covered by the other channel
			
			Table.create(hemisomiteList[b]); // Table has name in hemisomiteList[b]
			columnList = newArray("Colo Threshold", "Ch1_Single", "Ch1_Colo","Ch1_Total","Ch2_Single", "Ch2_Colo", "Ch2_Total"); // Name of column headers in an array
			for (c = 0; c < columnList.length; c++) {	// Create columns with names from columnList, and place value 0 at index 0
				Table.set(columnList[c], 0 , 0);
			}											
			rowList = newArray("Colo > 0%","Colo > 10%","Colo > 20%","Colo > 30%","Colo > 40%","Colo > 50%","Colo > 60%","Colo > 70%","Colo > 80%","Colo > 90%","Colo = 100%");
			Table.setColumn("Colo Threshold", rowList); // Set values in column "Colo Threshold"
			arrayOfZero = newArray(0,0,0,0,0,0,0,0,0,0,0);
			for (c = 1; c < columnList.length; c++) {
				Table.setColumn(columnList[c], arrayOfZero); // Set values in other columns to 0
			}
			
			
			
			
			// For both channels, create a black image with white representing the current channel's ROIs
			// Then generate a 3rd black and white image that shows white where both first images also had white ('and' operation)
			
			imageList = getFileList(ch1SliceDir);
			Array.sort(imageList);
			sliceList = getFileList(ch1SliceDir + "\\" + imageList[a]);
			Array.sort(sliceList);
			for (c = 0; c < sliceList.length; c++) { // Cycle through slices
				channelList= getFileList(sliceDir);
				
				// print report to user
				print("     Processing Image " + a+1 + " of " + cziList.length + ", Slice " + tempTicker + 1 + " of " + tickerTotal);
				
				// Create the black-with-white image for each channel
				for (d = 0; d < channelList.length; d++) {
					// print("Debug 6.4");
					// print("Debug 6.4 d = " + d + " of channelList.length = " + channelList.length);
					
					// create all these temporary variables now because Folder hierarchy does not match Processing hierarchy
					tempChannelList = getFileList(punctaRoiDir);
					Array.sort(tempChannelList);
					tempImgList = getFileList(punctaRoiDir + tempChannelList[d]);
					Array.sort(tempImgList);
					tempHemiSomiteList = getFileList(punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a]);
					Array.sort(tempHemiSomiteList);
					tempSliceList = getFileList(punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a] +"\\" + tempHemiSomiteList[b]);
					Array.sort(tempSliceList);
					tempCurrentSlice = getFileList(punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a] +"\\" + tempHemiSomiteList[b] +"\\"+ tempSliceList[c]);
					Array.sort(tempCurrentSlice);
						// FYI
						// Each slice is a folder rather than a file
						// If this folder contains a .zip file, that means there are ROIs in this slice to analyze
						// If this folder is empty, then there were no ROIs in this slice to analyze
						// This structure was chosen so that the number of objects (files or folders) representing slices is consistent
						// for the slices, binary, puncta measurements, and puncta ROI directories
					
					if (tempCurrentSlice.length == 0) { // If there are no files in this directory (no roi.zip file), then there are no puncta in this image. Create a pure black image
						// print("Debug 6.5 no ROI");
						newImage(tempChannelList[d], "8-bit black", width, height, 1);
						roiManager("reset");
					}
					if (tempCurrentSlice.length == 1) { // If there are files in the directory, then there are puncta in this image. 
														// Create a black image, then open the each ROI for this slice, and fill them with white pixels
						// print("Debug 6.5 has ROI");
						
						// Create black image
						newImage(tempChannelList[d], "8-bit black", width, height, 1); // 
						
						// Load ROIs and fill them with white
						roiManager("reset"); // Fill ROI regions with white
						roiManager("open", punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a] +"\\" + tempHemiSomiteList[b] +"\\"+ tempSliceList[c] +"\\"+ tempCurrentSlice[0]);
						for (e = 0; e < roiManager("count"); e++) { // Fill reach ROI in this slice with white
							// print("Debug 6.6");
							roiManager("select", e);
							run("Set...", "value=255");			
							
						}
					}
				}
				
				// Generate the image that shows white only in the pixels where the first 2 images had white
				imageCalculator("AND create", tempChannelList[d-2],tempChannelList[d-1]); 
				
				
				// print("Debug 6.7 Black and White Images ready");
				
				
				
				// Black-with-white images ready
				// For each channel, tally up the number of single puncta, colocalized puncta, and total puncta
					// Tally is per STACK (therefore, need to tally up across each slide of this stack)
				
				// For both channels in the current slice
				for (d = 0; d < channelList.length; d++) {
					
					
					
					// create all these temporary variables now because Folder hierarchy does not match Processing hierarchy
					tempChannelList = getFileList(punctaRoiDir);
					Array.sort(tempChannelList);
					tempImgList = getFileList(punctaRoiDir + tempChannelList[d]);
					Array.sort(tempImgList);
					tempHemiSomiteList = getFileList(punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a]);
					Array.sort(tempHemiSomiteList);
					tempSliceList = getFileList(punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a] +"\\" + tempHemiSomiteList[b]);
					Array.sort(tempSliceList);
					tempCurrentSlice = getFileList(punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a] +"\\" + tempHemiSomiteList[b] +"\\"+ tempSliceList[c]);
					Array.sort(tempCurrentSlice);
					
					// Check if we have any ROIs in this slice for this channel
					if (tempCurrentSlice.length == 0) { // if there are no ROI, do nothing
						// print("Debug 6.9 no ROI");
						// waitForUser("Debug 6.5 no ROI");
						// waitForUser("Debug 6.9");
					}
					if (tempCurrentSlice.length == 1) { // if there are ROIs, count the single, colo, and total
						// print("Debug 6.10 has ROI");
						
						
						// open the ROI file
						roiManager("reset");
						roiManager("open", punctaRoiDir + tempChannelList[d] +"\\"+ tempImgList[a] +"\\" + tempHemiSomiteList[b] +"\\"+ tempSliceList[c] +"\\"+ tempCurrentSlice[0]); 
						
						// Number of ROI in ROI file == number of puncta for this slice
						sumColoSingle = roiManager("count");
						// print("Debug 6.10 sumColoSingle = " + sumColoSingle);
						
						
						// Tally up total puncta count and update value in table
						selectWindow(hemisomiteList[b]);
						oldSumColoSingle = Table.get(columnList[3+(d*3)], 0);
						sumColoSingle = sumColoSingle + oldSumColoSingle;
						// print("Debug 6.10 oldSumColoSingle = " + oldSumColoSingle);
						// print("Debug 6.10 current Column = " + columnList[3+(d*3)]);
						// waitForUser("Debug 6.10");
						for (e = 0; e < 11; e++) {
							Table.set(columnList[3+(d*3)], e, sumColoSingle);
							Table.update;
							// waitForUser("Debug 6.10b");
						}
						
						
						
						// Analyze each individual punctum in this slice and see what % of their surface overlaps with a puncta from the other channel
						// Then categorize whether they fit under the "single punctum" or "colo punctum" column based on the threshold set by the row in the table 
						for (e = 0; e < roiManager("count"); e++) {
							// print("Debug 6.11");
							roiManager("select", e);
							
							run("Clear Results");
							run("Measure");
							areaPercent = getResult("%Area", 0); 	// The Image being analyzed is the black-with-white image that only shows white pixels where both channels had white pixels
																	// %Area returns area of this ROI (the punctum) that is white (overlaps with the other channel)
							
							selectWindow(hemisomiteList[b]); // Select the tally table (it is named hemisomiteList[b])
							
							// waitForUser("Debug 6.11");
							
							// Determine if current punctum counts as single or colo punctum based on areaPercent
							
							// area threshold from 0% to 90%
							for (f = 0; f < 10; f++) { 
								if (areaPercent <= f*10) { // areaPercent <= threshold, count as single punctum
									tableValue = Table.get(columnList[1+(d*3)], f);
									tableValue = tableValue + 1;
									Table.set(columnList[1+(d*3)], f, tableValue);
									Table.update;
									// waitForUser("Debug 6.11a");
								}
								if (areaPercent > f*10) { // areaPercent > threshold, count as colo punctum
									tableValue = Table.get(columnList[2+(d*3)], f);
									tableValue = tableValue + 1;
									Table.set(columnList[2+(d*3)], f, tableValue);
									Table.update;
									// waitForUser("Debug 6.11b");
								}
							}
							// Area threshold @ 100%
							if (areaPercent < 100) { // areaPercent < 100%, count as single punctum
								tableValue = Table.get(columnList[1+(d*3)], 10);
								tableValue = tableValue + 1;
								Table.set(columnList[1+(d*3)], f, tableValue);
								Table.update;
								// waitForUser("Debug 6.11c");
							}
							if (areaPercent == 100) { // areaPercent == 100%, count as colo punctum
								tableValue = Table.get(columnList[2+(d*3)], 10);
								tableValue = tableValue + 1;
								Table.set(columnList[2+(d*3)], f, tableValue);
								Table.update;
								// waitForUser("Debug 6.11d");
							}
							
							
							// waitForUser("Debug 6.6 has ROI");	
							// run("Set..." 255);
						}
					}
				}
				tempTicker = tempTicker + 1;
				
				close("*"); // close all images
			}
			
			// waitForUser("Debug 6.12a");
			//close("*");
			// waitForUser("Debug 6.12b");
			
			// Save Table_Colo_Puncta_Record
			selectWindow(hemisomiteList[b]); // select tally table
			saveAs("Results", coloResultDir + cziList[a] + "\\" + hemisomiteList[b] + ".csv"); // save tally table as CSV
			close(hemisomiteList[b] + ".csv"); // close tally table
			// waitForUser("Debug 6.13");
			
		}
	}
	
	print("Part 6 Complete");
	print("");
	
}


selectWindow("Log");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

print("Analysis started on: " + startYear + "-" + startMonth + "-" + startDayOfMonth + " at " + startHour + ":" + startMinute + ":" + startSecond);
print("Analysis ended on:   " + year + "-" + month + "-" + dayOfMonth + " at " + hour + ":" + minute + ":" + second);

saveAs("Text", settingsAndLogsDir + "Log of " + year + "-" + month + "-" + dayOfMonth + " at " + hour + "h" + minute + "m" + second + "s.txt");

close("ROI Manager");
close("Results");


print("Program Terminated");
beep();
















































