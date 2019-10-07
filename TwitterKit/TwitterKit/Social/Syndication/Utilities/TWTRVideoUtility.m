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

#import "TWTRVideoUtility.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreServices/CoreServices.h>

@implementation TWTRVideoUtility

+ (NSData *)videoThumbnailDataForURL:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 30);
    NSError *thumbnailError;
    CGImageRef thumbnailFrame = [generator copyCGImageAtTime:time actualTime:nil error:&thumbnailError];
    if (!thumbnailFrame) {
        NSLog(@"Could not retrieve thumbnail from video URL: %@", thumbnailError);
    }

    CFMutableDataRef thumbnailDataCopy = CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(thumbnailDataCopy, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImage(destination, thumbnailFrame, nil);
    if (!CGImageDestinationFinalize(destination))
        NSLog(@"Failed to write thumbnail");
    NSData *thumbnailData = (__bridge NSData *)thumbnailDataCopy;

    return thumbnailData;
}

+ (double)videoDuration:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    CMTime duration = asset.duration;

    return CMTimeGetSeconds(duration);
}

@end
