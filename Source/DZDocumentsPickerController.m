
//
//  DZDocumentsPickerController.h
//  DZDocumentsPickerController
//
//  Created Ignacio Romero Zurbuchen on 12/27/11.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "DZDocumentsPickerController.h"

#define RowHeight 56.0
#define LargerRowHeight 75.0

@implementation DZDocumentsPickerController
@synthesize delegate, tableview, documentType, deviceType, includePhotoLibrary, allowEditing;
@synthesize contentHeight, sharedFilesList, cloudFilesDict, netReach;
@synthesize servicesManager, availableServices;

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCheckout) name:@"DROPBOX_LINKED" object:nil];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    alrtCenter = [[DZAlertCenter alloc] init];
    
    self.netReach = [Reachability reachabilityForInternetConnection];
	[netReach startNotifier];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    viewController.navigationController.navigationBar.tintColor = [UIColor blackColor];
    viewController.navigationController.navigationBar.delegate = self;
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    navigationController.toolbar.tintColor = [UIColor colorWithWhite:0.1 alpha:1];
    navigationController.navigationBarHidden = YES;
    navigationController.toolbarHidden = NO;
    
    float controlWidth = self.contentSizeForViewInPopover.width-40;
    if (deviceType == DeviceTypeiPhone) segmentedItems = [NSMutableArray arrayWithObjects:@"Photos",@"Cloud",@"iTunes", nil];
    else segmentedItems = [NSMutableArray arrayWithObjects:@"Photos Library",@"Cloud Services",@"Shared Folder", nil];
    
    if (!includePhotoLibrary) [segmentedItems removeObjectAtIndex:0];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [UIColor darkGrayColor];
    segmentedControl.selectedSegmentIndex = 0;
    
    segmentedControl.frame = CGRectMake(0.0f, 0.0f, controlWidth, 30.0f);
    [segmentedControl setCenter:CGPointMake(self.contentSizeForViewInPopover.width/2, navigationController.toolbar.frame.size.height/2)];
    [navigationController.toolbar addSubview:segmentedControl];
    
    [self.view addSubview:navigationController.view];
    [self segmentAction:segmentedControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)segmentAction:(id)sender
{
    UISegmentedControl *segmentedController = (UISegmentedControl *)sender;
    currentSegment = segmentedController.selectedSegmentIndex;
    
    if (!includePhotoLibrary) currentSegment++;
    depthLevel = [NSNumber numberWithInt:0];

    NSLog(@"currentSegment = %d",currentSegment);
    
    if (currentSegment == 0 && includePhotoLibrary)
    {
        if (docsTimer)
        {
            [docsTimer invalidate];
            docsTimer = nil;
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary |
                                                            UIImagePickerControllerSourceTypeSavedPhotosAlbum)])
        {
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            pickerController.title = [segmentedItems objectAtIndex:currentSegment];
            pickerController.navigationItem.rightBarButtonItems = nil;
            pickerController.navigationBar.tintColor = [UIColor blackColor];
            //[pickerController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_Pattern.png"] forBarMetrics:UIBarMetricsDefault];
            
            if (self.documentType == DocumentTypeImages)
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                }
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                {
                    pickerController.sourceType = pickerController.sourceType | UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                }
            }
            
            /*
            if (self.documentType == DocumentTypeAll)
            {
                pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum | UIImagePickerControllerSourceTypeCamera;
            }
            else if (self.documentType == DocumentTypeVideo)
            {
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else if (self.documentType == DocumentTypeImages)
            {
                pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            */
            
            pickerController.allowsEditing = allowEditing;
            pickerController.delegate = self;
            //pickerController.navigationBarHidden = YES;
            
            [navigationController setViewControllers:[NSArray arrayWithObject:pickerController]];
        }
    }
    else
    {
        if (currentSegment == 1)
        {
            if (docsTimer)
            {
                [docsTimer invalidate];
                docsTimer = nil;
            }
            
            [self setCloudFilesDict:nil];
            cloudFilesDict = [[NSMutableDictionary alloc] init];
        }
        else if (currentSegment == 2)
        {
            [self performSelectorOnMainThread:@selector(fillUpSharedController) withObject:nil waitUntilDone:YES];
            
            docsTimer = nil;
            docsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkOutSharedController) userInfo:nil repeats:YES];
            [docsTimer fire];
        }
        
        UITableViewController *tableVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        tableVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        tableVC.title = [segmentedItems objectAtIndex:currentSegment];
        tableVC.view.backgroundColor = [UIColor whiteColor];
        tableVC.navigationController.navigationBar.delegate = self;
        
        tableVC.tableView.rowHeight = RowHeight;
        tableVC.tableView.showsVerticalScrollIndicator = YES;
        tableVC.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        tableVC.tableView.delegate = self;
        tableVC.tableView.dataSource = self;
        
        navController = [[UINavigationController alloc] initWithRootViewController:tableVC];
        navController.navigationBar.tintColor = [UIColor blackColor];
        navController.navigationBarHidden = NO;
        //[navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_Pattern.png"] forBarMetrics:UIBarMetricsDefault];
        navController.toolbarHidden = YES;
        navController.delegate = self;
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPicker:)];
        tableVC.navigationItem.rightBarButtonItem = cancelBtn;
        
        self.navigationController.navigationBar.delegate = self;
        [navigationController setViewControllers:[NSArray arrayWithObject:navController]];
    }
    
    
    NSLog(@"[[navigationController viewControllers] count] = %d",[[navigationController viewControllers] count]);
}

