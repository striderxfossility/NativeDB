
public class ExplosiveTriggerDeviceController extends ExplosiveDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ExplosiveTriggerDeviceControllerPS extends ExplosiveDeviceControllerPS {

  @attrib(category, "Trigger conditions")
  @default(ExplosiveTriggerDeviceControllerPS, false)
  private persistent let m_playerSafePass: Bool;

  private persistent let m_triggerExploded: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#42163";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.GameAttached();
  }

  public final const func CanPlayerSafePass() -> Bool {
    return this.m_playerSafePass;
  }

  public final const func IsDisarmed() -> Bool {
    return this.m_disarmed;
  }

  public final func IsTriggerExploded() -> Bool {
    return this.m_triggerExploded;
  }

  public final func SetTriggerExplodedState(state: Bool) -> Void {
    this.m_triggerExploded = state;
  }

  protected func ActionSetDeviceAttitude() -> ref<SetDeviceAttitude> {
    let action: ref<SetDeviceAttitude> = new SetDeviceAttitude();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public func ActionToggleON() -> ref<ToggleON> {
    let action: ref<ToggleON> = new ToggleON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    if this.IsON() {
      action.CreateInteraction("Disarm");
    } else {
      action.CreateInteraction("Arm");
    };
    action.CreateActionWidgetPackage();
    return action;
  }

  protected final func ActionSpiderbotDisarmExplosiveDevice() -> ref<SpiderbotDisarmExplosiveDevice> {
    let action: ref<SpiderbotDisarmExplosiveDevice> = new SpiderbotDisarmExplosiveDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    this.m_disarmed = true;
    return action;
  }

  protected final func ActionSpiderbotDisarmExplosiveDevicePerformed() -> ref<SpiderbotDisarmExplosiveDevicePerformed> {
    let action: ref<SpiderbotDisarmExplosiveDevicePerformed> = new SpiderbotDisarmExplosiveDevicePerformed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    let displayName: String = "Disarm";
    action.ResetCaption();
    action.CreateInteraction(context.processInitiatorObject, displayName);
    return action;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      if this.IsON() {
        this.Disarm(evt);
        RPGManager.GiveReward(evt.GetExecutor().GetGame(), t"RPGActionRewards.ExtractPartsSecurityTurret");
        return EntityNotificationType.SendThisEventToEntity;
      };
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func Disarm(action: ref<ScriptableDeviceAction>) -> Void {
    let actionToSend: ref<ScriptableDeviceAction> = this.ActionToggleON();
    actionToSend.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
    actionToSend.SetExecutor(action.GetExecutor());
    this.GetPersistencySystem().QueuePSDeviceEvent(actionToSend);
    this.SetBlockSecurityWakeUp(true);
    this.m_disarmed = true;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(actions, context) {
      return false;
    };
    if TogglePower.IsDefaultConditionMet(this, context) && Equals(context.requestType, gamedeviceRequestType.External) {
      ArrayPush(actions, this.ActionTogglePower());
    };
    if ToggleON.IsDefaultConditionMet(this, context) && NotEquals(context.requestType, gamedeviceRequestType.Direct) && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
      ArrayPush(actions, this.ActionToggleON());
    };
    ArrayPush(actions, this.ActionForceDetonate());
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestSetPlayerSafePass(true));
    ArrayPush(actions, this.ActionQuestSetPlayerSafePass(false));
  }

  protected final func ActionQuestSetPlayerSafePass(value: Bool) -> ref<QuestSetPlayerSafePass> {
    let action: ref<QuestSetPlayerSafePass> = new QuestSetPlayerSafePass();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(value);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func PushSkillCheckActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if this.IsON() && !this.m_playerSafePass {
      return this.PushSkillCheckActions(outActions, context);
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackToggleON();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    ArrayPush(actions, currentAction);
    currentAction = this.ActionSetDeviceAttitude();
    currentAction.SetObjectActionID(t"DeviceAction.OverrideAttitudeClassHack");
    currentAction.SetInactiveWithReason(!this.CanPlayerSafePass(), "LocKey#7010");
    ArrayPush(actions, currentAction);
    currentAction = this.ActionQuickHackExplodeExplosive();
    currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func CanCreateAnySpiderbotActions() -> Bool {
    if this.IsON() {
      return true;
    };
    return false;
  }

  protected func GetSpiderbotActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    ArrayPush(actions, this.ActionSpiderbotExplodeExplosiveDevice());
    if this.IsON() {
      ArrayPush(actions, this.ActionSpiderbotDisarmExplosiveDevice());
    };
  }

  protected final func OnSetDeviceAttitude(evt: ref<SetDeviceAttitude>) -> EntityNotificationType {
    this.m_playerSafePass = true;
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnQuestSetPlayerSafePass(evt: ref<QuestSetPlayerSafePass>) -> EntityNotificationType {
    this.m_playerSafePass = FromVariant(evt.prop.first);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSpiderbotDisarmExplosiveDevice(evt: ref<SpiderbotDisarmExplosiveDevice>) -> EntityNotificationType {
    this.SendSpiderbotToPerformAction(this.ActionSpiderbotDisarmExplosiveDevicePerformed(), evt.GetExecutor());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnSpiderbotDisarmExplosiveDevicePerformed(evt: ref<SpiderbotDisarmExplosiveDevicePerformed>) -> EntityNotificationType {
    if this.IsON() {
      this.ExecutePSAction(this.ActionToggleON());
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }
}

public class SpiderbotDisarmExplosiveDevice extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotDisarmExplosiveDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#391", n"LocKey#391");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SpiderbotDisarmExplosiveDevice";
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return true;
    };
    return false;
  }
}

public class SpiderbotDisarmExplosiveDevicePerformed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotDisarmExplosiveDevicePerformed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"SpiderbotDisarmExplosiveDevicePerformed", n"SpiderbotDisarmExplosiveDevicePerformed");
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return true;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return true;
  }
}

public class QuestSetPlayerSafePass extends ActionBool {

  public final func SetProperties(value: Bool) -> Void {
    if value {
      this.actionName = n"ForceSafeForPlayer";
    } else {
      this.actionName = n"DisableSafeForPlayer";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestSetPlayerSafePass", value, n"QuestSetPlayerSafePass", n"QuestSetPlayerSafePass");
  }
}
