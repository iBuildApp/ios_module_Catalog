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

#import <SQLiteManager.h>
#import "mCatalogueCart.h"

@class mCatalogueItem;

typedef struct{
  __unsafe_unretained NSArray *categories;
  __unsafe_unretained NSArray *products;
} mCatalogueDBSearchResult;

/**
 *  Extention for SQLiteManager for widget Catalogue/Directory
 */
@interface mCatalogueDBManager : SQLiteManager

/**
 *  Begin database transaction
 */
- (void)beginTransaction;

/**
 *  Commit database transaction
 */
- (void)commitTransaction;

/**
 * create all tables in database: categories, products, cart, user profile and relations between them
 */
- (BOOL)createTables;

/**
 * insert list of categories into the database
 * @param categoryList - category list of elements of type <mCatalogueCategory>
 */
- (BOOL)insertCategories:(NSArray *)categoryList;

/**
 *  insert products into database
 *
 *  @param products_ - product list of type <mCatalogueItem> (add or update)
 *
 *  @return YES - success, NO - failure
 */
- (BOOL)insertProducts:(NSArray *)products_;


/**
 *  deleteProductsWithParentID - remove products with specified parentID
 *
 *  @param uidParent - parent category uid
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteProductsWithParentID:(NSInteger)uidParent;


/**
 *  delete categories
 *
 *  @param categoriesList - list of objects of type <mCatalogueCategory> to remove
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteCategories:(NSArray *)categoriesList;


/**
 *  deleteCategoriesWithParentID - remove categories with specified parentID
 *
 *  @param uidParent - parent category uid
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteCategoriesWithParentID:(NSInteger)uidParent;


/**
 *  delete products
 *
 *  @param productList - list of objects of type <mCatalogueItem> to remove
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteProducts:(NSArray *)productList;


/**
 *  delete all categories
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteCategories;


/**
 *  delete all products
 *
 *  @return YES - when success, NO - failure occured
 */
- (BOOL)deleteProducts;

/**
 *  selects all categories
 *
 *  @return list of objects of type <mCatalogueCategory>
 */
- (NSArray *)selectAllCategories;

/**
 *  selects all categories with specified parent id
 *
 *  @param uidParent - category's parent uid
 *
 *  @return list of objects of type <mCatalogueCategory>
 */
- (NSArray *)selectCategoriesWithParentId:(NSInteger)uidParent;

/**
 *  selects all products
 *
 *  @return list of objects of type <mCatalogueItem>
 */
- (NSArray *)selectAllProducts;

/**
 *  selects product with specified parent id
 *
 *  @param uidParent - product's parent uid
 *
 *  @return object of type <mCatalogueItem>
 */
- (mCatalogueItem *)selectProductWithUID:(NSString *)uid;

/**
 *  selects all products for specified category
 *
 *  @param uidCategory - category uid
 *
 *  @return sorted list of objects of type <mCatalogueItem>
 */
- (NSArray *)selectProductsForCategoryId:(NSInteger)uidCategory;

/**
 *  Performs LIKE search on categories and products
 *
 *  @param token - some string to search for
 *
 *  @return struct mCatalogueDBSearchResult, with NSArray of mCatalogueCategory and NSArray of mCatalogueItem -- the found elements
 */
- (mCatalogueDBSearchResult)searchForToken:(NSString *)token;

/**
 * Selects all CartItems that are currently in the Cart
 */
-(mCatalogueCart *)selectCartContents;

/**
 * Deletes CartItems from productList from DB
 *
 * @param productList - an array of mCatalogueCartItems
 */
-(BOOL)deleteCartItems:(NSArray *)productList;

/**
 * Inserts CartItems from products_ to DB
 *
 * @param products_ - an array of mCatalogueCartItems
 */
-(BOOL)insertCartItems:(NSArray *)products_;

/**
 * Deletes all CartItems that are currently in the Cart
 */
-(void)clearCart;

/**
 * Clears the current Cart and writes items of the provided one
 * @see clearCart
 */
-(void)rewriteCart:(mCatalogueCart *)cart;

@end
