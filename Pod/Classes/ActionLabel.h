//
//  ActionLabel.h
//  Kitchen
//
//  Created by Rahul Jaswa on 12/27/14.
//  Copyright (c) 2014 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ActionLabel;

@protocol ActionLabelDelegate <NSObject>

@optional

- (void)actionLabel:(ActionLabel *)label didSelectLinkWithURL:(NSURL *)url;
- (void)actionLabel:(ActionLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents;
- (void)actionLabel:(ActionLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber;
- (void)actionLabel:(ActionLabel *)label didSelectLinkWithDate:(NSDate *)date;
- (void)actionLabel:(ActionLabel *)label didSelectLinkWithDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration;
- (void)actionLabel:(ActionLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components;
- (void)actionLabel:(ActionLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;

@end


@interface ActionLabel : UILabel

@property (nonatomic, strong) NSDictionary *activeLinkAttributes;
@property (nonatomic, strong) NSDictionary *linkAttributes;

@property (nonatomic, assign) id<ActionLabelDelegate> delegate;

@property (nonatomic, assign) NSTextCheckingTypes textCheckingTypes;

- (void)clearRegisteredBlocks;
- (void)registerBlock:(void (^)(void))block forRange:(NSRange)range highlightAttributes:(NSDictionary *)attributes;

@end
