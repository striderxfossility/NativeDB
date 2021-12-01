
public class AsyncSpawnData extends IScriptable {

  public let m_callbackTarget: wref<IScriptable>;

  public let m_controller: wref<IScriptable>;

  public let m_functionName: CName;

  public let m_libraryID: CName;

  public let m_widgetData: Variant;

  public final func Initialize(callbackTarget: wref<IScriptable>, functionName: CName, widgetData: Variant, opt controller: wref<IScriptable>) -> Void {
    this.m_callbackTarget = callbackTarget;
    this.m_functionName = functionName;
    this.m_widgetData = widgetData;
    this.m_controller = controller;
  }
}

public class DoorWidgetCustomData extends WidgetCustomData {

  private let passcode: Int32;

  private let card: CName;

  private let isPasswordKnown: Bool;

  public final const func GetPasscode() -> Int32 {
    return this.passcode;
  }

  public final func SetPasscode(newCode: Int32) -> Void {
    this.passcode = newCode;
  }

  public final const func GetCardName() -> CName {
    return this.card;
  }

  public final func SetCardName(cardName: CName) -> Void {
    this.card = cardName;
  }

  public final func IsPasswordKnown() -> Bool {
    return this.isPasswordKnown;
  }

  public final func SetIsPasswordKnown(choice: Bool) -> Void {
    this.isPasswordKnown = choice;
  }
}

public class LiftWidgetCustomData extends WidgetCustomData {

  private let movementState: gamePlatformMovementState;

  public final func GetMovementState() -> gamePlatformMovementState {
    return this.movementState;
  }

  public final func SetMovementState(value: gamePlatformMovementState) -> Void {
    this.movementState = value;
  }
}

public struct SWidgetPackageBase {

  public let libraryPath: ResRef;

  public let libraryID: CName;

  public let widgetTweakDBID: TweakDBID;

  public let widget: wref<inkWidget>;

  public let widgetName: String;

  public let placement: EWidgetPlacementType;

  @default(SWidgetPackageBase, true)
  public let isValid: Bool;

  public final static func ResolveWidgetTweakDBData(widgetTweakDBID: TweakDBID, out id: CName, out path: ResRef) -> Bool {
    let record: ref<WidgetDefinition_Record>;
    if TDBID.IsValid(widgetTweakDBID) {
      record = TweakDBInterface.GetWidgetDefinitionRecord(widgetTweakDBID);
      if record != null {
        path = record.LibraryPath();
        id = StringToName(record.LibraryID());
        return true;
      };
    };
    return false;
  }

  public final static func GetLibraryPath(widgetDef: ref<WidgetDefinition_Record>) -> ResRef {
    return widgetDef.LibraryPath();
  }

  public final static func GetLibraryID(widgetDef: ref<WidgetDefinition_Record>, screenTypeDef: ref<DeviceScreenType_Record>, styleDef: ref<WidgetStyle_Record>) -> String {
    let contentRatio: wref<WidgetRatio_Record>;
    let expectedRatio: String;
    let i: Int32;
    let id: String;
    let ratios: array<wref<WidgetRatio_Record>>;
    let styles: array<wref<WidgetStyle_Record>>;
    if !IsDefined(widgetDef) {
      return id;
    };
    id = widgetDef.LibraryID();
    widgetDef.Styles(styles);
    widgetDef.Ratios(ratios);
    i = 0;
    while i < ArraySize(styles) {
      if Equals(styleDef.EnumName(), styles[i].EnumName()) {
        id += "_" + styles[i].EnumName();
      };
      i += 1;
    };
    if IsDefined(screenTypeDef) {
      if widgetDef.UseContentRatio() {
        contentRatio = screenTypeDef.ContentRatio();
      };
      if IsDefined(contentRatio) {
        expectedRatio = contentRatio.EnumName();
      } else {
        expectedRatio = screenTypeDef.Ratio().EnumName();
      };
      i = 0;
      while i < ArraySize(ratios) {
        if Equals(expectedRatio, ratios[i].EnumName()) {
          id += "_" + ratios[i].EnumName();
        };
        i += 1;
      };
    };
    return id;
  }

