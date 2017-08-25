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

#import "mCatalogueSearchBarView.h"
#import "NSString+size.h"
#import "UIColor+HSL.h"
//#import "iphone/iphmasterviewcontroller.h"

@interface mCatalogueSearchBarView()
{
  CGRect searchTextFieldCollapsedFrame;
  CGRect searchTextFieldExpandedFrame;
  
  BOOL _cartButtonHidden;
  BOOL _hamburgerHidden;
}
@property (nonatomic, assign, readwrite) mCatalogueSearchBarViewAppearance appearance;
@property (nonatomic, retain) UILabel *cancelSearchLabel;
@property (nonatomic, retain) UIView *searchIconView;
@property (nonatomic, retain) UIView *hamburgerView;
@property (nonatomic, retain) UIView *backLabelView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *foundApplicationsCountLabel;
@property (nonatomic, retain) UIView *separator;

@end

@implementation mCatalogueSearchBarView

@synthesize searchInProgress = searchInProgress;

+(mCatalogueSearchBarView *)sharedCatalogueSearchBarView
{
  static mCatalogueSearchBarView *sharedCatalogueSearchBarView = nil;
  
  static dispatch_once_t onceToken = 0;
  
  dispatch_once(&onceToken, ^{
    sharedCatalogueSearchBarView = [[mCatalogueSearchBarView alloc] initWithApperance:mCatalogueSearchBarViewDefaultAppearance];
  });
  
  return sharedCatalogueSearchBarView;
}

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if(self){
    self.appearance = mCatalogueSearchBarViewDefaultAppearance;
    NSLog(@"mCatalogueSearchBarView: WARNING initWithFrame: constructor invoked, assuming mCatalogueSearchBarViewDefaultAppearance");
    [self setupSelf];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame apperance:(mCatalogueSearchBarViewAppearance) appearance
{
  self = [super initWithFrame:frame];
  
  if(self){
    self.appearance = appearance;
    [self setupSelf];
  }
  return self;
}

- (id)initWithApperance:(mCatalogueSearchBarViewAppearance) appearance
{
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;
  CGRect searchBarRect = (CGRect){0.0f, 0.0f, screenWidth, kToolbarHeight};
  
  self = [super initWithFrame:searchBarRect];
  
  if(self){
    self.appearance = appearance;
    [self setupSelf];
  }
  return self;
}

- (void)setupSelf
{
  searchInProgress = NO;
  _titleLabel = nil;
  _backButtonLabel = nil;
  _searchTextField = nil;
  _cancelSearchLabel = nil;
  _searchIconView = nil;
  _hamburgerView = nil;
  _foundApplicationsCountLabel = nil;
  _cartButton = nil;
  
  _cartButtonHidden = YES;
  _hamburgerHidden = YES;
  
  switch(self.appearance){
    default:
      NSLog(@"mCatalogueSearchBarView: WARNING unrecognized appearance, assumed mCatalogueSearchBarViewDefaultAppearance");
    case mCatalogueSearchBarViewPureNavigationAppearance:
    case mCatalogueSearchBarViewDefaultAppearance:
      [self placeNavigationBackView];
      break;
  }
  
  [self placeSearchIconImageView];
  
  [self placeCartButton]; //hidden by default
  
  [self placeHamburgerView];  //hidden by default
  
  [self placeTitleLabel];
  
  if(self.appearance == mCatalogueSearchBarViewPureNavigationAppearance){
    
    self.searchIconView.hidden = YES;
    
  } else {
    
    [self placeCancelSearchLabel];
    self.cancelSearchLabel.hidden = YES;
    
    [self placeSearchTextField];
    self.searchTextField.hidden = YES;
    
  }
  
  self.backgroundColor = [UIColor blackColor];
}

- (void) centerView:(UIView *)view
{
  CGFloat centerY = self.frame.size.height / 2;
  
  CGPoint viewCenter = view.center;
  viewCenter.y = centerY;
  view.center = viewCenter;
}

- (void) placeNavigationBackView
{
  self.backLabelView = [[UIView alloc] initWithFrame:(CGRect){0.0f, 0.0f, 82.0f, self.frame.size.height}];
  UIImage *backImg = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_back")];
  UIImageView *backImgView = [[UIImageView alloc] initWithImage:backImg];
  backImgView.frame = (CGRect){7.0f, 0.0f, 13.0f, 20.0f};
  [self centerView:backImgView];
  [self.backLabelView addSubview:backImgView];
  
  self.backButtonLabel = [[UILabel alloc] init];
  _backButtonLabel.frame = (CGRect){23.0f, 0.0f, 64.0f, self.frame.size.height};
  _backButtonLabel.textAlignment = NSTextAlignmentLeft;
  _backButtonLabel.text = NSBundleLocalizedString(@"mCatalogue_Back", @"Back");
  _backButtonLabel.textColor = [UIColor blackColor];
  _backButtonLabel.font = [UIFont systemFontOfSize: 16];
  _backButtonLabel.backgroundColor = [UIColor clearColor];
  [self centerView:_backButtonLabel];
  [self.backLabelView addSubview:_backButtonLabel];
  
  UITapGestureRecognizer *backTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonPressed)];
  [self.backLabelView addGestureRecognizer:backTapRecognizer];
  [self addSubview:self.backLabelView];
}

