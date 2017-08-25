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

#import "mCatalogueCartVC.h"
#import "TPKeyboardAvoidingTableView.h"
#import "mCatalogueTextField.h"
#import "mCatalogueOrder.h"
#import "mCatalogueItemVC.h"
#import "mCatalogueConfirmationManager.h"
#import "UIColor+HSL.h"
#import "mCatalogueCartOrderView.h"
#import "mCatalogueCartItemCell.h"
#import "NRLabel.h"
#import "mCatalogueCart+priceWidth.h"

#import "UIButton+Extensions.h"

#define kCellHeightPhone 100.f

#define kDefaultAnimationDuration 0.3f
#define kDefaultHeaderTextAlpha   0.75f

#define kImgLeftMargin   10.f
#define kImgRightMargin  10.f
#define kImgTopMargin    10.f
#define kImgBottomMargin 10.f
#define kImgHeight       100.f

#define kMsgLeftMargin   10.f
#define kMsgRightMargin  10.f
#define kMsgTopMargin    10.f
#define kMsgBottomMargin 10.f

@interface mCatalogueCartVC()
  @property(nonatomic,strong) TPKeyboardAvoidingTableView *tableView;
  @property(nonatomic,strong) UIView                      *messageView;

  @property(nonatomic,strong) mCatalogueCart *cart;
  @property(nonatomic,strong) mCatalogueParameters *catalogueParameters;
  @property(nonatomic,strong) mCatalogueConfirmationManager *confirmationManager;

@end

@implementation mCatalogueCartVC
@synthesize messageView = _messageView,
              tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
//    _delegate    = nil;
    _messageView = nil;
    _tableView   = nil;
    _confirmationManager = nil;
  }
  return self;
}

- (void)dealloc
{
  self.tableView   = nil;
  self.messageView = nil;
  
  self.cart = nil;
  self.catalogueParameters = nil;
  
  self.confirmationManager = nil;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[self.tabBarController tabBar] setHidden:YES];
  
  [self update];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.customNavBar.title = NSBundleLocalizedString( @"mCatalogue_TITLE", nil );
  self.customNavBar.cartButtonHidden = YES;
  
  [self update];
}

- (void)update
{
  self.catalogueParameters = mCatalogueParameters.sharedParameters;
  self.cart = self.catalogueParameters.cart;
  
  self.view.backgroundColor = self.catalogueParameters.backgroundColor;
  
  if(!self.cart.allItems.count)
  {
    // if table view exists - delete it
    if ( self.tableView )
    {
      [self.tableView removeFromSuperview];
      self.tableView = nil;
    }
    if ( !self.messageView )
    {
      [self placeEmptyCartMessage];
    }
  }else{
    if ( self.messageView )
    {
      [self.messageView removeFromSuperview];
      self.messageView = nil;
    }
    if ( !self.tableView )
    {
      [self placeTableView];
    }else{
      [self.tableView beginUpdates];
      [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                            withRowAnimation:UITableViewRowAnimationNone];
      [self.tableView endUpdates];
      [self updateTotalPrice];
    }
  }
}

-(void)placeEmptyCartMessage
{
  self.messageView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.messageView.backgroundColor     = [UIColor clearColor];
  self.messageView.autoresizesSubviews = YES;
  self.messageView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  UIImage *cartImage = [[self.catalogueParameters backgroundColor] isLight] ?
  [UIImage imageNamed:resourceFromBundle(@"mCatalogueBigCart")] :
  [UIImage imageNamed:resourceFromBundle(@"mCatalogueBigCartDark")];
  // show cart empty message
  UIImageView *imgView = [[UIImageView alloc] initWithImage:cartImage];
  imgView.frame = CGRectMake(kImgLeftMargin,
                             kImgTopMargin + CGRectGetMaxY(self.customNavBar.frame),
                             CGRectGetWidth ( self.view.bounds ) - kImgLeftMargin - kImgRightMargin,
                             kImgHeight );
  imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
  UIViewAutoresizingFlexibleHeight |
  UIViewAutoresizingFlexibleBottomMargin;
  
  imgView.contentMode   = UIViewContentModeCenter;
  imgView.clipsToBounds = YES;
  [self.messageView addSubview:imgView];
  
  // display empty cart message
  NRLabel *msgLabel = [[NRLabel alloc] initWithFrame:CGRectZero];
  msgLabel.backgroundColor  = [UIColor clearColor];
  msgLabel.textColor        = self.catalogueParameters.descriptionColor;
  msgLabel.font             = [UIFont boldSystemFontOfSize:18.f];
  msgLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth  |
  UIViewAutoresizingFlexibleHeight |
  UIViewAutoresizingFlexibleTopMargin;
  msgLabel.textAlignment     = NSTextAlignmentCenter;
  msgLabel.verticalAlignment = NRLabelVerticalAlignmentTop;
  msgLabel.frame = CGRectMake( kMsgLeftMargin,
                              CGRectGetMaxY(imgView.frame) + kImgBottomMargin + kMsgTopMargin,
                              CGRectGetWidth ( self.view.bounds ) - kMsgLeftMargin - kMsgRightMargin,
                              CGRectGetHeight( self.view.bounds ) - CGRectGetMaxY(imgView.frame) - kImgBottomMargin - kMsgTopMargin  - kMsgBottomMargin );
  msgLabel.text = NSBundleLocalizedString( @"mCatalogue_EMPTY_CART", nil );
  [self.messageView addSubview:msgLabel];
  [self.view insertSubview:self.messageView atIndex:0];
}

