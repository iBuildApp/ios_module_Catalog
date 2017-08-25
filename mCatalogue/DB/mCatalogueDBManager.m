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

#import "mCatalogueDBManager.h"
#import "mCatalogueCategory.h"
#import "mCatalogueItem.h"
#import "mCatalogueCartItem.h"

#import "mDBResource.h"

static NSInteger DBVersion = 8;

@implementation mCatalogueDBManager

-(void)beginTransaction
{
  [self doQuery:@"BEGIN TRANSACTION;"];
}

-(void)commitTransaction
{
  [self doQuery:@"COMMIT;"];
}

/**
 * create all tables in database: categories, products, Cart, orders, user profile and relations between them
 */

- (BOOL)createTables
{
  // first query doesn't execute (WTF ???) create dummy query
  NSString *query = @"SELECT * FROM table1";
  [self doQuery:query];
  
  [self openDatabase];
  
  if(![self dbIsUpToDate]){
    [self dropTables];
    [self setDBVersion];
  }
  
  query = @"CREATE TABLE IF NOT EXISTS \"Categories\"\
  (\"Id\" INTEGER NOT NULL,\
  \"CategoryOrder\" INTEGER,\
  \"ParentId\" INTEGER,\
  \"CategoryName\" TEXT NOT NULL  DEFAULT '',\
  \"ImageUrl\" TEXT,\
  \"ImagePath\" TEXT,\
  \"Valid\" BOOL NOT NULL  DEFAULT 1,\
  \"Visibility\" BOOL NOT NULL  DEFAULT 1,\
  PRIMARY KEY (\"Id\"));";
  
  [self doQuery:query];

  query = @"CREATE TABLE IF NOT EXISTS \"Products\"\
  (\"Id\" TEXT NOT NULL,\
  \"Pid\" INTEGER NOT NULL,\
  \"ProductOrder\" INTEGER,\
  \"CategoryId\" INTEGER,\
  \"ProductName\" TEXT,\
  \"Description\" TEXT,\
  \"DescriptionPlainText\" TEXT,\
  \"ProductSKU\" TEXT,\
  \"Price\" INTEGER NOT NULL DEFAULT 0,\
  \"OldPrice\" INTEGER NOT NULL DEFAULT 0,\
  \"ImageUrl\" TEXT,\
  \"ImagePath\" TEXT,\
  \"ThumbnailUrl\" TEXT,\
  \"ThumbnailPath\" TEXT,\
  \"Valid\" BOOL NOT NULL  DEFAULT 1,\
  \"Visibility\" BOOL NOT NULL  DEFAULT 1,\
  PRIMARY KEY (\"Id\"));";
  
  [self doQuery:query];
  
  query = @"CREATE TABLE IF NOT EXISTS \"Cart\"(\
  \"ProductId\" INTEGER NOT NULL,\
  \"Qty\" INTEGER NOT NULL DEFAULT 0,\
  PRIMARY KEY (\"ProductId\"));";
  
  [self doQuery:query];
  
  [self closeDatabase];
  
  return YES;
}

- (BOOL)deleteCategories
{
  NSString *query = @"DELETE FROM Categories;";
  return [self doQuery:query] == nil;
}

- (BOOL)deleteProducts
{
  //  You may want not to delete products from database, but mark them as invalid
  NSString *query = @"DELETE FROM Products;";
  return [self doQuery:query] == nil;
}

/**
 * insert list of categories into the database
 * @param categoryList - category list of elements of type <mCatalogueCategory>
 */
- (BOOL)insertCategories:(NSArray *)categoryList
{
  static NSString *insertStr = @"INSERT OR REPLACE INTO Categories\
  (Id, CategoryOrder, ParentId, CategoryName, ImageUrl, ImagePath, Valid, Visibility) ";

  @autoreleasepool {
    for (mCatalogueCategory *category in categoryList)
    {
      NSString *valuesString =  [NSString stringWithFormat:@"SELECT '%ld', '%ld', '%ld', '%@', '%@', '%@', '%d', '%d' ;",
                                 (long)category.uid,
                                 (long)category.order,
                                 (long)category.parentCategoryUid,
                                 mCatalogueGetCorrectDBString(category.name),
                                 mCatalogueGetCorrectDBString(category.imgUrl),
                                 mCatalogueGetCorrectDBString(category.imgUrlRes),
                                 category.valid,
                                 category.visible];
      
      NSString *query = [insertStr stringByAppendingString:valuesString];
      [self doQuery:query];
    }
  }
  return YES;
}

