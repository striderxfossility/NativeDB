
public class ExplosiveDeviceController extends BasicDistractionDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ExplosiveDeviceControllerPS extends BasicDistractionDeviceControllerPS {

  protected inline let m_explosiveSkillChecks: ref<EngDemoContainer>;

  @attrib(category, "Explosive properties")
  @attrib(tooltip, "The FIRST element in the vfxResourceOnFirstHit array will be used for normal first hit effects, the SECOND element will only be used if the device has a distraction collider and that is what is hit by the player.")
  protected edit const let m_explosionDefinition: array<ExplosiveDeviceResourceDefinition>;

  @attrib(category, "Explosive properties")
  protected edit let m_explosiveWithQhacks: Bool;

  @attrib(category, "Explosive properties")
  @default(ExplosiveDeviceControllerPS, 0f)
  protected let m_HealthDecay: Float;

  @attrib(category, "Explosive properties")
  @default(ExplosiveDeviceControllerPS, 0.1f)
  protected let m_timeToMeshSwap: Float;

  @attrib(category, "Explosive properties")
  protected edit let m_shouldDistractionHitVFXIgnoreHitPosition: Bool;

  @attrib(category, "Explosive properties")
  protected edit let m_canBeDisabledWithQhacks: Bool;

  protected let m_disarmed: Bool;

  private persistent let m_exploded: Bool;

  @attrib(category, "Tech design")
  @default(ExplosiveDeviceControllerPS, true)
  protected edit let m_provideExplodeAction: Bool;

