//
//  AudioRecordPlayViewController.m
//  Reportr
//
//  Created by Kim Adams on 5/1/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "AudioRecordPlayViewController.h"
#import <Parse/Parse.h>

static int const kINIT=0;
static int const kRECORD = 1;
static int const kPLAY =2;
static int const kSTOP =3;

@interface AudioRecordPlayViewController ()

@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *timeLbl;
@property (strong, nonatomic) IBOutlet UILabel *maxLbl;
@property (strong, nonatomic) IBOutlet UILabel *minLbl;

- (IBAction)recordAudio:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
- (IBAction)cancelTouched:(id)sender;
- (IBAction)doneTouched:(id)sender;


@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain)	NSTimer	*updateTimer;

typedef void (^processAudio)(BOOL);
@end

@implementation AudioRecordPlayViewController{
    BOOL _isBarHide;
    BOOL isPlaying;
    BOOL isRecording;
    BOOL showPlayerUI;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    [self configureView];
    [self configureAudioSession];
    [self configureAudioRecorder];
}

/** - (void)updateViewForPlayerState:(AVAudioPlayer *)p
    Sets up view for playing intent */
- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
    [self toggleUI:showPlayerUI];
    [self updateCurrentTimeForPlayer:p];
    
    if (self.updateTimer)
        [self.updateTimer invalidate];
    
    if (p.playing)   {
        self.slider.value = 0;
        self.slider.maximumValue = p.duration;
        self.maxLbl.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self
                                                          selector:@selector(updateCurrentTime)
                                                          userInfo:p repeats:YES];
    }
    else  {
        self.updateTimer = nil;
    }
}
/** -(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
    Helper method to update view for player progress.*/
-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
    self.slider.value=p.currentTime;
    self.timeLbl.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
}

/** -(void)updateCurrentTime
    Selector for timer triggers helper method.*/
- (void)updateCurrentTime
{
    [self updateCurrentTimeForPlayer:self.audioPlayer];
}

/** - (void)updateViewForRecorderState:(AVAudioPlayer *)p
 Sets up view for recording intent */
- (void)updateViewForRecorderState:(AVAudioRecorder *)recorder
{
    [self toggleUI:showPlayerUI];
    [self updateCurrentTimeForRecorder:recorder];
    
    if (self.updateTimer)
        [self.updateTimer invalidate];
    
    if (recorder.recording)   {
        self.timeLbl.text = @"00:00";
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self
                                                          selector:@selector(updateRecordingTime)
                                                          userInfo:recorder repeats:YES];
    }
    else  {
        self.updateTimer = nil;
    }
}

/** -(void)updateCurrentTimeForRecorder:(AVAudioPlayer *)p
    Helper method to update view/reflect recording time.*/
-(void)updateCurrentTimeForRecorder:(AVAudioRecorder *)r
{
     self.timeLbl.text =[NSString stringWithFormat:@"%d:%02d", (int)r.currentTime / 60, (int)r.currentTime % 60, nil];
}

/** -(void)updateRecordingTime
 Selector for timer triggers helper method.*/
-(void) updateRecordingTime{
    
    [self updateCurrentTimeForRecorder:self.audioRecorder];

}


#pragma mark audio delegate methods
/** -(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
    At play end closes player. */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag == NO){
        //TODO: Catch error state
        NSLog(@"Playback finished unsuccessfully");
    }
    else {
        [player setCurrentTime:player.duration];
        [player pause];
        self.slider.value = self.slider.maximumValue;
        [self updateViewForPlayerState:player];
    }
}

/**-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
    TODO: Catch/handle error in player*/
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}


#pragma mark - Event Handlers
/** - (IBAction)recordAudio:(id)sender
      Handles Record intent */
- (IBAction)recordAudio:(id)sender {
    
    // close playing and toggle to record
    if(isPlaying)
    {
        isPlaying=NO;
        showPlayerUI=NO;
        [_audioPlayer pause];
    }
    if(!isRecording){
        
        isRecording = YES;
        showPlayerUI=NO;
        [_audioRecorder record];
        
        [self updateButtons:kRECORD];
        [self updateViewForRecorderState:_audioRecorder];
    }
}

/** - (IBAction)playAudio:(id)sender
       Handles Play intent*/
- (IBAction)playAudio:(id)sender {
    
    // close recording and toggle to play
    if(isRecording)
    {
        isRecording = NO;
         showPlayerUI=YES;
        [_audioRecorder stop];
    }
    if(!isPlaying) {
        
        isPlaying = YES;
        showPlayerUI=YES;
        
        NSError *error;
        self.audioPlayer=nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:nil];
        self.audioPlayer.delegate = self;

        if (error){
            NSLog(@"Error on play audio: %@", [error localizedDescription]);
        }
        else
        {
            [_audioPlayer play];
            [self updateButtons:kPLAY];
            [self updateViewForPlayerState:_audioPlayer];
        }
    }
}

/** - (IBAction)stopAudio:(id)sender
       Handles stop intent*/