/**
 *  insert products into database
 *
 *  @param products_ - product list of type <mCatalogueItem> (add or update)
 *
 *  @return YES - success, NO - failure
 */
- (BOOL)insertProducts:(NSArray *)products_
{
  static NSString *insertStr = @"INSERT OR REPLACE INTO Products\
  (Id, Pid, ProductOrder, CategoryId, ProductName, Description, DescriptionPlainText, \
   ProductSKU, Price, OldPrice, ImageUrl, ImagePath, ThumbnailUrl, ThumbnailPath, Valid, Visibility) ";

  @autoreleasepool {
    for (mCatalogueItem *item in products_) {
      
      NSString *valuesString =  [NSString stringWithFormat:@"SELECT '%ld', '%ld', '%ld', '%ld', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d', '%d';",
                                 (long)item.uid,
                                 (long)item.pid,
                                 (long)item.order,
                                 (long)item.parentCategoryUid,
                                 mCatalogueGetCorrectDBString(item.name),
                                 mCatalogueGetCorrectDBString(item.description),
                                 mCatalogueGetCorrectDBString(item.descriptionPlainText),
                                 mCatalogueGetCorrectDBString(item.sku),
                                 [item.price stringValue],
                                 [item.oldPrice stringValue],                                          
                                 mCatalogueGetCorrectDBString(item.imgUrl),
                                 mCatalogueGetCorrectDBString(item.imgUrlRes),
                                 mCatalogueGetCorrectDBString(item.thumbnailUrl),
                                 mCatalogueGetCorrectDBString(item.thumbnailUrlRes),
                                 item.valid,
                                 item.visible];
      
      NSString *query = [insertStr stringByAppendingString:valuesString];
      
      [self doQuery:query];
    }
  }
  return YES;
}

/**
 *  deleteProductsWithParentID - remove products with specified parentID
 *
 *  @param uidParent - parent category uid
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteProductsWithParentID:(NSInteger)uidParent
{
  NSArray *products = [self selectProductsForCategoryId:uidParent];
  [products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    mCatalogueItem *it = (mCatalogueItem *)obj;
    it.valid = NO;
  }];

  return [self insertProducts:products];
}

/**
 *  deleteCategoriesWithParentID - remove categories with specified parentID
 *
 *  @param uidParent - parent category uid
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteCategoriesWithParentID:(NSInteger)uidParent
{
  NSString *query = [NSString stringWithFormat:@"DELETE FROM Categories WHERE ParentId = '%ld';", (long)uidParent ];
  return [self doQuery:query] == nil;
}

/**
 *  delete categories
 *
 *  @param categoriesList - list of objects of type <mCatalogueCategory> to remove
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteCategories:(NSArray *)categoriesList
{
  if (!categoriesList)
  {
    return YES;
  }
  
  NSString *delimiter = @", ";
  NSString *query = @"DELETE FROM Categories WHERE Id IN ( ";
  
  for (int i = 0; i < [categoriesList count]; i++) {
    
    if (i == [categoriesList count] - 1)
      delimiter = @" );";
    
    query = [NSString stringWithFormat:@"%@%ld%@", query, (long)((mCatalogueCategory*)[categoriesList objectAtIndex:i]).uid , delimiter];
  }
  
  [self doQuery:query];
  
  return YES;
  
}

/**
 *  delete products
 *
 *  @param productList - list of objects of type <mCatalogueItem> to remove
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteProducts:(NSArray *)productList
{
  if (!productList)
  {
    return YES;
  }
  
  NSString *delimiter = @", ";
  NSString *query = @"DELETE FROM Products WHERE Id IN ( ";

  for (int i = 0; i < [productList count]; i++) {
    
    if (i == [productList count] - 1)
      delimiter = @" );";
    
    query = [NSString stringWithFormat:@"%@'%ld'%@", query, (long)((mCatalogueItem*)[productList objectAtIndex:i]).uid , delimiter];
  }
  
  [self doQuery:query];
  return YES;
}

/**
 *  selects all categories with specified parent id
 *
 *  @param uidParent - category's parent uid
 *
 *  @return list of objects of type <mCatalogueCategory>
 */
