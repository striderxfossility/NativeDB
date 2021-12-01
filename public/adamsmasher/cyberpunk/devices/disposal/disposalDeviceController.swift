
public class ActionDisposal extends ActionBool {

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let actionEffects: array<wref<ObjectActionEffect_Record>>;
    let i: Int32;
    let mountingInfo: MountingInfo;
    let rewards: array<wref<RewardBase_Record>>;
    GameInstance.GetPersistencySystem(gameInstance).QueuePSDeviceEvent(this);
    mountingInfo = GameInstance.GetMountingFacility(gameInstance).GetMountingInfoSingleWithObjects(this.GetExecutor());
    this.GetObjectActionRecord().Rewards(rewards);
    i = 0;
    while i < ArraySize(rewards) {
      RPGManager.GiveReward(gameInstance, rewards[i].GetID(), Cast(mountingInfo.childId));
      i += 1;
    };
    this.GetObjectActionRecord().CompletionEffects(actionEffects);
    this.ProcessStatusEffects(actionEffects, gameInstance);
  }
}

public class DisposeBody extends ActionDisposal {

  public final func SetProperties() -> Void {
    this.actionName = n"Dispose";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Dispose", true, n"Dispose", n"Dispose");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class TakedownAndDisposeBody extends ActionDisposal {

  public final func SetProperties() -> Void {
    this.actionName = n"TakedownAndDispose";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"TakedownAndDispose", true, n"TakedownAndDispose", n"TakedownAndDispose");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class NonlethalTakedownAndDisposeBody extends ActionDisposal {

  public final func SetProperties() -> Void {
    this.actionName = n"NonlethalTakedownAndDispose";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"NonlethalTakedownAndDispose", true, n"NonlethalTakedownAndDispose", n"NonlethalTakedownAndDispose");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class SpiderbotDistractionPerformed extends ActionBool {

  public final func SetProperties(action_name: CName) -> Void {
    this.actionName = action_name;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(action_name, true, action_name, action_name);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class OverchargeDevice extends ActionBool {

  public final func SetProperties(action_name: CName) -> Void {
    this.actionName = action_name;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(action_name, true, action_name, action_name);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "Overcharge";
  }
}

public class DisposalDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class DisposalDeviceControllerPS extends ScriptableDeviceComponentPS {

  private persistent let m_DisposalDeviceSetup: DisposalDeviceSetup;

  private persistent let m_distractionSetup: DistractionSetup;

  private persistent let m_explosionSetup: DistractionSetup;

  private persistent let m_isDistractionDisabled: Bool;

  private persistent let m_wasActivated: Bool;

  private persistent let m_wasLethalTakedownPerformed: Bool;

  private let m_isPlayerCurrentlyPerformingDisposal: Bool;

  public final func GetInteractionName() -> TweakDBID {
    return this.m_distractionSetup.m_alternativeInteractionName;
  }

  public final func WasActivated() -> Bool {
    return this.m_wasActivated;
  }

  public final func SetIsPlayerCurrentlyPerformingDisposal(value: Bool) -> Void {
    this.m_isPlayerCurrentlyPerformingDisposal = value;
  }

  public final const func WasLethalTakedownPerformed() -> Bool {
    return this.m_wasLethalTakedownPerformed;
  }

  public final func SetWasLethalTakedownPerformed(value: Bool) -> Void {
    this.m_wasLethalTakedownPerformed = value;
  }

  public final func GetQuickHackName() -> TweakDBID {
    return this.m_distractionSetup.m_alternativeQuickHackName;
  }

  public final func GetActionName() -> TweakDBID {
    return this.m_DisposalDeviceSetup.m_actionName;
  }

  public final func GetTakedownActionName() -> TweakDBID {
    return this.m_DisposalDeviceSetup.m_takedownActionName;
  }

  public final func GetNonlethalTakedownActionName() -> TweakDBID {
    return this.m_DisposalDeviceSetup.m_nonlethalTakedownActionName;
  }

  public final func GetStimuliRange() -> Float {
    return this.m_distractionSetup.m_StimuliRange;
  }

  public final const func HasQuickHackDistraction() -> Bool {
    return this.m_distractionSetup.m_hasQuickHack;
  }

  public final func HasSpiderbotInteraction() -> Bool {
    return this.m_distractionSetup.m_hasSpiderbotInteraction;
  }

  public final func HasSpiderbotExplosionInteraction() -> Bool {
    return this.m_explosionSetup.m_hasSpiderbotInteraction;
  }

  public final func HasComputerInteraction() -> Bool {
    return this.m_explosionSetup.m_hasComputerInteraction;
  }

  public final func GetExplosionDeinitionArray() -> array<ExplosiveDeviceResourceDefinition> {
    return this.m_explosionSetup.explosionDefinition;
  }

  public final func GetNumberOfUses() -> Int32 {
    return this.m_DisposalDeviceSetup.m_numberOfUses;
  }

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_distractionSetup.m_skillChecks);
  }

  private final func ActionDisposeBody(interactionTweak: TweakDBID) -> ref<DisposeBody> {
    let action: ref<DisposeBody> = new DisposeBody();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionTweak);
    return action;
  }

  private final func ActionTakedownAndDisposeBody(interactionTweak: TweakDBID) -> ref<TakedownAndDisposeBody> {
    let action: ref<TakedownAndDisposeBody> = new TakedownAndDisposeBody();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionTweak);
    return action;
  }

  private final func ActionNonlethalTakedownAndDisposeBody(interactionTweak: TweakDBID) -> ref<NonlethalTakedownAndDisposeBody> {
    let action: ref<NonlethalTakedownAndDisposeBody> = new NonlethalTakedownAndDisposeBody();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionTweak);
    return action;
  }

