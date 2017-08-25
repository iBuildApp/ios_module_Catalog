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

#import "mCatalogue.h"
#import "TBXML.h"
#import <QuartzCore/QuartzCore.h>
#import "functionLibrary.h"
#import "NSString+colorizer.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "NRGridView.h"
#import "customgridcell.h"
#import "NSString+size.h"
#import "NSString+html.h"
#import "gradientselection.h"
#import "navigationcontroller.h"
#import "labelwidget.h"
#import "reachability.h"
#import "IBPayments/IBPCart.h"
#import "IBPayments/IBPCartItem.h"
#import "IBPayments/IBPPayPalManager.h"
#import "iphmainviewcontroller.h"
#import "IBSideBar/IBSideBarModuleAction.h"

#import "mCatalogueParameters.h"
#import "mCatalogueCategory.h"
#import "mCatalogueItem.h"
#import "mCatalogueItemVC.h"
#import "mCatalogueDBManager.h"
#import "mCatalogueEntryView.h"
#import "mCatalogueItemView.h"
#import "mCatalogueCategoryView.h"
#import "mCatalogueEntry.h"
#import "mCatalogueGridCell.h"
#import "mCatalogueRowCell.h"

/*
 * Beware of big xml configs (several Mbs) causing app crashes.
 * So parse xml with categories and and flush its contents to db.
 *
 * Here goes constants for batch size of items and categories, eligible to flush to db
 */
#define kCatalogueItemBatchCapacity 1000
#define kCatalogueCategoryBatchCapacity 1000

#define kCatalogueTableRowGap_Grid 8.0f
#define kCatalogueTableColumnMarginRigth kCatalogueTableColumnMarginLeft
#define kCatalogueTableColumnGap_Row 0.0f // only one column, no gaps
#define kCatalogueTable_PaddingHorizontal_Grid 6.0f

#define kCatalogueAssortmentCategoriesKey @"categories"
#define kCatalogueAssortmentItemsKey @"items"

#define kCatalogueImagelessCategoryCellBackground [[UIColor blackColor] colorWithAlphaComponent:0.2f]

#define kCatalogueNoResultsFoundLabelLeftMargin 20.0f
#define kCatalogueNoResultsFoundLabelOriginY    120.0f
#define kCatalogueNoResultsFoundLabelHeight     25.0f

#define kCatalogueInitialControllerIndexInStack 1
#define kCatalogueStackSizeOnInitialController  2

#define kCatalogueItemBackgroundColor [UIColor whiteColor]

#define kCatalogueMaskViewTag 10003

#define kCatalogueParsedParametersKey @"kCatalogueParsedParametersKey"

mCatalogueDBManager *catalogueDBManager = nil;

typedef struct{
  __unsafe_unretained mCatalogueEntry *first;
  __unsafe_unretained mCatalogueEntry *second;
} mCatalogueEntryPair;

@interface mCatalogueViewController(){
  UIStatusBarStyle initialStatusBarStyle;
  /**
   * Determines if this controller is the first one
   * after user opens the widget
   */
  BOOL isFirstPage;
}

@property(nonatomic, strong) NSMutableDictionary *assortment;
@property(nonatomic, strong) UITableView *catalogueTableView;
@property(nonatomic, assign) int elementIndex;

@end

@implementation mCatalogueViewController{
  NSInteger categoriesCount;
  NSInteger itemsCount;

  UITapGestureRecognizer *cancelSearchGestureRecognizer;

  auth_Share *aSha;
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNavBarAppearance:mCatalogueSearchBarViewDefaultAppearance];

  if ( self )
  {
    self.assortment = [NSMutableDictionary dictionary];

    _categoryToShow = 0;
    _searchToken = nil;
    _inSearchMode = NO;

    aSha = [[auth_Share alloc] init];
  }
  return self;
}

- (void)dealloc
{
  self.catalogueTableView = nil;
  self.assortment = nil;

  if(aSha){
    aSha.delegate = nil;
    aSha.viewController = nil;
    aSha = nil;
  }
}

#pragma mark - XML parsing
/**
 *  Special parser for processing original xml file
 *
 *  @param xmlElement_ XML node
 *  @param params_     Dictionary with module parameters
 */
+ (void)parseXML:(NSValue *)xmlElement_
      withParams:(NSMutableDictionary *)params_
{

//  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//  [request setHTTPMethod:@"GET"];
//  [request setURL:[NSURL URLWithString:@"http://ibuilder.solovathost.com/test/data.catalog.xml"]];
//
//  NSError *error = [[NSError alloc] init];
//  NSHTTPURLResponse *responseCode = nil;
//
//  NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//
//  if([responseCode statusCode] != 200){
//    NSLog(@"Error getting, HTTP status code %li", (long)[responseCode statusCode]);
//  }
//  NSString *s = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
//  NSLog(@"fuckin log %@", s);
//
//
//  NSData *dat = [s dataUsingEncoding:NSUTF8StringEncoding];
//  TBXML *tbxml = [[TBXML newTBXMLWithXMLData:dat
//                                       error:nil ] autorelease];
//
//  TBXMLElement element;
//  element = *[tbxml rootXMLElement];
//
//
//  TBXMLElement *configElement = [TBXML childElementNamed:@"config" parentElement:&element];
//
//
//  NSMutableDictionary *catalogueParsedParameters = [NSMutableDictionary dictionary];
//
//  [self parseParamsFromElement:configElement
//                intoParameters:catalogueParsedParameters];
//
//  [self parseColorskinFromElement:configElement
//                   intoParameters:catalogueParsedParameters];
//
//  [self parsePaymentDataFromElement:&element
//                     intoParameters:catalogueParsedParameters];
//
//  [self parseShoppingCartOptionsFromElement:configElement
//                             intoParameters:catalogueParsedParameters];
//
//
//  [params_ setObject:catalogueParsedParameters forKey:kCatalogueParsedParametersKey];
//
//  BOOL dbIsReady = [self prepareDatabaseAtPath:[mCatalogueParameters dbFilePath:[params_ objectForKey:@"module_id"]]];
//
//  if(dbIsReady){
//    [self persistCatalogueContents:element];
//  }


  TBXMLElement element;
  [xmlElement_ getValue:&element];

  TBXMLElement *configElement = [TBXML childElementNamed:@"config" parentElement:&element];

  NSMutableDictionary *catalogueParsedParameters = [NSMutableDictionary dictionary];

  [self parseParamsFromElement:configElement
                intoParameters:catalogueParsedParameters];

  [self parseColorskinFromElement:configElement
                   intoParameters:catalogueParsedParameters];

  NSMutableDictionary *colorskinDict = [[NSMutableDictionary alloc] init];
  [self parseColorskinFromElement:configElement
                   intoParameters:colorskinDict];
  catalogueParsedParameters[@"colorskinDict"] = colorskinDict;

  [self parsePaymentDataFromElement:&element
                     intoParameters:catalogueParsedParameters];

  [self parseShoppingCartOptionsFromElement:configElement
                             intoParameters:catalogueParsedParameters];


  [params_ setObject:catalogueParsedParameters forKey:kCatalogueParsedParametersKey];

  BOOL dbIsReady = [self prepareDatabaseAtPath:[mCatalogueParameters dbFilePath:[params_ objectForKey:@"module_id"]]];

  if(dbIsReady){
    [self persistCatalogueContents:element];
  }
}

