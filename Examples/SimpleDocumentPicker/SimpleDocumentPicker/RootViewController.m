
//
//  RootViewController.h
//  SimpleDocumentPicker
//
//  Created Ignacio Romero Zurbuchen on 4/16/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "RootViewController.h"

@implementation ViewController
@synthesize docPickerController, popOverController;

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)openDocumentsPicker:(id)sender
{
    [self setDocPickerController:nil];
    docPickerController = [[DZDocumentsPickerController alloc] init];
    docPickerController.includePhotoLibrary = YES;
    docPickerController.documentType = DocumentTypeImages;
    docPickerController.allowEditing = NO;
    docPickerController.delegate = self;
    docPickerController.availableServices = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ServiceTypeDropbox],[NSNumber numberWithInt:ServiceTypeCloudApp],nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        docPickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        docPickerController.deviceType = DeviceTypeiPhone;
        [self presentModalViewController:docPickerController animated:YES];
    }
    else
    {
        [docPickerController setContentSizeForViewInPopover:CGSizeMake(400, 600)];
        docPickerController.deviceType = DeviceTypeiPad;
        popOverController = [[UIPopoverController alloc] initWithContentViewController:docPickerController];
        [popOverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - UIDocumentsPickerControllerDelegate Methods

- (void)documentPickerController:(DZDocumentsPickerController *)picker didFinishPickingFileWithInfo:(NSDictionary *)info
{
    if (info)
    {
        if (picker.documentType == DocumentTypeImages ||
            picker.documentType == DocumentTypeAll)
        {
            NSData *data = [info objectForKey:@"file"];
            UIImage *file = [UIImage imageWithData:data];
            //NSString *extension = [info objectForKey:@"extension"];
            //NSString *name = [info objectForKey:@"name"];
            
            NSLog(@"file = %@",file);
            
            imgview.image = [file imageByScalingProportionallyToSize:imgview.frame.size];
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [popOverController dismissPopoverAnimated:YES];
    }
    
}

- (void)dismissPickerController:(DZDocumentsPickerController *)picker
{
    NSLog(@"%s",__FUNCTION__);
   
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [popOverController dismissPopoverAnimated:YES];
    }
}



- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    else return YES;
}

@end
