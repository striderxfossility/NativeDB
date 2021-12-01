
public native class SenseComponent extends IPlacedComponent {

  public native let visibleObject: ref<VisibleObject>;

  private let m_highLevelCb: ref<CallbackHandle>;

  private let m_reactionCb: ref<CallbackHandle>;

  private let m_highLevelState: gamedataNPCHighLevelState;

  private let m_mainPreset: TweakDBID;

  private let m_secondaryPreset: TweakDBID;

  private let m_puppetBlackboard: wref<IBlackboard>;

  private let m_playerTakedownStateCallbackID: ref<CallbackHandle>;

  private let m_playerUpperBodyStateCallbackID: ref<CallbackHandle>;

  private let m_playerCarryingStateCallbackID: ref<CallbackHandle>;

  private let m_playerInPerception: wref<PlayerPuppet>;

  public final native func SetHearingEnabled(enabled: Bool) -> Void;

  public final native func IsHearingEnabled() -> Bool;

  public final native func IsAgentVisible(object: ref<GameObject>) -> Bool;

  public final native func GetVisibilityTraceEndToAgentDist(object: ref<GameObject>) -> Float;

  public final native func GetDetection(entityID: EntityID) -> Float;

  public final native func SetDetectionFactor(detection: Float, opt shapeName: CName) -> Bool;

  public final native func SetDetectionCoolDown(coolDown: Float) -> Void;

  public final native func SetDetectionDropFactor(detectionDrop: Float) -> Void;

  public final native func SetDetectionMinRange(range: Float) -> Bool;

  private final native func UsePreset(presetID: TweakDBID) -> Bool;

  public final native func GetCurrentPreset() -> TweakDBID;

  public final native func AddDetection(target: ref<SenseComponent>, detection: Float) -> Bool;

  public final native func GetSenseShapes() -> array<ref<ISenseShape>>;

  public final native func HasDetectionOverwrite(entityID: EntityID) -> Bool;

  public final native func SetDetectionOverwrite(entityID: EntityID) -> Void;

  public final native func RemoveDetectionOverwrite(entityID: EntityID) -> Bool;

  public final native func HasDetectionAttitudeOverwrite(attitudeGroup: CName) -> Bool;

  public final native func SetDetectionAttitudeOverwrite(attitudeGroup: CName) -> Void;

  public final native func RemoveDetectionAttitudeOverwrite(attitudeGroup: CName) -> Bool;

  public final native func GetDetectionMultiplier(entityID: EntityID) -> Float;

  public final native func SetDetectionMultiplier(entityID: EntityID, multiplier: Float) -> Void;

  public final native func CreateSenseMappin() -> Void;

  public final native func CreateHearingMappin() -> Void;

  public final native func RemoveSenseMappin() -> Void;

  public final native func RequestRemovingSenseMappin() -> Void;

  public final native func RemoveHearingMappin() -> Void;

  public final native func HasSenseMappin() -> Bool;

  public final native func HasHearingMappin() -> Bool;

  public final native func SetSensorObjectType(objectType: gamedataSenseObjectType) -> Bool;

  public final native func SetVisibleObjectType(objectType: gamedataSenseObjectType) -> Bool;

  public final native func GetTimeSinceLastEntityVisible(entityID: EntityID) -> Float;

  public final native func SetMainTrackedObject(target: wref<GameObject>) -> Bool;

  public final native func SetMainTrackedObjectTraceZOffset(traceType: AdditionalTraceType, zOffset: Float) -> Bool;

  public final native func GetDistToTraceEndFromPosToMainTrackedObject(traceType: AdditionalTraceType) -> Float;

  public final native func SetForcedSensesTracing(targetObjectType: gamedataSenseObjectType, attitudeToTarget: EAIAttitude) -> Bool;

  public final native func RemoveForcedSensesTracing(targetObjectType: gamedataSenseObjectType, attitudeToTarget: EAIAttitude) -> Bool;

  public final native func SetTickDistanceOverride(overrideDistance: Float) -> Bool;

  public final native func SetHasPierceableWapon(hasTechWeapon: Bool) -> Bool;

  public final func ToggleComponent(condition: Bool) -> Void {
    this.SetHearingEnabled(condition);
    this.Toggle(condition);
  }

  public final func ToggleSenses(condition: Bool) -> Void {
    this.Toggle(condition);
  }

  public final func GetOwner() -> ref<GameObject> {
    return this.GetEntity() as GameObject;
  }

  public final func GetOwnerDevice() -> ref<SensorDevice> {
    return this.GetEntity() as SensorDevice;
  }

  public final func GetOwnerPuppet() -> ref<ScriptedPuppet> {
    return this.GetEntity() as ScriptedPuppet;
  }

  public final static func RequestMainPresetChange(obj: wref<GameObject>, const presetName: String) -> Void {
    let presetID: TweakDBID = TDBID.Create("Senses." + presetName);
    SenseComponent.RequestPresetChange(obj, presetID, true);
  }

  public final static func RequestSecondaryPresetChange(obj: wref<GameObject>, const presetName: String) -> Void {
    let presetID: TweakDBID = TDBID.Create("Senses." + presetName);
    SenseComponent.RequestPresetChange(obj, presetID, false);
  }

  public final static func RequestSecondaryPresetChange(obj: wref<GameObject>, const presetID: TweakDBID) -> Void {
    SenseComponent.RequestPresetChange(obj, presetID, false);
  }

  public final static func ResetPreset(obj: wref<GameObject>) -> Void {
    let evt: ref<SensePresetChangeEvent>;
    if !IsDefined(obj) {
      return;
    };
    evt = new SensePresetChangeEvent();
    evt.reset = true;
    obj.QueueEvent(evt);
  }

  public final static func RequestPresetChange(obj: wref<GameObject>, const presetID: TweakDBID, const mainPreset: Bool) -> Void {
    let evt: ref<SensePresetChangeEvent>;
    if !IsDefined(obj) || !TDBID.IsValid(presetID) {
      return;
    };
    evt = new SensePresetChangeEvent();
    evt.presetID = presetID;
    evt.mainPreset = mainPreset;
    obj.QueueEvent(evt);
  }

  protected cb func OnSensePresetChangeEvent(evt: ref<SensePresetChangeEvent>) -> Bool {
    if evt.reset {
      this.UsePreset(this.m_mainPreset);
      this.m_secondaryPreset = TDBID.undefined();
    } else {
      if evt.mainPreset {
        if !TDBID.IsValid(this.m_secondaryPreset) {
          if this.UsePreset(evt.presetID) {
            this.m_mainPreset = evt.presetID;
          };
        } else {
          this.m_mainPreset = evt.presetID;
        };
      } else {
        if this.UsePreset(evt.presetID) {
          this.m_secondaryPreset = evt.presetID;
        };
      };
    };
  }

  protected cb func OnSenseInitialize(evt: ref<SenseInitializeEvent>) -> Bool {
    let puppet: wref<ScriptedPuppet>;
    let sensorDevice: wref<SensorDevice> = this.GetEntity() as SensorDevice;
    if IsDefined(sensorDevice) && (sensorDevice.GetDevicePS() as SensorDeviceControllerPS).IsPartOfPrevention() {
      if sensorDevice.GetPreventionSystem().AreTurretsActive() {
        this.CreateSenseMappin();
      };
    } else {
      this.CreateSenseMappin();
    };
    puppet = this.GetOwnerPuppet();
    if IsDefined(puppet) {
      this.m_mainPreset = TDBID.Create("Senses." + (this.GetEntity() as ScriptedPuppet).GetStringFromCharacterTweak("relaxedSensesPreset", "Relaxed"));
      this.m_puppetBlackboard = puppet.GetPuppetStateBlackboard();
      if IsDefined(this.m_puppetBlackboard) {
        this.m_highLevelCb = this.m_puppetBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PuppetState.HighLevel, this, n"OnHighLevelChanged");
        this.m_reactionCb = this.m_puppetBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PuppetState.ReactionBehavior, this, n"OnReactionChanged");
      };
    };
  }

  private final func OnDetach() -> Void {
    let puppet: wref<ScriptedPuppet>;
    this.RemoveSenseMappin();
    this.RemoveHearingMappin();
    puppet = this.GetOwnerPuppet();
    if IsDefined(puppet) {
      this.m_puppetBlackboard = puppet.GetPuppetStateBlackboard();
      if IsDefined(this.m_puppetBlackboard) {
        this.m_puppetBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().PuppetState.ReactionBehavior, this.m_reactionCb);
        this.m_puppetBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().PuppetState.HighLevel, this.m_highLevelCb);
      };
    };
  }

  protected cb func OnHighLevelChanged(value: Int32) -> Bool {
    this.m_highLevelState = IntEnum(value);
    switch this.m_highLevelState {
      case gamedataNPCHighLevelState.Dead:
        this.RemoveHearingMappin();
        break;
      case gamedataNPCHighLevelState.Alerted:
      case gamedataNPCHighLevelState.Combat:
        this.ReevaluateDetectionOverwrite(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject());
        break;
      default:
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    this.ToggleComponent(false);
    this.RemoveHearingMappin();
  }

  protected cb func OnDefeated(evt: ref<DefeatedEvent>) -> Bool {
    if !IsMultiplayer() {
      this.ToggleComponent(false);
      this.RemoveHearingMappin();
    };
  }

  protected cb func OnResurrect(evt: ref<ResurrectEvent>) -> Bool {
    if !IsMultiplayer() {
      this.ToggleComponent(true);
    };
  }

  protected cb func OnReactionChanged(value: Int32) -> Bool {
    let reactionData: ref<AIReactionData> = this.GetOwnerPuppet().GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(reactionData) {
      reactionData = this.GetOwnerPuppet().GetStimReactionComponent().GetDesiredReactionData();
    };
    if IsDefined(reactionData) {
      this.ReevaluateDetectionOverwrite(reactionData.stimTarget);
    };
  }

  protected cb func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> Bool {
    let i: Int32;
    let target: ref<GameObject>;
    let threat: TrackedLocation;
    let threats: array<TrackedLocation>;
    let owner: ref<GameObject> = this.GetOwner();
    if owner.IsDevice() {
      return false;
    };
    if IsDefined(evt.targetToAssess) {
      if owner.GetTargetTrackerComponent().ThreatFromEntity(evt.targetToAssess, threat) {
        this.ReevaluateDetectionOverwrite(evt.targetToAssess);
      };
    } else {
      threats = owner.GetTargetTrackerComponent().GetThreats(true);
      i = 0;
      while i < ArraySize(threats) {
        target = threats[i].entity as GameObject;
        if IsDefined(target) {
          this.ReevaluateDetectionOverwrite(target);
        };
        i += 1;
      };
    };
  }

  protected cb func OnSenseEnabledEvent(evt: ref<SenseEnabledEvent>) -> Bool {
    if evt.isEnabled {
      this.CreateSenseMappin();
    };
  }

  protected cb func OnSenseVisibilityEvent(evt: ref<SenseVisibilityEvent>) -> Bool {
    this.RefreshCombatDetectionMultiplier(evt.target as ScriptedPuppet);
    if evt.target.IsPlayer() {
      if evt.isVisible {
        this.PlayerEnteredPerception(evt.target as PlayerPuppet);
      } else {
        this.PlayerExitedPercpetion(evt.target as PlayerPuppet);
      };
    } else {
      this.ReevaluateDetectionOverwrite(evt.target, evt.isVisible);
    };
  }

  private final func PlayerEnteredPerception(player: wref<PlayerPuppet>) -> Void {
    SenseComponent.RequestDetectionOverwriteReevaluation(this.GetOwner(), player, 0.50);
    if !this.HasSenseMappin() {
      return;
    };
    if IsDefined(this.m_playerInPerception) {
      this.PlayerExitedPercpetion(this.m_playerInPerception);
    };
    this.m_playerInPerception = player;
    this.ReevaluateDetectionOverwrite(this.m_playerInPerception, true);
    if !IsDefined(this.m_playerTakedownStateCallbackID) {
      this.m_playerTakedownStateCallbackID = this.m_playerInPerception.GetPlayerStateMachineBlackboard().RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown, this, n"OnPlayerTakedownStateChange", false);
    };
    if !IsDefined(this.m_playerUpperBodyStateCallbackID) {
      this.m_playerUpperBodyStateCallbackID = this.m_playerInPerception.GetPlayerStateMachineBlackboard().RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this, n"OnPlayerUpperBodyStateChange", false);
    };
    if !IsDefined(this.m_playerCarryingStateCallbackID) {
      this.m_playerCarryingStateCallbackID = this.m_playerInPerception.GetPlayerStateMachineBlackboard().RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying, this, n"OnPlayerCarryingStateChange", false);
    };
  }

  private final func PlayerExitedPercpetion(player: wref<PlayerPuppet>) -> Void {
    if !IsDefined(this.m_playerInPerception) || player != this.m_playerInPerception {
      return;
    };
    if IsDefined(this.m_playerTakedownStateCallbackID) {
      this.m_playerInPerception.GetPlayerStateMachineBlackboard().UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown, this.m_playerTakedownStateCallbackID);
    };
    if IsDefined(this.m_playerUpperBodyStateCallbackID) {
      this.m_playerInPerception.GetPlayerStateMachineBlackboard().UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this.m_playerUpperBodyStateCallbackID);
    };
    if IsDefined(this.m_playerCarryingStateCallbackID) {
      this.m_playerInPerception.GetPlayerStateMachineBlackboard().UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying, this.m_playerCarryingStateCallbackID);
    };
    this.m_playerInPerception = null;
  }

  private final func OnPlayerTakedownStateChange(takedownState: Int32) -> Void {
    this.ReevaluateDetectionOverwrite(this.m_playerInPerception);
  }

  private final func OnPlayerUpperBodyStateChange(upperBodyState: Int32) -> Void {
    this.ReevaluateDetectionOverwrite(this.m_playerInPerception);
  }

  private final func OnPlayerCarryingStateChange(carrying: Bool) -> Void {
    this.ReevaluateDetectionOverwrite(this.m_playerInPerception);
  }

  protected cb func OnDetectedEvent(evt: ref<OnDetectedEvent>) -> Bool;

  protected cb func OnDetectionReachedZero(evt: ref<OnRemoveDetection>) -> Bool {
    this.ReevaluateDetectionOverwrite(evt.target);
  }

  protected cb func OnAttitudeChanged(evt: ref<AttitudeChangedEvent>) -> Bool {
    this.ReevaluateDetectionOverwrite(evt.otherAgent.GetEntity() as GameObject);
  }

  protected cb func OnAttitudeGroupChanged(evt: ref<AttitudeGroupChangedEvent>) -> Bool {
    this.ReevaluateDetectionOverwrite(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject());
  }

  protected cb func OnSuspiciousObjectEvent(evt: ref<SuspiciousObjectEvent>) -> Bool {
    this.ReevaluateDetectionOverwrite(evt.target);
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    this.ReevaluateDetectionOverwrite(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject());
  }

  protected cb func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> Bool {
    let owner: wref<GameObject> = this.GetEntity() as GameObject;
    if IsDefined(owner) {
      if IsDefined(evt.GetWhoBreached()) {
        this.ReevaluateDetectionOverwrite(evt.GetWhoBreached());
      };
    };
  }

  public final static func RequestDetectionOverwriteReevaluation(obj: wref<GameObject>, target: wref<Entity>, opt delay: Float) -> Void {
    let evt: ref<ReevaluateDetectionOverwriteEvent>;
    if !IsDefined(obj) || !IsDefined(target) {
      return;
    };
    evt = new ReevaluateDetectionOverwriteEvent();
    evt.target = target;
    if delay > 0.00 {
      GameInstance.GetDelaySystem(obj.GetGame()).DelayEvent(obj, evt, delay, false);
    } else {
      obj.QueueEvent(evt);
    };
  }

  protected cb func OnReevaluateDetectionOverwriteEvent(evt: ref<ReevaluateDetectionOverwriteEvent>) -> Bool {
    this.ReevaluateDetectionOverwrite(evt.target as GameObject);
  }

  private final func GetGame() -> GameInstance {
    return this.GetOwner().GetGame();
  }

  private final func IsTargetPlayer(target: wref<GameObject>) -> Bool {
    if IsDefined(target) && target.IsPlayer() {
      return true;
    };
    return false;
  }

  public final static func ShouldIgnoreIfPlayerCompanion(owner: wref<Entity>, target: wref<Entity>) -> Bool {
    let aiControllerComponent: ref<AIHumanComponent>;
    let commandCombatTarget: wref<GameObject>;
    let ownerPuppet: ref<ScriptedPuppet>;
    let playerPuppet: ref<ScriptedPuppet>;
    let trackers: array<ref<Entity>>;
    let targetPuppet: wref<ScriptedPuppet> = target as ScriptedPuppet;
    if targetPuppet == null {
      return false;
    };
    if !ScriptedPuppet.IsPlayerCompanion(targetPuppet) {
      return false;
    };
    ownerPuppet = owner as ScriptedPuppet;
    if IsDefined(ownerPuppet) {
      aiControllerComponent = ownerPuppet.GetAIControllerComponent();
      if IsDefined(aiControllerComponent) {
        commandCombatTarget = FromVariant(aiControllerComponent.GetBehaviorArgument(n"CommandCombatTarget"));
        if IsDefined(commandCombatTarget) && commandCombatTarget == target {
          return false;
        };
      };
    };
    playerPuppet = GameInstance.GetPlayerSystem(targetPuppet.GetGame()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;
    trackers = playerPuppet.GetTargetTrackerComponent().CollectTrackers(true, false);
    if ArraySize(trackers) > 0 {
      return false;
    };
    return true;
  }

  private final func GetSecuritySystem() -> ref<SecuritySystemControllerPS> {
    let owner: wref<GameObject> = this.GetEntity() as GameObject;
    if IsDefined(owner) {
      return owner.GetSecuritySystem();
    };
    return null;
  }

  private final func IsTargetInterestingForSecuritySystem(target: wref<GameObject>) -> Bool {
    let owner: ref<GameObject> = this.GetEntity() as GameObject;
    let sec: ref<SecuritySystemControllerPS> = owner.GetSecuritySystem();
    if IsDefined(owner) && IsDefined(target) && IsDefined(sec) && sec.ShouldReactToTarget(target.GetEntityID(), owner.GetEntityID()) {
      return true;
    };
    return false;
  }

  public final func RefreshCombatDetectionMultiplier(target: ref<ScriptedPuppet>) -> Void {
    let cssi: ref<CombatSquadScriptInterface>;
    let tl: TrackedLocation;
    let tte: ref<TargetTrackingExtension>;
    AISquadHelper.GetCombatSquadInterface(target, cssi);
    if !IsDefined(this.GetOwnerPuppet()) {
      return;
    };
    tte = this.GetOwnerPuppet().GetTargetTrackerComponent() as TargetTrackingExtension;
    if !IsDefined(cssi) || !IsDefined(tte) {
      return;
    };
    if tte.IsSquadTracked(cssi) {
      this.SetDetectionMultiplier(target.GetEntityID(), 100.00);
    } else {
      if tte.ThreatFromEntity(target, tl) && tl.sharedAccuracy > 0.00 {
        this.SetDetectionMultiplier(target.GetEntityID(), 10.00);
      } else {
        if target.IsPlayer() && (target as PlayerPuppet).IsInCombat() {
          this.SetDetectionMultiplier(target.GetEntityID(), 2.00);
        } else {
          this.SetDetectionMultiplier(target.GetEntityID(), 1.00);
        };
      };
    };
  }

  private final func IsTargetInteresting(target: wref<GameObject>) -> Bool {
    let count: Int32;
    let cssi: ref<CombatSquadScriptInterface>;
    let i: Int32;
    let member: ref<ScriptedPuppet>;
    let membersList: array<wref<Entity>>;
    let owner: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let reactionComponent: ref<ReactionManagerComponent> = owner.GetStimReactionComponent();
    if !IsDefined(owner) {
      return false;
    };
    if !IsDefined(target) {
      return false;
    };
    if !owner.IsAggressive() {
      return false;
    };
    if this.IsPlayerRecentlyDroppedThreat(target) {
      return true;
    };
    if IsDefined(reactionComponent) && reactionComponent.IsTargetInterestingForPerception(target) {
      return true;
    };
    if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Alerted) {
      AISquadHelper.GetCombatSquadInterface(target, cssi);
      AISquadHelper.GetSquadmates(owner, membersList);
      count = ArraySize(membersList);
      i = 0;
      while i < count {
        member = membersList[i] as ScriptedPuppet;
        if Equals(member.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Alerted) {
          reactionComponent = member.GetStimReactionComponent();
          if IsDefined(reactionComponent) && reactionComponent.IsTargetInterestingForPerception(target) {
            return true;
          };
        };
        i += 1;
      };
    };
    return false;
  }

  private final func IsPlayerRecentlyDroppedThreat(target: wref<GameObject>) -> Bool {
    let threatData: DroppedThreatData;
    let threatObject: wref<GameObject>;
    let tte: wref<TargetTrackingExtension>;
    if TargetTrackingExtension.Get(this.GetOwnerPuppet(), tte) && tte.GetDroppedThreat(this.GetOwner().GetGame(), threatData) {
      threatObject = threatData.threat as GameObject;
      if IsDefined(threatObject) && threatObject.IsPlayer() {
        return true;
      };
    };
    return false;
  }

  private final func IsOwnerHostileTowardsPlayer() -> Bool {
    return this.IsOwnerHostileTowardsTarget(GetPlayer(this.GetGame()));
  }

  private final func IsOwnerHostileTowardsTarget(target: wref<GameObject>) -> Bool {
    let owner: wref<GameObject> = this.GetEntity() as GameObject;
    if IsDefined(owner) && IsDefined(target) && Equals(GameObject.GetAttitudeTowards(owner, target), EAIAttitude.AIA_Hostile) {
      return true;
    };
    return false;
  }

  private final func IsOwnerFriendlyTowardsPlayer() -> Bool {
    return this.IsOwnerFriendlyTowardsTarget(GetPlayer(this.GetGame()));
  }

  private final func IsOwnerFriendlyTowardsTarget(target: wref<GameObject>) -> Bool {
    let owner: wref<GameObject> = this.GetEntity() as GameObject;
    if IsDefined(owner) && IsDefined(target) && Equals(GameObject.GetAttitudeTowards(owner, target), EAIAttitude.AIA_Friendly) {
      return true;
    };
    return false;
  }

  private final func InitDetectionOverwrite() -> Void {
    let owner: wref<GameObject> = this.GetEntity() as GameObject;
    if !IsDefined(owner) {
      return;
    };
    this.SetDetectionOverwrite(GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID());
    this.SetDetectionAttitudeOverwrite(n"player");
  }

  public final func ReevaluateDetectionOverwrite(target: wref<GameObject>, opt isVisible: Bool) -> Bool {
    if !this.IsEnabled() {
      this.SetDetectionOverwrite(target.GetEntityID());
      if target.IsPlayer() {
        this.SetDetectionAttitudeOverwrite(n"player");
      };
      return false;
    };
    if !IsDefined(target) {
      return false;
    };
    if this.ShouldStartDetecting(target) {
      this.RemoveDetectionOverwrite(target.GetEntityID());
      if target.IsPlayer() {
        this.RemoveDetectionAttitudeOverwrite(n"player");
      };
      this.SendDetectionRiseEvent(target, isVisible);
      if target.IsPlayer() && this.GetDetection(target.GetEntityID()) == 0.00 && this.IsAgentVisible(target) {
        AIActionHelper.PreloadCoreAnimations(this.GetOwnerPuppet());
        PlayerPuppet.SendOnBeingNoticed(target as PlayerPuppet, this.GetOwner());
      };
      return true;
    };
    this.SetDetectionOverwrite(target.GetEntityID());
    if target.IsPlayer() {
      this.SetDetectionAttitudeOverwrite(n"player");
    };
    return false;
  }

  private final func ShouldStartDetecting(target: ref<GameObject>) -> Bool {
    let isDevice: Bool = this.GetOwnerDevice() != null;
    if ScriptedPuppet.IsBlinded(this.GetOwner()) {
      return false;
    };
    if isDevice && !(this.GetOwnerDevice().GetDevicePS() as SensorDeviceControllerPS).GetBehaviourCanDetectIntruders() {
      return false;
    };
    if this.IsTargetPlayer(target) {
      return this.ShouldStartDetectingPlayer(target as PlayerPuppet);
    };
    if SenseComponent.ShouldIgnoreIfPlayerCompanion(this.GetEntity(), target) {
      return false;
    };
    return true;
  }

  private final func ShouldStartDetectingPlayer(player: ref<PlayerPuppet>) -> Bool {
    let ownerPuppet: wref<ScriptedPuppet>;
    let owner: wref<GameObject> = this.GetOwner();
    if this.IsOwnerFriendlyTowardsTarget(player) {
      return false;
    };
    if owner.IsPuppet() {
      ownerPuppet = this.GetOwnerPuppet();
      if !TargetTrackingExtension.IsThreatInThreatList(ownerPuppet, player, false, true) {
        if !ownerPuppet.IsAggressive() && NotEquals(ownerPuppet.GetStimReactionComponent().GetReactionPreset().Type(), gamedataReactionPresetType.Civilian_Guard) {
          return false;
        };
      };
      if ownerPuppet.IsPrevention() && !PreventionSystem.ShouldReactionBeAgressive(owner.GetGame()) {
        return false;
      };
    };
    if this.IsOwnerHostileTowardsTarget(player) {
      return true;
    };
    if owner.IsPuppet() && this.IsTargetInteresting(player) {
      return true;
    };
    if this.IsTargetInterestingForSecuritySystem(player) {
      return true;
    };
    return false;
  }

  private final func SendDetectionRiseEvent(target: wref<GameObject>, isVisible: Bool) -> Void {
    let evtRise: ref<DetectionRiseEvent> = new DetectionRiseEvent();
    evtRise.target = target;
    evtRise.isVisible = isVisible;
    this.QueueEntityEvent(evtRise);
  }

  protected cb func OnHACK_UseSensePresetEvent(evt: ref<HACK_UseSensePresetEvent>) -> Bool {
    this.UsePreset(evt.sensePreset);
  }
}
