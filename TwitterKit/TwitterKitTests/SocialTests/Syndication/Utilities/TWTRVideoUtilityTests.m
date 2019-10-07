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

#import "TWTRFixtureLoader.h"
#import "TWTRTestCase.h"
#import "TWTRVideoUtility.h"

@interface TWTRVideoUtilityTests : TWTRTestCase

@end

@implementation TWTRVideoUtilityTests

- (void)testVideoThumbnail
{
    NSURL *videoFileURL = [TWTRFixtureLoader videoFileURL];
    NSData *thumbnailData = [TWTRVideoUtility videoThumbnailDataForURL:videoFileURL];
    UIImage *thumbnail = [UIImage imageWithData:thumbnailData];
    XCTAssertNotNil(thumbnail);
    XCTAssertEqual(thumbnail.size.width, 122);
    XCTAssertEqual(thumbnail.size.height, 82);
}

- (void)testVideoDuration
{
    NSURL *videoFileURL = [TWTRFixtureLoader videoFileURL];
    double duration = [TWTRVideoUtility videoDuration:videoFileURL];
    XCTAssertEqual(duration, 3.43);
}

@end
