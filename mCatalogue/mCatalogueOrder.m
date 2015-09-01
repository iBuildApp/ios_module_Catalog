  // IBAHeader



#import "mCatalogueOrder.h"
#import "mCatalogueItem.h"

@implementation mCatalogueOrder
@synthesize uid = _uid,
           date = _date,
     totalPrice = _totalPrice,
     totalCount = _totalCount,
         status = _status;

+ (NSUInteger)maxSummaryLength
{
  return 256;     // limit the summary field
}

- (void)initialize
{
  _status      = CatalogueOrderStatusPreparing;
  _uid         = 0;
  _date       = nil;
  _totalPrice = 0LL;
  _totalCount = 0;
}

- (void)reset
{
  self.status     = CatalogueOrderStatusPreparing;
  self.uid        = 0;
  self.date       = nil;
  self.totalPrice = 0LL;
  self.totalCount = 0;
}

- (id)init
{
  self = [super init];
  if ( self )
  {
    [self initialize];
  }
  return self;
}

- (void)dealloc
{
  [self reset];
  [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeInteger:self.uid         forKey:@"mCatalogueOrderItem::uid"];
  [coder encodeInteger:self.status      forKey:@"mCatalogueOrderItem::status"];
  [coder encodeInteger:self.totalCount  forKey:@"mCatalogueOrderItem::totalCount"];
  
  if ( self.date )
    [coder encodeObject:self.date    forKey:@"mCatalogueOrderItem::date"];
  [coder encodeObject:self.totalPrice forKey:@"mCatalogueOrderItem::totalPrice"];
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    self.uid            = [coder decodeIntegerForKey:@"mCatalogueOrderItem::uid"];
    self.status         = [coder decodeIntegerForKey:@"mCatalogueOrderItem::status"];
    self.totalCount     = [coder decodeIntegerForKey:@"mCatalogueOrderItem::totalCount"];
    self.date           = [coder decodeObjectForKey:@"mCatalogueOrderItem::date"];
    self.totalPrice     = [coder decodeObjectForKey:@"mCatalogueOrderItem::totalPrice"];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  mCatalogueOrder *orderItem = [[[self class] alloc] init];
  orderItem.uid         = self.uid;
  orderItem.status      = self.status;
  orderItem.date    = [[self.date    copyWithZone:zone] autorelease];
  orderItem.totalPrice = self.totalPrice;
  orderItem.totalCount = self.totalCount;
  return orderItem;
}

@end


