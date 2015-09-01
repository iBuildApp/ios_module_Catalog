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

#import "mCatalogueItem.h"
#import "NSString+html.h"

#define mCatalogueItemUidKey @"id"

#define mCatalogueItemPidKey @"pid"

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

#define mCatalogueItemOrderKey @"order"

@implementation mCatalogueItem

@synthesize
  description,
  priceStr,
  thumbnailUrl,
  thumbnailUrlRes,
  price;

- (id)initWithDictionary:(NSDictionary *)itemDict{
  
  self = [super init];
  
  if (!itemDict){
    NSLog(@"itemDict is empty!");
    return self;
  }
  
  if(self){
    self.uid = [[itemDict objectForKey:mCatalogueItemUidKey] integerValue];
    self.pid = [[itemDict objectForKey:mCatalogueItemPidKey] integerValue];
    self.order = [[itemDict objectForKey:mCatalogueItemOrderKey] integerValue];
    self.parentCategoryUid = [[itemDict objectForKey:mCatalogueItemCategoryUidKey] integerValue];
    self.visible = [[itemDict objectForKey:mCatalogueItemVisibleKey] boolValue];
    self.valid = [[itemDict objectForKey:mCatalogueItemValidKey] boolValue];
    
    self.name = [itemDict objectForKey:mCatalogueItemNameKey];
    self.description = [itemDict objectForKey:mCatalogueItemDescriptionKey];
    
    self.descriptionPlainText = [self.description htmlToNewLinePreservingText];
    
    self.priceStr = [itemDict objectForKey:mCatalogueItemPriceKey];
    
    if(self.priceStr.length){
      self.price = [NSDecimalNumber decimalNumberWithString:self.priceStr];
    } else {
      self.price = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    [self formatPriceStr];
  
    self.imgUrl = [itemDict objectForKey:mCatalogueItemImgUrlKey];
    self.imgUrlRes = [itemDict objectForKey:mCatalogueItemImgUrlResKey];
    self.thumbnailUrl = [itemDict objectForKey:mCatalogueItemThumbnailUrlKey];
    self.thumbnailUrlRes = [itemDict objectForKey:mCatalogueItemThumbnailUrlResKey];
  }
  
  return self;
}

- (void)dealloc
{
  self.description = nil,
  self.descriptionPlainText = nil,
  self.priceStr = nil,
  self.thumbnailUrl = nil,
  self.thumbnailUrlRes = nil;
  self.priceStr = nil;
  
  self.price = nil;
  
  [super dealloc];
}

- (void) formatPriceStr
{
  priceStr = [[self class] formattedPriceStringForPrice:price
                                       withCurrencyCode:self.currencyCode];
}

- (BOOL)hasValidImageWithRes:(NSString *)imageRes orURLString:(NSString *)imageUrlString
{
  BOOL hasImage = NO;
  
  if(imageRes && [imageRes length]){
    
    UIImage *imageImg = [UIImage imageNamed:imageRes];
    
    hasImage |= (imageImg != nil);
  }
  
  if(imageUrlString && [imageUrlString length]){
    hasImage = YES;
  }
  
  return hasImage;
}

- (BOOL)hasThumbnail{
  
  return [self hasValidImageWithRes:thumbnailUrlRes
                        orURLString:thumbnailUrl];
}

-(NSString *)imageUrlStringForThumbnail
{
  //due to compatibility with older/imported catalogues,
  //let's always return full-image url
  return self.imgUrl;
}

- (IBPItem *)asIBPItem
{
  IBPItem *ibpItem = [[[IBPItem alloc] init] autorelease];
  
  ibpItem.pid = self.pid;
  ibpItem.currencyCode = self.currencyCode;
  ibpItem.shortDescription = self.name;
  ibpItem.price = self.price;
  ibpItem.name = self.name;
  
  return ibpItem;
}

-(NSString *)currencyCode
{
  return [mCatalogueParameters sharedParameters].currencyCode;
}

-(void)setPrice:(NSDecimalNumber *)price_
{
  [price_ retain];
  [price release];
  
  price = price_;
  
  [self formatPriceStr];
}

+(NSString *)formattedPriceStringForPrice:(NSDecimalNumber *)aPrice
                         withCurrencyCode:(NSString *)currencyCode
{
  NSString *formattedPrice = nil;
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  numberFormatter.currencyCode = currencyCode;
  
  numberFormatter.locale = [NSLocale currentLocale];
  numberFormatter.maximumFractionDigits = 2;
  
  formattedPrice = [[numberFormatter stringFromNumber:[NSNumber numberWithDouble:[aPrice doubleValue]]] retain];
  
  [numberFormatter release];
  
  return formattedPrice;
}

@end
