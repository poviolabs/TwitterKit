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

#import "TWTRImageLoaderImageUtils.h"
#import "TWTRMediaMIMEType.h"
#import <TwitterCore/TWTRAssertionMacros.h>

@implementation TWTRImageLoaderImageUtils

+ (BOOL)imageHasAlphaChannel:(UIImage *)image
{
    TWTRParameterAssertOrReturnValue(image, NO);

    const CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return !(alpha == kCGImageAlphaNone || alpha == kCGImageAlphaNoneSkipFirst || alpha == kCGImageAlphaNoneSkipLast);
}

+ (NSData *)imageDataFromImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality
{
    TWTRParameterAssertOrReturnValue(image, nil);

    CGFloat clampedCompressionQuality = MIN(MAX(0, compressionQuality), 1);
    const BOOL imageHasAlpha = [TWTRImageLoaderImageUtils imageHasAlphaChannel:image];
    NSData *data = imageHasAlpha ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, clampedCompressionQuality);
    return data != nil ? data : [[NSData alloc] init];
}

+ (NSData *)imageDataFromImage:(UIImage *)image
{
    return [TWTRImageLoaderImageUtils imageDataFromImage:image compressionQuality:1.0];
}

+ (NSString *)mimeTypeForImageData:(NSData *)data
{
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];

    const char gif[3] = {'G', 'I', 'F'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};

    if (!memcmp(bytes, gif, 3)) {
        return TWTRTweetMediaMIMEContentTypeGIF;
    } else if (!memcmp(bytes, jpg, 3)) {
        return TWTRTweetMediaMIMEContentTypeJPG;
    } else if (!memcmp(bytes, png, 8)) {
        return TWTRTweetMediaMIMEContentTypePNG;
    }

    return nil;
}

@end