  protected final func ActionQuickHackDistraction(interactionTweak: TweakDBID) -> ref<QuickHackDistraction> {
    let action: ref<QuickHackDistraction> = new QuickHackDistraction();
    action = this.ActionQuickHackDistraction();
    action.CreateInteraction(interactionTweak);
    action.CreateInteraction();
    action.SetDurationValue(this.GetDistractionDuration(action));
    return action;
  }

  protected final func ActionSpiderbotDistraction(interactionName: String) -> ref<SpiderbotDistraction> {
    let action: ref<SpiderbotDistraction> = new SpiderbotDistraction();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionName);
    return action;
  }

  protected final func ActionSpiderbotExplosion(interactionName: String) -> ref<SpiderbotExplodeExplosiveDevice> {
    let action: ref<SpiderbotExplodeExplosiveDevice> = new SpiderbotExplodeExplosiveDevice();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionName);
    return action;
  }

  protected final func ActionSpiderbotExplodeExplosiveDevicePerformed() -> ref<SpiderbotExplodeExplosiveDevicePerformed> {
    let action: ref<SpiderbotExplodeExplosiveDevicePerformed> = new SpiderbotExplodeExplosiveDevicePerformed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionSpiderbotDistractionPerformed() -> ref<SpiderbotDistractionPerformed> {
    let action: ref<SpiderbotDistractionPerformed> = new SpiderbotDistractionPerformed();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties(n"Distract");
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionOverchargeDevice() -> ref<OverchargeDevice> {
    let action: ref<OverchargeDevice> = new OverchargeDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(n"Overcharge");
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  protected final func ActionToggleActivation(interactionTweak: TweakDBID) -> ref<ToggleActivation> {
    let action: ref<ToggleActivation> = new ToggleActivation();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionTweak);
    return action;
  }

  private final const func GetPlayerSMBlackboard() -> ref<IBlackboard> {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let psmBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return psmBlackboard;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let action: ref<ScriptableDeviceAction>;
    if this.IsDisabled() || this.m_isPlayerCurrentlyPerformingDisposal {
      return false;
    };
    if this.HasComputerInteraction() {
      ArrayPush(actions, this.ActionOverchargeDevice());
    };
    if this.m_distractionSetup.m_hasSimpleInteraction && !this.m_wasActivated {
      ArrayPush(actions, this.ActionToggleActivation(this.GetInteractionName()));
    };
    if !(this.IsPlayerCarrying() || this.IsEnemyGrappled()) {
      this.GetActions(actions, context);
    };
    if this.IsNPCDisposalBlockedStatusEffect() {
      return false;
    };
    if this.IsPlayerDroppingBody() {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(context.processInitiatorObject, n"NoWorldInteractions") {
      return false;
    };
    if this.IsEnemyGrappled() {
      action = this.ActionTakedownAndDisposeBody(this.GetTakedownActionName());
      action.SetInactiveWithReason(this.GetNumberOfUses() > 0, "LocKey#2115");
      ArrayPush(actions, action);
      action = this.ActionNonlethalTakedownAndDisposeBody(this.GetNonlethalTakedownActionName());
      action.SetInactiveWithReason(this.GetNumberOfUses() > 0, "LocKey#2115");
      ArrayPush(actions, action);
    };
    if this.IsPlayerCarrying() {
      action = this.ActionDisposeBody(this.GetActionName());
      action.SetInactiveWithReason(this.GetNumberOfUses() > 0, "LocKey#2115");
      ArrayPush(actions, action);
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected final func IsNPCDisposalBlockedStatusEffect() -> Bool {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(this.GetGameInstance()).GetMountingInfoSingleWithObjects(playerPuppet);
    let npc: wref<NPCPuppet> = GameInstance.FindEntityByID(this.GetGameInstance(), mountingInfo.childId) as NPCPuppet;
    return StatusEffectSystem.ObjectHasStatusEffect(npc, t"BaseStatusEffect.BlockBodyDisposal");
  }

  public final const func IsPlayerCarrying() -> Bool {
    return this.GetPlayerSMBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
  }

  public final const func IsEnemyGrappled() -> Bool {
    return this.GetPlayerSMBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Grapple);
  }

  protected final func IsPlayerDroppingBody() -> Bool {
    return this.GetPlayerSMBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying) == EnumInt(gamePSMBodyCarrying.Drop);
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    if this.IsDisabled() || this.IsDistracting() {
      return false;
    };
    if this.HasQuickHackDistraction() {
      return true;
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if this.IsDisabled() || this.IsDistracting() {
      return;
    };
    if this.HasQuickHackDistraction() {
      currentAction = this.ActionQuickHackDistraction();
      currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
      currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
      ArrayPush(actions, currentAction);
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func CanCreateAnySpiderbotActions() -> Bool {
    return false;
  }

  protected func GetSpiderbotActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void;

  public final func OnDistraction(evt: ref<Distraction>) -> EntityNotificationType {
    if this.m_distractionSetup.m_disableOnActivation {
      this.m_isDistractionDisabled = true;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnToggleActivation(evt: ref<ToggleActivation>) -> EntityNotificationType {
    this.UseNotifier(evt);
    this.m_wasActivated = true;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnSpiderbotDistraction(evt: ref<SpiderbotDistraction>) -> EntityNotificationType {
    this.SendSpiderbotToPerformAction(this.ActionSpiderbotDistractionPerformed(), evt.GetExecutor());
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnSpiderbotExplosion(evt: ref<SpiderbotExplodeExplosiveDevice>) -> EntityNotificationType {
    this.SendSpiderbotToPerformAction(this.ActionSpiderbotExplodeExplosiveDevicePerformed(), evt.GetExecutor());
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnSpiderbotExplosionPerformed(evt: ref<SpiderbotExplodeExplosiveDevicePerformed>) -> EntityNotificationType {
    if this.m_explosionSetup.m_disableOnActivation {
      this.DisableDevice();
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnSpiderbotDistractionPerformed(evt: ref<SpiderbotDistractionPerformed>) -> EntityNotificationType {
    if this.m_distractionSetup.m_disableOnActivation {
      this.m_isDistractionDisabled = true;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnDisposeBody(evt: ref<DisposeBody>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.m_DisposalDeviceSetup.m_numberOfUses = this.m_DisposalDeviceSetup.m_numberOfUses - 1;
    this.m_isPlayerCurrentlyPerformingDisposal = true;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnTakedownAndDisposeBody(evt: ref<TakedownAndDisposeBody>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.m_DisposalDeviceSetup.m_numberOfUses = this.m_DisposalDeviceSetup.m_numberOfUses - 1;
    this.m_isPlayerCurrentlyPerformingDisposal = true;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnNonlethalTakedownAndDisposeBody(evt: ref<NonlethalTakedownAndDisposeBody>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.m_DisposalDeviceSetup.m_numberOfUses = this.m_DisposalDeviceSetup.m_numberOfUses - 1;
    this.m_isPlayerCurrentlyPerformingDisposal = true;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnOverchargeDevice(evt: ref<OverchargeDevice>) -> EntityNotificationType {
    this.UseNotifier(evt);
    this.DisableDevice();
    return EntityNotificationType.SendThisEventToEntity;
  }
}
