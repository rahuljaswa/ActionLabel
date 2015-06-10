//
//  ActionLabel.m
//  Kitchen
//
//  Created by Rahul Jaswa on 12/27/14.
//  Copyright (c) 2014 Rahul Jaswa. All rights reserved.
//

#import "ActionLabel.h"


@interface ActionLabel ()

@property (nonatomic, strong) NSTextCheckingResult *activeResult;
@property (nonatomic, strong) NSDataDetector *dataDetector;

@property (nonatomic, strong) NSAttributedString *oldAttributedText;
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, strong) NSMutableDictionary *blocks;

@end


@implementation ActionLabel

#pragma mark - Public Properties

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:[self attributedTextWithDataDetected:attributedText]];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextCheckingTypes:(NSTextCheckingTypes)textCheckingTypes {
    NSError *error = nil;
    self.dataDetector = [NSDataDetector dataDetectorWithTypes:textCheckingTypes error:&error];
    if (error) {
        NSLog(@"Error creating data detector\n\n%@", [error localizedDescription]);
    }
}

#pragma mark - Private Instance Methods

- (NSAttributedString *)attributedTextWithDataDetected:(NSAttributedString *)attributedText {
    NSMutableAttributedString *mutableAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    
    if (self.dataDetector) {
        NSString *string = attributedText.string;
        NSArray *matches = [self.dataDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSDictionary *attributes = nil;
                if (self.activeResult && NSEqualRanges([match range], [self.activeResult range])) {
                    attributes = self.activeLinkAttributes;
                } else {
                    attributes = self.linkAttributes;
                }
                [mutableAttributedText setAttributes:attributes range:[match range]];
            }
        }
    }
    
    return mutableAttributedText;
}

- (void)didSelectTextCheckingResultMatch:(NSTextCheckingResult *)match {
    NSTextCheckingType resultType = match.resultType;
    switch (resultType) {
        case NSTextCheckingTypeDate:
            if (match.timeZone && [self.delegate respondsToSelector:@selector(actionLabel:didSelectLinkWithDate:timeZone:duration:)]) {
                [self.delegate actionLabel:self didSelectLinkWithDate:match.date timeZone:match.timeZone duration:match.duration];
            } else if ([self.delegate respondsToSelector:@selector(actionLabel:didSelectLinkWithDate:)]) {
                [self.delegate actionLabel:self didSelectLinkWithDate:match.date];
            }
            break;
        case NSTextCheckingTypeLink:
            if ([self.delegate respondsToSelector:@selector(actionLabel:didSelectLinkWithURL:)]) {
                [self.delegate actionLabel:self didSelectLinkWithURL:match.URL];
            }
            break;
        case NSTextCheckingTypeAddress:
            if ([self.delegate respondsToSelector:@selector(actionLabel:didSelectLinkWithAddress:)]) {
                [self.delegate actionLabel:self didSelectLinkWithAddress:match.addressComponents];
            }
            break;
        case NSTextCheckingTypePhoneNumber:
            if ([self.delegate respondsToSelector:@selector(actionLabel:didSelectLinkWithPhoneNumber:)]) {
                [self.delegate actionLabel:self didSelectLinkWithPhoneNumber:match.phoneNumber];
            }
            break;
        case NSTextCheckingTypeTransitInformation:
            if ([self.delegate respondsToSelector:@selector(actionLabel:didSelectLinkWithTransitInformation:)]) {
                [self.delegate actionLabel:self didSelectLinkWithTransitInformation:match.components];
            }
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(actionLabel:didSelectLinkWithTextCheckingResult:)]) {
        [self.delegate actionLabel:self didSelectLinkWithTextCheckingResult:match];
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _blocks = [[NSMutableDictionary alloc] init];
        _attributes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Public Instance Methods - Block Registration

- (void)clearRegisteredBlocks {
    _blocks = [[NSMutableDictionary alloc] init];
    _attributes = [[NSMutableDictionary alloc] init];
}

- (void)registerBlock:(void (^)(void))block forRange:(NSRange)range highlightAttributes:(NSDictionary *)attributes {
    for (NSString *key in self.blocks) {
        NSRange cachedRange = NSRangeFromString(key);
        if (NSIntersectionRange(range, cachedRange).length != 0) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Existing block overlaps range"
                                         userInfo:nil];
        }
    }
    
    NSString *newKey = NSStringFromRange(range);
    [self.blocks setObject:block forKey:newKey];
    [self.attributes setObject:attributes forKey:newKey];
}

