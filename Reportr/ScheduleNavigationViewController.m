//
//  ScheduleNavigationViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ScheduleNavigationViewController.h"
#import "ApplicationModel.h"


@interface ScheduleNavigationViewController ()
@property ScheduleNavigationViewController  * scheduleTabVController;
//@property NSMutableArray*appointments;
@end

@implementation ScheduleNavigationViewController
static ApplicationModel * appModel;

- (void)viewDidLoad {
    [super viewDidLoad];
   /* if(!_scheduleTabVController)
    {
        _scheduleTabVController = (ScheduleNavigationViewController*) self.visibleViewController;
        [_scheduleTabVController passAppointments: _appointments];
    }*/
    appModel = [ApplicationModel sharedApplicationModel];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*-(void) passAppointments:(NSMutableArray*) appointments
{
  //  _appointments=appointments;
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
