//
//  NaturalLanguageHelper.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/14/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation
import NaturalLanguage

final class NaturalLanguageHelper {
  public static let shared = NaturalLanguageHelper()
  
  func processWithNLTagger(_ text: String) {
    
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    
    let lang = recognizer.dominantLanguage
    
    let hypotheses = recognizer.languageHypotheses(withMaximum: 4)
    
    print(lang, hypotheses)
    
  //  print(text)
    let tagger = NLTagger(tagSchemes: [.nameType])
    tagger.string = text

    let options: NLTagger.Options = [.omitPunctuation, .joinNames]
    let tags: [NLTag] = [.personalName, .placeName, .organizationName, .number]

    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
        // Get the most likely tag, and print it if it's a named entity.
  //    print("tag \(text[tokenRange]) \(tag?.rawValue)")
        if let tag = tag, tags.contains(tag) {
            print("NLTagger - \(text[tokenRange]): \(tag.rawValue)")
        }
            
    //    // Get multiple possible tags with their associated confidence scores.
    //    let (hypotheses, _) = tagger.tagHypotheses(at: tokenRange.lowerBound, unit: .word, scheme: .nameType, maximumCount: 1)
    //    print(hypotheses)
            
       return true
    }
  }
}
