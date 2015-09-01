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

#import "mCatalogueCart.h"
#import "mCatalogueDBManager.h"
#import "mCatalogueCartButton.h"

#define kMaxSummaryLength 256

@interface mCatalogueCart()
  @property(nonatomic, strong) NSMutableArray *cartItems;    // product list <mCatalogueCartItem> placed in cart
@end

@implementation mCatalogueCart
@synthesize cartItems = _cartItems,
delegate = _delegate;

- (id)init
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    _cartItems = [[NSMutableArray alloc] init];
    _delegate = nil;
  }
  return self;
}

- (void)initialize
{
  _uid         = 0;
  _date       = nil;
}

- (void)dealloc
{
  [self reset];
  [_cartItems release];
  [super dealloc];
}

- (void)reset
{
  self.uid        = 0;
  self.date       = nil;
}

- (void)setCartItems:(NSMutableArray *)array_
{
  if ( _cartItems != array_ )
  {
    for ( mCatalogueCartItem *item in _cartItems )
      item.delegate = nil;
    
    [_cartItems release];
  
    _cartItems = [array_ retain];
    
    for ( mCatalogueCartItem *item in _cartItems )
    {
      item.delegate = self;
    }
    
    [[mCatalogueParameters sharedParameters].dbManager insertCartItems:_cartItems];
  }
}

- (void)setDelegate:(id<mCatalogueCartDelegate>)delegate_
{
  _delegate = delegate_;
}

- (NSArray *)allItems
{
  return self.cartItems;
}

- (mCatalogueCartItem *)itemAtIndex:(NSUInteger)index_
{
  return index_ < [self.cartItems count] ? [self.cartItems objectAtIndex:index_] : nil;
}

- (void)removeItem:(mCatalogueCartItem *)element_
{
  element_.delegate = nil;
  
  if ( [self.delegate respondsToSelector:@selector(catalogueCart:didDeleteItem:)] )
    [self.delegate catalogueCart:self
                     didDeleteItem:element_];
 
  [[mCatalogueParameters sharedParameters].dbManager deleteCartItems:@[element_]];
  [self.cartItems removeObject:element_];
  
  [self notifyTotalCountChanged];
}

- (void)removeItemAtIndex:(NSUInteger)index_
{
  if ( index_ < [self.cartItems count] )
  {
    mCatalogueCartItem *element = [self.cartItems objectAtIndex:index_];
    element.delegate = nil;
    
    [[mCatalogueParameters sharedParameters].dbManager deleteCartItems:@[element]];

    // call delegate about to delete product from cart
    if ( [self.delegate respondsToSelector:@selector(catalogueCart:didDeleteItem:)] )
    {
      [self.delegate catalogueCart:self
                       didDeleteItem:element];
    }
    
    [self.cartItems removeObjectAtIndex:index_];
  }
}

- (void)removeAllCartItems
{
  for ( mCatalogueCartItem *item in self.cartItems )
  {
    item.delegate = nil;
    
    // call delegate about to delete product from cart
    if ( [self.delegate respondsToSelector:@selector(catalogueCart:didDeleteItem:)] )
      [self.delegate catalogueCart:self
                       didDeleteItem:item];
  }
  
  [self.cartItems removeAllObjects];
  
  [[mCatalogueParameters sharedParameters].dbManager clearCart];
  
  [self notifyTotalCountChanged];
}

- (void)addCatalogueItem:(mCatalogueItem *)product_
      withQuantity:(NSInteger)quantity_
{
  mCatalogueCartItem *item = [[[mCatalogueCartItem alloc] initWithCatalogueItem:product_ count:quantity_] autorelease];
  [self addCartItems:@[item]];
}

- (void)addCartItems:(NSArray *)cartItems
{
  for(mCatalogueCartItem *item in cartItems){
    
    mCatalogueCartItem *existingItem = [self existingItemForItem:item];
    
    if(!existingItem){
      
      item.delegate = self;
      
      [self.cartItems addObject:item];
      
      if ( [self.delegate respondsToSelector:@selector(catalogueCart:didAddItem:)] )
        {
        [self.delegate catalogueCart:self
                          didAddItem:item];
        }
    } else {
      existingItem.count += item.count;
    }
    
    mCatalogueCartItem *itemToPersist = existingItem ? existingItem : item;
    
    [[mCatalogueParameters sharedParameters].dbManager insertCartItems:@[itemToPersist]];
  }
  
  [self notifyTotalCountChanged];
}

