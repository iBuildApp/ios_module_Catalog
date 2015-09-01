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



#import "mCatalogueCartItemCell.h"
#import "UIButton+Extensions.h"
#import "mCatalogueItem.h"
#import "UIColor+HSL.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kCellContentLeftMargin   10.f
#define kCellContentRightMargin  10.f
#define kCellContentTopMargin    10.f
#define kCellContentBottomMargin 10.f

#define kCellImageViewLeftMargin    0.f
#define kCellImageViewRightMargin  10.f
#define kCellImageViewTopMargin     0.f
#define kCellImageViewBottomMargin  0.f
#define kCellImageViewAspectRatio   1.f

#define kCellTextLabelLeftMargin    0.f
#define kCellTextLabelRightMargin   5.f
#define kCellTextLabelTopMargin     0.f
#define kCellTextLabelBottomMargin  10.f

#define kAmountControlHeightScale 0.5f

@implementation mCatalogueCartItemCell

+(UIEdgeInsets)contentMargin
{
  return UIEdgeInsetsMake(kCellContentTopMargin,
                          kCellContentLeftMargin,
                          kCellContentBottomMargin,
                          kCellContentRightMargin);
}

+(mCatalogueCartItemCell *)createCellWithCellIdentifier:(NSString *)identifier_
                                               delegate:(id<NSObject>)delegate_
{
  mCatalogueCartItemCell *cell = [[[mCatalogueCartItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                                reuseIdentifier:identifier_] autorelease];
  cell.clipsToBounds   = NO;
  cell.selectionStyle  = UITableViewCellSelectionStyleNone;
  cell.backgroundColor = [UIColor clearColor];
  cell.contentView.backgroundColor = [UIColor clearColor];
  cell.contentView.clipsToBounds   = NO;
  cell.accessoryType               = UITableViewCellAccessoryNone;
  cell.delegate                    = delegate_;
  
  if ( [cell respondsToSelector:@selector(setSeparatorInset:)] )
    cell.separatorInset = UIEdgeInsetsZero;
  
  if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    [cell setLayoutMargins:UIEdgeInsetsZero];
  
  
  cell.deleteButton.imageView.contentMode   = UIViewContentModeCenter;
  cell.deleteButton.imageView.clipsToBounds = YES;
  
  // select resource depends on color scheme
  UIImage *deleteImage = [[mCatalogueParameters sharedParameters].backgroundColor isLight] ?
                                        [UIImage imageNamed:resourceFromBundle(@"mCatalogueDeleteItemLight")] :
                                        [UIImage imageNamed:resourceFromBundle(@"mCatalogueDeleteItem")];
  [cell.deleteButton setImage:deleteImage
                     forState:UIControlStateNormal];
  [cell.deleteButton setTitle:NSBundleLocalizedString( @"mCatalogue_DELETE_BUTTON", nil )
                     forState:UIControlStateNormal];
  
  [cell.deleteButton setTitleColor:[[mCatalogueParameters sharedParameters] descriptionColor]
                          forState:UIControlStateNormal];
  cell.deleteButton.titleLabel.font      = [UIFont systemFontOfSize:14.f];
  
  cell.textLabel.textColor         = [[mCatalogueParameters sharedParameters] captionColor];
  cell.textLabel.font              = [UIFont boldSystemFontOfSize:13.f];
  cell.textLabel.backgroundColor   = [UIColor clearColor];
  cell.textLabel.lineBreakMode     = NSLineBreakByTruncatingTail;
  cell.textLabel.numberOfLines     = 0;
  
  cell.imageView.contentMode       = UIViewContentModeScaleAspectFit;
  cell.imageView.clipsToBounds     = YES;
  cell.imageView.backgroundColor   = [UIColor whiteColor];
  
  cell.priceLabel.backgroundColor   = [UIColor clearColor];
  cell.priceLabel.lineBreakMode     = NSLineBreakByTruncatingTail;
  cell.priceLabel.textColor         = [[mCatalogueParameters sharedParameters] priceColor];
  cell.priceLabel.font              = [UIFont boldSystemFontOfSize:15.f];
  cell.priceLabel.textAlignment     = NSTextAlignmentLeft;
  cell.priceLabel.verticalAlignment = NRLabelVerticalAlignmentTop;
  
  cell.amountField.placeholder              = @"1";
  cell.amountField.text                     = cell.amountField.placeholder;
  cell.amountField.textColor                = [[mCatalogueParameters sharedParameters] priceColor];
  cell.amountField.font                     = [UIFont systemFontOfSize:15.f];
  cell.amountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  cell.amountField.textAlignment            = NSTextAlignmentCenter;
  cell.amountField.backgroundColor          = [UIColor whiteColor];
  cell.amountField.contentInset             = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
  cell.amountField.keyboardType             = UIKeyboardTypeNumberPad;
  [[cell.amountField layer] setCornerRadius:5.f];
  [[cell.amountField layer] setBorderColor:[self borderColor].CGColor];
  [[cell.amountField layer] setBorderWidth:1.f];

  return cell;
}

-(void)updateContentWithItem:(mCatalogueCartItem *)item_
                containImage:(BOOL)containImage_
{
  self.item = item_;
  self.textLabel.text        = item_.item.name;
  self.amountField.text      = item_.countAsString;
  self.priceLabel.text       = item_.item.priceStr;
  
  self.containImage = YES;
  [self setThumbnailWithCatalogueCartItem:item_];
}


#pragma mark -
-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect frm = self.bounds;
  self.contentView.frame = CGRectMake( frm.origin.x + kCellContentLeftMargin,
                                      frm.origin.y + kCellContentTopMargin,
                                      frm.size.width - (kCellContentLeftMargin + kCellContentRightMargin),
                                      frm.size.height - (kCellContentTopMargin + kCellContentBottomMargin) );
  frm = self.contentView.bounds;
  
  CGRect infoFieldFrm = frm;
  self.imageView.frame = CGRectZero;
  if ( self.imageView.image )
  {
    // place image
    CGFloat imgHeight = frm.size.height - ( kCellImageViewTopMargin + kCellImageViewBottomMargin );
    CGRect imgFrm =  CGRectMake(kCellImageViewLeftMargin,
                                kCellImageViewTopMargin,
                                floorf(imgHeight * kCellImageViewAspectRatio),
                                imgHeight );
    self.imageView.frame = imgFrm;

    infoFieldFrm = CGRectMake(CGRectGetMaxX( imgFrm ) + kCellImageViewRightMargin,
                              CGRectGetMinY( imgFrm ),
                              CGRectGetWidth( frm ) - (CGRectGetMaxX( imgFrm ) + kCellImageViewRightMargin),
                              CGRectGetHeight( frm ));
  }
  {
    // text field placed in top right corner
    CGSize expectedLabelSize = [@"_9999_" sizeWithFont:self.amountField.font
                                     constrainedToSize:infoFieldFrm.size];
    self.amountField.frame = CGRectMake(CGRectGetMaxX(infoFieldFrm) - expectedLabelSize.width,
                                        CGRectGetMinY(infoFieldFrm),
                                        floorf(expectedLabelSize.width),
                                        floorf(self.amountField.font.lineHeight * ( 1.f + kAmountControlHeightScale )) );
  }
  {
    // delete button place at bottom right corner
    [self.deleteButton sizeToFit];
    CGRect frmDelete = self.deleteButton.frame;
    frmDelete.origin.x = CGRectGetMaxX( infoFieldFrm ) - CGRectGetWidth( frmDelete );
    frmDelete.origin.y = CGRectGetMaxY( infoFieldFrm ) - CGRectGetHeight( frmDelete );
    self.deleteButton.frame = frmDelete;
  }
  
  {
    // height of title limited by delete button height
    CGSize maxSize = CGSizeMake( CGRectGetMinX(self.amountField.frame) - CGRectGetMinX(infoFieldFrm) - kCellTextLabelLeftMargin -
                                kCellTextLabelRightMargin,
                                infoFieldFrm.size.height - CGRectGetHeight( self.deleteButton.frame ) - kCellTextLabelTopMargin - kCellTextLabelBottomMargin );
    
    CGSize expectedSize = [self.textLabel.text sizeWithFont:self.textLabel.font
                                          constrainedToSize:maxSize
                                              lineBreakMode:self.textLabel.lineBreakMode];
    
    CGFloat labelHeight = !self.textLabel.numberOfLines ?
    expectedSize.height :
    MIN( expectedSize.height, maxSize.height );
    
    // place title between image and edit field
    self.textLabel.frame  = CGRectMake( CGRectGetMinX(infoFieldFrm) + kCellTextLabelLeftMargin,
                                       CGRectGetMinY(infoFieldFrm) + kCellTextLabelTopMargin,
                                       maxSize.width,
                                       labelHeight );
  }
  
  {
    // price placed under title label
    // this field right limited with delete button
    self.priceLabel.frame = CGRectMake( CGRectGetMinX(infoFieldFrm),
                                       CGRectGetMaxY(self.textLabel.frame) + kCellTextLabelBottomMargin,
                                       CGRectGetMinX( self.deleteButton.frame ) - CGRectGetMinX( infoFieldFrm ),
                                       CGRectGetMaxY( infoFieldFrm ) - (CGRectGetMaxY( self.textLabel.frame ) + kCellTextLabelBottomMargin ));
  }
}

+(UIColor *)borderColor
{
    // if no color specified - use main color
  CGFloat clr = [[mCatalogueParameters sharedParameters].backgroundColor isLight] ? 0.f : 1.f;
  return [UIColor colorWithWhite:clr alpha:0.3f];
}

-(void)setThumbnailWithCatalogueCartItem:(mCatalogueCartItem *)cartItem
{
  [self.imageView setImageWithURL:[NSURL URLWithString:cartItem.item.thumbnailUrl]
                 placeholderImage:[UIImage imageNamed:resourceFromBundle(@"mCatalogue_ItemImagePlaceholder.png")]];
}

@end
