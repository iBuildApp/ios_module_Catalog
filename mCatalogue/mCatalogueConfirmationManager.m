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



#import "mCatalogueConfirmationManager.h"
#import "mCatalogueParameters.h"
#import "mCatalogueUserProfile.h"
#import "mCatalogueTextField.h"
#import "mCatalogueOrder.h"
#import "mCatalogueCartItem.h"
#import "mCatalogueOrderConfirmVC.h"
#import "mCatalogueCartVC.h"
#import "mCatalogueCartAlertView.h"
#import "IBPlaceHolderTextView.h"

#import "UIView+findFirstResponder.h"

#import "UIColor+HSL.h"

#import <SBJson.h>
#import <MBProgressHUD.h>

#import "IBPayments/IBPPayPalManager.h"

#import "mCatalogueThankYouPageVC.h"

#define kDefaultTextFieldWidth 300.f

#define kTextFieldPhonePaddingX 10.f
#define kTextFieldPhonePaddingY 5.f

#define kTextFieldPadPaddingX     10.f
#define kTextFieldPadTopMargin    30.f
#define kTextFieldPadBottomMargin 20.f

@implementation mCatalogueConfirmationView

-(instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  
  if(self){
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *resignRecognizer = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                        action:@selector(resignTableViewResponder)];
    
    [self addGestureRecognizer:resignRecognizer];
  }
  
  return self;
}

//hide keyboard for this complicated view.
//usefull when this view is a subview of TPKeyboardAvoidingTableView
//to hide keyboard when tapped somewhere outside text felds on this view
-(void)resignTableViewResponder
{
  [self.tableView endEditing:YES];
}

-(void)dealloc
{
  self.orderView = nil;
  self.confirmationView = nil;
  self.tableView = nil;
}

@end


@interface mCatalogueConfirmationManager ()<UITextViewDelegate>
{
  mCatalogueConfirmationView *view;
}
  @property(nonatomic, strong) mCatalogueOrderConfirmVC *orderConfirm;
  @property(nonatomic, assign) BOOL bConfirmationComplete;
  @property(nonatomic, assign) CatalogueUserProfileCellMetrics cellMetrics;    // needs to measure and align content
  @property(nonatomic, strong) IBPPayPalManager *payPalManager;

  @property(nonatomic, strong) mCatalogueParameters *parameters;
@end

@implementation mCatalogueConfirmationManager
@synthesize          delegate = _delegate,
                   cellMetrics = _cellMetrics,
         bConfirmationComplete = _bConfirmationComplete,
  shouldShowConfirmationButton = _shouldShowConfirmationButton;

- (id)init
{
  self = [super init];
  if (self)
  {
    _delegate         = nil;
    _orderConfirm     = nil;
    _shouldShowConfirmationButton = NO;
    _bConfirmationComplete = NO;
    CatalogueUserProfileCellMetrics metrics = { 0.f, 0.f };
    _cellMetrics = metrics;
    _presentingViewController = nil;
    
    self.parameters = [mCatalogueParameters sharedParameters];
  
    if(self.parameters.checkoutEnabled && self.parameters.payPalClientId.length){
      [self initPayPal];
    }
  }
  return self;
}

- (void)dealloc
{
  self.orderConfirm     = nil;
  
  self.presentingViewController = nil;
  
  self.payPalManager.presentingViewController = nil;
  self.payPalManager = nil;
    view = nil;

  
  self.parameters = nil;
}

-(void)initPayPal
{
  self.payPalManager = [[IBPPayPalManager alloc] init];
  self.payPalManager.widgetId = self.parameters.widgetId;
  [self.payPalManager preconnect];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(processPayPalCompletion:)
   name:IBPayPalPaymentCompleted
   object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(notifyPaymentIsNotProcessable:)
   name:IBPayPalPaymentIsNotProcessable
   object:nil];
}

-(void)setPresentingViewController:(mCatalogueBaseVC *)presentingViewController
{
  if(presentingViewController != _presentingViewController){
   
    _presentingViewController = presentingViewController;
    
    _payPalManager.presentingViewController = _presentingViewController;
  }
}


