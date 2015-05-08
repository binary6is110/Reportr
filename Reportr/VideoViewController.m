//
//  VideoViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/30/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//
#import "ScheduleViewController.h"
#import "VideoViewController.h"
#import "MessageModel.h"
#import <Parse/Parse.h>

@interface VideoViewController ()

typedef void (^processVideo)(BOOL);

@property(nonatomic,retain) NSURL*videoURLRef;
@property (nonatomic) NSMutableArray *capturedVideo;
@property (nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) IBOutlet UITextView *warningTextview;
@end

@implementation VideoViewController

static MessageModel *  mModel;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    mModel=[MessageModel sharedMessageModel];
    
    self.capturedVideo = [[NSMutableArray alloc] init];
    
    if (self.capturedVideo.count > 0)
        [self.capturedVideo removeAllObjects];
    
    [self createImagePicker];
}

/* -(void) createImagePicker
 create UIImagePickerController and update reference */
-(void) createImagePicker{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.showsCameraControls = YES;    
    imagePickerController.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    imagePickerController.allowsEditing = NO;
    imagePickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    imagePickerController.delegate = self;
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera Actions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
    self.videoURLRef=videoURL;
    NSString *pathToVideo = [videoURL path];
    BOOL okToSaveVideo = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToVideo);
    if (okToSaveVideo) {
        UISaveVideoAtPathToSavedPhotosAlbum(pathToVideo, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    } else {
        [self cancelAndExit];
    }
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self cancelAndExit];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(!error){
        [self processAndSaveVideo:^(BOOL success) {
            if(success){
                NSLog(@"didFinishSavingWithError block success");
                [self dismissViewControllerAnimated:YES completion:nil];
                self.imagePickerController = nil;
                // transition back - notifiy schedule view that video has been captured
                //TODO: Do something with captured video
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addVideoComplete" object:nil];

                [self dismissViewControllerAnimated: YES completion: nil];
            }
            else{
                  //TODO: Handle error
                NSLog(@"didFinishSavingWithError failure");
            }
        }];
    }
}

-(void) processAndSaveVideo:(processVideo)videoBlock{
    NSString * apptRef= [mModel appointmentId];
    NSData *videoData = [NSData dataWithContentsOfURL:self.videoURLRef];
    NSString*audioName= [NSString stringWithFormat:@"%@.mov", apptRef];

    PFFile *videofile = [PFFile fileWithName:audioName data:videoData];
    PFQuery *query = [PFQuery queryWithClassName:@"Appointments"];
    
    NSError *error;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.videoURLRef path] error:&error];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    
    if(fileSizeNumber > [NSNumber numberWithInt:10000000])    {
        [mModel displayError:@"Video Error" withMessage:[mModel videoSizeExceeded]];
        return;
    }    
    [query getObjectInBackgroundWithId:apptRef block:^(PFObject *appointment, NSError *error) {
        if(!error){
            NSLog(@"success in save video");
            appointment[@"video_file"] =videofile;
            [appointment saveInBackground];
            videoBlock(YES);
        }
        else{
            NSLog(@"error in save video");
            videoBlock(NO);
        }
    }];
}

-(void) cancelAndExit
{  [self dismissViewControllerAnimated:YES completion:nil];
   self.imagePickerController = nil;
   [self dismissViewControllerAnimated: YES completion: nil];
}

@end
