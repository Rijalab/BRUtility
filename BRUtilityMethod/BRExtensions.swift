//
//  BRExtensions.swift
//  BRUtilityMethod
//
//  Created by Balaji Ramakrishnan on 11/10/18.
//  Copyright © 2018 rijalab. All rights reserved.
//

import UIKit

struct ColorCode {
    static let appInputViewBackgroundColor: UInt32 = 0xF8F8F8
    static let appToolBarTintColor: UInt32 = 0xF0F0F0
    static let appTextGrayColor: UInt32 = 0x333333
    static let appInputErrorRedColor: UInt32 = 0xBF0000
    static let appBorderBlueColor: UInt32 = 0x37ABDE
    static let appPageControlColor: UInt32 = 0xAF2417
    static let appDarkBlue: UInt32 = 0x37ABFF
    static let appViewBlue: UInt32 = 0x2869A9
    static let appTextFieldBorderColor: UInt32 = 0x999999
}

// Required Values for Splitting Card No and Expiry date validation.
let splitByCount = 4, intervalString = "-"
let monthSymbol = "月", yearSymbol = "年"

//MARK:- UIColor Extension

extension UIColor{
    
    class func UIColorFromHex(_ rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

//MARK:- UITextField Extension

extension UITextField {
    
    private struct AssociatedObject {
        static var isfirstTime:Bool = false
    }
    
    var isfirstTime:Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedObject.isfirstTime) != nil)
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObject.isfirstTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func errorPlaceholderTextField(){
        self.placeHolderColor = UIColor.UIColorFromHex(ColorCode.appInputErrorRedColor, alpha: 1.0)
    }
    
    func errorTextField(){
        let attributedText = NSMutableAttributedString(attributedString: self.attributedText!)
        attributedText.setAttributes([NSAttributedString.Key.foregroundColor : UIColor.UIColorFromHex(ColorCode.appInputErrorRedColor, alpha: 1.0)], range: NSMakeRange(0, attributedText.length))
        self.attributedText = attributedText
    }
    
