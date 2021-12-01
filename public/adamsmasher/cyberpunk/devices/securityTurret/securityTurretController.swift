
public class RipOff extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"RipOff";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#383", n"LocKey#383");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "RipOff";
  }
}

public class QuestForceReload extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceReload";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceReload", true, n"QuestForceReload", n"QuestForceReload");
  }
}

public class QuestForceOverheat extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceOverheat";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceOverheat", true, n"QuestForceOverheat", n"QuestForceOverheat");
  }
}

public class QuestRemoveWeapon extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"RemoveWeapon";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestRemoveWeapon", true, n"QuestRemoveWeapon", n"QuestRemoveWeapon");
  }
}

public class SecurityTurretStatus extends BaseDeviceStatus {

  public func SetProperties(const deviceRef: ref<ScriptableDeviceComponentPS>) -> Void {
    this.SetProperties(deviceRef);
  }

  public const func GetCurrentDisplayString() -> String {
    return this.GetCurrentDisplayString();
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SecurityTurretStatus.IsAvailable(device) && SecurityTurretStatus.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return BaseDeviceStatus.IsAvailable(device);
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return BaseDeviceStatus.IsClearanceValid(clearance);
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return BaseDeviceStatus.IsContextValid(context);
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "wrong_action";
  }
}

public class SecurityTurretController extends SensorDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SecurityTurretControllerPS extends SensorDeviceControllerPS {

  private persistent let m_pendingSecuritySystemDisableRequest: Bool;

  private inline let m_turretSkillChecks: ref<EngDemoContainer>;

  protected edit let m_ignoreSkillcheckGeneration: Bool;

  @attrib(category, "Game effect refs")
  protected edit let m_laserGameEffectRef: EffectRef;

  @attrib(category, "Weapon custom override")
  private edit let m_weaponItemRecordString: String;

