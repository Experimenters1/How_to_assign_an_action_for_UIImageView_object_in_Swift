//
//  ViewController.swift
//  test1
//
//  Created by Huy Vu on 8/25/23.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var videoView_img: UIImageView!
    
    private var compressedPath: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // create tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        
        // add it to the image view;
        videoView_img.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        videoView_img.isUserInteractionEnabled = true
    }
    
    
    @IBAction func extractAudioAnd_Export(_ sender: Any) {
        let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String]
            present(picker, animated: true)
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            
            DispatchQueue.main.async { [unowned self] in
                let player = AVPlayer(url: self.compressedPath! as URL)
                let controller = AVPlayerViewController()
                controller.player = player
                self.present(controller, animated: true) {
                    player.play()
                }
            }
            
        }
    }
    

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            return
        }
        
        print("fvbhvbvfbvfbfh \(url)")
        updateCellImage(with: url)
        compressedPath = url
        videoView_img.contentMode = .scaleAspectFit
        
    }
    
    
    func generateThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            completion(thumbnail)
        } catch {
            print(error.localizedDescription)
            completion(nil)
        }
    }


    func updateCellImage(with url: URL) {
        generateThumbnail(url: url) { [weak self] thumbnail in
            DispatchQueue.main.async {
                if let image = thumbnail {
                    self?.videoView_img.image = image
                    self?.videoView_img.contentMode = .scaleAspectFit
                } else {
                    print("No Img") // Placeholder image if thumbnail generation fails
                }
            }
        }
    }

}
