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
    self.selfie.contentMode = UIViewContentModeScaleAspectFill;
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
    [self dismissViewControllerAnimated:YES completion:^
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.selfie.image = image;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Updating Photo";
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
        {
            NSString *picName = [[SharedDataHandler sharedInstance].userInformation objectForKey:@"ua_username"];
            NSLog(@"starting AWS");
            
            AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAIXLT3ZDWWR7Q4YKA" withSecretKey:@"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"];
#ifdef DEV
            NSLog(@"Amazon dev image bucket");
            S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:picName inBucket:@"DrinkUp-Users-Dev"];
#else
            S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:picName inBucket:@"DrinkUp-Users"];
#endif
            por.contentType = @"image/jpeg";
            por.data = UIImageJPEGRepresentation(image, 0.7);;
            [s3 putObject:por];
            
            S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
            override.contentType = @"image/jpeg";
            
            NSLog(@"ending AWS");
            
    //        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    //        gpsur.key     = picName;
    //        gpsur.bucket  = @"DrinkUp-Users";
    //        gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600];  // Added an hour's worth of seconds to the current time.
    //        gpsur.responseHeaderOverrides = override;
    //        
    //        NSURL *url = [s3 getPreSignedURL:gpsur];
            
            [[SharedDataHandler sharedInstance] updateUserProfileImageSaved:^(bool successful)
            {
                [self.navigationController popViewControllerAnimated:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }];
        });
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
