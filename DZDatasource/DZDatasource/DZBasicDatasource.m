//
//  DZBasicDatasource.m
//  DZDatasource
//
//  Created by Nikhil Nigade on 7/28/14.
//  Copyright (c) 2014 Dezine Zync. All rights reserved.
//

#import "DZBasicDatasource.h"
#import <objc/runtime.h>

@interface DZBasicDatasource()

@property (nonatomic, weak) id view;

@end

@implementation DZBasicDatasource

#pragma mark - Factory

+ (instancetype)datasourceWithView:(id)view
{
    return [[DZBasicDatasource alloc] initWithView:view];
}

#pragma mark - Init
- (instancetype)initWithView:(id)view
{
    NSAssert([view isKindOfClass:[UITableView class]]
			 || [view isKindOfClass:[UICollectionView class]],
			 @"View should be a UITableView or UICollectionView");
	
	if(self = [super init])
    {
        
        [self commonInit];
        
        _view = view;
		
		if([view isKindOfClass:[UITableView class]])
        {
			Protocol *tableDS = objc_allocateProtocol("UITableViewDatasource");
            class_addProtocol([self class], tableDS);
			
			[(UITableView *)_view setDataSource:self];
        }
		else if([view isKindOfClass:[UICollectionView class]])
		{
			Protocol *collectionDS = objc_allocateProtocol("UICollectionViewDatasource");
			class_addProtocol([self class], collectionDS);
			
			[(UICollectionView *)_view setDataSource:self];
		}
        
    }
    
    return self;
    
}

- (void)commonInit
{
    _data = @[].mutableCopy;
}

#pragma mark - Data management

- (void)setData:(NSMutableArray *)data
{
	if(!data) return;
	if(![data isKindOfClass:[NSArray class]]
	   || ![data isKindOfClass:[NSMutableArray class]]) return;
	
    if(![data count]) return;
	
	if(_data == data || [_data isEqualToArray:data]) return;
	
	if([_data count] == 0)
	{
//		New Data!
		_data = data;
		[self reloadView];
		return;
	}
	
	NSLog(@"Adding new data. Have %ld items in it.", (long)[data count]);
	
	NSOrderedSet *oldItemSet = [NSOrderedSet orderedSetWithArray:_data];
	NSOrderedSet *newItemSet = [NSOrderedSet orderedSetWithArray:data];
	
	NSMutableOrderedSet *deletedItems = [oldItemSet mutableCopy];
    [deletedItems minusOrderedSet:newItemSet];
	
    NSMutableOrderedSet *newItems = [newItemSet mutableCopy];
    [newItems minusOrderedSet:oldItemSet];
	
    NSMutableOrderedSet *movedItems = [newItemSet mutableCopy];
    [movedItems intersectOrderedSet:oldItemSet];
	
	NSMutableArray *deletedIndexPaths = [NSMutableArray arrayWithCapacity:[deletedItems count]];
	
    for (id deletedItem in deletedItems)
	{
        [deletedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:deletedItem] inSection:0]];
    }
	
    NSMutableArray *insertedIndexPaths = [NSMutableArray arrayWithCapacity:[newItems count]];
	
    for (id newItem in newItems)
	{
        [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:newItem] inSection:0]];
    }
	
    NSMutableArray *fromIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
    NSMutableArray *toIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
	
    for (id movedItem in movedItems)
	{
        [fromIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:movedItem] inSection:0]];
        [toIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:movedItem] inSection:0]];
    }
	
	_data = data;
	
	if([deletedIndexPaths count])
	{
		[self removeIndexPaths:deletedIndexPaths];
	}
	
	if([insertedIndexPaths count])
	{
		[self addIndexPaths:insertedIndexPaths];
	}
	
	if([fromIndexPaths count]
	   && [toIndexPaths count])
	{
		[self moveIndexPaths:fromIndexPaths toIndexPaths:toIndexPaths];
	}
	
}

- (void)prepend:(id)items
{
	
	if(!items) return;
	
	if([items isKindOfClass:[NSArray class]])
	{
		NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
		for(NSUInteger i=0,x=[items count]; i < x; i++)
		{
			[indexSet addIndex:i];
		}
		
		[self.data insertObjects:items atIndexes:indexSet];
		
		[self addIndexPaths:[self indexPathsFrom:0 to:[items count]]];
		
	}
	else
	{
		[self.data insertObject:items atIndex:0];
		[self addIndexPaths:[self indexPathsFrom:0 to:1]];
	}
	
}

