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

#import <Firebase/Firebase.h>
#import "LoginViewController.h"
#import "MapNavigationController.h"
#import "UserModel.h"

static NSString * const kEmail = @"kima@lopeznegrete.com";
static NSString * const kPassword = @"lnc2015";
static NSString * const kFirebaseURL = @"https://reportrplatform.firebaseio.com";

@interface LoginViewController ()
@property BOOL loginSuccess;
@property BOOL attemptInProgress;
@property (strong, nonatomic)UserModel * userModel;
@property (strong, nonatomic) Firebase *ref;
@property (strong, nonatomic) IBOutlet UITextField *user_tf;
@property (strong, nonatomic) IBOutlet UITextField *pass_tf;
@property (strong, nonatomic) IBOutlet UIButton *signin_btn;
- (IBAction)signIn:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user_tf.text=kEmail;
    _pass_tf.text=kPassword;
    _user_tf.delegate = self;
    _pass_tf.delegate = self;
    _attemptInProgress=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([[segue identifier] isEqualToString:@"loginToMapView"]) {
         MapNavigationController* mapViewController = [segue destinationViewController];
         [mapViewController passModel:_userModel];
     }
 }

 #pragma mark - Firebase Login
// attempt login
- (IBAction)signIn:(id)sender
{
    _loginSuccess=YES;
    //only accept one tap
    if(!_attemptInProgress)
    {
        [self attemptLogin:sender];
    }
}

-(void) updateSignInBtnUI
{
    if(_attemptInProgress)
    {
        _signin_btn.enabled=NO;
        _signin_btn.titleLabel.textColor = [UIColor grayColor];
    }
    else
    {
        _signin_btn.enabled=YES;
        _signin_btn.titleLabel.textColor = [UIColor whiteColor ];
    }
}

-(BOOL) attemptLogin:(id)sender
{   /*validation: username > "", password > ""*/
    _attemptInProgress=YES;
    [self updateSignInBtnUI];
    //don't try login if there are empty fields
    if ([_user_tf.text isEqualToString:@""]){
        [self displayError:@"Enter user name"];
        _loginSuccess=NO;
    }
     //don't try login if there are empty fields
    if (_loginSuccess && [_pass_tf.text isEqualToString:@""]){
        [self displayError:@"Enter password"];
        _loginSuccess=NO;
    }
    // only attempt login if username and password is present
    if( _loginSuccess) {
        Firebase *ref = [[Firebase alloc] initWithUrl:kFirebaseURL];
        [ref authUser:_user_tf.text password:_pass_tf.text withCompletionBlock:^(NSError *error, FAuthData *authData) {
            if (error) {
                // an error occurred while attempting login
                [self displayError:@"Unrecognized login credentials"];
                _loginSuccess=NO;
            } else {
                // user is logged in, check authData for data
                _loginSuccess=YES;
                Firebase * employees = [ [Firebase alloc] initWithUrl: [NSString stringWithFormat:@"%@/%@", kFirebaseURL, @"employees"]];
                [[employees queryOrderedByChild:@"employee_id"] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapShot) {
                    FQuery *queryRef = [[employees queryOrderedByChild:@"user_name"] queryEqualToValue:_user_tf.text];
                    [queryRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *querySnapshot) {
                        if(querySnapshot.childrenCount==1) {
                            for (FDataSnapshot* child in querySnapshot.children){
                                NSString *eId = child.value[@"employee_id"];
                                _userModel= [[UserModel alloc] initWithId:_user_tf.text andPassword:_pass_tf.text andEmployeeId:eId];
                                [self performSegueWithIdentifier:@"loginToMapView" sender:sender];
                            }                            
                        }
                        else {
                            [self displayError:[NSString stringWithFormat:@"Unable to retrieve data for %@.", _user_tf.text]];
                            _loginSuccess=NO;
                            
                        }
                    }];
                }];
            }
        }];
    }
    _attemptInProgress=NO;
    [self updateSignInBtnUI];
    return _loginSuccess;
}

#pragma mark -  Alerts
-(void) displayError:(NSString*)errorMessage {
    // display error on login failure
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - TextField
// dismiss keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
