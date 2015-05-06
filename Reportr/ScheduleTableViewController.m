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
#import "ApptTableViewCell.h"

@interface ScheduleTableViewController ()
@property (nonatomic,strong) ScheduleViewController*scheduleVController;
@property (nonatomic,strong) AppointmentModel*appointment;
@end

@implementation ScheduleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight=100.0;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ApptTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"apptCell" ];
    if(!cell){
        [tableView registerNib: [UINib nibWithNibName:@"ApptTableViewCell" bundle:nil] forCellReuseIdentifier:@"apptCell"];
        cell=[tableView dequeueReusableCellWithIdentifier:@"apptCell"];
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(ApptTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    AppointmentModel * appt = (AppointmentModel*)[_appointments objectAtIndex:indexPath.row];
    ApptTableViewCell*aCell = (ApptTableViewCell*) cell;
    [aCell setCompany:appt.company];
    [aCell setTime:[self formattedTime: appt.start_time]];
    [aCell setAgenda:appt.agenda];
    aCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([self shouldHighlightCell: indexPath.row])
    {
        //do stuff
        [aCell highlightCell];
    }
    else{
        [aCell resetCell];
    }
}

-(BOOL) shouldHighlightCell:(NSInteger)index{
    
    BOOL lastAppointmentEarlierThanNow = YES;
    BOOL nowEarlierThanNextAppointment = NO;
    
    AppointmentModel*lastAppt;
    AppointmentModel*thisAppt;

    // is the last appoitnment start time earlier than now?
    // is this appointment start time later than now?-> this time should be highlighted
    if(index>0)
    {
        lastAppt =[_appointments objectAtIndex:index-1];
        if ([self isThisTime:lastAppt.start_time earlierThanThisTime:[self currentTimeAsString]]) {
            NSLog(@" this time: %@ IS earlier than now: %@", lastAppt.start_time,[self currentTimeAsString] );
            lastAppointmentEarlierThanNow = YES;
        }else{
            lastAppointmentEarlierThanNow = NO;
        }
    }
    
    thisAppt =[_appointments objectAtIndex:index];
    if ([self isThisTime:[self currentTimeAsString] earlierThanThisTime:thisAppt.start_time]) {
        NSLog(@" this time: %@ IS earlier than now: %@", [self currentTimeAsString],thisAppt.start_time );
        nowEarlierThanNextAppointment = YES;
    }else{
        nowEarlierThanNextAppointment = NO;
    }    
    
    return (lastAppointmentEarlierThanNow && nowEarlierThanNextAppointment);
}

-(BOOL) isThisTime:(NSString*)time earlierThanThisTime:(NSString*)time2{
   
    NSArray * timeChunks = [time componentsSeparatedByString: @":"];
    int lastHours = (int)[timeChunks[0] integerValue];
    int lastMinutes = (int)[timeChunks[1] integerValue];
    
    NSArray * time2Chunks = [time2 componentsSeparatedByString: @":"];
    int nextHours = (int)[time2Chunks[0] integerValue];
    int nextMinutes = (int)[time2Chunks[1] integerValue];
    
    if(lastHours<nextHours)
        return YES;
    if(lastHours == nextHours && lastMinutes<nextMinutes)
        return YES;
    
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppointmentModel*appt = [_appointments objectAtIndex:indexPath.row];
    if(appt.hasVideo){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addVideoComplete" object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetVideoImage" object:nil];
    }
    
    if(appt.hasImage){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addImageComplete" object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetPhotoImage" object:nil];
    }
    
    if(appt.hasAudio){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addAudioComplete" object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetAudioImage" object:nil];
    }

    _appointment =(AppointmentModel*)[_appointments objectAtIndex:indexPath.row];
    [_scheduleVController passAppointment:_appointment];
}

#pragma mark - Utility
-(NSString*)currentTimeAsString {
    NSDate *date = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    return [timeFormatter stringFromDate: date];
}

-(NSString*)formattedTime:(NSString*)time {
    
    NSArray * timeChunks = [time componentsSeparatedByString: @":"];
    int hours = (int)[timeChunks[0] integerValue];
    int minutes = (int)[timeChunks[1] integerValue];
    NSString * suffix = @"AM";
    if (hours>=12){
        suffix = @"PM";
        if(hours>12)
            hours-=12;
    }
    return [NSString stringWithFormat:@"%d:%02d %@", hours, minutes, suffix, nil];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetailView"]) {
        _scheduleVController = (ScheduleViewController*)[segue destinationViewController];
    }
}


@end
