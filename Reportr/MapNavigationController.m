//
//  MapNavigationController.m
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "MapViewController.h"
#import "MapNavigationController.h"

@interface MapNavigationController ()
 @property MapViewController  * mapViewController;

@end

@implementation MapNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!_mapViewController)
    {   _mapViewController = (MapViewController*) self.visibleViewController;
        [_mapViewController passUserModel: _userModel];
    }
        
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



-(void) passModel:(UserModel*)model
{
    _userModel=model;
}

@end