-(UIView *)view
{
  if(!view){
    
    view = [[mCatalogueConfirmationView alloc] initWithFrame:CGRectZero];
    
    [self setupSubviews];
    
    [self setupViewFrame];
    
    [self addSubviews];
  }
  
  return view;
}

-(void)setupSubviews
{
  [self setupOrderView];
  [self setupTableView];
}

-(void)addSubviews
{
  [view addSubview:view.orderView];
  [view addSubview:view.tableView];
}

-(void)setupViewFrame
{
  CGFloat viewHeight = view.orderView.frame.size.height +
  view.tableView.frame.size.height;
  
  CGRect viewFrame = (CGRect)
  {
    0.0f,
    0.0f,
    self.presentingViewController.view.bounds.size.width,
    viewHeight
  };
  
  view.frame = viewFrame;
}

-(void)setupTableView
{
  CGRect tableViewFrame = CGRectZero;

  view.tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
  
  view.tableView.backgroundColor     = [UIColor clearColor];
  view.tableView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  view.tableView.autoresizesSubviews = YES;
  view.tableView.dataSource          = self;
  view.tableView.delegate            = self;
  view.tableView.separatorStyle      = UITableViewCellSeparatorStyleNone;
  
  UIView *footerView = [self makeTableViewFooter];
  
  CGFloat tableViewHeight = footerView.frame.size.height;
  
  if(self.parameters.checkoutEnabled == NO){
    
    UIView *headerView = [self makeTableViewHeader];
    
    tableViewHeight += [mCatalogueUserProfileCell defaultHeight] *
    [self.parameters.userProfile.fields count];
    
    tableViewHeight += headerView.frame.size.height;
    
    view.tableView.tableHeaderView = headerView;
  }
  
  view.tableView.tableFooterView = footerView;
  
  tableViewFrame = (CGRect)
  {
    0.0f,
    CGRectGetMaxY(view.orderView.frame),
    self.presentingViewController.view.bounds.size.width,
    tableViewHeight
  };
  
  self.view.tableView.frame = tableViewFrame;
}

-(void)setupConfirmationButton
{
  NSString *orderButtonTitle = nil;
  SEL orderButtonAction = nil;
  
  if(self.parameters.checkoutEnabled){
    orderButtonTitle = NSBundleLocalizedString(@"mCatalogue_CHECK_OUT", nil);
    orderButtonAction = @selector(checkoutCart:);
  } else {
    orderButtonTitle = NSBundleLocalizedString(@"mCatalogue_SUBMIT_ORDER", nil);
    orderButtonAction = @selector(submitOrder:);
  }
  
  [view.confirmationView.button setTitle:orderButtonTitle
                                forState:UIControlStateNormal];
  
  [view.confirmationView.button setTitleColor:[self.parameters cartSubmitButtonTextColor]
                                     forState:UIControlStateNormal];
  
  view.confirmationView.button.titleLabel.font      = [UIFont systemFontOfSize:20.f];
  view.confirmationView.button.backgroundColor      = self.parameters.priceColor;
  [[view.confirmationView.button layer] setCornerRadius:5.f];
  
  [view.confirmationView.button addTarget:self
                            action:orderButtonAction
                  forControlEvents:UIControlEventTouchUpInside];
  
}

-(void)setupConfirmationNoteField
{
  view.confirmationView.noteFieldHeight = 120.f;
  
  view.confirmationView.noteField.backgroundColor  = [UIColor whiteColor];
  view.confirmationView.noteField.placeholder.text = self.parameters.confirmInfo.note.placeholder;
  view.confirmationView.noteField.autoresizesSubviews = YES;
  view.confirmationView.noteField.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  view.confirmationView.noteField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  [[view.confirmationView.noteField layer] setCornerRadius:5.f];
  [[view.confirmationView.noteField layer] setBorderColor:[UIColor grayColor].CGColor];
  [[view.confirmationView.noteField layer] setBorderWidth:1.f];
  
  NSString *noteValue = self.parameters.confirmInfo.note.value;
  
  view.confirmationView.noteField.text = noteValue ? noteValue : @"";
  view.confirmationView.noteField.font = [UIFont systemFontOfSize:17.0f];
  view.confirmationView.noteField.delegate = self;
  
  self.parameters.confirmInfo.note.valid = [self.parameters.confirmInfo.note isValid];
}

