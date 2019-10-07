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

#import "TWTRMediaMIMEType.h"

NSString *const TWTRTweetMediaMIMEContentTypeJPG = @"image/jpeg";
NSString *const TWTRTweetMediaMIMEContentTypePNG = @"image/png";
NSString *const TWTRTweetMediaMIMEContentTypeGIF = @"image/gif";
NSString *const TWTRTweetMediaMIMEContentTypeMP4 = @"video/mp4";

TWTRMediaMIMEType TWTRMediaMIMETypeFromStringContentType(NSString *contentType)
{
    if ([contentType isEqualToString:TWTRTweetMediaMIMEContentTypeJPG]) {
        return TWTRMediaMIMETypeJPG;
    } else if ([contentType isEqualToString:TWTRTweetMediaMIMEContentTypePNG]) {
        return TWTRMediaMIMETypePNG;
    } else if ([contentType isEqualToString:TWTRTweetMediaMIMEContentTypeGIF]) {
        return TWTRMediaMIMETypeGIF;
    } else if ([contentType isEqualToString:TWTRTweetMediaMIMEContentTypeMP4]) {
        return TWTRMediaMIMETypeMP4;
    } else {
        NSLog(@"Unrecognizable Tweet media MIME content type.");
        return -1;
    }
}

NSString *NSStringFromTWTRMediaMIMEType(TWTRMediaMIMEType entityMIMEType)
{
    switch (entityMIMEType) {
        case TWTRMediaMIMETypeJPG:
            return TWTRTweetMediaMIMEContentTypeJPG;
        case TWTRMediaMIMETypePNG:
            return TWTRTweetMediaMIMEContentTypePNG;
        case TWTRMediaMIMETypeGIF:
            return TWTRTweetMediaMIMEContentTypeGIF;
        case TWTRMediaMIMETypeMP4:
            return TWTRTweetMediaMIMEContentTypeMP4;
    }
}
