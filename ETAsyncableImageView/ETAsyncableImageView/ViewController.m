//
//  ViewController.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ViewController.h"
#import "AsyncableImageView.h"

#define kPlaceholderImage @"Placeholder"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *urlList;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.urlList = [[NSMutableArray alloc]initWithObjects:
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/5QvP1Gy77PqwQeR99vA701bi0Lt7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvZGEvZGMvMzAvZGFkYzMwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/zbW7sjp-VvL0OPvIB_MGvRsU2AZ7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvZWIvNzIvNDAvZWI3MjQwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/uP88TRPv7rIo3YLRhkgpyc6T6dF7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvM2IvZGMvMzAvM2JkYzMwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/EQB6rJetQ3YuJwS5Hjq7GhHlzRh7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvNzQvOTQvNDAvNzQ5NDQwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/Xmwn_30UZf-jyownq-7C29MgjH17InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvMTIvMmUvMTAvMTIyZTEwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/kZ-JRmTbmd3WVPswTJ8Nwxzkf917InMiOiJzMyIsImIiOiJ0YXBwLWFzc2V0cyIsImsiOiJpL1UvaS9ZL1VpWW5xRFNvTUtyTEhLNXA0OHN2NkxmTmRVMC5qcGciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/VFP0digCcEMrdQEh4teTZXZrlNN7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvNzAvMjQvMjAvNzAyNDIwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/wlHP_HoFgxVrJyH5Tm7FgyrRrkt7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvYzAvMjQvMjAvYzAyNDIwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0",
    @"https://d2rfichhc2fb9n.cloudfront.net/image/5/I4A0KmLjCexgfFfwO_zHsOf7_RN7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvNGYvODAvMTAvNGY4MDEwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0",
                    nil];
   
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource methods

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.urlList count];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    } 
    [cell.textLabel setText:[NSString stringWithFormat:@"cell %d",indexPath.row]];
    AsyncableImageView *imageView = [[AsyncableImageView alloc]initWithFrame:CGRectMake(250,0,70,80) withPlaceHolderImage:[UIImage imageNamed:kPlaceholderImage]];
    [imageView showImageFromURL:(NSString*)[self.urlList objectAtIndex:indexPath.row]];
    //Testing for cancellation
//    if(indexPath.row == 5)
//    {
//        [imageView stopImageLoadingFromURL:(NSString*)[self.urlList objectAtIndex:2]];
//        [imageView stopAllImageLoading];
//
//    }
    [cell.contentView addSubview:imageView];
    return cell;
}

#pragma mark - UITableViewDelegate methods

@end
