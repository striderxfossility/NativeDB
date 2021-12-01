
public class CloseAd extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"CloseAd";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Close", true, n"LocKey#274", n"LocKey#274");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public final func CreateActionWidgetPackage(buttonName: String, opt actions: array<ref<DeviceAction>>) -> Void {
    this.m_actionWidgetPackage.wasInitalized = true;
    this.m_actionWidgetPackage.dependendActions = actions;
    this.m_actionWidgetPackage.libraryPath = this.GetInkWidgetLibraryPath();
    this.m_actionWidgetPackage.libraryID = this.GetInkWidgetLibraryID();
    this.m_actionWidgetPackage.widgetName = buttonName;
    this.m_actionWidgetPackage.displayName = buttonName;
    this.m_actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
    this.ResolveActionWidgetTweakDBData();
  }
}

public class ShowVendor extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ShowVendor";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ShowVendor", true, n"LocKey#268", n"LocKey#268");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public final func CreateActionWidgetPackage(buttonName: String, opt actions: array<ref<DeviceAction>>) -> Void {
    this.m_actionWidgetPackage.wasInitalized = true;
    this.m_actionWidgetPackage.dependendActions = actions;
    this.m_actionWidgetPackage.libraryPath = this.GetInkWidgetLibraryPath();
    this.m_actionWidgetPackage.libraryID = this.GetInkWidgetLibraryID();
    this.m_actionWidgetPackage.widgetName = buttonName;
    this.m_actionWidgetPackage.displayName = buttonName;
    this.m_actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
    this.ResolveActionWidgetTweakDBData();
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "ShowVendor";
  }
}

public class InteractiveAdController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class InteractiveAdControllerPS extends ScriptableDeviceComponentPS {

  @default(InteractiveAdControllerPS, false)
  protected let m_showAd: Bool;

  @default(InteractiveAdControllerPS, false)
  protected let m_showVendor: Bool;

  @default(InteractiveAdControllerPS, false)
  protected let m_locationAdded: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#197";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected final func ActionCloseAd(ButtonName: String) -> ref<CloseAd> {
    let action: ref<CloseAd> = new CloseAd();
    action.clearanceLevel = 1;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionShowVendor(ButtonName: String) -> ref<ShowVendor> {
    let action: ref<ShowVendor> = new ShowVendor();
    action.clearanceLevel = 1;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.m_locationAdded {
      ArrayPush(actions, this.ActionShowVendor("Show vendor"));
    };
    if this.m_showAd {
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
  }

  public final func OnCloseAd(evt: ref<CloseAd>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnShowVendor(evt: ref<ShowVendor>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func SetIsReady(value: Bool) -> Void {
    this.m_showAd = value;
  }

  public final func AddLocation(value: Bool) -> Void {
    this.m_locationAdded = value;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().InteractiveDeviceBlackboard;
  }
}
