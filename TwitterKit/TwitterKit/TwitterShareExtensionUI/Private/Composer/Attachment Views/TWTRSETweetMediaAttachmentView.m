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

#import "TWTRSETweetMediaAttachmentView.h"
#import "TWTRSETweetAttachment.h"
#import "TWTRTweetMediaView.h"
#import "TWTRVideoUtility.h"

const CGFloat TWTRMediaAspectRatio16x10 = 16.0 / 10.0;

#pragma mark -

@interface TWTRSETweetMediaAttachmentView ()

@property (nonatomic, readonly) TWTRTweetMediaView *mediaView;

@end

@implementation TWTRSETweetMediaAttachmentView

- (instancetype)initWithMediaAttachment:(TWTRSETweetAttachmentMedia *)mediaAttachment
{
    NSParameterAssert(mediaAttachment);
    NSParameterAssert(mediaAttachment.images || mediaAttachment.videoURL);

    if ((self = [super initWithFrame:CGRectZero])) {
        self.backgroundColor = UIColor.blackColor;

        _mediaView = [[TWTRTweetMediaView alloc] init];
        [self addSubview:_mediaView];
        _mediaView.translatesAutoresizingMaskIntoConstraints = NO;

        [_mediaView configureWithImages:[self imagesFromAttachment:mediaAttachment]
                               videoURL:mediaAttachment.videoURL
                                  style:TWTRTweetViewStyleCompact];
        _mediaView.aspectRatio = TWTRMediaAspectRatio16x10;

        [self setUpConstraints];
    }

    return self;
}

- (NSArray<UIImage *> *)imagesFromAttachment:(nonnull TWTRSETweetAttachmentMedia *)mediaAttachment {
    NSMutableArray<UIImage *> *images = [[NSMutableArray alloc] init];
    if (mediaAttachment.images.count > 0) {
        for (NSData *imageData in mediaAttachment.images) {
            UIImage *image = [UIImage imageWithData:imageData];
            [images addObject:image];
        }
    } else {
        NSData *thumbnailData = [TWTRVideoUtility videoThumbnailDataForURL:mediaAttachment.videoURL];
        UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
        [images addObject:thumbnailImage];
    }

    return images;
}

- (void)setUpConstraints
{
    CGFloat scale = 1.0 / TWTRMediaAspectRatio16x10;
    self.mediaView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mediaView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.mediaView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.mediaView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.mediaView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.mediaView.heightAnchor constraintEqualToAnchor:self.mediaView.widthAnchor multiplier:scale].active = YES;
    [self.heightAnchor constraintEqualToAnchor:self.mediaView.heightAnchor].active = YES;
}

@end