- (void)checkoutCart:(UIButton *)sender_
{
  IBPCart *cart = [self.parameters.cart asIBPCart];
  
  [self.payPalManager checkoutCartWithPayPal:cart];
}

-(UIView *)makeTableViewHeader
{
  mCatalogueUserProfileHeaderView *headerView = [[mCatalogueUserProfileHeaderView alloc]
                                                  initWithFrame:self.presentingViewController.view.bounds];
  
  headerView.autoresizesSubviews = YES;
  headerView.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
  headerView.title.backgroundColor = [UIColor clearColor];
  headerView.title.text            = NSBundleLocalizedString(@"mCatalogue_ENTER_CONTACT_INFO", nil);
  headerView.title.font            = [UIFont systemFontOfSize:18.f];
  headerView.title.textColor       = self.parameters.descriptionColor;
  headerView.labelInsets           = UIEdgeInsetsMake(kTextFieldPhonePaddingY,
                                                      kTextFieldPhonePaddingX,
                                                      kTextFieldPhonePaddingY,
                                                      kTextFieldPhonePaddingX);
  
  headerView.backgroundColor = [UIColor clearColor];
  
  [headerView layoutSubviews];
  
  return headerView;
}

-(UIView *)makeTableViewFooter
{
  view.confirmationView = [[mCatalogueUserProfileOrderConfirmationView alloc]
                            initWithFrame:self.presentingViewController.view.bounds];
  
  if ( self.parameters.confirmInfo.note.visible )
  {
    [self setupConfirmationNoteField];
  }
  
  [self setupConfirmationButton];
  
  [view.confirmationView layoutSubviews];
  
  return view.confirmationView;
}

-(void)setupOrderView
{
  view.orderView = [[mCatalogueCartOrderView alloc]
                     initWithFrame:self.presentingViewController.view.bounds];
  
  view.orderView.autoresizesSubviews = YES;
  view.orderView.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
  view.orderView.backgroundColor     = [UIColor clearColor];
  
  view.orderView.separatorColor      = self.parameters.cartSeparatorColor;
  
  view.orderView.totalLabel.text            = [NSBundleLocalizedString( @"mCatalogue_TOTAL", nil ) stringByAppendingString:@":"];
  view.orderView.totalLabel.textColor       = self.parameters.descriptionColor;
  view.orderView.totalLabel.font            = [UIFont systemFontOfSize:18.f];
  view.orderView.totalLabel.textAlignment   = NSTextAlignmentRight;
  view.orderView.totalLabel.contentMode     = UIViewContentModeRight;
  view.orderView.totalLabel.backgroundColor = view.orderView.backgroundColor;
  
  view.orderView.priceLabel.text            = [mCatalogueItem formattedPriceStringForPrice:self.parameters.cart.totalPrice
                                                                     withCurrencyCode:self.parameters.currencyCode];
  
  view.orderView.priceLabel.textColor       = self.parameters.priceColor;
  view.orderView.priceLabel.font            = [UIFont boldSystemFontOfSize:20.f];
  view.orderView.priceLabel.textAlignment   = NSTextAlignmentRight;
  view.orderView.priceLabel.contentMode     = UIViewContentModeRight;
  view.orderView.priceLabel.backgroundColor = view.orderView.backgroundColor;

  
    // run once layout for footer
  [view.orderView layoutSubviews];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.parameters.userProfile.fields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  mCatalogueUserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if ( cell == nil )
  {
    cell = [mCatalogueUserProfileCell createCellWithCellIdentifier:CellIdentifier
                                                          cellMetrics:&_cellMetrics
                                                             delegate:self];
  }
  
  mCatalogueUserProfileItem *item = [self.parameters.userProfile.fields objectAtIndex:indexPath.row];
  
  [cell updateContentWithItem:item];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [mCatalogueUserProfileCell defaultHeight];
}

