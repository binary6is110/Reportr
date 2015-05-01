//
//  AudioViewController.m
//  Reportr
//
//  Created by Kim Adams on 5/1/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "AudioViewController.h"


@interface AudioViewController ()
@property (nonatomic, strong)NSURL*soundFileURL;
@property (nonatomic,strong) AVAudioRecorder*soundRecorder;
@property (nonatomic, retain) AVAudioPlayer *player;
@property BOOL recording;
@property BOOL playing;

@property (strong, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *recordOrStopButton;
@end

@implementation AudioViewController
-(void) viewWillAppear:(BOOL)animated
{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *tempDir = NSTemporaryDirectory ();
    NSString *soundFilePath = [tempDir stringByAppendingString: @"sound.m4a"];
    
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    self.soundFileURL = newURL;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive: YES error: nil];
    
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:44100],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatAppleLossless],AVFormatIDKey,
                                   [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
    
    self.soundRecorder = [[AVAudioRecorder alloc] initWithURL:_soundFileURL settings:audioSettings error:nil];
    
    self.recording = NO;
    self.playing = NO;
   // self.playOrPauseButton.enabled=NO;
   // self.playOrPauseButton.alpha=0.0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)playOrPause:(id)sender {
  
    if (self.playing) {
        [self.player pause];
        
        [self.playOrPauseButton setTitle: @"pause" forState:UIControlStateNormal];
        [self.playOrPauseButton setTitle: @"pause" forState: UIControlStateHighlighted];
        
        self.playing=NO;
    }
    else {
        
        [self.player play];
        [self.playOrPauseButton setTitle: @"play" forState:UIControlStateNormal];
        [self.playOrPauseButton setTitle: @"play" forState: UIControlStateHighlighted];
        
        self.playing=YES;
    }

}

- (IBAction) recordOrStop: (id) sender {
    
    if (self.recording) {
        
        [self.soundRecorder stop];
        self.recording = NO;
        
        
        [self.recordOrStopButton setTitle: @"Start Recording" forState:UIControlStateNormal];
        [self.recordOrStopButton setTitle: @"Start Recording" forState: UIControlStateHighlighted];
        
    } else {
        
        [self.soundRecorder record];
        
        [self.recordOrStopButton setTitle: @"Stop Recording" forState: UIControlStateNormal];
        [self.recordOrStopButton setTitle: @"Stop Recording" forState: UIControlStateHighlighted];
        
        self.recording = YES;
    }
}

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag == YES) {
        [self.playOrPauseButton setTitle: @"Again" forState: UIControlStateNormal];
        self.playing=NO;
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error:nil];

    }
  //  AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL: self.soundFileURL error: nil];
   // self.player=newPlayer;
   // [self.player prepareToPlay];
   // self.player.delegate=self;
   // self.playOrPauseButton.enabled=YES;
   // self.playOrPauseButton.alpha=1.0;
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag == YES) {
        [self.playOrPauseButton setTitle: @"Again" forState: UIControlStateNormal];
        self.playing=NO;
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