    @IBInspectable var doneCancelAccessory: Bool{
        get{
            return self.doneCancelAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneCancelButtonOnKeyboard()
            }
        }
    }
    
    var hasValidEmail: Bool {
        return text!.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                           options: String.CompareOptions.regularExpression,
                           range: nil, locale: nil) != nil
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    func addDoneCancelButtonOnKeyboard(){
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = false
        toolbar.barTintColor = UIColor.UIColorFromHex(ColorCode.appToolBarTintColor, alpha: 1.0)
        
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: nil, action: nil)
        cancelButton.tintColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        cancelButton.actionClosure = {
            self.resignFirstResponder()
        }
        
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        //        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 21))
        //        label.text = pickerTitle
        //        label.center = toolbar.center
        //        label.textColor = UIColor.UIColorFromHex(ColorCode.appTextColor, alpha: 1.0)
        //        label.textAlignment = NSTextAlignment.center
        //
        //        let toolbarTitle = UIBarButtonItem(customView: label)
        
        //        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: nil, action: nil)
        doneBtn.tintColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        doneBtn.actionClosure = {
            self.resignFirstResponder()
        }
        
        toolbar.items = [cancelButton,flexibleSpace1, doneBtn]
        
        self.inputAccessoryView = toolbar
        
    }
    
    func datePickerInputView(pickerTitle: String, datePickerMode: UIDatePicker.Mode? = .date, date:Date? = nil, minimumDate:Date? = nil, maximumDate:Date? = nil, completionHandler: @escaping (_ datePicker:UIDatePicker) -> Void){
        
        let datePickerView = UIDatePicker()
        datePickerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        datePickerView.backgroundColor = UIColor.UIColorFromHex(ColorCode.appInputViewBackgroundColor, alpha: 1.0)
        datePickerView.timeZone = TimeZone(identifier: "UTC")!
        datePickerView.locale = Locale.init(identifier: "ja_JP")
        datePickerView.calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        if let dateMode = datePickerMode
        {
            datePickerView.datePickerMode = dateMode
        }
        else
        {
            datePickerView.datePickerMode = .date
        }
        
        if let currentDate = date { // If Default Date not nil
            
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let currentDateComponent = calendar.dateComponents([.day,.month,.year], from: currentDate)
            //            currentDateComponent.day = 01
            //            currentDateComponent.month = 01
            //            currentDateComponent.year = 1970
            datePickerView.date = calendar.date(from: currentDateComponent)!
            
        }else{ //Default Date 01/01/1970
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            var currentDateComponent = DateComponents()
            currentDateComponent.day = 01
            currentDateComponent.month = 01
            currentDateComponent.year = 1970
            datePickerView.date = calendar.date(from: currentDateComponent)!
        }
        
        if let minimumDates = minimumDate
        {
            datePickerView.minimumDate = minimumDates
        }
        
        if let maximumDates = maximumDate
        {
            datePickerView.maximumDate = maximumDates
        }
        
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = false
        toolbar.barTintColor = UIColor.UIColorFromHex(ColorCode.appToolBarTintColor, alpha: 1.0)
        
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: nil, action: nil)
        cancelButton.tintColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        //        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)], for: .normal)
        cancelButton.actionClosure = {
            self.resignFirstResponder()
        }
        
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 21))
        label.text = pickerTitle
        label.center = toolbar.center
        label.textColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        let toolbarTitle = UIBarButtonItem(customView: label)
        
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: nil, action: nil)
        doneBtn.tintColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        //        doneBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)], for: .normal)
        doneBtn.actionClosure = {
            self.resignFirstResponder()
            completionHandler(datePickerView)
        }
        
        toolbar.items = [cancelButton,flexibleSpace1,toolbarTitle, flexibleSpace2, doneBtn]
        
        self.inputAccessoryView = toolbar
        datePickerView.sizeToFit()
        self.inputView = datePickerView
        
    }
    
    
    func customPickerWith(pickerTitle: String, target: UIViewController, completionHandler: @escaping (_ currentPosition: Int) -> Void){
        
        let picker = UIPickerView()
        picker.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        picker.dataSource = target as? UIPickerViewDataSource
        picker.delegate = target as? UIPickerViewDelegate
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = false
        toolbar.barTintColor = UIColor.UIColorFromHex(ColorCode.appToolBarTintColor, alpha: 1.0)
        
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: nil, action: nil)
        cancelButton.tintColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        //        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)], for: .normal)
        cancelButton.actionClosure = {
            self.resignFirstResponder()
        }
        
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 21))
        label.text = pickerTitle
        label.center = toolbar.center
        label.textColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        
        let toolbarTitle = UIBarButtonItem(customView: label)
        
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: nil, action: nil)
        doneBtn.tintColor = UIColor.UIColorFromHex(ColorCode.appTextGrayColor, alpha: 1.0)
        //        doneBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)], for: .normal)
        doneBtn.actionClosure = {
            self.resignFirstResponder()
            completionHandler(picker.selectedRow(inComponent: 0))
        }
        
        toolbar.items = [cancelButton,flexibleSpace1,toolbarTitle, flexibleSpace2, doneBtn]
        
        self.inputAccessoryView = toolbar
        picker.sizeToFit()
        self.inputView = picker
    }
    
    /// CREDIT CARD VALIDATION METHODs
    
    func canInsert(atLocation y:Int) -> Bool {
        return ((1 + y)%(splitByCount + 1) == 0) ? true : false
    }
    
    func canRemove(atLocation y:Int) -> Bool {
        return (y != 0) ? (y%(splitByCount + 1) == 0) : false
    }
    
    func formatCreditCardNos(range : NSRange, string : String) -> Bool {
        
        let nsText = self.text! as NSString
        
        let noSet = "0123456789"
        
        if string.count > 0, (string.rangeOfCharacter(from: CharacterSet.init(charactersIn: noSet)) == nil) {
            return false
        }
        
        if range.location == 19 { return false }
        
        if range.length == 0 && canInsert(atLocation: range.location) {
            self.text! = self.text! + intervalString + string
            return false
        }
        
        if range.length == 1 && canRemove(atLocation: range.location) {
            self.text! = nsText.replacingCharacters(in: NSMakeRange(range.location-1, 2), with: "")
            return false
        }
        return true
    }
    
    func formatCardHolderName(range : NSRange, string : String) -> Bool {
        // CharSet allows only character and space.
        if string == " " {
            return true
        }
        return (string.rangeOfCharacter(from: CharacterSet.letters.inverted) != nil) ? false : true
    }
    
    func formatExpiryMonthYear(range : NSRange, string : String) -> Bool {
        
        let nsText = self.text! as NSString
        if range.location == 7 { return false }
        
        if range.length == 0 {
            
            switch range.location {
            case 0:
                return (string == "0" || string == "1") ? true : false
            case 1:
                let typedMonth = Int(self.text! + string) ?? 0
                
                if typedMonth <= 12, typedMonth > 0 {
                    self.text! = String(format: "%02d", typedMonth) + monthSymbol  + "/"
                }
            case 5:
                self.text! = self.text!  + string + yearSymbol
            default:
                return true
            }
            return false
        }
        else if range.length == 1 {
            switch range.location {
            case 3:
                self.text! = nsText.replacingCharacters(in: NSMakeRange(range.location-2, 3), with: "")
            case 6:
                self.text! = nsText.replacingCharacters(in: NSMakeRange(range.location-1, 2), with: "")
            default:
                return true
            }
            return false
        }
        
        return true
    }
}

//MARK:- UIBarButtonItem Extension

extension UIBarButtonItem {
    private struct AssociatedObject {
        static var key = "action_closure_key"
    }
    
    var actionClosure: (()->Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObject.key) as? ()->Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            target = self
            action = #selector(didTapButton(sender:))
        }
    }
    
    @objc func didTapButton(sender: Any) {
        actionClosure?()
    }
}

