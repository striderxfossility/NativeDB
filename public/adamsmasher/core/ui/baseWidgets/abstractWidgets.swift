
public abstract native class inkWidget extends IScriptable {

  public final native func GetName() -> CName;

  public final native func SetName(widgetName: CName) -> Void;

  public final native func GetController() -> wref<inkLogicController>;

  public final native func GetControllerByType(controllerType: CName) -> wref<inkLogicController>;

  public final native func GetControllerByBaseType(controllerType: CName) -> wref<inkLogicController>;

  public final native func GetControllers() -> array<wref<inkLogicController>>;

  public final native func GetControllersByType(controllerType: CName) -> array<wref<inkLogicController>>;

  public final native func GetNumControllers() -> Int32;

  public final native func GetNumControllersOfType(controllerType: CName) -> Int32;

  public final native func GetStylePath() -> ResRef;

  public final native func SetStyle(styleResPath: ResRef) -> Void;

  public final native func GetState() -> CName;

  public final native func SetState(state: CName) -> Void;

  public final static func DefaultState() -> CName {
    return n"Default";
  }

  public final native func IsVisible() -> Bool;

  public final native func SetVisible(visible: Bool) -> Void;

  public final native func IsInteractive() -> Bool;

  public final native func SetInteractive(value: Bool) -> Void;

  public final native func SetLayout(layout: inkWidgetLayout) -> Void;

  public final native func GetAffectsLayoutWhenHidden() -> Bool;

  public final native func SetAffectsLayoutWhenHidden(affectsLayoutWhenHidden: Bool) -> Void;

  public final native func GetMargin() -> inkMargin;

  public final native func SetMargin(margin: inkMargin) -> Void;

  public final func SetMargin(left: Float, top: Float, right: Float, bottom: Float) -> Void {
    this.SetMargin(new inkMargin(left, top, right, bottom));
  }

  public final func UpdateMargin(left: Float, top: Float, right: Float, bottom: Float) -> Void {
    let currentMargin: inkMargin = this.GetMargin();
    currentMargin.left += left;
    currentMargin.top += top;
    currentMargin.right += right;
    currentMargin.bottom += bottom;
    this.SetMargin(currentMargin);
  }

  public final native func GetPadding() -> inkMargin;

  public final native func SetPadding(padding: inkMargin) -> Void;

  public final func SetPadding(left: Float, top: Float, right: Float, bottom: Float) -> Void {
    this.SetPadding(new inkMargin(left, top, right, bottom));
  }

  public final native func GetHAlign() -> inkEHorizontalAlign;

  public final native func SetHAlign(hAlign: inkEHorizontalAlign) -> Void;

  public final native func GetVAlign() -> inkEVerticalAlign;

  public final native func SetVAlign(vAlign: inkEVerticalAlign) -> Void;

  public final native func GetAnchor() -> inkEAnchor;

  public final native func SetAnchor(anchor: inkEAnchor) -> Void;

  public final native func GetAnchorPoint() -> Vector2;

  public final native func SetAnchorPoint(anchorPoint: Vector2) -> Void;

  public final func SetAnchorPoint(x: Float, y: Float) -> Void {
    this.SetAnchorPoint(new Vector2(x, y));
  }

  public final native func GetSizeRule() -> inkESizeRule;

  public final native func SetSizeRule(sizeRule: inkESizeRule) -> Void;

  public final native func GetSizeCoefficient() -> Float;

  public final native func SetSizeCoefficient(sizeCoefficient: Float) -> Void;

  public final native func GetFitToContent() -> Bool;

  public final native func SetFitToContent(fitToContent: Bool) -> Void;

  public final native func GetSize() -> Vector2;

  public final native func SetSize(size: Vector2) -> Void;

  public final func SetSize(width: Float, height: Float) -> Void {
    this.SetSize(new Vector2(width, height));
  }

  public final func GetWidth() -> Float {
    let size: Vector2 = this.GetSize();
    return size.X;
  }

  public final func GetHeight() -> Float {
    let size: Vector2 = this.GetSize();
    return size.Y;
  }

  public final func SetWidth(width: Float) -> Void {
    this.SetSize(width, this.GetHeight());
  }

  public final func SetHeight(height: Float) -> Void {
    this.SetSize(this.GetWidth(), height);
  }

  public final native func GetDesiredSize() -> Vector2;

  public final func GetDesiredWidth() -> Float {
    let size: Vector2 = this.GetDesiredSize();
    return size.X;
  }

  public final func GetDesiredHeight() -> Float {
    let size: Vector2 = this.GetDesiredSize();
    return size.Y;
  }

  public final native func GetTintColor() -> HDRColor;

  public final native func SetTintColor(color: HDRColor) -> Void;

  public final func SetTintColor(r: Uint8, g: Uint8, b: Uint8, a: Uint8) -> Void {
    this.SetTintColor(new Color(r, g, b, a));
  }

  public final func SetTintColor(color: Color) -> Void {
    this.SetTintColor(Color.ToHDRColorDirect(color));
  }

  public final native func GetOpacity() -> Float;

  public final native func SetOpacity(opacity: Float) -> Void;

  public final native func GetRenderTransformPivot() -> Vector2;

  public final native func SetRenderTransformPivot(pivot: Vector2) -> Void;

  public final func SetRenderTransformPivot(x: Float, y: Float) -> Void {
    this.SetRenderTransformPivot(new Vector2(x, y));
  }

  public final native func SetScale(scale: Vector2) -> Void;

  public final native func GetScale() -> Vector2;

  public final native func SetShear(shear: Vector2) -> Void;

  public final native func GetShear() -> Vector2;

  public final native func SetRotation(angleInDegrees: Float) -> Void;

  public final native func GetRotation() -> Float;

  public final native func SetTranslation(translationVector: Vector2) -> Void;

  public final native func GetTranslation() -> Vector2;

  public final native func ChangeTranslation(translationVector: Vector2) -> Void;

  public final func SetTranslation(x: Float, y: Float) -> Void {
    this.SetTranslation(new Vector2(x, y));
  }

  public final native func PlayAnimation(animationDefinition: ref<inkAnimDef>) -> ref<inkAnimProxy>;

  public final native func PlayAnimationWithOptions(animationDefinition: ref<inkAnimDef>, playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final native func StopAllAnimations() -> Void;

  public final native func CallCustomCallback(eventName: CName) -> Void;

  public final native func RegisterToCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func UnregisterFromCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func SetEffectEnabled(effectType: inkEffectType, effectName: CName, enabled: Bool) -> Void;

  public final native func GetEffectEnabled(effectType: inkEffectType, effectName: CName) -> Bool;

  public final native func DisableAllEffectsByType(effectType: inkEffectType) -> Void;

  public final native func GetEffectParamValue(effectType: inkEffectType, effectName: CName, paramName: CName) -> Float;

  public final native func SetEffectParamValue(effectType: inkEffectType, effectName: CName, paramName: CName, paramValue: Float) -> Float;

  public final native func HasUserDataObject(userDataTypeName: CName) -> Bool;

  public final native func GetUserDataObjectCount(userDataTypeName: CName) -> Uint32;

  public final native func GetUserData(userDataTypeName: CName) -> ref<inkUserData>;

  public final native func GetUserDataArray(userDataTypeName: CName) -> array<ref<inkUserData>>;

  public final native func GatherUserData(userDataTypeName: CName, userDataCollection: array<ref<inkUserData>>) -> Void;

  public final native func BindProperty(propertyName: CName, stylePath: CName) -> Bool;

  public final native func UnbindProperty(propertyName: CName) -> Bool;

  public final native func Reparent(newParent: wref<inkCompoundWidget>, opt index: Int32) -> Void;
}

public abstract native class inkCompoundWidget extends inkWidget {

  public final native func GetNumChildren() -> Int32;

  public final native func AddChild(widgetTypeName: CName) -> wref<inkWidget>;

  public final native func AddChildWidget(widget: wref<inkWidget>) -> Void;

  public final native func GetWidgetByPath(path: inkWidgetPath) -> wref<inkWidget>;

  public final native func GetWidgetByIndex(index: Int32) -> wref<inkWidget>;

  public final func GetWidget(path: inkWidgetPath) -> wref<inkWidget> {
    return this.GetWidgetByPath(path);
  }

  public final func GetWidget(index: Int32) -> wref<inkWidget> {
    return this.GetWidgetByIndex(index);
  }

  public final native func GetWidgetByPathName(widgetNamePath: CName) -> wref<inkWidget>;

  public final func GetWidget(path: CName) -> wref<inkWidget> {
    return this.GetWidgetByPathName(path);
  }

  public final native func RemoveChild(childWidget: wref<inkWidget>) -> Void;

  public final native func RemoveChildByIndex(index: Int32) -> Void;

  public final native func RemoveChildByName(widgetName: CName) -> Void;

  public final native func RemoveAllChildren() -> Void;

  public final native func ReorderChild(childWidget: wref<inkWidget>, newIndex: Int32) -> Void;

  public final native func GetChildOrder() -> inkEChildOrder;

  public final native func SetChildOrder(newOrder: inkEChildOrder) -> Void;

  public final native func GetChildMargin() -> inkMargin;

  public final native func SetChildMargin(newMargin: inkMargin) -> Void;

  public final native func GetChildPosition(widget: wref<inkWidget>) -> Vector2;

  public final native func GetChildSize(widget: wref<inkWidget>) -> Vector2;
}
