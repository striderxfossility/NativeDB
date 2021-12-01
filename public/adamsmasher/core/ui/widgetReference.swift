
public static func OperatorEqual(var1: inkWidgetRef, var2: inkWidgetRef) -> Bool {
  return inkWidgetRef.Equals(var1, var2);
}

public native struct inkWidgetRef {

  public final static native func Get(self: inkWidgetRef) -> wref<inkWidget>;

  public final static native func IsValid(self: inkWidgetRef) -> Bool;

  public final static native func Equals(self: inkWidgetRef, other: inkWidgetRef) -> Bool;

  public final static native func GetName(self: inkWidgetRef) -> CName;

  public final static native func SetName(self: inkWidgetRef, widgetName: CName) -> Void;

  public final static native func GetController(self: inkWidgetRef) -> wref<inkLogicController>;

  public final static native func GetControllerByType(self: inkWidgetRef, controllerType: CName) -> wref<inkLogicController>;

  public final static native func GetControllers(self: inkWidgetRef) -> array<wref<inkLogicController>>;

  public final static native func GetControllersByType(self: inkWidgetRef, controllerType: CName) -> array<wref<inkLogicController>>;

  public final static native func GetNumControllers(self: inkWidgetRef) -> Int32;

  public final static native func GetNumControllersOfType(self: inkWidgetRef, controllerType: CName) -> Int32;

  public final static native func GetStylePath(self: inkWidgetRef) -> ResRef;

  public final static native func SetStyle(self: inkWidgetRef, styleResPath: ResRef) -> Void;

  public final static native func GetState(self: inkWidgetRef) -> CName;

  public final static native func SetState(self: inkWidgetRef, state: CName) -> Void;

  public final static func DefaultState(self: inkWidgetRef) -> CName {
    return n"Default";
  }

  public final static native func IsVisible(self: inkWidgetRef) -> Bool;

  public final static native func SetVisible(self: inkWidgetRef, visible: Bool) -> Void;

  public final static native func IsInteractive(self: inkWidgetRef) -> Bool;

  public final static native func SetInteractive(self: inkWidgetRef, value: Bool) -> Void;

  public final static native func SetLayout(self: inkWidgetRef, layout: inkWidgetLayout) -> Void;

  public final static native func GetMargin(self: inkWidgetRef) -> inkMargin;

  public final static native func SetMargin(self: inkWidgetRef, margin: inkMargin) -> Void;

  public final static func SetMargin(self: inkWidgetRef, left: Float, top: Float, right: Float, bottom: Float) -> Void {
    inkWidgetRef.SetMargin(self, new inkMargin(left, top, right, bottom));
  }

  public final static func UpdateMargin(self: inkWidgetRef, left: Float, top: Float, right: Float, bottom: Float) -> Void {
    let currentMargin: inkMargin = inkWidgetRef.GetMargin(self);
    currentMargin.left += left;
    currentMargin.top += top;
    currentMargin.right += right;
    currentMargin.bottom += bottom;
    inkWidgetRef.SetMargin(self, currentMargin);
  }

  public final static native func GetPadding(self: inkWidgetRef) -> inkMargin;

  public final static native func SetPadding(self: inkWidgetRef, padding: inkMargin) -> Void;

  public final static func SetPadding(self: inkWidgetRef, left: Float, top: Float, right: Float, bottom: Float) -> Void {
    inkWidgetRef.SetPadding(self, new inkMargin(left, top, right, bottom));
  }

  public final static native func GetHAlign(self: inkWidgetRef) -> inkEHorizontalAlign;

  public final static native func SetHAlign(self: inkWidgetRef, hAlign: inkEHorizontalAlign) -> Void;

  public final static native func GetVAlign(self: inkWidgetRef) -> inkEVerticalAlign;

  public final static native func SetVAlign(self: inkWidgetRef, vAlign: inkEVerticalAlign) -> Void;

  public final static native func GetAnchor(self: inkWidgetRef) -> inkEAnchor;

  public final static native func SetAnchor(self: inkWidgetRef, anchor: inkEAnchor) -> Void;

  public final static native func GetAnchorPoint(self: inkWidgetRef) -> Vector2;

  public final static native func SetAnchorPoint(self: inkWidgetRef, anchorPoint: Vector2) -> Void;

  public final static func SetAnchorPoint(self: inkWidgetRef, x: Float, y: Float) -> Void {
    inkWidgetRef.SetAnchorPoint(self, new Vector2(x, y));
  }

  public final static native func GetSizeRule(self: inkWidgetRef) -> inkESizeRule;

  public final static native func SetSizeRule(self: inkWidgetRef, sizeRule: inkESizeRule) -> Void;

  public final static native func GetSizeCoefficient(self: inkWidgetRef) -> Float;

  public final static native func SetSizeCoefficient(self: inkWidgetRef, sizeCoefficient: Float) -> Void;

  public final static native func GetFitToContent(self: inkWidgetRef) -> Bool;

  public final static native func SetFitToContent(self: inkWidgetRef, fitToContent: Bool) -> Void;

  public final static native func GetSize(self: inkWidgetRef) -> Vector2;

  public final static native func SetSize(self: inkWidgetRef, size: Vector2) -> Void;

  public final static func SetSize(self: inkWidgetRef, width: Float, height: Float) -> Void {
    inkWidgetRef.SetSize(self, new Vector2(width, height));
  }

  public final static func GetWidth(self: inkWidgetRef) -> Float {
    let size: Vector2 = inkWidgetRef.GetSize(self);
    return size.X;
  }

  public final static func GetHeight(self: inkWidgetRef) -> Float {
    let size: Vector2 = inkWidgetRef.GetSize(self);
    return size.Y;
  }

  public final static func SetWidth(self: inkWidgetRef, width: Float) -> Void {
    inkWidgetRef.SetSize(self, width, inkWidgetRef.GetHeight(self));
  }

  public final static func SetHeight(self: inkWidgetRef, height: Float) -> Void {
    inkWidgetRef.SetSize(self, inkWidgetRef.GetWidth(self), height);
  }

  public final static native func GetDesiredSize(self: inkWidgetRef) -> Vector2;

  public final static func GetDesiredWidth(self: inkWidgetRef) -> Float {
    let size: Vector2 = inkWidgetRef.GetDesiredSize(self);
    return size.X;
  }

  public final static func GetDesiredHeight(self: inkWidgetRef) -> Float {
    let size: Vector2 = inkWidgetRef.GetDesiredSize(self);
    return size.Y;
  }

  public final static native func GetTintColor(self: inkWidgetRef) -> HDRColor;

  public final static native func SetTintColor(self: inkWidgetRef, color: HDRColor) -> Void;

  public final static func SetTintColor(self: inkWidgetRef, color: Color) -> Void {
    inkWidgetRef.SetTintColor(self, Color.ToHDRColorDirect(color));
  }

  public final static func SetTintColor(self: inkWidgetRef, r: Uint8, g: Uint8, b: Uint8, a: Uint8) -> Void {
    inkWidgetRef.SetTintColor(self, new Color(r, g, b, a));
  }

  public final static native func GetOpacity(self: inkWidgetRef) -> Float;

  public final static native func SetOpacity(self: inkWidgetRef, opacity: Float) -> Void;

  public final static native func GetRenderTransformPivot(self: inkWidgetRef) -> Vector2;

  public final static native func SetRenderTransformPivot(self: inkWidgetRef, pivot: Vector2) -> Void;

  public final static func SetRenderTransformPivot(self: inkWidgetRef, x: Float, y: Float) -> Void {
    inkWidgetRef.SetRenderTransformPivot(self, new Vector2(x, y));
  }

  public final static native func SetScale(self: inkWidgetRef, scale: Vector2) -> Void;

  public final static native func GetScale(self: inkWidgetRef) -> Vector2;

  public final static native func SetShear(self: inkWidgetRef, shear: Vector2) -> Void;

  public final static native func GetShear(self: inkWidgetRef) -> Vector2;

  public final static native func SetRotation(self: inkWidgetRef, angleInDegrees: Float) -> Void;

  public final static native func GetRotation(self: inkWidgetRef) -> Float;

  public final static native func SetTranslation(self: inkWidgetRef, translationVector: Vector2) -> Void;

  public final static native func GetTranslation(self: inkWidgetRef) -> Vector2;

  public final static native func ChangeTranslation(self: inkWidgetRef, translationVector: Vector2) -> Void;

  public final static func SetTranslation(self: inkWidgetRef, x: Float, y: Float) -> Void {
    inkWidgetRef.SetTranslation(self, new Vector2(x, y));
  }

  public final static native func PlayAnimation(self: inkWidgetRef, animationDefinition: ref<inkAnimDef>) -> ref<inkAnimProxy>;

  public final static native func PlayAnimationWithOptions(self: inkWidgetRef, animationDefinition: ref<inkAnimDef>, playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final static native func StopAllAnimations(self: inkWidgetRef) -> Void;

  public final static native func CallCustomCallback(self: inkWidgetRef, eventName: CName) -> Void;

  public final static native func RegisterToCallback(self: inkWidgetRef, eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final static native func UnregisterFromCallback(self: inkWidgetRef, eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final static native func HasUserDataObject(self: inkWidgetRef, userDataTypeName: CName) -> Bool;

  public final static native func GetUserDataObjectCount(self: inkWidgetRef, userDataTypeName: CName) -> Uint32;

  public final static native func GetUserData(self: inkWidgetRef, userDataTypeName: CName) -> ref<inkUserData>;

  public final static native func GetUserDataArray(self: inkWidgetRef, userDataTypeName: CName) -> array<ref<inkUserData>>;

  public final static native func GatherUserData(self: inkWidgetRef, userDataTypeName: CName, userDataCollection: array<ref<inkUserData>>) -> Void;

  public final static native func Reparent(self: inkWidgetRef, newParent: wref<inkCompoundWidget>, opt index: Int32) -> Void;
}

public native struct inkCompoundRef extends inkWidgetRef {

  public final static native func GetNumChildren(self: inkCompoundRef) -> Int32;

  public final static native func AddChild(self: inkCompoundRef, widgetTypeName: CName) -> wref<inkWidget>;

  public final static native func AddChildWidget(self: inkCompoundRef, widget: wref<inkWidget>) -> Void;

  public final static native func GetWidgetByPath(self: inkCompoundRef, path: inkWidgetPath) -> wref<inkWidget>;

  public final static native func GetWidgetByIndex(self: inkCompoundRef, index: Int32) -> wref<inkWidget>;

  public final static func GetWidget(self: inkCompoundRef, path: inkWidgetPath) -> wref<inkWidget> {
    return inkCompoundRef.GetWidgetByPath(self, path);
  }

  public final static func GetWidget(self: inkCompoundRef, index: Int32) -> wref<inkWidget> {
    return inkCompoundRef.GetWidgetByIndex(self, index);
  }

  public final static native func GetWidgetByPathName(self: inkCompoundRef, widgetNamePath: CName) -> wref<inkWidget>;

  public final static func GetWidget(self: inkCompoundRef, path: CName) -> wref<inkWidget> {
    return inkCompoundRef.GetWidgetByPathName(self, path);
  }

  public final static native func RemoveChild(self: inkCompoundRef, childWidget: wref<inkWidget>) -> Void;

  public final static native func RemoveChildByIndex(self: inkCompoundRef, index: Int32) -> Void;

  public final static native func RemoveChildByName(self: inkCompoundRef, widgetName: CName) -> Void;

  public final static native func RemoveAllChildren(self: inkCompoundRef) -> Void;

  public final static native func ReorderChild(self: inkCompoundRef, childWidget: wref<inkWidget>, newIndex: Int32) -> Void;

  public final static native func GetChildOrder(self: inkBasePanelRef) -> inkEChildOrder;

  public final static native func SetChildOrder(self: inkBasePanelRef, newOrder: inkEChildOrder) -> Void;

  public final static native func GetChildPosition(self: inkCompoundRef, childWidget: wref<inkWidget>) -> Vector2;

  public final static native func GetChildSize(self: inkCompoundRef, childWidget: wref<inkWidget>) -> Vector2;
}

public native struct inkTextRef extends inkLeafRef {

  public final static native func GetText(self: inkTextRef) -> String;

  public final static native func SetText(self: inkTextRef, displayText: String, opt textParams: ref<inkTextParams>) -> Void;

  public final static native func SetTextDirect(self: inkTextRef, displayText: String) -> Void;

  public final static native func SetLocalizedText(self: inkTextRef, locKey: CName, opt textParams: ref<inkTextParams>) -> Void;

  public final static native func SetLocalizedTextString(self: inkTextRef, locKey: String, opt textParams: ref<inkTextParams>) -> Void;

  public final static func SetLocalizedTextScript(self: inkTextRef, locKey: String, opt textParams: ref<inkTextParams>) -> Void {
    if IsStringNumber(locKey) {
      inkTextRef.SetText(self, locKey, textParams);
    } else {
      if !IsStringValid(locKey) {
        inkTextRef.SetText(self, "", textParams);
      } else {
        inkTextRef.SetLocalizedTextString(self, locKey, textParams);
      };
    };
  }

  public final static func SetLocalizedTextScript(self: inkTextRef, locKey: CName, opt textParams: ref<inkTextParams>) -> Void {
    if !IsNameValid(locKey) {
      inkTextRef.SetText(self, "", textParams);
    } else {
      inkTextRef.SetLocalizedText(self, locKey, textParams);
    };
  }

  public final static native func GetTextParameters(self: inkTextRef) -> ref<inkTextParams>;

  public final static native func SetTextParameters(self: inkTextRef, textParams: ref<inkTextParams>) -> Void;

  public final static native func GetLocalizationKey(self: inkTextRef) -> CName;

  public final static native func SetLocalizationKey(self: inkTextRef, displayText: CName) -> Void;

  public final static native func SetLocalizationKeyString(self: inkTextRef, displayText: String) -> Void;

  public final static native func UpdateLanguageResources(self: inkTextRef, opt applyFontModifiers: Bool) -> Void;

  public final static native func SetTextFromParts(self: inkTextRef, textpart1: String, opt textpart2: String, opt textpart3: String) -> Void;

  public final static native func GetVerticalAlignment(self: inkTextRef) -> textVerticalAlignment;

  public final static native func SetVerticalAlignment(self: inkTextRef, verticalAlignment: textVerticalAlignment) -> Void;

  public final static func GetVerticalAlignmentEnumValue(self: inkTextRef, nameValue: CName) -> textVerticalAlignment {
    let returnValue: textVerticalAlignment;
    if Equals(nameValue, n"Top") {
      returnValue = textVerticalAlignment.Top;
    } else {
      if Equals(nameValue, n"Bottom") {
        returnValue = textVerticalAlignment.Bottom;
      } else {
        if Equals(nameValue, n"Center") {
          returnValue = textVerticalAlignment.Center;
        };
      };
    };
    return returnValue;
  }

  public final static native func GetHorizontalAlignment(self: inkTextRef) -> textHorizontalAlignment;

  public final static native func SetHorizontalAlignment(self: inkTextRef, horizontalAlignment: textHorizontalAlignment) -> Void;

  public final static func GetHorizontalAlignmentEnumValue(self: inkTextRef, nameValue: CName) -> textHorizontalAlignment {
    let returnValue: textHorizontalAlignment;
    if Equals(nameValue, n"Left") {
      returnValue = textHorizontalAlignment.Left;
    } else {
      if Equals(nameValue, n"Right") {
        returnValue = textHorizontalAlignment.Right;
      } else {
        if Equals(nameValue, n"Center") {
          returnValue = textHorizontalAlignment.Center;
        };
      };
    };
    return returnValue;
  }

  public final static native func SetFontFamily(self: inkTextRef, fontFamilyPath: String, opt fontStyle: CName) -> Void;

  public final static native func GetFontStyle(self: inkTextRef) -> CName;

  public final static native func SetFontStyle(self: inkTextRef, fontStyle: CName) -> Void;

  public final static native func GetFontSize(self: inkTextRef) -> Int32;

  public final static native func SetFontSize(self: inkTextRef, textSize: Int32) -> Void;

  public final static native func GetLetterCase(self: inkTextRef) -> textLetterCase;

  public final static native func SetLetterCase(self: inkTextRef, letterCase: textLetterCase) -> Void;

  public final static native func EnableAutoScroll(self: inkTextRef, enableState: Bool) -> Void;

  public final static native func SetDateTimeByTimestamp(self: inkTextRef, timestamp: Uint64) -> Void;

  public final static native func GetScrollTextSpeed(self: inkTextRef) -> Float;

  public final static native func SetScrollTextSpeed(self: inkTextRef, scrollTextSpeed: Float) -> Void;
}
