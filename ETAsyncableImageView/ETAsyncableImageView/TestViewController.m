//
//  TestViewController.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/12/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "TestViewController.h"
#import "AsyncableImageView.h"

#define url @"https://d2rfichhc2fb9n.cloudfront.net/image/5/uP88TRPv7rIo3YLRhkgpyc6T6dF7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvM2IvZGMvMzAvM2JkYzMwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0"
#define kPlaceholderImage @"Placeholder"

@interface TestViewController ()

@property (nonatomic, strong) AsyncableImageView *imageView;

- (IBAction)dismissController:(id)sender;

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.imageView = [[AsyncableImageView alloc]initWithFrame:CGRectMake(20.0, 20.0, 100.0, 100.0)];
  [self.view addSubview:self.imageView];
  
  UIImage *placeholder = [UIImage imageNamed:kPlaceholderImage];
  [self.imageView showImageFromURL:url withPlaceHolderImage:placeholder];
  
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