- (void)updateInvalidFields:(NSArray *)invalidFields_
{
  if ( ![invalidFields_ count] )
    return;
  
  for ( mCatalogueUserProfileItem *item in invalidFields_ )
    item.valid = NO;
    
  // mark invalid text fields
  [view.tableView reloadRowsAtIndexPaths:[view.tableView indexPathsForVisibleRows]
                        withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark Keyboard notification handler
- (void)keyboardWillShow:(NSNotification*)notification
{
  // this method must be overriden to enable all controls when touched !!! (don't delete it)
}

#pragma mark
#pragma mark shouldChangeCharactersInRange handler
- (void)didChangeTextFieldValueWithString:(NSString *)string_ forCell:(UITableViewCell *)cell_
{
  NSIndexPath *indexPath = [view.tableView indexPathForCell:cell_];
  mCatalogueUserProfileItem *item = [self.parameters.userProfile.fields objectAtIndex:indexPath.row];
  item.value = string_;
  item.valid = YES;
}

#pragma mark
#pragma mark UITextViewDelegate handler
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
  mCatalogueUserProfileItem *item = self.parameters.confirmInfo.note;
  item.value = newString;

  [[view.confirmationView.noteField layer] setBorderColor:[UIColor grayColor].CGColor];
  
  return YES;
}


#pragma mark
#pragma mark confurm order button handler
- (void)submitOrder:(UIButton *)sender
{
  // remove keyboard
  [view.tableView endEditing:YES];
  
  // validate fields
  NSArray *invalidFields = [self.parameters.userProfile validate];
  
  BOOL shouldShowAlertWithNote = YES;
  
  BOOL dataIsValid = ![invalidFields count];
  
  if(self.parameters.confirmInfo.note.visible){
    dataIsValid &= [self.parameters.confirmInfo.note isValid];
  }
  
  if ( !dataIsValid )
  {
    // specialy for incorrect email field
    // display warning message
    if ( [invalidFields count] )
    {
      mCatalogueUserProfileItem *item = [invalidFields objectAtIndex:0];
      
      NSString *msg = [[item.name lowercaseString] isEqualToString:@"email"] ?
                                NSBundleLocalizedString(@"mCatalogue_INCORRECT_EMAIL", nil ):
                                NSBundleLocalizedString(@"mCatalogue_FILL_OUT_FIELDS_MESSAGE", nil );
      
      mCatalogueCartAlertView *alert = [[mCatalogueCartAlertView alloc] initWithTitle:@""
                                                                               message:msg
                                                                     cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK",nil)
                                                                     otherButtonTitles:nil
                                                                            completion:^(UIAlertView *alertView, NSInteger idx)
                                        {
                                          // move focus to first invalid field
                                          mCatalogueUserProfileItem *item = [invalidFields objectAtIndex:0];
                                          // find this item in out list
                                          NSUInteger index = [self.parameters.userProfile.fields indexOfObject:item];
                                          // get cell with this index
                                          mCatalogueUserProfileCell *cell;
                                          NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                          [view.tableView scrollToRowAtIndexPath:indexPath
                                                                atScrollPosition:UITableViewScrollPositionMiddle
                                                                        animated:YES];
                                          
                                          cell = (mCatalogueUserProfileCell *)[view.tableView cellForRowAtIndexPath:indexPath];
                                          [cell.editField becomeFirstResponder];
                                          
                                        }];
      [alert show];
      [self updateInvalidFields:invalidFields];
      // sey not show alert when check note field
      shouldShowAlertWithNote = NO;
    }
    if ( ![self.parameters.confirmInfo.note isValid] )
    {
      if ( shouldShowAlertWithNote )
      {
        // validate note field
        NSString *msg = NSBundleLocalizedString(@"mCatalogue_FILL_OUT_FIELDS_MESSAGE", nil );
        mCatalogueCartAlertView *alert = [[mCatalogueCartAlertView alloc] initWithTitle:@""
                                                                               message:msg
                                                                     cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK",nil)
                                                                     otherButtonTitles:nil
                                                                            completion:^(UIAlertView *alertView, NSInteger idx)
                                          {
                                            [view.confirmationView.noteField becomeFirstResponder];
                                          }];
        [alert show];
      }
      [[view.confirmationView.noteField layer] setBorderColor:[UIColor redColor].CGColor];
    }
    return;
  }else{
    // order has been confirmed, send the order to the endpoint
    // when success sending show will success alert
    // clear cart and append this order into order history
    // show spinner when sending order
    [MBProgressHUD showHUDAddedTo:self.presentingViewController.view animated:YES];
    
    [self.parameters sendOrderWithUserProfile:self.parameters.userProfile
                                         note:self.parameters.confirmInfo.note
                                      success:^(NSData *data)
     {
       [MBProgressHUD hideAllHUDsForView:self.presentingViewController.view animated:YES];
       // parse server response...
       
       SBJsonParser *jsonParser = [SBJsonParser new];
       NSDictionary *serverResp = [jsonParser objectWithData:data];
       if ( serverResp )
       {
         // JSON response must contain order id...
         NSNumber *orderNumber    = [serverResp objectForKey:@"order_number"];
         
         if([orderNumber isEqual:[NSNull null]]){
           [self showOrderErrorMessage:NSBundleLocalizedString(@"mCatalogue_ERROR_SEND_MESSAGE",nil)];
           return;
         }

         BOOL     bCompleteStatus = [[serverResp objectForKey:@"status"] isEqualToString:@"complete"];
         if ( orderNumber && bCompleteStatus )
         {
           [self showOrderSuccessMessageWithOrderNumber:orderNumber.integerValue];
           //------------------------------------------------------------------------------------
           self.bConfirmationComplete = YES;
         }else{
           // detect an error, show error alert
           [self showOrderErrorMessage:[serverResp objectForKey:@"description"]];
           return;
         }
       }else{
         // detect an error, show error alert
         [self showOrderErrorMessage:NSBundleLocalizedString(@"mCatalogue_ERROR_SEND_MESSAGE",nil)];
         return;
       }
       
       [self.parameters serialize];
       
       [self.parameters.cart clear];
       self.parameters.confirmInfo.note.value = @"";

     } failure:^(NSError *error)
     {
       [MBProgressHUD hideAllHUDsForView:self.presentingViewController.view animated:YES];
       
       // show data transfer filure error alert
       UIAlertView *msg = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"general_cellularDataTurnedOff", nil )
                                                      message:NSLocalizedString(@"general_cellularDataTurnOnMessage", nil)
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK", nil)
                                            otherButtonTitles:nil];
       [msg show];
     }];
  }
}