+(void)parseParamsFromElement:(TBXMLElement *)element
               intoParameters:(NSMutableDictionary *)parametersDict
{
  TBXMLElement *mCatalogueParamElement = element->firstChild;

  NSArray *tagList = [NSArray arrayWithObjects:
                      @"title",
                      @"module_id",
                      @"app_id",
                      @"app_name",
                      @"currency",
                      @"mainpagestyle",
                      @"enabled_buttons",
                      @"showimages",
                      nil];

  while( mCatalogueParamElement )
  {
    NSString *elementName = [[TBXML elementName:mCatalogueParamElement] lowercaseString];
    if ( [tagList containsObject:elementName] )
    {
      NSString *tagContent = [TBXML textForElement:mCatalogueParamElement];

      if ( [tagContent length] )

        [parametersDict setValue:tagContent forKey:elementName];
    }
    mCatalogueParamElement = mCatalogueParamElement->nextSibling;
  }
}

+(void)parseColorskinFromElement:(TBXMLElement *)element
                  intoParameters:(NSMutableDictionary *)parametersDict
{
  // search for tag <colorskin>
  TBXMLElement *colorskinElement = [TBXML childElementNamed:@"colorskin" parentElement:element];
  if (colorskinElement)
  {
    // <color1>
    // <color2>
    // <color3>
    // <color4>
    // <color5>
    // <color6>
    // <color7>
    // <color8>
    // <isLight>
    TBXMLElement *colorElement = colorskinElement->firstChild;
    while( colorElement )
    {
      NSString *colorElementContent = [TBXML textForElement:colorElement];

      if ( [colorElementContent length] )
        [parametersDict setValue:colorElementContent forKey:[[TBXML elementName:colorElement] lowercaseString]];

      colorElement = colorElement->nextSibling;
    }
  }
}

+(void)parsePaymentDataFromElement:(TBXMLElement *)element
                    intoParameters:(NSMutableDictionary *)parametersDict
{
  TBXMLElement *paymentDataElement = [TBXML childElementNamed:@"payment_data" parentElement:element];

  NSString *payPalClientId = nil;

  NSNumber *checkoutEnabled = @0;

  if(paymentDataElement){
    TBXMLElement *payPalElement = [TBXML childElementNamed:@"paypal" parentElement:paymentDataElement];

    if(payPalElement){
      TBXMLElement *clientId = [TBXML childElementNamed:@"client_id" parentElement:payPalElement];
      payPalClientId = [TBXML textForElement:clientId];

      if(payPalClientId.length){
        [parametersDict setValue:payPalClientId forKey:@"payPalClientId"];

        checkoutEnabled = @1;
      }
    }
  }

  [parametersDict setObject:checkoutEnabled forKey:@"checkoutEnabled"];
}

+(void)parseShoppingCartOptionsFromElement:(TBXMLElement *)element
                            intoParameters:(NSMutableDictionary *)parametersDict
{
  TBXMLElement *shoppingCartElement = [TBXML childElementNamed:@"shoppingcart" parentElement:element];

  NSNumber *cartEnabled = @0;

  if(shoppingCartElement){

    cartEnabled = @1;

    BOOL checkoutEnabled = [[parametersDict objectForKey:@"checkoutEnabled"] boolValue];

    if(!checkoutEnabled)
    {
      [self parseUserFillableFieldsFromElement:shoppingCartElement
                                intoParameters:parametersDict];
    }
  }

  [parametersDict setObject:cartEnabled forKey:@"cartEnabled"];
}

+(void)parseUserFillableFieldsFromElement:(TBXMLElement *)element
                           intoParameters:(NSMutableDictionary *)parametersDict
{
  mCatalogueUserProfile *userProfile = [mCatalogueUserProfile createWithXMLElement:[TBXML childElementNamed:@"orderform" parentElement:element]];
  mCatalogueConfirmInfo *confInfo = [mCatalogueConfirmInfo createWithXMLElement:[TBXML childElementNamed:@"orderconfirmation" parentElement:element]];
  NSString *cartDescription = @"";
  if ([TBXML childElementNamed:@"cartdescription" parentElement:element]) {
     cartDescription = [TBXML textForElement:[TBXML childElementNamed:@"cartdescription" parentElement:element]];
  }


  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

  NSString *currentLevelKey = @"cartdescription";


  [preferences setObject:cartDescription forKey:currentLevelKey];

    //  Save to disk
  const BOOL didSave = [preferences synchronize];

  if (!didSave)
  {
      //  Couldn't save (I've never seen this happen in real world testing)
  }
//  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL"
//                                                  message:cartDescription
//                                                 delegate:self
//                                        cancelButtonTitle:@"OK"
//                                        otherButtonTitles:nil];
//  [alert show];

  mCatalogueUserProfileItem *note = userProfile.note;

  //we need this to present note as multiline view
  //it is only possible if note is a part of mCatalogueConfirmInfo
  if(note){
    NSMutableArray *fields = [userProfile.fields mutableCopy];

    NSUInteger indexOfNote = [userProfile.fields indexOfObject:note];
    [fields removeObjectAtIndex:indexOfNote];
    [userProfile setFields:fields];

    confInfo.note = note;
  }

  NSData *profileData = [NSKeyedArchiver archivedDataWithRootObject:userProfile];
  NSData *confInfoData = [NSKeyedArchiver archivedDataWithRootObject:confInfo];

  [parametersDict setObject:profileData forKey:mCatalogueUserProfileKey];
  [parametersDict setObject:confInfoData forKey:mCatalogueOrderConfirmInfoKey];
}

