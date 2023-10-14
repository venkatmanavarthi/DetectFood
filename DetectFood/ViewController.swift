//
//  ViewController.swift
//  DetectFood
//
//  Created by Venkat Rao Manavarthi on 10/13/23.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var picker: UIImagePickerController = UIImagePickerController()
    let model = {
        do{
            let config = MLModelConfiguration()
            return try Inceptionv3(configuration: config)
        }catch{
            fatalError()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.sourceType = .camera
        self.picker.delegate = self
//        self.imageView.image = UIImage(systemName: "square.and.arrow.up")
        self.imageView.contentMode = .scaleAspectFill
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        self.present(self.picker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//    imagePickerController(_:didFinishPickingMediaWithInfo:)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.imageView.image = image
            if let cgImage = image.cgImage{
                self.detect(image: CIImage(cgImage: cgImage))
            }
        }
        picker.dismiss(animated: true)
    }
    
    func detect(image: CIImage){
        guard let m = try? VNCoreMLModel(for: self.model().model) else { return }
        let request = VNCoreMLRequest(model: m){ (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { fatalError() }
            print(results)
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }catch{
            print(error.localizedDescription)
        }
    }
}