-(UIView *)hamburgerView
{
  if(!_hamburgerView)
  {
    CGFloat hamburgerOriginX = self.frame.size.width - kToolbarHeight - 7.0f;
    
    CGRect hamburgerFrame = (CGRect){hamburgerOriginX, 0.0f, kToolbarHeight, kToolbarHeight};
    
    _hamburgerView = [[UIView alloc] initWithFrame:hamburgerFrame];
    _hamburgerView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *hamburgerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hamburgerPressed)];
    [_hamburgerView addGestureRecognizer:hamburgerTapRecognizer];
    
    UIImage *hamburger = [UIImage imageNamed:resourceFromBundle(@"mCatalogueHamburger_black")];
    UIImageView *hamburgerImageView = [[UIImageView alloc] initWithImage:hamburger];
    hamburgerImageView.contentMode = UIViewContentModeCenter;
    
    hamburgerImageView.frame = _hamburgerView.bounds;
    hamburgerImageView.center = (CGPoint){hamburgerImageView.center.x, _hamburgerView.center.y};
    
    [_hamburgerView addSubview:hamburgerImageView];
  }
  
  return _hamburgerView;
}

- (void) placeHamburgerView
{
  [self addSubview:self.hamburgerView];
  
  self.hamburgerView.hidden = _hamburgerHidden;
}

- (void) placeSearchIconImageView
{
  CGFloat tapAreaOriginX = self.frame.size.width - kToolbarHeight;
  
  self.searchIconView = [[UIView alloc] initWithFrame:(CGRect){tapAreaOriginX, 0.0f, kToolbarHeight, kToolbarHeight}];
  self.searchIconView.backgroundColor = [UIColor clearColor];
  self.searchIconView.userInteractionEnabled = YES;
  
  UITapGestureRecognizer *searchIconTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchIconTapped)];
  [self.searchIconView addGestureRecognizer:searchIconTapRecognizer];
  [self addSubview:self.searchIconView];
  
  CGFloat searchIconOriginX = kToolbarHeight - kSearchIconWidth - kSearchIconPaddingRight;
  
  UIImage *searchIcon = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_search")];
  UIImageView *searchIconImageView = [[UIImageView alloc] initWithImage:searchIcon];
  
  int space = 0;
  
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  
  NSString *cartEnabledKey = @"currentlevel";
  
  if ([preferences objectForKey:cartEnabledKey] == nil)
  {
      //  Doesn't exist.
  }
  else
  {
      //  Get current level
    const BOOL cartEnabled = [preferences integerForKey:cartEnabledKey];
    if (cartEnabled) {
      space = 20;
    }
  }
  
  CGRect searchIconFrame = (CGRect){searchIconOriginX + space, 0.0f, kSearchIconWidth, kSearchIconWidth};
  searchIconImageView.frame = searchIconFrame;
  searchIconImageView.center = (CGPoint){(int)searchIconImageView.center.x, (int)(kToolbarHeight/2)};
  
  [self.searchIconView addSubview:searchIconImageView];
}

- (void) placeCartButton
{
  [self addSubview:self.cartButton];
  
  self.cartButton.hidden = _cartButtonHidden;
}

-(mCatalogueCartButton *)cartButton
{
  if(!_cartButton)
  {
    CGRect cartButtonFrame = CGRectMake(self.frame.size.width - kToolbarHeight, 0.0f, kToolbarHeight, kToolbarHeight);
    
    _cartButton = [[mCatalogueCartButton alloc] initWithFrame:cartButtonFrame];
    
    [_cartButton addTarget:self
                    action:@selector(cartButtonPressed)
          forControlEvents:UIControlEventTouchUpInside];
  }
  
  return _cartButton;
}

