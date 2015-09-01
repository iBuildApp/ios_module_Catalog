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



#import "mCatalogueUserProfileCell.h"
#import "mCatalogueParameters.h"

#define kDefaultCellHeight 50.0f

#define kConfirmButtonTopMargin         10.f
#define kConfirmButtonBottomMargin      10.f
#define kConfirmButtonHeightScaleFactor 0.8f

#define kNoteFieldHeight                80.f
#define kNoteFieldBottomMargin          10.f

#define kTextFieldPaddingX 10.f
#define kTextFieldPaddingY 5.f

#define kSubmitButtonWidth 240.0f
#define kSubmitButtonHeight 40.0f

#define kTopSeparatorViewHeight 1.0f

@implementation mCatalogueUserProfileHeaderView
@synthesize title = _title,
      labelInsets = _labelInsets,
 topSeparatorView = _topSeparatorView;

- (id)init
{
  self = [super init];
  if ( self )
  {
    _title       = nil;
    _labelInsets = UIEdgeInsetsZero;
  }
  return self;
}

- (void)dealloc
{
  [_title removeFromSuperview];
  [_title release];
  [super dealloc];
}

- (UILabel *)title
{
  if ( !_title )
  {
    _title = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_title];
  }
  return _title;
}

-(UIView *)topSeparatorView
{
  if ( !_topSeparatorView )
  {
    _topSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _topSeparatorView.backgroundColor = [[mCatalogueParameters sharedParameters] cartSeparatorColor];
    
    [self addSubview:_topSeparatorView];
  }
  return _topSeparatorView;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect originFrame = self.frame;
  ///
  CGRect frm = UIEdgeInsetsInsetRect([self bounds], _labelInsets );
  
  CGSize expectedSize = [_title.text sizeWithFont:_title.font
                                constrainedToSize:CGSizeMake( CGRectGetWidth(frm), 9999.f )
                                    lineBreakMode:_title.lineBreakMode];
  
  _title.frame = CGRectMake(frm.origin.x,
                            frm.origin.y + kTopSeparatorViewHeight,
                            frm.size.width,
                            ceilf(expectedSize.height) );
  
  originFrame.size.height = CGRectGetMaxY( _title.frame ) + _labelInsets.bottom + kTopSeparatorViewHeight;
  self.frame = originFrame;
  
  self.topSeparatorView.frame = CGRectMake(0.0f,
                                           CGRectGetMinY(originFrame),
                                           originFrame.size.width,
                                           kTopSeparatorViewHeight);
}

@end


@implementation mCatalogueUserProfileOrderConfirmationView
@synthesize button = _button,
         noteField = _noteField,
         noteLabel = _noteLabel,
   noteFieldHeight = _noteFieldHeight,
           metrics = _metrics;
- (id)init
{
  self = [super init];
  if ( self )
  {
    _button    = nil;
    _noteField = nil;
    _noteLabel = nil;
    _noteFieldHeight = kNoteFieldHeight;
    _metrics   = NULL;
  }
  return self;
}

- (void)dealloc
{
  [_noteLabel removeFromSuperview];
  [_noteLabel release];
  [_noteField removeFromSuperview];
  [_noteField release];
  [_button removeFromSuperview];
  [_button release];
  [super dealloc];
}

- (UIButton *)button
{
  if ( !_button )
  {
    _button = [[UIButton alloc] initWithFrame:CGRectZero];
    [self addSubview:_button];
  }
  return _button;
}

- (IBPlaceHolderTextView *)noteField
{
  if ( !_noteField )
  {
    _noteField = [[IBPlaceHolderTextView alloc] initWithFrame:CGRectZero];
    [self addSubview:_noteField];
  }
  return _noteField;
}

- (UILabel *)noteLabel
{
  if ( !_noteLabel )
  {
    _noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_noteLabel];
  }
  return _noteLabel;
}


- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect originFrame = self.frame;

  CGRect frm = CGRectMake( CGRectGetMinX(self.bounds) +  kTextFieldPaddingX,
                           CGRectGetMinY(self.bounds) +  kTextFieldPaddingY,
                           CGRectGetWidth(self.bounds) - kTextFieldPaddingX * 2.f,
                           0.f );
  CGFloat confirmButtonTopMargin = kConfirmButtonTopMargin;
  
  CGFloat yOffset = CGRectGetMinY(frm);
  if ( _noteField )
  {
    if ( _metrics && _noteLabel )
    {
      frm = [self bounds];
      
      UIEdgeInsets insetsTitle     = [mCatalogueUserProfileCell titleLabelInsets];
      UIEdgeInsets insetsTextField = [mCatalogueUserProfileCell textFieldInsets];
      CGRect frame = frm;
      CGFloat widthTotal = _metrics->titleWidth + insetsTitle.left + insetsTitle.right +
                           _metrics->textFieldWidth + insetsTextField.left + insetsTextField.right;
      frm.origin.x   = floorf((CGRectGetWidth(frm) - widthTotal) / 2.f);
      frm.size.width = widthTotal;
      CGFloat elementOriginX;
      CGFloat cumulativeWidth = 0.f;
      {
        CGFloat elementWidth = _metrics->textFieldWidth + insetsTextField.left + insetsTextField.right;
        cumulativeWidth += elementWidth;
        elementOriginX = MAX(CGRectGetMaxX(frm) - cumulativeWidth, 0.f);
        CGRect elementFrame   = CGRectMake( elementOriginX, CGRectGetMinY(frm), elementWidth, _noteFieldHeight );
        _noteField.frame = UIEdgeInsetsInsetRect( elementFrame, insetsTextField );
      }
      {
        CGFloat elementWidth = _metrics->titleWidth + insetsTitle.left + insetsTitle.right;
        cumulativeWidth += elementWidth;
        elementOriginX = MAX(CGRectGetMaxX(frm) - cumulativeWidth, 0.f);
        CGRect elementFrame = CGRectMake( elementOriginX,
                                          CGRectGetMinY(frm),
                                          elementWidth,
                                          [mCatalogueUserProfileCell defaultHeight] );
        _noteLabel.frame = UIEdgeInsetsInsetRect( elementFrame, insetsTitle );
      }
      confirmButtonTopMargin = 32.f;
      frm = frame;
    }else{
      _noteField.frame = CGRectMake(CGRectGetMinX(frm),
                                    CGRectGetMinY(frm),
                                    CGRectGetWidth(frm),
                                    _noteFieldHeight);
    }
    yOffset += CGRectGetHeight(_noteField.frame) + kNoteFieldBottomMargin;
  }

  _button.frame = CGRectMake(floorf(CGRectGetMinX(frm) + (CGRectGetWidth(frm) - kSubmitButtonWidth) / 2.f),
                             yOffset,
                             kSubmitButtonWidth,
                             kSubmitButtonHeight);
  
  originFrame.size.height = CGRectGetMaxY( _button.frame ) + kConfirmButtonBottomMargin + kTextFieldPaddingY;
  self.frame = originFrame;
}

