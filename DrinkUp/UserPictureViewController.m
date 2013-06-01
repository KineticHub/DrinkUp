//
//  UserPictureViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "UserPictureViewController.h"
#import "SharedDataHandler.h"
#import "MBProgressHUD.h"

#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>

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
    
    NSString *picName = [[SharedDataHandler sharedInstance].userInformation objectForKey:@"ua_username"];
    NSLog(@"starting AWS");
    
    [MBProgressHUD showHUDAddedTo:self.imagePicker.view animated:YES];
    
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAIXLT3ZDWWR7Q4YKA" withSecretKey:@"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"];
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:picName inBucket:@"DrinkUp"];
    por.contentType = @"image/jpeg";
    por.data = UIImageJPEGRepresentation(image, 0.7);;
    [s3 putObject:por];
    
    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
    override.contentType = @"image/jpeg";
    
    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    gpsur.key     = picName;
    gpsur.bucket  = @"DrinkUp";
    gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600];  // Added an hour's worth of seconds to the current time.
    gpsur.responseHeaderOverrides = override;
    
    NSURL *url = [s3 getPreSignedURL:gpsur];
    
    [[SharedDataHandler sharedInstance] userUpdateProfilePicture:url withSuccess:^(bool successful) {
    }];
    
    [MBProgressHUD hideHUDForView:self.imagePicker.view animated:YES];
    
    NSLog(@"ending AWS");
    
    
    
    [self.selfie setImage:image];
}

@end