- (void) placeTitleLabel
{
  self.titleLabel = [[UILabel alloc] init];
  
  switch(self.appearance){
    case mCatalogueSearchBarViewDefaultAppearance:
      break;
      
    case mCatalogueSearchBarViewPureNavigationAppearance:
      break;
      
    default:
      break;
  }
  
  _titleLabel.font = [UIFont systemFontOfSize:kMainPageTitleFontSize];
  _titleLabel.textColor = kMainPageTitleFontColor;
  _titleLabel.backgroundColor = [UIColor clearColor];
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  CGFloat titleLabelWidth =  CGRectGetMinX(self.searchIconView.frame) - 12.0f - CGRectGetMaxX(self.backLabelView.frame);
  
  CGRect titleLabelFrame = (CGRect){CGRectGetMaxX(self.backLabelView.frame) + 6.0f, 0.0f, titleLabelWidth, kToolbarHeight / 2};
  _titleLabel.frame = titleLabelFrame;
  
  self.titleLabel.center = (CGPoint){self.bounds.size.width / 2, kToolbarHeight / 2};
  
  [self addSubview:_titleLabel];
}

- (void) placeCancelSearchLabel
{
  self.cancelSearchLabel = [[UILabel alloc] init];
  self.cancelSearchLabel.font = [UIFont systemFontOfSize:kCancelLabelFontSize];
  
  NSString *labelText = NSBundleLocalizedString(@"mCatalogue_CancelSearch", @"Cancel");
  
  CGSize cancelSearchLabelSize = [labelText sizeForFont:self.cancelSearchLabel.font limitSize:self.frame.size];
  CGFloat cancelSearchLabelOriginX = self.bounds.size.width - kCancelLabelHorizontalPadding - cancelSearchLabelSize.width;
  CGFloat cancelSearchLabelOriginY = 0.0f;
  
  CGRect cancelLabelFrame = (CGRect){cancelSearchLabelOriginX, cancelSearchLabelOriginY, cancelSearchLabelSize.width, kToolbarHeight};
  
  self.cancelSearchLabel.frame = cancelLabelFrame;
  self.cancelSearchLabel.backgroundColor = [UIColor clearColor];
  self.cancelSearchLabel.text = labelText;
  self.cancelSearchLabel.textColor = kCancelLabelFontColor;
  self.cancelSearchLabel.userInteractionEnabled = YES;
  
  UITapGestureRecognizer *cancelSearchTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)];
  
  [self.cancelSearchLabel addGestureRecognizer:cancelSearchTapRecognizer];
  
  [self addSubview:self.cancelSearchLabel];
}

- (void) placeSearchTextField
{
  self.searchTextField = [[UITextField alloc] init];
  
  self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
  
  if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
    self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  }
  
  searchTextFieldCollapsedFrame = (CGRect){self.cancelSearchLabel.frame.origin.x - kCancelLabelHorizontalPadding,
    (self.frame.size.height - kSearchTextFieldHeight) / 2,
    0.0f,
    kSearchTextFieldHeight};

  CGFloat searchTextFieldWidth = self.frame.size.width - (kCancelLabelHorizontalPadding + 2 * kCancelLabelHorizontalPadding + self.cancelSearchLabel.frame.size.width);
  
  searchTextFieldExpandedFrame = (CGRect){kCancelLabelHorizontalPadding, searchTextFieldCollapsedFrame.origin.y, searchTextFieldWidth, kSearchTextFieldHeight};
  
  self.searchTextField.returnKeyType = UIReturnKeySearch;
  self.searchTextField.delegate = self.mCatalogueSearchViewTextFieldDelegate;
  self.searchTextField.borderStyle = UITextBorderStyleNone;
  self.searchTextField.layer.backgroundColor = [UIColor whiteColor].CGColor;
  
  self.searchTextField.layer.cornerRadius = kSearchBarTextFieldCornerRadius;
  self.searchTextField.font = [UIFont systemFontOfSize:kSearchBarTextViewFontSize];
  self.searchTextField.textAlignment = NSTextAlignmentLeft;
  
  UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, kSearchTextFieldHeight)];
  [self.searchTextField setLeftViewMode:UITextFieldViewModeAlways];
  [self.searchTextField setLeftView:spacerView];
  
  self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
  
  [self setupSearchPlaceholder];
  
  self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  self.searchTextField.frame = searchTextFieldCollapsedFrame;
  self.searchTextField.delegate = self;
  
  [self addSubview:self.searchTextField];
  
  [self placeFoundApplicationsCountRightView];
}

-(void)setupSearchPlaceholder{
  NSString *placeholderText = NSBundleLocalizedString(@"mCatalogue_SearchPlaceholder", @"Search");
  
  if ([self.searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
    UIColor *color = [UIColor blackColor];
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: color}];
  } else {
    self.searchTextField.placeholder = placeholderText;
  }
}