  @attrib(category, "Tech design")
  @default(ExplosiveDeviceControllerPS, true)
  protected edit let m_doExplosiveEngineerLogic: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#42163";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_explosiveSkillChecks);
  }

  public final func PushPersistentData() -> Void {
    if this.IsInitialized() {
      return;
    };
  }

  public final func GetExplosionDefinition(index: Int32) -> ExplosiveDeviceResourceDefinition {
    return this.m_explosionDefinition[index];
  }

  public final func GetExplosionDefinitionArray() -> array<ExplosiveDeviceResourceDefinition> {
    return this.m_explosionDefinition;
  }

  public final const func IsExplosiveWithQhacks() -> Bool {
    return this.m_explosiveWithQhacks;
  }

  public final func GetHealthDecay() -> Float {
    return this.m_HealthDecay;
  }

  public final func GetTimeToMeshSwap() -> Float {
    return this.m_timeToMeshSwap;
  }

  public final func GetDistractionHitVFXIgnoreHitPosition() -> Bool {
    return this.m_shouldDistractionHitVFXIgnoreHitPosition;
  }

  public final const func IsDisabledWithQhacks() -> Bool {
    return this.m_canBeDisabledWithQhacks;
  }

  public final const quest func IsExploded() -> Bool {
    return this.m_exploded;
  }

  public final func DoExplosiveResolveGameplayLogic() -> Bool {
    if !this.m_doExplosiveEngineerLogic || !this.m_provideExplodeAction {
      return false;
    };
    return true;
  }

  public final func SetExplodedState(state: Bool) -> Void {
    this.m_exploded = state;
    this.SendPSChangedEvent();
  }

  protected final func ActionSpiderbotExplodeExplosiveDevice() -> ref<SpiderbotExplodeExplosiveDevice> {
    let action: ref<SpiderbotExplodeExplosiveDevice> = new SpiderbotExplodeExplosiveDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func OnSpiderbotExplodeExplosiveDevice(evt: ref<SpiderbotExplodeExplosiveDevice>) -> EntityNotificationType {
    this.SendSpiderbotToPerformAction(this.ActionSpiderbotExplodeExplosiveDevicePerformed(), evt.GetExecutor());
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionSpiderbotExplodeExplosiveDevicePerformed() -> ref<SpiderbotExplodeExplosiveDevicePerformed> {
    let action: ref<SpiderbotExplodeExplosiveDevicePerformed> = new SpiderbotExplodeExplosiveDevicePerformed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnSpiderbotExplodeExplosiveDevicePerformed(evt: ref<SpiderbotExplodeExplosiveDevicePerformed>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionSpiderbotDistractExplosiveDevice() -> ref<SpiderbotDistractExplosiveDevice> {
    let action: ref<SpiderbotDistractExplosiveDevice> = new SpiderbotDistractExplosiveDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func OnSpiderbotDistractExplosiveDevice(evt: ref<SpiderbotDistractExplosiveDevice>) -> EntityNotificationType {
    this.m_distractExecuted = true;
    this.SendSpiderbotToPerformAction(this.ActionSpiderbotDistractExplosiveDevicePerformed(), evt.GetExecutor());
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionSpiderbotDistractExplosiveDevicePerformed() -> ref<SpiderbotDistractExplosiveDevicePerformed> {
    let action: ref<SpiderbotDistractExplosiveDevicePerformed> = new SpiderbotDistractExplosiveDevicePerformed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnSpiderbotDistractExplosiveDevicePerformed(evt: ref<SpiderbotDistractExplosiveDevicePerformed>) -> EntityNotificationType {
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceDetonate() -> ref<QuestForceDetonate> {
    let action: ref<QuestForceDetonate> = new QuestForceDetonate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceDetonate(evt: ref<QuestForceDetonate>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionForceDetonate() -> ref<ForceDetonate> {
    let action: ref<ForceDetonate> = new ForceDetonate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnForceDetonate(evt: ref<ForceDetonate>) -> EntityNotificationType {
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuickHackExplodeExplosive() -> ref<QuickHackExplodeExplosive> {
    let action: ref<QuickHackExplodeExplosive> = new QuickHackExplodeExplosive();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func OnQuickHackExplodeExplosive(evt: ref<QuickHackExplodeExplosive>) -> EntityNotificationType {
    this.ForceDisableDevice();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuickHackDistractExplosive() -> ref<QuickHackDistractExplosive> {
    let action: ref<QuickHackDistractExplosive> = new QuickHackDistractExplosive();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected func ActionQuickHackToggleON() -> ref<QuickHackToggleON> {
    let action: ref<QuickHackToggleON> = this.ActionQuickHackToggleON();
    if this.IsON() {
      action.CreateInteraction(t"Interactions.Disarm");
    } else {
      action.CreateInteraction(t"Interactions.Arm");
    };
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(actions, context) {
      return false;
    };
    if this.m_provideExplodeAction {
      ArrayPush(actions, this.ActionForceDetonate());
      this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    };
    return true;
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestForceDetonate());
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    if this.IsExplosiveWithQhacks() {
      return true;
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    this.GetQuickHackActions(actions, context);
    if !this.IsExplosiveWithQhacks() {
      return;
    };
    if this.IsON() && this.IsDisabledWithQhacks() {
      currentAction = this.ActionQuickHackToggleON();
      currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
      ArrayPush(actions, currentAction);
    };
    if this.HasNPCWorkspotKillInteraction() && this.IsSomeoneUsingNPCWorkspot() {
      currentAction = this.ActionOverloadDevice();
      currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
      currentAction.SetInactiveWithReason(!this.m_wasQuickHacked && this.IsSomeoneUsingNPCWorkspot(), "LocKey#7011");
      ArrayPush(actions, currentAction);
    } else {
      currentAction = this.ActionQuickHackExplodeExplosive();
      currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
      ArrayPush(actions, currentAction);
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ExplosionDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ExplosionDeviceBackground";
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      if this.IsON() && this.m_doExplosiveEngineerLogic {
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
}

public class SpiderbotExplodeExplosiveDevice extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotExplodeExplosiveDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#389", n"LocKey#389");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SpiderbotExplodeExplosiveDevice";
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

public class SpiderbotExplodeExplosiveDevicePerformed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotExplodeExplosiveDevicePerformed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"SpiderbotExplodeExplosiveDevicePerformed", n"SpiderbotExplodeExplosiveDevicePerformed");
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

public class SpiderbotDistractExplosiveDevice extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotDistractExplosiveDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#390", n"LocKey#390");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SpiderbotDistractExplosiveDevice";
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

public class SpiderbotDistractExplosiveDevicePerformed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotDistractExplosiveDevicePerformed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"SpiderbotDistractExplosiveDevicePerformed", n"SpiderbotDistractExplosiveDevicePerformed");
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

public class QuestForceDetonate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceDetonate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceDetonate", true, n"QuestForceDetonate", n"QuestForceDetonate");
  }
}

public class ForceDetonate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceDetonate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ForceDetonate", true, n"LocKey#17832", n"LocKey#17832");
  }
}

public class QuickHackExplodeExplosive extends ActionBool {

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties() -> Void {
    this.actionName = n"QuickHackExplodeExplosive";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuickHackExplodeExplosive", true, n"LocKey#1607", n"LocKey#1607");
  }
}

public class QuickHackDistractExplosive extends ActionBool {

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties() -> Void {
    this.actionName = n"QuickHackDistractExplosive";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuickHackDistractExplosive", true, n"LocKey#375", n"LocKey#375");
  }
}
