//
//  ViewController.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ViewController.h"
#import "AsyncableImageView.h"

#define kSampleDataUrl @"https://d2rfichhc2fb9n.cloudfront.net/image/5/zbW7sjp-VvL0OPvIB_MGvRsU2AZ7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvZWIvNzIvNDAvZWI3MjQwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0"
#define kPlaceholderImage @"Placeholder"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource methods

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    }
    [cell.textLabel setText:[NSString stringWithFormat:@"cell %d",indexPath.row]];
    AsyncableImageView *imageView = [[AsyncableImageView alloc]initWithFrame:CGRectMake(270,0,50,50)];
    UIImage *placeholder = [UIImage imageNamed:kPlaceholderImage];
    [imageView showImageFromURL:kSampleDataUrl withMaskImage:placeholder];
    [cell.contentView addSubview:imageView];
    return cell;
}

#pragma mark - UITableViewDelegate methods

@end