/**
 *  Parsing tags and attributes for XML node
 *
 *  @param tagsList      array of valid tag names
 *  @param parentElement XML node
 *
 *  @return Mutable dictionary with parsed data
 */
+ (NSMutableDictionary*) getElementsDictionaryWithTags:(NSArray*)tagsList andParent:(TBXMLElement*)parentElement
{
  NSMutableDictionary *elementMap = [[NSMutableDictionary alloc] init];
  for( NSString *tag in tagsList )
    {
    TBXMLElement *subElement = [TBXML childElementNamed:tag parentElement:parentElement];
    if ( subElement )
      [elementMap setObject:[TBXML textForElement:subElement] forKey:[TBXML elementName:subElement]];
    }

    // processing attributes for <item>:
  TBXMLAttribute * attribute = parentElement->firstAttribute;

    // if attribute is valid
  while (attribute)
    {
    [elementMap setObject:[TBXML attributeValue:attribute] forKey:[TBXML attributeName:attribute]];
      // Obtain the next attribute
    attribute = attribute->next;
    }

  return elementMap;
}

#pragma mark - DB
/**
 * Prepare database: create file and schema if needed
 * @return BOOL succeeded - whether db is ready for use
 */
+ (BOOL)prepareDatabaseAtPath:(NSString *)dbPath{
    //Due to our DB Manager is static variable, but there could be several mCatalogue modules
    //with different db, but one module at a time.
    //So let's release and rewrite DB Manager every time new mCatalogue module launches.
  if(catalogueDBManager){
    catalogueDBManager = nil;
  }

  catalogueDBManager = [[mCatalogueDBManager alloc] initWithDatabaseNamed:dbPath];

  NSError *error = [catalogueDBManager openDatabase];

  if ( error ){
      // can't open database, so database doesn't exists, create database file
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:dbPath
                                                          contents:nil
                                                        attributes:nil];
    if ( !result ){
      catalogueDBManager = nil;
      return NO;
    }

      // now, try to open database
    error = [catalogueDBManager openDatabase];
    if ( error ){
      catalogueDBManager = nil;
      return NO;
    }

  }

    // create tables in database
  [catalogueDBManager createTables];
  [catalogueDBManager closeDatabase];

  return YES;
}

+(void)persistCatalogueContents:(TBXMLElement)element
{
  BOOL categoriesPersisted = YES;
  BOOL itemsPersisted = YES;

  [catalogueDBManager openDatabase];
  [catalogueDBManager beginTransaction];

  /*
   * Better way: since we have config with categories and products with "valid" = 1 or 0
   * If valid = 0, we delete that entries from DB. If 1, we just update.
   */
  [catalogueDBManager deleteCategories];
  [catalogueDBManager deleteProducts];

  // search for tag <category>
  categoriesPersisted = [mCatalogueViewController persistCategoriesWithDBManager:catalogueDBManager parentElement:element];
  // search for tag <item>
  itemsPersisted = [mCatalogueViewController persistItemsWithDBManager:catalogueDBManager parentElement:element];

  [catalogueDBManager commitTransaction];
  [catalogueDBManager closeDatabase];

  NSLog(@"mCatalogue categories persisted: %@\nitems persisted %@",
        categoriesPersisted ? @"OK" : @"FAIL",
             itemsPersisted ? @"OK" : @"FAIL");
}

+(BOOL)persistCategoriesWithDBManager:(const mCatalogueDBManager *)dbManager
                        parentElement:(TBXMLElement)element
{
  BOOL persistenceSucceeded = YES;

  NSArray *subTagList = @[@"categoryname",
                          @"categoryimg",
                          @"categoryimg_res"];

  TBXMLElement *categoryElement = [TBXML childElementNamed:@"categories" parentElement:&element]->firstChild;

  NSMutableArray *categories = [[NSMutableArray alloc] init];

  while (categoryElement)
    {
    NSMutableDictionary *categoryElementMap = [[NSMutableDictionary alloc] init];

    // processing attributes for <category>:
    TBXMLAttribute * attribute = categoryElement->firstAttribute;

    while (attribute)
      {
      [categoryElementMap setObject:[TBXML attributeValue:attribute] forKey:[TBXML attributeName:attribute]];
      attribute = attribute->next;
      }

    // processing sub tags for <category>
    for( NSString *tag in subTagList )
      {
      TBXMLElement *subElement = [TBXML childElementNamed:tag parentElement:categoryElement];
      if (!subElement)
        continue;

      [categoryElementMap setObject:[TBXML textForElement:subElement] forKey:[TBXML elementName:subElement]];
      }

    mCatalogueCategory *category = [[mCatalogueCategory alloc] initWithDictionary:categoryElementMap];
    [categories addObject:category];

    categoryElement = [TBXML nextSiblingNamed:[TBXML elementName:categoryElement] searchFromElement:categoryElement];

    if([categories count] == kCatalogueCategoryBatchCapacity){
      persistenceSucceeded &= [dbManager insertCategories:categories];
      categories = [[NSMutableArray alloc] init];
    }
    }

  if([categories count]){
    persistenceSucceeded &= [dbManager insertCategories:categories];
  }

  categories = nil;

  return persistenceSucceeded;
}

