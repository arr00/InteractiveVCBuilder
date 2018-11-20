//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport






// This is esentially a web browser built in native swift and UIKIt
//Input in the following format:
// * Each line is an indevidual element
// * Each line contains first a class name (choose from the valid classes), and a dictionary containing item specifications
// * All coordinates are given in percentages relative to the rendered page and anchored at the element's center
// * Manditory specifactions are specified for each element in the documentation. Adherance to these is manditory—if not done correctly, an error will be thrown, and rendering will not complete.

//Actions
// * actions are based on tags of items
// * actions are defined in a seperate file, and are based on tags
// * actions may be saved as variables and passed into other actions only AFTER they are defined.
// * each action occupies one line of the file


var processedActions = [Int:() -> ()]()
func runActionsOn(vc:UIViewController,text:String) throws {
    let actions = text.components(separatedBy: "\n")
    
    
    // Type of actions
    // * animation
    // ** specify tag, destination, duration, curve
    
    
    // All actions MUST specify an animationTag
    // All actions have an optional on completion tag
    // In general, animations are run asyncrously
    
    let validAnimations = ["animation"]
    
    for action in actions {
        let value = action.components(separatedBy: "=")
        
        if validAnimations.contains(value[0]) {
            let input = value[1]
            guard let dictionary = try? input.buildDictionary() else {
                throw VCBuildingError.InvalidDictionaryFormat(message: "Issue building dictionary from input")
            }
            
            switch(value[0]) {
            case "animation":
                let action  = buildAnimationWithData(data:dictionary,vc:vc)
                processedActions[Int(dictionary["actionTag"]!)!] = action
            default:
                print("Invalid action")
            }
        }
    }
    
    print("Running actions")
    let actionToRun = processedActions[1]!
    print("running action")
    processedActions[1]!()
}


// MARK - ACTION CREATION

func buildAnimationWithData(data:[String:String],vc:UIViewController) -> (() -> ()) {
    let animation = {
        let itemOfInterest = vc.view.viewWithTag(Int(data["tag"]!)!)!
        UIView.animate(withDuration: Double(data["duration"]!)!, animations: {
            itemOfInterest.center = CGPoint(x: Double(data["toX"]!)!, y: Double(data["toY"]!)!)
        }, completion: { (success) in
            if(data["onCompletion"] != nil) {
                processedActions[Int(data["onCompletion"]!)!]!()
                
            }
        })
    }
    return animation
}



func buildVC(text:String) throws -> UIViewController  {
    var validClasses = ["button","imageview","textlabel","slider"]

    
    
    let viewController = UIViewController()
    viewController.view.backgroundColor = UIColor.white
    let items = text.components(separatedBy: "\n")
    
    for item in items {
        let values = item.components(separatedBy: "=")
        var standardized = [String]()
        for value in values {
            standardized.append(value.trimmingCharacters(in: .whitespaces).lowercased())
        }
        
        
        
        // Check first value for class
        if validClasses.contains(standardized[0]) {
            let input = values[1]
            // extract dictionary from standardized[1]
            guard let dictionary = try? input.buildDictionary() else {
                throw VCBuildingError.InvalidDictionaryFormat(message: "Issue building dictionary from input")
            }
            
            
            
            // Extract next four values for rect data. Always the same
            if dictionary.count < 5 {
                throw VCBuildingError.MissingEntries
            }
            
            
            let x = dictionary["x"]!.CGFloatValue() ?? 0
            let y = dictionary["y"]!.CGFloatValue() ?? 0
            let width = dictionary["width"]!.CGFloatValue() ?? 0
            let height = dictionary["height"]!.CGFloatValue() ?? 0
            let rect = CGRect(x: x, y: y, width: width, height: height)
            
            
            switch (standardized[0]) {
            case "button":
                do {
                    let button = try buildButtonWithData(rect: rect, data: dictionary)
                    viewController.view.addSubview(button)
                    print("Added button succesfully")
                }
                catch {
                    print("error building button")
                }
                
            case "imageview":
                let imageView = UIImageView(frame: rect)
                viewController.view.addSubview(imageView)
            case "textlabel":
                let label = UILabel(frame: rect)
                viewController.view.addSubview(label)
            case "slider":
                let slider = UISlider(frame: rect)
                viewController.view.addSubview(slider)
            default:
                print("Add nothing")
            }
        }
        else {
            print("Invalid class")
            if (standardized[0] != "") {
                throw VCBuildingError.InvalidClass
            }
        }
        
    }
    
    
    return viewController
}

