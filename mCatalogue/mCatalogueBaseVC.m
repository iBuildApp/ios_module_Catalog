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

#import "mCatalogueBaseVC.h"
#import "iphnavbardata.h"
#import "reachability.h"
#import "mCatalogueCartVC.h"
#import "mCatalogueCartAlertView.h"

@interface mCatalogueBaseVC()
{
  mCatalogueSearchBarViewAppearance searchBarAppearance;
}

@end


@implementation mCatalogueBaseVC

-(instancetype)initWithNavBarAppearance:(mCatalogueSearchBarViewAppearance)appearance
{
  self = [super initWithNibName:nil bundle:nil];
  
  if(self){
    searchBarAppearance = appearance;
    _catalogueParams = [mCatalogueParameters sharedParameters];
    
    _colorSkin = nil;
  }
  
  return self;
}

-(instancetype)init
{
  self = [super initWithNibName:nil bundle:nil];
  
  if(self){
    searchBarAppearance = mCatalogueSearchBarViewPureNavigationAppearance;
    _catalogueParams = [mCatalogueParameters sharedParameters];
    
    _colorSkin = nil;
  }
  
  return self;
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  _catalogueParams = nil;
  self.customNavBar = nil;
  self.statusBarView = nil;
  
  _colorSkin = nil;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[self.tabBarController tabBar] setHidden:YES];
  
  //if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
    //self.wantsFullScreenLayout = YES;
      self.extendedLayoutIncludesOpaqueBars = YES;
  //}
  
  self.view.backgroundColor = [UIColor whiteColor];
  [self placeNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  internetReachable = _catalogueParams.isInternetReachable;
  
  self.customNavBar.cartButton.count = _catalogueParams.cart.totalCount;
  self.customNavBar.cartButtonHidden = !_catalogueParams.cartEnabled;
  
  [self.navigationController setNavigationBarHidden:YES];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reachabilityChanged:)
                                               name:kReachabilityChangedNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(customizeNavBarAppearanceCompleted:)
                                               name:TIPhoneNavBarDataCustomizeNavBarAppearanceCompleted
                                             object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{

  [self.navigationController setNavigationBarHidden:YES];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kReachabilityChangedNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:TIPhoneNavBarDataCustomizeNavBarAppearanceCompleted
                                                object:nil];
  
  [super viewWillDisappear:animated];
}

#pragma mark - Interface
-(void)placeNavBar
{
  if(!_customNavBar){
    self.customNavBar = [[mCatalogueSearchBarView alloc] initWithApperance:searchBarAppearance];
    
    CGRect barFrame = (CGRect){0.0f, 0.0f, self.customNavBar.frame.size.width, 20.0f};
    
    UIColor *navBarColor = [_colorSkin navBarBackgroundColor];
    
    self.statusBarView = [[UIView alloc] initWithFrame:barFrame];
    self.statusBarView.backgroundColor = navBarColor;
    [self.view addSubview:self.statusBarView];
    
    self.customNavBar.backgroundColor = navBarColor;
    
    self.customNavBar.frame = CGRectOffset(self.customNavBar.frame, 0.0f, barFrame.size.height);
    self.customNavBar.backgroundColor = navBarColor;
    self.customNavBar.title = self.title;
    self.customNavBar.mCatalogueSearchViewDelegate = self;
    
    [self.view addSubview:self.customNavBar];
  }
}

-(void)customizeNavBarAppearanceCompleted:(NSNotification *)notification
{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(void)setTitle:(NSString *)title
{
  [super setTitle:title];
  self.customNavBar.title = title;
}

#pragma mark - mCatalogueSearchViewDelegate
-(void)mCatalogueSearchViewLeftButtonPressed
{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)mCatalogueSearchViewCartButtonPressed
{
  [self gotoCart];
}

#pragma mark - Navigation
-(void)gotoCart
{
  mCatalogueCartVC *cartVC = [[mCatalogueCartVC alloc] init];
  cartVC.colorSkin = self.colorSkin;
  [self.navigationController pushViewController:cartVC animated:YES];
}

-(void)cartButtonPressed:(mCatalogueItemView *)sender
{
  mCatalogueItem *item = sender.catalogueItem;
  
  [self addCatalogueItemToCart:item];
}

-(void)addCatalogueItemToCart:(mCatalogueItem *)item
{//adding many items
  [_catalogueParams.cart addCatalogueItem:item
                             withQuantity:1];
  
  [self showGotoCartPrompt];
}

-(void)addCatalogueItemToCart:(mCatalogueItem *)item withQuantity:(int)quantity
{//adding many items
  [_catalogueParams.cart addCatalogueItem:item
                             withQuantity:quantity];
  
  [self showGotoCartPrompt];
}

-(void)showGotoCartPrompt
{
  mCatalogueCartAlertView *cartAlert = [[mCatalogueCartAlertView alloc] initWithCartCount:_catalogueParams.cart.totalCount
                                                                                    addCount:1
                                                                               cancelHandler:nil
                                                                               actionHandler:^(UIAlertView *alertView)
                                           {
                                             //cart button was tapped
                                             [self gotoCart];
                                           }];
  [cartAlert show];
}

+ (void)removeUpToViewController:(Class)vcClass
        withNavigationController:(UINavigationController *)navController_
                   exceptCurrent:(BOOL)exceptCurrent_
                        animated:(BOOL)animated_
{
  NSArray *vcStack = [navController_ viewControllers];
  if ( ![vcStack count] )
    return;
  
  NSMutableArray *vcList = [NSMutableArray arrayWithArray:vcStack];
  
  NSInteger lastIndex = [vcStack count] - 1;
  
  NSInteger idx = exceptCurrent_ ? [vcStack count] - 2 : lastIndex;
  if ( idx < 0 )
    return;
  BOOL bFound = NO;
  while ( idx >= 0 )
  {
    UIViewController *vc = [vcList objectAtIndex:idx];
    if ( [vc isKindOfClass:vcClass] )
    {
      [vcList removeObjectAtIndex:idx];
      bFound = YES;
      break;
    }
    [vcList removeObjectAtIndex:idx];
    --idx;
  }
  
  if ( exceptCurrent_ )
  {
    if ( bFound && [vcList count] )
      [navController_ setViewControllers:[NSArray arrayWithArray:vcList]
                                animated:animated_];
  }else{
    // remove current view controller if we can't find specified view controller
    if ( !bFound )
    {
      vcList = [NSMutableArray arrayWithArray:vcStack];
      [vcList removeLastObject];
    }
    if ( [vcList count] )
      [navController_ setViewControllers:[NSArray arrayWithArray:vcList]
                                animated:animated_];
  }
}

-(NSInteger)previousViewControllerIndex
{
  NSArray *viewControllers = self.navigationController.viewControllers;
  NSInteger currentIndex = [viewControllers indexOfObject:self];
  
  return currentIndex - 1;
}

#pragma mark - Reachability
-(void)reachabilityChanged:(NSNotification *) notification
{
  NSLog(@"mCatalogueBaseVC -- reachability changed");
}

#pragma mark - Autorotate handlers

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

-(BOOL)shouldAutorotate
{
  return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationPortrait;
}

#pragma mark - IBSideBar
-(NSArray *)actionsForIBSideBar
{
  self.customNavBar.hamburgerHidden = NO;
  
  if([mCatalogueParameters sharedParameters].cartEnabled)
  {
    return @[self.customNavBar.cartButton.sideBarModuleAction];
  }
  
  return nil;
}

@end