- (void)cancelPicker:(id)sender
{
    if (docsTimer)
    {
        [docsTimer invalidate];
        docsTimer = nil;
    }
    
    if ([delegate respondsToSelector:@selector(dismissPickerController:)])
        [delegate dismissPickerController:self];
}

- (void)checkOutSharedController
{
    [self performSelectorOnMainThread:@selector(fillUpSharedController) withObject:nil waitUntilDone:YES];
    [tableview reloadData];
}

- (void)fillUpSharedController
{
    [self setSharedFilesList:nil];
    sharedFilesList = [[NSMutableArray alloc] init];
    
    NSString *documentsPath = [NSString getDocumentsDirectoryForFile:@"/"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentsPath])
    {
        NSArray *contentsOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
        
        for (int i = 0; i < [contentsOfDirectory count]; i++)
        {
            NSString *fileName = [contentsOfDirectory objectAtIndex:i];
            if ([DZDocument getDocumentsTypeOfFile:fileName] == documentType || documentType == DocumentTypeAll)
            {
                [sharedFilesList addObject:fileName];
            }
        }
    }
    else [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)checkServiceSupport:(int)index
{
    for (NSNumber *number in availableServices)
    {
        if (index == [number intValue]) return YES;
    }
    
    return NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentSegment == 1)
    {
        if ([depthLevel intValue] == 0) return [[DZServicesManager servicesSupported] count];
        int filesCount = [[cloudFilesDict objectForKey:depthLevel] count];
        if (filesCount > 0) return filesCount;
        else return 3;
    }
    if (currentSegment == 2)
    {
        if ([sharedFilesList count] > 0) return [sharedFilesList count];
        else return 3;
    }
    
    return 0;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentSegment == 1 && [depthLevel intValue] == 0) return LargerRowHeight;
    else return RowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    int nodeCount = 0;
    if (currentSegment == 1) nodeCount = [[cloudFilesDict objectForKey:depthLevel] count];
    else if (currentSegment == 2) nodeCount = [sharedFilesList count];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.userInteractionEnabled = YES;
    cell.clipsToBounds = YES;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.clearsContextBeforeDrawing = YES;
    }
    
    if (nodeCount > 0)
    {
        if (currentSegment == 1)
        {
            for (UIView *view in cell.contentView.subviews) [view removeFromSuperview];
            
            NSArray *filesList = [cloudFilesDict objectForKey:depthLevel];
            DZDocument *document = [filesList objectAtIndex:indexPath.row];
            //DBMetadata *fileMetaData = [filesList objectAtIndex:indexPath.row];
            
            if (document.isDirectory)
            {
                NSString *fileName = document.name;
                NSString *name = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[document.name pathExtension]] withString:@""];
                cell.textLabel.text = name;
                cell.textLabel.textColor = [UIColor blackColor];
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.textLabel.text = document.name;
                cell.textLabel.textColor = [UIColor darkGrayColor];
                cell.detailTextLabel.text = document.size;
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.imageView.image = [DZDocument getIconDocumentsTypeOfFile:document.name];
        }
        else if (currentSegment == 2)
        {
            NSString *fileName = [sharedFilesList objectAtIndex:indexPath.row];
            NSString *name = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[fileName pathExtension]] withString:@""];
            name = [[NSString cleanWhiteSpacesFrom:name] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            name = [NSString convertToUTF8Entities:name];
            cell.textLabel.text = name;
            
            cell.imageView.frame = CGRectMake(0, 0, RowHeight, RowHeight);
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.autoresizesSubviews = NO;
            cell.imageView.clipsToBounds = YES;
            cell.imageView.backgroundColor = [UIColor clearColor];
            
            if (self.documentType == DocumentTypeImages)
            {
                NSString *filePath = [NSString getDocumentsDirectoryForFile:[sharedFilesList objectAtIndex:indexPath.row]];
                UIImage *cellImg = [UIImage imageWithContentsOfFile:filePath];
                if ([cellImg hasAlpha]) cellImg = [cellImg fillAlphaWithColor:[UIColor whiteColor]];
                cell.imageView.image = [cellImg imageByScalingProportionallyToSize:CGSizeMake(60, 60)];
            }
            else if (self.documentType == DocumentTypeMSOffice || self.documentType == DocumentTypePDF || self.documentType == DocumentTypeAll)
            {
                cell.imageView.image = [DZDocument getIconDocumentsTypeOfFile:fileName];
            }
        }
    }
    else
    {
        if (currentSegment == 1 && [depthLevel intValue] == 0)
        {
            cell = [self buildServiceCell:tableView withIndexPath:indexPath];
            NSLog(@"cell = %@",cell.description);
            
            return cell;
        }
        else if (currentSegment == 1 && indexPath.row == 2)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 ,self.view.frame.size.width, RowHeight)];
            
            if ([depthLevel intValue] > 0) label.text = @"No Compatible Files Found.";
            else if ([depthLevel intValue] == 0) label.text = @"Loading Your Files...";
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.textAlignment = UITextAlignmentCenter;
            label.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:label];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (currentSegment == 2 && indexPath.row == 2)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 ,self.view.frame.size.width, RowHeight)];
            label.text = @"No Compatible Files Found.";
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.textAlignment = UITextAlignmentCenter;
            label.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:label];
        }
    }

    return cell;
}

