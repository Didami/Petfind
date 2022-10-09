//
//  ImageManager.swift
//  Petfind
//
//  Created by Didami on 02/02/22.
//

import UIKit
import Vision

final class ImageManager {
    
    static let shared = ImageManager()

    var animalRecognitionRequest = VNRecognizeAnimalsRequest(completionHandler: nil)
    private let animalRecognitionWorkQueue = DispatchQueue(label: "PetClassifierRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    enum ImageFetchError: Error {
        case invalidURL
        case networkError(Data?, URLResponse?)
    }

    private init() { }

    @discardableResult
    func fetchImage(urlString: String, completion: @escaping (_ result: Result<UIImage, Error>) -> Void) -> URLSessionTask? {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(.success(cachedImage))
            return nil
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(ImageFetchError.invalidURL))
            return nil
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let responseData = data,
                let httpUrlResponse = response as? HTTPURLResponse,
                200 ..< 300 ~= httpUrlResponse.statusCode,
                let image = UIImage(data: responseData)
            else {
                
                DispatchQueue.main.async {
                    completion(.failure(error ?? ImageFetchError.networkError(data, response)))
                }
                return
            }

            self.imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }

        task.resume()

        return task
    }
}

// MARK: - Animal Recognition
struct AnimalRecognition {
    var type: String
    var count: Int
    var confidence: Float
}

extension ImageManager {
    
    public func animalClassifier(image: UIImage, completion: @escaping (_ recognition: AnimalRecognition?) -> ()) {
        
        animalRecognitionRequest = VNRecognizeAnimalsRequest(completionHandler: { request, error in
            
            DispatchQueue.main.async {
                
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    
                    var animalRecognition: AnimalRecognition?
                    var animalCount = 0
                    
                    for result in results {
                        
                        let animals = result.labels
                        
                        for animal in animals {
                            
                            animalCount += 1
                            var animalLabel = ""
                            
                            if animal.identifier == "Dog" {
                                animalLabel = "Dog"
                            } else if animal.identifier == "Cat" {
                                animalLabel = "Cat"
                            } else {
                                animalLabel = "Other"
                            }
                            
                            animalRecognition = AnimalRecognition(type: animalLabel, count: animalCount, confidence: animal.confidence)
                        }
                    }
                    
                    completion(animalRecognition)
                }
            }
        })
        
        guard let cgImage = image.cgImage else { return }
        
        animalRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.animalRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
