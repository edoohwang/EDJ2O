# EDJ2O
---
This is a easy extension of NSObject to change JSON/Dictionaty to Object model with Swift!


##Installation
---
### CocoaPods

Add pod 'EDJ2O' to your Podfile or pod 'EDJ2O', :head if you're feeling adventurous.

### Manually
Drag the EDJ2O/EDJ2O folder into your project.

##Usage
---
you can make a object and set the key-value with a `json/dictionaty`:

```
let myObject = MyObject.ed_objectWithDictionary(objectkeyValueDictionaty) as! MyObject
```
and if you want to make a object array and set the key-value with a `json/dictionaty array`:

```
let myObjects = MyObject.ed_objectsWithDictionaryArray([objectkeyValueDictionaty]) as! [MyObject]
```
###Nesting
if you customize your object inner have customization object array,you need override the method in your customization class to make EDJ2O change correct：

```
class MyObject: NSObject {
   func ed_innerObjectTypeOfArray() -> [String: AnyClass]? {
        return ["innerObjArray1"，MyinnerObjType1，
        		"innerObjArray2"，MyinnerObjType2，
        		"innerObjArray3"，MyinnerObjType3，
        		]
    }
 }
```
