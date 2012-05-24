
//
//  AppDelegate.h
//  SimpleDocumentPicker
//
//  Created Ignacio Romero Zurbuchen on 4/16/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

#import <DropboxSDK/DropboxSDK.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

//Dropbox Session Universal Object
@property (nonatomic, strong) DBSession *session;
@property (nonatomic, strong) NSString *relinkUserId;

- (void)startDropboxSession;


- (id)getSettingsForObjectForKey:(NSString *)objKey;

@end
