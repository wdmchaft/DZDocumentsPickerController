
//
//  RootViewController.h
//  SimpleDocumentPicker
//
//  Created Ignacio Romero Zurbuchen on 4/16/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "DZDocumentsPickerController.h"

@interface ViewController : UIViewController <DZDocumentsPickerControllerDelegate>
{
    IBOutlet UIImageView *imgview;
    IBOutlet UIButton *button;
    
    
}

@property (nonatomic, strong) DZDocumentsPickerController *docPickerController;
@property (nonatomic, strong) UIPopoverController *popOverController;

- (IBAction)openDocumentsPicker:(id)sender;

@end
