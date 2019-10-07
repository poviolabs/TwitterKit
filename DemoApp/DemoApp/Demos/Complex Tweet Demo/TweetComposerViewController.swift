//
//  TweetComposerViewController.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/31/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class TweetComposerViewController: UIViewController {

    enum ComposerType {
        case tweetComposer
        case tweetViewController
        case tweetViewControllerWithMedia
        case tweetViewControllerLastPhoto
        case tweetViewControllerWithLocalJPG
        case tweetViewControllerWithLocalPNG
        case tweetViewControllerWithLocalGIF
        case tweetViewControllerWithLocalMulti
    }

    enum PhotosError: Error {
        case emptyFetchResult
        case imageNotFound
    }

    // MARK: - Private Variables

    private lazy var composer: TWTRComposer = {
        let composer = TWTRComposer()
        composer.setText("Hello World.")
        return composer
    }()

    private var composerType: ComposerType

    // MARK: - Init

    required init(composerType: ComposerType) {
        self.composerType = composerType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentComposer()
    }

    // MARK: - Private Methods

    private func presentComposer() {
        switch composerType {
        case .tweetComposer: presentTweetComposer()
        case .tweetViewController: presentTweetViewController()
        case .tweetViewControllerWithMedia: presentTweetViewControllerWithMedia()
        case .tweetViewControllerLastPhoto: presentTweetViewControllerLastPhoto()
        case .tweetViewControllerWithLocalJPG: presentTweetViewControllerWithLocalJPG()
        case .tweetViewControllerWithLocalPNG: presentTweetViewControllerWithLocalPNG()
        case .tweetViewControllerWithLocalGIF: presentTweetViewControllerWithLocalGIF()
        case .tweetViewControllerWithLocalMulti: presentTweetViewControllerWithLocalMulti()
        }
    }

    private func presentTweetComposer() {
        composer.show(from: self) { [weak self] _ in
            self?.dismiss(animated: false, completion: nil)
        }
    }

    private func presentTweetViewController() {
        let composer = TWTRComposerViewController.emptyComposer()
        composer.delegate = self
        present(composer, animated: true, completion: nil)
    }

    private func presentTweetViewControllerWithMedia() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        picker.modalPresentationStyle = .overCurrentContext
        if #available(iOS 11.0, *) {
            picker.videoExportPreset = AVAssetExportPresetPassthrough
        }
        present(picker, animated: true, completion: nil)
    }

    private func presentTweetViewControllerLastPhoto() {
        fetchLastPhoto { [weak self] (image, error) in
            if let error = error, let weakSelf = self {
                UIAlertController.showAlert(with: error, on: weakSelf)
            } else if let image = image {
                let composer = TWTRComposerViewController(initialText: "Check out this photo!", image: image, videoData: nil)
                composer.delegate = self
                self?.present(composer, animated: true)
            }
        }
    }

    private func presentTweetViewControllerWithLocalJPG() {
        presentTweetViewControllerWithLocalImage("IMG_1", "JPG")
    }

    private func presentTweetViewControllerWithLocalPNG() {
        presentTweetViewControllerWithLocalImage("IMG_2", "PNG")
    }

    private func presentTweetViewControllerWithLocalGIF() {
        presentTweetViewControllerWithLocalImage("IMG_3", "GIF")
    }

    private func presentTweetViewControllerWithLocalImage(_ resource: String, _ type: String) {
        guard let imageData = dataFromBundleResource(resource, ofType: type) else { return }

        let composer = TWTRComposerViewController(initialText: "Check out this great image: ", images: [imageData], videoURL: nil)
        composer.delegate = self
        present(composer, animated: true)
    }

    private func presentTweetViewControllerWithLocalMulti() {
        guard let imageData1 = dataFromBundleResource("IMG_1", ofType: "JPG") else { return }
        guard let imageData2 = dataFromBundleResource("IMG_2", ofType: "PNG") else { return }

        let composer = TWTRComposerViewController(initialText: "Check out these great images: ", images: [imageData1, imageData2], videoURL: nil)
        composer.delegate = self
        present(composer, animated: true)
    }

    private func dataFromBundleResource(_ resource: String, ofType type: String) -> Data? {
        guard let bundleImagePath = Bundle.main.path(forResource: resource, ofType: type) else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: bundleImagePath))
    }

    private func fetchLastPhoto(_ completion: @escaping (UIImage?, Error?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]

        guard let image = (PHAsset.fetchAssets(with: .image, options: fetchOptions)).lastObject else {
            completion(nil, PhotosError.emptyFetchResult)
            return
        }

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: image, options: options) { (asset, mix, info) in
            DispatchQueue.main.async {
                let size = CGSize(width: 50.0, height: 50.0)
                PHImageManager.default().requestImage(for: image, targetSize: size, contentMode: .aspectFit, options: nil) { (image, info) in
                    if let image = image {
                        completion(image, nil)
                    } else {
                        completion(nil, PhotosError.imageNotFound)
                    }
                }
            }
        }
    }
}

// MARK: - TWTRComposerViewControllerDelegate

extension TweetComposerViewController: TWTRComposerViewControllerDelegate {
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension TweetComposerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let composer = TWTRComposerViewController(initialText: "Check out this great image: ", image: image, videoURL: nil)
            composer.delegate = self
            self.present(composer, animated: true)
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let composer = TWTRComposerViewController(initialText: "Check out this great video: ", images: nil, videoURL: videoURL)
            composer.delegate = self
            self.present(composer, animated: true)
        }
    }
}