@end



@implementation mCatalogueUserProfileCell
@synthesize editField = _editField,
                 item = _item,
              metrics = _metrics,
             delegate = _delegate;

+ (CGFloat)defaultHeight
{
  return kDefaultCellHeight;
}

- (void)configureCellWithCellIdentifier:(NSString *)identifier_
                            cellMetrics:(CatalogueUserProfileCellMetrics *)metrics_
                               delegate:(id<NSObject>)delegate_
{
  self.metrics         = metrics_;
  self.selectionStyle  = UITableViewCellSelectionStyleNone;
  self.backgroundColor = [UIColor clearColor];
  self.contentView.backgroundColor = [UIColor clearColor];
  self.accessoryType               = UITableViewCellAccessoryNone;
  
  self.editField.backgroundColor     = [UIColor whiteColor];
  self.editField.autoresizesSubviews = YES;
  self.editField.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.editField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  self.editField.textAlignment            = NSTextAlignmentLeft;
  self.editField.contentInset             = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
  self.editField.autocapitalizationType   = UITextAutocapitalizationTypeNone;
  self.editField.autocorrectionType       = UITextAutocorrectionTypeNo;
  self.editField.frame = CGRectInset(self.contentView.bounds, kTextFieldPaddingX, kTextFieldPaddingY );
  self.delegate = delegate_;
  
  self.editField.borderRadius = 5.f;
  self.editField.borderWidth  = 1.f;
  self.editField.borderColor  = [UIColor grayColor];
}

- (id)init
{
  self = [super init];
  if ( self )
  {
    _editField = nil;
    _item      = nil;
    _delegate  = nil;
  }
  return self;
}

- (void)dealloc
{
  [_editField removeFromSuperview];
  [_editField release];
  
  self.item = nil;
  [super dealloc];
}

- (mCatalogueTextField *)editField
{
  if ( !_editField )
  {
    _editField = [[mCatalogueTextField alloc] initWithFrame:CGRectZero];
    _editField.delegate = self;
    [self.contentView addSubview:_editField];
  }
  return _editField;
}

- (void)updateContentWithItem:(mCatalogueUserProfileItem *)item_
{
  self.item = item_;
  self.editField.placeholder = [item_.placeholder length] ? item_.placeholder : item_.name;
  
  UIKeyboardType keyboardType;
  
  if([[item_.name lowercaseString] isEqualToString:@"email"]){
    keyboardType = UIKeyboardTypeEmailAddress;
  } else if([[item_.name lowercaseString] isEqualToString:@"phone"]){
    keyboardType = UIKeyboardTypePhonePad;
  } else {
    keyboardType = UIKeyboardTypeDefault;
  }
  
  self.editField.keyboardType = keyboardType;
  self.editField.text         = [item_ value];
  self.editField.textColor    = [UIColor darkTextColor];
  
  // set red frame around edit field if field is invalid
  self.editField.borderColor = item_.valid ? [UIColor grayColor] : [UIColor redColor];
}


#pragma mark
#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  if ( _editField == textField )
  {
    // on editing - reset border frame
    ((mCatalogueTextField *)textField).borderColor = [UIColor grayColor];
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if ( [self.delegate respondsToSelector:@selector(didChangeTextFieldValueWithString:forCell:)] )
      [self.delegate performSelector:@selector(didChangeTextFieldValueWithString:forCell:)
                          withObject:newString
                          withObject:self];
  }
  return YES;
}

+ (mCatalogueUserProfileCell *)createCellWithCellIdentifier:(NSString *)identifier_
                                                        cellMetrics:(CatalogueUserProfileCellMetrics *)metrics_
                                                           delegate:(id<NSObject>)delegate_
{
  mCatalogueUserProfileCell *cell = [[[mCatalogueUserProfileCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                                      reuseIdentifier:identifier_] autorelease];
  
  
  [cell configureCellWithCellIdentifier:identifier_
                            cellMetrics:metrics_
                               delegate:delegate_];
  return cell;
}

+ (UIEdgeInsets)titleLabelInsets
{
  return UIEdgeInsetsMake( 5.f, 0.f, 5.f, 10.f );
}

+ (UIEdgeInsets)textFieldInsets
{
  return UIEdgeInsetsMake( 5.f, 10.f, 5.f, 0.f);
}

@end