- (DZServiceTableViewCell *)buildServiceCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DZServiceTableViewCell";
    DZServiceTableViewCell *serviceCell = (DZServiceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (serviceCell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DZServiceTableViewCell" owner:self options:nil];
        for (id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[DZServiceTableViewCell class]])
            {
                serviceCell = (DZServiceTableViewCell *)currentObject;
                [serviceCell setClipsToBounds:YES];
            }
        }
    }
    
    NSString *cloudName = [[DZServicesManager servicesSupported] objectAtIndex:indexPath.row];
    NSString *cloudImgName = [[NSString stringWithFormat:@"logo_%@.png",cloudName] lowercaseString];
    serviceCell.logoImgView.image = [UIImage imageNamed:cloudImgName];
    
    if ([self checkServiceSupport:indexPath.row])
    {
        serviceCell.accessoryType = UITableViewCellAccessoryNone;
        serviceCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else
    {
        serviceCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [serviceCell.logoImgView setAlpha:0.25];
    }
    
    return serviceCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentSegment == 1)
    { 
        if ([depthLevel intValue] > 0)
        {
            NSArray *filesList = [cloudFilesDict objectForKey:depthLevel];
            DZDocument *document = [filesList objectAtIndex:indexPath.row];
            
            if (servicesManager.currentService == ServiceTypeDropbox)
            {
                if (document.isDirectory)
                {
                    [servicesManager loadFilesAtPath:document.path];
                    
                    NSString *fileName = document.name;
                    NSString *name = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[document.name pathExtension]] withString:@""];

                    UITableViewController *tableVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
                    tableVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                    tableVC.title = name;
                    tableVC.view.backgroundColor = [UIColor whiteColor];
                    tableVC.view.tag = [depthLevel intValue]+1;
                    
                    tableVC.tableView.rowHeight = RowHeight;
                    tableVC.tableView.showsVerticalScrollIndicator = YES;
                    tableVC.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
                    tableVC.tableView.delegate = self;
                    tableVC.tableView.dataSource = self;
                    
                    vController = tableVC;
                }
                else
                {
                    if ([self isNetworkReachable])
                    {
                        isDownloading = YES;
                        
                        NSString *localPath = [NSString getCacheDirectoryForFile:document.name];
                        NSString *webPath = document.path;

                        [servicesManager setDownloadingFileInfo:nil];
                        servicesManager.downloadingFileInfo = [[NSDictionary alloc] initWithObjectsAndKeys:document.name,@"filename",
                                                              webPath,@"webPath",localPath,@"localPath",nil];
                        [servicesManager downloadFileAtPath:webPath intoLocalPath:localPath];
                    }
                    else [alrtCenter noInternetConnectionAlert];
                }
            }
            else if (servicesManager.currentService == ServiceTypeCloudApp)
            {
                if ([self isNetworkReachable])
                {
                    isDownloading = YES;
                    
                    NSString *localPath = [NSString getCacheDirectoryForFile:document.name];
                    NSString *webPath = document.path;
                    
                    [servicesManager setDownloadingFileInfo:nil];
                    servicesManager.downloadingFileInfo = [[NSDictionary alloc] initWithObjectsAndKeys:document.name,@"filename",
                                                          webPath,@"webPath",localPath,@"localPath",nil];
                    [servicesManager downloadFileAtPath:webPath intoLocalPath:localPath];
                }
                else [alrtCenter noInternetConnectionAlert];
            }
        }
        else
        {
            if ([self isNetworkReachable])
            {
                UITableViewController *tableVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
                tableVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                tableVC.view.backgroundColor = [UIColor whiteColor];
                tableVC.view.tag = [depthLevel intValue]+1;
                
                tableVC.tableView.rowHeight = RowHeight;
                tableVC.tableView.showsVerticalScrollIndicator = YES;
                tableVC.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
                tableVC.tableView.delegate = self;
                tableVC.tableView.dataSource = self;
                
                vController = tableVC;
                
                [self setServicesManager:nil];
                servicesManager = [[DZServicesManager alloc] initWithDelegate:appDelegate];
                servicesManager.delegate = self;
                servicesManager.allowedDocuments = documentType;
                servicesManager.parentViewController = tableVC.navigationController;
                servicesManager.currentService = indexPath.row;
                [servicesManager prepareForLogin];
                
                vController.title = [DZServicesManager serviceTypeToString:servicesManager.currentService];
            }
            else
            {
                [alrtCenter noInternetConnectionAlert];
            }
        }
    }
    else if (currentSegment == 2)
    {
        NSString *filePath = [NSString getDocumentsDirectoryForFile:[sharedFilesList objectAtIndex:indexPath.row]];
        
        NSString *fileName = [sharedFilesList objectAtIndex:indexPath.row];
        NSString *extension = [fileName pathExtension];
        NSString *name = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extension] withString:@""];
        
        id pickedFile;
        if ([DZDocument getDocumentsTypeOfFile:fileName] == DocumentTypeImages) pickedFile = (UIImage *)[UIImage imageWithContentsOfFile:filePath];
        else pickedFile = (NSData *)[NSData dataWithContentsOfFile:filePath];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: pickedFile,@"file",
                             extension,@"extension", name,@"name", nil];

        if ([delegate respondsToSelector:@selector(documentPickerController:didFinishPickingFileWithInfo:)])
            [delegate documentPickerController:self didFinishPickingFileWithInfo:dic];
        
        //[self cancelPicker:nil];
    }
    
    /*
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    for (int i = 0; i < [selectedRows count]; i++) [tableView deselectRowAtIndexPath:[selectedRows objectAtIndex:i] animated:YES];
     */
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"";
}

