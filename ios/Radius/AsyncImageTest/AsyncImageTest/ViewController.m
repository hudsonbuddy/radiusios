//
//  ViewController.m
//  AsyncImageTest
//
//  Created by David Herzka on 10/14/12.
//  Copyright (c) 2012 David Herzka. All rights reserved.
//

#import "ViewController.h"
#import "AsyncImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    cache = [[NSMutableDictionary alloc] init];
    
    imgs = [NSArray arrayWithObjects:@"http://st.gdefon.ru/wallpapers_original/wallpapers/160252_susan_4096x2731_(www.GdeFon.ru).jpg",@"http://i.imgur.com/566sO.jpg",@"http://i.imgur.com/K5k65.jpg",@"http://i.imgur.com/kGUgL.jpg",nil];
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return imgs.count;
}

id cache;

NSArray *imgs;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.textLabel.text = [NSString stringWithFormat:@"this is cell %d",indexPath.row];
    
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,44,44) imageURL:[NSURL URLWithString:[imgs objectAtIndex:indexPath.row]] cache:cache loadImmediately:YES];
    
    // To be able to see the frame of the image view
    imageView.backgroundColor = [UIColor yellowColor];
    
    // Get the text out of the way of the image
    cell.indentationWidth = imageView.frame.size.width;
    cell.indentationLevel = 1;
    [cell addSubview:imageView];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)printCache:(id)sender {
    for(int i = 0; i < imgs.count; i++) {
        NSString *key = [NSString stringWithFormat:@"%X",[[NSURL URLWithString:[imgs objectAtIndex:i]] hash]];
        id value = [cache objectForKey:key];
        
        NSLog(@"%@ in cache? %@",[imgs objectAtIndex:i],value?@"yes":@"no");
    }
}

@end
