
public class MasterDeviceInkGameControllerBase extends DeviceInkGameControllerBase {

  protected let m_thumbnailWidgetsData: array<SThumbnailWidgetPackage>;

  private let m_onThumbnailWidgetsUpdateListener: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected final func CreateThumbnailWidgetAsync(parentWidget: wref<inkWidget>, widgetData: SThumbnailWidgetPackage) -> Void {
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if this.HasThumbnailWidgetData(widgetData) {
      return;
    };
    screenDef = this.GetScreenDefinition();
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnThumbnailWidgetSpawned", ToVariant(widgetData), this);
    widgetData.libraryID = this.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath, spawnData);
    this.AddThumbnailWidgetData(widgetData);
  }

  protected cb func OnThumbnailWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let spawnData: ref<AsyncSpawnData>;
    let widgetData: SThumbnailWidgetPackage;
    if widget != null {
      widget.SetSizeRule(inkESizeRule.Stretch);
    };
    spawnData = userData as AsyncSpawnData;
    if spawnData != null {
      widgetData = FromVariant(spawnData.m_widgetData);
      widgetData.widget = widget;
      widgetData.libraryID = spawnData.m_libraryID;
      this.UpdateThumbnailWidgetData(widgetData, this.GetThumbnailWidgetDataIndex(widgetData));
      this.InitializeThumbnailWidget(widget, widgetData);
    };
  }

  protected final func CreateThumbnailWidget(parentWidget: wref<inkWidget>, widgetData: SThumbnailWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    let widget: ref<inkWidget> = this.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    if widget != null {
      widget.SetSizeRule(inkESizeRule.Stretch);
    };
    return widget;
  }

  protected final func UpdateThumbnailWidgetData(widgetData: SThumbnailWidgetPackage, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_thumbnailWidgetsData) {
      this.m_thumbnailWidgetsData[index] = widgetData;
    };
  }

  protected final func GetThumbnailWidgetDataIndex(widgetData: SThumbnailWidgetPackage) -> Int32 {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    widgetData.libraryID = this.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_thumbnailWidgetsData) {
      if Equals(this.m_thumbnailWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_thumbnailWidgetsData[i].widgetName, widgetData.widgetName) && this.m_thumbnailWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_thumbnailWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_thumbnailWidgetsData[i].libraryID, widgetData.libraryID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected final func GetThumbnailWidget(widgetData: SThumbnailWidgetPackage) -> wref<inkWidget> {
    let index: Int32 = this.GetThumbnailWidgetDataIndex(widgetData);
    if index >= 0 && index < ArraySize(this.m_thumbnailWidgetsData) {
      return this.m_thumbnailWidgetsData[index].widget;
    };
    return null;
  }

  protected final func HasThumbnailWidgetData(widgetData: SThumbnailWidgetPackage) -> Bool {
    return this.GetThumbnailWidgetDataIndex(widgetData) >= 0;
  }

  protected final func HasThumbnailWidget(widgetData: SThumbnailWidgetPackage) -> Bool {
    return this.GetThumbnailWidget(widgetData) != null;
  }

  protected final func AddThumbnailWidgetData(widgetData: SThumbnailWidgetPackage) -> Void {
    ArrayPush(this.m_thumbnailWidgetsData, widgetData);
  }

  protected final func AddThumbnailWidget(widget: ref<inkWidget>, widgetData: SThumbnailWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    widgetData.libraryID = this.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_thumbnailWidgetsData, widgetData);
    return widgetData.widget;
  }

  protected final func InitializeThumbnailWidget(widget: ref<inkWidget>, widgetData: SThumbnailWidgetPackage) -> Void {
    let controller: ref<DeviceThumbnailWidgetControllerBase> = widget.GetController() as DeviceThumbnailWidgetControllerBase;
    if controller != null {
      controller.Initialize(this, widgetData);
    };
    widget.SetVisible(true);
  }

  protected final func HideThumbnailWidgets() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_thumbnailWidgetsData) {
      if this.m_thumbnailWidgetsData[i].widget != null {
        this.m_thumbnailWidgetsData[i].widget.SetVisible(false);
      };
      i += 1;
    };
  }

  protected func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    this.UpdateActionWidgets(widgetsData);
  }

  protected func UpdateThumbnailWidgets(widgetsData: array<SThumbnailWidgetPackage>) -> Void {
    this.HideThumbnailWidgets();
  }

  protected func UpdateDeviceWidgets(widgetsData: array<SDeviceWidgetPackage>) -> Void {
    this.UpdateDeviceWidgets(widgetsData);
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.Refresh(state);
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onThumbnailWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as MasterDeviceBaseBlackboardDef.ThumbnailWidgetsData, this, n"OnThumbnailWidgetsUpdate");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as MasterDeviceBaseBlackboardDef.ThumbnailWidgetsData, this.m_onThumbnailWidgetsUpdateListener);
    };
  }

  protected cb func OnThumbnailWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SThumbnailWidgetPackage> = FromVariant(value);
    this.UpdateThumbnailWidgets(widgetsData);
  }

  protected cb func OnThumbnailActionCallback(e: ref<inkPointerEvent>) -> Bool {
    let action: ref<ScriptableDeviceAction>;
    let controller: ref<DeviceThumbnailWidgetControllerBase>;
    let executor: ref<PlayerPuppet>;
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as DeviceThumbnailWidgetControllerBase;
      if controller != null {
        action = controller.GetAction();
      };
      executor = GetPlayer(this.GetOwner().GetGame());
      this.ExecuteAction(action, executor);
    };
  }

  protected final func RequestDeviceWidgetsUpdate(devices: array<PersistentID>) -> Void {
    let deviceWidgetsEvent: ref<RequestDeviceWidgetsUpdateEvent> = new RequestDeviceWidgetsUpdateEvent();
    deviceWidgetsEvent.requesters = devices;
    deviceWidgetsEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(deviceWidgetsEvent);
  }

  protected final func RequestDeviceWidgetsUpdate(device: PersistentID) -> Void {
    let deviceWidgetEvent: ref<RequestDeviceWidgetUpdateEvent> = new RequestDeviceWidgetUpdateEvent();
    deviceWidgetEvent.requester = device;
    deviceWidgetEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(deviceWidgetEvent);
  }

  protected final func RequestThumbnailWidgetsUpdate() -> Void {
    let thumbnailWidgetsEvent: ref<RequestThumbnailWidgetsUpdateEvent> = new RequestThumbnailWidgetsUpdateEvent();
    thumbnailWidgetsEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(thumbnailWidgetsEvent);
  }

  protected final func IsOwner(deviceID: PersistentID) -> Bool {
    return Equals(deviceID, this.GetOwner().GetDevicePS().GetID());
  }
}