  public final static func GetLibraryIDPackage(widgetDef: ref<WidgetDefinition_Record>, screenTypeDef: ref<DeviceScreenType_Record>, styleDef: ref<WidgetStyle_Record>) -> array<String> {
    let contentRatio: wref<WidgetRatio_Record>;
    let expectedRatio: String;
    let fullID: String;
    let i: Int32;
    let idPackage: array<String>;
    let idpart1: String;
    let idpart2: String;
    let idpart3: String;
    let ratios: array<wref<WidgetRatio_Record>>;
    let styles: array<wref<WidgetStyle_Record>>;
    if !IsDefined(widgetDef) {
      return idPackage;
    };
    idpart1 = widgetDef.LibraryID();
    widgetDef.Styles(styles);
    widgetDef.Ratios(ratios);
    fullID = idpart1;
    i = 0;
    while i < ArraySize(styles) {
      if Equals(styleDef.EnumName(), styles[i].EnumName()) {
        idpart2 = styles[i].EnumName();
        fullID += "_" + idpart2;
      } else {
        i += 1;
      };
    };
    if IsDefined(screenTypeDef) {
      if widgetDef.UseContentRatio() {
        contentRatio = screenTypeDef.ContentRatio();
      };
      if IsDefined(contentRatio) {
        expectedRatio = contentRatio.EnumName();
      } else {
        expectedRatio = screenTypeDef.Ratio().EnumName();
      };
      i = 0;
      while i < ArraySize(ratios) {
        if Equals(expectedRatio, ratios[i].EnumName()) {
          idpart3 = ratios[i].EnumName();
          fullID += "_" + idpart3;
        } else {
          i += 1;
        };
      };
    };
    ArrayPush(idPackage, fullID);
    if IsStringValid(idpart2) {
      ArrayPush(idPackage, idpart1 + "_" + idpart2);
    };
    if IsStringValid(idpart3) {
      ArrayPush(idPackage, idpart1 + "_" + idpart3);
    };
    ArrayPush(idPackage, idpart1);
    return idPackage;
  }
}

public class DeviceInkGameControllerBase extends inkGameController {

  @attrib(category, "Animations")
  protected inline edit let m_animationManager: ref<WidgetAnimationManager>;

  protected let m_rootWidget: wref<inkCanvas>;

  protected let m_actionWidgetsData: array<SActionWidgetPackage>;

  protected let m_deviceWidgetsData: array<SDeviceWidgetPackage>;

  protected let m_breadcrumbStack: array<SBreadcrumbElementData>;

  protected let m_cashedState: EDeviceStatus;

  protected let m_isInitialized: Bool;

  protected let m_hasUICameraZoom: Bool;

  protected let m_activeBreadcrumb: SBreadcrumbElementData;

  private let m_onRefreshListener: ref<CallbackHandle>;

  private let m_onActionWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onDeviceWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onBreadcrumbBarUpdateListener: ref<CallbackHandle>;

  protected let m_bbCallbacksRegistered: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    this.RegisterBlackboardCallbacks(this.GetBlackboard());
    this.m_hasUICameraZoom = this.GetOwner().GetDevicePS().HasUICameraZoom();
    this.SetupWidgets();
    this.m_isInitialized = true;
    if this.GetOwner().IsReadyForUI() {
      this.Refresh(this.GetOwner().GetDeviceState());
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.UpdateUnstreamedUI();
    if this.m_bbCallbacksRegistered {
      this.UnRegisterBlackboardCallbacks(this.GetBlackboard());
    };
  }

  protected func SetupWidgets() -> Void;

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  public final const func GetDeviceState() -> EDeviceStatus {
    return this.m_cashedState;
  }

  protected final func GetBlackboard() -> ref<IBlackboard> {
    let device: ref<Device> = this.GetOwner();
    if IsDefined(device) {
      return device.GetBlackboard();
    };
    return null;
  }

  public final func GetScreenDefinition() -> ScreenDefinitionPackage {
    return this.GetOwner().GetScreenDefinition();
  }

  protected final func CreateActionWidget(parentWidget: wref<inkWidget>, widgetData: SActionWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    let widget: ref<inkWidget> = this.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    if widget != null {
      widget.SetSizeRule(inkESizeRule.Stretch);
      widget.SetHAlign(inkEHorizontalAlign.Fill);
    };
    return widget;
  }