- (void) placeSeparator
{
  CGRect separatorFrame = (CGRect){0.0f, kToolbarHeight, self.frame.size.width, kToolbarSeparatorHeight};
  
  self.separator = [[UIView alloc] initWithFrame:separatorFrame];
  
  if([self.backgroundColor isLight]){
    self.separator.backgroundColor = kSeparatorColorDark;
  } else {
    self.separator.backgroundColor = kSeparatorColorLight;
  }
  
  self.separatorColor = self.separator.backgroundColor;
  
  [self addSubview:self.separator];
}

- (void) leftButtonPressed
{
  if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewLeftButtonPressed)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewLeftButtonPressed];
  }
}

- (void) cartButtonPressed
{
  if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewCartButtonPressed)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewCartButtonPressed];
  }
}

- (void) hamburgerPressed
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"moduleHamburgerPressed"
                                                      object:nil];
  //[[CIphoneMasterViewController appHomeScreenVC] toggleSideBar];
}

- (void) searchIconTapped
{
  searchInProgress = !searchInProgress;
  
  [self setupSearchPlaceholder];
  
  switch(self.appearance){
    case mCatalogueSearchBarViewDefaultAppearance:
      self.backLabelView.hidden = YES;
      break;
    case mCatalogueSearchBarViewPureNavigationAppearance:
    default:
      break;
  }
  
  self.titleLabel.hidden = YES;
  self.searchIconView.hidden = YES;

  self.cartButton.alpha = 0.0f;
  self.cartButton.enabled = NO;
  self.hamburgerView.alpha = 0.0f;
  self.hamburgerView.userInteractionEnabled = NO;
  
  self.cancelSearchLabel.alpha = 0.0f;
  self.cancelSearchLabel.hidden = NO;
  self.searchTextField.hidden = NO;
  
  [self.searchTextField becomeFirstResponder];
  
  [UIView animateWithDuration:0.2f animations:^{
    self.cancelSearchLabel.alpha = 1.0f;
  }];
  
  [UIView animateWithDuration:0.3f animations:^{
    self.searchTextField.frame = searchTextFieldExpandedFrame;
  } completion:^(BOOL completed){
    if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewDidShowSearchField)]){
      [self.mCatalogueSearchViewDelegate mCatalogueSearchViewDidShowSearchField];
    }
  }];
}

- (void) cancelSearch
{
  searchInProgress = !searchInProgress;
  
  self.searchTextField.text = @"";
  self.searchTextField.placeholder = @"";
  
  self.titleLabel.alpha = 0.0f;
  self.titleLabel.hidden = NO;
  
  self.searchIconView.alpha = 0.0f;
  self.searchIconView.hidden = NO;
  
  
  switch(self.appearance){
    case mCatalogueSearchBarViewDefaultAppearance:
      self.backLabelView.alpha = 0.0f;
      self.backLabelView.hidden = NO;
      break;
    case mCatalogueSearchBarViewPureNavigationAppearance:
    default:
      break;
  }
  
  if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewDidCancelSearch)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewDidCancelSearch];
  }
  
  [UIView animateWithDuration:0.3f animations:^{
    self.searchTextField.frame = searchTextFieldCollapsedFrame;
    [self.searchTextField resignFirstResponder];
  } completion:^(BOOL finished){
    self.cancelSearchLabel.hidden = YES;
    self.searchTextField.hidden = YES;
    
    [UIView animateWithDuration:0.1f animations:^{
      self.titleLabel.alpha = 1.0f;
      self.searchIconView.alpha = 1.0f;
      
      self.cartButton.alpha = 1.0f;
      self.hamburgerView.alpha = 1.0f;
      
      self.cartButton.enabled = YES;
      self.hamburgerView.userInteractionEnabled = YES;
      
      switch(self.appearance){
        case mCatalogueSearchBarViewDefaultAppearance:
          self.backLabelView.alpha = 1.0f;
          break;
        case mCatalogueSearchBarViewPureNavigationAppearance:
        default:
          break;
      }
    }];
    
  }];
}


- (void) setCatalogueSearchViewTextFieldDelegate:(id<NSObject,UITextFieldDelegate>)mCatalogueSearchViewTextFieldDelegate {
  if(_mCatalogueSearchViewTextFieldDelegate != mCatalogueSearchViewTextFieldDelegate){
    _mCatalogueSearchViewTextFieldDelegate = mCatalogueSearchViewTextFieldDelegate;
    self.searchTextField.delegate = _mCatalogueSearchViewTextFieldDelegate;
  }
}

