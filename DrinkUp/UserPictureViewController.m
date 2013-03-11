//
//  UserPictureViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "UserPictureViewController.h"

@interface UserPictureViewController ()
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImageView *selfie;
@end

@implementation UserPictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selfie = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    [self.view addSubview:self.selfie];
    
    [self takePictureWithCamera];
}

-(void)takePictureWithCamera
{
    // Lazily allocate image picker controller
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        
        // If our device has a camera, we want to take a picture, otherwise, we just pick from
        // photo library
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self.imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
        } else
        {
            [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        
        // image picker needs a delegate so we can respond to its messages
        [self.imagePicker setDelegate:self];
    }
    // Place image picker on the screen
    [self presentViewController:self.imagePicker animated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:YES completion:^{}]; //Do this first!!
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self.selfie setImage:image];
}

@end
