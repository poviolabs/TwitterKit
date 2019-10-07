/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "TWTRSETweetImageAttachmentView.h"
#import "TWTRSETweetAttachment.h"
#import "TWTRAnimatableImageView.h"
#import "TWTRImageLoaderImageUtils.h"
#import "TWTRMediaMIMEType.h"

#pragma mark -

@interface TWTRSETweetImageAttachmentView ()

@property (nonatomic, readonly) UIImageView *imageView;
// TODO: enable for GIF animation preview
// @property (nonatomic, readonly) TWTRAnimatableImageView *animatableImageView;

@end

@implementation TWTRSETweetImageAttachmentView

- (instancetype)initWithImageAttachment:(TWTRSETweetAttachmentImage *)imageAttachment
{
    NSParameterAssert(imageAttachment);
    NSParameterAssert(imageAttachment.image);

    if ((self = [super initWithFrame:CGRectZero])) {
        _imageView = [[UIImageView alloc] initWithImage:imageAttachment.image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (@available(iOS 11.0, *)) {
            _imageView.accessibilityIgnoresInvertColors = YES;
        }

        [self addSubview:_imageView];
        [self setUpConstraintsForView:_imageView scale:_imageView.image.size.height / _imageView.image.size.width];

        if ([[TWTRImageLoaderImageUtils mimeTypeForImageData:imageAttachment.imageData] isEqualToString:TWTRTweetMediaMIMEContentTypeGIF]) {
            // TODO: parse with AnimatedImage, then set animationImages/Duration...
        }
    }

    return self;
}

- (void)setUpConstraintsForView:(UIView *)view scale:(CGFloat)scale
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [view.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;

    [view.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;

    [view.heightAnchor constraintEqualToAnchor:view.widthAnchor multiplier:scale].active = YES;
    [self.heightAnchor constraintEqualToAnchor:view.heightAnchor].active = YES;
}

@end
