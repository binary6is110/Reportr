//
//  ImageViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/30/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//
#import "ScheduleViewController.h"
#import "ImageViewController.h"

@interface ImageViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;

@end

@implementation ImageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.capturedImages = [[NSMutableArray alloc] init];
    
    /* TODO: Handle devices with no camera*/
    
    if (self.imageView.isAnimating)
        [self.imageView stopAnimating];
    
    if (self.capturedImages.count > 0)
       [self.capturedImages removeAllObjects];
    
    [self createImagePicker];

    [self presentViewController:self.imagePickerController animated:NO completion:nil];
}

/* -(void) createImagePicker
    create UIImagePickerController and update reference */
-(void) createImagePicker{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.showsCameraControls = YES;
    
    self.imagePickerController = imagePickerController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate
// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:image];
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancelAndExit];
}

#pragma mark - Camera Handlers
- (void)finishAndUpdate
{
   [self dismissViewControllerAnimated:NO completion:NULL];
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
        }
        [self.capturedImages removeAllObjects];
    }
    self.imagePickerController = nil;
    //** transition back - notifiy schedule view that image has been captured
     [[NSNotificationCenter defaultCenter] postNotificationName:@"addImageComplete" object:nil];
    [self dismissViewControllerAnimated: YES completion: nil];
}

-(void) cancelAndExit
{   [self dismissViewControllerAnimated:NO completion:NULL];
    self.imagePickerController = nil;
    [self dismissViewControllerAnimated: YES completion: nil];
}



@end
