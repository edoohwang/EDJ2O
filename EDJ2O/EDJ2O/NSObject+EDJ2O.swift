

import Foundation

let EDModalNames = "modalNames"
let EDPropertyListDictionaty = "propertyListDictionaty"
public extension NSObject {
    

    /**
     字典数组转模型数组
     
     - parameter dictionaties: 字典数组
     
     - returns: 模型数组
     */
    // FIXME: 返回值如何动态获得数组元素类型
    class func ed_objectWithDictionaryArray(dictionaries: [[String: AnyObject!]])->[AnyObject] {
        var objs = [AnyObject]()
        
        for dict in dictionaries {
            let obj = self.ed_objectWithDictionary(dict)
            objs.append(obj)
        }
        return objs
    }
    /**
     字典转模型
     
     - parameter dictionaty: 字典
     
     - returns: 模型
     */
    class func ed_objectWithDictionary(dictionaty: [String: AnyObject!])->(Self) {
        let obj = self.init()
        
        obj.setKVInRuntime(dictionaty)
        
        return obj
    }
    
    
    convenience init(dictionaty: [String: AnyObject!]){
        self.init()
        
        setKVInRuntime(dictionaty)

    }
    /**
     运用运行时通过字典设置属性值
     
     - parameter dictionaty: 字典
     */
    private func setKVInRuntime(dictionaty: [String: AnyObject!])->() {
 
        let modalNames = getModalNames()
        
        let propertyListDictionaty = getPropertyListDictionaty()
        
        for name in modalNames {
                
            // 确保value有值，不然报错
            guard let value = dictionaty[name] else {
                continue
            }
            
            let className = propertyListDictionaty[name]!
            
       
            
            if value is NSDictionary {
                if !className.containsString("NS") {
                    // 二级转换
                    let clazz: AnyClass = NSClassFromString(className)!
                    
                    let obj = clazz.alloc()
                    (obj as! NSObject).setKVInRuntime(value as! [String : AnyObject!])
                    setValue(obj, forKey: name)
                    continue
                }
                
            } else if value is NSArray {
                
                guard let innerObjectOfArrayDictionary = self.ed_innerObjectOfArray() else {
                    setValue(value, forKey: name)
                    continue
                }
                for (_, v) in innerObjectOfArrayDictionary.enumerate() {
                    
                    let dictArray = value as! [[String : AnyObject!]]
                    let innerObjectKeyString = v.0
                    let innerObjectTypeString = String(reflecting: v.1)
                    
                    if name == innerObjectKeyString {
                       let clazz: AnyClass = NSClassFromString(innerObjectTypeString)!
                        let modals = (clazz as! NSObject.Type).ed_objectWithDictionaryArray(dictArray)
                       setValue(modals, forKey: name)
                    }
                }
                continue
            }
            
            setValue(value, forKey: name)
        }
        
 
    }
    /**
     如果模型中的成员有自定义对象数组的时候，需要实现这个方法，以能够在内部解析数组中的自定义类型是什么，返回一个字典，key是成员名称，value是类对象
     
     - returns: 需要解释模型内部自定义对象数组的类型字典
     */
    func ed_innerObjectOfArray() -> [String: AnyClass]? {
        return nil
    }
    
    /**
     懒加载并且单例化变量名数组，防止每次调运字典转模型的时候通过runtime的方式消耗资源
     
     - returns: 模型成员变量名数组
     */
    private func getModalNames()->([String]) {
        guard let modalNames = objc_getAssociatedObject(self, EDModalNames) else  {
            
            var modalNames = [String]()
            
            var propertylistCont: UInt32 = 0
            let pPropertyList = class_copyPropertyList(object_getClass(self), &propertylistCont)
            
            for i in 0..<propertylistCont {
                let property = pPropertyList[Int(i)]
                // 获得key
                let propertyName = property_getName(property)
                let name = String.fromCString(propertyName)!
                modalNames.append(name)
                
            }
            
            objc_setAssociatedObject(self, EDModalNames, modalNames, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            return modalNames
        }
        return modalNames as! ([String])
    }
    /**
     懒加载并且单例化变量名类型字典，防止每次调运字典转模型的时候通过runtime的方式消耗资源
     
     
     - returns: 模型成员变量名类型字典，字典key是通过getModalNames()获得的变量名子项
     */
    private func getPropertyListDictionaty()->([String : String!]) {
        guard let propertyListDictionaty = objc_getAssociatedObject(self, EDPropertyListDictionaty) else  {
            
            var propertyListDictionaty = [String: String!]()
            
            var propertylistCont: UInt32 = 0
            let pPropertyList = class_copyPropertyList(object_getClass(self), &propertylistCont)
            
            for i in 0..<propertylistCont {
                let property = pPropertyList[Int(i)]
                // 获得key
                let propertyName = property_getName(property)
                let name = String.fromCString(propertyName)!
                // 获得属性
                let propertyAttributes = property_getAttributes(property)
                let attr = String.fromCString(propertyAttributes)!
                
                let className = attributeToClassName(attr)
                propertyListDictionaty[name] =  className
                
            }
            
            objc_setAssociatedObject(self, EDPropertyListDictionaty, propertyListDictionaty, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            return propertyListDictionaty
        }
        return propertyListDictionaty as! ([String : String!])
    }
    
    /**
     iVar获得的属性字符串转换成为类名字符串
     
     - parameter attr: iVar获得的属性字符串
     
     - returns: 类名字符串
     */
    private func attributeToClassName(attr: String)->(String) {
        // T@"_TtC12EDWBLoaction10EDUserItem",N,&,Vuser
        let components = attr.componentsSeparatedByString(",")
        var className = components.first!
        className = className.substringFromIndex("T@".endIndex)
        className = className.stringByReplacingOccurrencesOfString("\"", withString: "")
 
        return className
    }
    

    

    
}