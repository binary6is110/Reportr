//
//  ScheduleViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ScheduleViewController.h"
#import "MessageModel.h"
#import "ApplicationModel.h"
#import "ContactModel.h"


#define kKEYBOARD_OFFSET 80.0

@interface ScheduleViewController () 
@property (nonatomic,strong) AppointmentModel * aModel;
@property (strong, nonatomic) IBOutlet UILabel *contact_lbl;
@property (strong, nonatomic) IBOutlet UILabel *company_lbl;
@property (strong, nonatomic) IBOutlet UILabel *date_lbl;
@property (strong, nonatomic) IBOutlet UITextView *notes_tview;
@property (strong, nonatomic) IBOutlet UITextView *nextSteps_tview;
@property (strong, nonatomic) IBOutlet UIButton *routeBtn;
@property (strong, nonatomic) IBOutlet UIButton *callBtn;
@property (strong, nonatomic) IBOutlet UIView *meetingNotesBkgd;
@property (strong, nonatomic) IBOutlet UIView *nextStepsBkgrd;
@end

@implementation ScheduleViewController

static MessageModel *  mModel;
static ApplicationModel * appModel;

/* -(id) init: register notifications */
-(id) init {
    if ( self = [super init] )  {
       
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImageFlagWithSuccess:)
                                                 name:@"addImageComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoFlagWithSuccess:)
                                                 name:@"addVideoComplete" object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAudioFlagWithSuccess:)
                                                 name:@"addAudioComplete" object:nil];
 

    
    [[self.callBtn layer] setBorderWidth:1.0f];
    [[self.callBtn layer] setBorderColor:[appModel darkBlueColor].CGColor];
    [[self.routeBtn layer] setBorderWidth:1.0f];
    [[self.routeBtn layer] setBorderColor:[appModel darkBlueColor].CGColor];
    
    [[self.meetingNotesBkgd layer] setCornerRadius:5.0f];
    [[self.meetingNotesBkgd layer] setBorderWidth:1.0f];
    [[self.meetingNotesBkgd layer] setBorderColor:[appModel lightGreyColor].CGColor];
    
    [[self.nextStepsBkgrd layer] setCornerRadius:5.0f];
    [[self.nextStepsBkgrd layer] setBorderWidth:1.0f];
    [[self.nextStepsBkgrd layer] setBorderColor:[appModel lightGreyColor].CGColor];
}

/* -(void) viewWillDisappear:(BOOL)animated
    Tear down/unregister notifications*/
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    appModel=nil;
}

/* - (void)viewDidLoad 
    update fields to reflect selected appointment details
    Query Firebase data store to get contact information for appointment
    update view and set up text views for legibility */