- (NSArray *)selectCategoriesWithParentId:(NSInteger)uidParent
{
  
  static NSString *queryTemplate = @"SELECT Id, CategoryOrder, ParentId, CategoryName, ImageUrl, ImagePath, Valid, Visibility \
  FROM Categories \
  WHERE ParentId = '%d' AND Valid = 1 AND Visibility = 1 ORDER BY CategoryOrder ASC";
  
  NSString *query = [NSString stringWithFormat:queryTemplate, uidParent];

  NSArray *categories = [self selectCategoriesWithQuery:query];
  
    //Let us add subcategories and products to category
  for(mCatalogueCategory *category in categories){
    //Do not extract categories recursively
    NSString *query = [NSString stringWithFormat:queryTemplate, category.uid];
    category.subcategories = [self selectCategoriesWithQuery:query];
    
    category.items = [self selectProductsForCategoryId:category.uid];
  }

  return categories;
}

/**
 *  selects all categories
 *
 *  @return list of objects of type <mCatalogueCategory>
 */
- (NSArray *)selectAllCategories
{ 
  NSString *query =[NSString stringWithFormat:@"SELECT Id, CategoryOrder, ParentId, CategoryName, ImageUrl, ImagePath, Valid, Visibility \
                    FROM Categories \
                    WHERE Valid = 1 \
                    AND Visibility = 1"];

  return [self selectCategoriesWithQuery:query];
}

- (NSArray *) selectCategoriesWithQuery:(NSString *)query
{
  NSArray *rows = [self getRowsForQuery:query];
  NSMutableArray *result = [[NSMutableArray alloc] init];
  
  for (NSDictionary *row in rows) {
    mCatalogueCategory *category = [[mCatalogueCategory alloc] init];
    
    category.uid                = [[row objectForKey:@"Id"] intValue];
    category.order              = [[row objectForKey:@"CategoryOrder"] intValue];
    category.parentCategoryUid  = [[row objectForKey:@"ParentId"] intValue];
    category.name               = [row objectForKey:@"CategoryName"];
    category.imgUrl             = [row objectForKey:@"ImageUrl"];
    category.imgUrlRes          = [row objectForKey:@"ImagePath"];
    category.valid              = [[row objectForKey:@"Valid"] boolValue];
    category.visible            = [[row objectForKey:@"Visibility"] boolValue];
    
    
    
    [result addObject:category];
  }
  return result;
}

/**
 *  selects all products
 *
 *  @return list of objects of type <mCatalogueItem>
 */
- (NSArray *)selectAllProducts
{
  NSString *query = [NSString stringWithFormat:
                     @"SELECT p.Id, p.Pid, p.ProductOrder, p.CategoryId, p.ProductName, p.Description, p.DescriptionPlainText, p.ProductSKU, p.Price, p.OldPrice, p.ImageUrl, p.ImagePath, p.ThumbnailUrl, p.ThumbnailPath, p.Valid, p.Visibility \
                     FROM Products p WHERE p.Valid = 1 AND p.Visibility = 1"];

  return [self selectProductsWithQuery:query];
}

/**
 *  selects product with specified parent id
 *
 *  @param uidParent - product's parent uid
 *
 *  @return object of type <mCatalogueItem>
 */
- (mCatalogueItem *)selectProductWithUID:(NSString *)uid;
{
  NSString *query = [NSString stringWithFormat:
                     @"SELECT p.Id, p.Pid, p.ProductOrder, p.CategoryId, p.ProductName, p.Description, p.DescriptionPlainText, p.ProductSKU, p.Price, p.OldPrice, p.ImageUrl, p.ImagePath, p.ThumbnailUrl, p.ThumbnailPath, p.Valid, p.Visibility \
                     FROM Products p \
                     WHERE p.Id = '%@' AND p.Visibility = 1", uid];
  
  NSArray *rows = [self getRowsForQuery:query];
  
  if (rows && [rows count]){
    NSDictionary *row = [rows objectAtIndex:0];
    
    mCatalogueItem *item = [[mCatalogueItem alloc] init];
    
    item.uid                  = [[row objectForKey:@"Id"] integerValue];
    item.pid                  = [[row objectForKey:@"Pid"] integerValue];
    item.order                = [[row objectForKey:@"ProductOrder"] integerValue];
    item.parentCategoryUid    = [[row objectForKey:@"ParentId"] integerValue];
    item.name                 = [row objectForKey:@"ProductName"];
    item.description          = [row objectForKey:@"Description"];
    item.descriptionPlainText = [row objectForKey:@"DescriptionPlainText"];
    item.sku                  = [row objectForKey:@"ProductSKU"];
    item.price                = [NSDecimalNumber decimalNumberWithString:[[row objectForKey:@"Price"] stringValue]];
    item.oldPrice             = [NSDecimalNumber decimalNumberWithString:
                                                      [[row objectForKey:@"OldPrice"] stringValue]];
    item.imgUrl               = [row objectForKey:@"ImageUrl"];
    item.imgUrlRes            = [row objectForKey:@"ImagePath"];
    item.thumbnailUrl         = [row objectForKey:@"ThumbnailUrl"];
    item.thumbnailUrlRes      = [row objectForKey:@"ThumbnailPath"];
    item.valid                = [[row objectForKey:@"Valid"] boolValue];
    item.visible              = [[row objectForKey:@"Visibility"] boolValue];
    
    return item;
  }
  else {
    return nil;
  }
}