//MARK:- UIViewController Extension

var currentScrollView: UIScrollView?

extension UIViewController {
    
    func showAlertViewController(withTitle title: String?, message: String?, autoHide: Bool? = false, completionBlock: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
        
        if let hide = autoHide {
            if hide == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    alert.dismiss(animated: true, completion: {
                        if let completion = completionBlock {
                            completion()
                        }
                    })
                }
            }else{
                
                let action = UIAlertAction.init(title: "Ok", style: .cancel) { (action) in
                    if let completion = completionBlock {
                        completion()
                    }
                }
                
                alert.addAction(action)
            }
        }
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func enableTextFieldFocus(forView : UIScrollView) {
        
        currentScrollView = forView
        let showNotification = NSNotification.init(name: UIResponder.keyboardWillShowNotification, object: nil)
        let hideNotification = NSNotification.init(name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: showNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: hideNotification.name, object: nil)
    }
    
    func disableTextFieldFocus() {
        let showNotification = NSNotification.init(name: UIResponder.keyboardWillShowNotification, object: nil)
        let hideNotification = NSNotification.init(name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: showNotification.name, object: nil)
        NotificationCenter.default.removeObserver(self, name: hideNotification.name, object: nil)
    }
    
    //MARK: Keyboard Show/Hide methods
    
    @objc func keyboardWillShow(notification : Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 253
        
        if let scrollView = currentScrollView {
            let contentInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight + 20, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(notification : Notification) {
        if let scrollView = currentScrollView {
            let contentInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
}

//MARK:- Double Extension

extension Double {
    func toCurrencySplitup() -> String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        if let formattedTipAmount = formatter.string(from: self as NSNumber) {
            return formattedTipAmount
        }
        else {
            return nil
        }
    }
}

//MARK:- Int Extension

extension Int {
    func toString() -> String {
        return "\(self)"
    }
    
    func toCurrencySplitup() -> String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        if let formattedTipAmount = formatter.string(from: self as NSNumber) {
            return formattedTipAmount
        }
        else {
            return nil
        }
    }
    
    func toFormattedCurrency() -> String {
        let ichiMan = 10000
        let manSymbol = "万"
        let yenSymbol = "円"
        
        var formattedCurrency = ""
        
        if self >= ichiMan {
            let amount = Double(self)/Double(ichiMan)
            if let formattedAmount = amount.toCurrencySplitup() {
                formattedCurrency = formattedAmount + manSymbol
            }
        }
        else {
            if let formattedAmount = self.toCurrencySplitup() {
                formattedCurrency = formattedAmount
            }
        }
        
        return formattedCurrency + yenSymbol
    }
}

//MARK:- Date Extension

extension Date {
    
    var getTimestamp: String {
        return String(UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000))
    }
    
    func toString(dateFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.current
        
        //        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        dateFormatter.dateFormat = dateFormat
        
        return (dateFormatter.string(from: self))
    }
}

//MARK:- UIView Extension

extension UIView {
    
    func makeRounded(){
        
        self.layer.cornerRadius = self.frame.height/2
    }
    
    func setShadow(shadowColor:UIColor? = nil){
        
        if let color = shadowColor
        {
            self.layer.shadowColor = color.cgColor
        }else
        {
            self.layer.shadowColor = UIColor.black.cgColor
        }
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.6
        self.layer.masksToBounds = false
    }
    
    
    @IBInspectable var cornerRadius: CGFloat {
        
        get {
            return layer.cornerRadius
        }
        set {
            
            layer.cornerRadius = newValue
            
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

//MARK:- String extension

extension String {
    
    func trimWhiteSpaces() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func removeSpecialCharsFromString() -> String {
        struct ValidCharaters {
            static let validChars = Set("1234567890")
        }
        return String(self.filter { ValidCharaters.validChars.contains($0) })
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
    
    subscript(_ range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }
    
    func toHalfWidth() -> String {
        let text: CFMutableString = NSMutableString(string: self) as CFMutableString
        CFStringTransform(text, nil, kCFStringTransformFullwidthHalfwidth, false)
        return text as String
    }
    
    func toFullWidth()-> String {
        let text: CFMutableString = NSMutableString(string: self) as CFMutableString
        CFStringTransform(text, nil, kCFStringTransformFullwidthHalfwidth, true)
        return text as String
    }
    
    func toFullWidthWithCharSet(from aSet: CharacterSet) -> String {
        return String(self.map {
            if String($0).rangeOfCharacter(from: aSet) != nil {
                let string = NSMutableString(string: String($0))
                CFStringTransform(string, nil, kCFStringTransformFullwidthHalfwidth, true)
                return String(string).first!
            } else {
                return $0
            }
        })
    }
    
    func toDate(format : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: self)
    }
}

//MARK:- UIImage Extension

extension UIImage {
    
    func compressTo(_ expectedSizeInMb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                    break
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    /*
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    */
}

//MARK:- UIApplication Extension

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

//MARK:- URL Extension

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
}
