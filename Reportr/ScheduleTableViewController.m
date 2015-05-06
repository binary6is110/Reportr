//
//  ScheduleTableTableViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "AppointmentModel.h"
#import "ScheduleViewController.h"
#import "AppointmentTableViewCell.h"

@interface ScheduleTableViewController ()
@property (nonatomic,strong) ScheduleViewController*scheduleVController;
@property (nonatomic,strong) AppointmentModel*appointment;
@end

@implementation ScheduleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) passAppointments:(NSMutableArray *) appointments
{
    _appointments=appointments;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_appointments count];
}

-(NSString*)currentTimeAsString {
   NSDate *date = [NSDate date];
   NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
   timeFormatter.dateFormat = @"HH:mm";
   return [timeFormatter stringFromDate: date];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"apptCell" forIndexPath:indexPath];
    AppointmentModel * appt = (AppointmentModel*)[_appointments objectAtIndex:indexPath.row];   
    cell.textLabel.text=appt.start_time;
    cell.detailTextLabel.text=appt.company;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _appointment =(AppointmentModel*)[_appointments objectAtIndex:indexPath.row];
   // NSLog(@"didSelectRowAtIndexPath: appt name: %@",_appointment.company);
    [_scheduleVController passAppointment:_appointment];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetailView"]) {
        _scheduleVController = (ScheduleViewController*)[segue destinationViewController];
    }
}


@end
