//
//  ScheduleTableViewController.h
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewController : UITableViewController
@property (strong,nonatomic) NSMutableArray * appointments;
-(void) passAppointments:(NSMutableArray *) appointments;

@end