+(BOOL)persistItemsWithDBManager:(const mCatalogueDBManager *)dbManager
                   parentElement:(TBXMLElement)element
{
  BOOL persistenceSucceeded = YES;

  // sub tags in <item>
  NSArray *itemTagList = @[@"itemname",
                           @"itemdescription",
                           @"itemprice",
                           @"itemoldprice",
                           @"itemsku",
                           @"image",
                           @"image_res",
                           @"thumbnail",
                           @"thumbnail_res"];

  TBXMLElement *itemElement = [TBXML childElementNamed:@"items" parentElement:&element]->firstChild;

  NSMutableArray *items = [[NSMutableArray alloc] init];

  while (itemElement)
  {
    NSMutableDictionary *itemElementMap = [[NSMutableDictionary alloc] init];

    // processing attributes for <item>:
    TBXMLAttribute * attribute = itemElement->firstAttribute;

    while (attribute)
      {
      [itemElementMap setObject:[TBXML attributeValue:attribute] forKey:[TBXML attributeName:attribute]];
      attribute = attribute->next;
      }

    // processing sub tags for <category>
    for( NSString *tag in itemTagList )
      {
      TBXMLElement *subElement = [TBXML childElementNamed:tag parentElement:itemElement];
      if (!subElement)
        continue;

      [itemElementMap setObject:[TBXML textForElement:subElement] forKey:[TBXML elementName:subElement]];
      }

    mCatalogueItem *item = [[mCatalogueItem alloc] initWithDictionary:itemElementMap];
    [items addObject:item];
    itemElement = itemElement->nextSibling;

    if([items count] == kCatalogueItemBatchCapacity){
      persistenceSucceeded &= [dbManager insertProducts:items];
      items = [[NSMutableArray alloc] init];
    }
  }

  if([items count]){
    persistenceSucceeded &= [dbManager insertProducts:items];
  }
  items = nil;

  return persistenceSucceeded;
}

-(void)retreiveEntriesByLike:(NSString *)token
{
  mCatalogueDBSearchResult searchResult = [catalogueDBManager searchForToken:token];

  [self processQueriedCategories:searchResult.categories andProducts:searchResult.products];
}

-(void)retreiveEntriesFromCategory:(NSInteger)categoryUid
{
  NSArray *queriedCategories = [catalogueDBManager selectCategoriesWithParentId:categoryUid];
  NSArray *queriedProducts = [catalogueDBManager selectProductsForCategoryId:categoryUid];

  [self processQueriedCategories:queriedCategories andProducts:queriedProducts];
}

-(void)processQueriedCategories:(NSArray *)queriedCategories
                    andProducts:(NSArray *)queriedProducts
{
  NSMutableArray *populatedCategories = [[NSMutableArray alloc] init];
    //uncomment if you want to show only categories with items (products) inside
  for (mCatalogueCategory *category in queriedCategories) {
      //if ([category.items count] || [category.subcategories count]){
    [populatedCategories addObject:category];
      //}
  }

  NSMutableArray *extractedCategories = [NSMutableArray array];
  NSMutableArray *extractedItems = [NSMutableArray array];

  BOOL topAndHavetSubCategory = NO;
  if (populatedCategories.count)
    {
    mCatalogueCategory *firstCategory = [populatedCategories objectAtIndex:0];
    topAndHavetSubCategory = firstCategory.parentCategoryUid == 0 && !firstCategory.subcategories.count;
    }

    // initially single top-level category was expanded
    // if there is only one category with items and no noncategorized items
    // show all the items/subcategories from the category on the top level
  if (topAndHavetSubCategory && ([populatedCategories count] == 1) && ![queriedProducts count]){

    mCatalogueCategory *category = [populatedCategories objectAtIndex:0];

    for(mCatalogueCategory *subcategoty in category.subcategories){
      [extractedCategories addObject:subcategoty];
    }

    for(mCatalogueItem *item in category.items){
      [extractedItems addObject:item];
    }
  } else {
    [extractedCategories addObjectsFromArray:populatedCategories];

    for(mCatalogueItem *item in queriedProducts){
      [extractedItems addObject:item];
    }
  }

  [self populateAssortmentWithCategories:extractedCategories andItems:extractedItems];
}

-(void)populateAssortmentWithCategories:(NSMutableArray *)categories
                               andItems:(NSMutableArray *)items
{
  NSMutableArray *categoriesToPopulate;
  NSMutableArray *itemsToPopulate;

  if(_catalogueParams.isGrid){
      //To preserve correct grid layout we do not allow the number of categories to be odd
      //so we add a fake "category" to have our products start from new row
    if(categories.count % 2){
      [categories addObject:[NSNull null]];
    }

    categoriesToPopulate = [NSMutableArray array];
    itemsToPopulate = [NSMutableArray array];

    [self populateCatalogueEntryPairsArray:categoriesToPopulate withEntriesFromSourceArray:categories];
    [self populateCatalogueEntryPairsArray:itemsToPopulate withEntriesFromSourceArray:items];

  } else {

    categoriesToPopulate = categories;
    itemsToPopulate = items;

  }

  [self.assortment setObject:categoriesToPopulate forKey:kCatalogueAssortmentCategoriesKey];
  [self.assortment setObject:itemsToPopulate forKey:kCatalogueAssortmentItemsKey];

  categoriesCount = [categoriesToPopulate count];
  itemsCount = [itemsToPopulate count];
}

- (void)populateCatalogueEntryPairsArray:(NSMutableArray *)entryPairsArray
              withEntriesFromSourceArray:(NSArray *)sourceArray
{
  if(!entryPairsArray || !sourceArray){
    return;
  }

  NSUInteger entriesCount = sourceArray.count;

  for(NSUInteger i = 0; i < entriesCount; i += 2){
    NSArray *pairArray;

    if(i + 1 != entriesCount){
      pairArray = @[sourceArray[i], sourceArray[i+1]];
    } else {
      pairArray = @[sourceArray[i]];
    }
    [entryPairsArray addObject:pairArray];
  }
}

-(void)retreiveData
{
  if([self isInSearchMode]){
    [self retreiveEntriesByLike:_searchToken];

    NSArray *categories = [self.assortment objectForKey:kCatalogueAssortmentCategoriesKey];
    NSArray *items = [self.assortment objectForKey:kCatalogueAssortmentItemsKey];

    if(!categories || ![categories count]){
      if(!items || ![items count]){
        [self placeNoResultsLabel];
      }
    }
  } else {
    [self retreiveEntriesFromCategory:_categoryToShow];
  }
}

