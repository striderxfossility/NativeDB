
public class Confess extends Pay {

  public final func SetProperties(displayName: CName) -> Void {
    this.actionName = n"Confess";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, displayName, displayName);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if Confess.IsAvailable(device) && Confess.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsDisabled() || device.IsUnpowered() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOnClearance()) {
      return true;
    };
    return false;
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.ConfessDeviceActionWidget";
  }
}

public class ConfessionBoothController extends BasicDistractionDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ConfessionBoothControllerPS extends BasicDistractionDeviceControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-ConfessionBooth";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(actions, context) {
      return false;
    };
    if Confess.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionConfess());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenSuicide", t"QuickHack.DeviceSuicideHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenBlind", t"QuickHack.BlindHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenHeartAttack", t"QuickHack.HeartAttackHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenGrenade", t"QuickHack.GrenadeHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    if !GlitchScreen.IsDefaultConditionMet(this, context) {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7003");
    };
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7004");
    };
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
  }

  protected func ActionConfess() -> ref<Confess> {
    let action: ref<Confess> = new Confess();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetObjectActionID(t"Payment.Confess");
    action.SetExecutor(GetPlayer(this.GetGameInstance()));
    action.SetUp(this);
    action.SetProperties(n"LocKey#3389");
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.SetDurationValue(1.50);
    return action;
  }

  public func OnConfess(evt: ref<Confess>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier>;
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled");
    };
    if evt.IsStarted() {
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      if evt.CanPayCost() {
        notifier = new ActionNotifier();
        notifier.SetAll();
        this.Notify(notifier, evt);
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().ConfessionalBlackboard;
  }
}
