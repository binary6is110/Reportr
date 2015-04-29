//
//  ScheduleViewController.h
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppointmentModel.h"

@interface ScheduleViewController : UIViewController<UITextViewDelegate, UIScrollViewDelegate>
-(void) passAppointment:(AppointmentModel *) appointment;
@end
