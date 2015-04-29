//
//  MapViewController.h
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "UserModel.h"

@interface MapViewController : UIViewController
- (IBAction)showSchedule:(id)sender;
-(void) passUserModel:(UserModel *) userModel;
-(void) addDirections:(NSDictionary *) json;
@end