-(mCatalogueCartItem *)existingItemForItem:(mCatalogueCartItem *)newItem
{
  for(mCatalogueCartItem *existingItem in self.cartItems){
    if(existingItem.item.uid == newItem.item.uid){
      return existingItem;
    }
  }
  return nil;
}


- (void)catalogueCartItem:(mCatalogueCartItem *)item
             didChangeCount:(NSInteger)newCount_
                   oldCount:(NSInteger)oldCount_
{
  if(newCount_ > 0){
     [[mCatalogueParameters sharedParameters].dbManager insertCartItems:@[item]];
  }
  
  if ( [self.delegate respondsToSelector:@selector(catalogueCart:didChangeQuantityForItem:oldQuantity:newQuantity:)] )
  {
    [self.delegate catalogueCart:self
        didChangeQuantityForItem:item
                     oldQuantity:oldCount_
                     newQuantity:newCount_];
  }
  
  [self notifyTotalCountChanged];
}

-(void)notifyTotalCountChanged
{
  [[NSNotificationCenter defaultCenter] postNotificationName:mCatalogueCartButtonCartCountNotification
                                                      object:[NSNumber numberWithInteger:self.totalCount]];
}

- (NSString *)jsonString
{
  NSString *jsonString = nil;
  
  NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
  
  for(mCatalogueCartItem *item in self.allItems){
    [jsonDict setObject:@(item.count) forKey:@(item.item.pid).stringValue];
  }
  
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                     options:0
                                                       error:&error];
  
  if (error) {
    
    NSLog(@"mCatalogue Cart PayPal JSON Parsing error: %@", error);
    
  } else {
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }

  return jsonString;
}

#pragma mark -
- (void)formatSummary
{
  // format summary with title of products in cart
  NSArray *items = [self allItems];
  if ( [items count] )
  {
    static NSString *strSeparator = @", ";
    NSRange summaryRange = NSMakeRange(0, 0 );
    NSMutableString *strSummary = [[NSMutableString alloc] init];
    for ( mCatalogueCartItem *item in items )
    {
      [strSummary appendString:item.item.name];
      [strSummary appendString:strSeparator];
      if ( [strSummary length] > kMaxSummaryLength + [strSeparator length] )
      {
        summaryRange.length = kMaxSummaryLength;
        break;
      }
      summaryRange.length = [strSummary length] - [strSeparator length];
    }
    self.summary = [strSummary substringWithRange:summaryRange];
    [strSummary release];
  }else{
    self.summary = @"";
  }
}

- (void)clear
{
  // empty cart
  [self removeAllCartItems];
  [self reset];
}

-(NSDecimalNumber *)totalPrice
{
  NSDecimalNumber *totalPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
  
  for(mCatalogueCartItem *item in self.cartItems){
    totalPrice = [totalPrice decimalNumberByAdding:item.totalPrice];
  }
  
  return totalPrice;
}

+ (NSUInteger)maxSummaryLength
{
  return kMaxSummaryLength;
}

-(NSUInteger)totalCount
{
  _totalCount = 0;
  
  for(mCatalogueCartItem *item in self.cartItems){
    _totalCount += item.count;
  }
  
  return _totalCount;
}

- (IBPCart *)asIBPCart
{
  NSMutableArray *cartItems = [NSMutableArray array];
  
  for(mCatalogueCartItem *item in self.cartItems){
    [cartItems addObject:[item asIBPCartItem]];
  }
  
  IBPCart *ibpCart = [[IBPCart alloc] initWithItems:cartItems];
  
  return ibpCart;
}

-(void)persist
{
  [[mCatalogueParameters sharedParameters].dbManager rewriteCart:self];
}

@end
