//
//  AudioRecordPlayViewController.h
//  Reportr
//
//  Created by Kim Adams on 5/1/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EZAudio/EZAudio.h"

@interface AudioRecordPlayViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, EZMicrophoneDelegate>


@property (strong, nonatomic)  UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
- (IBAction)recordAudio:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *playingTextField;
@property (strong, nonatomic) IBOutlet UILabel *recordingTextField;
@property (strong, nonatomic) IBOutlet UILabel *microphoneTextField;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) NSArray *playItems;
@property (strong, nonatomic) NSArray *pauseItems;
@property (strong, nonatomic) UIBarButtonItem *playBBI;
@property (strong, nonatomic) UIBarButtonItem *pauseBBI;
@property (strong, nonatomic) IBOutlet UISwitch *microphoneSwitch;

// Use a OpenGL based plot to visualize the data coming in
@property (nonatomic,strong)  EZAudioPlotGL *audioPlot;
/** The microphone component */
@property (nonatomic,strong) EZMicrophone *microphone;
/** The recorder component */
@property (nonatomic,strong) EZRecorder *recorder;

@end
