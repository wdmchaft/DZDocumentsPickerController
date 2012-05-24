# DZDocumentsPickerController

iPhone/iPad controller to import file from multiple sources, such as Image Library, iTunes shared folder, and cloud services like Dropbox, Cloud App, iCloud, Google Drive, Microsoft SkyDrive, SugarSync, BOX, and many more.

Until now, only Dropbox and Cloud App are operational, and Microsoft SkyDrive is half-way in.

This idea was born because of a common need to all iOS users of importing documents regardless the source. I am sharing this controller so you can enjoy it in your own apps and collaborate with the development. You are very welcome to fork it or help me out with the debugging!

It is still a "work in progress" project, and I haven't yet took the time to document the code…Enjoy!

## Some Screenshots
![DZDocumentsPickerController](http://www.dzen.cl/github/DZDocumentsPickerController.jpg)

## How to use
DZDocumentsPickerController is intended to be very easy for you to implement.
There is a demo app, so you can take a quick look of how it looks and works.

### Step 1
```
Import "DZDocumentsPickerController.h" to your view controller subclass.
```

### Step 2
Instantiate the DZDocumentsPickerController class and give it the properties you mostly need.
- includePhotoLibrary: should the picker include Apple's UIImagePickerController, for accessing iOS' media library
- documentType: the set of documents supported
- allowEditing: if includePhotoLibrary is on, this tells the UIImagePickerController to allow edition mode.
- delegate: a must, so you can receive DZDocumentsPickerControllerDelegate's method.

Then insert the viewcontroller into an Apple's UIPopOverController, like so:
```
docPickerController = [[DZDocumentsPickerController alloc] init];
docPickerController.includePhotoLibrary = YES;
docPickerController.documentType = DocumentTypeAll;
docPickerController.allowEditing = NO;
docPickerController.delegate = self;
    
[docPickerController setContentSizeForViewInPopover:CGSizeMake(400, 600)];
docPickerController.deviceType = DeviceTypeiPad;
popOverController = [[UIPopoverController alloc] initWithContentViewController:docPickerController];
[popOverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
```

### Step 3
Call for DZDocumentsPickerControllerDelegate methods.
```
- (void)documentPickerController:(DZDocumentsPickerController *)picker didFinishPickingFileWithInfo:(NSDictionary *)info
{
    //Called when file has been selected and imported/downloaded successfully
}

- (void)dismissPickerController:(DZDocumentsPickerController *)picker
{
    //Called when dismissed the DZDocumentsPickerController
}
```

## Third party Frameworks and iOS Categories

DZDocumentsPickerController uses some official and unofficial Objective-C APIs to plug with cloud services, such as Dropbox, Cloud App and SkyDrive's:
- Official Dropbox SDK for iOS (https://www.dropbox.com/developers/reference/sdk)
- Forked version of the OpenSource Cloud App library (https://github.com/dzenbot/CloudAppSDK)
- Forked version of the Official Microsoft LiveSDK for iOS (https://github.com/dzenbot/MSLiveSDK)

DZDocumentsPickerController requires Apple's Reachability, but the ARC version from @tonymillion (https://github.com/tonymillion/Reachability)

DZDocumentsPickerController also needs DZEN_Categories, a collection of useful iOS categories (https://github.com/DZen-Interaktiv/DZEN_Categories). You are very welcome to contribute too!

## License
(The MIT License)

Copyright (c) 2012 Ignacio Romero Zurbuchen <iromero@dzen.cl>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.