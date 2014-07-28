//
//  DZViewController.m
//  DZDatasource
//
//  Created by Nikhil Nigade on 7/28/14.
//  Copyright (c) 2014 Dezine Zync. All rights reserved.
//

#import "DZViewController.h"
#import "DZBasicDatasource.h"

static NSString *const cellIdentifier = @"com.dezinezync.basicDatasource.cell";

@interface DZViewController () <DZDatasource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DZBasicDatasource *datasource;

@end

@implementation DZViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		[self commonInit];
	}
	return self;
}

- (instancetype)init
{
	if(self = [super init])
	{
		[self commonInit];
	}
	
	return self;
}

- (void)commonInit
{
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.rowHeight = 60;
	_tableView.separatorColor = [UIColor blackColor];
	
	_datasource = [DZBasicDatasource datasourceWithView:_tableView];
	_datasource.delegate = self;
	
	[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
	
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	if(!self.tableView) [self commonInit];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"photos" ofType:@"json"];
	
	NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:kNilOptions error:nil];
	
	[_datasource setData:[data[@"photos"][@"photo"] mutableCopy]];
	
	__weak typeof(self) weakSelf = self;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		NSLog(@"Appending 4 items");
		
		[weakSelf.datasource append:[weakSelf appendData]];
		
		[weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:20 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		
	});
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		NSLog(@"Prepending 4 items");
		
		[weakSelf.datasource prepend:[weakSelf prependData]];
		[weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		
	});
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		NSLog(@"Moving two items around");
		
		NSMutableArray *fromIncides = [NSMutableArray arrayWithCapacity:2];
		NSMutableArray *toIndices = [NSMutableArray arrayWithCapacity:2];
		
		for(NSInteger i=0; i<2; i++)
		{
//			2,4
			NSInteger from = i*2+2;
//			3,6
			NSInteger to = i*3+3;
			
			[fromIncides addObject:[NSIndexPath indexPathForRow:from inSection:0]];
			[toIndices addObject:[NSIndexPath indexPathForRow:to inSection:0]];
		}
		
		[weakSelf.datasource moveItemsAtIndices:fromIncides toIndices:toIndices];
		
	});
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	NSDictionary *data = [self.datasource.data objectAtIndex:indexPath.row];
	
	if(data)
	{
		cell.textLabel.text = [data valueForKey:@"title"];
		cell.contentView.backgroundColor = [UIColor colorWithWhite:1.0-(indexPath.row*0.025) alpha:1];
		cell.backgroundColor = cell.contentView.backgroundColor;
	}
	
	return cell;
	
}

- (NSArray *)appendData
{
	NSString *appData = @"[{\"id\":\"13106612905\",\"owner\":\"34581217@N00\",\"secret\":\"56caa5edeb\",\"server\":\"3763\",\"farm\":4,\"title\":\"2014-03-07 15.35.02\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"4678944354\",\"owner\":\"87677022@N00\",\"secret\":\"6d4e033db2\",\"server\":\"4018\",\"farm\":5,\"title\":\"Waiting in line early Monday morning for the Keynote.\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"14619701641\",\"owner\":\"34581217@N00\",\"secret\":\"0b8a99ce16\",\"server\":\"5584\",\"farm\":6,\"title\":\"2014-06-19 16.13.01\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"14162106852\",\"owner\":\"34581217@N00\",\"secret\":\"51c1e37da0\",\"server\":\"2904\",\"farm\":3,\"title\":\"2014-04-30 18.15.04\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0}]";
	
	NSArray *appPhotos = [NSJSONSerialization JSONObjectWithData:[appData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
	
	return appPhotos;
}

- (NSArray *)prependData
{
	NSString *preData = @"[{\"id\":\"13106612905\",\"owner\":\"34581217@N00\",\"secret\":\"56caa5edeb\",\"server\":\"3763\",\"farm\":4,\"title\":\"2014-03-07 15.35.02\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"13106611515\",\"owner\":\"34581217@N00\",\"secret\":\"c2d5e289dd\",\"server\":\"7365\",\"farm\":8,\"title\":\"2014-03-07 15.35.03-2\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"13106721403\",\"owner\":\"34581217@N00\",\"secret\":\"a74c2dbbe6\",\"server\":\"2565\",\"farm\":3,\"title\":\"2014-03-07 15.40.07\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"13106725133\",\"owner\":\"34581217@N00\",\"secret\":\"879e025dd8\",\"server\":\"3833\",\"farm\":4,\"title\":\"2014-03-07 15.35.03-1\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0}]";
	
	NSArray *prePhotos = [NSJSONSerialization JSONObjectWithData:[preData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
	
	return prePhotos;
}

@end
