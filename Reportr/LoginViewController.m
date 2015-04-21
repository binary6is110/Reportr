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


static NSString * const kEmail = @"kima@lopeznegrete.com";
static NSString * const kPassword = @"lnc2015";
static NSString * const kFirebaseURL = @"https://reportrplatform.firebaseio.com";

@interface LoginViewController ()
- (IBAction)signIn:(id)sender;
- (BOOL) attemptLogin;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL) attemptLogin
{
    BOOL loginSuccess;
    
    
    return loginSuccess;
}

- (IBAction)signIn:(id)sender {
    
    if ([self attemptLogin])
        NSLog ( @"success");
    else
        NSLog ( @"failure");
}
@end
