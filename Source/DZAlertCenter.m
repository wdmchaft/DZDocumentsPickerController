
//
//  DZAlertCenter.h
//  DZDocumentsPickerController
//
//  Created Ignacio Romero Zurbuchen on 5/4/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "DZAlertCenter.h"

@implementation DZAlertCenter
@synthesize alert, alertMode, firstAction, secondAction, uploadProgressView;

- (void)alertWithTitle:(NSString *)title message:(NSString *)mssg cancelButtonTitle:(NSString *)cancelTitle withTarget:(id)target andSingleAction:(NSString *)selector
{
    if (selector) [self setupTarget:target andSelectors:[NSArray arrayWithObject:selector]];
    
    alert = [[UIAlertView alloc] initWithTitle:title message:mssg delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil];
    [alert show];
}

- (void)loadingAlertWithTitle:(NSString *)title message:(NSString *)mssg cancelButtonTitle:(NSString *)cancelTitle withTarget:(id)target andSingleAction:(NSString *)selector
{
    [self setupTarget:target andSelectors:[NSArray arrayWithObject:selector]];
    
    alert = [[UIAlertView alloc] initWithTitle:title message:mssg delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    
    [self setUploadProgressView:nil];
    uploadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 100.0f, 225.0f, 90.0f)];
    [uploadProgressView setProgressViewStyle:UIProgressViewStyleBar];
    [alert addSubview:uploadProgressView];
    
    [alert show];
}

- (void)loginActionAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle actionButtonTitle:(NSString *)actionTitle withTarget:(id)target andActions:(NSArray *)someSelectors;
{
    [self setupTarget:target andSelectors:someSelectors];
    
    alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:actionTitle,nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    UITextField *emailTxtField = [alert textFieldAtIndex:0];
    emailTxtField.placeholder = @"Email";
    UITextField *passwordTxtField = [alert textFieldAtIndex:1];
    passwordTxtField.placeholder = @"Password";
    
    [alert show];
}

- (void)setupTarget:(id)atarget andSelectors:(NSArray *)someSelectors
{
    actionTarget = nil;
    actionTarget = atarget;
    
    selectors = nil;
    selectors = someSelectors;
}

- (void)noActionAlertWithTitle:(NSString *)title withMessage:(NSString *)mssg withCancelButton:(NSString *)btnTitle
{
    alert = [[UIAlertView alloc] initWithTitle:title message:mssg delegate:nil cancelButtonTitle:btnTitle otherButtonTitles:nil];
    [alert show];
}






- (void)singleActionAlertWithTitle:(NSString *)title withMessage:(NSString *)mssg withCancelButton:(NSString *)btnTitle1 withApprovalButton:(NSString *)btnTitle2 withAction:(NSString *)notificationName
{
    alertMode = @"singleAction";
    firstAction = notificationName;
    alert = [[UIAlertView alloc] initWithTitle:title message:mssg delegate:self cancelButtonTitle:btnTitle1 otherButtonTitles:btnTitle2,nil];
    [alert show];
}

- (void)loadingActionAlertWithTitle:(NSString *)title withMessage:(NSString *)mssg withCancelButton:(NSString *)btnTitle1 andWithAction:(NSString *)notificationName
{
    alertMode = @"cancelAction";
    firstAction = notificationName;
    alert = [[UIAlertView alloc] initWithTitle:title message:mssg delegate:self cancelButtonTitle:btnTitle1 otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    
    [self setUploadProgressView:nil];
    uploadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 100.0f, 225.0f, 90.0f)];
    [uploadProgressView setProgressViewStyle:UIProgressViewStyleBar];
    [alert addSubview:uploadProgressView];
    
    [alert show];
}

- (void)noActionloadingnAlertWithTitle:(NSString *)title withMessage:(NSString *)mssg
{
    alert = [[UIAlertView alloc] initWithTitle:title message:mssg delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = CGPointMake(138.0, 120);
    [indicator startAnimating];
    [alert addSubview:indicator];
    
    [alert show];
}

- (void)noInternetConnectionAlert
{
    alertMode = @"noInternet";
    alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                              message:@"No Internet connection detected. Please check your Internet connection or try again later."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%s",__FUNCTION__);
    
    if (alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput)
    {
        if (buttonIndex == 0)
        {
            NSLog(@"CANCEL LOGIN");
            
            SEL selector = NSSelectorFromString([selectors objectAtIndex:0]);
            [actionTarget performSelector:selector];
        }
        else
        {
            NSLog(@"PROCEED LOGIN");
            
            UITextField *emailTxtField = [alertView textFieldAtIndex:0];
            UITextField *passwordTxtField = [alertView textFieldAtIndex:1];
            
            NSLog(@"email = %@",emailTxtField.text);
            NSLog(@"password = %@",passwordTxtField.text);
            
            SEL selector = NSSelectorFromString([selectors objectAtIndex:1]);
            [actionTarget performSelector:selector
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:emailTxtField.text,@"email",
                                           passwordTxtField.text,@"password",nil]];
        }
    }
    if (alertView.alertViewStyle == UIAlertViewStyleDefault)
    {
        if ([selectors count] > 0)
        {
            if ([selectors count] == 1)
            {
                SEL selector = NSSelectorFromString([selectors objectAtIndex:0]);
                //[actionTarget performSelector:selector];
                objc_msgSend(actionTarget,selector);
                
                /*
                 NSMethodSignature *methodSig = [[self class] instanceMethodSignatureForSelector:selector];
                 NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
                 [invocation setSelector:selector];
                 [invocation setTarget:actionTarget];
                 [invocation invoke];
                 */
            }
        }
    }
    
    
    
    /*
    if ((alertMode == @"singleAction" && buttonIndex == 1) || (alertMode == @"cancelAction" && buttonIndex == 0))
        [[NSNotificationCenter defaultCenter] postNotificationName:firstAction object:self];
    if (alertMode == @"doubleAction")
    {
        if (buttonIndex == 1) [[NSNotificationCenter defaultCenter] postNotificationName:firstAction object:self];
        else if (buttonIndex == 2) [[NSNotificationCenter defaultCenter] postNotificationName:secondAction object:self];
    }*/
}

- (void)closeAlertView
{
    if (alert)
    {
        [alert dismissWithClickedButtonIndex:0 animated:TRUE];
        alert = nil;
    }
}


@end
