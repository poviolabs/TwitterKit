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

#import "TWTRSharedComposerWrapper.h"
#import <AVFoundation/AVFoundation.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <UIKit/UIKit.h>
#import "TWTRComposerAccount.h"
#import "TWTRComposerNetworking.h"
#import "TWTRComposerViewController.h"
#import "TWTRErrors.h"
#import "TWTRLocalizedResources.h"
#import "TWTRSETweet.h"
#import "TWTRSETweetAttachment.h"
#import "TWTRSETweetShareViewController.h"
#import "TWTRTwitter.h"
#import "TWTRTwitterText.h"
#import "TWTRTwitter_Private.h"
#import "TWTRWordRange.h"
#import "TWTRVideoUtility.h"
#import "TWTRImageLoaderImageUtils.h"

NSArray *existingAccounts()
{
    NSMutableArray<TWTRComposerAccount *> *accounts = [NSMutableArray array];

    TWTRSessionStore *sessionStore = [TWTRTwitter sharedInstance].sessionStore;
    NSArray *currentSessions = [sessionStore existingUserSessions];
    for (TWTRSession *session in currentSessions) {
        [accounts addObject:accountFromSession(session)];
    }

    return accounts;
}

@implementation TWTRSharedComposerWrapper

#pragma mark - Initialization

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image attachment:(id<TWTRSETweetAttachment>)attachment
{
    NSArray *images = image ? @[[TWTRImageLoaderImageUtils imageDataFromImage:image]] : nil;
    return [self initWithText:text images:images attachment:attachment];
}