- (void)append:(id)items
{
	
	if(!items) return;
	
	if([items isKindOfClass:[NSArray class]])
	{
		NSUInteger from = [self.data count];
		NSUInteger to = [items count]+from;
		
		[self.data addObjectsFromArray:items];
		
		NSArray *indices = [self indexPathsFrom:from to:to];
		
		[self addIndexPaths:indices];
	}
	else
	{
		[self.data addObject:items];
		
		NSUInteger from = [self.data count];
		[self addIndexPaths:[self indexPathsFrom:from to:from+1]];
	}
	
}

- (void)add:(id)items atIndexPaths:(id)indexPaths
{
    
    if(!items) return;
    
    if([items isKindOfClass:[NSArray class]])
    {
        
        if([indexPaths isKindOfClass:[NSArray class]])
        {
            
//			Check if we have the same number of items and indexPaths
			if([items count] == [indexPaths count])
			{
				NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
				for(NSIndexPath *indexPath in indexPaths)
				{
//					Works for both Table & Collection Views?
					[indexSet addIndex:indexPath.item];
				}
				
				[self.data insertObjects:items atIndexes:indexSet];
				[self addIndexPaths:indexPaths];
				
			}
			else
			{
//				Not the same count. We can't work with the indexPaths. Append the items
				[self append:items];
			}
            
        }
		else
		{
//			Single index path?
//			We should have a single item. Let's check what's inside it.
			if([items count] == 1 && [indexPaths isKindOfClass:[NSIndexPath class]])
			{
				[self.data insertObject:items atIndex:[(NSIndexPath *)indexPaths item]];
				[self addIndexPaths:indexPaths];
			}
			else
			{
				[self append:items];
			}
			
		}
        
    }
    else
    {
        
		if(indexPaths && [indexPaths isKindOfClass:[NSArray class]])
		{
//			One - to - Many. Invalid case. Items are missing.
			[self append:items];
		}
		else if([indexPaths isKindOfClass:[NSIndexPath class]])
		{
			[self.data insertObject:items atIndex:[(NSIndexPath *)indexPaths item]];
			[self addIndexPaths:indexPaths];
		}
		else
		{
			[self append:items];
		}
		
    }
    
}

- (void)moveItemsAtIndices:(NSArray *)from toIndices:(NSArray *)to
{
	
	if([from count] != [to count]) return;
	
	for (NSUInteger i=0, x = [from count]; i < x; i++) {
		
		id obj = [self.data objectAtIndex:((NSIndexPath *)from[i]).item];
		[self.data removeObjectAtIndex:((NSIndexPath *)from[i]).item];
		[self.data insertObject:obj atIndex:((NSIndexPath *)to[i]).item];
		
	}
	
	[self moveIndexPaths:from toIndexPaths:to];
	
}

#pragma mark - Internals - Reload All

