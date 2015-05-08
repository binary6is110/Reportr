//
//  ScheduleViewController.h
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppointmentModel.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ScheduleViewController : UIViewController<UITextViewDelegate, UIScrollViewDelegate,GMSMapViewDelegate>
- (IBAction)callTouched:(id)sender;
- (IBAction)routeTouched:(id)sender;

-(void) updateImageFlagWithSuccess: (NSNotification *)notification;
-(void) updateVideoFlagWithSuccess: (NSNotification *)notification;
-(void) updateAudioFlagWithSuccess: (NSNotification *)notification;

@end