- (void)viewDidLoad {
    [super viewDidLoad];
    appModel = [ApplicationModel sharedApplicationModel];
    mModel = [MessageModel sharedMessageModel];
    _aModel=appModel.appointment;
    mModel.appointmentId=_aModel.appointment_id;

    _nextSteps_tview.delegate=self;
    _nextSteps_tview.text=_aModel.next_steps;
    [_nextSteps_tview setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    [_nextSteps_tview scrollRangeToVisible:NSMakeRange(0,1)];
    
    _notes_tview.delegate=self;
    _notes_tview.text=_aModel.notes;
    [_notes_tview setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    [_notes_tview scrollRangeToVisible:NSMakeRange(0,1)];
    
    _company_lbl.text=_aModel.company;
    _date_lbl.text=_aModel.start_time;
    
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Contacts"];
    [query whereKey:@"contact_id" equalTo:_aModel.contactId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *contact, NSError *error) {
        if (!error ) {
            ContactModel * contactM = [[ContactModel alloc] initWithFirstName:contact[@"first_name"] lastName:contact[@"last_name"] company:contact[@"company"] address1:contact[@"address_1"] address2:contact[@"address_1"] city:contact[@"city"] state:contact[@"state"] zip:contact[@"zip"] contactId:contact[@"contact_id"] officePhone:contact[@"phone_office"] mobilePhone:contact[@"phone_mobile"]];
            [appModel setContact:contactM];
            _contact_lbl.text=  [NSString stringWithFormat:@"%@ %@", contact[@"first_name"],contact[@"last_name"]];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard/Textview
/* -(void)keyboardWillShow
    Notification handler: Prepares view for editing/keyboard showing*/
-(void)keyboardWillShow{
    // Animate the current view out of the way
   if (self.view.frame.origin.y >= 0){
        [self adjustView:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self adjustView:NO];
    }
}

/* -(void)keyboardWillHide 
     Notification handler: Restores view after editing/keyboard hiding. */
-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        [self adjustView:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self adjustView:NO];
    }
}

/*-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
    Hack to get keyboard to resign using done <enter>  */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

/* -(void)adjustView:(BOOL)upward
    Adjust the view up/down when the keyboard is shown or dismissed*/
-(void)adjustView:(BOOL)upward
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect rect = self.view.frame;
    if (upward){
        rect.origin.y -= kKEYBOARD_OFFSET;
        rect.size.height += kKEYBOARD_OFFSET;
    }
    else  {
        rect.origin.y += kKEYBOARD_OFFSET;
        rect.size.height -= kKEYBOARD_OFFSET;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark - Event Handlers

- (IBAction)callTouched:(id)sender {
    ContactModel*contactM=[appModel contact];
    [self makeCall:[contactM contact_phone_mobile]];
}

-(BOOL)makeCall:(NSString *)number
{
    NSString *readyNumber = [NSString stringWithFormat:@"tel:%@",number];
    NSURL *tel = [NSURL URLWithString:readyNumber] ;
    if([[UIApplication sharedApplication] canOpenURL:tel])
    {
        [[UIApplication sharedApplication] openURL:tel];
        return YES;
    }
    else
    {
        [self displayError:@"Error" withMessage:@"Sorry, cannot place phone call with this device"];
        return NO;
    }
}

#pragma mark -  Alerts
-(void) displayError:(NSString*)errorType withMessage:(NSString*)errorMessage {
    // display error on login failure
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorType message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)routeTouched:(id)sender {
    NSLog(@"need directions to latitude: %f longitude: %f",[[appModel appointment] latitude], [[appModel appointment] longitude],nil);
    
    CLLocation *location = [appModel currentLocation];
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    
    NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                     start.latitude, start.longitude, [[appModel appointment] latitude], [[appModel appointment] longitude] ];
    
  
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
}


#pragma mark - Asset Update Notifications

/**-(void) updateImageFlagWithSuccess: (NSNotification *)notification
     TODO: Update icon flag to reflect image for appointment */
-(void) updateImageFlagWithSuccess: (NSNotification *)notification{
    NSLog(@"ScheduleViewController::updateImageFlagWithSuccess, %@",notification.object);
    //[ setImage:[UIImage imageNamed:@"anyImageName"]];
     _aModel.hasImage=YES;
}

/**-(void) updateVideoFlagWithSuccess: (NSNotification *)notification
 TODO: Update icon flag to reflect video for appointment */
-(void) updateVideoFlagWithSuccess: (NSNotification *)notification{
    NSLog(@"ScheduleViewController::updateVideoFlagWithSuccess, %@",notification.object);
    _aModel.hasVideo=YES;
}

/**-(void) updateAudioFlagWithSuccess: (NSNotification *)notification
 TODO: Update audio flag to reflect video for appointment */
-(void) updateAudioFlagWithSuccess: (NSNotification *)notification{
    NSLog(@"ScheduleViewController::updateAudioFlagWithSuccess, %@",notification.object);
    _aModel.hasAudio=YES;
}



#pragma mark - Messaging
/** -(void) passAppointment: (AppointmentModel *) appointment
    Passes appointment object to view before segue
 */
-(void) passAppointment: (AppointmentModel *) appointment {
    //_aModel=appointment;
}

#pragma mark - Navigation
 /** -(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
 Unwind stub.
 */
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"ScheduleViewController::prepareForUnwind");
}


/* In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
