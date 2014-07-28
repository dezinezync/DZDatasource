//
//  DZDatasourceTests.m
//  DZDatasourceTests
//
//  Created by Nikhil Nigade on 7/28/14.
//  Copyright (c) 2014 Dezine Zync. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "DZBasicDatasource.h"

@interface DZDatasourceTests : XCTestCase

@property (nonatomic, strong) DZBasicDatasource *ds;

@end

@implementation DZDatasourceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	NSLog(@"%ld",(long)[self.ds.data count]);
	if(![self.ds.data count])
	{
		[self.ds setData:[[self testBaseData] mutableCopy]];
	}
	
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit
{
    XCTAssertNotNil([self ds], @"Non-nil Datasource for UITableView");
	
	Protocol *tableDS = objc_allocateProtocol("UITableViewDatasource");
	
	XCTAssert([self.ds conformsToProtocol:tableDS], @"DS1 conforms to TableView Datasource Protocol");
	
	DZBasicDatasource *ds2 = [DZBasicDatasource datasourceWithView:[[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:[UICollectionViewLayout new]]];
	
	Protocol *cvDS = objc_allocateProtocol("UICollectionViewDatasource");
	
	XCTAssert([self.ds conformsToProtocol:cvDS], @"DS2 conforms to UICollectionView Datasource Protocol");
	
	XCTAssertNotNil(ds2, @"Non-nil Datasource for UICollectionView");
}

- (void)testPrepend
{
	NSString *preData = @"[{\"id\":\"13106612905\",\"owner\":\"34581217@N00\",\"secret\":\"56caa5edeb\",\"server\":\"3763\",\"farm\":4,\"title\":\"2014-03-07 15.35.02\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"13106611515\",\"owner\":\"34581217@N00\",\"secret\":\"c2d5e289dd\",\"server\":\"7365\",\"farm\":8,\"title\":\"2014-03-07 15.35.03-2\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"13106721403\",\"owner\":\"34581217@N00\",\"secret\":\"a74c2dbbe6\",\"server\":\"2565\",\"farm\":3,\"title\":\"2014-03-07 15.40.07\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"13106725133\",\"owner\":\"34581217@N00\",\"secret\":\"879e025dd8\",\"server\":\"3833\",\"farm\":4,\"title\":\"2014-03-07 15.35.03-1\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0}]";
	
	NSArray *prePhotos = [NSJSONSerialization JSONObjectWithData:[preData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
	
	XCTAssertNotNil(prePhotos, @"Pre Photos are acquired");
	XCTAssert([prePhotos count] == 4, @"Correct number of pre photos");
	
	[self.ds prepend:prePhotos];
	
	XCTAssertEqual([self.ds.data count], 24, @"Photos prepended");
	XCTAssertEqualObjects(self.ds.data[0], prePhotos[0], @"Objects seem to be in order");
	
}

- (void)testAppend
{
	NSString *appData = @"[{\"id\":\"13106612905\",\"owner\":\"34581217@N00\",\"secret\":\"56caa5edeb\",\"server\":\"3763\",\"farm\":4,\"title\":\"2014-03-07 15.35.02\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"4678944354\",\"owner\":\"87677022@N00\",\"secret\":\"6d4e033db2\",\"server\":\"4018\",\"farm\":5,\"title\":\"Waiting in line early Monday morning for the Keynote.\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"14619701641\",\"owner\":\"34581217@N00\",\"secret\":\"0b8a99ce16\",\"server\":\"5584\",\"farm\":6,\"title\":\"2014-06-19 16.13.01\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"14162106852\",\"owner\":\"34581217@N00\",\"secret\":\"51c1e37da0\",\"server\":\"2904\",\"farm\":3,\"title\":\"2014-04-30 18.15.04\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0}]";
	
	NSArray *appPhotos = [NSJSONSerialization JSONObjectWithData:[appData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
	
	XCTAssertNotNil(appPhotos, @"App Photos are acquired");
	XCTAssert([appPhotos count] == 4, @"Correct number of App photos");
	
	NSUInteger countBeforeAppending = [self.ds.data count];
	
	[self.ds append:appPhotos];
	
	XCTAssertEqual([self.ds.data count], countBeforeAppending + [appPhotos count], @"Photos prepended");
	XCTAssertEqualObjects(self.ds.data[countBeforeAppending], appPhotos[0], @"Objects seem to be in order");
	
}

- (void)testMoving
{
	
	NSArray *dataCopy = [self.ds.data copy];
	
	NSMutableArray *fromIncides = [NSMutableArray arrayWithCapacity:2];
	NSMutableArray *toIndices = [NSMutableArray arrayWithCapacity:2];
	
	for(NSInteger i=0; i<2; i++)
	{
//		2,4
		NSInteger from = i*2+2;
//		3,6
		NSInteger to = i*3+3;
		
		[fromIncides addObject:[NSIndexPath indexPathForRow:from inSection:0]];
		[toIndices addObject:[NSIndexPath indexPathForRow:to inSection:0]];
	}
	
	[self.ds moveItemsAtIndices:fromIncides toIndices:toIndices];
	
	XCTAssertEqualObjects([self.ds.data objectAtIndex:[(NSIndexPath*)toIndices[0] row]], [dataCopy objectAtIndex:[(NSIndexPath *)fromIncides[0] row]], @"Data is match. Object at index 2 moved");
	
	XCTAssertEqualObjects([self.ds.data objectAtIndex:[(NSIndexPath*)toIndices[1] row]], [dataCopy objectAtIndex:[(NSIndexPath *)fromIncides[1] row]], @"Data is match. Object at index 4 moved");
	
}

- (void)testIndexPathsGen
{
	NSArray *indices = [self.ds indexPathsFrom:2 to:4];
	
	for(NSInteger i=0,x=[indices count]; i < x; i++)
	{
		NSIndexPath *indexPath = indices[i];
		NSLog(@"124 : %@", indexPath);
		XCTAssert(indexPath.item == (i+2), @"Got incorrect index at: %ld", (long)i);
	}
	
}

- (void)testAddAtIndexPaths
{
	NSArray *items = @[@"Custom Object 1", @"Custom Object 2"];
	NSArray *indices = @[[NSIndexPath indexPathForItem:12 inSection:0], [NSIndexPath indexPathForItem:16 inSection:0]];
	
	[self.ds add:items atIndexPaths:indices];
	
	XCTAssertEqualObjects(items[0], self.ds.data[12], @"Object added to index 12");
	XCTAssertEqualObjects(items[1], self.ds.data[16], @"Object added to index 16");
	
}

- (DZBasicDatasource *)ds
{
	if(!_ds)
	{
		_ds = [DZBasicDatasource datasourceWithView:[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain]];
	}
	return _ds;
}

- (NSArray *)testBaseData
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"photos" ofType:@"json"];
	XCTAssertNotNil(filePath, @"Photos File Acquired.");
	
	NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:kNilOptions error:nil];
	
	NSArray *photos = data[@"photos"][@"photo"];
	
	return photos;
}

@end