#pragma mark - Input params processing
- (void)setParams:(NSMutableDictionary *)inputParams
{
  [self processInputParams:inputParams];

  NSDictionary *catalogueParsedParameters = [inputParams objectForKey:kCatalogueParsedParametersKey];
  [self processCatalogueParsedParams:catalogueParsedParameters];

  self.title = [inputParams objectForKey:@"title"];
  [self.navigationItem setTitle:_catalogueParams.pageTitle];

  // set values for ColorskinModel
  NSDictionary *colorskinDict = [catalogueParsedParameters objectForKey:@"colorskinDict"];

  self.colorSkin = [[iphColorskinModel alloc] init];

  NSString *isLightValue = [colorskinDict objectForKey:@"isLight"];
  if(isLightValue && [isLightValue length])
    self.colorSkin.isLight = [isLightValue boolValue];

  NSString *color1Value = [colorskinDict objectForKey:@"color1"];
  if(color1Value && [color1Value length])
    self.colorSkin.color1 = [color1Value asColor];

  if([[color1Value uppercaseString]  isEqualToString:@"#FFFFFF"])
    self.colorSkin.color1IsWhite = YES;

  if([[color1Value uppercaseString]  isEqualToString:@"#000000"])
    self.colorSkin.color1IsBlack = YES;

  NSString *color2Value = [colorskinDict objectForKey:@"color2"];
  if(color2Value && [color2Value length])
    self.colorSkin.color2 = [color2Value asColor];

  NSString *color3Value = [colorskinDict objectForKey:@"color3"];
  if(color3Value && [color3Value length])
    self.colorSkin.color3 = [color3Value asColor];

  NSString *color4Value = [colorskinDict objectForKey:@"color4"];
  if(color4Value && [color4Value length])
    self.colorSkin.color4 = [color4Value asColor];

  NSString *color5Value = [colorskinDict objectForKey:@"color5"];
  if(color5Value && [color5Value length])
    self.colorSkin.color5 = [color5Value asColor];

  NSString *color6Value = [colorskinDict objectForKey:@"color6"];
  if(color6Value && [color6Value length])
    self.colorSkin.color6 = [color6Value asColor];

  NSString *color7Value = [colorskinDict objectForKey:@"color7"];
  if(color7Value && [color7Value length])
    self.colorSkin.color7 = [color7Value asColor];

  NSString *color8Value = [colorskinDict objectForKey:@"color8"];
  if(color8Value && [color8Value length])
    self.colorSkin.color8 = [color8Value asColor];
}

-(void)processInputParams:(NSDictionary *)inputParams
{
  _catalogueParams.pageTitle = [inputParams objectForKey:@"title"];
  _catalogueParams.showLink = [[inputParams objectForKey:@"showLink"] boolValue];

  if ([inputParams objectForKey:@"app_id"])
    _catalogueParams.appID = [inputParams objectForKey:@"app_id"];
  else
    _catalogueParams.appID  = @"";

  if ([inputParams objectForKey:@"appName"])
    _catalogueParams.appName = [inputParams objectForKey:@"appName"];
  else
    _catalogueParams.appName  = @"";

  if ([inputParams objectForKey:@"module_id"])
    _catalogueParams.moduleID = [inputParams objectForKey:@"module_id"];
  else
    _catalogueParams.moduleID  = @"";

  NSString *widgetId = [inputParams objectForKey:@"widget_id"];
  _catalogueParams.widgetId = [widgetId integerValue];
}

