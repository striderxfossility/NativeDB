
public abstract native class inkIGameController extends IScriptable {

  public final native func GetRootWidget() -> wref<inkWidget>;

  public final native func GetRootCompoundWidget() -> wref<inkCompoundWidget>;

  public final native func GetWidget(path: inkWidgetPath) -> wref<inkWidget>;

  public final native func GetController(opt path: inkWidgetPath) -> wref<inkLogicController>;

  public final native func GetControllerByType(controllerType: CName, opt path: inkWidgetPath) -> wref<inkLogicController>;

  public final native func GetControllers(opt path: inkWidgetPath) -> array<wref<inkLogicController>>;

  public final native func GetControllersByType(controllerType: CName, opt path: inkWidgetPath) -> array<wref<inkLogicController>>;

  public final native func GetNumControllers(opt path: inkWidgetPath) -> Int32;

  public final native func GetNumControllersOfType(controllerType: CName, opt path: inkWidgetPath) -> Int32;

  public final native func RequestSetFocus(const widget: wref<inkWidget>) -> Void;

  public final native func GetChildWidgetByPath(widgetNamePath: CName) -> wref<inkWidget>;

  public final native func GetChildControllerByPath(widgetNamePath: CName) -> wref<inkLogicController>;

  public final func GetWidget(widgetNamePath: CName) -> wref<inkWidget> {
    return this.GetChildWidgetByPath(widgetNamePath);
  }

  public final func GetController(widgetNamePath: CName) -> wref<inkLogicController> {
    return this.GetChildControllerByPath(widgetNamePath);
  }

  public final native func SpawnFromLocal(parentWidget: wref<inkWidget>, libraryID: CName) -> wref<inkWidget>;

  public final native func SpawnFromExternal(parentWidget: wref<inkWidget>, resourcePath: ResRef, libraryID: CName) -> wref<inkWidget>;

  public final native func AsyncSpawnFromLocal(spawnData: ref<inkAsyncSpawnData>, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName) -> wref<inkAsyncSpawnRequest>;

  public final func AsyncSpawnFromLocal(parentWidget: wref<inkWidget>, libraryID: CName, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName, opt userData: ref<IScriptable>) -> wref<inkAsyncSpawnRequest> {
    let spawnData: ref<inkAsyncSpawnData> = new inkAsyncSpawnData();
    spawnData.parentWidget = parentWidget as inkCompoundWidget;
    spawnData.libraryID = libraryID;
    spawnData.userData = userData;
    return this.AsyncSpawnFromLocal(spawnData, callbackObject, callbackFunctionName);
  }

  public final native func AsyncSpawnFromExternal(spawnData: ref<inkAsyncSpawnData>, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName) -> wref<inkAsyncSpawnRequest>;

  public final func AsyncSpawnFromExternal(parentWidget: wref<inkWidget>, resourcePath: ResRef, libraryID: CName, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName, opt userData: ref<IScriptable>) -> wref<inkAsyncSpawnRequest> {
    let spawnData: ref<inkAsyncSpawnData> = new inkAsyncSpawnData();
    spawnData.parentWidget = parentWidget as inkCompoundWidget;
    spawnData.libraryID = libraryID;
    spawnData.userData = userData;
    spawnData.SetResourcePath(resourcePath);
    return this.AsyncSpawnFromExternal(spawnData, callbackObject, callbackFunctionName);
  }

  public final native func HasLocalLibrary(libraryID: CName) -> Bool;

  public final native func HasExternalLibrary(resourcePath: ResRef, opt libraryID: CName) -> Bool;

  public final native func CallCustomCallback(eventName: CName) -> Void;

  public final native func RegisterToCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func UnregisterFromCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func RegisterToGlobalInputCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func UnregisterFromGlobalInputCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func PlayLibraryAnimation(animationName: CName, opt playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final native func PlayLibraryAnimationOnTargets(animationName: CName, targets: ref<inkWidgetsSet>, opt playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final native func PlayLibraryAnimationOnAutoSelectedTargets(animationName: CName, target: ref<inkWidget>, opt playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final native func GetSystemRequestsHandler() -> wref<inkISystemRequestsHandler>;

  public final native func QueueEvent(evt: ref<Event>) -> Void;

  private func ReadUICondition(condition: gamedataUICondition) -> Bool {
    return false;
  }

  public final func FindLibraryID(widgetRecord: ref<WidgetDefinition_Record>, opt screenTypeRecord: ref<DeviceScreenType_Record>, opt styleRecord: ref<WidgetStyle_Record>, opt id: CName, opt path: ResRef) -> CName {
    let i: Int32;
    let ids: array<String>;
    let libraryID: CName;
    let libraryPath: ResRef;
    if widgetRecord == null {
      libraryPath = path;
      if IsNameValid(id) {
        libraryID = id;
      };
    } else {
      libraryPath = widgetRecord.LibraryPath();
      ids = SWidgetPackageBase.GetLibraryIDPackage(widgetRecord, screenTypeRecord, styleRecord);
      i = 0;
      while i < ArraySize(ids) {
        libraryID = StringToName(ids[i]);
        if this.HasLocalLibrary(libraryID) {
        } else {
          if this.HasExternalLibrary(libraryPath, libraryID) {
          } else {
            i += 1;
          };
        };
      };
    };
    return libraryID;
  }

  public final func RequestWidgetFromLibrary(parentWidget: wref<inkWidget>, widgetRecord: ref<WidgetDefinition_Record>, opt screenTypeRecord: ref<DeviceScreenType_Record>, opt styleRecord: ref<WidgetStyle_Record>, opt id: CName, opt path: ResRef, spawnData: ref<AsyncSpawnData>) -> CName {
    let i: Int32;
    let ids: array<String>;
    let libraryID: CName;
    let libraryPath: ResRef;
    if widgetRecord == null {
      libraryPath = path;
      if IsNameValid(id) {
        libraryID = id;
        this.CreateWidgetAsync(parentWidget, libraryID, libraryPath, spawnData);
      };
    } else {
      libraryPath = widgetRecord.LibraryPath();
      ids = SWidgetPackageBase.GetLibraryIDPackage(widgetRecord, screenTypeRecord, styleRecord);
      i = 0;
      while i < ArraySize(ids) {
        libraryID = StringToName(ids[i]);
        if this.CreateWidgetAsync(parentWidget, libraryID, libraryPath, spawnData) {
        } else {
          i += 1;
        };
      };
    };
    return libraryID;
  }

  public final func FindWidgetInLibrary(parentWidget: wref<inkWidget>, widgetRecord: ref<WidgetDefinition_Record>, opt screenTypeRecord: ref<DeviceScreenType_Record>, opt styleRecord: ref<WidgetStyle_Record>, opt id: CName, opt path: ResRef) -> wref<inkWidget> {
    let i: Int32;
    let ids: array<String>;
    let libraryID: CName;
    let libraryPath: ResRef;
    let widget: ref<inkWidget>;
    if widgetRecord == null {
      libraryPath = path;
      if IsNameValid(id) {
        libraryID = id;
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
      };
    } else {
      libraryPath = widgetRecord.LibraryPath();
      ids = SWidgetPackageBase.GetLibraryIDPackage(widgetRecord, screenTypeRecord, styleRecord);
      i = 0;
      while i < ArraySize(ids) {
        libraryID = StringToName(ids[i]);
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
        if widget != null {
        } else {
          i += 1;
        };
      };
    };
    return widget;
  }

  public final func FindWidgetDataInLibrary(parentWidget: wref<inkWidget>, widgetRecord: ref<WidgetDefinition_Record>, opt screenTypeRecord: ref<DeviceScreenType_Record>, opt styleRecord: ref<WidgetStyle_Record>, opt id: CName, opt path: ResRef) -> SWidgetPackageBase {
    let i: Int32;
    let ids: array<String>;
    let libraryID: CName;
    let libraryPath: ResRef;
    let widget: ref<inkWidget>;
    let widgetData: SWidgetPackageBase;
    if widgetRecord == null {
      libraryPath = path;
      widgetData.libraryPath = libraryPath;
      if IsNameValid(id) {
        libraryID = id;
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
        widgetData.libraryID = libraryID;
        widgetData.widget = widget;
      };
    } else {
      libraryPath = widgetRecord.LibraryPath();
      widgetData.libraryPath = libraryPath;
      ids = SWidgetPackageBase.GetLibraryIDPackage(widgetRecord, screenTypeRecord, styleRecord);
      i = 0;
      while i < ArraySize(ids) {
        libraryID = StringToName(ids[i]);
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
        if widget != null {
          widgetData.libraryID = libraryID;
          widgetData.widget = widget;
        } else {
          i += 1;
        };
      };
    };
    return widgetData;
  }

  protected final func CreateWidget(parentWidget: wref<inkWidget>, id: CName, path: ResRef) -> wref<inkWidget> {
    let widget: ref<inkWidget>;
    if parentWidget == null {
      return widget;
    };
    if this.HasLocalLibrary(id) {
      widget = this.SpawnFromLocal(parentWidget, id);
    } else {
      if this.HasExternalLibrary(path, id) {
        widget = this.SpawnFromExternal(parentWidget, path, id);
      };
    };
    return widget;
  }

  protected final func CreateWidgetAsync(parentWidget: wref<inkWidget>, id: CName, opt path: ResRef, spawnData: ref<AsyncSpawnData>) -> Bool {
    let returnValue: Bool;
    if parentWidget == null {
      return false;
    };
    if this.HasLocalLibrary(id) {
      spawnData.m_libraryID = id;
      this.AsyncSpawnFromLocal(parentWidget, id, spawnData.m_callbackTarget, spawnData.m_functionName, spawnData);
      returnValue = true;
    } else {
      if this.HasExternalLibrary(path, id) {
        spawnData.m_libraryID = id;
        this.AsyncSpawnFromExternal(parentWidget, path, id, spawnData.m_callbackTarget, spawnData.m_functionName, spawnData);
        returnValue = true;
      } else {
        returnValue = false;
      };
    };
    return returnValue;
  }
}

public native class inkLogicController extends inkILogicController {

  public final native func GetRootWidget() -> wref<inkWidget>;

  public final native func GetRootCompoundWidget() -> wref<inkCompoundWidget>;

  public final native func GetWidget(path: inkWidgetPath) -> wref<inkWidget>;

  public final native func GetController(opt path: inkWidgetPath) -> wref<inkLogicController>;

  public final native func GetControllerByType(controllerType: CName, opt path: inkWidgetPath) -> wref<inkLogicController>;

  public final native func GetControllerByBaseType(controllerType: CName, opt path: inkWidgetPath) -> wref<inkLogicController>;

  public final native func GetControllers(opt path: inkWidgetPath) -> array<wref<inkLogicController>>;

  public final native func GetControllersByType(controllerType: CName, opt path: inkWidgetPath) -> array<wref<inkLogicController>>;

  public final native func GetNumControllers(opt path: inkWidgetPath) -> Int32;

  public final native func GetNumControllersOfType(controllerType: CName, opt path: inkWidgetPath) -> Int32;

  public final native func GetChildWidgetByPath(widgetNamePath: CName) -> wref<inkWidget>;

  public final native func GetChildControllerByPath(widgetNamePath: CName) -> wref<inkLogicController>;

  public final func GetWidget(widgetNamePath: CName) -> wref<inkWidget> {
    return this.GetChildWidgetByPath(widgetNamePath);
  }

  public final func GetController(widgetNamePath: CName) -> wref<inkLogicController> {
    return this.GetChildControllerByPath(widgetNamePath);
  }

  public final native func CallCustomCallback(eventName: CName) -> Void;

  public final native func RegisterToCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func UnregisterFromCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func RegisterToGlobalInputCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func UnregisterFromGlobalInputCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void;

  public final native func SpawnFromLocal(parentWidget: wref<inkWidget>, libraryID: CName) -> wref<inkWidget>;

  public final native func SpawnFromExternal(parentWidget: wref<inkWidget>, resourcePath: ResRef, libraryID: CName) -> wref<inkWidget>;

  public final native func AsyncSpawnFromLocal(spawnData: ref<inkAsyncSpawnData>, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName) -> wref<inkAsyncSpawnRequest>;

  public final func AsyncSpawnFromLocal(parentWidget: wref<inkWidget>, libraryID: CName, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName, opt userData: ref<IScriptable>) -> wref<inkAsyncSpawnRequest> {
    let spawnData: ref<inkAsyncSpawnData> = new inkAsyncSpawnData();
    spawnData.parentWidget = parentWidget as inkCompoundWidget;
    spawnData.libraryID = libraryID;
    spawnData.userData = userData;
    return this.AsyncSpawnFromLocal(spawnData, callbackObject, callbackFunctionName);
  }

  public final native func AsyncSpawnFromExternal(spawnData: ref<inkAsyncSpawnData>, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName) -> wref<inkAsyncSpawnRequest>;

  public final func AsyncSpawnFromExternal(parentWidget: wref<inkWidget>, resourcePath: ResRef, libraryID: CName, opt callbackObject: ref<IScriptable>, opt callbackFunctionName: CName, opt userData: ref<IScriptable>) -> wref<inkAsyncSpawnRequest> {
    let spawnData: ref<inkAsyncSpawnData> = new inkAsyncSpawnData();
    spawnData.parentWidget = parentWidget as inkCompoundWidget;
    spawnData.libraryID = libraryID;
    spawnData.userData = userData;
    spawnData.SetResourcePath(resourcePath);
    return this.AsyncSpawnFromExternal(spawnData, callbackObject, callbackFunctionName);
  }

  protected final func CreateWidgetAsync(parentWidget: wref<inkWidget>, id: CName, opt path: ResRef, spawnData: ref<AsyncSpawnData>) -> Bool {
    let returnValue: Bool;
    if parentWidget == null {
      return false;
    };
    if this.HasLocalLibrary(id) {
      spawnData.m_libraryID = id;
      this.AsyncSpawnFromLocal(parentWidget, id, spawnData.m_callbackTarget, spawnData.m_functionName, spawnData);
      returnValue = true;
    } else {
      if this.HasExternalLibrary(path, id) {
        spawnData.m_libraryID = id;
        this.AsyncSpawnFromExternal(parentWidget, path, id, spawnData.m_callbackTarget, spawnData.m_functionName, spawnData);
        returnValue = true;
      } else {
        returnValue = false;
      };
    };
    return returnValue;
  }

  public final native func HasLocalLibrary(libraryID: CName) -> Bool;

  public final native func HasExternalLibrary(resourcePath: ResRef, opt libraryID: CName) -> Bool;

  public final native func SetCursorContext(context: CName, opt data: ref<inkUserData>) -> Void;

  public final native func SetCursorOverWidget(widget: wref<inkWidget>) -> Void;

  public final native func PlayLibraryAnimation(animationName: CName, opt playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final native func PlayLibraryAnimationOnTargets(animationName: CName, targets: ref<inkWidgetsSet>, opt playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final native func PlayLibraryAnimationOnAutoSelectedTargets(animationName: CName, target: ref<inkWidget>, opt playbackOptions: inkAnimOptions) -> ref<inkAnimProxy>;

  public final native func PlaySound(widgetName: CName, eventName: CName, opt actionKey: CName) -> Void;

  public final native func Reparent(newParent: wref<inkCompoundWidget>, opt index: Int32) -> Void;

  public final native func QueueEvent(evt: ref<Event>) -> Void;

  public final native func QueueBroadcastEvent(evt: ref<Event>) -> Void;

  protected final func SetTexture(imageWidget: wref<inkImage>, textureID: TweakDBID) -> Void {
    if imageWidget != null && TDBID.IsValid(textureID) {
      InkImageUtils.RequestSetImage(this, imageWidget, textureID);
    };
  }

  protected final func SetTexture(imageRef: inkImageRef, textureID: TweakDBID) -> Void {
    let imageWidget: wref<inkImage> = inkWidgetRef.Get(imageRef) as inkImage;
    if imageWidget != null && TDBID.IsValid(textureID) {
      InkImageUtils.RequestSetImage(this, imageWidget, textureID);
    };
  }

  protected final func SetTexture(imageWidget: wref<inkImage>, textureRecord: wref<UIIcon_Record>) -> Void {
    if imageWidget != null && textureRecord != null {
      imageWidget.SetAtlasResource(textureRecord.AtlasResourcePath());
      imageWidget.SetTexturePart(textureRecord.AtlasPartName());
    };
  }

  protected final func SetTexture(imageRef: inkImageRef, textureRecord: wref<UIIcon_Record>) -> Void {
    if inkWidgetRef.IsValid(imageRef) && textureRecord != null {
      inkImageRef.SetAtlasResource(imageRef, textureRecord.AtlasResourcePath());
      inkImageRef.SetTexturePart(imageRef, textureRecord.AtlasPartName());
    };
  }

  public final func FindWidgetInLibrary(parentWidget: wref<inkWidget>, widgetRecord: ref<WidgetDefinition_Record>, opt screenTypeRecord: ref<DeviceScreenType_Record>, opt styleRecord: ref<WidgetStyle_Record>, opt id: CName, opt path: ResRef) -> wref<inkWidget> {
    let i: Int32;
    let ids: array<String>;
    let libraryID: CName;
    let libraryPath: ResRef;
    let widget: ref<inkWidget>;
    if widgetRecord == null {
      libraryPath = path;
      if IsNameValid(id) {
        libraryID = id;
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
      };
    } else {
      libraryPath = widgetRecord.LibraryPath();
      ids = SWidgetPackageBase.GetLibraryIDPackage(widgetRecord, screenTypeRecord, styleRecord);
      i = 0;
      while i < ArraySize(ids) {
        libraryID = StringToName(ids[i]);
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
        if widget != null {
        } else {
          i += 1;
        };
      };
    };
    return widget;
  }

  public final func FindWidgetDataInLibrary(parentWidget: wref<inkWidget>, widgetRecord: ref<WidgetDefinition_Record>, opt screenTypeRecord: ref<DeviceScreenType_Record>, opt styleRecord: ref<WidgetStyle_Record>, opt id: CName, opt path: ResRef) -> SWidgetPackageBase {
    let i: Int32;
    let ids: array<String>;
    let libraryID: CName;
    let libraryPath: ResRef;
    let widget: ref<inkWidget>;
    let widgetData: SWidgetPackageBase;
    if widgetRecord == null {
      libraryPath = path;
      widgetData.libraryPath = libraryPath;
      if IsNameValid(id) {
        libraryID = id;
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
        widgetData.libraryID = libraryID;
        widgetData.widget = widget;
      };
    } else {
      libraryPath = widgetRecord.LibraryPath();
      widgetData.libraryPath = libraryPath;
      ids = SWidgetPackageBase.GetLibraryIDPackage(widgetRecord, screenTypeRecord, styleRecord);
      i = 0;
      while i < ArraySize(ids) {
        libraryID = StringToName(ids[i]);
        widget = this.CreateWidget(parentWidget, libraryID, libraryPath);
        if widget != null {
          widgetData.libraryID = libraryID;
          widgetData.widget = widget;
        } else {
          i += 1;
        };
      };
    };
    return widgetData;
  }

  protected final func CreateWidget(parentWidget: wref<inkWidget>, id: CName, path: ResRef) -> wref<inkWidget> {
    let widget: ref<inkWidget>;
    if parentWidget == null {
      return widget;
    };
    if this.HasLocalLibrary(id) {
      widget = this.SpawnFromLocal(parentWidget, id);
    } else {
      if this.HasExternalLibrary(path, id) {
        widget = this.SpawnFromExternal(parentWidget, path, id);
      };
    };
    return widget;
  }
}