- (void)reloadView
{
    if(self.view)
    {
        
 //     Invalidate the layout if our view  is a CollectionView
        [self checkAndInvalidateLayout];
        
        [self.view performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
	
}

- (void)checkAndInvalidateLayout
{
    __weak typeof(self) weakSelf = self;
    
    if([self.view isKindOfClass:[UICollectionView class]])
    {
        asyncMain(^{
            [[(UICollectionView *)weakSelf.view collectionViewLayout] invalidateLayout];
        });
    }
}

#pragma mark - Internals - Reload IndexPaths

- (void)reloadIndexPaths:(id)indexPaths
{
	
	if(!self.view) return;
	
	__weak typeof(self) weakSelf = self;
	
	if ([self.view isKindOfClass:[UICollectionView class]])
	{
		
		if([indexPaths isKindOfClass:[NSArray class]])
		{
			
			asyncMain(^{
				[(UICollectionView *)weakSelf.view reloadItemsAtIndexPaths:indexPaths];
			});
			
		}
		else
		{
			asyncMain(^{
				[(UICollectionView *)weakSelf.view reloadItemsAtIndexPaths:@[indexPaths]];
			});
		}
		
	}
	else
	{
		if([indexPaths isKindOfClass:[NSArray class]])
		{
			asyncMain(^{
				[(UITableView *)weakSelf.view reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
			});
		}
		else
		{
			asyncMain(^{
				[(UITableView *)weakSelf.view reloadRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
			});
		}
	}
	
}

- (void)addIndexPaths:(id)indexPaths
{
	
	if(!self.view) return;
	
	__weak typeof(self) weakSelf = self;
	
	if ([self.view isKindOfClass:[UICollectionView class]])
	{
		
		if([indexPaths isKindOfClass:[NSArray class]])
		{
			asyncMain(^{
				[(UICollectionView *)weakSelf.view insertItemsAtIndexPaths:indexPaths];
			});
		}
		else
		{
			asyncMain(^{
				[(UICollectionView *)weakSelf.view insertItemsAtIndexPaths:@[indexPaths]];
			});
		}
		
	}
	else
	{
		if([indexPaths isKindOfClass:[NSArray class]])
		{
			asyncMain(^{
				[(UITableView *)weakSelf.view insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
			});
		}
		else
		{
			asyncMain(^{
				[(UITableView *)weakSelf.view insertRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
			});
		}
	}
	
}

- (void)removeIndexPaths:(id)indexPaths
{
	
	if(!self.view) return;
	
	__weak typeof(self) weakSelf = self;
	
	if ([self.view isKindOfClass:[UICollectionView class]])
	{
		
		if([indexPaths isKindOfClass:[NSArray class]])
		{
			asyncMain(^{
				[(UICollectionView *)weakSelf.view deleteItemsAtIndexPaths:indexPaths];
			});
		}
		else
		{
			asyncMain(^{
				[(UICollectionView *)weakSelf.view deleteItemsAtIndexPaths:@[indexPaths]];
			});
		}
		
	}
	else
	{
		if([indexPaths isKindOfClass:[NSArray class]])
		{
			asyncMain(^{
				[(UITableView *)weakSelf.view deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
			});
		}
		else
		{
			asyncMain(^{
				[(UITableView *)weakSelf.view deleteRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
			});
		}
	}
	
}

- (void)moveIndexPaths:(id)fromIndexPaths toIndexPaths:(id)toIndexPaths
{
	
	if([fromIndexPaths isKindOfClass:[NSArray class]]
	   && [toIndexPaths isKindOfClass:[NSArray class]]
	   && [fromIndexPaths count] == [toIndexPaths count])
	{
//		We have a proper set
		if(!self.view) return;
		
		__weak typeof(self) weakSelf = self;
		
		if([self.view isKindOfClass:[UICollectionView class]])
		{
			
			for(NSUInteger i=0,x=[fromIndexPaths count]; i < x; i++)
			{
				asyncMain(^{
					[(UICollectionView *)weakSelf.view moveItemAtIndexPath:[fromIndexPaths objectAtIndex:i] toIndexPath:[toIndexPaths objectAtIndex:i]];
				});
			}
			
		}
		else
		{
			
			for(NSUInteger i=0,x=[fromIndexPaths count]; i < x; i++)
			{
				asyncMain(^{
					[(UITableView *)weakSelf.view moveRowAtIndexPath:[fromIndexPaths objectAtIndex:i] toIndexPath:[toIndexPaths objectAtIndex:i]];
				});
			}
			
		}
		
	}
	
}

#pragma mark - Generate IndexPaths

- (NSArray *)indexPathsFrom:(NSUInteger)from to:(NSUInteger)to
{
	NSUInteger total  = to-from;
	
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:total];
	
	if([self.view isKindOfClass:[UICollectionView class]])
	{
		for(NSUInteger i=from,x=to; i < x; i++)
		{
			[indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
		}
	}
	else
	{
		for(NSUInteger i=from,x=to; i < x; i++)
		{
			[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
	}
	
	return [NSArray arrayWithArray:indexPaths];
	
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if([tableView isEqual:self.view])
	{
		return 1;
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if([tableView isEqual:self.view] && section == 0)
	{
		return [self.data count];
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)])
	{
		
		return [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
		
	}
	
	return nil;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
	if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
		
	{
		return [self.delegate tableView:tableView titleForHeaderInSection:section];
	}
	
	return nil;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:titleForFooterInSection:)])
		
	{
		return [self.delegate tableView:tableView titleForFooterInSection:section];
	}
	
	return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	if(self.delegate && [self.delegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)])
	{
		return [self.delegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
	}
	
	return nil;
	
}

@end