-(void)processCatalogueParsedParams:(NSDictionary *)catalogueParsedParameters
{
  if (!catalogueParsedParameters || [catalogueParsedParameters count] == 0){
    NSLog(@"parametersDict is empty!!!");
  }

  _catalogueParams.currencyCode = [catalogueParsedParameters objectForKey:@"currency"];

  _catalogueParams.showImages = [[catalogueParsedParameters objectForKey:@"showimages"] isEqualToString:@"on"];
  _catalogueParams.isGrid = [[catalogueParsedParameters objectForKey:@"mainpagestyle"] isEqualToString:@"grid"];
  _catalogueParams.enabledButtons = [catalogueParsedParameters objectForKey:@"enabled_buttons"];
  NSString *s = [catalogueParsedParameters objectForKey:@"enabled_buttons"];

  [[NSUserDefaults standardUserDefaults] setObject:s forKey:@"enabled_buttons"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  NSString *color1String = [catalogueParsedParameters objectForKey:@"color1"];

  if (color1String)
    _catalogueParams.backgroundColor  = [color1String asColor];
  else
    _catalogueParams.backgroundColor  = [UIColor lightGrayColor];

  if([color1String isEqualToString:@"#ffffff"] || [color1String isEqualToString:@"#fff"] || /*Quite impossible, but give it a chance*/ [color1String isEqualToString:@"white"]) {
    _catalogueParams.isWhiteBackground = YES;
  }
  else {
    _catalogueParams.isWhiteBackground = NO;
  }

  if ([catalogueParsedParameters objectForKey:@"color2"])
    _catalogueParams.categoryTitleColor  = [[catalogueParsedParameters objectForKey:@"color2"] asColor];
  else
    _catalogueParams.categoryTitleColor     = [UIColor yellowColor];

  if ([catalogueParsedParameters objectForKey:@"color3"])
    _catalogueParams.captionColor  = [[catalogueParsedParameters objectForKey:@"color3"] asColor];
  else
    _catalogueParams.captionColor = [UIColor yellowColor];

  if ([catalogueParsedParameters objectForKey:@"color4"])
    _catalogueParams.descriptionColor  = [[catalogueParsedParameters objectForKey:@"color4"] asColor];
  else
    _catalogueParams.descriptionColor = [UIColor whiteColor];

  if ([catalogueParsedParameters objectForKey:@"color5"])
    _catalogueParams.priceColor  = [[catalogueParsedParameters objectForKey:@"color5"] asColor];
  else
    _catalogueParams.priceColor = [UIColor blackColor];

  /**
   * At this point catalogueDBManager holds a value of last-used manager
   * Now we obtain and store to that variable a manager, sepcific to our module
   */
  [mCatalogueViewController prepareDatabaseAtPath:[mCatalogueParameters dbFilePath:_catalogueParams.moduleID]];

  _catalogueParams.dbManager = catalogueDBManager;

  NSString *payPalClientId = [catalogueParsedParameters objectForKey:@"payPalClientId"];

  if(payPalClientId.length){
    [IBPPayPalManager initializePayPalWithClientId:payPalClientId];
  }

  _catalogueParams.payPalClientId = payPalClientId;

  _catalogueParams.cartEnabled = [[catalogueParsedParameters objectForKey:@"cartEnabled"] integerValue]; //BOOL

  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

  NSString *cartEnabledKey = @"cartEnabled";

  const BOOL cartEnabled = _catalogueParams.cartEnabled;
  [preferences setBool:cartEnabled forKey:cartEnabledKey];

    //  Save to disk
  [preferences synchronize];


  _catalogueParams.checkoutEnabled = [[catalogueParsedParameters objectForKey:@"checkoutEnabled"] integerValue]; //BOOL

  if(_catalogueParams.cartEnabled && !_catalogueParams.checkoutEnabled){
    @try
    {
      _catalogueParams.confirmInfo = [NSKeyedUnarchiver unarchiveObjectWithData:[catalogueParsedParameters objectForKey:mCatalogueOrderConfirmInfoKey]];
    }
    @catch (NSException *e)
    {
      _catalogueParams.confirmInfo = nil;
    }

    @try
    {
      _catalogueParams.userProfile = [NSKeyedUnarchiver unarchiveObjectWithData:[catalogueParsedParameters objectForKey:mCatalogueUserProfileKey]];
    }
    @catch (NSException *e)
    {
      _catalogueParams.userProfile = nil;
    }

    [self fillUserProfileWithSerializedParamsIfAvailable];
  }

  _catalogueParams.cart = [catalogueDBManager selectCartContents];
}

-(void)fillUserProfileWithSerializedParamsIfAvailable
{
  mCatalogueParameters *serializedParameters = [mCatalogueParameters deserializeParametersWithModuleID:_catalogueParams.moduleID];

  if(serializedParameters){
    _catalogueParams.userProfile = serializedParameters.userProfile;
  }
}

#pragma mark - Interface
-(void)placeTableView
{
  CGRect catalogueTableViewFrame = CGRectOffset(self.view.bounds, 0.0f, CGRectGetMaxY(self.customNavBar.frame));
  catalogueTableViewFrame.size.height -= catalogueTableViewFrame.origin.y;

  self.catalogueTableView = [[UITableView alloc] initWithFrame:catalogueTableViewFrame style:UITableViewStylePlain];
  _catalogueTableView.autoresizesSubviews = YES;
  _catalogueTableView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _catalogueTableView.delegate            = self;
  _catalogueTableView.dataSource          = self;

  [_catalogueTableView setShowsHorizontalScrollIndicator:NO];
  [_catalogueTableView setShowsVerticalScrollIndicator  :NO];

  _catalogueTableView.backgroundColor = self.view.backgroundColor;

  _catalogueTableView.backgroundColor = _catalogueTableView.backgroundColor;

  _catalogueTableView.separatorColor = [UIColor clearColor];

  [self.view insertSubview:self.catalogueTableView belowSubview:self.customNavBar];
}

- (void)placeNoResultsLabel
{
  CGFloat maxLabelWidth = self.view.bounds.size.width - 2*kCatalogueNoResultsFoundLabelLeftMargin;

  UILabel *noResultsLabel = [[UILabel alloc] init];
  noResultsLabel.numberOfLines = 0;
  noResultsLabel.textColor = _catalogueParams.captionColor;
  noResultsLabel.textAlignment = NSTextAlignmentCenter;
  noResultsLabel.text = NSBundleLocalizedString(@"mCatalogue_NoResultsFound", @"There is no result for your query");
  noResultsLabel.backgroundColor = self.view.backgroundColor;
  noResultsLabel.lineBreakMode = NSLineBreakByWordWrapping;

  CGSize actualLabelSize = [noResultsLabel.text sizeForFont:noResultsLabel.font
                                                  limitSize:(CGSize){maxLabelWidth, CGFLOAT_MAX}
                                              lineBreakMode:noResultsLabel.lineBreakMode];

  CGRect noResultsLabelFrame = (CGRect){
    kCatalogueNoResultsFoundLabelLeftMargin,
    kCatalogueNoResultsFoundLabelOriginY + CGRectGetMaxY(self.customNavBar.frame),
    maxLabelWidth,
    actualLabelSize.height
  };

  noResultsLabel.frame = noResultsLabelFrame;

  [self.view addSubview:noResultsLabel];
}

-(void)addTapRecognizerToEntryView:(mCatalogueEntryView *)view{

  if(view){
    UITapGestureRecognizer *recognizer;

    if([view isKindOfClass:[mCatalogueItemView class]]){
      recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showItem:)];
    } else if([view isKindOfClass:[mCatalogueCategoryView class]]){
      recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCategoryContent:)];
    } else {
      return;
    }

    [view addGestureRecognizer:recognizer];
  }
}

-(void)customizeNavBarAppearanceCompleted:(NSNotification *)notification
{
  if(isFirstPage){
    initialStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
  }

  [super customizeNavBarAppearanceCompleted:notification];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  [[self.tabBarController tabBar] setHidden:YES];

  isFirstPage = ([self.navigationController.viewControllers indexOfObject:self] == kCatalogueInitialControllerIndexInStack);

  if(isFirstPage){
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likedItemsLoaded:)
                                                 name:k_auth_Share_LikedItemsLoadedNotificationName
                                               object:nil];

    self.customNavBar.backButtonLabel.text = NSLocalizedString(@"core_rootViewControllerTitle", @"Home");
  }

  self.customNavBar.cartButtonHidden = ![mCatalogueParameters sharedParameters].cartEnabled;

  self.view.backgroundColor = _catalogueParams.backgroundColor;

  [self placeTableView];

  [self retreiveData];

  [self loadLikedItemsIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:NO];

  self.customNavBar.cartButton.sideBarModuleAction.target = self;
  self.customNavBar.cartButton.sideBarModuleAction.selector = @selector(gotoCart);

  self.customNavBar.title = self.title;

  UIEdgeInsets contentInset =  self.catalogueTableView.contentInset;
  CGRect actualizedCatalogueTableView = _catalogueTableView.frame;

  if (_catalogueParams.isGrid) {
    contentInset.top = kCatalogueTableRowGap_Grid;
  }
  else {
    contentInset.top = 0.0f;
    contentInset.bottom = kCatalogueTableRowGap_Grid;
  }

  _catalogueTableView.frame = actualizedCatalogueTableView;
  _catalogueTableView.contentInset = contentInset;

  [self loadLikedItemsIfNeeded];
}

