//
//  DZBasicDatasource.h
//  DZDatasource
//
//  Created by Nikhil Nigade on 7/28/14.
//  Copyright (c) 2014 Dezine Zync. All rights reserved.
//

#ifndef asyncMain

#define asyncMain(block) {\
    if([NSThread isMainThread])\
    {\
        block();\
    }\
    else\
    {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }\
};

#endif

#ifndef NS_DESIGNATED_INITIALIZER
	#if __has_attribute(objc_designated_initializer)
		#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
	#else
		#define NS_DESIGNATED_INITIALIZER
	#endif
#endif

#import <Foundation/Foundation.h>

@protocol DZDatasource <NSObject>

@optional

// If using a UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

// If using a UICollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DZBasicDatasource : NSObject

@property (nonatomic, strong, setter = setData:) NSMutableArray *data;
@property (nonatomic, weak) id<DZDatasource> delegate;

#pragma mark - Init & Factory
+ (instancetype)datasourceWithView:(id)view;
- (instancetype)initWithView:(id)view NS_DESIGNATED_INITIALIZER;

#pragma mark - Manipulating the Datasource
- (void)setData:(NSMutableArray *)data;

- (void)prepend:(id)items;
- (void)append:(id)items;
- (void)add:(id)items atIndexPaths:(id)indexPaths;
// Two arrays of NSIndexPath objects
- (void)moveItemsAtIndices:(NSArray *)from toIndices:(NSArray *)to;

- (NSArray *)indexPathsFrom:(NSUInteger)from to:(NSUInteger)to;

@end