- (CGRect)frameForTableview
{
    float tableHeight = 0;
    if (deviceType == DeviceTypeiPad) tableHeight = self.contentSizeForViewInPopover.height-(navigationController.navigationBar.frame.size.height*2)-[[UIApplication sharedApplication] statusBarFrame].size.height;
    else tableHeight = self.view.frame.size.height-(navigationController.navigationBar.frame.size.height*2);
    CGRect tableRect = CGRectMake(vController.view.frame.origin.x, vController.view.frame.origin.y,
                                  self.view.frame.size.width, tableHeight);
    
    return tableRect;
}

#pragma mark - UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (currentSegment == 1)
    {
        if (viewController.view.tag < [depthLevel intValue])
        {
            [cloudFilesDict removeObjectForKey:depthLevel];
            depthLevel = [NSNumber numberWithInt:[depthLevel intValue]-1];
            NSLog(@"PopItem && depthLevel = %d",[depthLevel intValue]);
            NSLog(@"[cloudFilesDict count] = %d",[cloudFilesDict count]);
        }
        else NSLog(@"PushItem");
    }
    
    //Deselect Table Row / after "back" button
    if ([depthLevel intValue] == 0)
    {
        NSArray *selectedRows = [tableview indexPathsForSelectedRows];
        for (int i = 0; i < [selectedRows count]; i++) [tableview deselectRowAtIndexPath:[selectedRows objectAtIndex:i] animated:YES];
    }
    else
    {
        for (UIView *view in viewController.view.subviews)
        {
            if ([view isKindOfClass:[UITableView class]])
            {
                NSLog(@"Table found!!");
                UITableView *aTable = (UITableView *)view;
                NSArray *selectedRows = [aTable indexPathsForSelectedRows];
                for (int i = 0; i < [selectedRows count]; i++) [aTable deselectRowAtIndexPath:[selectedRows objectAtIndex:i] animated:YES];
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}


#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (info)
    {
        NSData *data;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            data = [NSData dataWithContentsOfURL:videoURL];
        }
        else
        {
            UIImage *pickedFile;
            if (allowEditing) pickedFile = [info objectForKey:UIImagePickerControllerEditedImage];
            else pickedFile = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            data = UIImagePNGRepresentation(pickedFile);
        }
        
        NSString *extension = [info objectForKey:UIImagePickerControllerMediaType];
        NSString *name = [info objectForKey:UIImagePickerControllerMediaMetadata];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:data,@"file",extension,@"extension",name,@"name",nil];
        
        //NSLog(@"data = %@",data);
        
        if ([delegate respondsToSelector:@selector(documentPickerController:didFinishPickingFileWithInfo:)])
            [delegate documentPickerController:self didFinishPickingFileWithInfo:dic];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([delegate respondsToSelector:@selector(dismissPickerController:)])
        [delegate dismissPickerController:self];
}


