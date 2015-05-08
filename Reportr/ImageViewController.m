//
//  ImageViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/30/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//
#import "ScheduleViewController.h"
#import "ImageViewController.h"
#import "MessageModel.h"
#import "ApplicationModel.h"

#import <Parse/Parse.h>

@interface ImageViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;
typedef void (^processImage)(BOOL);
@end

@implementation ImageViewController
static MessageModel *  mModel;
static ApplicationModel * appModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mModel=[MessageModel sharedMessageModel];
    appModel = [ApplicationModel sharedApplicationModel];
    
    if (self.capturedImages){
        if (self.capturedImages.count > 0){
            [self.capturedImages removeAllObjects];
        }
    } else {
        self.capturedImages = [[NSMutableArray alloc] init];
    }
    if (self.imageView.isAnimating)
        [self.imageView stopAnimating];
    
    /* TODO: Handle devices with no camera*/
    [self createImagePicker];
    [self presentViewController:self.imagePickerController animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIImagePickerControllerDelegate
/*- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    Save request after image taken from camera.*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:image];
    [self finishAndUpdate];
}

/*- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
     Cancel on user request */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self cancelAndExit];
}

#pragma mark - Prepare & Store Image
/** - (void)finishAndUpdate {
    controls data creation & server sync action */
- (void)finishAndUpdate {
   [self dismissViewControllerAnimated:NO completion:nil];
    if ([self.capturedImages count] > 0){
        if ([self.capturedImages count] == 1){
            // Camera took a single picture.
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
            [self processAndSaveImage:^(BOOL success) {
                if(success){
                    NSLog(@" dismissViewControllerAnimated block success");
                    self.imagePickerController = nil;
                    appModel.appointment.hasImage=YES;
                    //** transition back - notifiy schedule view that image has been captured
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addImageComplete" object:nil];
                    [self dismissViewControllerAnimated: YES completion: nil];
                }
            }];
        }
        [self.capturedImages removeAllObjects];
    }
}

/* -(void) processAndSaveImage:(processImage)imageBlock{
     Prepares image for upload to database */
-(void) processAndSaveImage:(processImage)imageBlock{
    NSString * apptRef= [mModel appointmentId];
    NSData* data = UIImageJPEGRepresentation(self.imageView.image, 0.5f);
    NSString*imgName= [NSString stringWithFormat:@"%@.jpg", apptRef];
    PFFile *imageFile = [PFFile fileWithName:imgName data:data];
    PFQuery *query = [PFQuery queryWithClassName:@"Appointments"];
    [query getObjectInBackgroundWithId:apptRef block:^(PFObject *appointment, NSError *error) {
        if(!error){
            NSLog(@"success in save image");
            appointment[@"image_file"] =imageFile;
            [appointment saveInBackground];
            imageBlock(YES);
        }
        else{
            NSLog(@"error in save image");
            imageBlock(NO);
        }
    }];
}

/* -(void) cancelAndExit
    Cancels view */
-(void) cancelAndExit
{   [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePickerController = nil;
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - UI Update
/* -(void) createImagePicker
    Create UIImagePickerController and update reference */
-(void) createImagePicker{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.showsCameraControls = YES;
    self.imagePickerController = imagePickerController;
}

@end