  @attrib(category, "Weapon custom override")
  private edit let m_vfxNameOnShoot: CName;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-TurretSecurity";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    if !this.m_ignoreSkillcheckGeneration {
      this.InitializeSkillChecks(this.m_turretSkillChecks);
    };
  }

  protected final func SetDeviceState(state: EDeviceStatus) -> Void {
    this.SetDeviceState(state);
    if EnumInt(state) <= EnumInt(EDeviceStatus.UNPOWERED) {
      this.SendDeviceNotOperationalEvent();
    };
  }

  public final const func GetIsUnderControl() -> Bool {
    return this.m_isControlledByThePlayer;
  }

  public final const func GetLaserGameEffectRef() -> EffectRef {
    return this.m_laserGameEffectRef;
  }

  public const func GetDeviceStatusAction() -> ref<BaseDeviceStatus> {
    return this.ActionSecurityTurretStatus();
  }

  public final const func GetVfxNameOnShoot() -> String {
    return ToString(this.m_vfxNameOnShoot);
  }

  public final const func GetWeaponItemRecordString() -> String {
    return this.m_weaponItemRecordString;
  }

  private final const func ActionSecurityTurretStatus() -> ref<SecurityTurretStatus> {
    let action: ref<SecurityTurretStatus> = new SecurityTurretStatus();
    action.clearanceLevel = DefaultActionsParametersHolder.GetStatusClearance();
    action.SetUp(this);
    action.SetProperties(this);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestFollowTarget());
    ArrayPush(actions, this.ActionQuestStopFollowingTarget());
    ArrayPush(actions, this.ActionQuestLookAtTarget());
    ArrayPush(actions, this.ActionQuestStopLookAtTarget());
    ArrayPush(actions, this.ActionQuestForceTakeControlOverCamera());
    ArrayPush(actions, this.ActionQuestForceStopTakeControlOverCamera());
    ArrayPush(actions, this.ActionQuestForceAttitude());
    ArrayPush(actions, this.ActionQuestResetDeviceToInitialState());
    ArrayPush(actions, this.ActionQuestForceReload());
    ArrayPush(actions, this.ActionQuestForceOverheat());
    ArrayPush(actions, this.ActionQuestRemoveWeapon());
    ArrayPush(actions, this.ActionQuestSetDetectionToTrue());
    ArrayPush(actions, this.ActionQuestSetDetectionToFalse());
    ArrayPush(actions, this.ActionQuestSpotTargetReference());
  }

  protected func ActionRipOff() -> ref<RipOff> {
    let action: ref<RipOff> = new RipOff();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnRipOff(evt: ref<RipOff>) -> EntityNotificationType {
    this.ExecutePSAction(this.ActionQuestForceDisabled());
    this.SetBlockSecurityWakeUp(true);
    evt.GetExecutor().QueueEvent(evt);
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(actions, context) {
      return false;
    };
    if ToggleON.IsDefaultConditionMet(this, context) && NotEquals(context.requestType, gamedeviceRequestType.Direct) && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
      ArrayPush(actions, this.ActionToggleON());
    };
    if ScriptableDeviceAction.IsDefaultConditionMet(this, context) && Equals(context.requestType, gamedeviceRequestType.Direct) {
      ArrayPush(actions, this.ActionRipOff());
    };
    if ToggleTakeOverControl.IsDefaultConditionMet(this, context) && this.m_canPlayerTakeOverControl && Equals(context.requestType, gamedeviceRequestType.External) || this.m_isControlledByThePlayer {
      ArrayPush(actions, this.ActionToggleTakeOverControl());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    if Equals(this.GetDurabilityState(), EDeviceDurabilityState.NOMINAL) {
      return true;
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if Equals(this.GetDurabilityState(), EDeviceDurabilityState.NOMINAL) {
      this.GetQuickHackActions(actions, context);
      currentAction = this.ActionSetDeviceAttitude();
      currentAction.SetObjectActionID(t"DeviceAction.TurretOverrideAttitudeClassHack");
      currentAction.SetInactiveWithReason(this.IsAttitudeFromContextHostile(), "LocKey#7010");
      ArrayPush(actions, currentAction);
      currentAction = this.ActionToggleTakeOverControl();
      currentAction.SetObjectActionID(t"DeviceAction.TakeControlClassHack");
      currentAction.SetInactiveWithReason(this.m_canPlayerTakeOverControl, "LocKey#7006");
      currentAction.SetInactiveWithReason(!PlayerPuppet.IsSwimming(GetPlayer(this.GetGameInstance())), "LocKey#7003");
      currentAction.SetInactiveWithReason(PlayerPuppet.GetSceneTier(GetPlayer(this.GetGameInstance())) <= EnumInt(gamePSMHighLevel.SceneTier1), "LocKey#7003");
      ArrayPush(actions, currentAction);
      currentAction = this.ActionSetDeviceTagKillMode();
      currentAction.SetObjectActionID(t"DeviceAction.SetDeviceTagKillMode");
      currentAction.SetInactiveWithReason(!this.IsInTagKillMode(), "LocKey#7004");
      ArrayPush(actions, currentAction);
      currentAction = this.ActionQuickHackToggleON();
      ArrayPush(actions, currentAction);
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func GetMinigameActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let action: ref<ScriptableDeviceAction> = this.ActionProgramSetDeviceOff();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    ArrayPush(actions, action);
    action = this.ActionProgramSetDeviceAttitude();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    ArrayPush(actions, action);
  }

  private final func OnPendingSecuritySystemDisable(evt: ref<PendingSecuritySystemDisable>) -> EntityNotificationType {
    this.m_pendingSecuritySystemDisableRequest = evt.isPending;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    this.OnSecuritySystemOutput(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected const func CanPerformReprimand() -> Bool {
    return true;
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    let displayName: String = "Override";
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
      this.Override(evt);
      RPGManager.GiveReward(evt.GetExecutor().GetGame(), t"RPGActionRewards.ExtractPartsSecurityTurret");
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionDemolition(context: GetActionsContext) -> ref<ActionDemolition> {
    let action: ref<ActionDemolition> = this.ActionDemolition(context);
    let displayName: String = "RipOff";
    action.ResetCaption();
    action.SetAvailableOnUnpowered();
    action.CreateInteraction(context.processInitiatorObject, displayName);
    return action;
  }

  public func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionDemolition(evt);
    if evt.IsCompleted() {
      this.RipOff(evt);
      return EntityNotificationType.SendPSChangedEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func Override(action: ref<ScriptableDeviceAction>) -> Void {
    let actionToSend: ref<ScriptableDeviceAction> = this.ActionSetDeviceAttitude();
    actionToSend.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
    actionToSend.SetExecutor(action.GetExecutor());
    this.GetPersistencySystem().QueuePSDeviceEvent(actionToSend);
  }

  private final func RipOff(action: ref<ScriptableDeviceAction>) -> Void {
    let actionToSend: ref<ScriptableDeviceAction> = this.ActionRipOff();
    actionToSend.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
    actionToSend.SetExecutor(action.GetExecutor());
    this.GetPersistencySystem().QueuePSDeviceEvent(actionToSend);
  }

  public func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.TurnAuthorizationModuleOFF();
    this.m_disassembleProperties.m_canBeDisassembled = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceReload() -> ref<QuestForceReload> {
    let action: ref<QuestForceReload> = new QuestForceReload();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceReload(evt: ref<QuestForceReload>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceOverheat() -> ref<QuestForceOverheat> {
    let action: ref<QuestForceOverheat> = new QuestForceOverheat();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceOverheat(evt: ref<QuestForceOverheat>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestRemoveWeapon() -> ref<QuestRemoveWeapon> {
    let action: ref<QuestRemoveWeapon> = new QuestRemoveWeapon();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestRemoveWeapon(evt: ref<QuestRemoveWeapon>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionProgramSetDeviceOff() -> ref<ProgramSetDeviceOff> {
    let action: ref<ProgramSetDeviceOff> = this.ActionProgramSetDeviceOff();
    let multiplier: Float = GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(GetPlayer(this.GetGameInstance()).GetEntityID()), gamedataStatType.TurretShutdownExtension);
    action.SetDurationValue(action.GetDurationFromTDBRecord(t"MinigameAction.NetworkTurretShutdown") * multiplier);
    return action;
  }

  public func ActionProgramSetDeviceAttitude() -> ref<ProgramSetDeviceAttitude> {
    let action: ref<ProgramSetDeviceAttitude> = this.ActionProgramSetDeviceAttitude();
    let multiplier: Float = GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(GetPlayer(this.GetGameInstance()).GetEntityID()), gamedataStatType.TurretFriendlyExtension);
    action.SetDurationValue(action.GetDurationFromTDBRecord(t"MinigameAction.NetworkTurretFriendly") * multiplier);
    return action;
  }

  public func SendDeviceNotOperationalEvent() -> Void {
    let areas: array<ref<SecurityAreaControllerPS>>;
    let i: Int32;
    if this.m_pendingSecuritySystemDisableRequest && !this.IsTurretOperationalUnderSecuritySystem() {
      areas = this.GetSecurityAreas();
      i = 0;
      while i < ArraySize(areas) {
        this.QueuePSEvent(areas[i], new SecurityTurretOffline());
        i += 1;
      };
      this.m_pendingSecuritySystemDisableRequest = false;
    };
  }

  public final const func IsTurretOperationalUnderSecuritySystem() -> Bool {
    let turret: ref<SecurityTurret> = this.GetOwnerEntityWeak() as SecurityTurret;
    let groupName: CName = turret.GetAttitudeAgent().GetAttitudeGroup();
    let isOperational: Bool = !this.IsControlledByPlayer() && !this.IsSecurityWakeUpBlocked() && NotEquals(groupName, n"player") && this.IsPowered();
    return isOperational;
  }

  protected func OnSetDeviceAttitude(evt: ref<SetDeviceAttitude>) -> EntityNotificationType {
    this.OnSetDeviceAttitude(evt);
    this.ExecutePSAction(this.ActionSetDeviceTagKillMode());
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.TurretDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.TurretDeviceBackground";
  }
}
