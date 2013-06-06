//
//  ImageViewController.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/5/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ImageViewController.h"
#import "AsyncableImageView.h"

#define url1 @"https://d2rfichhc2fb9n.cloudfront.net/image/5/zbW7sjp-VvL0OPvIB_MGvRsU2AZ7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvZWIvNzIvNDAvZWI3MjQwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0"
#define url2 @"https://d2rfichhc2fb9n.cloudfront.net/image/5/I4A0KmLjCexgfFfwO_zHsOf7_RN7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvNGYvODAvMTAvNGY4MDEwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0"
#define kPlaceholderImage @"Placeholder"

@interface ImageViewController ()

@property (nonatomic, strong)AsyncableImageView *image1;
@property (nonatomic, strong)AsyncableImageView *image2;

- (IBAction)dismissController:(id)sender;

@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      _image1 = [[AsyncableImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 200.0)];
      _image2 = [[AsyncableImageView alloc]initWithFrame:CGRectMake(0.0, 250.0, 320.0, 200.0)];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.image1 = [[AsyncableImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 200.0)];
  self.image2 = [[AsyncableImageView alloc]initWithFrame:CGRectMake(0.0, 250.0, 320.0, 200.0)];
  [self.view addSubview:self.image1];
  [self.view addSubview:self.image2];
  
  UIImage *placeholder = [UIImage imageNamed:kPlaceholderImage];
  [self.image1 showImageFromURL:url1 withPlaceHolderImage:placeholder];
  [self.image2 showImageFromURL:url2 withPlaceHolderImage:placeholder];
  
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissController:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