#pragma mark - DZServicesManagerDelegate Methods

- (void)servicesManager:(DZServicesManager *)manager didLoadFiles:(NSArray *)files
{
    NSLog(@"%s",__FUNCTION__);
    
    if (manager.currentService == ServiceTypeDropbox)
    {
        
    }
    else if (manager.currentService == ServiceTypeCloudApp)
    {
        
    }
    else if (manager.currentService == ServiceTypeSkyDrive)
    {
        
    }
    
    depthLevel = [NSNumber numberWithInt:[depthLevel intValue]+1];
    [cloudFilesDict setObject:files forKey:depthLevel];
    vController.view.tag = [depthLevel intValue];
    [navController pushViewController:vController animated:YES];
    
    NSLog(@"depthLevel = %d",[depthLevel intValue]);
    
    if (depthLevel == [NSNumber numberWithInt:1])
    {
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleDone target:manager action:@selector(logOut)];
        [logoutButton setTintColor:[UIColor colorWithRed:125/255.0 green:170/255.0 blue:255/255.0 alpha:1.0]];
        [vController.navigationItem setRightBarButtonItem:logoutButton animated:YES];
    }
}

- (void)servicesManager:(DZServicesManager *)manager didDownloadFile:(NSDictionary *)info
{
    NSLog(@"%s",__FUNCTION__);
    
    if (manager.currentService == ServiceTypeDropbox)
    {
        
    }
    else if (manager.currentService == ServiceTypeCloudApp)
    {
        
    }
    else if (manager.currentService == ServiceTypeSkyDrive)
    {
        
    }
    
    if ([delegate respondsToSelector:@selector(documentPickerController:didFinishPickingFileWithInfo:)])
        [delegate documentPickerController:self didFinishPickingFileWithInfo:info];
}