- (instancetype)initWithText:(NSString *)text images:(NSArray<NSData *> *)images attachment:(id<TWTRSETweetAttachment>)attachment
{
    self.networking = [[TWTRComposerNetworking alloc] init];
    self.networking.delegate = self;

    // Networking & Accounts
    NSArray *accounts = existingAccounts();
    if (accounts.count == 0) {
        NSLog(@"[TwitterKit] Error: Composer created without any user accounts set up. It is the responsibility of the developer to ensure that Twitter Kit has a logged-in user before presenting a composer. See https://dev.twitter.com/twitterkit/ios/compose-tweets#presenting-a-basic-composer");
    }
    TWTRSETweet *tweet = [self tweetWithText:text attachment:attachment images:images];

    // Shared Composer
    TWTRSETweetShareConfiguration *config = [[TWTRSETweetShareConfiguration alloc] initWithInitialTweet:tweet accounts:accounts initiallySelectedAccount:[accounts lastObject] geoTagging:nil autoCompletion:nil cardPreviewProvider:nil imageDownloader:[self imageLoader] localizedResources:[TWTRLocalizedResources class] networking:self.networking twitterText:[TWTRTwitterText class] wordRangeCalculator:[NSString class] delegate:self];

    self = [super initWithConfiguration:config];

    return self;
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoURL:(nullable NSURL *)videoURL {
    NSArray *images = image ? @[[TWTRImageLoaderImageUtils imageDataFromImage:image]] : nil;
    return [self initWithInitialText:initialText images:images videoURL:videoURL];
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText images:(nullable NSArray<NSData *> *)images videoURL:(nullable NSURL *)videoURL
{
    if ([videoURL.scheme isEqualToString:@"assets-library"]) {
        NSLog(@"Incorrect video URL format was provided. Use key `UIImagePickerControllerMediaURL` from the `didFinishPickingMediaWithInfo:` info parameter.");
        return nil;
    }

    if (videoURL && images) {
        NSLog(@"Only one attachment type may be provided (image or video).");
        return nil;
    }

    if (videoURL && !(images.count > 0)) {
        images = @[[TWTRVideoUtility videoThumbnailDataForURL:videoURL]];
    }

    id<TWTRSETweetAttachment> attachment = nil;
    if (videoURL) {
        attachment = [[TWTRSETweetAttachmentMedia alloc] initWithImages:images videoURL:videoURL];
    }

    if (self = [self initWithText:initialText images:images attachment:attachment]) {
        if (videoURL) {
            NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
            // Must set this after [self init] is called
            [self.networking prepareVideoData:videoData];
        }
    }

    return self;
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoData:(nullable NSData *)videoData {
    NSArray *images = image ? @[[TWTRImageLoaderImageUtils imageDataFromImage:image]] : nil;
    return [self initWithInitialText:initialText images:images videoData:videoData];
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText images:(nullable NSArray<NSData *> *)images videoData:(nullable NSData *)videoData
{
    if (videoData && !(images.count > 0)) {
        NSLog(@"The video doesn't have a preview image to show in composer.");
        return nil;
    }

    if (self = [self initWithText:initialText images:images attachment:nil]) {
        if (videoData) {
            [self.networking prepareVideoData:videoData];
        }
    }

    return self;
}

#pragma mark - Internal Methods

// Provide backup values for the image loader so tests don't need to call startWithConsumerKey:consumerSecret:
- (TWTRImageLoader *)imageLoader
{
    return [TWTRTwitter sharedInstance].imageLoader ?: [[TWTRImageLoader alloc] initWithSession:[NSURLSession sharedSession] cache:nil taskManager:[[TWTRImageLoaderTaskManager alloc] init]];
}

- (TWTRSETweet *)tweetWithText:(NSString *)text attachment:(id<TWTRSETweetAttachment>)attachment images:(NSArray<NSData *> *)images
{
    id<TWTRSETweetAttachment> tweetAttachment = attachment ?: [self attachmentWithImages:images];

    return [[TWTRSETweet alloc] initWithInReplyToTweetID:nil text:text attachment:tweetAttachment place:nil usernames:nil hashtags:nil];
}

- (id<TWTRSETweetAttachment>)attachmentWithImages:(NSArray<NSData *> *)images
{
    if (images) {
        if (images.count > 1) {
            return [[TWTRSETweetAttachmentMedia alloc] initWithImages:images videoURL:nil];
        } else if (images.count == 1) {
            return [[TWTRSETweetAttachmentImage alloc] initWithImageData:images[0]];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

#pragma mark - TWTRSETweetShareViewControllerDelegate Protocol Methods

- (void)shareViewControllerWantsToCancelComposerWithPartiallyComposedTweet:(nonnull TWTRSETweet *)partiallyComposedTweet
{
    [self dismissViewControllerAnimated:YES completion:nil];

    // Reset the pending video data so that a second Tweet doesn't attempt
    // to send that data again (or send data for a cancelled Tweet)
    [self.networking cancelPendingVideoUpload];
    [self.delegate composerDidCancel:(TWTRComposerViewController *)self];
}

- (void)shareViewControllerDidFinishSendingTweet
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareViewController:(TWTRSETweetShareViewController *)shareViewController didSelectAccount:(id<TWTRSEAccount>)account
{
    self.currentUserID = [NSString stringWithFormat:@"%llu", account.userID];
}

- (void)shareViewControllerPresentedWithNoAccounts
{
    NSLog(@"[TwitterKit] Error: composer presented with no available Twitter accounts.");
    [self dismissViewControllerAnimated:NO
                             completion:^{
                                 NSError *error = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Error: There is no Twitter account."}];
                                 [self.delegate composerDidFail:(TWTRComposerViewController *)self withError:error];
                             }];
}

#pragma mark - TWTRComposerNetworkingDelegate Protocol Methods

- (void)didFinishSendingTweet:(TWTRTweet *)tweet
{
    NSLog(@"Did successfully send Tweet: %@", tweet);
    [self.delegate composerDidSucceed:(TWTRComposerViewController *)self withTweet:tweet];
}

- (void)didAbortSendingTweetWithError:(NSError *)error
{
    NSLog(@"Did encounter error sending Tweet: %@", error);
    [self.delegate composerDidFail:(TWTRComposerViewController *)self withError:error];
}

@end
