
public class DeviceWidgetControllerBase extends DeviceInkLogicControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_backgroundTextureRef: inkImageRef;

  @attrib(category, "Widget Refs")
  protected edit let m_statusNameWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_actionsListWidget: inkWidgetRef;

  protected let m_actionWidgetsData: array<SActionWidgetPackage>;

  protected let m_actionData: ref<ResolveActionData>;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SDeviceWidgetPackage) -> Void {
    let actionWidget: ref<inkWidget>;
    let i: Int32;
    this.HideActionWidgets();
    i = 0;
    while i < ArraySize(widgetData.actionWidgets) {
      actionWidget = this.GetActionWidget(widgetData.actionWidgets[i], gameController);
      if actionWidget == null {
        this.CreateActionWidgetAsync(gameController, this.GetParentForActionWidgets(), widgetData.actionWidgets[i]);
      } else {
        this.InitializeActionWidget(gameController, actionWidget, widgetData.actionWidgets[i]);
      };
      i += 1;
    };
    if TDBID.IsValid(widgetData.bckgroundTextureID) {
      this.SetTexture(this.m_backgroundTextureRef, widgetData.bckgroundTextureID);
    } else {
      inkWidgetRef.SetVisible(this.m_backgroundTextureRef, false);
    };
    inkTextRef.SetLocalizedTextScript(this.m_statusNameWidget, widgetData.deviceStatus, widgetData.textData);
    inkTextRef.SetLocalizedTextScript(this.m_displayNameWidget, widgetData.displayName);
    if Equals(widgetData.widgetState, EWidgetState.ALLOWED) {
      inkWidgetRef.SetState(this.m_statusNameWidget, n"Allowed");
      inkWidgetRef.SetState(this.m_displayNameWidget, n"Allowed");
    } else {
      if Equals(widgetData.widgetState, EWidgetState.LOCKED) {
        inkWidgetRef.SetState(this.m_statusNameWidget, n"Locked");
        inkWidgetRef.SetState(this.m_displayNameWidget, n"Locked");
      } else {
        if Equals(widgetData.widgetState, EWidgetState.SEALED) {
          inkWidgetRef.SetState(this.m_statusNameWidget, n"Sealed");
          inkWidgetRef.SetState(this.m_displayNameWidget, n"Sealed");
        };
      };
    };
    this.m_isInitialized = true;
    if gameController != null {
      gameController.SetUICameraZoomState(false);
    };
  }

  public func GetParentForActionWidgets() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_actionsListWidget);
  }

  protected final func CreateActionWidgetAsync(gameController: ref<DeviceInkGameControllerBase>, parentWidget: wref<inkWidget>, widgetData: SActionWidgetPackage) -> Void {
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if this.HasActionWidgetData(widgetData, gameController) {
      return;
    };
    screenDef = gameController.GetScreenDefinition();
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnActionWidgetSpawned", ToVariant(widgetData), gameController);
    widgetData.libraryID = gameController.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath, spawnData);
    this.AddActionWidgetData(widgetData, gameController);
  }

  protected cb func OnActionWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let deviceGameController: ref<DeviceInkGameControllerBase>;
    let spawnData: ref<AsyncSpawnData>;
    let widgetData: SActionWidgetPackage;
    if widget != null {
      widget.SetSizeRule(inkESizeRule.Stretch);
    };
    spawnData = userData as AsyncSpawnData;
    if spawnData != null {
      deviceGameController = spawnData.m_controller as DeviceInkGameControllerBase;
      widgetData = FromVariant(spawnData.m_widgetData);
      if deviceGameController != null {
        widgetData.widget = widget;
        widgetData.libraryID = spawnData.m_libraryID;
        this.UpdateActionWidgetData(widgetData, this.GetActionWidgetDataIndex(widgetData, deviceGameController));
        this.InitializeActionWidget(deviceGameController, widget, widgetData);
      };
    };
  }

  protected final func CreateActionWidget(gameController: ref<DeviceInkGameControllerBase>, parentWidget: wref<inkWidget>, widgetData: SActionWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    let widget: ref<inkWidget> = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    if widget != null {
      widget.SetSizeRule(inkESizeRule.Stretch);
    };
    return widget;
  }

  protected final func GetActionWidget(widgetData: SActionWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> wref<inkWidget> {
    let index: Int32 = this.GetActionWidgetDataIndex(widgetData, gameController);
    if index >= 0 && index < ArraySize(this.m_actionWidgetsData) {
      return this.m_actionWidgetsData[index].widget;
    };
    return null;
  }

  protected final func UpdateActionWidgetData(widgetData: SActionWidgetPackage, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_actionWidgetsData) {
      this.m_actionWidgetsData[index] = widgetData;
    };
  }

  protected final func GetActionWidgetDataIndex(widgetData: SActionWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Int32 {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_actionWidgetsData) {
      if Equals(this.m_actionWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_actionWidgetsData[i].widgetName, widgetData.widgetName) && this.m_actionWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_actionWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_actionWidgetsData[i].libraryID, widgetData.libraryID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected final func HasActionWidgetData(widgetData: SActionWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Bool {
    return this.GetActionWidgetDataIndex(widgetData, gameController) >= 0;
  }

  protected final func HasActionWidget(widgetData: SActionWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Bool {
    return this.GetActionWidget(widgetData, gameController) != null;
  }

  protected final func AddActionWidget(widget: ref<inkWidget>, widgetData: SActionWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_actionWidgetsData, widgetData);
    return widgetData.widget;
  }

  protected final func AddActionWidgetData(widgetData: SActionWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    ArrayPush(this.m_actionWidgetsData, widgetData);
  }

  protected final func InitializeActionWidget(gameController: ref<DeviceInkGameControllerBase>, widget: ref<inkWidget>, widgetData: SActionWidgetPackage) -> Void {
    let controller: ref<DeviceActionWidgetControllerBase> = widget.GetController() as DeviceActionWidgetControllerBase;
    if controller != null {
      controller.Initialize(gameController, widgetData);
    };
    widget.SetVisible(true);
  }

  protected final func HideActionWidgets() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_actionWidgetsData) {
      if this.m_actionWidgetsData[i].widget != null {
        this.m_actionWidgetsData[i].widget.SetVisible(false);
      };
      i += 1;
    };
  }

  protected func ResolveAction(widgetData: SActionWidgetPackage) -> Void;
}
