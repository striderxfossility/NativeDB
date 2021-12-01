
public class NPCStatesComponent extends AINetStateComponent {

  private let m_aimingLookatEvent: ref<LookAtAddEvent>;

  @default(NPCStatesComponent, highLevelState)
  private let m_highLevelAnimFeatureName: CName;

  @default(NPCStatesComponent, upperBodyState)
  private let m_upperBodyAnimFeatureName: CName;

  @default(NPCStatesComponent, stanceState)
  private let m_stanceAnimFeatureName: CName;

  public let m_statFlagDefensiveState: ref<gameStatModifierData>;

  @default(NPCStatesComponent, gamedataNPCStanceState.Invalid)
  private let m_prevNPCStanceState: gamedataNPCStanceState;

  @default(NPCStatesComponent, gamedataNPCHighLevelState.Invalid)
  private let m_previousHighLevelState: gamedataNPCHighLevelState;

  @default(NPCStatesComponent, EHitReactionMode.Invalid)
  private let m_prevHitReactionMode: EHitReactionMode;

  private let m_bulkyStaggerMinRecordID: TweakDBID;

  private let m_staggerMinRecordID: TweakDBID;

  private let m_unstoppableRecordID: TweakDBID;

  private let m_unstoppableTwitchMinRecordID: TweakDBID;

  private let m_unstoppableTwitchNoneRecordID: TweakDBID;

  private let m_forceImpactRecordID: TweakDBID;

  private let m_forceStaggerRecordID: TweakDBID;

  private let m_forceKnockdownRecordID: TweakDBID;

  private let m_fragileRecordID: TweakDBID;

  private let m_weakRecordID: TweakDBID;

  private let m_toughRecordID: TweakDBID;

  private let m_bulkyRecordID: TweakDBID;

  private let m_regularRecordID: TweakDBID;

  @default(NPCStatesComponent, false)
  private let m_inCombat: Bool;