-(void)placeTableView
{
  CGFloat offsetY = CGRectGetMaxY(self.customNavBar.frame);
  // cart is't empty display content of cart
  CGRect tableViewFrame = (CGRect)
  {
    0.0f,
    offsetY,
    self.view.bounds.size.width,
    self.view.bounds.size.height - offsetY,
  };
  
  self.tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:tableViewFrame];
  self.tableView.backgroundColor     = self.view.backgroundColor;
  self.tableView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.autoresizesSubviews = YES;
  self.tableView.dataSource          = self;
  self.tableView.delegate            = self;
  self.tableView.separatorStyle      = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.separatorColor      = [self.catalogueParameters cartSeparatorColor];
  
  [self placeConfirmationView];
  
  [self updateTotalPrice];
  [self.view addSubview:self.tableView];
}

-(void)placeConfirmationView
{
  self.confirmationManager = [[mCatalogueConfirmationManager alloc] init];
  self.confirmationManager.presentingViewController = self;
  
  mCatalogueConfirmationView *confirmationManagerView = self.confirmationManager.view;
  
  CGRect confirmationManagerFrame = confirmationManagerView.frame;
  confirmationManagerFrame.origin.y = CGRectGetMaxY(self.tableView.frame);
  
  confirmationManagerView.frame = confirmationManagerFrame;
  
  self.tableView.tableFooterView = confirmationManagerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // number of cell in cart = products count
  return [self.cart.allItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"Cell";
  UITableViewCell *tableCell = nil;
  
    // iPhone cell design
  mCatalogueCartItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if ( cell == nil )
    {
    cell = [mCatalogueCartItemCell createCellWithCellIdentifier:cellIdentifier
                                                       delegate:self];
    }
  
  //fix for clearing cart. after clearing ther were crashes due to
  //indexPath.row was out of bounds of empty cart
  if(self.cart.allItems.count > indexPath.row){
    mCatalogueCartItem *item = [self.cart.allItems objectAtIndex:indexPath.row];
    
    [cell updateContentWithItem:item
                   containImage:YES];
  }
  
  tableCell = cell;
  
  return tableCell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  // fix separators bug in iOS 7
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  // fix separators bug in iOS 7
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return kCellHeightPhone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  mCatalogueCartItem *cartItem = [self.cart.allItems objectAtIndex:indexPath.row];

  mCatalogueItemVC *itemVC = [[mCatalogueItemVC alloc] initWithCatalogueItem:cartItem.item];
  itemVC.colorSkin = self.colorSkin;
  itemVC.title = self.customNavBar.title;
  
  [self.navigationController pushViewController:itemVC animated:YES];
}

- (void)updateTotalPrice
{
  mCatalogueCartOrderView *orderView = self.confirmationManager.view.orderView;

  NSString *strPrice = [mCatalogueItem formattedPriceStringForPrice:self.cart.totalPrice
                                                   withCurrencyCode:self.catalogueParameters.currencyCode];
  
  orderView.priceLabel.text = strPrice;
  self.confirmationManager.view.orderView.hidden = NO;
  self.confirmationManager.view.orderView.totalLabel.hidden = NO;
  self.confirmationManager.view.orderView.priceLabel.hidden = NO;
  if ([self.cart.totalPrice  isEqual: @0]){
    self.confirmationManager.view.orderView.totalLabel.hidden = YES;
    self.confirmationManager.view.orderView.priceLabel.hidden = YES;
  }
  
  [orderView setNeedsLayout];
}

#pragma mark
#pragma mark cell buttons delegate
- (void)didDeleteCell:(UITableViewCell *)cell_
{
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell_];
  
  [self.cart removeItemAtIndex:indexPath.row];

  // remove table cell...
  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                        withRowAnimation:UITableViewRowAnimationFade];
  
  [self updateTotalPrice];
  
  
  // remove footer if cart is empty...
  if ( ![[self.cart allItems] count] )
  {
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    [self performSelector:@selector(update) withObject:nil afterDelay:0.3f];
  }
}

- (void)didChangeItemsForCell:(UITableViewCell *)cell_
{
  [self updateTotalPrice];
}

#pragma mark
#pragma mark toolbar buttons handler
- (void)didDeleteAllProductsFromCart:(UIButton *)sender
{
  // remove all products from cart
  while( [[self.tableView visibleCells] count] )
  {
    UITableViewCell *cell = [[self.tableView visibleCells] lastObject];
    [self didDeleteCell:cell];
  }
}

#pragma mark - IBSideBar
-(NSArray *)actionsForIBSideBar
{
  self.customNavBar.hamburgerHidden = NO;
  
  return nil;
}

@end