/**
 *  select all products for specified category
 *
 *  @param uidCategory - category uid
 *
 *  @return sorted list of objects of type <mCatalogueItem>
 */

- (NSArray *)selectProductsForCategoryId:(NSInteger)uidCategory
{
  NSString *query = [NSString stringWithFormat:
                     @"SELECT p.Id, p.Pid, p.ProductOrder, p.CategoryId, p.ProductName, p.Description, p.DescriptionPlainText, p.ProductSKU, p.Price, p.OldPrice, p.ImageUrl, p.ImagePath, p.ThumbnailUrl, p.ThumbnailPath, p.Valid, p.Visibility \
                     FROM Products p \
                     WHERE p.CategoryId = '%ld' AND p.Visibility = 1 ORDER BY p.ProductOrder ASC", (long)uidCategory];
  
  return [self selectProductsWithQuery:query];
}

-(BOOL)dbIsUpToDate
{
  NSString *query = @"PRAGMA user_version";
  
  NSArray *rows = [self getRowsForQuery:query];
  
  NSInteger presentVersion = 0;
  
  for(NSDictionary *row in rows){
    presentVersion = [row[@"user_version"] integerValue];
  }
  
  return presentVersion == DBVersion;
}

-(void)setDBVersion
{
  NSString *query = [NSString stringWithFormat:@"PRAGMA user_version = %ld", (long)DBVersion];
  [self doQuery:query];
}

-(void)dropTables
{
  NSString *dropProducts = @"DROP TABLE IF EXISTS Products";
  NSString *dropCategories = @"DROP TABLE IF EXISTS Categories";
  NSString *dropCart = @"DROP TABLE IF EXISTS Cart";
  
  [self doQuery:dropProducts];
  [self doQuery:dropCategories];
  [self doQuery:dropCart];
}

- (NSArray *)selectProductsWithQuery:(NSString *)query
{
  NSArray *rows = [self getRowsForQuery:query];
  NSMutableArray *result = [[NSMutableArray alloc] init];
  
  for (NSDictionary *row in rows) {
    mCatalogueItem *item = [[mCatalogueItem alloc] init];
    
    item.uid                  = [[row objectForKey:@"Id"] integerValue];
    item.pid                  = [[row objectForKey:@"Pid"] integerValue];
    item.order                = [[row objectForKey:@"ProductOrder"] integerValue];
    item.parentCategoryUid    = [[row objectForKey:@"ParentId"] integerValue];
    item.name                 = [row objectForKey:@"ProductName"];
    item.description          = [row objectForKey:@"Description"];
    item.descriptionPlainText = [row objectForKey:@"DescriptionPlainText"];
    item.sku                  = [row objectForKey:@"ProductSKU"];
    item.price                = [NSDecimalNumber decimalNumberWithString:[[row objectForKey:@"Price"] stringValue]];
    item.oldPrice             = [NSDecimalNumber decimalNumberWithString:
                                                      [[row objectForKey:@"OldPrice"] stringValue]];
    item.imgUrl               = [row objectForKey:@"ImageUrl"];
    item.imgUrlRes            = [row objectForKey:@"ImagePath"];
    item.thumbnailUrl         = [row objectForKey:@"ThumbnailUrl"];
    item.thumbnailUrlRes      = [row objectForKey:@"ThumbnailPath"];
    item.valid                = [[row objectForKey:@"Valid"] boolValue];
    item.visible              = [[row objectForKey:@"Visibility"] boolValue];
    
    [result addObject:item];
  }
  return result;
}

