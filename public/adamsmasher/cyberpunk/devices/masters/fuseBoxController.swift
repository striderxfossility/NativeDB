
public class OverloadDevice extends ActionBool {

  @default(OverloadDevice, 1.0f)
  protected let m_killDelay: Float;

  public final func SetProperties() -> Void {
    this.actionName = n"OverloadDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#237", n"LocKey#237");
  }

  public final func GetKillDelay() -> Float {
    return this.m_killDelay;
  }

  public final func SetKillDelay(delay: Float) -> Void {
    this.m_killDelay = delay;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Overload";
  }
}

public class SendSpiderbotToOverloadDevice extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SendSpiderbotToOverloadDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#599", n"LocKey#599");
  }
}

public class SendSpiderbotToTogglePower extends ActionBool {

  public final func SetProperties(status: EDeviceStatus) -> Void {
    let unpowered: Bool;
    this.actionName = n"TogglePower";
    if Equals(status, EDeviceStatus.UNPOWERED) {
      unpowered = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"TogglePower", unpowered, n"LocKey#258", n"LocKey#257");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "Unpower";
    };
    return "Power";
  }
}

public class FuseBoxController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class FuseBoxControllerPS extends MasterControllerPS {

  private inline let m_fuseBoxSkillChecks: ref<EngineeringContainer>;

  @attrib(tooltip, "Generator has spiderbot action to overload given device")
  private edit let m_isGenerator: Bool;

  private persistent let m_isOverloaded: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#2013";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.RefreshSlaves_Event();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_fuseBoxSkillChecks);
  }

  public final const func IsGenerator() -> Bool {
    return this.m_isGenerator;
  }

  public const func GetExpectedSlaveState() -> EDeviceStatus {
    if !this.IsON() {
      return EDeviceStatus.UNPOWERED;
    };
    return EDeviceStatus.INVALID;
  }

  protected const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(5, 5);
  }

  public func GetWidgetTypeName() -> CName {
    return n"FuseBoxWidget";
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    action.ResetCaption();
    action.SetAvailableOnUnpowered();
    action.CreateInteraction(context.processInitiatorObject, "Open");
    return action;
  }

  public func OnToggleON(evt: ref<ToggleON>) -> EntityNotificationType {
    this.OnToggleON(evt);
    this.RefreshSlaves_Event();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnSetDeviceOFF(evt: ref<SetDeviceOFF>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.OFF);
    this.RefreshSlaves_Event();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnSetDeviceON(evt: ref<SetDeviceON>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.ON);
    this.RefreshSlaves_Event();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func RefreshSlaves(devices: array<ref<DeviceComponentPS>>) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let device: ref<ScriptableDeviceComponentPS>;
    devices = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        device = devices[i] as ScriptableDeviceComponentPS;
        if IsDefined(device) {
          if this.IsON() {
            action = device.ActionSetDevicePowered();
          } else {
            action = device.ActionSetDeviceUnpowered();
          };
        };
        if IsDefined(action) {
          this.ExecutePSAction(action, device);
        };
      };
      i = i + 1;
    };
  }

  protected func OnRefreshSlavesEvent(evt: ref<RefreshSlavesEvent>) -> EntityNotificationType {
    this.RefreshSlaves(evt.devices);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func ActionToggleON() -> ref<ToggleON> {
    let action: ref<ToggleON> = new ToggleON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.CreateInteraction();
    return action;
  }

  protected func ActionSendSpiderbotToTogglePower() -> ref<SendSpiderbotToTogglePower> {
    let action: ref<SendSpiderbotToTogglePower> = new SendSpiderbotToTogglePower();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.CreateInteraction();
    return action;
  }

  protected final func OnSendSpiderbotToTogglePower(evt: ref<SendSpiderbotToTogglePower>) -> EntityNotificationType {
    this.SendSpiderbotToPerformAction(this.ActionToggleON(), evt.GetExecutor());
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionSendSpiderbotToOverloadDevice() -> ref<SendSpiderbotToOverloadDevice> {
    let action: ref<SendSpiderbotToOverloadDevice> = new SendSpiderbotToOverloadDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  protected final func OnSendSpiderbotToOverloadDevice(evt: ref<SendSpiderbotToOverloadDevice>) -> EntityNotificationType {
    this.SendSpiderbotToPerformAction(this.ActionOverloadDevice(), evt.GetExecutor());
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ActionOverloadDevice() -> ref<OverloadDevice> {
    let action: ref<OverloadDevice> = new OverloadDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    action.CreateInteraction();
    action.SetDurationValue(this.GetDistractionDuration(action));
    return action;
  }

  protected func OnOverloadDevice(evt: ref<OverloadDevice>) -> EntityNotificationType {
    if evt.IsStarted() {
      this.m_isOverloaded = true;
      evt.SetCanTriggerStim(true);
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      evt.SetCanTriggerStim(false);
      this.ExecutePSAction(this.ActionToggleActivation(), this);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func IsOverloaded() -> Bool {
    return this.m_isOverloaded;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if this.m_isGenerator {
      return false;
    };
    if !this.GetActions(outActions, context) {
      return false;
    };
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionToggleON());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func CanCreateAnySpiderbotActions() -> Bool {
    if !this.m_isGenerator || this.m_isOverloaded {
      return false;
    };
    return true;
  }

  protected func GetSpiderbotActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    if !this.m_isGenerator || this.m_isOverloaded {
      return;
    };
    ArrayPush(actions, this.ActionSendSpiderbotToOverloadDevice());
    if this.HasAnySlave() {
      ArrayPush(actions, this.ActionSendSpiderbotToTogglePower());
    };
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    if !this.m_isGenerator || this.m_isOverloaded {
      return false;
    };
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if !this.m_isGenerator || this.m_isOverloaded {
      return;
    };
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(actions, currentAction);
    currentAction = this.ActionOverloadDevice();
    currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    currentAction.SetInactiveWithReason(!this.m_isOverloaded, "LocKey#7013");
    ArrayPush(actions, currentAction);
    if this.HasAnySlave() {
      currentAction = this.ActionQuickHackToggleON();
      currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
      currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
      ArrayPush(actions, currentAction);
    };
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7004");
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GeneratorDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GeneratorDeviceBackground";
  }
}