  public final func OnGameAttach() -> Void {
    this.m_bulkyStaggerMinRecordID = t"HitReactionThresholdModifiers.BulkyStaggerMin";
    this.m_staggerMinRecordID = t"HitReactionThresholdModifiers.StaggerMin";
    this.m_unstoppableRecordID = t"HitReactionThresholdModifiers.Unstoppable";
    this.m_unstoppableTwitchMinRecordID = t"HitReactionThresholdModifiers.Unstoppable";
    this.m_unstoppableTwitchNoneRecordID = t"HitReactionThresholdModifiers.Unstoppable";
    this.m_forceImpactRecordID = t"HitReactionThresholdModifiers.ForceImpact";
    this.m_forceStaggerRecordID = t"HitReactionThresholdModifiers.ForceStagger";
    this.m_forceKnockdownRecordID = t"HitReactionThresholdModifiers.ForceKnockdown";
    this.m_fragileRecordID = t"HitReactionThresholdModifiers.Fragile";
    this.m_weakRecordID = t"HitReactionThresholdModifiers.Weak";
    this.m_toughRecordID = t"HitReactionThresholdModifiers.Tough";
    this.m_bulkyRecordID = t"HitReactionThresholdModifiers.Bulky";
    this.m_regularRecordID = t"HitReactionThresholdModifiers.Regular";
    if IsDefined(this.GetPuppetStateBlackboard()) {
      this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.Stance, EnumInt(this.GetCurrentStanceState()));
      this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.HighLevel, EnumInt(this.GetCurrentHighLevelState()));
    };
  }

  public final func GetCurrentHighLevelState() -> gamedataNPCHighLevelState {
    return IntEnum(this.GetReplicatedHighLevelState());
  }

  public final func SetCurrentHighLevelState(newState: gamedataNPCHighLevelState) -> Bool {
    return this.SetReplicatedHighLevelState(EnumInt(newState));
  }

  public final func GetPreviousHighLevelState() -> gamedataNPCHighLevelState {
    return this.m_previousHighLevelState;
  }

  public final func GetCurrentUpperBodyState() -> gamedataNPCUpperBodyState {
    return IntEnum(this.GetReplicatedUpperBodyState());
  }

  public final func SetCurrentUpperBodyState(newState: gamedataNPCUpperBodyState) -> Bool {
    return this.SetReplicatedUpperBodyState(EnumInt(newState));
  }

  public final func GetCurrentDefenseMode() -> gamedataDefenseMode {
    return IntEnum(this.GetReplicatedDefenseMode());
  }

  public final func SetCurrentDefenseMode(newState: gamedataDefenseMode) -> Bool {
    return this.SetReplicatedDefenseMode(EnumInt(newState));
  }

  public final func GetCurrentLocomotionMode() -> gamedataLocomotionMode {
    return IntEnum(this.GetReplicatedLocomotionMode());
  }

  public final func SetCurrentLocomotionMode(newState: gamedataLocomotionMode) -> Bool {
    return this.SetReplicatedLocomotionMode(EnumInt(newState));
  }

  public final func GetCurrentStanceState() -> gamedataNPCStanceState {
    return IntEnum(this.GetReplicatedStanceState());
  }

  public final func SetPreviousStanceState(prevState: gamedataNPCStanceState) -> Void {
    this.m_prevNPCStanceState = prevState;
  }

  public final func GetPreviousStanceState() -> gamedataNPCStanceState {
    return this.m_prevNPCStanceState;
  }

  public final func SetCurrentStanceState(newState: gamedataNPCStanceState) -> Bool {
    return this.SetReplicatedStanceState(EnumInt(newState));
  }

  public final func SetPreviousHitReactionMode(prevState: EHitReactionMode) -> Void {
    this.m_prevHitReactionMode = prevState;
  }

  public final func GetPreviousHitReactionMode() -> EHitReactionMode {
    return this.m_prevHitReactionMode;
  }

  public final func GetCurrentHitReactionModeState() -> EHitReactionMode {
    return IntEnum(this.GetReplicatedHitReactionModeState());
  }

  public final func SetCurrentHitReactionModeState(newState: EHitReactionMode) -> Bool {
    return this.SetReplicatedHitReactionModeState(EnumInt(newState));
  }

  public final func GetCurrentBehaviorState() -> gamedataNPCBehaviorState {
    return IntEnum(this.GetReplicatedBehaviorState());
  }

  public final func SetCurrentBehaviorState(newState: gamedataNPCBehaviorState) -> Bool {
    return this.SetReplicatedBehaviorState(EnumInt(newState));
  }

  public final func GetCurrentPhaseState() -> ENPCPhaseState {
    return IntEnum(this.GetReplicatedPhaseState());
  }

  public final func SetCurrentPhaseState(newState: ENPCPhaseState) -> Bool {
    return this.SetReplicatedPhaseState(EnumInt(newState));
  }

  public final static func GetAnimWrapperNameBasedOnHighLevelState(highLevelState: gamedataNPCHighLevelState) -> CName {
    switch highLevelState {
      case gamedataNPCHighLevelState.Alerted:
        return n"alertedLocomotion";
      case gamedataNPCHighLevelState.Combat:
        return n"combatLocomotion";
      case gamedataNPCHighLevelState.Stealth:
        return n"stealthLocomotion";
      case gamedataNPCHighLevelState.Fear:
        return n"";
    };
    return n"";
  }

  public final static func GetAnimWrapperNameBasedOnStanceState(stanceState: gamedataNPCStanceState) -> CName {
    switch stanceState {
      case gamedataNPCStanceState.Crouch:
        return n"inCrouch";
      case gamedataNPCStanceState.Cover:
        return n"inCover";
      case gamedataNPCStanceState.Swim:
        return n"inSwim";
      case gamedataNPCStanceState.Vehicle:
        return n"inVehicle";
      case gamedataNPCStanceState.VehicleWindow:
        return n"inVehicle";
      default:
        return n"";
    };
    return n"";
  }

  public final static func AlertPuppet(ownerPuppet: wref<ScriptedPuppet>) -> Bool {
    let currentHLS: gamedataNPCHighLevelState;
    let securitySystem: ref<SecuritySystemControllerPS>;
    if !IsDefined(ownerPuppet) || !ownerPuppet.IsActive() || !ownerPuppet.IsAggressive() {
      return false;
    };
    currentHLS = ownerPuppet.GetHighLevelStateFromBlackboard();
    if Equals(currentHLS, gamedataNPCHighLevelState.Relaxed) {
      NPCPuppet.ChangeHighLevelState(ownerPuppet, gamedataNPCHighLevelState.Alerted);
      if !ownerPuppet.IsBoss() {
        return true;
      };
    };
    if Equals(currentHLS, gamedataNPCHighLevelState.Alerted) && !GameInstance.GetStatusEffectSystem(ownerPuppet.GetGame()).HasStatusEffectWithTag(ownerPuppet.GetEntityID(), n"CommsNoiseJam") {
      securitySystem = ownerPuppet.GetSecuritySystem();
      if IsDefined(securitySystem) {
        ownerPuppet.TriggerSecuritySystemNotification(ownerPuppet.GetWorldPosition(), ownerPuppet, ESecurityNotificationType.ALARM);
        return true;
      };
      AISquadHelper.EnterAlerted(ownerPuppet);
      return true;
    };
    return false;
  }

  private final func GetPuppet() -> ref<ScriptedPuppet> {
    return this.GetOwner() as ScriptedPuppet;
  }

  private final func GetPuppetStateBlackboard() -> ref<IBlackboard> {
    if IsDefined(this.GetPuppet()) {
      return this.GetPuppet().GetPuppetStateBlackboard();
    };
    return null;
  }

  public final func OnNPCStateChangeSignalReceived(signal: ref<NPCStateChangeSignal>) -> Void {
    if signal.m_highLevelStateValid {
      this.ChangeHighLevelState(signal.m_highLevelState);
    };
    if signal.m_upperBodyStateValid {
      this.ChangeUpperBodyState(signal.m_upperBodyState);
    };
    if signal.m_stanceStateValid {
      this.ChangeStanceState(signal.m_stanceState);
    };
    if signal.m_hitReactionModeStateValid {
      this.ChangeHitReactionModeState(signal.m_hitReactionModeState);
    };
    if signal.m_behaviorStateValid {
      this.ChangeBehaviorState(signal.m_behaviorState);
    };
    if signal.m_defenseModeValid {
      this.ChangeDefenseMode(signal.m_defenseMode);
    };
    if signal.m_locomotionModeValid {
      this.ChangeLocomotionMode(signal.m_locomotionMode);
    };
    if signal.m_phaseStateValid {
      this.ChangePhaseState(signal.m_phaseState);
    };
    if signal.m_highLevelStateValid && Equals(signal.m_highLevelState, gamedataNPCHighLevelState.Combat) {
      AIActionHelper.CombatQueriesInit(this.GetPuppet());
    };
  }

  private final func ChangeHighLevelState(newState: gamedataNPCHighLevelState) -> Void {
    let currentHighLevelStateEvent: ref<gameHighLevelStateDataEvent>;
    this.m_previousHighLevelState = this.GetCurrentHighLevelState();
    if Equals(this.m_previousHighLevelState, newState) {
      return;
    };
    if this.SetCurrentHighLevelState(newState) {
      currentHighLevelStateEvent = new gameHighLevelStateDataEvent();
      currentHighLevelStateEvent.currentHighLevelState = this.GetCurrentHighLevelState();
      currentHighLevelStateEvent.currentNPCEntityID = this.GetOwner().GetEntityID();
      this.UpdateHighLevelState(this.GetCurrentHighLevelState(), this.m_previousHighLevelState);
      this.GetOwner().QueueEvent(currentHighLevelStateEvent);
      GetPlayer(this.GetOwner().GetGame()).QueueEvent(currentHighLevelStateEvent);
      AIComponent.InvokeBehaviorCallback(this.GetPuppet(), n"OnHighLevelChanged");
    };
  }

  private final func ChangeDefenseMode(newState: gamedataDefenseMode) -> Void {
    if NotEquals(this.GetCurrentDefenseMode(), newState) {
      if this.SetCurrentDefenseMode(newState) {
        this.UpdateDefenseMode();
      };
    };
  }

  private final func ChangeLocomotionMode(newState: gamedataLocomotionMode) -> Void {
    if NotEquals(this.GetCurrentLocomotionMode(), newState) {
      if this.SetCurrentLocomotionMode(newState) {
        this.UpdateLocomotionMode();
      };
    };
  }

  private final func ChangeUpperBodyState(newState: gamedataNPCUpperBodyState) -> Void {
    if NotEquals(this.GetCurrentUpperBodyState(), newState) {
      if this.SetCurrentUpperBodyState(newState) {
        this.UpdateUpperBodyState();
      };
    };
  }

  private final func ChangeStanceState(newState: gamedataNPCStanceState) -> Void {
    if NotEquals(this.GetCurrentStanceState(), newState) {
      if this.SetCurrentStanceState(newState) {
        this.UpdateStanceState();
      };
    };
  }

  private final func ChangeHitReactionModeState(newState: EHitReactionMode) -> Void {
    if NotEquals(this.GetCurrentHitReactionModeState(), newState) {
      this.SetPreviousHitReactionMode(this.GetCurrentHitReactionModeState());
      if this.SetCurrentHitReactionModeState(newState) {
        this.UpdateHitReactionsExceptionState();
      };
    };
  }

  private final func ChangeBehaviorState(newState: gamedataNPCBehaviorState) -> Void {
    if NotEquals(this.GetCurrentBehaviorState(), newState) {
      if this.SetCurrentBehaviorState(newState) {
        this.UpdateBehaviorState();
      };
    };
  }

  private final func ChangePhaseState(newState: ENPCPhaseState) -> Void {
    if NotEquals(this.GetCurrentPhaseState(), newState) {
      if this.SetCurrentPhaseState(newState) {
        this.UpdatePhaseState();
      };
    };
  }

  private final func UpdateHighLevelState(newState: gamedataNPCHighLevelState, previousState: gamedataNPCHighLevelState) -> Void {
    let stateAnimFeature: ref<AnimFeature_NPCState>;
    let aiRole: ref<AIRole> = this.GetPuppet().GetAIControllerComponent().GetAIRole();
    this.OnHighLevelStateExit(previousState, newState);
    if IsDefined(aiRole) {
      aiRole.OnHighLevelStateExit(this.GetOwner(), previousState, newState);
    };
    stateAnimFeature = new AnimFeature_NPCState();
    stateAnimFeature.state = EnumInt(newState);
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), this.m_highLevelAnimFeatureName, stateAnimFeature);
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.HighLevel, EnumInt(newState));
    this.OnHighLevelStateEnter(newState, previousState);
    if IsDefined(aiRole) {
      aiRole.OnHighLevelStateEnter(this.GetOwner(), newState, previousState);
    };
  }

  private final func HandleCombatStateAnimHint(newState: gamedataNPCHighLevelState, previousState: gamedataNPCHighLevelState) -> Void {
    let owner: ref<GameObject> = this.GetOwner();
    if Equals(newState, gamedataNPCHighLevelState.Combat) && !this.m_inCombat {
      GameInstance.GetAnimationSystem(owner.GetGame()).EnterCombatMode(owner.GetEntityID());
      this.m_inCombat = true;
    } else {
      if Equals(newState, gamedataNPCHighLevelState.Relaxed) && this.m_inCombat {
        this.m_inCombat = false;
        GameInstance.GetAnimationSystem(owner.GetGame()).ExitCombatMode(this.GetOwner().GetEntityID());
      };
    };
  }

  private final func OnHighLevelStateEnter(newState: gamedataNPCHighLevelState, previousState: gamedataNPCHighLevelState) -> Void {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(this.GetOwner(), NPCStatesComponent.GetAnimWrapperNameBasedOnHighLevelState(newState), 1.00);
    this.HandleCombatStateAnimHint(newState, previousState);
    switch newState {
      case gamedataNPCHighLevelState.Relaxed:
        this.OnRelaxed();
        break;
      case gamedataNPCHighLevelState.Alerted:
        this.OnAlerted();
        break;
      case gamedataNPCHighLevelState.Combat:
        this.OnCombat();
        break;
      case gamedataNPCHighLevelState.Stealth:
        break;
      case gamedataNPCHighLevelState.Dead:
        this.OnDead();
        break;
      case gamedataNPCHighLevelState.Fear:
        break;
      default:
    };
  }

  private final func OnHighLevelStateExit(leftState: gamedataNPCHighLevelState, nextState: gamedataNPCHighLevelState) -> Void {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(this.GetOwner(), NPCStatesComponent.GetAnimWrapperNameBasedOnHighLevelState(leftState), 0.00);
    switch leftState {
      case gamedataNPCHighLevelState.Relaxed:
        break;
      case gamedataNPCHighLevelState.Alerted:
        break;
      case gamedataNPCHighLevelState.Combat:
        if NotEquals(nextState, gamedataNPCHighLevelState.Dead) {
          BumpComponent.ToggleComponentOn(this.GetOwner() as ScriptedPuppet);
        };
        break;
      case gamedataNPCHighLevelState.Stealth:
        break;
      case gamedataNPCHighLevelState.Dead:
        break;
      case gamedataNPCHighLevelState.Fear:
        break;
      default:
    };
  }

  private final func OnRelaxed() -> Void {
    let targetTracker: wref<TargetTrackingExtension>;
    (this.GetOwner() as NPCPuppet).GetInfluenceComponent().SetReservationRadius(0.50);
    if ScriptedPuppet.IsPlayerCompanion(this.GetPuppet()) {
      SenseComponent.RequestMainPresetChange(this.GetPuppet(), "Follower");
    } else {
      SenseComponent.RequestMainPresetChange(this.GetPuppet(), this.GetPuppet().GetStringFromCharacterTweak("relaxedSensesPreset", "Relaxed"));
    };
    if TargetTrackingExtension.Get(this.GetPuppet(), targetTracker) {
      targetTracker.ResetRecentlyDroppedThreat();
    };
  }

  private final func OnAlerted() -> Void {
    (this.GetOwner() as NPCPuppet).GetInfluenceComponent().SetReservationRadius(1.00);
    if ScriptedPuppet.IsPlayerCompanion(this.GetPuppet()) {
      SenseComponent.RequestMainPresetChange(this.GetPuppet(), "Follower");
    } else {
      SenseComponent.RequestMainPresetChange(this.GetPuppet(), this.GetPuppet().GetStringFromCharacterTweak("alertedSensesPreset", "Alerted"));
    };
  }

  private final func OnCombat() -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let combatTarget: wref<GameObject>;
    let isCompanion: Bool;
    let targetTracker: wref<TargetTrackingExtension>;
    (this.GetOwner() as NPCPuppet).GetInfluenceComponent().SetReservationRadius(1.00);
    isCompanion = ScriptedPuppet.IsPlayerCompanion(this.GetPuppet());
    if isCompanion {
      SenseComponent.RequestMainPresetChange(this.GetPuppet(), "FollowerCombat");
    } else {
      SenseComponent.RequestMainPresetChange(this.GetPuppet(), this.GetPuppet().GetStringFromCharacterTweak("combatSensesPreset", "Combat"));
    };
    GameObject.StartCooldown(this.GetOwner(), n"chatter_flank_order", 7.00);
    if GameInstance.GetStatsSystem(this.GetOwner().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.IsHeavyRangedArchetype) > 0.00 {
      GameObject.PlayVoiceOver(this.GetOwner(), n"hmg_charge", n"Scripts:OnCombat");
    };
    GameObject.PlayVoiceOver(this.GetOwner(), n"start_combat", n"Scripts:OnCombat", isCompanion ? 1.50 : 0.00);
    combatTarget = FromVariant((this.GetOwner() as ScriptedPuppet).GetAIControllerComponent().GetBehaviorArgument(n"CombatTarget"));
    if IsDefined(combatTarget) {
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetEntity() as GameObject, n"CommsNoiseJam") {
        AIActionHelper.QueuePullSquadSync(this.GetOwner());
        if this.GetOwner().IsConnectedToSecuritySystem() {
          AIActionHelper.QueueSecuritySystemCombatNotification(this.GetOwner());
        };
      };
      broadcaster = this.GetOwner().GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(this.GetOwner(), gamedataStimType.Alarm, 10.00, true);
      };
    };
    if TargetTrackingExtension.Get(this.GetPuppet(), targetTracker) {
      targetTracker.ResetRecentlyDroppedThreat();
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetEntity() as GameObject, n"ResetSquadSync") {
        targetTracker.PushSquadSync(AISquadType.Combat);
        targetTracker.PullSquadSync(AISquadType.Combat);
      };
    };
    AICoverHelper.GetCoverBlackboard(this.GetPuppet()).SetBool(GetAllBlackboardDefs().AICover.firstCoverEvaluationDone, false);
    AICoverHelper.GetCoverBlackboard(this.GetPuppet()).SetFloat(GetAllBlackboardDefs().AICover.startCoverEvaluationTimeStamp, -1.00);
    (this.GetOwner() as ScriptedPuppet).GetBumpComponent().Toggle(false);
    (this.GetOwner() as NPCPuppet).ReevaluatEAIThreatCalculationType();
  }

  private final func OnDead() -> Void {
    this.ChangeUpperBodyState(gamedataNPCUpperBodyState.Normal);
    this.GetPuppet().GetSensesComponent().Toggle(false);
    this.GetPuppet().GetBumpComponent().Toggle(false);
    this.PlayDeadVO();
  }

  private final func PlayDeadVO() -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    if NotEquals(this.m_previousHighLevelState, gamedataNPCHighLevelState.Combat) {
      GameObject.PlayVoiceOver(this.GetOwner(), n"stlh_death", n"Scripts:PlayDeadVO");
    } else {
      GameObject.PlayVoiceOver(this.GetOwner(), n"start_dead", n"Scripts:PlayDeadVO");
      broadcaster = this.GetOwner().GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(this.GetOwner(), gamedataStimType.Attention);
      };
    };
  }

  protected cb func OnNotifySecuritySystemCombatEvent(evt: ref<NotifySecuritySystemCombatEvent>) -> Bool {
    if this.GetOwner().IsActive() {
      this.NotifySecuritySystemCombat();
    };
  }

  private final func NotifySecuritySystemCombat() -> Void {
    let lastKnownPosition: Vector4;
    let threat: wref<GameObject>;
    let threatLocation: TrackedLocation;
    let puppet: ref<ScriptedPuppet> = this.GetOwner() as ScriptedPuppet;
    if IsDefined(puppet) {
      AIActionHelper.GetActiveTopHostilePuppetThreat(puppet, threatLocation);
      threat = threatLocation.entity as GameObject;
      if IsDefined(threat) {
        lastKnownPosition = threatLocation.sharedLocation.position;
        puppet.TriggerSecuritySystemNotification(lastKnownPosition, threat, ESecurityNotificationType.COMBAT);
      };
    };
  }

  private final func UpdateUpperBodyState() -> Void {
    let stateAnimFeature: ref<AnimFeature_NPCState> = new AnimFeature_NPCState();
    stateAnimFeature.state = this.GetUpperBodyStateForAnimGraph();
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), this.m_upperBodyAnimFeatureName, stateAnimFeature);
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.UpperBody, EnumInt(this.GetCurrentUpperBodyState()));
    this.OnUpperBodyStateChanged();
    switch this.GetCurrentUpperBodyState() {
      case gamedataNPCUpperBodyState.Normal:
        this.OnNormal();
        break;
      case gamedataNPCUpperBodyState.Shoot:
        this.OnShoot();
        break;
      case gamedataNPCUpperBodyState.Reload:
        this.OnReload();
        break;
      case gamedataNPCUpperBodyState.Defend:
        this.OnDefend();
        break;
      case gamedataNPCUpperBodyState.Parry:
        this.OnParry();
        break;
      case gamedataNPCUpperBodyState.Attack:
        break;
      case gamedataNPCUpperBodyState.ChargedAttack:
        break;
      default:
    };
  }

  private final func GetUpperBodyStateForAnimGraph() -> Int32 {
    switch this.GetCurrentUpperBodyState() {
      case gamedataNPCUpperBodyState.Aim:
        return 1;
      case gamedataNPCUpperBodyState.Attack:
        return 2;
      case gamedataNPCUpperBodyState.ChargedAttack:
        return 3;
      case gamedataNPCUpperBodyState.Defend:
        return 4;
      case gamedataNPCUpperBodyState.Equip:
        return 5;
      case gamedataNPCUpperBodyState.Normal:
        return 6;
      case gamedataNPCUpperBodyState.Parry:
        return 7;
      case gamedataNPCUpperBodyState.Reload:
        return 8;
      case gamedataNPCUpperBodyState.Shoot:
        return 9;
      case gamedataNPCUpperBodyState.Taunt:
        return 10;
      default:
        return 0;
    };
  }

  private final func OnUpperBodyStateChanged() -> Void {
    this.UpdateDefensiveState(false);
    this.TurnOffParryState();
  }

  private final func OnNormal() -> Void;

  private final func OnShoot() -> Void;

  private final func OnReload() -> Void;

  private final func OnDefend() -> Void {
    this.UpdateDefensiveState(true);
  }

  private final func OnParry() -> Void {
    this.TurnOnParryState();
  }

  private final func OnAttack() -> Void;

  private final func OnChargeAttack() -> Void;

  private final func UpdateLocomotionMode() -> Void {
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.LocomotionMode, EnumInt(this.GetCurrentLocomotionMode()));
    this.OnLocomotionModeChanged();
    switch this.GetCurrentLocomotionMode() {
      case gamedataLocomotionMode.Static:
        this.OnStatic();
        break;
      case gamedataLocomotionMode.Moving:
        this.OnMoving();
        break;
      default:
    };
  }

  private final func OnLocomotionModeChanged() -> Void;

  private final func OnStatic() -> Void;

  private final func OnMoving() -> Void;

  private final func UpdateDefenseMode() -> Void {
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.DefenseMode, EnumInt(this.GetCurrentDefenseMode()));
    this.OnDefenseModeChanged();
    switch this.GetCurrentDefenseMode() {
      case gamedataDefenseMode.NoDefend:
        this.OnNoDefend();
        break;
      case gamedataDefenseMode.DefendAll:
        this.OnDefendAll();
        break;
      case gamedataDefenseMode.DefendMelee:
        this.OnDefendMelee();
        break;
      case gamedataDefenseMode.DefendRanged:
        this.OnDefendRanged();
        break;
      default:
    };
  }

  private final func OnDefenseModeChanged() -> Void;

  private final func OnNoDefend() -> Void;

  private final func OnDefendAll() -> Void;

  private final func OnDefendMelee() -> Void;

  private final func OnDefendRanged() -> Void;

  private final func UpdateBehaviorState() -> Void {
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.BehaviorState, EnumInt(this.GetCurrentBehaviorState()));
  }

  private final func UpdatePhaseState() -> Void {
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.PhaseState, EnumInt(this.GetCurrentPhaseState()));
  }

  private final func UpdateDefensiveState(enable: Bool) -> Void {
    let puppetID: StatsObjectID = Cast(this.GetPuppet().GetEntityID());
    if enable {
      if GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).GetStatValue(puppetID, gamedataStatType.IsBlocking) == 0.00 {
        this.m_statFlagDefensiveState = RPGManager.CreateStatModifier(gamedataStatType.IsBlocking, gameStatModifierType.Additive, 1.00);
        GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).AddModifier(puppetID, this.m_statFlagDefensiveState);
      };
    } else {
      if GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).GetStatValue(puppetID, gamedataStatType.IsBlocking) == 1.00 {
        GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).RemoveModifier(puppetID, this.m_statFlagDefensiveState);
      };
    };
  }

  private final func TurnOnParryState() -> Void {
    let statFlag: ref<gameStatModifierData>;
    let puppetID: StatsObjectID = Cast(this.GetPuppet().GetEntityID());
    if GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).GetStatValue(puppetID, gamedataStatType.IsDeflecting) == 0.00 {
      statFlag = RPGManager.CreateStatModifier(gamedataStatType.IsDeflecting, gameStatModifierType.Additive, 1.00);
      GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).AddModifier(puppetID, statFlag);
    };
  }

  private final func TurnOffParryState() -> Void {
    let statFlag: ref<gameStatModifierData>;
    let puppetID: StatsObjectID = Cast(this.GetPuppet().GetEntityID());
    if GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).GetStatValue(puppetID, gamedataStatType.IsDeflecting) == 1.00 {
      statFlag = RPGManager.CreateStatModifier(gamedataStatType.IsDeflecting, gameStatModifierType.Additive, -1.00);
      GameInstance.GetStatsSystem(this.GetPuppet().GetGame()).AddModifier(puppetID, statFlag);
    };
  }

  private final func UpdateHitReactionsExceptionState() -> Void {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetOwner().GetGame());
    let entityID: EntityID = this.GetOwner().GetEntityID();
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.HitReactionMode, EnumInt(this.GetCurrentHitReactionModeState()));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_bulkyStaggerMinRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_staggerMinRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_unstoppableRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_unstoppableTwitchMinRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_unstoppableTwitchNoneRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_forceImpactRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_forceStaggerRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_forceKnockdownRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_fragileRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_weakRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_toughRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_bulkyRecordID));
    statSystem.RemoveModifierGroup(Cast(entityID), TDBID.ToNumber(this.m_regularRecordID));
    switch this.GetCurrentHitReactionModeState() {
      case EHitReactionMode.BulkyStaggerMin:
        this.OnBulkyStaggerMin(statSystem, entityID, this.m_bulkyStaggerMinRecordID);
        break;
      case EHitReactionMode.StaggerMin:
        this.OnStaggerMin(statSystem, entityID, this.m_staggerMinRecordID);
        break;
      case EHitReactionMode.Unstoppable:
        this.OnUnstoppable(statSystem, entityID, this.m_unstoppableRecordID);
        break;
      case EHitReactionMode.UnstoppableTwitchMin:
        this.OnUnstoppableTwitchMin(statSystem, entityID, this.m_unstoppableTwitchMinRecordID);
        break;
      case EHitReactionMode.UnstoppableTwitchNone:
        this.OnUnstoppableTwitchNone(statSystem, entityID, this.m_unstoppableTwitchNoneRecordID);
        break;
      case EHitReactionMode.ForceImpact:
        this.OnForceImpact(statSystem, entityID, this.m_forceImpactRecordID);
        break;
      case EHitReactionMode.ForceStagger:
        this.OnForceStagger(statSystem, entityID, this.m_forceStaggerRecordID);
        break;
      case EHitReactionMode.ForceKnockdown:
        this.OnForceKnockdown(statSystem, entityID, this.m_forceKnockdownRecordID);
        break;
      case EHitReactionMode.Fragile:
        this.OnFragile(statSystem, entityID, this.m_fragileRecordID);
        break;
      case EHitReactionMode.Weak:
        this.OnWeak(statSystem, entityID, this.m_weakRecordID);
        break;
      case EHitReactionMode.Tough:
        this.OnTough(statSystem, entityID, this.m_toughRecordID);
        break;
      case EHitReactionMode.Bulky:
        this.OnBulky(statSystem, entityID, this.m_bulkyRecordID);
        break;
      case EHitReactionMode.Regular:
        this.OnRegular(statSystem, entityID, this.m_regularRecordID);
        break;
      default:
    };
    if Equals(this.GetPreviousHitReactionMode(), EHitReactionMode.Unstoppable) && NotEquals(this.GetCurrentHitReactionModeState(), EHitReactionMode.Unstoppable) {
      this.SendOnUnstoppableRemovedSignal(false);
    };
  }

  private final func SendOnUnstoppableRemovedSignal(b: Bool) -> Void {
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable> = (this.GetOwner() as NPCPuppet).GetAIControllerComponent().GetSignals();
    if !IsDefined(signalTable) {
      return;
    };
    signalId = signalTable.GetOrCreateSignal(n"OnUnstoppableStateSignal");
    signalTable.Set(signalId, b);
  }

  private final func OnRegular(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
    AnimationControllerComponent.SetInputFloat(this.GetOwner() as NPCPuppet, n"twitch_hit_scale", 0.80);
  }

  private final func OnForceImpact(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnForceStagger(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnForceKnockdown(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnFragile(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnWeak(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnTough(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnBulky(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnUnstoppable(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
    this.SendOnUnstoppableRemovedSignal(true);
  }

  private final func OnUnstoppableTwitchMin(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
    AnimationControllerComponent.SetInputFloat(this.GetOwner() as NPCPuppet, n"twitch_hit_scale", 0.10);
  }

  private final func OnUnstoppableTwitchNone(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
    AnimationControllerComponent.SetInputFloat(this.GetOwner() as NPCPuppet, n"twitch_hit_scale", 0.00);
  }

  private final func OnStaggerMin(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func OnBulkyStaggerMin(statSystem: ref<StatsSystem>, entityID: EntityID, recordID: TweakDBID) -> Void {
    let tdbId: Uint64 = TDBID.ToNumber(recordID);
    statSystem.DefineModifierGroupFromRecord(tdbId, recordID);
    statSystem.ApplyModifierGroup(Cast(entityID), tdbId);
  }

  private final func UpdateStanceState() -> Void {
    let stateAnimFeature: ref<AnimFeature_NPCState> = new AnimFeature_NPCState();
    stateAnimFeature.state = EnumInt(this.GetCurrentStanceState());
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), this.m_stanceAnimFeatureName, stateAnimFeature);
    this.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.Stance, EnumInt(this.GetCurrentStanceState()));
    this.OnStanceStateChanged();
    switch this.GetCurrentStanceState() {
      case gamedataNPCStanceState.Stand:
        this.OnStand();
        break;
      case gamedataNPCStanceState.Crouch:
        this.OnCrouch();
        break;
      case gamedataNPCStanceState.Cover:
        this.OnCover();
        break;
      case gamedataNPCStanceState.Swim:
        this.OnSwim();
        break;
      case gamedataNPCStanceState.Vehicle:
        this.OnVehicle();
        break;
      default:
    };
    this.SetPreviousStanceState(this.GetCurrentStanceState());
  }

  private final func OnStanceStateChanged() -> Void {
    let stanceStateChangeEvent: ref<StanceStateChangeEvent>;
    let previousAnimWrapper: CName = NPCStatesComponent.GetAnimWrapperNameBasedOnStanceState(this.GetPreviousStanceState());
    let currentAnimWrapper: CName = NPCStatesComponent.GetAnimWrapperNameBasedOnStanceState(this.GetCurrentStanceState());
    if IsNameValid(previousAnimWrapper) && NotEquals(previousAnimWrapper, currentAnimWrapper) {
      AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(this.GetOwner(), previousAnimWrapper, 0.00);
    };
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(this.GetOwner(), currentAnimWrapper, 1.00);
    stanceStateChangeEvent = new StanceStateChangeEvent();
    stanceStateChangeEvent.state = this.GetCurrentStanceState();
    this.GetOwner().QueueEvent(stanceStateChangeEvent);
    if Equals(this.GetCurrentStanceState(), gamedataNPCStanceState.VehicleWindow) {
      this.ToggleVehicleWindow(true);
    } else {
      if Equals(this.GetPreviousStanceState(), gamedataNPCStanceState.VehicleWindow) {
        this.ToggleVehicleWindow(false);
      };
    };
  }

  private final func ToggleVehicleWindow(toggle: Bool) -> Void {
    let mountInfo: MountingInfo = GameInstance.GetMountingFacility(this.GetOwner().GetGame()).GetMountingInfoSingleWithObjects(this.GetOwner());
    let vehicle: wref<VehicleObject> = GameInstance.FindEntityByID(this.GetOwner().GetGame(), mountInfo.parentId) as VehicleObject;
    VehicleComponent.ToggleVehicleWindow(this.GetOwner().GetGame(), vehicle, mountInfo.slotId, toggle, n"Fast");
  }

  private final func OnStand() -> Void;

  private final func OnCrouch() -> Void;

  private final func OnCover() -> Void;

  private final func OnSwim() -> Void;

  private final func OnVehicle() -> Void;
}