- (mCatalogueDBSearchResult)searchForToken:(NSString *)token
{
  mCatalogueDBSearchResult result;
  
  NSString *productsQuery = [NSString stringWithFormat:
                     @"SELECT p.Id, p.Pid, p.ProductOrder, p.CategoryId, p.ProductName, p.Description, p.DescriptionPlainText, p.ProductSKU, p.Price, p.OldPrice, p.ImageUrl, p.ImagePath, p.ThumbnailUrl, p.ThumbnailPath, p.Valid, p.Visibility \
                     FROM Products p \
                     WHERE p.Valid = 1 AND p.Visibility = 1 AND (p.ProductName LIKE '%%%@%%' OR p.DescriptionPlainText LIKE '%%%@%%') ORDER BY ProductName", token, token];

  result.products = [self selectProductsWithQuery:productsQuery];

  result.categories = nil;

  return result;
}

-(void)rewriteCart:(mCatalogueCart *)cart
{
  [self clearCart];
  [self insertCartItems:cart.allItems];
}

/**
 *  insert products into cart
 *
 *  @param products_ - list of objects of type <mCatalogueCartItem>
 *
 *  @return YES - success, NO - failure
 */
- (BOOL)insertCartItems:(NSArray *)products_
{
  if (!products_)
  {
    return NO;
  }
  
  NSString *insertStr = @"INSERT OR REPLACE INTO Cart (ProductId, Qty) ";
  
  for (int i = 0; i < [products_ count]; i++) {
    
    mCatalogueCartItem *cartItem = [products_ objectAtIndex:i];
    
    if(cartItem.count == 0){
      
      [self deleteCartItems:@[cartItem]];
      
    } else {
      NSString *valuesString =  [NSString stringWithFormat:@"SELECT '%ld', '%lu';",
                                 (long)cartItem.item.uid,
                                 (unsigned long)cartItem.count];
      
      NSString *query = [insertStr stringByAppendingString:valuesString];
      
      [self openDatabase];
      [self doQuery:query];
      [self closeDatabase];
    }
  }
  
  return YES;
}

/**
 *  remove products from Cart
 *
 *  @param  productList - list of objects of type <mCatalogueItem> to remove
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteCartItems:(NSArray *)productList
{
  if ( !productList && [productList count] )
  {
    return NO;
  }
  
  static NSString *delimiter = @", ";
  NSMutableString *query = [NSMutableString stringWithString:@"DELETE FROM Cart WHERE ProductId IN ("];
  
  for ( mCatalogueCartItem *item in productList )
  {
    [query appendFormat:@"'%ld'%@", (long)item.item.uid , delimiter];
  }
  
  NSRange lastSeparatorRange = NSMakeRange( [query length] - [delimiter length], [delimiter length] );
  // remove last comma
  [query deleteCharactersInRange:lastSeparatorRange];
  
  [query appendString:@");"];
  
  [self openDatabase];
  [self doQuery:query];
  [self closeDatabase];
  
  return YES;
}

- (mCatalogueCart *)selectCartContents
{
  static NSString *query =  @"SELECT * FROM Cart;";
  
  NSArray *rows = [self getRowsForQuery:query];
  
  mCatalogueCart *cart = [[mCatalogueCart alloc] init];
  
  [self openDatabase];
  
  for (NSDictionary *row in rows) {
    NSUInteger countInCart = [[row objectForKey:@"Qty"] unsignedIntegerValue];
    NSString *productUID = [row objectForKey:@"ProductId"];
    
    mCatalogueItem *item = [self selectProductWithUID:productUID];
    
    [cart addCatalogueItem:item withQuantity:countInCart];
  }
  
  [self closeDatabase];
  
  return cart;
}

-(void)clearCart
{
  [self openDatabase];

  [self doQuery:@"DELETE FROM Cart"];
  
  [self closeDatabase];
}

NSURL *mCatalogueGetCorrectDBURLFromString( NSString *inputString )
{
   if ( inputString && [inputString length] )
      return [NSURL URLWithString:inputString];
   return nil;
}

NSString *mCatalogueGetCorrectDBURL(NSURL *inputURL)
{
   return inputURL ? [inputURL absoluteString] : @"";
}

NSString *mCatalogueGetCorrectDBString(NSString *inputStr)
{
   // elliminate null in database record
   
   if (!inputStr)
      return @"";
   
   if ([inputStr isEqualToString:@"null"])
      return @"";
   
   // replace single "'" symbol with "''" string to avoid SQL error
   return [inputStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

@end