#pragma mark -
// show order accepted success message
- (void)showOrderSuccessMessageWithOrderNumber:(NSInteger)orderNumber_
{
  self.orderConfirm = [[mCatalogueOrderConfirmVC alloc]
                        initWithNavBarAppearance:mCatalogueSearchBarViewPureNavigationAppearance];
  self.orderConfirm.colorSkin = self.presentingViewController.colorSkin;
  
  self.orderConfirm.title = NSBundleLocalizedString( @"mCatalogue_ORDER_CONFIRMATION", nil );
  self.orderConfirm.view.backgroundColor = self.parameters.backgroundColor;
  
  NSInteger previousControllerIndex = self.presentingViewController.previousViewControllerIndex;
  
  if(previousControllerIndex >= 0){
    self.orderConfirm.controllerIndexToPopTo = previousControllerIndex;
  }
  
  mCatalogueOrderSummaryView *summaryView = self.orderConfirm.summaryView;
  
  summaryView.imageView.backgroundColor = self.parameters.backgroundColor;
  summaryView.imageView.contentMode     = UIViewContentModeCenter;
  summaryView.imageView.clipsToBounds   = YES;
  UIImage *cartImage = [self.parameters.backgroundColor isLight] ?
                                  [UIImage imageNamed:resourceFromBundle(@"mCatalogueBigCart")] :
                                  [UIImage imageNamed:resourceFromBundle(@"mCatalogueBigCartDark")];

  summaryView.imageView.image           = cartImage;
  
  NSString *titleStr = self.parameters.confirmInfo.title ?
                                      self.parameters.confirmInfo.title :
                                      NSBundleLocalizedString( @"mCatalogue_YOUR_ORDER_NUMBER", nil);
  summaryView.titleLabel.backgroundColor = [UIColor clearColor];
  
  if ([titleStr containsString:@"{order}"]) {
    summaryView.titleLabel.text = [titleStr stringByReplacingOccurrencesOfString:@"{order}" withString:[@"" stringByAppendingFormat:@"%ld", (long)orderNumber_ ]];
  } else {
    summaryView.titleLabel.text            = [titleStr stringByAppendingFormat:@" %ld", (long)orderNumber_ ];
  }
  
  
  summaryView.titleLabel.font            = [UIFont boldSystemFontOfSize:18.f];
  summaryView.titleLabel.numberOfLines   = 0;
  summaryView.titleLabel.textAlignment   = NSTextAlignmentCenter;
  summaryView.titleLabel.textColor       = self.parameters.priceColor;

  NSString *subTitleStr = self.parameters.confirmInfo.text ?
                                      self.parameters.confirmInfo.text :
                                      NSBundleLocalizedString( @"mCatalogue_THANK_YOU_FOR_ORDER", nil );
  
  summaryView.subtitleLabel.backgroundColor = [UIColor clearColor];
  summaryView.subtitleLabel.text            = subTitleStr;
  
  
  if ([subTitleStr containsString:@"{order}"]) {
    summaryView.subtitleLabel.text = [subTitleStr stringByReplacingOccurrencesOfString:@"{order}" withString:[@"" stringByAppendingFormat:@"%ld", (long)orderNumber_ ]];
  }
  
  summaryView.subtitleLabel.font            = [UIFont systemFontOfSize:18.f];
  summaryView.subtitleLabel.numberOfLines   = 0;
  summaryView.subtitleLabel.textAlignment   = NSTextAlignmentCenter;
  summaryView.subtitleLabel.textColor       = self.parameters.descriptionColor;
  
  summaryView.backgroundColor = self.parameters.backgroundColor;
  
  UINavigationController *navController = self.presentingViewController.navigationController;

  [navController pushViewController:self.orderConfirm animated:YES];
  
  [view.tableView removeFromSuperview];
  view.tableView = nil;
}

