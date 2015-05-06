//
//  ScheduleViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ScheduleViewController.h"

#define kKEYBOARD_OFFSET 80.0

@interface ScheduleViewController () 
@property (nonatomic,strong) AppointmentModel * aModel;
@property (strong, nonatomic) IBOutlet UILabel *contact_lbl;
@property (strong, nonatomic) IBOutlet UILabel *company_lbl;
@property (strong, nonatomic) IBOutlet UILabel *date_lbl;
@property (strong, nonatomic) IBOutlet UITextView *notes_tview;
@property (strong, nonatomic) IBOutlet UITextView *nextSteps_tview;
@end

@implementation ScheduleViewController

/* -(id) init: register notifications */
-(id) init {
    if ( self = [super init] )  {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide)
                                                     name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImageIconWithSuccess:)
                                                     name:@"addImageComplete" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoIconWithSuccess:)
                                                     name:@"addVideoComplete" object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/* -(void) viewWillDisappear:(BOOL)animated
    Tear down/unregister notifications*/
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

/* - (void)viewDidLoad 
    update fields to reflect selected appointment details
    Query Firebase data store to get contact information for appointment
    update view and set up text views for legibility */
- (void)viewDidLoad {
    [super viewDidLoad];

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
}

- (IBAction)syncTouched:(id)sender {
}

- (IBAction)saveTouched:(id)sender {
}

#pragma mark - Asset Update Notifications

/**-(void) updateImageIconWithSuccess: (NSNotification *)notification
     TODO: Update icon image to reflect image for appointment */
-(void) updateImageIconWithSuccess: (NSNotification *)notification{
    NSLog(@"ScheduleViewController::updateImageIconWithSuccess, %@",notification.object);
}

/**-(void) updateVideoIconWithSuccessvid: (NSNotification *)notification
 TODO: Update icon image to reflect video for appointment */
-(void) updateVideoIconWithSuccess: (NSNotification *)notification{
    NSLog(@"ScheduleViewController::updateVideoIconWithSuccess, %@",notification.object);
}

#pragma mark - Messaging

/** -(void) passAppointment: (AppointmentModel *) appointment
    Passes appointment object to view before segue
 */
-(void) passAppointment: (AppointmentModel *) appointment {
    _aModel=appointment;
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