- (void) setTitle:(NSString *)title
{
  if(_title != title){
    _title = title;
    self.titleLabel.text = _title;
    self.titleLabel.center = (CGPoint){self.bounds.size.width / 2, kToolbarHeight / 2};
    
    if(self.titleLabel.frame.origin.x <= (self.backLabelView.frame.origin.x + self.backLabelView.frame.size.width + 6.0f)){
      CGRect shiftedTitleFrame = self.titleLabel.frame;
      shiftedTitleFrame.origin.x += 6.0f;
      self.titleLabel.frame = shiftedTitleFrame;
    }
  }
}

- (void) setSeparatorColor:(UIColor *)separatorColor
{
  if(_separatorColor != separatorColor){
    _separatorColor = separatorColor;
    
    _separator.backgroundColor = _separatorColor;
  }
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
  [super setBackgroundColor:backgroundColor];
  
  if([self.backgroundColor isLight]){
    [self setSeparatorColor:kSeparatorColorDark];
  } else {
    [self setSeparatorColor:kSeparatorColorLight];
  }
}



-(void)placeFoundApplicationsCountRightView
{
  self.foundApplicationsCountLabel = [[UILabel alloc] init];
  self.foundApplicationsCountLabel.textColor = kAppCountTextColor;
  self.foundApplicationsCountLabel.backgroundColor = [UIColor clearColor];
  self.foundApplicationsCountLabel.font = [UIFont systemFontOfSize:12.0f];
  
  [self.searchTextField setRightViewMode:UITextFieldViewModeUnlessEditing];
  [self.searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
  [self.searchTextField setRightView:self.foundApplicationsCountLabel];
}

- (void)clearSearchResultsCount
{
  self.foundApplicationsCountLabel.text = @"";
}

- (void)refreshSearchResultsCount:(NSUInteger)newValue
{
  NSString *countAsString = [NSString stringWithFormat:@"%ld", (long)newValue];
  
  self.foundApplicationsCountLabel.text = countAsString;
  self.foundApplicationsCountLabel.textColor = kAppCountTextColor;
  [self.foundApplicationsCountLabel sizeToFit];
  
  CGRect newFrame = self.foundApplicationsCountLabel.frame;
  newFrame.size.width += 5.0f;
  self.foundApplicationsCountLabel.frame = newFrame;
}


- (void)setCartButtonHidden:(BOOL)hidden
{
  if ((_cartButtonHidden != hidden) &&  _hamburgerHidden)
  {
    if (!hidden && _hamburgerHidden)
        [self moveSearchIcon:-kToolbarHeight];
    
    if (hidden && _hamburgerHidden)
      [self moveSearchIcon:kToolbarHeight];
    
    self.cartButton.hidden = hidden;
    _cartButtonHidden = hidden;
  }
}

- (void)setHamburgerHidden:(BOOL)hidden
{
  if(_hamburgerHidden != hidden)
  {
    if (!hidden && _cartButtonHidden)
      [self moveSearchIcon:-kToolbarHeight];
    
    if (hidden && _cartButtonHidden)
      [self moveSearchIcon:kToolbarHeight];
    
    if (!hidden) self.cartButton.hidden = YES;
    
    self.hamburgerView.hidden = hidden;
    _hamburgerHidden = hidden;
  }
}

-(void)moveSearchIcon:(CGFloat)offset
{
  CGPoint searchIconViewCenter = self.searchIconView.center;
  CGRect titleLabelFrame = self.titleLabel.frame;
  
  searchIconViewCenter.x += offset;
  titleLabelFrame.size = CGSizeMake(titleLabelFrame.size.width, titleLabelFrame.size.height);
  
  self.searchIconView.center = searchIconViewCenter;
  self.titleLabel.frame = titleLabelFrame;
}

-(BOOL) cartButtonHidden
{
  return _cartButtonHidden;
}

-(BOOL) hamburgerHidden
{
  return _hamburgerHidden;
}


#pragma mark - UITextField delegate
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
  return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
  [textField resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  
  if(self.mCatalogueSearchViewDelegate && [self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewSearchInitiated:)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewSearchInitiated:textField.text];
  }
  
  return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
  textField.text = @"";
  
  if(self.mCatalogueSearchViewDelegate && [self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewSearchInitiated:)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewSearchInitiated:textField.text];
  }
  
  return NO;
}

- (void) dealloc
{
  self.titleLabel = nil;
  self.backButtonLabel = nil;
  self.searchTextField = nil;
  self.cancelSearchLabel = nil;
  self.searchIconView = nil;
  self.hamburgerView = nil;
  self.foundApplicationsCountLabel = nil;
  self.separatorColor = nil;
  
  self.cartButton = nil;
}

@end