// error while ordering
- (void)showOrderErrorMessage:(NSString *)message
{
  // show error alert view (data transfer error)
  UIAlertView *msg = [[UIAlertView alloc] initWithTitle:NSBundleLocalizedString(@"mCatalogue_ORDER_FAILED_TO_SEND",nil)
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK", nil)
                                       otherButtonTitles:nil];
  [msg show];
}

-(void)notifyPaymentIsNotProcessable:(NSNotification *)notification
{
  id item = notification.object;
  
  if(![item isKindOfClass:[IBPCart class]]){
    return;
  }
  
  [[[UIAlertView alloc] initWithTitle:@""
                              message:NSBundleLocalizedString(@"mCatalogue_PaymentIsNotProcessable", @"Payment is not processable!")
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

-(void)processPayPalCompletion:(NSNotification *)notification
{
  [self.parameters.cart clear];
  [self showThankYouPage];
}

-(void)showThankYouPage
{
  mCatalogueThankYouPageVC *thankYouPage = [[mCatalogueThankYouPageVC alloc] init];
  thankYouPage.colorSkin = self.presentingViewController.colorSkin;
  thankYouPage.controllerIndexToPopTo = [self.presentingViewController previousViewControllerIndex];
  
  [self.presentingViewController.navigationController pushViewController:thankYouPage animated:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
  if(textView == view.confirmationView.noteField)
  {
    self.parameters.confirmInfo.note.value = view.confirmationView.noteField.text;
    self.parameters.confirmInfo.note.valid = [self.parameters.confirmInfo.note isValid];
  }
}

@end