#pragma mark - UITableViewDatasource
- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"CatalogueEntryCell";


  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

  NSArray *categories = [self.assortment objectForKey:kCatalogueAssortmentCategoriesKey];
  NSArray *items = [self.assortment objectForKey:kCatalogueAssortmentItemsKey];

  if(_catalogueParams.isGrid){
    mCatalogueEntryView *firstView = nil;
    mCatalogueEntryView *secondView = nil;

    if(!cell){
      cell = [[mCatalogueGridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
      cell.userInteractionEnabled = YES;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.backgroundColor = self.catalogueTableView.backgroundColor;
    }

    NSArray *catalogueEntryPair = nil;

    if(indexPath.row < categoriesCount){
      //it's grid, we show pair of categories
      catalogueEntryPair = categories[indexPath.row];

      firstView = [[mCatalogueCategoryView alloc] initWithCatalogueEntryViewStyle:mCatalogueEntryViewStyleGrid];

      mCatalogueCategory *firstCategory = [catalogueEntryPair firstObject];
      ((mCatalogueCategoryView *)firstView).catalogueCategory = firstCategory;
      firstView.backgroundColor = _catalogueParams.backgroundColor;

      if(_catalogueParams.isWhiteBackground){
        ((mCatalogueCategoryView *)firstView).imagePlaceholderMaskColor = kCatalogueCategoryDarkMaskColor;
      }

      mCatalogueCategory *secondCategory = [categories[indexPath.row] lastObject];

      if((id)secondCategory != (id)[NSNull null]){
        secondView = [[mCatalogueCategoryView alloc] initWithCatalogueEntryViewStyle:mCatalogueEntryViewStyleGrid];

        ((mCatalogueCategoryView *)secondView).catalogueCategory = secondCategory;
        secondView.backgroundColor = _catalogueParams.backgroundColor;

        if(_catalogueParams.isWhiteBackground){
          ((mCatalogueCategoryView *)secondView).imagePlaceholderMaskColor = kCatalogueCategoryDarkMaskColor;
        }
      }
    }
    else {
      //it's grid, we show pair of items
      NSUInteger itemIndex = indexPath.row - categoriesCount;

      mCatalogueItemView *firstItemView = [[mCatalogueItemView alloc] initWithCatalogueEntryViewStyle:mCatalogueEntryViewStyleGrid];
      firstView = firstItemView;

      catalogueEntryPair = items[itemIndex];

      mCatalogueItem *firstItem = [catalogueEntryPair firstObject];
      firstItemView.catalogueItem = firstItem;
      firstItemView.delegate = self;
      firstView.backgroundColor = kCatalogueItemBackgroundColor;

      if(catalogueEntryPair.count == 2){
        mCatalogueItem *secondItem = [catalogueEntryPair lastObject];

        if(secondItem != (id)[NSNull null]){
          mCatalogueItemView *secondItemView = [[mCatalogueItemView alloc] initWithCatalogueEntryViewStyle:mCatalogueEntryViewStyleGrid];
          secondView = secondItemView;

          secondItemView.catalogueItem = secondItem;
          secondItemView.delegate = self;
          secondView.backgroundColor = kCatalogueItemBackgroundColor;
        }
      }
    }

    [self addTapRecognizerToEntryView:firstView];
    [self addTapRecognizerToEntryView:secondView];

    firstView.catalogueParameters = _catalogueParams;
    secondView.catalogueParameters = _catalogueParams;

    ((mCatalogueGridCell *)cell).firstView = firstView;
    ((mCatalogueGridCell *)cell).secondView = secondView;

  } else {
    mCatalogueEntryView *catalogueEntryView = nil;

    if(!cell){
      cell = [[mCatalogueRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
      cell.userInteractionEnabled = YES;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.backgroundColor = self.catalogueTableView.backgroundColor;
    }

    if(indexPath.row < categoriesCount){
      //it's rows, show screen-wide category
      catalogueEntryView = [[mCatalogueCategoryView alloc] initWithCatalogueEntryViewStyle:mCatalogueEntryViewStyleRow];

      mCatalogueCategory *category = [categories objectAtIndex:indexPath.row];
      ((mCatalogueCategoryView *)catalogueEntryView).catalogueCategory = category;
      ((mCatalogueCategoryView *)catalogueEntryView).catalogueParameters = _catalogueParams;

      catalogueEntryView.backgroundColor = _catalogueParams.backgroundColor;

      if(_catalogueParams.isWhiteBackground){
        ((mCatalogueCategoryView *)catalogueEntryView).imagePlaceholderMaskColor = kCatalogueCategoryDarkMaskColor;
      } else {
        ((mCatalogueCategoryView *)catalogueEntryView).imagePlaceholderMaskColor = catalogueEntryView.backgroundColor;
      }
    }
    else {
     //it's rows, show screen-wide item
      NSUInteger itemIndex = indexPath.row - categoriesCount;

      mCatalogueItemView *itemView = [[mCatalogueItemView alloc] initWithCatalogueEntryViewStyle:mCatalogueEntryViewStyleRow];
      catalogueEntryView = itemView;

      mCatalogueItem *item = [items objectAtIndex:itemIndex];
      itemView.catalogueItem = item;
      itemView.delegate = self;

      catalogueEntryView.backgroundColor = kCatalogueItemBackgroundColor;
    }

    [self addTapRecognizerToEntryView:catalogueEntryView];

    catalogueEntryView.catalogueParameters = _catalogueParams;
    ((mCatalogueRowCell *) cell).catalogueEntryView = catalogueEntryView;
  }

  return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return categoriesCount + itemsCount;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  mCatalogueEntryViewStyle style = _catalogueParams.isGrid ? mCatalogueEntryViewStyleGrid : mCatalogueEntryViewStyleRow;

  CGFloat rowGap = style == mCatalogueEntryViewStyleGrid ? kCatalogueTableRowGap_Grid : kCatalogueTableRowGap_Row;

  CGFloat height = 0.0f;

  //Categories always come first
  if(indexPath.row < categoriesCount){
    height = [mCatalogueCategoryView sizeForStyle:style].height;

    if(style == mCatalogueEntryViewStyleGrid){
      height += rowGap;
    } else {
      //do not add category gap to the last category,
      //because product gap is added
      //if(indexPath.row < categoriesCount - 1){
        height += kCatalogCategoryRowGap_Row;
      //}
    }
  }
  else {
    height = [mCatalogueItemView sizeForStyle:style].height + rowGap;
  }
  return height;
}

#pragma mark - mCatalogue Entry tap recognizer actions

-(void)showItem:(UITapGestureRecognizer *)recognizer
{
  mCatalogueItem *item = ((mCatalogueItemView *) recognizer.view) .catalogueItem;

  mCatalogueItemVC *itemVC = [[mCatalogueItemVC alloc] initWithCatalogueItem:item];
  itemVC.colorSkin = self.colorSkin;

  itemVC.title = isFirstPage ? _catalogueParams.pageTitle : self.title;

  [self.navigationController pushViewController:itemVC animated:YES];
}

-(void)showCategoryContent:(UITapGestureRecognizer *)recognizer
{
  mCatalogueCategory *category = ((mCatalogueCategoryView *) recognizer.view) .catalogueCategory;

  mCatalogueViewController *categoryVC = [[mCatalogueViewController alloc] initWithNibName:nil bundle:nil];
  categoryVC.colorSkin = self.colorSkin;

  categoryVC.categoryToShow = category.uid;
  categoryVC.title = category.name;

  [self.navigationController pushViewController:categoryVC animated:YES];
}

#pragma mark - mCatalogue DB Operation delegates

-(void)didFinishUpdateOperationWithResult:(NSDictionary *)result{
  NSLog(@"didFinishUpdateOperation");
}

-(void)didFinishSelectOperationWithResult:(NSDictionary *)result {
  NSLog(@"didFinishSelectOperation");
}

#pragma mark - mCatalogue SearchView delegate

-(void)mCatalogueSearchViewDidShowSearchField{
  NSLog(@"mCatalogue show search bar");

  cancelSearchGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch:)];

  UIView *maskView = [[UIView alloc] initWithFrame:self.catalogueTableView.frame];
  maskView.backgroundColor = [UIColor clearColor];
  maskView.tag = kCatalogueMaskViewTag;
  [maskView addGestureRecognizer:cancelSearchGestureRecognizer];
  [self.view insertSubview:maskView belowSubview:self.customNavBar];
}


/**
 * Method for handling taps on "<Back"
 */
-(void)mCatalogueSearchViewLeftButtonPressed{
  if(self.isInSearchMode){
    [self.navigationController popToViewController:self.navigationController.viewControllers[kCatalogueInitialControllerIndexInStack] animated:YES];
  } else {
    if(isFirstPage){
      [[NSNotificationCenter defaultCenter] removeObserver:self
                                                      name:k_auth_Share_LikedItemsLoadedNotificationName
                                                    object:nil];

      [[UIApplication sharedApplication] setStatusBarStyle:initialStatusBarStyle];

      [aSha cancelPendingTasksIfAny];

      [self clearImages];
    }

    [self.navigationController popViewControllerAnimated:YES];
  }
}

-(void)mCatalogueSearchViewSearchInitiated:(NSString *)searchToken{
  NSLog(@"mCatalogue Search");

  if(searchToken && [searchToken length]){
    mCatalogueViewController *categoryVC = [[mCatalogueViewController alloc] initWithNibName:nil bundle:nil];
    categoryVC.colorSkin = self.colorSkin;

    categoryVC.inSearchMode = YES;
    categoryVC.searchToken = searchToken;
    categoryVC.categoryToShow = 0;
    categoryVC.title = NSBundleLocalizedString(@"mCatalogue_SearchTitle", @"Search results");

    [self.navigationController pushViewController:categoryVC animated:YES];

    [self.customNavBar cancelSearch];
  }
}

-(void)mCatalogueSearchViewDidCancelSearch{
  //assume that recognzer set on maskView
  UIView *maskView = [self.view viewWithTag:kCatalogueMaskViewTag];

  if(cancelSearchGestureRecognizer){
    [maskView removeGestureRecognizer:cancelSearchGestureRecognizer];
    [maskView removeFromSuperview];
    cancelSearchGestureRecognizer = nil;
  }
}

-(void)cancelSearch:(UITapGestureRecognizer *) recognizer
{
  [self.customNavBar cancelSearch];
}

-(void)clearImages
{
  SDImageCache *imageCache = [SDImageCache sharedImageCache];
  [imageCache clearMemory];
  [imageCache cleanDisk];
}

-(void)loadLikedItemsIfNeeded
{
  if([_catalogueParams isInternetReachable]){
    /**
     * Let's request liked items now and use them when displaying item VC
     */
    if(aSha.user.authentificatedWith == auth_ShareServiceTypeFacebook){

      if(_catalogueParams.likedItemsLoadingState == mCatalogueLikedFacebookItemsLoadingNotStarted ||
         _catalogueParams.likedItemsLoadingState == mCatalogueLikedFacebookItemsLoadingFailed){

        [aSha loadFacebookLikedURLs];
        _catalogueParams.likedItemsLoadingState = mCatalogueLikedFacebookItemsLoadingInProgress;
      }
    }
  }
}

#pragma mark - auth_Share liked fb items loading handler
-(void)likedItemsLoaded:(NSNotification *)notification
{
  NSArray *likedItems = [notification.object allObjects];

  if(_catalogueParams.likedItemsLoadingState == mCatalogueLikedFacebookItemsLoadingInProgress){

    if(_catalogueParams.likedItems){
        //rare case - we have liked smth, but array of liked items was loading at that moment
        //so we put our like in temporary array. Let's merge the arrays
      [_catalogueParams.likedItems addObjectsFromArray:likedItems];
    } else {
      _catalogueParams.likedItems = [likedItems mutableCopy];
    }

    _catalogueParams.likedItemsLoadingState = mCatalogueLikedFacebookItemsLoadingCompletedSuccessfully;
  }
}

#pragma mark -
-(void)didReceiveMemoryWarning
{
  [self clearImages];
  [super didReceiveMemoryWarning];
}

@end
