
//
//  DZDocumentsPickerController.h
//  DZDocumentsPickerController
//
//  Created Ignacio Romero Zurbuchen on 12/27/11.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "DZServiceTableViewCell.h"
#import "DZServicesManager.h"
#import "DZDocument.h"
#import "DZAlertCenter.h"

#import "EGORefreshTableHeaderView.h"

#import <dispatch/dispatch.h>
#import "Reachability.h"

@protocol DZDocumentsPickerControllerDelegate;

enum DevicesType {DeviceTypeiPod = 0, DeviceTypeiPhone = 1, DeviceTypeiPad = 2};
typedef enum DevicesType DeviceType;

@interface DZDocumentsPickerController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                                            UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,
                                                            EGORefreshTableHeaderDelegate, DZServicesManagerDelegate>
{
    AppDelegate *appDelegate;
    DZAlertCenter *alrtCenter;
    
    EGORefreshTableHeaderView *refreshHeaderView;
    
    UINavigationController *navigationController;
    UINavigationController *navController;
    UITableViewController *tableController;
    NSMutableArray *segmentedItems;
        
    int currentSegment;
    BOOL isReloading;
    BOOL isDownloading;
    NSNumber *depthLevel;
    
    NSTimer *docsTimer;
}

@property (nonatomic, strong) id <DZDocumentsPickerControllerDelegate> delegate;
@property (nonatomic, assign) DocumentType documentType;
@property (nonatomic, assign) DeviceType deviceType;
@property BOOL includePhotoLibrary;
@property BOOL allowEditing;
@property float contentHeight;

@property (nonatomic, strong) DZServicesManager *servicesManager;
@property (nonatomic, strong) NSArray *availableServices;
@property (nonatomic, strong) NSString *cloudPath;

@property (nonatomic, strong) NSMutableArray *sharedFilesList;
@property (nonatomic, strong) NSMutableDictionary *cloudFilesDict;

@property (nonatomic, strong) Reachability *netReach;

- (void)segmentAction:(id)sender;
- (void)cancelPicker:(id)sender;
- (void)fillUpSharedController;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end


@protocol DZDocumentsPickerControllerDelegate <NSObject>
@required
- (void)documentPickerController:(DZDocumentsPickerController *)picker didFinishPickingFileWithInfo:(NSDictionary *)info;
@optional
- (void)dismissPickerController:(DZDocumentsPickerController *)picker;
@end


