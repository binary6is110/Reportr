//
//  LoginViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/20/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "MessageModel.h"
#import "ApplicationModel.h"

#import "LoginViewController.h"
#import "MapNavigationController.h"
#import "UserModel.h"

#define kKEYBOARD_OFFSET 90.0

@interface LoginViewController ()
@property BOOL loginSuccess;
@property BOOL attemptInProgress;
@property BOOL notificationsDone;
@property float viewY;
@property (strong, nonatomic) IBOutlet UITextField *user_tf;
@property (strong, nonatomic) IBOutlet UITextField *pass_tf;
@property (strong, nonatomic) IBOutlet UIButton *signin_btn;
- (IBAction)signIn:(id)sender;
@end

@implementation LoginViewController

static ApplicationModel * appModel;
static MessageModel *  mModel;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    mModel = [MessageModel sharedMessageModel];
    appModel = [ApplicationModel sharedApplicationModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow)
                                                     name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide)
                                                     name:UIKeyboardWillHideNotification object:nil];
    _viewY= (float)self.view.frame.origin.y;    
    
    [[_signin_btn layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[_signin_btn layer] setBorderWidth: 2.0f];
    
    _user_tf.text= mModel.getUserName;
    _pass_tf.text=mModel.getPassword;
    
    _user_tf.delegate = self;
    _pass_tf.delegate = self;
    _attemptInProgress=NO;
}

-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning: %@",@"LoginViewController");
}

 #pragma mark - Parse Login
// attempt login
- (IBAction)signIn:(id)sender {
    _loginSuccess=YES;
    //only accept one tap
    if(!_attemptInProgress){
        [self attemptLogin:sender];
    }
}

-(BOOL) attemptLogin:(id)sender {
    if(_attemptInProgress)
        return NO;
    /*validation: username > "", password > ""*/
    _attemptInProgress=YES;
    [self updateSignInBtnUI];
    //don't try login if there are empty fields
    if ([_user_tf.text isEqualToString:@""]){
         [mModel displayError:@"Login Error" withMessage:@"Enter user name"];
        _loginSuccess=NO;
    }
     //don't try login if there are empty fields
    if (_loginSuccess && [_pass_tf.text isEqualToString:@""]){
        [mModel displayError:@"Login Error" withMessage:@"Enter password"];
        _loginSuccess=NO;
    }
    // only attempt login if username and password is present
    if( _loginSuccess) {
        [PFUser logInWithUsernameInBackground:_user_tf.text password:_pass_tf.text
                                        block:^(PFUser *user, NSError *error) {
            if (user) {
                _loginSuccess=YES;
                PFObject*empId=[user valueForKey:@"employee_id"];
                PFQuery *query = [PFQuery queryWithClassName:@"Employees"];
                [query whereKey:@"employee_id" equalTo:empId.objectId];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *employee, NSError *error) {
                    if (!error ) {
                        appModel.user=[[UserModel alloc] initWithId:_user_tf.text andPassword:_pass_tf.text andEmployeeId:empId.objectId];
                        [self performSegueWithIdentifier:@"loginToMapView" sender:sender];
                    }
                }];
            } else {
                // The login failed. TODOCheck error to see why.
                [mModel displayError:@"Login Error" withMessage:@"Unrecognized login credentials"];
                _loginSuccess=NO;
            }
        }];
    }
    _attemptInProgress=NO;
    [self updateSignInBtnUI];
    return _loginSuccess;
}

-(void) updateSignInBtnUI {
    if(_attemptInProgress) {
        _signin_btn.enabled=NO;
        _signin_btn.titleLabel.textColor = [UIColor grayColor];
    } else {
        _signin_btn.enabled=YES;
        _signin_btn.titleLabel.textColor = [UIColor whiteColor];
    }
}

#pragma mark - Textfield delegate
/* -(void)keyboardWillShow
 Notification handler: Prepares view for editing/keyboard showing*/
-(void)keyboardWillShow{
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= _viewY){
        [self adjustView:YES];
    }
    else if (self.view.frame.origin.y < _viewY){
        [self adjustView:NO];
    }
}

/* -(void)keyboardWillHide
 Notification handler: Restores view after editing/keyboard hiding. */
-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= _viewY){
        [self adjustView:YES];
    }
    else if (self.view.frame.origin.y <_viewY){
        [self adjustView:NO];
    }
}

/* -(void)adjustView:(BOOL)upward
 Adjust the view up/down when the keyboard is shown or dismissed*/
-(void)adjustView:(BOOL)upward{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect rect = self.view.frame;
    if (upward){
        rect.origin.y -= kKEYBOARD_OFFSET;
        rect.size.height += kKEYBOARD_OFFSET;
    }   else  {
        rect.origin.y += kKEYBOARD_OFFSET;
        rect.size.height -= kKEYBOARD_OFFSET;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}

/*-(BOOL) textFieldShouldReturn:(UITextField *)textField
 Drop keyboard on done */
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"loginToMapView"]) {
    }
}


@end