- (IBAction)stopAudio:(id)sender {
    
        // stop everything
        isRecording = NO;
    
        isPlaying = NO;
         showPlayerUI=NO;
    
        [_audioRecorder stop];
        [_audioPlayer pause];
    
        [self updateButtons:kSTOP];
    
        [self updateViewForPlayerState:_audioPlayer];
        [self updateViewForRecorderState:_audioRecorder];
}


- (IBAction)cancelTouched:(id)sender {
    [self cancelAndExit];
}

- (IBAction)doneTouched:(id)sender {
    //TODO: Save audio
    [self cancelAndExit];
}

-(void) cancelAndExit
{
    if([self updateTimer])
        [self.updateTimer invalidate];
    self.updateTimer=nil;
    
    [self processAndSaveAudio:^(BOOL success) {
        if(success){
            NSLog(@"cancelAndExit block success");
            //** transition back - notifiy schedule view that image has been captured
          //  [[NSNotificationCenter defaultCenter] postNotificationName:@"addImageComplete" object:nil];            
            
            [self dismissViewControllerAnimated:YES completion:nil];
            self.audioRecorder = nil;
            self.audioPlayer = nil;
            [self dismissViewControllerAnimated: YES completion: nil];
        }
        else{
            NSLog(@"cancelAndExit failure");
        }
    }];
}

-(void) processAndSaveAudio:(processAudio)audioBlock{
    
    NSLog(@"processAndSaveAudio");
    NSString * apptRef= @"JgNj4N9fcw";
   //
    NSString*audioName= [NSString stringWithFormat:@"%@.m4a", apptRef];
    NSData *audioData = [NSData dataWithContentsOfFile:[self audioFilePath]];
    NSLog(@"audioData = %@", audioData);
    
    //create audiofile as a property
    PFFile *audioFile = [PFFile fileWithName:audioName data:audioData];
    PFQuery *query = [PFQuery queryWithClassName:@"Appointments"];
    
    [query getObjectInBackgroundWithId:@"JgNj4N9fcw" block:^(PFObject *appointment, NSError *error) {
        if(!error){
            NSLog(@"success in save audio");
            appointment[@"audio_file"] =audioFile;
            [appointment saveInBackground];
            audioBlock(YES);
        }
        else{
            NSLog(@"error in save audio");
            audioBlock(NO);
        }
    }];
}



#pragma mark - Utility methods

-(NSString*)audioFilePath{
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    return [docsDir stringByAppendingPathComponent:@"sound.m4a"];
}

-(NSURL*)audioURL
{
    return [NSURL fileURLWithPath:[self audioFilePath]];
}

-(void) updateButtons:(int)state
{
    switch(state){
        case kINIT:
            self.playButton.enabled=NO;
            self.playButton.alpha=.6;
            self.recordButton.enabled=YES;
            self.recordButton.alpha=1.0;
            self.stopButton.enabled=NO;
            self.stopButton.alpha=.6;
            self.doneButton.hidden=YES;
            break;
        case kRECORD:
            self.playButton.enabled=NO;
            self.playButton.alpha=.6;
            self.recordButton.enabled=NO;
            self.recordButton.alpha=.6;
            self.stopButton.enabled=YES;
            self.stopButton.alpha=1.0;
            self.doneButton.hidden=YES;
            break;
        case kPLAY:
            self.playButton.enabled=NO;
            self.playButton.alpha=.6;
            self.recordButton.enabled=NO;
            self.recordButton.alpha=.6;
            self.stopButton.enabled=YES;
            self.stopButton.alpha=1.0;
            self.doneButton.hidden=NO;
            break;
        case kSTOP:
            self.playButton.enabled=YES;
            self.playButton.alpha=1.0;
            self.recordButton.enabled=YES;
            self.recordButton.alpha=1.0;
            self.stopButton.enabled=NO;
            self.stopButton.alpha=0.6;
            self.doneButton.hidden=NO;
            break;
    }
}

-(void) toggleUI:(BOOL)showUI
{
    if(!showUI){      
        self.minLbl.alpha=0.0;
        self.maxLbl.alpha=0.0;
        self.slider.alpha=0.0;
    }
    else{
        self.minLbl.alpha=1.0;
        self.maxLbl.alpha=1.0;
        self.slider.alpha=1.0;
    }
}


#pragma mark - Configuration / Set up
-(void) configureAudioSession{
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
}



-(void) configureView{
    
    //TODO: test for exisitng audio & load/update view
    
    UIImage *sliderMaxTrackImage=[UIImage imageNamed:@"emptyThumb.png"];
    sliderMaxTrackImage = [sliderMaxTrackImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    
    [self.slider setMinimumTrackImage:nil forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:sliderMaxTrackImage forState:UIControlStateNormal];
    
    [self updateButtons:kINIT];
    
    self.timeLbl.text=@"00:00";
    self.minLbl.text=@"00:00";
    self.maxLbl.text=@"00:00";
    
    self.slider.value = 0.0;
    self.slider.thumbTintColor=[UIColor clearColor];
    
    [self toggleUI:showPlayerUI];
}


-(void) configureAudioRecorder{
    NSError *error;
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   /* [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],AVSampleRateKey,*/
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self audioURL] settings:recordSettings error:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }else{
        [self.audioRecorder prepareToRecord];
    }
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