// MARK - Element Creation

func buildTextLabelWithData(rect: CGRect, data: [String:String]) throws -> UILabel {
    // Data
    // required:
    // * text
    // optional
    // * textcolor
    // * backgroundcolor
    // * textcentering
    // * font
    return UILabel()
}

func buildButtonWithData(rect:CGRect, data:[String:String]) throws -> UIButton {
    // Data
    // required:
    // * color
    // * tag
    // optional:
    // * titleTextColor
    // * title
    /*var standardized = [String]()
    for dataPoint in data {
        standardized.append(dataPoint.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines))
    }*/
    
    if(data.count < 7) {
        throw ButtonBuildingError.MissingEntries
    }
    
    let button = UIButton(frame: rect)
    print(data["title"]!)
    
    button.backgroundColor = data["color"]!.colorValue() ?? .clear
    button.tag = Int(data["tag"]!) ?? -1
    
    
    
    
    
    // Set optional values
    if data.keys.contains("titleTextColor") {
        button.setTitleColor(data["titleTextColor"]!.colorValue() ?? .black, for: .normal)
    }
    
    if data.keys.contains("title") {
        button.setTitle(data["title"]!, for: .normal)
    }
    
    
    
    return button
}


enum VCBuildingError:Error {
    case InvalidClass
    case MissingEntries
    case InvalidDictionaryFormat(message:String?)
}
enum ButtonBuildingError:Error {
    case MissingEntries
}
enum DictionaryBuildingError:Error {
    case InvalidFormat
    case EmptyString
}


// MARK - Extensions
extension String {
    func CGFloatValue() -> CGFloat? {
        guard let doubleValue = Double(self) else {
            return nil
        }
        
        return CGFloat(doubleValue)
    }
    
    func colorValue() -> UIColor? {
        switch self.lowercased() {
        case "red":
            return UIColor.red
        case "blue":
            return UIColor.blue
        case "green":
            return UIColor.green
        case "orange":
            return UIColor.orange
        case "purple":
            return UIColor.purple
        case "clear":
            return UIColor.clear
        default:
            return nil
        }
    }
    
    public func buildDictionary() throws -> [String:String] {
        if self.isEmpty {
            throw DictionaryBuildingError.EmptyString
        }
        
        if self.first! != "[" || self.last! != "]" {
            throw DictionaryBuildingError.InvalidFormat
        }
        
        var contentString = self
        contentString.removeLast()
        contentString.removeFirst()
        
        var result = [String:String]()
        let dataEntries = contentString.components(separatedBy: ",")
        for dataEntry in dataEntries {
            let keyAndValue =  dataEntry.components(separatedBy: ":")
            result[keyAndValue[0]] = keyAndValue[1]
        }
        
        return result
        
    }
}




let url = Bundle.main.url(forResource: "testTxt", withExtension: "txt")!
let actionsUrl = Bundle.main.url(forResource: "actions", withExtension: "txt")!
do {
    let text = try String(contentsOf: url)
    let actionText = try String(contentsOf: actionsUrl)
    
    let vc = try buildVC(text: text)
    
    try runActionsOn(vc: vc, text: actionText)
    
    PlaygroundPage.current.liveView = vc
    
    
}
catch (let error) {
    print("Error, \(error.localizedDescription)")
    
}





