//
//  ScheduleTableTableViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "AppointmentModel.h"
#import "ApptTableViewCell.h"
#import "ApplicationModel.h"

@interface ScheduleTableViewController ()
@end

@implementation ScheduleTableViewController

static ApplicationModel * appModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    appModel = [ApplicationModel sharedApplicationModel];
    self.tableView.estimatedRowHeight=100.0;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [appModel.appointments count];
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
    AppointmentModel * appt = [appModel getAppointmentAtIndex:indexPath.row];
    ApptTableViewCell*aCell = (ApptTableViewCell*) cell;
    [aCell setCompany:appt.company];
    [aCell setTime:[appModel formattedTime: appt.start_time]];
    [aCell setAgenda:appt.agenda];
    aCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([self shouldHighlightCell: indexPath.row])
    {
        [aCell highlightCell];
    }
    else{
        [aCell resetCell];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppointmentModel*appt = [appModel getAppointmentAtIndex:indexPath.row];
    appModel.appointment=appt;
    
   /* if(appt.hasVideo){
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
    }*/
}

#pragma mark - Schedule Highlighting Logic
/* -(BOOL) shouldHighlightCell:(NSInteger)index
 Tests appointment time: if last appoitnment start time is earlier than now and
 this appointment start time is later than now, this appointment should be highlighted */
-(BOOL) shouldHighlightCell:(NSInteger)index{
    
    BOOL lastAppointmentEarlierThanNow = YES;
    BOOL nowEarlierThanNextAppointment = NO;
    AppointmentModel*lastAppt;
    AppointmentModel*thisAppt;
    if(index>0)    {
        lastAppt = [appModel getAppointmentAtIndex:index-1];
        if ([self isThisTime:lastAppt.start_time earlierThanThisTime:[appModel currentTimeAsString]]) {
            lastAppointmentEarlierThanNow = YES;
        }else{
            lastAppointmentEarlierThanNow = NO;
        }
    }
    thisAppt =[appModel getAppointmentAtIndex:index];
    if ([self isThisTime:[appModel currentTimeAsString] earlierThanThisTime:thisAppt.start_time]) {
        nowEarlierThanNextAppointment = YES;
    }else{
        nowEarlierThanNextAppointment = NO;
    }
    return (lastAppointmentEarlierThanNow && nowEarlierThanNextAppointment);
}

/*-(BOOL) isThisTime:(NSString*)time earlierThanThisTime:(NSString*)time2
 Helper method returns if time is earlier than time2. */
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




#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetailView"]) {
    }
}


@end
