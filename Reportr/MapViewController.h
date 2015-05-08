//
//  MapViewController.h
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>


@interface MapViewController : UIViewController <GMSMapViewDelegate,CLLocationManagerDelegate>
- (IBAction)showSchedule:(id)sender;
-(void) addDirections:(NSDictionary *) json;
@end
