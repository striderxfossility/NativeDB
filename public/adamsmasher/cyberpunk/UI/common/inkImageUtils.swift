
public class InkImageUtils extends IScriptable {

  public final static func RequestSetImage(controller: ref<inkIGameController>, target: inkImageRef, iconID: CName, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, inkWidgetRef.Get(target) as inkImage, NameToString(iconID), callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkIGameController>, target: inkImageRef, iconID: String, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, inkWidgetRef.Get(target) as inkImage, iconID, callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkIGameController>, target: inkImageRef, iconID: TweakDBID, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, inkWidgetRef.Get(target) as inkImage, iconID, callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkIGameController>, target: wref<inkImage>, iconID: CName, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, target, TDBID.Create(NameToString(iconID)), callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkIGameController>, target: wref<inkImage>, iconID: String, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, target, TDBID.Create(iconID), callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkIGameController>, target: wref<inkImage>, iconID: TweakDBID, opt callbackFunction: CName) -> Void {
    let iconRef: ref<UIIconReference>;
    if IsDefined(target) {
      iconRef = new UIIconReference();
      iconRef.iconID = iconID;
      if IsDefined(controller) && IsNameValid(callbackFunction) {
        target.RequestSetImage(iconRef, controller, callbackFunction);
      } else {
        target.RequestSetImage(iconRef);
      };
    };
  }

  public final static func RequestSetImage(controller: ref<inkLogicController>, target: inkImageRef, iconID: String, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, inkWidgetRef.Get(target) as inkImage, iconID, callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkLogicController>, target: inkImageRef, iconID: CName, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, inkWidgetRef.Get(target) as inkImage, NameToString(iconID), callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkLogicController>, target: inkImageRef, iconID: TweakDBID, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, inkWidgetRef.Get(target) as inkImage, iconID, callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkLogicController>, target: wref<inkImage>, iconID: String, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, target, TDBID.Create(iconID), callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkLogicController>, target: wref<inkImage>, iconID: CName, opt callbackFunction: CName) -> Void {
    InkImageUtils.RequestSetImage(controller, target, TDBID.Create(NameToString(iconID)), callbackFunction);
  }

  public final static func RequestSetImage(controller: ref<inkLogicController>, target: wref<inkImage>, iconID: TweakDBID, opt callbackFunction: CName) -> Void {
    let iconRef: ref<UIIconReference>;
    if IsDefined(target) {
      iconRef = new UIIconReference();
      iconRef.iconID = iconID;
      if IsDefined(controller) && IsNameValid(callbackFunction) {
        target.RequestSetImage(iconRef, controller, callbackFunction);
      } else {
        target.RequestSetImage(iconRef);
      };
    };
  }
}