  protected final func CreateActionWidgetAsync(parentWidget: wref<inkWidget>, widgetData: SActionWidgetPackage) -> Void {
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if this.HasActionWidgetData(widgetData) {
      return;
    };
    screenDef = this.GetScreenDefinition();
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnActionWidgetSpawned", ToVariant(widgetData), this);
    widgetData.libraryID = this.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath, spawnData);
    this.AddActionWidgetData(widgetData);
  }

  protected cb func OnActionWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let spawnData: ref<AsyncSpawnData>;
    let widgetData: SActionWidgetPackage;
    if widget != null {
      widget.SetSizeRule(inkESizeRule.Stretch);
      widget.SetHAlign(inkEHorizontalAlign.Fill);
    };
    spawnData = userData as AsyncSpawnData;
    if spawnData != null {
      widgetData = FromVariant(spawnData.m_widgetData);
      widgetData.widget = widget;
      widgetData.libraryID = spawnData.m_libraryID;
      this.UpdateActionWidgetData(widgetData, this.GetActionWidgetDataIndex(widgetData));
      this.InitializeActionWidget(widget, widgetData);
    };
  }

  protected final func GetActionWidget(widgetData: SActionWidgetPackage) -> wref<inkWidget> {
    let index: Int32 = this.GetActionWidgetDataIndex(widgetData);
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

  protected final func GetActionWidgetDataIndex(widgetData: SActionWidgetPackage) -> Int32 {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    widgetData.libraryID = this.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_actionWidgetsData) {
      if Equals(this.m_actionWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_actionWidgetsData[i].widgetName, widgetData.widgetName) && this.m_actionWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_actionWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_actionWidgetsData[i].libraryID, widgetData.libraryID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected final func HasActionWidgetData(widgetData: SActionWidgetPackage) -> Bool {
    return this.GetActionWidgetDataIndex(widgetData) >= 0;
  }

  protected final func HasActionWidget(widgetData: SActionWidgetPackage) -> Bool {
    return this.GetActionWidget(widgetData) != null;
  }

  protected final func AddActionWidgetData(widgetData: SActionWidgetPackage) -> Void {
    ArrayPush(this.m_actionWidgetsData, widgetData);
  }

  protected final func AddActionWidget(widget: ref<inkWidget>, widgetData: SActionWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    widgetData.libraryID = this.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_actionWidgetsData, widgetData);
    return widgetData.widget;
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

  protected final func InitializeActionWidget(widget: ref<inkWidget>, widgetData: SActionWidgetPackage) -> Void {
    let controller: ref<DeviceActionWidgetControllerBase> = widget.GetController() as DeviceActionWidgetControllerBase;
    if controller != null {
      controller.Initialize(this, widgetData);
    };
    widget.SetVisible(true);
  }

  protected final func CreateDeviceWidgetAsync(parentWidget: wref<inkWidget>, widgetData: SDeviceWidgetPackage) -> Void {
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if this.HasDeviceWidgetData(widgetData) {
      return;
    };
    screenDef = this.GetScreenDefinition();
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnDeviceWidgetSpawned", ToVariant(widgetData), this);
    widgetData.libraryID = this.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath, spawnData);
    this.AddDeviceWidgetData(widgetData);
  }

  protected cb func OnDeviceWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let widgetData: SDeviceWidgetPackage;
    let spawnData: ref<AsyncSpawnData> = userData as AsyncSpawnData;
    if spawnData != null {
      widgetData = FromVariant(spawnData.m_widgetData);
      widgetData.widget = widget;
      widgetData.libraryID = spawnData.m_libraryID;
      widget.SetAnchor(inkEAnchor.Fill);
      widget.SetSizeRule(inkESizeRule.Stretch);
      this.UpdateDeviceWidgetData(widgetData, this.GetDeviceWidgetDataIndex(widgetData));
      this.InitializeDeviceWidget(widget, widgetData);
    };
  }

  protected final func CreateDeviceWidget(parentWidget: wref<inkWidget>, widgetData: SDeviceWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    let widget: ref<inkWidget> = this.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    return widget;
  }

  protected final func UpdateDeviceWidgetData(widgetData: SDeviceWidgetPackage, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_deviceWidgetsData) {
      this.m_deviceWidgetsData[index] = widgetData;
    };
  }

  protected final func GetDeviceWidgetDataIndex(widgetData: SDeviceWidgetPackage) -> Int32 {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    widgetData.libraryID = this.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_deviceWidgetsData) {
      if Equals(this.m_deviceWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_deviceWidgetsData[i].widgetName, widgetData.widgetName) && this.m_deviceWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_deviceWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_deviceWidgetsData[i].libraryID, widgetData.libraryID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected final func GetDeviceWidget(widgetData: SDeviceWidgetPackage) -> wref<inkWidget> {
    let index: Int32 = this.GetDeviceWidgetDataIndex(widgetData);
    if index >= 0 && index < ArraySize(this.m_deviceWidgetsData) {
      return this.m_deviceWidgetsData[index].widget;
    };
    return null;
  }

  protected final func HasDeviceWidgetData(widgetData: SDeviceWidgetPackage) -> Bool {
    return this.GetDeviceWidgetDataIndex(widgetData) >= 0;
  }

  protected final func HasDeviceWidget(widgetData: SDeviceWidgetPackage) -> Bool {
    return this.GetDeviceWidget(widgetData) != null;
  }

  protected final func AddDeviceWidgetData(widgetData: SDeviceWidgetPackage) -> Void {
    ArrayPush(this.m_deviceWidgetsData, widgetData);
  }

  protected final func AddDeviceWidget(widget: ref<inkWidget>, widgetData: SDeviceWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = this.GetScreenDefinition();
    widgetData.libraryID = this.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_deviceWidgetsData, widgetData);
    return widgetData.widget;
  }

  protected final func InitializeDeviceWidget(widget: ref<inkWidget>, widgetData: SDeviceWidgetPackage) -> Void {
    let controller: ref<DeviceWidgetControllerBase> = widget.GetController() as DeviceWidgetControllerBase;
    if controller != null {
      controller.Initialize(this, widgetData);
    };
    widget.SetVisible(true);
  }

  protected final func HideDeviceWidgets() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_deviceWidgetsData) {
      if this.m_deviceWidgetsData[i].widget != null {
        this.m_deviceWidgetsData[i].widget.SetVisible(false);
      };
      i += 1;
    };
  }

  public final func GetCurrentFullLibraryID(widgetRecord: ref<WidgetDefinition_Record>, opt screenTypeRecord: ref<DeviceScreenType_Record>, opt styleRecord: ref<WidgetStyle_Record>) -> CName {
    return this.FindLibraryID(widgetRecord, screenTypeRecord, styleRecord);
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    this.HideActionWidgets();
  }

  public func UpdateDeviceWidgets(widgetsData: array<SDeviceWidgetPackage>) -> Void {
    this.HideDeviceWidgets();
  }

  public func UpdateBreadCrumbBar(data: SBreadCrumbUpdateData) -> Void;

  public func Refresh(state: EDeviceStatus) -> Void {
    this.m_cashedState = state;
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    if IsDefined(blackboard) {
      this.m_onRefreshListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef().UIupdate, this, n"OnRefresh");
      this.m_onActionWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().ActionWidgetsData, this, n"OnActionWidgetsUpdate");
      this.m_onDeviceWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().DeviceWidgetsData, this, n"OnDeviceWidgetsUpdate");
      this.m_onBreadcrumbBarUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().BreadCrumbElement, this, n"OnBreadcrumbBarUpdate");
      this.m_bbCallbacksRegistered = true;
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef().UIupdate, this.m_onRefreshListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().ActionWidgetsData, this.m_onActionWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().DeviceWidgetsData, this.m_onDeviceWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().BreadCrumbElement, this.m_onBreadcrumbBarUpdateListener);
      this.m_bbCallbacksRegistered = false;
    };
  }

  protected cb func OnRefresh(value: Bool) -> Bool {
    let evt: ref<UIRefreshedEvent>;
    if this.m_isInitialized {
      this.Refresh(this.GetOwner().GetDeviceState());
      evt = new UIRefreshedEvent();
      this.GetOwner().QueueEvent(evt);
    };
  }

  protected cb func OnBreadcrumbBarUpdate(value: Variant) -> Bool {
    let data: SBreadCrumbUpdateData = FromVariant(value);
    this.UpdateBreadCrumbBar(data);
  }

  protected cb func OnActionWidgetsUpdate(value: Variant) -> Bool {
    let widgets: array<SActionWidgetPackage> = FromVariant(value);
    this.UpdateActionWidgets(widgets);
  }

  protected cb func OnDeviceWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SDeviceWidgetPackage> = FromVariant(value);
    this.UpdateDeviceWidgets(widgetsData);
  }

  protected cb func OnGlitchingStateChanged(value: Variant) -> Bool {
    let glitchData: GlitchData = FromVariant(value);
    if Equals(glitchData.state, EGlitchState.NONE) {
      this.StopGlitchingScreen();
    } else {
      this.StartGlitchingScreen(glitchData);
    };
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void;

  private func StopGlitchingScreen() -> Void;

  protected final func ExecuteAction(action: ref<DeviceAction>, executor: wref<GameObject>) -> Void {
    let actionEvent: ref<UIActionEvent> = new UIActionEvent();
    actionEvent.action = action;
    actionEvent.executor = executor;
    let owner: ref<Device> = this.GetOwner();
    if IsDefined(owner) {
      owner.QueueEvent(actionEvent);
    };
  }

  protected cb func OnDeviceActionCallback(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") && !this.IsInteractivityBlocked() {
      this.ExecuteDeviceActions(e.GetCurrentTarget().GetController() as DeviceActionWidgetControllerBase);
    };
  }

  protected cb func OnExecuteButtonAction(widget: wref<inkWidget>) -> Bool {
    if !this.IsInteractivityBlocked() {
      this.ExecuteDeviceActions(widget.GetController() as DeviceActionWidgetControllerBase);
    };
  }

  protected func ExecuteDeviceActions(controller: ref<DeviceActionWidgetControllerBase>) -> Void {
    let actions: array<wref<DeviceAction>>;
    let executor: wref<GameObject>;
    let i: Int32;
    if controller != null {
      if controller.CanExecuteAction() {
        actions = controller.GetActions();
      };
    };
    i = 0;
    while i < ArraySize(actions) {
      executor = GetPlayer(this.GetOwner().GetGame());
      this.ExecuteAction(actions[i], executor);
      controller.FinalizeActionExecution(executor, actions[i]);
      i += 1;
    };
  }

  protected final func IsInteractivityBlocked() -> Bool {
    let isBlockedByAiming: Bool;
    let isBlockedByBB: Bool;
    let isBlockedByPS: Bool;
    let isBlockedByRestriction: Bool;
    let player: ref<PlayerPuppet>;
    let owner: ref<Device> = this.GetOwner();
    if IsDefined(owner) {
      player = GetPlayer(owner.GetGame());
      isBlockedByBB = this.GetBlackboard().GetBool(owner.GetBlackboardDef().UI_InteractivityBlocked);
      isBlockedByPS = !owner.GetDevicePS().IsInteractive();
    };
    if IsDefined(player) {
      isBlockedByAiming = player.GetPlayerStateMachineBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
      isBlockedByRestriction = StatusEffectSystem.ObjectHasStatusEffect(player, t"GameplayRestriction.BlockDeviceInteractions") || StatusEffectSystem.ObjectHasStatusEffect(player, t"GameplayRestriction.NoWorldInteractions") || StatusEffectSystem.ObjectHasStatusEffect(player, t"GameplayRestriction.PhoneCallRestriction");
    };
    return isBlockedByBB || isBlockedByRestriction || isBlockedByPS || isBlockedByAiming;
  }

  protected final func GoUp() -> Void {
    if ArraySize(this.m_breadcrumbStack) > 0 {
      ArrayPop(this.m_breadcrumbStack);
    };
  }

  protected final func ClearBreadcrumbStack() -> Void {
    ArrayClear(this.m_breadcrumbStack);
  }

  protected final func GoDown(element: SBreadcrumbElementData) -> Void {
    ArrayPush(this.m_breadcrumbStack, element);
  }

  protected func ResolveBreadcrumbLevel() -> Void;

  public final const func GetCurrentBreadcrumbElement() -> SBreadcrumbElementData {
    let element: SBreadcrumbElementData;
    if ArraySize(this.m_breadcrumbStack) > 0 {
      return ArrayLast(this.m_breadcrumbStack);
    };
    element.elementName = "";
    return element;
  }

  public final const func GetCurrentBreadcrumbElementName() -> String {
    let element: SBreadcrumbElementData;
    if ArraySize(this.m_breadcrumbStack) > 0 {
      element = ArrayLast(this.m_breadcrumbStack);
      return element.elementName;
    };
    return "";
  }

  public final const func GetActiveBreadcrumbElement() -> SBreadcrumbElementData {
    return this.m_activeBreadcrumb;
  }

  public final const func GetActiveBreadcrumbElementName() -> String {
    return this.m_activeBreadcrumb.elementName;
  }

  protected final func SetActiveBreadcrumbElement(element: SBreadcrumbElementData) -> Void {
    this.m_activeBreadcrumb = element;
  }

  public final func SetUICameraZoomState(hasUICameraZoom: Bool) -> Void {
    let evt: ref<SetUICameraZoomEvent>;
    if Equals(hasUICameraZoom, this.m_hasUICameraZoom) {
      return;
    };
    evt = new SetUICameraZoomEvent();
    evt.hasUICameraZoom = hasUICameraZoom;
    this.GetOwner().QueueEvent(evt);
    this.m_hasUICameraZoom = hasUICameraZoom;
  }

  protected final func RequestActionWidgetsUpdate() -> Void {
    let actionWidgetsEvent: ref<RequestActionWidgetsUpdateEvent> = new RequestActionWidgetsUpdateEvent();
    actionWidgetsEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(actionWidgetsEvent);
  }

  protected final func RequestDeviceWidgetsUpdate() -> Void {
    let deviceWidgetEvent: ref<RequestDeviceWidgetUpdateEvent> = new RequestDeviceWidgetUpdateEvent();
    deviceWidgetEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(deviceWidgetEvent);
  }

  protected final func RequestUIRefresh(opt context: CName) -> Void {
    let refreshEvent: ref<RequestUIRefreshEvent> = new RequestUIRefreshEvent();
    refreshEvent.context = context;
    this.GetOwner().QueueEvent(refreshEvent);
  }

  protected final func RequestBeadcrumbBarUpdate(data: SBreadCrumbUpdateData) -> Void {
    let breadcrumbEvent: ref<RequestBreadCrumbBarUpdateEvent> = new RequestBreadCrumbBarUpdateEvent();
    breadcrumbEvent.breadCrumbData = data;
    this.GetOwner().QueueEvent(breadcrumbEvent);
  }

  protected cb func OnButtonHoverOver(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DeviceButtonLogicControllerBase> = e.GetCurrentTarget().GetController() as DeviceButtonLogicControllerBase;
    if IsDefined(controller) {
      this.PlaySound(controller.GetWidgetAudioName(), n"OnHoverOver", controller.GetOnHoverOverKey());
    };
  }

  protected cb func OnButtonHoverOut(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DeviceButtonLogicControllerBase> = e.GetCurrentTarget().GetController() as DeviceButtonLogicControllerBase;
    if IsDefined(controller) {
      this.PlaySound(controller.GetWidgetAudioName(), n"OnHoverOut", controller.GetOnHoverOutKey());
    };
  }

  protected cb func OnButtonPress(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DeviceButtonLogicControllerBase>;
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as DeviceButtonLogicControllerBase;
      if IsDefined(controller) {
        this.PlaySound(controller.GetWidgetAudioName(), n"OnPress", controller.GetOnHoverOutKey());
      };
    };
  }

  protected cb func OnButtonRelease(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DeviceButtonLogicControllerBase>;
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as DeviceButtonLogicControllerBase;
      if IsDefined(controller) {
        this.PlaySound(controller.GetWidgetAudioName(), n"OnRelease", controller.GetOnHoverOutKey());
      };
    };
  }

  public final func TriggerAnimationByName(animName: CName, playbackOption: EInkAnimationPlaybackOption, opt targetWidget: ref<inkWidget>, opt playbackOptionsOverrideData: ref<PlaybackOptionsUpdateData>) -> Void {
    if IsDefined(this.m_animationManager) {
      this.m_animationManager.TriggerAnimationByName(this, animName, playbackOption, targetWidget, playbackOptionsOverrideData);
    };
  }

  protected final func UpdateUnstreamedUI() -> Void {
    let evt: ref<UIUnstreamedEvent>;
    if this.m_isInitialized {
      evt = new UIUnstreamedEvent();
      this.GetOwner().QueueEvent(evt);
    };
  }
}