- (void)servicesManagerDidCancelDownload:(DZServicesManager *)manager
{
    NSLog(@"%s",__FUNCTION__);
    
    if (manager.currentService == ServiceTypeDropbox)
    {
        
    }
    else if (manager.currentService == ServiceTypeCloudApp)
    {
        
    }
    else if (manager.currentService == ServiceTypeSkyDrive)
    {
        
    }
}

- (void)servicesManagerDidCancelLogin:(DZServicesManager *)manager
{
    NSLog(@"%s",__FUNCTION__);
    
    if (manager.currentService == ServiceTypeDropbox)
    {
        
    }
    else if (manager.currentService == ServiceTypeCloudApp)
    {
        
    }
    else if (manager.currentService == ServiceTypeSkyDrive)
    {
        
    }
    
    
    UITableViewController *tableVC = (UITableViewController *)[navController.viewControllers objectAtIndex:0];
    NSArray *cells = [tableVC.tableView visibleCells];
    for (int i = 0; i < [cells count]; i++)
    {
        UITableViewCell *cell = [cells objectAtIndex:i];
        [cell setSelected:NO animated:YES];
    }
}

- (void)servicesManagerDidLogOut:(DZServicesManager *)manager
{
    NSLog(@"%s",__FUNCTION__);
    
    if (manager.currentService == ServiceTypeDropbox)
    {
        
    }
    else if (manager.currentService == ServiceTypeCloudApp)
    {
        
    }
    else if (manager.currentService == ServiceTypeSkyDrive)
    {
        
    }
    
    UIViewController *viewcontroller = [navController.viewControllers objectAtIndex:0];
    [navController popToViewController:viewcontroller animated:YES];
}


#pragma mark - Network Reachability 

- (BOOL)isNetworkReachable
{
	NetworkStatus netStatus = [self.netReach currentReachabilityStatus];
	BOOL connectionRequired = [self.netReach connectionRequired];
	
	if (((netStatus == ReachableViaWiFi) || (netStatus == ReachableViaWWAN)) && (!connectionRequired)) return YES;
	else return NO;
}


#pragma mark - UIInterface Rotation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


#pragma mark - View lifeterm

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end
