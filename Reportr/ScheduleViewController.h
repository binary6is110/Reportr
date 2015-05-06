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


@interface ScheduleViewController : UIViewController<UITextViewDelegate, UIScrollViewDelegate>
-(void) passAppointment:(AppointmentModel *) appointment;
- (IBAction)callTouched:(id)sender;
- (IBAction)syncTouched:(id)sender;
- (IBAction)saveTouched:(id)sender;
-(void) updateImageIconWithSuccess: (NSNotification *)notification;
-(void) updateVideoIconWithSuccess: (NSNotification *)notification;
-(void) updateVideoStatusWithSuccess: (NSNotification *)notification;

@end
