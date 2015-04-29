//
//  ScheduleViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/24/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ScheduleViewController.h"
#import <Firebase/Firebase.h>

#define kKEYBOARD_OFFSET 80.0

static NSString * const kFirebaseURL = @"https://reportrplatform.firebaseio.com";

@interface ScheduleViewController () 
@property (nonatomic,strong) AppointmentModel * aModel;
@property (strong, nonatomic) IBOutlet UILabel *contact_lbl;
@property (strong, nonatomic) IBOutlet UILabel *company_lbl;
@property (strong, nonatomic) IBOutlet UILabel *date_lbl;
@property (strong, nonatomic) IBOutlet UITextView *notes_tview;
@property (strong, nonatomic) IBOutlet UITextView *nextSteps_tview;
@end

@implementation ScheduleViewController

-(id) init
{
     NSLog(@"ScheduleViewController init");
    if ( self = [super init] ) {
       
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ScheduleViewController viewDidLoad");
    
    _company_lbl.text=_aModel.company;
    _date_lbl.text=_aModel.start_time;
    
    _nextSteps_tview.delegate=self;
    _notes_tview.delegate=self;
    
    _nextSteps_tview.text=_aModel.next_steps;
    [_nextSteps_tview setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    [_nextSteps_tview scrollRangeToVisible:NSMakeRange(0,1)];
    
    _notes_tview.text=_aModel.notes;
    [_notes_tview setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    [_notes_tview scrollRangeToVisible:NSMakeRange(0,1)];
    
    Firebase *ref = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", kFirebaseURL, @"contacts"]];
    [[[[ref queryOrderedByKey] queryStartingAtValue:_aModel.contactId] queryLimitedToFirst:1] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
         NSLog(@"%@ %@", snapshot.key, snapshot.value);
         _contact_lbl.text=  [NSString stringWithFormat:@"%@ %@", snapshot.value[@"first_name"],snapshot.value[@"last_name"]];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardWillShow:(NSNotification*)notification{
   
    // Animate the current view out of the way
   if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kKEYBOARD_OFFSET;
        rect.size.height += kKEYBOARD_OFFSET;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kKEYBOARD_OFFSET;
        rect.size.height -= kKEYBOARD_OFFSET;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}



#pragma mark - Communication
-(void) passAppointment: (AppointmentModel *) appointment
{
    NSLog(@"passApts");
    _aModel=appointment;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
