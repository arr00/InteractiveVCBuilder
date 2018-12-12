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

public class VCBuilder {
    
    public static let validClasses = ["button","imageview","textlabel","slider","experation"]
    public static func buildVC(text:String) throws -> UIViewController  {
        
        
        
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.white
        var items = text.components(separatedBy: "\n")
        
        // CHECK FOR EXPERATION
        if items.contains(where: { (str) -> Bool in
            return str.lowercased().hasPrefix("experation")
        }) {
            let indexOfExperation = items.index { (str) -> Bool in
                return str.lowercased().hasPrefix("experation")
            }
            let experationInfo = items[indexOfExperation!]
            let values = experationInfo.components(separatedBy: "=")
            let epochExp = TimeInterval(values[1])!
            if(Date().timeIntervalSince1970 > epochExp) {
                // EXPIRED
                let expiredVC = UIViewController()
                expiredVC.title = "EXPIRED"
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                label.text = "EXPIRED"
                label.font = UIFont.systemFont(ofSize: 20)
                expiredVC.view.addSubview(label)
                expiredVC.view.backgroundColor = UIColor.white
                return expiredVC
            }
            else {
                // NOT EXPIRED
                items.remove(at: indexOfExperation!)
            }
        }
        
        for item in items {
            let values = item.components(separatedBy: "=")
            var standardized = [String]()
            for value in values {
                standardized.append(value.trimmingCharacters(in: .whitespaces).lowercased())
            }
            
            
            
            // Check first value for class
            if VCBuilder.validClasses.contains(standardized[0]) {
                let input = values[1]
                // extract dictionary from standardized[1]
                guard let dictionary = try? input.buildDictionary() else {
                    throw VCBuildingError.InvalidDictionaryFormat(message: "Issue building dictionary from input")
                }
                
                
                
                // Extract next four values for rect data. Always the same
                if dictionary.count < 5 {
                    throw VCBuildingError.MissingEntries
                }
                
                var x:CGFloat = 0.0
                if dictionary["x"]!.contains("%") {
                    x = percentToPixelsHorizontal(percent: dictionary["x"]!)
                }
                else {
                    x = dictionary["x"]!.CGFloatValue() ?? 0
                }
                
                var y:CGFloat = 0.0
                if dictionary["y"]!.contains("%") {
                    y = percentToPixelsVertical(percent: dictionary["y"]!)
                }
                else {
                    y = dictionary["y"]!.CGFloatValue() ?? 0
                }
                
                var width:CGFloat = 0.0
                if dictionary["width"]!.contains("%") {
                    width = percentToPixelsHorizontal(percent: dictionary["width"]!)
                }
                else {
                    width = dictionary["width"]!.CGFloatValue() ?? 0
                }
                
                var height:CGFloat = 0.0
                if dictionary["height"]!.contains("%") {
                    height = percentToPixelsVertical(percent: dictionary["height"]!)
                }
                else {
                    height = dictionary["height"]!.CGFloatValue() ?? 0
                }
                
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
                    let imageView = buildImageViewWithData(rect: rect, data:dictionary)
                    
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
    
    public static func percentToPixelsVertical(percent:String) -> CGFloat {
        let changed = percent.replacingOccurrences(of: "%", with: "")
        let percentValue = CGFloat(Double(changed)!)/100
        let temp = UIViewController()
        return 660 * percentValue
    }
    public static func percentToPixelsHorizontal(percent:String) -> CGFloat {
        let changed = percent.replacingOccurrences(of: "%", with: "")
        let percentValue = CGFloat(Double(changed)!)/100
        let temp = UIViewController()
        return 375 * percentValue
    }
    
    // MARK - Element Creation
    
    private static func buildTextLabelWithData(rect: CGRect, data: [String:String]) throws -> UILabel {
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
    
    // Required:
    // * imageUrl
    private static func buildImageViewWithData(rect:CGRect, data:[String:String]) -> UIImageView {
        let imageView = UIImageView(frame: rect)
        let urlString = data["imageUrl"]!
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                print("Data is nill")
                return
            }
            let image = UIImage(data: data)!
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        
        task.resume()
        
        
        return imageView
    }
    
    private static func buildButtonWithData(rect:CGRect, data:[String:String]) throws -> UIButton {
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
}

public class AnimationRunner {
    private var processedActions = [Int:() -> ()]()
    public static let validAnimations = ["moveAnimation","opacityAnimation","jointAction","removeAction","buttonTriggerAction","rotateAnimation"]
    
    public func runActionsOn(vc:UIViewController,text:String) throws {
        let actions = text.components(separatedBy: "\n")
        
        
        // Type of actions
        // * animation
        // ** specify tag, destination, duration, curve
        
        
        // All actions MUST specify an animationTag
        // All actions have an optional onCompletion tag
        // In general, animations are run asyncrously
        
        
        
        for action in actions {
            let value = action.components(separatedBy: "=")
            
            if AnimationRunner.validAnimations.contains(value[0]) {
                let input = value[1]
                guard let dictionary = try? input.buildDictionary() else {
                    throw VCBuildingError.InvalidDictionaryFormat(message: "Issue building dictionary from input")
                }
                print(value[0])
                
                switch(value[0]) {
                case "moveAnimation":
                    let action  = buildMoveAnimationWithData(data:dictionary,vc:vc)
                    processedActions[Int(dictionary["actionTag"]!)!] = action
                case "rotateAnimation":
                    print("Building rotation animation")
                    let action = buildRotateAnimationWithData(data: dictionary, vc: vc)
                    
                    processedActions[Int(dictionary["actionTag"]!)!] = action
                case "opacityAnimation":
                    let action = buildOpacityAnimationWithData(data:dictionary,vc:vc)
                    processedActions[Int(dictionary["actionTag"]!)!] = action
                case "jointAction":
                    do {
                        let action = try buildJointAction(data: dictionary)
                        processedActions[Int(dictionary["actionTag"]!)!] = action
                    }
                    catch {
                        print("error building joint action")
                    }
                case "removeAction":
                    do {
                        let action = try buildRemoveAction(data:dictionary,vc:vc)
                        processedActions[Int(dictionary["actionTag"]!)!] = action
                    }
                    catch {
                        print("Error building remove action")
                    }
                case "buttonTriggerAction":
                    buildButtonTriggerAction(data:dictionary,vc:vc)
                    //Returns nil since it is just tethering an existing action to a button
                default:
                    print("Invalid action")
                }
            }
        }
        print("running action")
        processedActions[1]!()
    }
    
    
    // MARK - ACTION CREATION
    
    
    // * actionTag
    // * elementTag
    // * duration
    // * toX
    // * toY
    // * optional onCompletion
    private func buildMoveAnimationWithData(data:[String:String],vc:UIViewController) -> (() -> ()) {
        let animation = {
            let itemOfInterest = vc.view.viewWithTag(Int(data["elementTag"]!)!)!
            UIView.animate(withDuration: Double(data["duration"]!)!, delay: 0, options: [UIViewAnimationOptions.curveLinear], animations: {
                var x:CGFloat = 0.0
                if data["toX"]!.contains("%") {
                    x = VCBuilder.percentToPixelsHorizontal(percent: data["toX"]!)
                } else {
                    x = CGFloat(Double(data["toX"]!)!)
                }
                var y:CGFloat = 0.0
                if data["toY"]!.contains("%") {
                    y = VCBuilder.percentToPixelsVertical(percent: data["toY"]!)
                }
                else {
                    y = CGFloat(Double(data["toY"]!)!)
                }
                itemOfInterest.center = CGPoint(x:x, y: y)
            }, completion: { (success) in
                if(data["onCompletion"] != nil) {
                    self.processedActions[Int(data["onCompletion"]!)!]!()
                }
            })
            /*
            UIView.animate(withDuration: Double(data["duration"]!)!, animations: {
                itemOfInterest.center = CGPoint(x: Double(data["toX"]!)!, y: Double(data["toY"]!)!)
            }, completion: { (success) in
                if(data["onCompletion"] != nil) {
                    self.processedActions[Int(data["onCompletion"]!)!]!()
                }
            })*/
        }
        return animation
    }
    
    
    // Require:
    // * actionTag
    // * elementTag
    // * duration
    // * angle in radians
    private func buildRotateAnimationWithData(data:[String:String],vc:UIViewController) -> (() -> ()) {
        let animation = {
            let itemOfInterest = vc.view.viewWithTag(Int(data["elementTag"]!)!)!
            UIView.animate(withDuration: Double(data["duration"]!)!, animations: {
                itemOfInterest.transform = CGAffineTransform(rotationAngle: CGFloat(Double(data["angle"]!)!))
            }, completion: { (success) in
                if(data["onCompletion"] != nil) {
                    self.processedActions[Int(data["onCompletion"]!)!]!()
                }
            })
        }
        return animation
    }
    
    
    // Require:
    // * actionTag
    // * elementTag (must be a button)
    // * targetActionTag
    private func buildButtonTriggerAction(data:[String:String],vc:UIViewController) {
        let button = vc.view.viewWithTag(Int(data["elementTag"]!)!) as! UIButton
        button.addTargetClosure(closure: { (button) in
            print("Running action")
            self.processedActions[Int(data["targetActionTag"]!)!]!()
        })
    }
    
    
    // Require:
    // * actionTag
    // * elementTag
    // * targetOpacity
    // * duration
    // Optional:
    // * onCompletion
    private func buildOpacityAnimationWithData(data:[String:String],vc:UIViewController) -> () -> () {
        let animation = {
            let element = vc.view.viewWithTag(Int(data["elementTag"]!)!)!
            UIView.animate(withDuration: Double(data["duration"]!)!, animations: {
                element.alpha = NumberFormatter().number(from: data["targetOpacity"]!) as! CGFloat
                
            }, completion: { (success) in
                if(data.keys.contains("onCompletion")) {
                    self.processedActions[Int(data["onCompletion"]!)!]!()
                }
            })
        }
        return animation
    }
    
    
    // Require:
    // * tags (array of tags to run asyncronously) in the format [12,1,5,1,51]
    // * actionTag
    // * NO individual on completion. Must use on completion of child actions
    private func buildJointAction(data:[String:String]) throws -> () -> () {
        do {
            let arrayOfTags = try data["tags"]!.buildArray()
            let animation = {
                for tag in arrayOfTags {
                    let action = self.processedActions[Int(tag)!]!
                    action()
                }
            }
            return animation
        }
        catch {
            throw ActionBuildingError.ErrorBuildingAction
        }
    }
    
    private func buildRemoveAction(data:[String:String],vc:UIViewController) throws -> () -> () {
        guard let itemOfInterest = vc.view.viewWithTag(Int(data["elementTag"]!)!) else {
            throw ActionBuildingError.ErrorBuildingAction
        }
        
        let action = {
            itemOfInterest.removeFromSuperview()
        }
        
        return action
    }
    
}


public enum VCBuildingError:Error {
    case InvalidClass
    case MissingEntries
    case InvalidDictionaryFormat(message:String?)
}
public enum ButtonBuildingError:Error {
    case MissingEntries
}
public enum DictionaryBuildingError:Error {
    case InvalidFormat
    case EmptyString
}
public enum ArrayBuildingError:Error {
    case InvalidFormat
    case EmptyString
}

public enum ActionBuildingError:Error {
    case ErrorBuildingAction
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
            //Value is the rest
            var value = keyAndValue[1]
            if keyAndValue.count > 2 {
                for i in 2..<keyAndValue.count {
                    value += ":"
                    value += keyAndValue[i]
                }
            }
            result[keyAndValue[0]] = value
        }
        
        return result
        
    }
    
    public func buildArray() throws -> [String] {
        if self.isEmpty {
            throw ArrayBuildingError.EmptyString
        }
        if self.first! != "[" || self.last! != "]" {
            throw DictionaryBuildingError.InvalidFormat
        }
        
        var contentString = self
        contentString.removeLast()
        contentString.removeFirst()
        
        let result = contentString.components(separatedBy: "-")
        return result
    }
}




let url = Bundle.main.url(forResource: "testTxt", withExtension: "txt")!
let actionsUrl = Bundle.main.url(forResource: "actions", withExtension: "txt")!
do {
    let text = try String(contentsOf: url)
    let actionText = try String(contentsOf: actionsUrl)
    
    let vc = try VCBuilder.buildVC(text: text)
    
    
    if vc.title != "EXPIRED" {
        let actionRunner = AnimationRunner()
        try actionRunner.runActionsOn(vc: vc, text: actionText)
    }
    
    
    PlaygroundPage.current.liveView = vc
    
    
}
catch (let error) {
    print("Error, \(error.localizedDescription)")
    
}




typealias UIButtonTargetClosure = (UIButton) -> ()

class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

extension UIButton {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
}




