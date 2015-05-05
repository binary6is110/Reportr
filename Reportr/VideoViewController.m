//
//  VideoViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/30/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//
#import "ScheduleViewController.h"
#import "VideoViewController.h"

@interface VideoViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *cameraOverlayView;
@property (nonatomic) NSMutableArray *capturedVideo;
@property (nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation VideoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect theRect = [self.imagePickerController.view frame];
    [_cameraOverlayView setFrame:theRect];
    self.imagePickerController.cameraOverlayView = _cameraOverlayView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.capturedVideo = [[NSMutableArray alloc] init];
    
    /* TODO: Handle devices with no camera*/
    if (self.cameraOverlayView.isAnimating)
        [self.cameraOverlayView stopAnimating];
    
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
    imagePickerController.videoQuality = UIImagePickerControllerQualityType640x480;
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
    NSString *pathToVideo = [videoURL path];
    BOOL okToSaveVideo = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToVideo);
    if (okToSaveVideo) {
        UISaveVideoAtPathToSavedPhotosAlbum(pathToVideo, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    } else {
        [self cancelAndExit];
    }
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancelAndExit];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
    // transition back - notifiy schedule view that video has been captured
    //TODO: Do something with captured video
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addVideoComplete" object:nil];
    [self dismissViewControllerAnimated: YES completion: nil];
    
}


-(void) cancelAndExit
{  [self dismissViewControllerAnimated:YES completion:nil];
   self.imagePickerController = nil;
   [self dismissViewControllerAnimated: YES completion: nil];
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