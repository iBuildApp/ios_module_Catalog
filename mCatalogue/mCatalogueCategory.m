/****************************************************************************
 *                                                                           *
 *  Copyright (C) 2014-2015 iBuildApp, Inc. ( http://ibuildapp.com )         *
 *                                                                           *
 *  This file is part of iBuildApp.                                          *
 *                                                                           *
 *  This Source Code Form is subject to the terms of the iBuildApp License.  *
 *  You can obtain one at http://ibuildapp.com/license/                      *
 *                                                                           *
 ****************************************************************************/

#import "mCatalogueCategory.h"
#import "mCatalogueItem.h"

#import "mCatalogueDBManager.h"

#define mCatalogueCategoryUidKey @"id"

#define mCatalogueCategoryParentCategoryUidKey @"parentid"
#define mCatalogueCategoryVisibleKey @"visible"
#define mCatalogueCategoryValidKey @"valid"

#define mCatalogueCategoryNameKey @"categoryname"

#define mCatalogueCategoryImgUrlKey @"categoryimg"
#define mCatalogueCategoryImgUrlResKey @"categoryimg_res"

#define mCatalogueCategoryOrderKey @"order"

@implementation mCatalogueCategory

@synthesize
showItemsImgs,
items,
subcategories;

- (void)dealloc
{
  self.items  = nil;
  self.subcategories = nil;
   
  [super dealloc];
}

- (id)initWithDictionary:(NSDictionary*)categoryDict
{
  self = [super init];
  
  if (!categoryDict)
  {
    NSLog(@"categoryDict is empty!");
    return self;
  }
  
  if(self){
    self.uid = [[categoryDict objectForKey:mCatalogueCategoryUidKey] integerValue];
    self.order = [[categoryDict objectForKey:mCatalogueCategoryOrderKey] integerValue];
    self.parentCategoryUid = [[categoryDict objectForKey:mCatalogueCategoryParentCategoryUidKey] integerValue];
    self.visible = [[categoryDict objectForKey:mCatalogueCategoryVisibleKey] boolValue];
    self.valid = [[categoryDict objectForKey:mCatalogueCategoryValidKey] boolValue];
    
    self.name = [categoryDict objectForKey:mCatalogueCategoryNameKey];
    
    self.imgUrl = [categoryDict objectForKey:mCatalogueCategoryImgUrlKey];
    self.imgUrlRes = [categoryDict objectForKey:mCatalogueCategoryImgUrlResKey];
    
    items = nil;
    subcategories = nil;
    showItemsImgs = NO;
  }
  return self;
}

- (void)setItems:(NSArray *)items_{
  if(items != items_){
    [items_ retain];
    [items release];
    items = items_;
    
    for(mCatalogueItem *item in items){
      if (item.imgUrl && [item.imgUrl length]){
        self.showItemsImgs = YES;
        break;
      }
    }
  }
}

-(NSString *)description
{
  return [NSString stringWithFormat:@"mCatalogueCategory\nId: %ld, parentCategoryId: %ld name: %@",
                                    (long)self.uid, (long)self.parentCategoryUid, self.name];
}

@end