#pragma mark - Public Instance Methods - Touch Handlers

- (NSUInteger)indexOfCharacterAtTouchPoint:(UITouch *)touch {
    CGPoint location = [touch locationInView:self];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // init text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    // init text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    NSParagraphStyle *style = [[NSParagraphStyle alloc] init];
    textContainer.lineFragmentPadding = 0;
    textContainer.lineBreakMode = style.lineBreakMode;
    textContainer.layoutManager = layoutManager;
    
    [layoutManager addTextContainer:textContainer];
    [layoutManager setTextStorage:textStorage];
    
    return [layoutManager characterIndexForPoint:location
                                 inTextContainer:textContainer
        fractionOfDistanceBetweenInsertionPoints:NULL];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if ([touches count] == 1) {
        self.oldAttributedText = [self.attributedText copy];
        NSMutableAttributedString *mutableAttr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        NSUInteger location = [self indexOfCharacterAtTouchPoint:[touches anyObject]];
        if (self.dataDetector) {
            NSString *string = self.attributedText.string;
            NSArray *matches = [self.dataDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
            for (NSTextCheckingResult *match in matches) {
                NSRange range = [match range];
                if (NSLocationInRange(location, range)) {
                    self.activeResult = match;
                    
                    NSAttributedString *originalAttrString = [mutableAttr attributedSubstringFromRange:range];
                    NSAttributedString *replacementAttrString = [[NSAttributedString alloc] initWithString:originalAttrString.string
                                                                                                attributes:self.activeLinkAttributes];
                    [mutableAttr replaceCharactersInRange:range withAttributedString:replacementAttrString];
                    
                    self.attributedText = mutableAttr;
                    return;
                }
            }
        }
        
        if ([self.blocks count] > 0) {
            for (NSString *key in self.blocks) {
                NSRange keyRange = NSRangeFromString(key);
                if (NSLocationInRange(location, keyRange)) {
                    
                    NSAttributedString *originalAttrString = [mutableAttr attributedSubstringFromRange:keyRange];
                    NSAttributedString *replacementAttrString = [[NSAttributedString alloc] initWithString:originalAttrString.string
                                                                                                attributes:[self.attributes objectForKey:key]];
                    [mutableAttr replaceCharactersInRange:keyRange withAttributedString:replacementAttrString];
                    
                    self.attributedText = mutableAttr;
                    return;
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (self.activeResult) {
        self.activeResult = nil;
    }
    
    if (self.oldAttributedText) {
        self.attributedText = [self.oldAttributedText copy];
        self.oldAttributedText = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    BOOL shouldCheckRegisteredBlocks = YES;
    
    if (self.activeResult) {
        [self didSelectTextCheckingResultMatch:self.activeResult];
        self.activeResult = nil;
        shouldCheckRegisteredBlocks = NO;
    }
    
    if (self.oldAttributedText) {
        self.attributedText = [self.oldAttributedText copy];
        self.oldAttributedText = nil;
    }
    
    if (shouldCheckRegisteredBlocks && ([touches count] == 1) && ([self.blocks count] > 0)) {
        NSUInteger location = [self indexOfCharacterAtTouchPoint:[touches anyObject]];
        for (NSString *key in self.blocks) {
            NSRange keyRange = NSRangeFromString(key);
            if (NSLocationInRange(location, keyRange)) {
                void (^block)() = [self.blocks objectForKey:key];
                if (block) {
                    block();
                }
            }
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeZero;
    newSize.width = size.width;
    newSize.height = [self.attributedText boundingRectWithSize:CGSizeMake(newSize.width, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil].size.height;
    newSize.height = ceil(newSize.height) + 1.0f;
    return newSize;
}
@end
