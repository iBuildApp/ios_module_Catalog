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

#import "mCatalogueEntry.h"

#define mCatalogueItemUidKey @"id"

#define mCatalogueItemCategoryUidKey @"categoryid"
#define mCatalogueItemVisibleKey @"visible"
#define mCatalogueItemValidKey @"valid"

#define mCatalogueItemNameKey @"itemname"
#define mCatalogueItemDescriptionKey @"itemdescription"
#define mCatalogueItemPriceKey @"itemprice"
#define mCatalogueItemPriceStrKey @"itemprice_str"

#define mCatalogueItemImgUrlKey @"image"
#define mCatalogueItemImgUrlResKey @"image_res"
#define mCatalogueItemThumbnailUrlKey @"thumbnail"
#define mCatalogueItemThumbnailUrlResKey @"thumbnail_res"

@implementation mCatalogueEntry

@synthesize
uid,
parentCategoryUid,
valid,
visible,
name,
imgUrl,
imgUrlRes;

- (id)initWithDictionary:(NSDictionary *)itemDict{
  
  self = [super init];
  
  if(self){
      name = nil;
      imgUrl = nil;
    imgUrlRes = nil;
  }
  
  return self;
}

- (void)dealloc
{
    self.name = nil;
    self.imgUrl = nil;
  self.imgUrlRes = nil;
}

- (BOOL)hasImage{
  
  BOOL hasImage = NO;
  
  if(imgUrlRes && [imgUrlRes length]){
    UIImage *imageImg = [UIImage imageNamed:imgUrlRes];
    
    hasImage |= (imageImg != nil);
  }
  
  if(imgUrl && [imgUrl length]){
    hasImage = YES;
  }
  
  return hasImage;
}

@end
