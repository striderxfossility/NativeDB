
public class PlayerMuntedToMyVehicle extends Event {

  public let player: wref<PlayerPuppet>;

  public final static func Create(player: wref<PlayerPuppet>) -> ref<PlayerMuntedToMyVehicle> {
    let evt: ref<PlayerMuntedToMyVehicle> = new PlayerMuntedToMyVehicle();
    evt.player = player;
    return evt;
  }
}

public class ReactionManagerComponent extends ScriptableComponent {

  private let m_activeReaction: ref<AIReactionData>;

  private let m_desiredReaction: ref<AIReactionData>;

  private let m_stimuliCache: array<ref<StimuliEvent>>;

  private let m_reactionCache: array<ref<AIReactionData>>;

  private let m_reactionPreset: ref<ReactionPreset_Record>;

  private let m_puppetReactionBlackboard: ref<IBlackboard>;

  private let m_receivedStimType: gamedataStimType;

  private let m_inCrowd: Bool;

  private let m_inTrafficLane: Bool;

  @default(ReactionManagerComponent, -1)
  private let m_desiredFearPhase: Int32;

  private let m_previousFearPhase: Int32;

  @default(ReactionManagerComponent, 0.3f)
  private let m_NPCRadius: Float;

  @default(ReactionManagerComponent, 1.0f)
  private let m_bumpTriggerDistanceBufferMounted: Float;

  @default(ReactionManagerComponent, -0.11f)
  private let m_bumpTriggerDistanceBufferCrouched: Float;

  private let m_delayReactionEventID: DelayID;

  private let m_delay: Vector2;

  private let m_delayDetectionEventID: DelayID;

  private let m_delayStimEventID: DelayID;

  private let m_resetReactionDataID: DelayID;

  private let m_callingPoliceID: DelayID;

  private let m_lookatEvent: ref<LookAtAddEvent>;

  private let m_ignoreList: array<EntityID>;

  private let m_investigationList: array<StimEventData>;

  private let m_pendingReaction: ref<AIReactionData>;

  @default(ReactionManagerComponent, 1.f)
  private let m_ovefloodCooldown: Float;

  @default(ReactionManagerComponent, gamedataNPCStanceState.Stand)
  private let m_stanceState: gamedataNPCStanceState;

  @default(ReactionManagerComponent, gamedataNPCHighLevelState.Relaxed)
  private let m_highLevelState: gamedataNPCHighLevelState;

  private let m_aiRole: EAIRole;

  private let m_pendingBehaviorCb: ref<CallbackHandle>;

  private let m_inPendingBehavior: Bool;

  private let m_cacheSecuritySysOutput: ref<SecuritySystemOutput>;

  private let m_environmentalHazards: array<ref<StimuliEvent>>;

  private let m_environmentalHazardsDelayIDs: array<DelayID>;

  private let m_stolenVehicle: wref<VehicleObject>;

  @default(ReactionManagerComponent, false)
  private let m_isAlertedByDeadBody: Bool;

  private let m_isInCrosswalk: Bool;

  private let m_owner_id: EntityID;

  private let m_presetName: CName;

  private let m_updateByActive: Bool;

  private let m_personalities: array<gamedataStatType>;

  private let m_workspotReactionPlayed: Bool;

  private let m_inReactionSequence: Bool;

  private let m_playerProximity: Bool;

  private let m_fearToIdleDistance: Vector2;

  private let m_exitWorkspotAim: Vector2;

  private let m_bumpedRecently: Int32;

  private let m_bumpTimestamp: Float;

  private let m_bumpReactionInProgress: Bool;

  private let m_crowdAimingReactionDistance: Float;

  private let m_fearInPlaceAroundDistance: Float;

  private let m_lookatRepeat: Bool;

  private let m_disturbingComfortZoneInProgress: Bool;

  private let m_entereProximityRecently: Int32;

  private let m_comfortZoneTimestamp: Float;

  private let m_disturbComfortZoneEventId: DelayID;

  private let m_checkComfortZoneEventId: DelayID;

  private let m_spreadingFearEventId: DelayID;

  private let m_proximityLookatEventId: DelayID;

  private let m_resetFacialEventId: DelayID;

  private let m_exitWorkspotSequenceEventId: DelayID;

  @default(ReactionManagerComponent, true)
  private let m_fastWalk: Bool;

  @default(ReactionManagerComponent, true)
  private let m_createThreshold: Bool;

  private let m_initialized: Bool;

  private let m_initCrowd: Bool;

  private let m_facialCooldown: Float;

  private let m_disturbComfortZoneAggressiveEventId: DelayID;

  private let m_backOffInProgress: Bool;

  private let m_backOffTimestamp: Float;

  @default(ReactionManagerComponent, gameFearStage.Relaxed)
  private let m_crowdFearStage: gameFearStage;

  private let m_fearLocomotionWrapper: Bool;

  private let m_successfulFearDeescalation: Float;

  private let m_willingToCallPolice: Bool;

  private let m_deadBodyInvestigators: array<EntityID>;

  private let m_deadBodyStartingPosition: Vector4;

  private let m_currentStimThresholdValue: Int32;

  private let m_timeStampThreshold: Float;

  private let m_currentStealthStimThresholdValue: Int32;

  private let m_stealthTimeStampThreshold: Float;

  protected final func HandleStimEventByTask(stimEvent: ref<StimuliEvent>) -> Void {
    let data: ref<StimEventTaskData> = new StimEventTaskData();
    data.cachedEvt = stimEvent;
    stimEvent.id = 0u;
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).QueueTask(this, data, n"HandleStimEventTask", gameScriptTaskExecutionStage.PostPhysics);
  }

  protected final func HandleStimEventTask(data: ref<ScriptTaskData>) -> Void {
    let stimData: ref<StimEventTaskData> = data as StimEventTaskData;
    if IsDefined(stimData) {
      this.HandleStimEvent(stimData.cachedEvt);
    };
  }

  protected final func HandleStimEvent(stimEvent: ref<StimuliEvent>) -> Void {
    let localPlayer: ref<GameObject>;
    let ownerPuppet: ref<ScriptedPuppet>;
    let resetLookatReaction: ref<ResetLookatReactionEvent>;
    let stimParams: StimParams;
    let stimType: gamedataStimType;
    if !IsDefined(stimEvent) {
      return;
    };
    stimType = stimEvent.GetStimType();
    this.m_receivedStimType = stimType;
    if !this.IsEnabled() {
      this.m_receivedStimType = gamedataStimType.Invalid;
      return;
    };
    if !this.m_initialized {
      this.Initialiaze();
      this.m_initialized = true;
    };
    ownerPuppet = this.GetOwnerPuppet();
    if Equals(this.m_receivedStimType, gamedataStimType.AudioEnemyPing) {
      if ScriptedPuppet.IsActive(ownerPuppet) && ownerPuppet.IsAggressive() {
        localPlayer = GameInstance.GetPlayerSystem(ownerPuppet.GetGame()).GetLocalPlayerMainGameObject();
        if !this.SourceAttitude(localPlayer, EAIAttitude.AIA_Friendly) {
          GameInstance.GetAudioSystem(ownerPuppet.GetGame()).RegisterEnemyPingStim(ownerPuppet.GetHighLevelStateFromBlackboard(), ownerPuppet.IsPrevention());
        };
      };
      return;
    };
    if this.ShouldEventBeProcessed(stimEvent) {
      if IsDefined(ownerPuppet.GetCrowdMemberComponent()) && (this.m_inCrowd || ownerPuppet.IsCharacterCivilian()) {
        if this.ShouldStimBeProcessedByCrowd(stimEvent) {
          this.HandleCrowdReaction(stimEvent);
        };
        if stimEvent.IsTagInStimuli(n"Safe") {
          resetLookatReaction = new ResetLookatReactionEvent();
          GameInstance.GetDelaySystem(this.GetOwner().GetGame()).DelayEvent(this.GetOwner(), resetLookatReaction, 1.00);
        };
        this.m_receivedStimType = gamedataStimType.Invalid;
        return;
      };
      if this.ShouldStimBeProcessed(stimEvent) {
        stimParams = this.ProcessStimParams(stimEvent);
        this.ProcessReactionOutput(stimEvent, stimParams);
      };
    };
    if Equals(stimType, gamedataStimType.StopedAiming) && this.m_reactionPreset.IsAggressive() {
      ownerPuppet.GetSensesComponent().ReevaluateDetectionOverwrite(stimEvent.sourceObject);
    };
    if Equals(stimType, gamedataStimType.EnvironmentalHazard) {
      this.ProcessEnvironmentalHazard(stimEvent);
    };
    this.m_receivedStimType = gamedataStimType.Invalid;
  }

  protected final func ReactToSecuritySystemOutputByTask(evt: ref<SecuritySystemOutput>) -> Void {
    let data: ref<SecuritySystemOutputTaskData> = new SecuritySystemOutputTaskData();
    data.cachedEvt = evt;
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).QueueTask(this, data, n"ReactToSecuritySystemOutputTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func ReactToSecuritySystemOutputTask(data: ref<ScriptTaskData>) -> Void {
    let taskData: ref<SecuritySystemOutputTaskData> = data as SecuritySystemOutputTaskData;
    if IsDefined(taskData) {
      this.ReactToSecurityOutput(taskData.cachedEvt);
    };
  }

  public final func OnGameAttach() -> Void {
    this.m_owner_id = this.GetOwner().GetEntityID();
    this.m_puppetReactionBlackboard = IBlackboard.Create(GetAllBlackboardDefs().PuppetReaction);
  }

  protected cb func OnPlayerMuntedToMyVehicle(evt: ref<PlayerMuntedToMyVehicle>) -> Bool {
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if ownerPuppet.IsAggressive() && ScriptedPuppet.IsActive(ownerPuppet) && AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, evt.player) {
      this.GetOwner().QueueEvent(AIEvents.ExitVehicleEvent());
      TargetTrackingExtension.InjectThreat(ownerPuppet, evt.player);
    };
  }

  protected cb func OnSenseVisibilityEvent(evt: ref<SenseVisibilityEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let ignoreListEvent: ref<IgnoreListEvent>;
    let investigateData: stimInvestigateData;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let owner: ref<GameObject> = this.GetOwner();
    if IsDefined(evt.target) {
      broadcaster = evt.target.GetStimBroadcasterComponent();
    };
    if evt.target.IsPlayer() {
      if ownerPuppet.IsPrevention() || NPCManager.HasTag(ownerPuppet.GetRecordID(), n"TriggerPrevention") {
        if evt.isVisible {
          PreventionSystem.RegisterAsViewerToPreventionSystem(owner.GetGame(), ownerPuppet);
        } else {
          PreventionSystem.UnRegisterAsViewerToPreventionSystem(owner.GetGame(), ownerPuppet);
        };
      };
      if evt.isVisible {
        if this.CanTriggerReprimandOrder() {
          if !IsDefined(this.m_activeReaction) {
            broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.AskToFollowOrder, owner);
          };
          if NotEquals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) {
            (owner as NPCPuppet).GetComfortZoneComponent().Toggle(true);
          };
        };
      } else {
        (owner as NPCPuppet).GetComfortZoneComponent().Toggle(false);
      };
    } else {
      if !this.HasCombatTarget() && IsDefined(broadcaster) {
        if Equals(evt.description, n"Dead_Body") {
          investigateData.attackInstigator = EntityGameInterface.GetEntity(GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject().GetEntity());
          broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.DeadBody, owner, investigateData);
        } else {
          if Equals(evt.description, n"Unconscious") {
            broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.DeadBody, owner);
          } else {
            if Equals(evt.description, n"HeartAttack") {
              broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.DeadBody, owner);
            };
          };
        };
      } else {
        if this.HasCombatTarget() {
          if Equals(evt.description, n"Dead_Body") || Equals(evt.description, n"Unconscious") || Equals(evt.description, n"HeartAttack") {
            if !ArrayContains(this.m_ignoreList, evt.target.GetEntityID()) {
              ignoreListEvent = new IgnoreListEvent();
              ignoreListEvent.bodyID = evt.target.GetEntityID();
              ArrayPush(this.m_ignoreList, ignoreListEvent.bodyID);
              this.SendEventToSquad(ignoreListEvent);
            };
          };
        };
      };
    };
  }

  protected cb func OnLookedAtEvent(evt: ref<LookedAtEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject().GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      if evt.isLookedAt && !IsDefined(this.m_activeReaction) && this.CanTriggerReprimandOrder() {
        broadcaster.SendDrirectStimuliToTarget(this.GetOwner(), gamedataStimType.AskToFollowOrder, this.GetOwner());
      };
    };
  }

  protected cb func OnDetectedEvent(evt: ref<OnDetectedEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let deviceLink: ref<PuppetDeviceLinkPS>;
    let scriptedPuppetTarget: ref<ScriptedPuppet>;
    let securitySystem: ref<SecuritySystemControllerPS>;
    let securitySystemInput: ref<SecuritySystemInput>;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let owner: ref<GameObject> = this.GetOwner();
    if ScriptedPuppet.IsBlinded(ownerPuppet) {
      return false;
    };
    if IsDefined(evt.target) && evt.isVisible {
      if evt.target.IsPlayer() {
        deviceLink = owner.GetDeviceLink() as PuppetDeviceLinkPS;
        if IsDefined(deviceLink) {
          deviceLink.NotifyAboutSpottingPlayer(true);
        };
        if this.IsPlayerAiming() && this.IsReactionAvailableInPreset(gamedataStimType.AimingAt) || this.DidTargetMakeMeAlerted(evt.target) {
          if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, evt.target) {
            TargetTrackingExtension.InjectThreat(ownerPuppet, evt.target);
          };
        } else {
          broadcaster = evt.target.GetStimBroadcasterComponent();
          securitySystem = ownerPuppet.GetSecuritySystem();
          if Equals(this.m_reactionPreset.Type(), gamedataReactionPresetType.Civilian_Guard) {
            broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.SecurityBreach, owner);
          } else {
            if IsDefined(securitySystem) {
              securitySystemInput = deviceLink.ActionSecurityBreachNotification(evt.target.GetWorldPosition(), evt.target, ESecurityNotificationType.DEFAULT);
              if Equals(securitySystem.DetermineSecuritySystemState(securitySystemInput, true), ESecuritySystemState.COMBAT) {
                if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, evt.target) {
                  TargetTrackingExtension.InjectThreat(ownerPuppet, evt.target);
                };
              } else {
                ownerPuppet.TriggerSecuritySystemNotification(evt.target.GetWorldPosition(), evt.target, ESecurityNotificationType.DEFAULT);
              };
            };
          };
          if this.IsTargetArmed(evt.target) && IsDefined(broadcaster) {
            broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.WeaponDisplayed, owner);
          };
        };
      } else {
        if NotEquals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) && evt.target.IsPuppet() && this.IsTargetSquadAlly(evt.target) && !evt.target.IsDead() && !ownerPuppet.IsCharacterCivilian() && !ownerPuppet.IsCharacterChildren() {
          scriptedPuppetTarget = evt.target as ScriptedPuppet;
          if Equals(scriptedPuppetTarget.GetStimReactionComponent().GetReactionPreset().Type(), gamedataReactionPresetType.Civilian_Guard) {
            if Equals(scriptedPuppetTarget.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Fear) && Equals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) {
              NPCPuppet.ChangeHighLevelState(owner, gamedataNPCHighLevelState.Alerted);
            };
          } else {
            this.HelpAlly(scriptedPuppetTarget);
          };
        };
      };
    };
  }

  protected cb func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> Bool {
    let target: wref<GameObject>;
    if !this.IsEnabled() {
      return IsDefined(null);
    };
    if IsDefined(this.GetOwner()) {
      target = evt.GetWhoBreached();
    };
    if IsDefined(target) && target.IsPlayer() && this.IsTargetDetected(target) {
      if NotEquals(this.m_reactionPreset.Type(), gamedataReactionPresetType.Civilian_Guard) {
        this.GetOwnerPuppet().TriggerSecuritySystemNotification(target.GetWorldPosition(), target, ESecurityNotificationType.DEFAULT);
      };
    };
  }

  protected cb func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> Bool {
    let debugFact: CName;
    if this.GetOwnerPuppet().GetAreIncomingSecuritySystemEventsSuppressed() {
      return IsDefined(null);
    };
    if !IsFinal() {
      debugFact = StringToName(EntityID.ToDebugStringDecimal(this.m_owner_id));
      AddFact(this.GetOwnerPuppet().GetGame(), debugFact);
    };
    this.ReactToSecuritySystemOutputByTask(evt);
  }

  protected cb func OnReprimandEscalationEvent(evt: ref<ReprimandEscalationEvent>) -> Bool {
    if evt.startReprimand {
      this.StartEscalateReprimand();
    } else {
      if evt.startDeescalate {
        this.DeescalateReprimand();
      } else {
        this.ReprimandEscalation();
      };
    };
  }

  private final func StartEscalateReprimand() -> Void {
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
    statPoolSys.RequestAddingStatPool(Cast(this.GetOwner().GetEntityID()), t"BaseStatPools.ReprimandEscalation", true);
  }

  private final func ReprimandEscalation() -> Void {
    let statPoolMod: StatPoolModifier;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerId: EntityID = owner.GetEntityID();
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(owner.GetGame());
    statPoolSys.GetModifier(Cast(ownerId), gamedataStatPoolType.ReprimandEscalation, gameStatPoolModificationTypes.Regeneration, statPoolMod);
    statPoolMod.enabled = true;
    statPoolSys.RequestSettingModifier(Cast(ownerId), gamedataStatPoolType.ReprimandEscalation, gameStatPoolModificationTypes.Regeneration, statPoolMod);
  }

  private final func DeescalateReprimand() -> Void {
    let decayMod: StatPoolModifier;
    let regenMod: StatPoolModifier;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerId: EntityID = owner.GetEntityID();
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(owner.GetGame());
    statPoolSys.GetModifier(Cast(ownerId), gamedataStatPoolType.ReprimandEscalation, gameStatPoolModificationTypes.Regeneration, regenMod);
    regenMod.enabled = false;
    statPoolSys.RequestSettingModifier(Cast(ownerId), gamedataStatPoolType.ReprimandEscalation, gameStatPoolModificationTypes.Regeneration, regenMod);
    statPoolSys.GetModifier(Cast(ownerId), gamedataStatPoolType.ReprimandEscalation, gameStatPoolModificationTypes.Decay, decayMod);
    decayMod.enabled = true;
    statPoolSys.RequestSettingModifier(Cast(ownerId), gamedataStatPoolType.ReprimandEscalation, gameStatPoolModificationTypes.Decay, decayMod);
  }

  protected cb func OnReprimandUpdate(evt: ref<ReprimandUpdate>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let owner: ref<GameObject>;
    let ownerPuppet: ref<ScriptedPuppet>;
    let reprimandUpdateEvent: ref<StimuliEvent>;
    let trespasser: ref<GameObject>;
    let trespasserID: EntityID;
    if !this.IsEnabled() {
      return false;
    };
    owner = this.GetOwner();
    ownerPuppet = this.GetOwnerPuppet();
    if ownerPuppet.GetAreIncomingSecuritySystemEventsSuppressed() {
      return false;
    };
    if Equals(evt.reprimandInstructions, EReprimandInstructions.CONCLUDE_SUCCESSFUL) {
      reprimandUpdateEvent = new StimuliEvent();
      reprimandUpdateEvent.name = n"targetComplies";
      owner.QueueEvent(reprimandUpdateEvent);
    };
    if Equals(evt.reprimandInstructions, EReprimandInstructions.CONCLUDE_FAILED) {
      reprimandUpdateEvent = new StimuliEvent();
      reprimandUpdateEvent.name = n"concludeFailed";
      owner.QueueEvent(reprimandUpdateEvent);
    };
    if Equals(evt.reprimandInstructions, EReprimandInstructions.RELEASE_TO_ANOTHER_ENTITY) {
      reprimandUpdateEvent = new StimuliEvent();
      reprimandUpdateEvent.name = n"exitReprimand";
    };
    trespasserID = evt.target;
    trespasser = GameInstance.FindEntityByID(owner.GetGame(), trespasserID) as GameObject;
    if !IsDefined(trespasser) {
      return false;
    };
    broadcaster = trespasser.GetStimBroadcasterComponent();
    if VehicleComponent.IsMountedToVehicle(owner.GetGame(), trespasser) {
      if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, trespasser) {
        TargetTrackingExtension.InjectThreat(ownerPuppet, trespasser);
      };
    };
    if Equals(evt.reprimandInstructions, EReprimandInstructions.INITIATE_FIRST) {
      if this.RecentReaction(gamedataOutput.AskToHolster) {
        broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.ReprimandFinalWarning, owner);
      } else {
        broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.Reprimand, owner);
      };
    };
    if Equals(evt.reprimandInstructions, EReprimandInstructions.INITIATE_SUCCESSIVE) {
      broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.ReprimandFinalWarning, owner);
    };
    if Equals(evt.reprimandInstructions, EReprimandInstructions.TAKEOVER) {
      broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.Reprimand, owner);
    };
  }

  private final func RecentReaction(behaviorName: gamedataOutput) -> Bool {
    let reactionData: ref<AIReactionData>;
    let simTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame()));
    let i: Int32 = 0;
    while i < ArraySize(this.m_reactionCache) {
      reactionData = this.m_reactionCache[i];
      if Equals(reactionData.reactionBehaviorName, behaviorName) && reactionData.recentReactionTimeStamp >= simTime {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected cb func OnSuspiciousObjectEvent(evt: ref<SuspiciousObjectEvent>) -> Bool {
    if evt.target.IsPlayer() {
      AIActionHelper.TryChangingAttitudeToHostile(this.GetOwner() as ScriptedPuppet, evt.target);
    };
  }

  private final func HelpAlly(ally: wref<GameObject>, opt attacker: wref<Entity>) -> Void {
    let allyAIComponent: ref<AIHumanComponent>;
    let commandCombatTargetVariant: Variant;
    let ownerPuppet: ref<ScriptedPuppet>;
    let targetOfAlly: wref<GameObject>;
    let threat: TrackedLocation;
    if !IsDefined(ally) {
      return;
    };
    if Equals(this.m_reactionPreset.Type(), gamedataReactionPresetType.NoReaction) {
      return;
    };
    if IsDefined(attacker) {
      targetOfAlly = attacker as GameObject;
    } else {
      allyAIComponent = (ally as ScriptedPuppet).GetAIControllerComponent();
      if IsDefined(allyAIComponent) {
        commandCombatTargetVariant = allyAIComponent.GetBehaviorArgument(n"CommmandCombatTarget");
        if VariantIsValid(commandCombatTargetVariant) {
          targetOfAlly = FromVariant(commandCombatTargetVariant);
        };
      };
    };
    ownerPuppet = this.GetOwnerPuppet();
    if IsDefined(targetOfAlly) && ally.GetTargetTrackerComponent().ThreatFromEntity(targetOfAlly, threat) {
    } else {
      if ally.GetTargetTrackerComponent().GetTopHostileThreat(false, threat) {
      } else {
        if !ScriptedPuppet.IsActive(ally) {
          AISquadHelper.EnterAlerted(ownerPuppet);
          return;
        };
        if IsDefined(attacker) && this.IsSquadMateInDanger(gamedataOutput.Intruder) {
          if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, targetOfAlly) && this.IsTargetInFront(ally) {
            TargetTrackingExtension.InjectThreat(ownerPuppet, targetOfAlly);
          };
          return;
        };
        return;
      };
    };
    if IsDefined(threat.entity) && AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, threat.entity as GameObject) {
      TargetTrackingExtension.InjectThreat(ownerPuppet, threat);
    };
  }

  private final func ReactToSecurityOutput(evt: ref<SecuritySystemOutput>) -> Void {
    let deviceNotifier: ref<GameObject>;
    let trespasser: wref<GameObject>;
    if !this.IsEnabled() {
      return;
    };
    if Equals(evt.GetOriginalInputEvent().GetNotificationType(), ESecurityNotificationType.DEVICE_DESTROYED) && NotEquals(evt.GetCachedSecurityState(), ESecuritySystemState.COMBAT) {
      deviceNotifier = evt.GetOriginalInputEvent().GetNotifierHandle().GetOwnerEntityWeak() as GameObject;
      StimBroadcasterComponent.SendStimDirectly(deviceNotifier, gamedataStimType.ProjectileDistraction, this.GetOwner());
      return;
    };
    if !evt.GetSecurityStateChanged() && this.ReflectSecSysStateToHLS(evt.GetCachedSecurityState()) {
      return;
    };
    trespasser = evt.GetOriginalInputEvent().GetWhoBreached();
    switch evt.GetCachedSecurityState() {
      case ESecuritySystemState.COMBAT:
        if Equals(evt.GetBreachOrigin(), EBreachOrigin.LOCAL) && IsDefined(trespasser) {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"LoreAnim") {
            this.m_cacheSecuritySysOutput = evt;
          } else {
            this.TriggerCombat(trespasser);
          };
        } else {
          if !IsDefined(trespasser) || IsDefined(trespasser) && trespasser.IsPlayer() {
            this.TriggerAlerted();
          };
        };
        break;
      case ESecuritySystemState.ALERTED:
        if !IsDefined(trespasser) || IsDefined(trespasser) && trespasser.IsPlayer() {
          if Equals(evt.GetOriginalInputEvent().GetNotificationType(), ESecurityNotificationType.ALARM) {
            if Equals(evt.GetOriginalInputEvent().GetStimTypeTriggeredAlarm(), gamedataStimType.DeadBody) {
              this.m_isAlertedByDeadBody = true;
            } else {
              this.m_stolenVehicle = evt.GetOriginalInputEvent().GetNotifierHandle().GetOwnerEntityWeak() as VehicleObject;
            };
          };
          this.TriggerAlerted();
        };
        break;
      default:
    };
  }

  private final func ReflectSecSysStateToHLS(securityState: ESecuritySystemState) -> Bool {
    switch securityState {
      case ESecuritySystemState.COMBAT:
        if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) {
          return true;
        };
        return false;
      case ESecuritySystemState.ALERTED:
        if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Alerted) {
          return true;
        };
        return false;
      case ESecuritySystemState.SAFE:
        if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) {
          return true;
        };
        return false;
      default:
        return false;
    };
  }

  private final func TriggerAlerted() -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if !ownerPuppet.GetSecuritySystem().IsReprimandOngoing() && Equals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Relaxed) && !ownerPuppet.IsCharacterCivilian() && !ownerPuppet.IsCharacterChildren() {
      NPCPuppet.ChangeHighLevelState(this.GetOwner(), gamedataNPCHighLevelState.Alerted);
    };
  }

  private final func TriggerCombat(trespasser: wref<GameObject>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if ownerPuppet.IsCharacterCivilian() {
      broadcaster = trespasser.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.SendDrirectStimuliToTarget(this.GetOwner(), gamedataStimType.SecurityBreach, this.GetOwner());
      };
    };
    if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, trespasser) {
      TargetTrackingExtension.InjectThreat(ownerPuppet, trespasser);
    };
  }

  protected cb func OnReactionBehaviorStatus(evt: ref<ReactionBehaviorStatus>) -> Bool {
    switch evt.status {
      case AIbehaviorUpdateOutcome.IN_PROGRESS:
        if IsDefined(this.m_desiredReaction) {
          this.OnReactionStarted(evt.reactionData);
        } else {
          this.m_activeReaction = evt.reactionData;
        };
        break;
      default:
        this.OnReactionEnded();
    };
  }

  protected cb func OnEndLookatEvent(evt: ref<EndLookatEvent>) -> Bool {
    if !this.m_inReactionSequence {
      this.DeactiveLookAt(evt.repeat);
    };
  }

  protected cb func OnTerminateReactionLookatEvent(evt: ref<TerminateReactionLookatEvent>) -> Bool {
    this.DeactiveLookAt();
  }

  protected cb func OnRepeatLookatEvent(evt: ref<RepeatLookatEvent>) -> Bool {
    this.m_lookatRepeat = false;
    if this.m_playerProximity && !this.m_inReactionSequence {
      this.TriggerFacialLookAtReaction(false, true);
    };
  }

  protected cb func OnEventReceived(stimEvent: ref<StimuliEvent>) -> Bool {
    if !this.IsStimuliEventValid(stimEvent) {
      return IsDefined(null);
    };
    this.HandleStimEventByTask(stimEvent);
  }

  protected cb func OnAIEvent(aiEvent: ref<AIEvent>) -> Bool {
    if Equals(aiEvent.name, n"ReprimandSuccessful") {
      this.GetOwnerPuppet().TriggerSecuritySystemNotification(this.m_activeReaction.stimTarget.GetWorldPosition(), this.m_activeReaction.stimTarget, ESecurityNotificationType.REPRIMAND_SUCCESSFUL);
    };
    if Equals(aiEvent.name, n"TriggerCombatReaction") {
      this.TriggerPendingReaction();
      this.m_inPendingBehavior = false;
    };
    if Equals(aiEvent.name, n"TriggerPendingReaction") {
      this.TriggerPendingReaction();
      this.m_inPendingBehavior = false;
    };
  }

  private final func Initialiaze() -> Void {
    this.m_delay = TweakDBInterface.GetVector2(t"AIGeneralSettings.reactionDelay", new Vector2(0.30, 0.70));
    let puppetBlackboard: ref<IBlackboard> = this.GetOwnerPuppet().GetPuppetStateBlackboard();
    if IsDefined(puppetBlackboard) {
      if puppetBlackboard.GetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior) {
        this.m_inPendingBehavior = true;
      };
      this.m_pendingBehaviorCb = puppetBlackboard.RegisterListenerBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, this, n"OnPendingBehaviorChanged");
    };
  }

  private final func CacheEvent(stimEvent: ref<StimuliEvent>) -> Void {
    if ArraySize(this.m_stimuliCache) > 0 {
      if !this.IsEventDuplicated(stimEvent) {
        if ArraySize(this.m_stimuliCache) > 4 {
          ArrayRemove(this.m_stimuliCache, this.m_stimuliCache[0]);
        };
        stimEvent.id = Cast(ArraySize(this.m_stimuliCache));
        ArrayPush(this.m_stimuliCache, stimEvent);
      };
    } else {
      stimEvent.id = Cast(ArraySize(this.m_stimuliCache));
      ArrayPush(this.m_stimuliCache, stimEvent);
    };
  }

  private final func CacheReaction(reactionData: ref<AIReactionData>) -> Void {
    if ArraySize(this.m_reactionCache) > 0 {
      if ArraySize(this.m_reactionCache) > 4 {
        ArrayRemove(this.m_reactionCache, this.m_reactionCache[0]);
      };
      reactionData.recentReactionTimeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame())) + TweakDBInterface.GetFloat(t"AIGeneralSettings.recentReactionValidTimeStamp", 120.00);
      ArrayPush(this.m_reactionCache, reactionData);
    } else {
      reactionData.recentReactionTimeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame())) + TweakDBInterface.GetFloat(t"AIGeneralSettings.recentReactionValidTimeStamp", 120.00);
      ArrayPush(this.m_reactionCache, reactionData);
    };
  }

  private final func IsEventDuplicated(stimEvent: ref<StimuliEvent>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_stimuliCache) {
      if this.IsDuplicate(stimEvent, this.m_stimuliCache[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsDuplicate(stimEvent: ref<StimuliEvent>, cacheStim: ref<StimuliEvent>) -> Bool {
    if stimEvent.sourceObject == cacheStim.sourceObject && Equals(stimEvent.GetStimType(), cacheStim.GetStimType()) {
      return true;
    };
    return false;
  }

  protected cb func OnStimThresholdEvent(thresholdEvent: ref<StimThresholdEvent>) -> Bool {
    let delayEvent: ref<StimThresholdEvent>;
    if thresholdEvent.reset {
      this.m_currentStimThresholdValue = 0;
      this.m_timeStampThreshold = 0.00;
    } else {
      if this.m_currentStimThresholdValue == 0 && this.m_timeStampThreshold == 0.00 {
        this.m_timeStampThreshold = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame())) + thresholdEvent.timeThreshold;
        delayEvent = new StimThresholdEvent();
        delayEvent.reset = true;
        GameInstance.GetDelaySystem(this.GetOwnerPuppet().GetGame()).DelayEvent(this.GetOwner(), delayEvent, thresholdEvent.timeThreshold);
      };
      this.m_currentStimThresholdValue += 1;
    };
  }

  protected cb func OnStealthStimThresholdEvent(thresholdEvent: ref<StealthStimThresholdEvent>) -> Bool {
    let delayEvent: ref<StealthStimThresholdEvent>;
    if thresholdEvent.reset {
      this.m_currentStealthStimThresholdValue = 0;
      this.m_stealthTimeStampThreshold = 0.00;
    } else {
      if this.m_currentStealthStimThresholdValue == 0 && this.m_stealthTimeStampThreshold == 0.00 {
        this.m_stealthTimeStampThreshold = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame())) + thresholdEvent.timeThreshold;
        delayEvent = new StealthStimThresholdEvent();
        delayEvent.reset = true;
        GameInstance.GetDelaySystem(this.GetOwnerPuppet().GetGame()).DelayEvent(this.GetOwner(), delayEvent, thresholdEvent.timeThreshold);
      };
      this.m_currentStealthStimThresholdValue += 1;
    };
  }

  public final func GetIgnoreList() -> array<EntityID> {
    return this.m_ignoreList;
  }

  private final func IsStimuliEventValid(stimEvent: ref<StimuliEvent>) -> Bool {
    let owner: ref<GameObject>;
    if stimEvent.sourceObject == null || Vector4.IsZero(stimEvent.sourcePosition) {
      return false;
    };
    owner = this.GetOwner();
    if stimEvent.sourceObject == owner {
      return false;
    };
    if Equals(stimEvent.GetStimType(), gamedataStimType.Invalid) {
      return false;
    };
    if owner.IsPlayer() {
      return false;
    };
    return true;
  }

  private final func ShouldEventBeProcessed(stimEvent: ref<StimuliEvent>) -> Bool {
    if !ScriptedPuppet.IsActive(this.GetOwner()) {
      return false;
    };
    if !stimEvent.stimRecord.IsReactionStim() {
      return false;
    };
    if Equals(this.m_reactionPreset.Type(), gamedataReactionPresetType.NoReaction) {
      return false;
    };
    if this.m_puppetReactionBlackboard.GetBool(GetAllBlackboardDefs().PuppetReaction.blockReactionFlag) {
      return false;
    };
    return true;
  }

  private final func ShouldStimBeProcessed(stimEvent: ref<StimuliEvent>) -> Bool {
    let allyReactionCmp: ref<ReactionManagerComponent>;
    let broadcaster: ref<StimBroadcasterComponent>;
    let delayStimEvent: ref<DelayStimEvent>;
    let delaySystem: ref<DelaySystem>;
    let device: ref<Device>;
    let investigateData: stimInvestigateData;
    let investigators: array<EntityID>;
    let ownerSecuritySystem: ref<SecuritySystemControllerPS>;
    let reevaluateDetectionOverwriteEvent: ref<ReevaluateDetectionOverwriteEvent>;
    let stimData: StimEventData;
    let stimTags: array<CName>;
    let stimType: gamedataStimType;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let reactionData: ref<AIReactionData> = this.m_desiredReaction;
    if !IsDefined(reactionData) {
      reactionData = this.m_activeReaction;
    };
    stimType = stimEvent.GetStimType();
    if Equals(stimType, gamedataStimType.MeleeAttack) && WeaponObject.IsFists(GameObject.GetActiveWeapon(stimEvent.sourceObject).GetItemID()) {
      return false;
    };
    if Equals(stimType, gamedataStimType.WeaponDisplayed) && !this.CanAskToHolsterWeapon() {
      return false;
    };
    if this.IsCategory(stimEvent, n"Security") {
      if stimEvent.sourceObject.IsPuppet() && !owner.IsTargetTresspassingMyZone(stimEvent.sourceObject) {
        return false;
      };
    };
    if this.IsPublicZone(stimEvent) && !this.IsPlayerInZone(gamePSMZones.Public) {
      return false;
    };
    if Equals(stimEvent.stimPropagation, gamedataStimPropagation.Visual) {
      if IsDefined(stimEvent.sourceObject as ScriptedPuppet) {
        if !this.IsTargetVisible(stimEvent.sourceObject) {
          if Equals(stimType, gamedataStimType.Gunshot) {
            if this.ValidVisualGunshotTarget(stimEvent, reactionData) {
              if !this.CheckVisibilityRaycast(stimEvent) {
                return false;
              };
            } else {
              return false;
            };
          } else {
            return false;
          };
        };
      } else {
        if !this.IsTargetInFront(stimEvent.sourceObject) {
          return false;
        };
        if !this.IsTargetClose(stimEvent.sourceObject) {
          return false;
        };
        if GameInstance.GetWorkspotSystem(owner.GetGame()).IsActorInWorkspot(owner) {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Braindance") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Sleep") {
            return false;
          };
        };
      };
    };
    if Equals(stimEvent.stimPropagation, gamedataStimPropagation.Audio) && !this.IsDirectStimuli(stimType) {
      if !this.IsTargetVisible(stimEvent.sourceObject) {
        if !ownerPuppet.GetSensesComponent().IsHearingEnabled() {
          return false;
        };
        if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"HearingImpaired") && !this.CheckHearingDistance(stimEvent) {
          return false;
        };
      };
    };
    if NotEquals(stimType, gamedataStimType.Combat) && ScriptedPuppet.IsBeingGrappled(ownerPuppet) {
      return false;
    };
    if Equals(stimType, gamedataStimType.AimingAt) && this.m_reactionPreset.IsAggressive() && this.IsReactionAvailableInPreset(gamedataStimType.AimingAt) {
      delaySystem = GameInstance.GetDelaySystem(owner.GetGame());
      delaySystem.CancelDelay(this.m_delayDetectionEventID);
      reevaluateDetectionOverwriteEvent = new ReevaluateDetectionOverwriteEvent();
      reevaluateDetectionOverwriteEvent.target = stimEvent.sourceObject;
      this.m_delayDetectionEventID = delaySystem.DelayEvent(owner, reevaluateDetectionOverwriteEvent, 0.10);
      delaySystem.CancelDelay(this.m_delayStimEventID);
      delayStimEvent = new DelayStimEvent();
      delayStimEvent.stimEvent = stimEvent;
      this.m_delayStimEventID = delaySystem.DelayEvent(owner, delayStimEvent, 0.35);
      return false;
    };
    if this.IgnoreStimIfNonFriendly(stimEvent) && !this.SourceAttitude(stimEvent.sourceObject, EAIAttitude.AIA_Friendly) {
      return false;
    };
    stimTags = stimEvent.stimRecord.Tags();
    if ArrayContains(stimTags, n"Stealth") && !ReactionManagerComponent.ReactOnPlayerStealthStim(owner, stimEvent.sourceObject) {
      return false;
    };
    if ArrayContains(stimTags, n"Security") && !ownerPuppet.IsConnectedToSecuritySystem() {
      return false;
    };
    if ArrayContains(stimTags, n"PlayerOnly") && !stimEvent.sourceObject.IsDevice() {
      investigateData = stimEvent.stimInvestigateData;
      if !stimEvent.sourceObject.IsPlayer() && !IsDefined(investigateData.attackInstigator) {
        return false;
      };
      if IsDefined(investigateData.attackInstigator) && !(investigateData.attackInstigator as GameObject).IsPlayer() {
        return false;
      };
    };
    if this.SourceAttitude(stimEvent.sourceObject, EAIAttitude.AIA_Friendly) {
      if ArrayContains(stimTags, n"IgnoreFriendly") && !stimEvent.sourceObject.IsDevice() {
        return false;
      };
      if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) && !ArrayContains(stimTags, n"AllowFriendlyInCombat") {
        return false;
      };
      if this.ShouldHelpAlly(stimType) {
        if this.IsTargetSquadAlly(stimEvent.sourceObject) || this.IsTargetRecentSquadAlly(stimEvent.sourceObject) {
          this.HelpAlly(stimEvent.sourceObject, investigateData.attackInstigator);
          allyReactionCmp = (stimEvent.sourceObject as ScriptedPuppet).GetStimReactionComponent();
          if IsDefined(ownerPuppet) {
            ownerSecuritySystem = ownerPuppet.GetSecuritySystem();
            if IsDefined(ownerSecuritySystem) && IsDefined(stimEvent.sourceObject as ScriptedPuppet) && IsDefined(allyReactionCmp) {
              if ownerSecuritySystem.IsReprimandOngoing() && IsDefined(ownerSecuritySystem.GetReprimandPerformer()) || Equals(allyReactionCmp.GetReactionPreset().Type(), gamedataReactionPresetType.Civilian_Guard) || Equals(allyReactionCmp.GetActiveReactionData().reactionBehaviorName, gamedataOutput.BackOff) {
                broadcaster = this.GetPlayerSystem().GetLocalPlayerControlledGameObject().GetStimBroadcasterComponent();
                if IsDefined(broadcaster) {
                  broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.SoundDistraction, owner);
                };
                return false;
              };
            };
          };
          if NotEquals(stimType, gamedataStimType.Call) && NotEquals(stimType, gamedataStimType.Dying) {
            return false;
          };
        } else {
          return false;
        };
      };
    };
    if this.CheckSquadInvestigation(stimData) {
      return false;
    };
    if this.IsSameStimulus(stimEvent) && this.IsSameSourceObject(stimEvent) && this.IgnoreStimIfFromSameSource(stimEvent) {
      return false;
    };
    if IsDefined(reactionData) && !this.IsStimPriorityValid(stimEvent, reactionData.stimPriority) {
      return false;
    };
    stimData = this.FillStimData(stimEvent);
    if ArrayContains(this.m_ignoreList, stimEvent.sourceObject.GetEntityID()) {
      return false;
    };
    if GameObject.IsCooldownActive(owner, EnumValueToName(n"gamedataStimType", Cast(EnumInt(stimType)))) {
      return false;
    };
    if Equals(stimType, gamedataStimType.AreaEffect) && !this.m_inPendingBehavior && !ownerPuppet.IsCharacterCivilian() {
      return false;
    };
    if IsDefined(this.m_desiredReaction) && Equals(this.m_desiredReaction.stimType, stimType) && GameObject.IsCooldownActive(owner, StringToName("ovefloodCooldown" + EnumValueToString("gamedataStimType", Cast(EnumInt(this.m_desiredReaction.stimType))))) {
      return false;
    };
    if Equals(stimType, gamedataStimType.GrenadeLanded) && !this.ShouldTriggerGrenadeDodgeBehavior(stimEvent) {
      return false;
    };
    if Equals(stimType, gamedataStimType.DeviceExplosion) && !this.CanTriggerPanicInCombat(stimEvent) {
      return false;
    };
    if ownerPuppet.IsCharacterPolice() && !this.ShouldPoliceReact(stimEvent) {
      return false;
    };
    if this.ShouldBeDetected(stimType) && !this.IsTargetDetected(stimEvent.sourceObject) {
      return false;
    };
    if Equals(stimType, gamedataStimType.Distract) {
      device = stimEvent.sourceObject as Device;
      investigators = device.GetDevicePS().GetWillingInvestigators();
      if !ArrayContains(investigators, owner.GetEntityID()) && this.IsTargetInFront(stimEvent.sourceObject, 180.00) {
        if !ownerPuppet.IsInvestigating() && ArraySize(investigators) != 0 {
          this.ActivateReactionLookAt(stimEvent.sourceObject, true, false, 1.00, true);
        };
        return false;
      };
    };
    if this.HasCombatTarget() {
      if this.CanStimInterruptCombat(stimEvent) {
        ScriptedPuppet.SendActionSignal(ownerPuppet, n"GracefulCombatInterruption", 2.00);
        this.m_inPendingBehavior = true;
      } else {
        if this.ShouldUpdateThreatPosition(stimEvent) {
          ownerPuppet.GetTargetTrackerComponent().AddThreat(stimEvent.sourceObject, true, stimEvent.sourceObject.GetWorldPosition(), 1.00, -1.00, false);
        };
        return false;
      };
    };
    return true;
  }

  private final func ProcessStimParams(stimEvent: ref<StimuliEvent>) -> StimParams {
    let stimParams: StimParams;
    let owner: ref<GameObject> = this.GetOwner();
    let stimData: StimEventData = this.FillStimData(stimEvent);
    let rules: array<wref<Rule_Record>> = this.GetRules();
    let reactionOutput: ReactionOutput = this.GetReactionOutput(stimEvent.GetStimType(), rules);
    if GameInstance.GetWorkspotSystem(owner.GetGame()).IsActorInWorkspot(owner) {
      reactionOutput.startedInWorkspot = true;
      if this.GetOwnerPuppet().IsCharacterCivilian() {
        reactionOutput.workspotReaction = GameInstance.GetWorkspotSystem(owner.GetGame()).IsReactionAvailable(owner, reactionOutput.workspotReactionType);
      };
    };
    stimParams.stimData = stimData;
    stimParams.reactionOutput = reactionOutput;
    return stimParams;
  }

  private func FillStimData(stimEvent: ref<StimuliEvent>) -> StimEventData {
    let data: StimEventData;
    data.source = stimEvent.sourceObject;
    data.stimType = stimEvent.GetStimType();
    return data;
  }

  private final const func IsReactionAvailableInPreset(stimTrigger: gamedataStimType) -> Bool {
    let reactionPresetOutput: ReactionOutput = this.GetReactionOutput(stimTrigger, this.GetRules());
    if NotEquals(reactionPresetOutput.reactionBehavior, gamedataOutput.Ignore) && NotEquals(reactionPresetOutput.reactionBehavior, gamedataOutput.Invalid) {
      return true;
    };
    return false;
  }

  private final func CreateFearThreashold() -> Void {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetOwner().GetGame());
    let statMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.PersonalityFear, gameStatModifierType.Additive, this.m_reactionPreset.FearThreshold());
    statSystem.AddModifier(Cast(this.GetOwner().GetEntityID()), statMod);
  }

  private final func AddReactionValueToStatPool(reactionData: ref<AIReactionData>) -> Void {
    let ownerId: EntityID;
    let securitySystem: ref<SecuritySystemControllerPS>;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(ownerPuppet.GetGame());
    if IsDefined(reactionData) && Equals(reactionData.reactionBehaviorName, gamedataOutput.TurnAt) && reactionData.stimTarget.IsPuppet() && this.IsTargetVisible(reactionData.stimTarget) {
      return;
    };
    securitySystem = ownerPuppet.GetSecuritySystem();
    if IsDefined(securitySystem) && !securitySystem.IsReprimandOngoing() {
      if reactionData.stimRecord.Fear() > 0.00 {
        ownerId = ownerPuppet.GetEntityID();
        statPoolSystem.RequestSettingModifierWithRecord(Cast(ownerId), gamedataStatPoolType.Fear, gameStatPoolModificationTypes.Decay, t"BaseStatPools.ReactionValueDecay");
        statPoolSystem.RequestChangingStatPoolValue(Cast(ownerId), gamedataStatPoolType.Fear, reactionData.stimRecord.Fear(), null, true, false);
      };
    };
  }

  private final const func GetRules() -> array<wref<Rule_Record>> {
    let rules: array<wref<Rule_Record>>;
    this.m_reactionPreset.Rules(rules);
    return rules;
  }

  private final const func GetReactionOutput(stimType: gamedataStimType, rules: array<wref<Rule_Record>>) -> ReactionOutput {
    let reactionOutput: ReactionOutput;
    let i: Int32 = 0;
    while i < ArraySize(rules) {
      if this.StimRule(rules[i], stimType) {
        reactionOutput.reactionPriority = rules[i].Output().Priority();
        reactionOutput.AIbehaviorPriority = rules[i].Output().AIPriority();
        reactionOutput.reactionCooldown = rules[i].Cooldown();
        reactionOutput.reactionBehavior = rules[i].Output().Type();
        reactionOutput.workspotReactionType = rules[i].WorkspotOutput();
      } else {
        reactionOutput.reactionBehavior = gamedataOutput.Ignore;
        i += 1;
      };
    };
    return reactionOutput;
  }

  private final const func StimRule(rule: wref<Rule_Record>, stimType: gamedataStimType) -> Bool {
    if IsDefined(rule) && Equals(rule.Stimulus().Type(), stimType) {
      return true;
    };
    return false;
  }

  private func ProcessReactionOutput(stimEvent: ref<StimuliEvent>, stimParams: StimParams) -> Void {
    let grenade: ref<BaseGrenade>;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let reactionData: ref<AIReactionData> = this.m_desiredReaction;
    if !IsDefined(reactionData) {
      reactionData = this.m_activeReaction;
    };
    grenade = stimEvent.sourceObject as BaseGrenade;
    if IsDefined(grenade) && this.HasCombatTarget() && Equals(stimEvent.GetStimType(), gamedataStimType.ProjectileDistraction) {
      stimEvent.SetStimType(gamedataStimType.GrenadeLanded);
      stimParams = this.ProcessStimParams(stimEvent);
    };
    if Equals(stimParams.reactionOutput.reactionBehavior, gamedataOutput.Panic) && ownerPuppet.IsBoss() {
      return;
    };
    if stimParams.reactionOutput.workspotReaction {
      if GameInstance.GetWorkspotSystem(owner.GetGame()).SendReactionSignal(owner, stimParams.reactionOutput.workspotReactionType) {
        return;
      };
    };
    if Equals(stimParams.reactionOutput.reactionBehavior, gamedataOutput.Ignore) {
      return;
    };
    if Equals(stimParams.reactionOutput.reactionBehavior, gamedataOutput.LookAt) {
      if this.IsTargetInFront(stimEvent.sourceObject) || Equals(stimEvent.GetStimType(), gamedataStimType.Attention) {
        GameObject.PlayVoiceOver(owner, n"stlh_curious_grunt", n"Scripts:ProcessReactionOutput");
        this.ActivateReactionLookAt(stimEvent.sourceObject, true);
        return;
      };
      stimParams.reactionOutput.reactionBehavior = gamedataOutput.TurnAt;
      this.TriggerBehaviorReaction(stimParams.reactionOutput, stimEvent, stimParams.stimData);
    };
    if Equals(stimEvent.GetStimType(), gamedataStimType.OpeningDoor) {
      if this.IsTargetInFront(stimEvent.sourceObject) {
        GameObject.PlayVoiceOver(owner, n"stlh_curious_grunt", n"Scripts:ProcessReactionOutput");
        this.ActivateReactionLookAt(stimEvent.sourceObject, true);
        return;
      };
    };
    if Equals(stimParams.reactionOutput.reactionBehavior, gamedataOutput.Intruder) && !StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"LoreAnim") {
      if GameInstance.GetWorkspotSystem(owner.GetGame()).IsActorInWorkspot(owner) {
        if this.TriggerCombatFromHostileStim(stimEvent.GetStimType()) && AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, stimEvent.sourceObject) {
          if SenseComponent.ShouldIgnoreIfPlayerCompanion(owner, stimEvent.sourceObject) {
            return;
          };
          TargetTrackingExtension.InjectThreat(ownerPuppet, stimEvent.sourceObject);
          return;
        };
        if this.TriggerAlertedFromHostileStim(stimEvent) {
          NPCPuppet.ChangeHighLevelState(owner, gamedataNPCHighLevelState.Alerted);
          this.CacheEvent(stimEvent);
          return;
        };
      };
      if this.IsSquadMateInDanger(stimParams.reactionOutput.reactionBehavior) {
        if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, stimEvent.sourceObject) {
          TargetTrackingExtension.InjectThreat(ownerPuppet, stimEvent.sourceObject);
          return;
        };
      };
    };
    if IsDefined(reactionData) && stimParams.reactionOutput.reactionPriority < reactionData.reactionPriority {
      return;
    };
    if IsDefined(this.m_pendingReaction) && stimParams.reactionOutput.reactionPriority < this.m_pendingReaction.reactionPriority {
      return;
    };
    if IsDefined(this.m_activeReaction) && Equals(this.m_activeReaction.reactionBehaviorName, stimParams.reactionOutput.reactionBehavior) && NotEquals(this.m_activeReaction.reactionBehaviorName, gamedataOutput.DeviceInvestigate) {
      this.UpdateActiveReaction(stimParams.reactionOutput, stimEvent, stimParams.stimData, this.m_updateByActive);
    } else {
      if IsDefined(reactionData) && IsDefined(this.m_desiredReaction) && Equals(reactionData.reactionBehaviorName, stimParams.reactionOutput.reactionBehavior) && GameObject.IsCooldownActive(owner, StringToName("ovefloodCooldown" + EnumValueToString("gamedataOutput", Cast(EnumInt(this.m_desiredReaction.reactionBehaviorName))))) {
        return;
      };
      this.TriggerBehaviorReaction(stimParams.reactionOutput, stimEvent, stimParams.stimData);
    };
  }

  private final func UpdateActiveReaction(reaction: ReactionOutput, stimEvent: ref<StimuliEvent>, stimData: StimEventData, updateByActive: Bool) -> Void {
    let resetDesiredReactionData: ref<ResetReactionEvent>;
    let stimName: CName;
    let updateStimSourceAIEvent: ref<StimuliEvent>;
    let owner: ref<GameObject> = this.GetOwner();
    GameInstance.GetDelaySystem(owner.GetGame()).CancelDelay(this.m_resetReactionDataID);
    if updateByActive {
      this.m_desiredReaction = this.m_activeReaction;
    } else {
      this.m_desiredReaction = new AIReactionData();
      this.m_desiredReaction.reactionBehaviorName = reaction.reactionBehavior;
      this.m_desiredReaction.stimPriority = stimEvent.stimRecord.Priority().Type();
      this.m_desiredReaction.stimTarget = stimEvent.sourceObject;
      this.m_desiredReaction.stimSource = this.GetStimSource(stimEvent);
      this.m_desiredReaction.stimType = stimEvent.GetStimType();
      this.m_desiredReaction.stimRecord = stimEvent.stimRecord;
      this.m_desiredReaction.stimEventData = stimData;
      this.m_desiredReaction.reactionPriority = reaction.reactionPriority;
      this.m_desiredReaction.stimInvestigateData = stimEvent.stimInvestigateData;
      this.m_desiredReaction.reactionBehaviorAIPriority = reaction.AIbehaviorPriority;
      this.m_desiredReaction.reactionCooldown = reaction.reactionCooldown;
      this.m_desiredReaction.initAnimInWorkspot = reaction.startedInWorkspot;
    };
    if Equals(this.m_desiredReaction.reactionBehaviorName, gamedataOutput.DeviceInvestigate) && !this.IsInList(this.m_investigationList, stimData) {
      ArrayPush(this.m_investigationList, stimData);
    };
    updateStimSourceAIEvent = new StimuliEvent();
    updateStimSourceAIEvent.name = n"updateSource";
    owner.QueueEvent(updateStimSourceAIEvent);
    stimName = EnumValueToName(n"gamedataStimType", Cast(EnumInt(this.m_desiredReaction.stimType)));
    if this.m_desiredReaction.reactionCooldown != 0.00 {
      GameObject.StartCooldown(owner, stimName, this.m_desiredReaction.reactionCooldown);
    };
    if !GameObject.IsCooldownActive(owner, n"ActiveReactionValueCooldown-" + stimName) && !this.GetOwnerPuppet().GetSecuritySystem().IsReprimandOngoing() {
      this.AddReactionValueToStatPool(this.m_desiredReaction);
      GameObject.StartCooldown(owner, n"ActiveReactionValueCooldown-" + stimName, 1.00);
    };
    resetDesiredReactionData = new ResetReactionEvent();
    resetDesiredReactionData.data = this.m_desiredReaction;
    this.m_resetReactionDataID = GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, resetDesiredReactionData, 1.00);
  }

  private func TriggerBehaviorReaction(reaction: ReactionOutput, stimEvent: ref<StimuliEvent>, stimData: StimEventData) -> Void {
    let exitEvent: ref<AIEvent>;
    let game: GameInstance;
    let triggerAIEvent: ref<StimuliEvent>;
    let owner: ref<GameObject> = this.GetOwner();
    this.DeactiveLookAt();
    game = owner.GetGame();
    GameInstance.GetDelaySystem(game).CancelDelay(this.m_resetReactionDataID);
    this.m_desiredReaction = new AIReactionData();
    this.m_desiredReaction.reactionBehaviorName = reaction.reactionBehavior;
    this.m_desiredReaction.stimPriority = stimEvent.stimRecord.Priority().Type();
    this.m_desiredReaction.stimTarget = stimEvent.sourceObject;
    this.m_desiredReaction.stimType = stimEvent.GetStimType();
    this.m_desiredReaction.stimSource = this.GetStimSource(stimEvent);
    this.m_desiredReaction.stimRecord = stimEvent.stimRecord;
    this.m_desiredReaction.reactionPriority = reaction.reactionPriority;
    this.m_desiredReaction.stimInvestigateData = stimEvent.stimInvestigateData;
    this.m_desiredReaction.stimEventData = stimData;
    this.m_desiredReaction.reactionBehaviorAIPriority = reaction.AIbehaviorPriority;
    this.m_desiredReaction.reactionCooldown = reaction.reactionCooldown;
    this.m_desiredReaction.initAnimInWorkspot = reaction.startedInWorkspot;
    GameObject.StartCooldown(owner, StringToName("ovefloodCooldown" + EnumValueToString("gamedataStimType", Cast(EnumInt(this.m_desiredReaction.stimType)))), this.m_ovefloodCooldown);
    GameObject.StartCooldown(owner, StringToName("ovefloodCooldown" + EnumValueToString("gamedataOutput", Cast(EnumInt(this.m_desiredReaction.reactionBehaviorName)))), 0.50);
    triggerAIEvent = new StimuliEvent();
    triggerAIEvent.SetStimType(gamedataStimType.Invalid);
    if this.IsInPendingBehavior() {
      this.m_pendingReaction = this.m_desiredReaction;
      this.m_pendingReaction.validTillTimeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(game)) + TweakDBInterface.GetFloat(t"AIGeneralSettings.pendingReactionValidTimeStamp", 10.00);
      this.m_desiredReaction = null;
      if Equals(reaction.reactionBehavior, gamedataOutput.Reprimand) && VehicleComponent.IsMountedToVehicle(game, owner) {
        exitEvent = new AIEvent();
        exitEvent.name = n"ExitVehicle";
        owner.QueueEvent(exitEvent);
      };
    } else {
      triggerAIEvent.name = n"triggerReaction";
      if IsDefined(this.m_activeReaction) && Equals(this.m_activeReaction.reactionBehaviorName, gamedataOutput.BodyInvestigate) && AISquadHelper.IsSignalActive(this.GetOwnerPuppet(), n"BodyInvestigationTicketReceived") {
        this.OnBodyInvestigated(new BodyInvestigatedEvent());
      };
      if this.FirstSquadMemberReaction() && !this.DelayReaction(stimEvent.GetStimType()) {
        owner.QueueEvent(triggerAIEvent);
      } else {
        this.m_delayReactionEventID = GameInstance.GetDelaySystem(game).DelayEvent(owner, triggerAIEvent, RandRangeF(0.20, 0.70));
      };
      if Equals(reaction.reactionBehavior, gamedataOutput.Flee) || Equals(reaction.reactionBehavior, gamedataOutput.Surrender) || Equals(reaction.reactionBehavior, gamedataOutput.WalkAway) || Equals(reaction.reactionBehavior, gamedataOutput.CallGuard) {
        NPCPuppet.ChangeHighLevelState(owner, gamedataNPCHighLevelState.Fear);
        AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetFearAnimWrapper(this.GetFearReactionPhase(stimEvent)), 1.00);
        if !this.m_fearLocomotionWrapper {
          AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetRandomFearLocomotionAnimWrapper(this.GetFearReactionPhase(stimEvent)), 1.00);
        };
      };
    };
    if this.m_createThreshold {
      this.CreateFearThreashold();
      this.m_createThreshold = false;
    };
    this.CacheEvent(stimEvent);
  }

  private final func GetStimSource(stimEvent: ref<StimuliEvent>) -> Vector4 {
    let closestDistanceSquared: Float;
    let closestPosition: Vector4;
    let distanceSquared: Float;
    let navigationSystem: ref<AINavigationSystem>;
    let path: ref<NavigationPath>;
    let query: AINavigationSystemQuery;
    let queryId: Uint32;
    let result: AINavigationSystemResult;
    let sourceWorldPosition: WorldPosition;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPos: Vector4 = owner.GetWorldPosition();
    let investigationSources: array<Vector4> = stimEvent.movePositions;
    let i: Int32 = 0;
    while i < ArraySize(investigationSources) {
      distanceSquared = Vector4.DistanceSquared(investigationSources[i], ownerPos);
      path = GameInstance.GetAINavigationSystem(owner.GetGame()).CalculatePathForCharacter(ownerPos, investigationSources[i], 0.00, owner);
      if !IsDefined(path) {
      } else {
        if distanceSquared < closestDistanceSquared || closestDistanceSquared == 0.00 {
          closestDistanceSquared = distanceSquared;
          closestPosition = investigationSources[i];
        };
      };
      i += 1;
    };
    if !Vector4.IsZero(closestPosition) {
      return closestPosition;
    };
    if stimEvent.IsTagInStimuli(n"NavReach") {
      navigationSystem = GameInstance.GetAINavigationSystem(owner.GetGame());
      AIPositionSpec.SetEntity(query.source, this.GetEntity());
      WorldPosition.SetVector4(sourceWorldPosition, stimEvent.sourcePosition);
      AIPositionSpec.SetWorldPosition(query.target, sourceWorldPosition);
      queryId = navigationSystem.StartPathfinding(query);
      navigationSystem.GetResult(queryId, result);
      navigationSystem.StopPathfinding(queryId);
      if result.hasClosestReachablePoint {
        return WorldPosition.ToVector4(result.closestReachablePoint);
      };
    };
    return stimEvent.sourcePosition;
  }

  private final func TriggerCombatFromHostileStim(stimType: gamedataStimType) -> Bool {
    if this.GetOwnerPuppet().IsCharacterPolice() {
      return false;
    };
    if Equals(stimType, gamedataStimType.Gunshot) || Equals(stimType, gamedataStimType.Combat) || Equals(stimType, gamedataStimType.IllegalAction) || Equals(stimType, gamedataStimType.IllegalInteraction) || Equals(stimType, gamedataStimType.Bullet) || Equals(stimType, gamedataStimType.CarryBody) {
      return true;
    };
    return false;
  }

  private final func TriggerAlertedFromHostileStim(stimEvent: ref<StimuliEvent>) -> Bool {
    if this.GetOwnerPuppet().IsCharacterPolice() {
      return true;
    };
    if Equals(stimEvent.GetStimType(), gamedataStimType.CombatHit) {
      return true;
    };
    return false;
  }

  private final func IsSquadMateInDanger(reaction: gamedataOutput) -> Bool {
    let i: Int32;
    let member: ref<ScriptedPuppet>;
    let memberDesiredReaction: ref<AIReactionData>;
    let smi: ref<SquadScriptInterface>;
    let squadMembers: array<wref<Entity>>;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if !AISquadHelper.GetSquadMemberInterface(ownerPuppet, smi) {
      return false;
    };
    squadMembers = smi.ListMembersWeak();
    if ArraySize(squadMembers) <= 1 {
      return false;
    };
    i = 0;
    while i < ArraySize(squadMembers) {
      member = squadMembers[i] as ScriptedPuppet;
      if !ScriptedPuppet.IsActive(member) {
      } else {
        if member == ownerPuppet {
        } else {
          memberDesiredReaction = member.GetStimReactionComponent().GetDesiredReactionData();
          if IsDefined(memberDesiredReaction) && Equals(memberDesiredReaction.reactionBehaviorName, reaction) {
            if this.IsTargetVisible(member) {
              return true;
            };
          };
        };
      };
      i += 1;
    };
    return false;
  }

  private final func FirstSquadMemberReaction() -> Bool {
    let distance: Float;
    let i: Int32;
    let member: ref<ScriptedPuppet>;
    let memberDesiredReactionData: ref<AIReactionData>;
    let smi: ref<SquadScriptInterface>;
    let squadMembers: array<wref<Entity>>;
    let stimDistance: Float;
    let suitableSquadmate: ref<ScriptedPuppet>;
    if !AISquadHelper.GetSquadMemberInterface(this.GetOwnerPuppet(), smi) {
      return true;
    };
    squadMembers = smi.ListMembersWeak();
    if ArraySize(squadMembers) <= 1 {
      return true;
    };
    i = 0;
    while i < ArraySize(squadMembers) {
      member = squadMembers[i] as ScriptedPuppet;
      if !ScriptedPuppet.IsActive(member) {
      } else {
        memberDesiredReactionData = member.GetStimReactionComponent().GetDesiredReactionData();
        if IsDefined(this.m_desiredReaction) && NotEquals(member.GetStimReactionComponent().GetReceivedStimType(), this.m_desiredReaction.stimType) && IsDefined(memberDesiredReactionData) && NotEquals(memberDesiredReactionData.stimType, this.m_desiredReaction.stimType) {
        } else {
          stimDistance = Vector4.Distance(member.GetWorldPosition(), this.m_desiredReaction.stimSource);
          if stimDistance < distance || distance == 0.00 {
            suitableSquadmate = member;
            distance = stimDistance;
          };
        };
      };
      i += 1;
    };
    if IsDefined(suitableSquadmate) {
      return this.GetOwnerPuppet() == suitableSquadmate;
    };
    return true;
  }

  private func TriggerPendingReaction() -> Void {
    let crowdMemberComponent: ref<CrowdMemberBaseComponent>;
    let owner: ref<GameObject>;
    let triggerAIEvent: ref<StimuliEvent>;
    if !IsDefined(this.m_pendingReaction) {
      return;
    };
    owner = this.GetOwner();
    if this.m_pendingReaction.validTillTimeStamp > 0.00 && this.m_pendingReaction.validTillTimeStamp < EngineTime.ToFloat(GameInstance.GetSimTime(owner.GetGame())) {
      this.m_pendingReaction = null;
      return;
    };
    this.DeactiveLookAt();
    GameInstance.GetDelaySystem(owner.GetGame()).CancelDelay(this.m_resetReactionDataID);
    this.m_desiredReaction = new AIReactionData();
    this.m_desiredReaction.reactionBehaviorName = this.m_pendingReaction.reactionBehaviorName;
    this.m_desiredReaction.stimPriority = this.m_pendingReaction.stimPriority;
    this.m_desiredReaction.stimTarget = this.m_pendingReaction.stimTarget;
    this.m_desiredReaction.stimType = this.m_pendingReaction.stimType;
    this.m_desiredReaction.stimSource = this.m_pendingReaction.stimSource;
    this.m_desiredReaction.stimRecord = this.m_pendingReaction.stimRecord;
    this.m_desiredReaction.reactionPriority = this.m_pendingReaction.reactionPriority;
    this.m_desiredReaction.stimInvestigateData = this.m_pendingReaction.stimInvestigateData;
    this.m_desiredReaction.stimEventData = this.m_pendingReaction.stimEventData;
    this.m_desiredReaction.reactionBehaviorAIPriority = this.m_pendingReaction.reactionBehaviorAIPriority;
    this.m_desiredReaction.reactionCooldown = this.m_pendingReaction.reactionCooldown;
    if this.IsInitAnimShock(this.m_pendingReaction.reactionBehaviorName) {
      this.m_desiredReaction.initAnimInWorkspot = true;
      if this.m_previousFearPhase == 2 {
        this.m_previousFearPhase = 0;
      };
    };
    triggerAIEvent = new StimuliEvent();
    triggerAIEvent.SetStimType(gamedataStimType.Invalid);
    triggerAIEvent.name = n"triggerReaction";
    if Equals(this.m_pendingReaction.reactionBehaviorName, gamedataOutput.Flee) {
      NPCPuppet.ChangeHighLevelState(owner, gamedataNPCHighLevelState.Fear);
      this.DeactiveLookAt();
      this.ResetFacial(0.00);
      this.TriggerFearFacial(3);
      AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetRandomFearLocomotionAnimWrapper(3), 1.00);
      if this.m_inCrowd {
        crowdMemberComponent = this.GetOwnerPuppet().GetCrowdMemberComponent();
        crowdMemberComponent.SetThreatLastKnownPosition(this.m_desiredReaction.stimSource);
        crowdMemberComponent.ChangeMoveType(n"run");
        crowdMemberComponent.AllowWorkspotsUsage(false);
      };
    };
    owner.QueueEvent(triggerAIEvent);
    this.m_pendingReaction = null;
  }

  private final func TriggerReactionBehaviorForCrowd(stimEvent: ref<StimuliEvent>, reaction: gamedataOutput, initAnimInWorkspot: Bool) -> Void {
    let crowdMemberComponent: ref<CrowdMemberBaseComponent>;
    let triggerAIEvent: ref<StimuliEvent>;
    let stimData: stimInvestigateData = stimEvent.stimInvestigateData;
    this.m_desiredReaction = new AIReactionData();
    this.m_desiredReaction.reactionBehaviorName = reaction;
    this.m_desiredReaction.stimPriority = stimEvent.stimRecord.Priority().Type();
    this.m_desiredReaction.stimTarget = stimEvent.sourceObject;
    this.m_desiredReaction.stimType = stimEvent.GetStimType();
    this.m_desiredReaction.stimSource = this.GetStimSource(stimEvent);
    this.m_desiredReaction.stimRecord = stimEvent.stimRecord;
    this.m_desiredReaction.stimInvestigateData = stimData;
    this.m_desiredReaction.reactionBehaviorAIPriority = this.GetOutputPriority(reaction);
    if initAnimInWorkspot {
      this.m_desiredReaction.initAnimInWorkspot = initAnimInWorkspot;
    } else {
      this.m_desiredReaction.initAnimInWorkspot = stimData.skipInitialAnimation;
    };
    triggerAIEvent = new StimuliEvent();
    triggerAIEvent.SetStimType(gamedataStimType.Invalid);
    triggerAIEvent.name = n"triggerReaction";
    if this.IsInPendingBehavior() && (NotEquals(reaction, gamedataOutput.Flee) || Equals(reaction, gamedataOutput.Flee) && Equals(stimEvent.GetStimType(), gamedataStimType.HijackVehicle)) {
      this.m_pendingReaction = this.m_desiredReaction;
      this.m_pendingReaction.validTillTimeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame())) + TweakDBInterface.GetFloat(t"AIGeneralSettings.pendingReactionValidTimeStamp", 10.00);
      this.m_desiredFearPhase = -1;
      this.m_desiredReaction = null;
    } else {
      this.GetOwner().QueueEvent(triggerAIEvent);
      if this.m_inCrowd {
        crowdMemberComponent = this.GetOwnerPuppet().GetCrowdMemberComponent();
        crowdMemberComponent.SetThreatLastKnownPosition(this.m_desiredReaction.stimSource);
        crowdMemberComponent.AllowWorkspotsUsage(false);
        crowdMemberComponent.ChangeFearStage(this.m_crowdFearStage, !stimData.skipInitialAnimation);
      };
    };
  }

  private final func TriggerReactionBehaviorForCrowd(target: ref<GameObject>, reaction: gamedataOutput, initAnimInWorkspot: Bool, opt sourcePosition: Vector4) -> Void {
    let crowdMemberComponent: ref<CrowdMemberBaseComponent>;
    let triggerAIEvent: ref<StimuliEvent>;
    this.m_desiredReaction = new AIReactionData();
    this.m_desiredReaction.reactionBehaviorName = reaction;
    this.m_desiredReaction.stimTarget = target;
    if Vector4.IsZero(sourcePosition) {
      this.m_desiredReaction.stimSource = target.GetWorldPosition();
    } else {
      this.m_desiredReaction.stimSource = sourcePosition;
    };
    this.m_desiredReaction.reactionBehaviorAIPriority = this.GetOutputPriority(reaction);
    this.m_desiredReaction.initAnimInWorkspot = initAnimInWorkspot;
    triggerAIEvent = new StimuliEvent();
    triggerAIEvent.SetStimType(gamedataStimType.Invalid);
    triggerAIEvent.name = n"triggerReaction";
    if this.IsInPendingBehavior() {
      this.m_pendingReaction = this.m_desiredReaction;
      this.m_pendingReaction.validTillTimeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame())) + TweakDBInterface.GetFloat(t"AIGeneralSettings.pendingReactionValidTimeStamp", 10.00);
      this.m_desiredReaction = null;
    } else {
      this.GetOwner().QueueEvent(triggerAIEvent);
      if Equals(reaction, gamedataOutput.Bump) && IsDefined(this.m_activeReaction) && (Equals(this.m_activeReaction.reactionBehaviorName, gamedataOutput.Bump) || Equals(this.m_activeReaction.reactionBehaviorName, gamedataOutput.BackOff)) {
        this.m_desiredReaction.escalateProvoke = true;
      };
      if this.m_inCrowd {
        if NotEquals(this.m_crowdFearStage, gameFearStage.Relaxed) {
          crowdMemberComponent = this.GetOwnerPuppet().GetCrowdMemberComponent();
          crowdMemberComponent.SetThreatLastKnownPosition(this.m_desiredReaction.stimSource);
          crowdMemberComponent.AllowWorkspotsUsage(false);
          crowdMemberComponent.ChangeFearStage(this.m_crowdFearStage, false);
        } else {
          if Equals(reaction, gamedataOutput.CallPolice) {
            crowdMemberComponent.TryStopTrafficMovement();
          };
        };
      };
    };
  }

  protected cb func OnDelayStimEvent(evt: ref<DelayStimEvent>) -> Bool {
    if this.IsPlayerAiming() && evt.stimEvent.sourceObject.IsPlayer() && this.IsTargetDetected(evt.stimEvent.sourceObject) && this.IsReactionAvailableInPreset(gamedataStimType.AimingAt) {
      if AIActionHelper.TryChangingAttitudeToHostile(this.GetOwnerPuppet(), evt.stimEvent.sourceObject) {
        TargetTrackingExtension.InjectThreat(this.GetOwnerPuppet(), evt.stimEvent.sourceObject);
      };
    };
  }

  private final func ProcessEnvironmentalHazard(stimEvent: ref<StimuliEvent>) -> Void {
    let i: Int32;
    if this.m_inCrowd {
      return;
    };
    if IsDefined(stimEvent.sourceObject) {
      if !this.IsTargetInFront(stimEvent.sourceObject) {
        return;
      };
      if !this.IsTargetClose(stimEvent.sourceObject, stimEvent.radius) {
        return;
      };
    } else {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_environmentalHazards) {
      if this.m_environmentalHazards[i].sourceObject == stimEvent.sourceObject {
        GameInstance.GetDelaySystem(this.GetOwner().GetGame()).CancelDelay(this.m_environmentalHazardsDelayIDs[i]);
        this.m_environmentalHazards[i] = stimEvent;
        this.m_environmentalHazardsDelayIDs[i] = this.DelayEnvironmentalHazardEvent(stimEvent);
        return;
      };
      i += 1;
    };
    ArrayPush(this.m_environmentalHazards, stimEvent);
    ArrayPush(this.m_environmentalHazardsDelayIDs, this.DelayEnvironmentalHazardEvent(stimEvent));
  }

  private final func DelayEnvironmentalHazardEvent(stimEvent: ref<StimuliEvent>) -> DelayID {
    let cleanEnvironmentalHazardEvent: ref<CleanEnvironmentalHazardEvent> = new CleanEnvironmentalHazardEvent();
    cleanEnvironmentalHazardEvent.stimEvent = stimEvent;
    return GameInstance.GetDelaySystem(this.GetOwner().GetGame()).DelayEvent(this.GetOwner(), cleanEnvironmentalHazardEvent, 2.00);
  }

  protected cb func OnCleanEnvironmentalHazardEvent(cleanEnvironmentalHazardEvent: ref<CleanEnvironmentalHazardEvent>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_environmentalHazards) {
      if this.m_environmentalHazards[i] == cleanEnvironmentalHazardEvent.stimEvent {
        ArrayRemove(this.m_environmentalHazards, this.m_environmentalHazards[i]);
        ArrayRemove(this.m_environmentalHazardsDelayIDs, this.m_environmentalHazardsDelayIDs[i]);
      };
      i += 1;
    };
  }

  private final func InitCrowd() -> Void {
    this.m_exitWorkspotAim = TweakDBInterface.GetVector2(t"AIGeneralSettings.workspotReactionExitDelay", new Vector2(3.00, 5.00));
    this.m_fearToIdleDistance = TweakDBInterface.GetVector2(t"AIGeneralSettings.fearToIdleDistance", new Vector2(15.00, 5.00));
    this.m_crowdAimingReactionDistance = TweakDBInterface.GetFloat(t"AIGeneralSettings.crowdAimingReactionDistance", 20.00);
    this.m_fearInPlaceAroundDistance = TweakDBInterface.GetFloat(t"AIGeneralSettings.fearInPlaceAroundDistance", 20.00);
  }

  private final func ShouldStimBeProcessedByCrowd(stimEvent: ref<StimuliEvent>) -> Bool {
    let fearReactionPhase: Int32;
    let vehicle: ref<VehicleObject>;
    let owner: ref<GameObject> = this.GetOwner();
    let stimType: gamedataStimType = stimEvent.GetStimType();
    if !this.m_initCrowd {
      this.InitCrowd();
      this.m_initCrowd = true;
    };
    if (!this.m_inCrowd || Equals(stimType, gamedataStimType.AimingAt)) && this.SourceAttitude(stimEvent.sourceObject, EAIAttitude.AIA_Friendly) {
      return false;
    };
    if (owner as NPCPuppet).IsRagdolling() {
      return false;
    };
    if !this.CanReactInVehicle(stimEvent) {
      return false;
    };
    if Equals(stimEvent.stimPropagation, gamedataStimPropagation.Visual) {
      if !this.IsTargetInFront(stimEvent.sourceObject) {
        return false;
      };
      if !this.IsTargetClose(stimEvent.sourceObject) {
        return false;
      };
      if !this.TargetVerticalCheck(stimEvent.sourceObject) {
        return false;
      };
      if GameInstance.GetWorkspotSystem(owner.GetGame()).IsActorInWorkspot(owner) {
        if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Braindance") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Sleep") {
          return false;
        };
      };
    };
    if this.m_desiredFearPhase > -1 || IsDefined(this.m_activeReaction) || NotEquals(this.m_crowdFearStage, gameFearStage.Relaxed) || this.m_inReactionSequence && GameInstance.GetWorkspotSystem(owner.GetGame()).IsActorInWorkspot(owner) {
      if Equals(stimType, gamedataStimType.CombatHit) {
        if FromVariant(this.GetOwnerPuppet().GetAIControllerComponent().GetBehaviorArgument(n"InFearInPlace")) {
          GameObject.PlayVoiceOver(owner, n"fear_beg", n"Scripts:ShouldStimBeProcessedByCrowd", true);
        } else {
          if Equals(PlayerPuppet.GetCurrentCombatState(stimEvent.sourceObject as PlayerPuppet), gamePSMCombat.InCombat) {
            return true;
          };
        };
      };
      fearReactionPhase = this.GetFearReactionPhase(stimEvent);
      if this.m_desiredFearPhase >= fearReactionPhase {
        return false;
      };
      if !this.ShouldInterruptCurrentFearStage(fearReactionPhase) {
        return false;
      };
    };
    if !stimEvent.IsTagInStimuli(n"CrowdReaction") && !stimEvent.IsTagInStimuli(n"ChildDanger") {
      return false;
    };
    if Equals(stimType, gamedataStimType.CrowdIllegalAction) && StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"LoreVictimSaved") {
      return false;
    };
    if Equals(stimType, gamedataStimType.CrowdIllegalAction) && StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"LoreVictimSaved") {
      return false;
    };
    if Equals(stimType, gamedataStimType.Driving) && IsDefined(stimEvent.sourceObject as VehicleObject) {
      if !(stimEvent.sourceObject as VehicleObject).IsOnPavement() {
        return false;
      };
      if !this.IsTargetInFront(stimEvent.sourceObject, 30.00, true) && !this.IsTargetBehind(stimEvent.sourceObject, 160.00, true) && !this.IsTargetClose(stimEvent.sourceObject, 10.00) {
        return false;
      };
      vehicle = stimEvent.sourceObject as VehicleObject;
      if IsDefined(vehicle) {
        if vehicle.GetCurrentSpeed() < 8.00 {
          return false;
        };
      };
    };
    return true;
  }

  private final func HandleCrowdReaction(stimEvent: ref<StimuliEvent>) -> Void {
    let delayedCrowdReaction: ref<DelayedCrowdReactionEvent>;
    let mountInfo: MountingInfo;
    let stimAttackData: stimInvestigateData;
    let vehicleReactionEvent: ref<HandleReactionEvent>;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    if Equals(this.m_reactionPreset.Type(), gamedataReactionPresetType.Child) && stimEvent.IsTagInStimuli(n"ChildDanger") {
      this.m_desiredFearPhase = 3;
      this.DeactiveLookAt();
      stimAttackData = stimEvent.stimInvestigateData;
      if IsDefined(stimAttackData.attackInstigator) {
        stimEvent.sourceObject = stimAttackData.attackInstigator as GameObject;
        stimEvent.sourcePosition = stimEvent.sourceObject.GetWorldPosition();
      };
      this.ActivateReactionLookAt(stimEvent.sourceObject, false);
      delayedCrowdReaction = new DelayedCrowdReactionEvent();
      delayedCrowdReaction.stimEvent = stimEvent;
      owner.QueueEvent(delayedCrowdReaction);
    } else {
      if VehicleComponent.IsMountedToVehicle(game, owner) && NotEquals(stimEvent.GetStimType(), gamedataStimType.HijackVehicle) && NotEquals(stimEvent.GetStimType(), gamedataStimType.Dying) {
        NPCPuppet.ChangeHighLevelState(owner, gamedataNPCHighLevelState.Fear);
        mountInfo = GameInstance.GetMountingFacility(game).GetMountingInfoSingleWithObjects(owner);
        this.m_previousFearPhase = this.ConvertFearStageToFearPhase(this.m_crowdFearStage);
        vehicleReactionEvent = new HandleReactionEvent();
        vehicleReactionEvent.fearPhase = this.GetFearReactionPhase(stimEvent);
        vehicleReactionEvent.stimEvent = stimEvent;
        GameInstance.FindEntityByID(game, mountInfo.parentId).QueueEvent(vehicleReactionEvent);
      } else {
        this.m_previousFearPhase = this.ConvertFearStageToFearPhase(this.m_crowdFearStage);
        this.m_desiredFearPhase = this.GetFearReactionPhase(stimEvent);
        if VehicleComponent.IsMountedToVehicle(game, owner) && Equals(stimEvent.GetStimType(), gamedataStimType.HijackVehicle) {
          GameObject.PlayVoiceOver(owner, n"fear_beg", n"Scripts:HandleCrowdReaction", true);
        };
        GameInstance.GetReactionSystem(game).AddFearSource(stimEvent.sourceObject);
        this.DeactiveLookAt();
        stimAttackData = stimEvent.stimInvestigateData;
        if IsDefined(stimAttackData.attackInstigator) {
          stimEvent.sourceObject = stimAttackData.attackInstigator as GameObject;
          stimEvent.sourcePosition = stimEvent.sourceObject.GetWorldPosition();
        };
        this.ActivateReactionLookAt(stimEvent.sourceObject, false);
        delayedCrowdReaction = new DelayedCrowdReactionEvent();
        delayedCrowdReaction.stimEvent = stimEvent;
        if this.m_desiredFearPhase == -1 {
          return;
        };
        if !stimAttackData.skipReactionDelay {
          this.m_delayReactionEventID = GameInstance.GetDelaySystem(game).DelayEvent(owner, delayedCrowdReaction, RandRangeF(this.m_delay.X, this.m_delay.Y));
        } else {
          owner.QueueEvent(delayedCrowdReaction);
        };
      };
    };
  }

  protected cb func OnCrowdReaction(reactionDelayEvent: ref<DelayedCrowdReactionEvent>) -> Bool {
    let blackboard: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    let broadcaster: ref<StimBroadcasterComponent>;
    let crowdMemberComponent: ref<CrowdMemberComponent>;
    let exitWorkspot: ref<ExitWorkspotSequenceEvent>;
    let fearPhase: Int32;
    let game: GameInstance;
    let pointResults: NavigationFindPointResult;
    let stimType: gamedataStimType;
    let workspotSystem: ref<WorkspotGameSystem>;
    let owner: ref<GameObject> = this.GetOwner();
    let stimData: stimInvestigateData = reactionDelayEvent.stimEvent.stimInvestigateData;
    if !ScriptedPuppet.IsActive(owner) {
      return false;
    };
    game = owner.GetGame();
    stimType = reactionDelayEvent.stimEvent.GetStimType();
    crowdMemberComponent = this.GetOwnerPuppet().GetCrowdMemberComponent();
    crowdMemberComponent.OnCrowdReaction(stimType);
    if Equals(stimType, gamedataStimType.AimingAt) {
      blackboardSystem = GameInstance.GetBlackboardSystem(game);
      blackboard = blackboardSystem.GetLocalInstanced(this.GetPlayerSystem().GetLocalPlayerMainGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) {
        blackboard = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_TargetingInfo);
        if blackboard.GetEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget) != owner.GetEntityID() && NotEquals(this.m_reactionPreset.Type(), gamedataReactionPresetType.InVehicle_Civilian) {
          this.DeactiveLookAt();
          this.m_desiredFearPhase = -1;
          return IsDefined(null);
        };
      } else {
        this.DeactiveLookAt();
        this.m_desiredFearPhase = -1;
        return IsDefined(null);
      };
    };
    GameInstance.GetDelaySystem(game).CancelDelay(this.m_callingPoliceID);
    fearPhase = this.GetFearReactionPhase(reactionDelayEvent.stimEvent);
    if reactionDelayEvent.vehicleFearPhase > 0 {
      fearPhase = reactionDelayEvent.vehicleFearPhase;
    };
    workspotSystem = GameInstance.GetWorkspotSystem(game);
    crowdMemberComponent.SetThreatLastKnownPosition(this.GetStimSource(reactionDelayEvent.stimEvent));
    crowdMemberComponent.AllowWorkspotsUsage(false);
    NPCPuppet.ChangeHighLevelState(owner, gamedataNPCHighLevelState.Fear);
    this.DeactiveLookAt();
    this.ResetFacial(0.00);
    this.TriggerFearFacial(fearPhase);
    if workspotSystem.IsActorInWorkspot(owner) {
      AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetFearAnimWrapper(fearPhase), 1.00);
      if fearPhase != 0 && (!this.m_fearLocomotionWrapper || fearPhase == 3) {
        AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetRandomFearLocomotionAnimWrapper(fearPhase, stimType), 1.00);
      };
      this.m_fearLocomotionWrapper = true;
      switch fearPhase {
        case 0:
          this.TriggerFacialLookAtReaction(true, true);
          break;
        case 1:
          pointResults = GameInstance.GetAINavigationSystem(game).FindPointInSphereForCharacter(owner.GetWorldPosition(), 0.50, owner);
          if this.IsTargetClose(reactionDelayEvent.stimEvent.sourceObject, 3.00) && this.IsTargetInFront(reactionDelayEvent.stimEvent.sourceObject) && workspotSystem.IsReactionAvailable(owner, n"Fear") && NotEquals(stimType, gamedataStimType.Bump) {
            this.ActivateReactionLookAt(reactionDelayEvent.stimEvent.sourceObject, false, false, true);
            workspotSystem.SendReactionSignal(owner, n"Fear");
            this.m_inReactionSequence = true;
            GameObject.PlayVoiceOver(owner, n"fear_beg", n"Scripts:OnDelayedReaction");
            exitWorkspot = new ExitWorkspotSequenceEvent();
            this.m_exitWorkspotSequenceEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, exitWorkspot, 3.00);
          } else {
            if Equals(pointResults.status, worldNavigationRequestStatus.OK) {
              this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.WalkAway, false);
            } else {
              if workspotSystem.IsReactionAvailable(owner, n"Fear") && NotEquals(stimType, gamedataStimType.Bump) {
                this.ActivateReactionLookAt(reactionDelayEvent.stimEvent.sourceObject, false, false, true);
                workspotSystem.SendReactionSignal(owner, n"Fear");
                this.m_inReactionSequence = true;
                GameObject.PlayVoiceOver(owner, n"fear_beg", n"Scripts:OnDelayedReaction");
                exitWorkspot = new ExitWorkspotSequenceEvent();
                this.m_exitWorkspotSequenceEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, exitWorkspot, 3.00);
              } else {
                this.TriggerFacialLookAtReaction(true, true);
              };
            };
          };
          break;
        case 2:
          if workspotSystem.IsReactionAvailable(owner, n"Fear") {
            this.ActivateReactionLookAt(reactionDelayEvent.stimEvent.sourceObject, false, false, true);
            workspotSystem.SendReactionSignal(owner, n"Fear");
            this.m_inReactionSequence = true;
            GameObject.PlayVoiceOver(owner, n"fear_beg", n"Scripts:OnDelayedReaction");
            exitWorkspot = new ExitWorkspotSequenceEvent();
            this.m_exitWorkspotSequenceEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, exitWorkspot, 3.00);
          } else {
            if !this.m_inReactionSequence {
              if fearPhase == 3 {
                this.SetCrowdRunningAwayAnimFeature(stimType);
                this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Flee, false);
              } else {
                this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Surrender, false);
              };
            };
          };
          break;
        case 3:
          if !workspotSystem.HasExitNodes(owner, true, false, true) && (workspotSystem.IsReactionAvailable(owner, n"Fear") || this.m_inReactionSequence) {
            this.ActivateReactionLookAt(reactionDelayEvent.stimEvent.sourceObject, false, false, true);
            workspotSystem.SendReactionSignal(owner, n"Fear");
            this.m_inReactionSequence = true;
            GameObject.PlayVoiceOver(owner, n"fear_beg", n"Scripts:OnDelayedReaction");
            exitWorkspot = new ExitWorkspotSequenceEvent();
            this.m_exitWorkspotSequenceEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, exitWorkspot, 3.00);
          } else {
            if this.ShouldFearInPlace(reactionDelayEvent.stimEvent) {
              this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.FearInPlace, true);
            } else {
              if this.m_previousFearPhase > 1 || workspotSystem.HasExitNodes(owner, true, false) {
                this.SetCrowdRunningAwayAnimFeature(stimType);
                this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Flee, true);
              } else {
                this.SetCrowdRunningAwayAnimFeature(stimType);
                this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Flee, false);
              };
            };
          };
      };
    } else {
      if this.m_inTrafficLane {
        this.GetOwnerPuppet().GetAIControllerComponent().SetBehaviorArgument(n"StimTarget", ToVariant(reactionDelayEvent.stimEvent.sourceObject));
        if fearPhase != 0 && (!this.m_fearLocomotionWrapper || fearPhase == 3) {
          AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetRandomFearLocomotionAnimWrapper(fearPhase, stimType), 1.00);
        };
        this.m_fearLocomotionWrapper = true;
        switch fearPhase {
          case 0:
            this.TriggerFacialLookAtReaction(true, true);
            break;
          case 1:
            this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.WalkAway, true);
            break;
          case 2:
            crowdMemberComponent.TryStopTrafficMovement();
            this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Surrender, true);
            break;
          case 3:
            if this.ShouldFearInPlace(reactionDelayEvent.stimEvent) {
              crowdMemberComponent.TryStopTrafficMovement();
              this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.FearInPlace, true);
            } else {
              this.SetCrowdRunningAwayAnimFeature(stimType);
              this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Flee, true);
            };
        };
      } else {
        AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetFearAnimWrapper(fearPhase), 1.00);
        if fearPhase != 0 && (!this.m_fearLocomotionWrapper || fearPhase == 3) {
          AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, this.GetRandomFearLocomotionAnimWrapper(fearPhase, stimType), 1.00);
        };
        this.m_fearLocomotionWrapper = true;
        switch fearPhase {
          case 0:
            this.TriggerFacialLookAtReaction(true, true);
            break;
          case 1:
            pointResults = GameInstance.GetAINavigationSystem(game).FindPointInSphereForCharacter(owner.GetWorldPosition(), 0.50, owner);
            if Equals(pointResults.status, worldNavigationRequestStatus.OK) {
              this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.WalkAway, false);
            } else {
              this.TriggerFacialLookAtReaction(true, true);
            };
            break;
          case 2:
            this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Surrender, true);
            break;
          case 3:
            if this.ShouldFearInPlace(reactionDelayEvent.stimEvent) {
              this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.FearInPlace, true);
            } else {
              if this.m_previousFearPhase > 1 {
                this.SetCrowdRunningAwayAnimFeature(stimType);
                this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Flee, true);
              } else {
                this.SetCrowdRunningAwayAnimFeature(stimType);
                this.TriggerReactionBehaviorForCrowd(reactionDelayEvent.stimEvent, gamedataOutput.Flee, false);
              };
            };
        };
      };
    };
    switch fearPhase {
      case 1:
        this.m_crowdFearStage = gameFearStage.Stressed;
        break;
      case 2:
        this.m_crowdFearStage = gameFearStage.Alarmed;
        break;
      case 3:
        this.m_crowdFearStage = gameFearStage.Panic;
        crowdMemberComponent.SetThreatLastKnownPosition(reactionDelayEvent.stimEvent.sourcePosition);
        crowdMemberComponent.ChangeMoveType(n"run");
        break;
      default:
        this.m_crowdFearStage = gameFearStage.Relaxed;
    };
    crowdMemberComponent.ChangeFearStage(this.m_crowdFearStage, !stimData.skipInitialAnimation);
    if reactionDelayEvent.stimEvent.sourceObject == this.GetPlayerSystem().GetLocalPlayerMainGameObject() && !reactionDelayEvent.stimEvent.IsTagInStimuli(n"NoFearSpread") && NotEquals(this.m_reactionPreset.Type(), gamedataReactionPresetType.Child) {
      if fearPhase > 1 {
        this.SpreadFear(reactionDelayEvent.stimEvent.sourceObject, fearPhase);
      } else {
        if Equals(stimType, gamedataStimType.SpreadFear) {
          this.SpreadFear(owner, fearPhase);
        };
      };
    } else {
      if Equals(stimType, gamedataStimType.HijackVehicle) {
        broadcaster = reactionDelayEvent.stimEvent.sourceObject.GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          broadcaster.TriggerSingleBroadcast(owner, gamedataStimType.CrimeWitness);
        };
      };
    };
    this.m_desiredFearPhase = -1;
  }

  private final func SpreadFear(instigator: ref<GameObject>, phase: Int32) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let stimData: stimInvestigateData;
    let owner: ref<GameObject> = this.GetOwner();
    if !GameObject.IsCooldownActive(instigator, n"spreadFearCooldown") {
      GameObject.StartCooldown(instigator, n"spreadFearCooldown", 3.00);
      broadcaster = instigator.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        if !instigator.IsPlayer() {
          stimData.fearPhase = 1;
          broadcaster.AddActiveStimuli(owner, gamedataStimType.SpreadFear, 3.00, 3.00, stimData, true);
        } else {
          if phase == 3 {
            stimData.fearPhase = 3;
            broadcaster.TriggerSingleBroadcast(owner, gamedataStimType.SpreadFear, 50.00, stimData);
            broadcaster.AddActiveStimuli(owner, gamedataStimType.SpreadFear, 4.00, 30.00, stimData, true);
          } else {
            stimData.fearPhase = 1;
            broadcaster.TriggerSingleBroadcast(owner, gamedataStimType.SpreadFear, 5.00, stimData);
            broadcaster.AddActiveStimuli(owner, gamedataStimType.SpreadFear, 3.00, 10.00, stimData, true);
          };
        };
      };
    };
  }

  private final func ShouldFearInPlace(stimEvent: ref<StimuliEvent>) -> Bool {
    let player: ref<PlayerPuppet>;
    let weapon: ref<WeaponObject>;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    if VehicleComponent.IsMountedToVehicle(game, owner) {
      return false;
    };
    player = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if VehicleComponent.IsMountedToVehicle(game, player) {
      return false;
    };
    if stimEvent.IsTagInStimuli(n"TryRunAway") {
      return false;
    };
    weapon = GameObject.GetActiveWeapon(player);
    if weapon.IsMelee() {
      return false;
    };
    if Equals(PlayerPuppet.GetCurrentCombatState(player), gamePSMCombat.InCombat) {
      if Equals(stimEvent.GetStimType(), gamedataStimType.CombatHit) {
        return true;
      };
      if this.GetThreatDistanceSquared(stimEvent.sourceObject) < this.m_fearInPlaceAroundDistance * this.m_fearInPlaceAroundDistance {
        return true;
      };
    };
    return false;
  }

  private final func TriggerFacialLookAtReaction(opt forceFear: Bool, opt playVO: Bool) -> Void {
    let lookAtData: LookAtData;
    let vo: CName;
    let facialReactionAnimFeature: ref<AnimFeature_FacialReaction> = new AnimFeature_FacialReaction();
    let target: ref<GameObject> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject();
    if !this.m_inCrowd {
      playVO = true;
      facialReactionAnimFeature.category = 3;
      facialReactionAnimFeature.idle = 1;
      this.m_facialCooldown = 2.00;
      vo = n"greeting";
      this.ActivateReactionLookAt(target, false);
    } else {
      if forceFear || this.IsTargetArmed(target) {
        facialReactionAnimFeature.category = 3;
        facialReactionAnimFeature.idle = 10;
        this.ActivateReactionLookAt(target, false);
        this.m_facialCooldown = 5.00;
      } else {
        if (target as PlayerPuppet).IsNaked() {
          facialReactionAnimFeature.category = 3;
          facialReactionAnimFeature.idle = 7;
          vo = n"fear_foll";
          this.ActivateReactionLookAt(target, true);
          this.m_facialCooldown = 5.00;
        } else {
          this.SelectFacialEmotion(lookAtData);
          vo = n"greeting";
          this.ActivateReactionLookAt(target, true, true);
          facialReactionAnimFeature.category = lookAtData.category;
          facialReactionAnimFeature.idle = lookAtData.idle;
          this.m_facialCooldown = 2.00;
        };
      };
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"FacialReaction", facialReactionAnimFeature);
    if !this.GetOwnerPuppet().IsVendor() && playVO {
      GameObject.PlayVoiceOver(this.GetOwner(), vo, n"Scripts:TriggerLookAtReaction");
    };
  }

  private final func TriggerFearFacial(phase: Int32) -> Void {
    let facialReactionAnimFeature: ref<AnimFeature_FacialReaction> = new AnimFeature_FacialReaction();
    facialReactionAnimFeature.category = 3;
    switch phase {
      case 1:
        facialReactionAnimFeature.idle = 10;
        break;
      case 2:
        facialReactionAnimFeature.idle = 11;
        break;
      case 3:
        facialReactionAnimFeature.idle = 9;
        break;
      default:
        facialReactionAnimFeature.idle = 10;
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"FacialReaction", facialReactionAnimFeature);
  }

  private final func ResetFacial(cooldown: Float) -> Void {
    let facialReactionAnimFeature: ref<AnimFeature_FacialReaction>;
    let facialResetEvent: ref<ResetFacialEvent>;
    if cooldown > 0.00 {
      GameInstance.GetDelaySystem(this.GetOwner().GetGame()).CancelDelay(this.m_resetFacialEventId);
      facialResetEvent = new ResetFacialEvent();
      this.m_resetFacialEventId = this.GetDelaySystem().DelayEvent(this.GetOwner(), facialResetEvent, cooldown);
    } else {
      facialReactionAnimFeature = new AnimFeature_FacialReaction();
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"FacialReaction", facialReactionAnimFeature);
    };
  }

  protected cb func OnResetLookatReactionEvent(evt: ref<ResetLookatReactionEvent>) -> Bool {
    this.DeactiveLookAt();
    this.ResetFacial(this.m_facialCooldown);
  }

  protected cb func OnResetFacialEvent(evt: ref<ResetFacialEvent>) -> Bool {
    this.m_facialCooldown = 0.00;
    let facialReactionAnimFeature: ref<AnimFeature_FacialReaction> = new AnimFeature_FacialReaction();
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"FacialReaction", facialReactionAnimFeature);
  }

  private final func CanTriggerExpressionLookAt() -> Bool {
    let sceneSystem: ref<SceneSystemInterface>;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if !ScriptedPuppet.IsAlive(owner) || StatusEffectSystem.ObjectHasStatusEffect(owner, t"BaseStatusEffect.Unconscious") {
      return false;
    };
    if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) || Equals(this.m_highLevelState, gamedataNPCHighLevelState.Alerted) {
      return false;
    };
    if (ownerPuppet as NPCPuppet).IsRagdolling() {
      return false;
    };
    if ScriptedPuppet.IsBlinded(ownerPuppet) {
      return false;
    };
    if Equals(this.m_reactionPreset.Type(), gamedataReactionPresetType.NoReaction) || Equals(this.m_reactionPreset.Type(), gamedataReactionPresetType.Follower) {
      return false;
    };
    if ownerPuppet.IsBoss() {
      return false;
    };
    if this.m_inReactionSequence || Equals(this.m_crowdFearStage, gameFearStage.Alarmed) || Equals(this.m_crowdFearStage, gameFearStage.Panic) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"LoreAnim") {
      return false;
    };
    if GameInstance.GetWorkspotSystem(owner.GetGame()).IsActorInWorkspot(owner) {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Braindance") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Sleep") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Busy") {
        return false;
      };
    };
    sceneSystem = GameInstance.GetSceneSystem(owner.GetGame()).GetScriptInterface();
    if IsDefined(sceneSystem) && (sceneSystem.IsEntityInDialogue(owner.GetEntityID()) || sceneSystem.IsEntityInScene(owner.GetEntityID())) {
      return false;
    };
    if !ownerPuppet.IsOnAutonomousAI() {
      return false;
    };
    return true;
  }

  private final func IsPlayerFearThreat() -> Bool {
    if this.IsTargetArmed(this.GetPlayerSystem().GetLocalPlayerControlledGameObject()) {
      return true;
    };
    if this.IsPlayerCarryingBody(this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet) {
      return true;
    };
    return false;
  }

  private final const func IsPlayerCarryingBody(playerPuppet: wref<PlayerPuppet>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    if !IsDefined(playerPuppet) {
      return false;
    };
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(playerPuppet.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return playerStateMachineBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
  }

  private final func SetCrowdRunningAwayAnimFeature(stimType: gamedataStimType) -> Void {
    let crowdRunningAwayAnimFeature: ref<AnimFeature_CrowdRunningAway> = new AnimFeature_CrowdRunningAway();
    if Equals(stimType, gamedataStimType.Driving) {
      crowdRunningAwayAnimFeature.isRunningAwayFromPlayersCar = true;
    } else {
      crowdRunningAwayAnimFeature.isRunningAwayFromPlayersCar = false;
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"CrowdRunningAway", crowdRunningAwayAnimFeature);
  }

  private final func SafeToExitFear() -> Bool {
    let distanceToPlayer: Float;
    if this.IsPlayerFearThreat() {
      distanceToPlayer = Vector4.DistanceSquared(this.GetOwner().GetWorldPosition(), this.GetPlayerSystem().GetLocalPlayerControlledGameObject().GetWorldPosition());
      if this.IsTargetInFront(this.GetPlayerSystem().GetLocalPlayerControlledGameObject(), 120.00) {
        if distanceToPlayer < this.m_fearToIdleDistance.X * this.m_fearToIdleDistance.X {
          return false;
        };
      } else {
        if distanceToPlayer < this.m_fearToIdleDistance.Y * this.m_fearToIdleDistance.Y {
          return false;
        };
      };
    };
    return true;
  }

  private final func SafeToExitPanicFear() -> Bool {
    let simTime: Float;
    let distanceToPlayer: Float = Vector4.DistanceSquared(this.GetOwner().GetWorldPosition(), this.GetPlayerSystem().GetLocalPlayerControlledGameObject().GetWorldPosition());
    if !CameraSystemHelper.IsInCameraFrustum(this.GetOwner(), 2.00, 0.75) {
      if distanceToPlayer > 25.00 * 25.00 {
        simTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame()));
        if this.m_successfulFearDeescalation == 0.00 {
          this.m_successfulFearDeescalation = simTime + 1.50;
        };
        if this.m_successfulFearDeescalation <= simTime {
          return true;
        };
        return false;
      };
    } else {
      if distanceToPlayer > 45.00 * 45.00 {
        simTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame()));
        if this.m_successfulFearDeescalation == 0.00 {
          this.m_successfulFearDeescalation = simTime + 0.50;
        };
        if this.m_successfulFearDeescalation >= simTime {
          return true;
        };
        return false;
      };
    };
    this.m_successfulFearDeescalation = 0.00;
    return false;
  }

  private final func SurrenderToLeave() -> Bool {
    let target: ref<GameObject> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject();
    let targetPos: Vector4 = target.GetWorldPosition();
    let ownerPos: Vector4 = this.GetOwner().GetWorldPosition();
    let direction: Vector4 = targetPos - ownerPos;
    let angleToTarget: Float = Vector4.GetAngleDegAroundAxis(direction, this.GetOwner().GetWorldForward(), this.GetOwner().GetWorldUp());
    if AbsF(angleToTarget) > 120.00 {
      return true;
    };
    direction = ownerPos - targetPos;
    angleToTarget = Vector4.GetAngleDegAroundAxis(direction, target.GetWorldForward(), target.GetWorldUp());
    if AbsF(angleToTarget) > 10.00 {
      return true;
    };
    return false;
  }

  private final func CanTriggerReprimandOrder() -> Bool {
    let record: ref<IPrereq_Record>;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    let reprimandAbility: ref<GameplayAbility_Record> = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanAskToFollowOrder");
    let prereqCount: Int32 = reprimandAbility.GetPrereqsForUseCount();
    let i: Int32 = 0;
    while i < prereqCount {
      record = reprimandAbility.GetPrereqsForUseItem(i);
      if IPrereq.CreatePrereq(record.GetID()).IsFulfilled(game, owner) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func CanAskToHolsterWeapon() -> Bool {
    let record: ref<IPrereq_Record>;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    let reprimandAbility: ref<GameplayAbility_Record> = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanAskToHolsterWeapon");
    let prereqCount: Int32 = reprimandAbility.GetPrereqsForUseCount();
    let i: Int32 = 0;
    while i < prereqCount {
      record = reprimandAbility.GetPrereqsForUseItem(i);
      if IPrereq.CreatePrereq(record.GetID()).IsFulfilled(game, owner) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func NotifySecuritySystem(stimType: gamedataStimType, stimObject: ref<GameObject>) -> Void {
    if Equals(stimType, gamedataStimType.DeadBody) {
      this.GetOwnerPuppet().TriggerSecuritySystemNotification(stimObject.GetWorldPosition(), stimObject, ESecurityNotificationType.ALARM, stimType);
    };
  }

  private final func SetWarningMessage(lockey: String) -> Void {
    let simpleScreenMessage: SimpleScreenMessage;
    simpleScreenMessage.isShown = true;
    simpleScreenMessage.duration = 5.00;
    simpleScreenMessage.message = lockey;
    simpleScreenMessage.isInstant = true;
    GameInstance.GetBlackboardSystem(this.GetPlayerSystem().GetLocalPlayerControlledGameObject().GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(simpleScreenMessage), true);
  }

  protected cb func OnTriggerDelayedReactionEvent(evt: ref<TriggerDelayedReactionEvent>) -> Bool {
    this.TriggerReactionBehaviorForCrowd(evt.stimEvent, evt.behavior, evt.initAnim);
  }

  protected cb func OnExitWorkspotSequenceEvent(evt: ref<ExitWorkspotSequenceEvent>) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    if this.m_inReactionSequence {
      if Equals(this.m_crowdFearStage, gameFearStage.Panic) && VehicleComponent.IsMountedToVehicle(game, owner) {
        if this.SafeToExitPanicFear() {
          this.m_successfulFearDeescalation = 0.00;
          GameInstance.GetWorkspotSystem(game).HardResetPlaybackToStart(owner);
        } else {
          GameInstance.GetDelaySystem(game).CancelDelay(this.m_exitWorkspotSequenceEventId);
          this.m_exitWorkspotSequenceEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, evt, 1.00);
        };
      } else {
        if NotEquals(this.m_crowdFearStage, gameFearStage.Panic) {
          if this.SafeToExitFear() {
            if VehicleComponent.IsMountedToVehicle(game, owner) {
              GameInstance.GetWorkspotSystem(game).HardResetPlaybackToStart(owner);
            } else {
              GameInstance.GetWorkspotSystem(game).ResetPlaybackToStart(owner);
            };
          } else {
            GameInstance.GetDelaySystem(game).CancelDelay(this.m_exitWorkspotSequenceEventId);
            this.m_exitWorkspotSequenceEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, evt, 1.00);
          };
        };
      };
    };
  }

  protected cb func OnCrowdSettingsEvent(evt: ref<CrowdSettingsEvent>) -> Bool {
    let crowdMemberComponent: ref<CrowdMemberBaseComponent> = this.GetOwnerPuppet().GetCrowdMemberComponent();
    if Equals(this.m_crowdFearStage, gameFearStage.Stressed) && this.IsTargetInMovementDirection(this.GetPlayerSystem().GetLocalPlayerControlledGameObject()) {
      crowdMemberComponent.TryChangeMovementDirection();
    };
    crowdMemberComponent.ChangeMoveType(evt.movementType);
  }

  private final func GetFearReactionPhase(stimEvent: ref<StimuliEvent>) -> Int32 {
    let stimData: stimInvestigateData;
    let tags: array<CName> = stimEvent.stimRecord.Tags();
    if Equals(stimEvent.GetStimType(), gamedataStimType.IllegalAction) {
      stimData = stimEvent.stimInvestigateData;
      if stimData.fearPhase != 0 {
        return 0;
      };
    };
    if ArrayContains(tags, n"Uncomfortable") {
      if this.m_isInCrosswalk {
        return 1;
      };
      return 0;
    };
    if ArrayContains(tags, n"PotentialFear") {
      return 1;
    };
    if ArrayContains(tags, n"DirectThreat") {
      if this.IsTargetClose(stimEvent.sourceObject, 10.00) {
        return 2;
      };
      return 1;
    };
    if ArrayContains(tags, n"PanicFear") {
      return 3;
    };
    if Equals(stimEvent.GetStimType(), gamedataStimType.SpreadFear) {
      stimData = stimEvent.stimInvestigateData;
      if stimData.fearPhase == 0 {
        return 1;
      };
      return stimData.fearPhase;
    };
    if Equals(stimEvent.GetStimType(), gamedataStimType.Driving) {
      return 3;
    };
    return -1;
  }

  private final func ShouldInterruptCurrentFearStage(fearPhase: Int32) -> Bool {
    if fearPhase > this.ConvertFearStageToFearPhase(this.m_crowdFearStage) {
      return true;
    };
    return false;
  }

  private final func ConvertFearStageToFearPhase(fearStage: gameFearStage) -> Int32 {
    switch fearStage {
      case gameFearStage.Relaxed:
        return 0;
      case gameFearStage.Stressed:
        return 1;
      case gameFearStage.Alarmed:
        return 2;
      case gameFearStage.Panic:
        return 3;
    };
  }

  private final func GetSpreadFearPhase(stimEvent: ref<StimuliEvent>) -> Int32 {
    if Equals(stimEvent.GetStimType(), gamedataStimType.CombatHit) {
      return 1;
    };
    if this.m_desiredFearPhase > 0 && this.m_desiredFearPhase != 3 {
      return 1;
    };
    return this.m_desiredFearPhase;
  }

  private final func CanReactInVehicle(stimEvent: ref<StimuliEvent>) -> Bool {
    let carMountInfo: MountingInfo;
    let count: Int32;
    let i: Int32;
    let mountingInfos: array<MountingInfo>;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    if VehicleComponent.IsMountedToVehicle(game, owner) && Equals(stimEvent.GetStimType(), gamedataStimType.Dying) {
      carMountInfo = GameInstance.GetMountingFacility(game).GetMountingInfoSingleWithObjects(owner);
      mountingInfos = GameInstance.GetMountingFacility(game).GetMountingInfoMultipleWithIds(carMountInfo.parentId);
      count = ArraySize(mountingInfos);
      i = 0;
      while i < count {
        if (GameInstance.FindEntityByID(game, mountingInfos[i].childId) as GameObject) == stimEvent.sourceObject {
          return true;
        };
        i += 1;
      };
      return false;
    };
    return true;
  }

  protected cb func OnCrowdCallingPoliceEvent(evt: ref<CrowdCallingPoliceEvent>) -> Bool {
    let request: ref<UnregisterPoliceCaller>;
    this.m_willingToCallPolice = false;
    let reactionSystem: ref<ScriptedReactionSystem> = GameInstance.GetScriptableSystemsContainer(this.GetOwner().GetGame()).Get(n"ScriptedReactionSystem") as ScriptedReactionSystem;
    if IsDefined(reactionSystem) && reactionSystem.IsCaller(this.GetEntity()) {
      this.TriggerReactionBehaviorForCrowd(this.GetPlayerSystem().GetLocalPlayerMainGameObject(), gamedataOutput.CallPolice, false);
      request = new UnregisterPoliceCaller();
      reactionSystem.QueueRequest(request);
    };
  }

  private final func CheckStalk(target: ref<GameObject>, timeout: Float) -> Void {
    let stalkEvent: ref<StalkEvent>;
    if this.m_playerProximity && (NotEquals(this.m_reactionPreset.Type(), gamedataReactionPresetType.Civilian_Passive) || !this.SourceAttitude(target, EAIAttitude.AIA_Friendly)) {
      stalkEvent = new StalkEvent();
      GameInstance.GetDelaySystem(this.GetOwner().GetGame()).DelayEvent(this.GetOwner(), stalkEvent, timeout);
    };
  }

  private final func CheckComfortZone() -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let checkComfortZoneEvent: ref<CheckComfortZoneEvent>;
    let distrurbComfortZoneEvent: ref<DisturbingComfortZone>;
    let owner: ref<GameObject> = this.GetOwner();
    let player: ref<GameObject> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject();
    let game: GameInstance = owner.GetGame();
    let simTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
    if this.m_playerProximity && this.IsTargetInFront(player) && this.IsTargetInFront(player, 45.00, true) {
      if this.m_disturbingComfortZoneInProgress {
        if this.m_comfortZoneTimestamp >= simTime {
          this.m_entereProximityRecently += 1;
          if this.m_entereProximityRecently >= 3 {
            broadcaster = player.GetStimBroadcasterComponent();
            if IsDefined(broadcaster) {
              broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.CrowdIllegalAction, owner);
            };
          };
        } else {
          this.m_entereProximityRecently = 0;
          this.m_disturbingComfortZoneInProgress = false;
        };
      } else {
        this.m_disturbingComfortZoneInProgress = true;
        this.m_entereProximityRecently += 1;
        this.m_comfortZoneTimestamp = simTime + 10.00;
      };
      distrurbComfortZoneEvent = new DisturbingComfortZone();
      this.m_disturbComfortZoneEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, distrurbComfortZoneEvent, 10.00);
    } else {
      if this.m_playerProximity {
        checkComfortZoneEvent = new CheckComfortZoneEvent();
        this.m_checkComfortZoneEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, checkComfortZoneEvent, 1.00);
      };
    };
  }

  protected cb func OnDisturbingComfortZoneEvent(evt: ref<DisturbingComfortZone>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let disturbEvent: ref<DisturbingComfortZone>;
    let player: ref<GameObject> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject();
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).CancelDelay(this.m_disturbComfortZoneEventId);
    if this.m_playerProximity && this.IsTargetInFront(player) && !this.GetOwnerPuppet().IsVendor() && this.IsTargetClose(player, 1.00) && this.IsTargetInFront(player, 45.00, true) {
      this.TriggerFacialLookAtReaction(true, true);
      broadcaster = player.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.SendDrirectStimuliToTarget(this.GetOwner(), gamedataStimType.CrowdIllegalAction, this.GetOwner());
      };
    } else {
      if this.m_playerProximity {
        disturbEvent = new DisturbingComfortZone();
        this.m_disturbComfortZoneEventId = GameInstance.GetDelaySystem(this.GetOwner().GetGame()).DelayEvent(this.GetOwner(), disturbEvent, 1.00);
      };
    };
  }

  protected cb func OnCheckComfortZoneEvent(evt: ref<CheckComfortZoneEvent>) -> Bool {
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).CancelDelay(this.m_checkComfortZoneEventId);
    this.CheckComfortZone();
  }

  private final func GetOutputPriority(output: gamedataOutput) -> Float {
    let outputRecord: ref<Output_Record> = TweakDBInterface.GetOutputRecord(TDBID.Create("ReactionOutput." + EnumValueToString("gamedataOutput", Cast(EnumInt(output)))));
    if IsDefined(outputRecord) {
      return outputRecord.AIPriority();
    };
    return 4.00;
  }

  private final func DelayReaction(stimType: gamedataStimType) -> Bool {
    if Equals(stimType, gamedataStimType.AimingAt) {
      return true;
    };
    return false;
  }

  private final func SelectFacialEmotion(out lookAtData: LookAtData) -> Void {
    let personalities: array<gamedataStatType>;
    ArrayPush(personalities, gamedataStatType.PersonalityAggressive);
    ArrayPush(personalities, gamedataStatType.PersonalityCuriosity);
    ArrayPush(personalities, gamedataStatType.PersonalityDisgust);
    ArrayPush(personalities, gamedataStatType.PersonalityFear);
    ArrayPush(personalities, gamedataStatType.PersonalityFunny);
    ArrayPush(personalities, gamedataStatType.PersonalityJoy);
    ArrayPush(personalities, gamedataStatType.PersonalitySad);
    ArrayPush(personalities, gamedataStatType.PersonalityShock);
    ArrayPush(personalities, gamedataStatType.PersonalitySurprise);
    lookAtData.personality = personalities[RandRange(0, 9)];
    lookAtData.category = 3;
    switch lookAtData.personality {
      case gamedataStatType.PersonalityAggressive:
        lookAtData.idle = 1;
        break;
      case gamedataStatType.PersonalityCuriosity:
        lookAtData.category = 1;
        lookAtData.idle = 3;
        break;
      case gamedataStatType.PersonalityDisgust:
        lookAtData.idle = 7;
        break;
      case gamedataStatType.PersonalityFear:
        lookAtData.idle = 10;
        break;
      case gamedataStatType.PersonalityFunny:
        lookAtData.idle = 5;
        break;
      case gamedataStatType.PersonalityJoy:
        lookAtData.idle = 5;
        break;
      case gamedataStatType.PersonalitySad:
        lookAtData.idle = 3;
        break;
      case gamedataStatType.PersonalityShock:
        lookAtData.idle = 8;
        break;
      case gamedataStatType.PersonalitySurprise:
        lookAtData.idle = 8;
        break;
      default:
        lookAtData.idle = 2;
    };
    lookAtData.category = 2;
  }

  private final func MapLookAtVO(lookAtData: LookAtData, out vo: CName) -> Void {
    switch lookAtData.personality {
      case gamedataStatType.PersonalityAggressive:
        vo = n"fear_foll";
        break;
      case gamedataStatType.PersonalityCuriosity:
        vo = n"greeting";
        break;
      case gamedataStatType.PersonalityDisgust:
        vo = n"fear_foll";
        break;
      case gamedataStatType.PersonalityFear:
        vo = n"fear_foll";
        break;
      case gamedataStatType.PersonalityFunny:
        vo = n"greeting";
        break;
      case gamedataStatType.PersonalityJoy:
        vo = n"greeting";
        break;
      case gamedataStatType.PersonalitySad:
        vo = n"";
        break;
      case gamedataStatType.PersonalityShock:
        vo = n"fear_foll";
        break;
      case gamedataStatType.PersonalitySurprise:
        vo = n"greeting";
        break;
      default:
        vo = n"";
    };
    goto 451;
  }

  private func ActivateReactionLookAt(targetEntity: ref<Entity>, opt end: Bool, opt repeat: Bool, opt duration: Float, opt upperBody: Bool) -> Bool {
    let endLookat: ref<EndLookatEvent>;
    let lookAtEvent: ref<LookAtAddEvent>;
    let lookAtPartRequest: LookAtPartRequest;
    let lookAtParts: array<LookAtPartRequest>;
    let owner: ref<GameObject>;
    if !IsDefined(targetEntity) {
      return false;
    };
    if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) {
      return false;
    };
    owner = this.GetOwner();
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"LoreAnim") {
      return false;
    };
    if IsDefined(this.m_lookatEvent) {
      this.DeactiveLookAt();
    };
    lookAtEvent = new LookAtAddEvent();
    lookAtEvent.SetEntityTarget(targetEntity, n"pla_default_tgt", Vector4.EmptyVector());
    lookAtEvent.SetStyle(animLookAtStyle.Normal);
    lookAtEvent.request.limits.softLimitDegrees = 360.00;
    lookAtEvent.request.limits.hardLimitDegrees = 270.00;
    lookAtEvent.request.limits.hardLimitDistance = GetLookAtLimitDistanceValue(IntEnum(3l));
    lookAtEvent.request.limits.backLimitDegrees = 210.00;
    lookAtEvent.request.calculatePositionInParentSpace = true;
    lookAtEvent.bodyPart = n"Eyes";
    lookAtPartRequest.partName = n"Head";
    lookAtPartRequest.weight = 0.10;
    lookAtPartRequest.suppress = 1.00;
    lookAtPartRequest.mode = 0;
    ArrayPush(lookAtParts, lookAtPartRequest);
    lookAtPartRequest.partName = n"Chest";
    lookAtPartRequest.weight = 2.00;
    lookAtPartRequest.suppress = 0.00;
    lookAtPartRequest.mode = 0;
    if upperBody {
      lookAtPartRequest.weight = 0.20;
    };
    ArrayPush(lookAtParts, lookAtPartRequest);
    if !IsFinal() {
      lookAtEvent.SetDebugInfo("ScriptReactionComponent");
    };
    lookAtEvent.SetAdditionalPartsArray(lookAtParts);
    owner.QueueEvent(lookAtEvent);
    if end {
      endLookat = new EndLookatEvent();
      endLookat.repeat = repeat;
      if duration != 0.00 {
        this.GetDelaySystem().DelayEvent(owner, endLookat, TweakDBInterface.GetFloat(t"AIGeneralSettings.reactionLookAtDuration", duration));
      } else {
        this.GetDelaySystem().DelayEvent(owner, endLookat, TweakDBInterface.GetFloat(t"AIGeneralSettings.reactionLookAtDuration", 5.00));
      };
    };
    this.m_lookatEvent = lookAtEvent;
    return true;
  }

  private func DeactiveLookAt(opt repeat: Bool) -> Bool {
    let owner: ref<GameObject>;
    let repeatLookat: ref<RepeatLookatEvent>;
    if !IsDefined(this.m_lookatEvent) {
      return false;
    };
    owner = this.GetOwner();
    LookAtRemoveEvent.QueueRemoveLookatEvent(owner, this.m_lookatEvent);
    this.m_lookatEvent = null;
    if repeat && this.m_playerProximity && !ScriptedPuppet.IsDefeated(owner) && !this.m_lookatRepeat {
      repeatLookat = new RepeatLookatEvent();
      repeatLookat.target = this.GetPlayerSystem().GetLocalPlayerControlledGameObject();
      this.GetDelaySystem().DelayEvent(owner, repeatLookat, TweakDBInterface.GetFloat(t"AIGeneralSettings.repeatReactionLookAtDelay", 2.50));
      this.m_lookatRepeat = true;
    };
    return true;
  }

  private final func OnReactionStarted(reactionData: ref<AIReactionData>) -> Void {
    let player: ref<GameObject>;
    let stimTypeName: CName;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let game: GameInstance = owner.GetGame();
    this.m_activeReaction = reactionData;
    if this.m_desiredReaction == reactionData {
      this.m_desiredReaction = null;
    };
    this.m_workspotReactionPlayed = false;
    if IsDefined(ownerPuppet) && IsDefined(ownerPuppet.GetPuppetStateBlackboard()) {
      ownerPuppet.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.ReactionBehavior, EnumInt(this.m_activeReaction.reactionBehaviorName));
    };
    if reactionData.reactionCooldown != 0.00 {
      GameObject.StartCooldown(owner, EnumValueToName(n"gamedataStimType", Cast(EnumInt(reactionData.stimType))), reactionData.reactionCooldown);
    };
    if Equals(reactionData.reactionBehaviorName, gamedataOutput.DeviceInvestigate) {
      ArrayPush(this.m_investigationList, reactionData.stimEventData);
    };
    if Equals(reactionData.reactionBehaviorName, gamedataOutput.Panic) {
      player = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
      if GameInstance.GetStatsSystem(game).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.CausingPanicReducesUltimateHacksCost) == 1.00 {
        StatusEffectHelper.ApplyStatusEffect(player, t"BaseStatusEffect.ReduceUltimateHackCostBy2");
      };
    };
    stimTypeName = EnumValueToName(n"gamedataStimType", Cast(EnumInt(reactionData.stimType)));
    if !GameObject.IsCooldownActive(owner, n"ActiveReactionValueCooldown-" + stimTypeName) {
      this.AddReactionValueToStatPool(reactionData);
      GameObject.StartCooldown(owner, n"ActiveReactionValueCooldown-" + stimTypeName, 1.00);
    };
    this.CacheReaction(reactionData);
  }

  public final func GetCurrentStimTimeStamp() -> Float {
    return this.m_timeStampThreshold;
  }

  public final func GetCurrentStimThresholdValue() -> Int32 {
    return this.m_currentStimThresholdValue;
  }

  public final func GetCurrentStealthStimTimeStamp() -> Float {
    return this.m_stealthTimeStampThreshold;
  }

  public final func GetCurrentStealthStimThresholdValue() -> Int32 {
    return this.m_currentStealthStimThresholdValue;
  }

  private final func AddInvestigatedBody(bodyID: EntityID) -> Void {
    let bodyInvestigatedEvent: ref<AddInvestigatorEvent> = new AddInvestigatorEvent();
    bodyInvestigatedEvent.investigator = this.GetOwner().GetEntityID();
    let body: ref<Entity> = GameInstance.FindEntityByID(this.GetOwner().GetGame(), bodyID);
    body.QueueEvent(bodyInvestigatedEvent);
  }

  protected cb func OnAddInvestigatedBodyEvent(evt: ref<AddInvestigatorEvent>) -> Bool {
    ArrayPush(this.m_deadBodyInvestigators, evt.investigator);
  }

  public final func InformInvestigators() -> Void {
    let bodyInvestigator: ref<ScriptedPuppet>;
    let removeIgnoreListEvent: ref<IgnoreListEvent> = new IgnoreListEvent();
    removeIgnoreListEvent.bodyID = this.GetOwner().GetEntityID();
    removeIgnoreListEvent.removeEvent = true;
    let i: Int32 = 0;
    while i < ArraySize(this.m_deadBodyInvestigators) {
      bodyInvestigator = GameInstance.FindEntityByID(this.GetOwner().GetGame(), this.m_deadBodyInvestigators[i]) as ScriptedPuppet;
      if ScriptedPuppet.IsAlive(bodyInvestigator) {
        bodyInvestigator.QueueEvent(removeIgnoreListEvent);
      };
      i += 1;
    };
  }

  protected cb func OnBodyPickedUp(evt: ref<SetBodyPositionEvent>) -> Bool {
    let droppedPosition: Vector4;
    let acceptableDistance: Float = 5.00;
    if evt.pickedUp {
      this.m_deadBodyStartingPosition = evt.bodyPosition;
      StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), t"BaseStatusEffect.BeingCarried");
    } else {
      droppedPosition = evt.bodyPosition;
      StatusEffectHelper.RemoveStatusEffect(this.GetOwner(), t"BaseStatusEffect.BeingCarried");
      if Vector4.IsZero(this.m_deadBodyStartingPosition) {
        return false;
      };
      if Vector4.Distance(this.m_deadBodyStartingPosition, droppedPosition) > acceptableDistance {
        this.InformInvestigators();
      };
    };
  }

  private final func OnReactionEnded() -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    this.m_activeReaction = null;
    if IsDefined(ownerPuppet) && IsDefined(ownerPuppet.GetPuppetStateBlackboard()) {
      ownerPuppet.GetPuppetStateBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.ReactionBehavior, EnumInt(gamedataOutput.Ignore));
      this.GetPuppetReactionBlackboard().SetBool(GetAllBlackboardDefs().PuppetReaction.exitReactionFlag, false);
    };
    ArrayClear(this.m_investigationList);
  }

  protected cb func OnResetReactionEvent(evt: ref<ResetReactionEvent>) -> Bool {
    if this.m_desiredReaction == evt.data {
      this.m_desiredReaction = null;
    };
  }

  public final static func BodyInvestigated(owner: wref<ScriptedPuppet>) -> Void {
    if !IsDefined(owner) {
      return;
    };
    owner.QueueEvent(new BodyInvestigatedEvent());
  }

  protected cb func OnBodyInvestigated(evt: ref<BodyInvestigatedEvent>) -> Bool {
    let ignoreListEvent: ref<IgnoreListEvent>;
    if this.ShouldAddToIgnoreList(this.m_activeReaction.stimType) {
      ignoreListEvent = new IgnoreListEvent();
      ignoreListEvent.bodyID = this.m_activeReaction.stimEventData.source.GetEntityID();
      ArrayPush(this.m_ignoreList, ignoreListEvent.bodyID);
      this.SendEventToSquad(ignoreListEvent);
    };
    if NotEquals(this.GetOwnerPuppet().GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      this.SetWarningMessage("LocKey#53240");
      if this.GetOwnerPuppet().IsConnectedToSecuritySystem() {
        this.NotifySecuritySystem(this.m_activeReaction.stimType, this.m_activeReaction.stimTarget);
      };
    };
  }

  private final func CheckSquadInvestigation(stimEventData: StimEventData) -> Bool {
    let i: Int32;
    let member: ref<ScriptedPuppet>;
    let smi: ref<SquadScriptInterface>;
    let squadMembers: array<wref<Entity>>;
    if !AISquadHelper.GetSquadMemberInterface(this.GetOwnerPuppet(), smi) {
      return this.IsInList(this.m_investigationList, stimEventData);
    };
    squadMembers = smi.ListMembersWeak();
    i = 0;
    while i < ArraySize(squadMembers) {
      member = squadMembers[i] as ScriptedPuppet;
      if smi.HasOrderBySquadAction(n"Investigate", member) {
        return this.IsInList(this.m_investigationList, stimEventData);
      };
      i += 1;
    };
    return this.IsInList(this.m_investigationList, stimEventData);
  }

  private final const func GetOwnerPuppet() -> ref<ScriptedPuppet> {
    return this.GetOwner() as ScriptedPuppet;
  }

  private final func HasCombatTarget() -> Bool {
    let combatTarget: wref<GameObject>;
    if !IsDefined(this.GetOwnerPuppet()) {
      return false;
    };
    combatTarget = FromVariant(this.GetOwnerPuppet().GetAIControllerComponent().GetBehaviorArgument(n"CombatTarget"));
    if IsDefined(combatTarget) {
      return true;
    };
    return false;
  }

  private final func PickCloserTarget(newStimEvent: ref<StimuliEvent>, out updateByActive: Bool) -> Void {
    let ownerPos: Vector4 = this.GetOwner().GetWorldPosition();
    let activeDistanceSquared: Float = Vector4.DistanceSquared(this.m_activeReaction.stimSource, ownerPos);
    if activeDistanceSquared < Vector4.DistanceSquared(newStimEvent.sourcePosition, ownerPos) {
      updateByActive = true;
    };
  }

  private final const func DidTargetMakeMeAlerted(target: ref<GameObject>) -> Bool {
    let game: GameInstance;
    let mountInfo: MountingInfo;
    let reactionData: ref<AIReactionData>;
    let simTime: Float;
    let stimData: stimInvestigateData;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if ArraySize(this.m_reactionCache) == 0 {
      return false;
    };
    if Equals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Alerted) && !ownerPuppet.GetSecuritySystem().IsReprimandOngoing() {
      reactionData = this.m_reactionCache[ArraySize(this.m_reactionCache) - 1];
      stimData = reactionData.stimInvestigateData;
      if (reactionData.stimTarget == target || stimData.attackInstigator == target) && reactionData.recentReactionTimeStamp >= simTime && NotEquals(reactionData.reactionBehaviorName, gamedataOutput.Reprimand) {
        return true;
      };
      game = owner.GetGame();
      simTime = EngineTime.ToFloat(GameInstance.GetSimTime(game));
      if EngineTime.ToFloat((owner as NPCPuppet).GetLastSEAppliedByPlayer().GetLastApplicationSimTimestamp()) + 10.00 >= simTime {
        return true;
      };
      if this.IsTargetInterestingForRecentSquadMates(target, reactionData.stimTarget) {
        return true;
      };
      if IsDefined(this.m_stolenVehicle) && VehicleComponent.IsMountedToVehicle(game, target) {
        mountInfo = GameInstance.GetMountingFacility(game).GetMountingInfoSingleWithObjects(target);
        if this.m_stolenVehicle == (GameInstance.FindEntityByID(game, mountInfo.parentId) as VehicleObject) {
          return true;
        };
      };
    };
    return false;
  }

  private final const func IsTargetInterestingForRecentSquadMates(target: ref<GameObject>, ally: ref<GameObject>) -> Bool {
    let reactionCache: array<ref<AIReactionData>>;
    let reactionData: ref<AIReactionData>;
    let simTime: Float;
    let stimData: stimInvestigateData;
    if this.IsTargetRecentSquadAlly(ally) {
      reactionCache = (ally as ScriptedPuppet).GetStimReactionComponent().GetReactionCache();
      reactionData = reactionCache[ArraySize(reactionCache) - 1];
      stimData = reactionData.stimInvestigateData;
      simTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetOwner().GetGame()));
      if stimData.attackInstigator == target && reactionData.recentReactionTimeStamp >= simTime {
        return true;
      };
      if EngineTime.ToFloat((ally as NPCPuppet).GetLastSEAppliedByPlayer().GetLastApplicationSimTimestamp()) + 10.00 >= simTime {
        return true;
      };
    };
    return false;
  }

  private final const func IsPlayerAiming() -> Bool {
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerControlledGameObject();
    let weapon: ref<WeaponObject> = GameObject.GetActiveWeapon(player);
    let blackboard: ref<IBlackboard> = (player as PlayerPuppet).GetPlayerStateMachineBlackboard();
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) && weapon.IsRanged() || blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon) == EnumInt(gamePSMMeleeWeapon.ChargedHold) || blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon) == EnumInt(gamePSMMeleeWeapon.Targeting) || blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.Charge) {
      if GameInstance.GetBlackboardSystem(this.GetOwner().GetGame()).Get(GetAllBlackboardDefs().UI_TargetingInfo).GetEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget) == this.GetOwner().GetEntityID() {
        return true;
      };
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) == EnumInt(gamePSMCombatGadget.Charging) {
      return true;
    };
    return false;
  }

  public final const func GetDesiredReactionData() -> ref<AIReactionData> {
    return this.m_desiredReaction;
  }

  public final const func GetActiveReactionData() -> ref<AIReactionData> {
    return this.m_activeReaction;
  }

  public final const func GetDesiredReactionName() -> gamedataOutput {
    if !IsDefined(this.m_desiredReaction) {
      return gamedataOutput.Ignore;
    };
    return this.m_desiredReaction.reactionBehaviorName;
  }

  public final const func GetReactionBehaviorName() -> gamedataOutput {
    if !IsDefined(this.m_activeReaction) {
      return gamedataOutput.Ignore;
    };
    return this.m_activeReaction.reactionBehaviorName;
  }

  public final const func GetReactionCache() -> array<ref<AIReactionData>> {
    return this.m_reactionCache;
  }

  public final const func GetStimuliCache() -> array<ref<StimuliEvent>> {
    return this.m_stimuliCache;
  }

  public final const func GetReceivedStimType() -> gamedataStimType {
    return this.m_receivedStimType;
  }

  public final const func GetWorkSpotReactionFlag() -> Bool {
    return this.m_workspotReactionPlayed;
  }

  public final const func IsTargetInterestingForPerception(target: ref<GameObject>) -> Bool {
    let reactionData: ref<AIReactionData>;
    if !IsDefined(target) {
      return false;
    };
    if this.DidTargetMakeMeAlerted(target) {
      return true;
    };
    if this.IsPlayerCarryingBody(target as PlayerPuppet) && this.IsReactionAvailableInPreset(gamedataStimType.CarryBody) {
      return true;
    };
    if (target as PlayerPuppet).GetPlayerStateMachineBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) > 0 {
      return true;
    };
    if this.IsPlayerAiming() && this.IsReactionAvailableInPreset(gamedataStimType.AimingAt) {
      return true;
    };
    if !WeaponObject.IsFists(GameObject.GetActiveWeapon(target).GetItemID()) && IsDefined(GameObject.GetActiveWeapon(target)) && this.CanAskToHolsterWeapon() {
      return true;
    };
    reactionData = this.GetActiveReactionData();
    if IsDefined(reactionData) {
      if Equals(reactionData.reactionBehaviorName, gamedataOutput.BodyInvestigate) {
        return true;
      };
      if reactionData.stimTarget == target {
        if Equals(reactionData.reactionBehaviorName, gamedataOutput.AskToFollowOrder) && NotEquals(reactionData.reactionBehaviorName, gamedataOutput.TurnAt) {
          return false;
        };
        if Equals(reactionData.reactionBehaviorName, gamedataOutput.PlayerCall) {
          return false;
        };
        return true;
      };
    };
    return false;
  }

  public final const func GetPuppetReactionBlackboard() -> ref<IBlackboard> {
    return this.m_puppetReactionBlackboard;
  }

  private final func IsInitAnimShock(behavior: gamedataOutput) -> Bool {
    if NotEquals(this.GetOwnerPuppet().GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      if Equals(behavior, gamedataOutput.Investigate) || Equals(behavior, gamedataOutput.Intruder) || Equals(behavior, gamedataOutput.Panic) {
        return true;
      };
    };
    return false;
  }

  public final const func IsInitAnimCall(stim: gamedataStimType) -> Bool {
    if Equals(stim, gamedataStimType.Call) {
      return true;
    };
    return false;
  }

  public final const func GetInPendingBehavior() -> Bool {
    return this.m_inPendingBehavior;
  }

  public final const func GetReactionPreset() -> wref<ReactionPreset_Record> {
    return this.m_reactionPreset;
  }

  private final func IsInPendingBehavior() -> Bool {
    if this.m_inPendingBehavior {
      return true;
    };
    if Equals(this.m_stanceState, gamedataNPCStanceState.Vehicle) || Equals(this.m_stanceState, gamedataNPCStanceState.VehicleWindow) {
      return true;
    };
    if (this.GetOwnerPuppet() as NPCPuppet).IsRagdolling() {
      return true;
    };
    return false;
  }

  public final const func IsAlertedByDeadBody() -> Bool {
    return this.m_isAlertedByDeadBody;
  }

  public final func GetPreviousFearPhase() -> Int32 {
    return this.m_previousFearPhase;
  }

  public final func GetEnvironmentalHazards() -> array<ref<StimuliEvent>> {
    return this.m_environmentalHazards;
  }

  private final const func GetActiveStimPriority() -> gamedataStimPriority {
    if !IsDefined(this.m_activeReaction) {
      return gamedataStimPriority.Invalid;
    };
    return this.m_activeReaction.stimPriority;
  }

  private final const func GetActiveStimTarget() -> ref<GameObject> {
    if !IsDefined(this.m_activeReaction) {
      return null;
    };
    return this.m_activeReaction.stimTarget;
  }

  private final const func GetActiveStimSource() -> Vector4 {
    if !IsDefined(this.m_activeReaction) {
      return Vector4.EmptyVector();
    };
    return this.m_activeReaction.stimSource;
  }

  private final func ShouldUpdateThreatPosition(stimEvent: ref<StimuliEvent>) -> Bool {
    if stimEvent.IsTagInStimuli(n"Direct") {
      return false;
    };
    if stimEvent.sourceObject != FromVariant(this.GetOwnerPuppet().GetAIControllerComponent().GetBehaviorArgument(n"CombatTarget")) {
      return false;
    };
    if this.IsTargetVisible(stimEvent.sourceObject) {
      return false;
    };
    if Equals(stimEvent.stimPropagation, gamedataStimPropagation.Visual) && NotEquals(stimEvent.GetStimType(), gamedataStimType.Gunshot) {
      return false;
    };
    return true;
  }

  private final func ShouldTriggerGrenadeDodgeBehavior(stimEvent: ref<StimuliEvent>) -> Bool {
    let agileAbility: ref<GameplayAbility_Record>;
    let game: GameInstance;
    let i: Int32;
    let innerRadius: Float;
    let isAgileNPC: Bool;
    let outerRadius: Float;
    let owner: ref<GameObject>;
    let prereqCount: Int32;
    let record: ref<IPrereq_Record>;
    let stimDistanceSquared: Float;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if ownerPuppet.IsCharacterCivilian() || Equals(ownerPuppet.GetNPCType(), gamedataNPCType.Drone) {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(ownerPuppet, gamedataStatusEffectType.Wounded) {
      return false;
    };
    owner = this.GetOwner();
    game = owner.GetGame();
    innerRadius = TweakDBInterface.GetFloat(t"AIGeneralSettings.grenadeDodgeInnerRadius", 0.00);
    outerRadius = TweakDBInterface.GetFloat(t"AIGeneralSettings.grenadeDodgeOuterRadius", 0.00);
    agileAbility = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.HasKerenzikov");
    prereqCount = agileAbility.GetPrereqsForUseCount();
    i = 0;
    while i < prereqCount {
      record = agileAbility.GetPrereqsForUseItem(i);
      if IPrereq.CreatePrereq(record.GetID()).IsFulfilled(game, owner) {
        isAgileNPC = true;
      } else {
        i += 1;
      };
    };
    stimDistanceSquared = Vector4.DistanceSquared(owner.GetWorldPosition(), stimEvent.sourcePosition);
    if stimDistanceSquared <= innerRadius * innerRadius || stimDistanceSquared <= outerRadius * outerRadius && this.IsTargetInFront(stimEvent.sourceObject) || stimDistanceSquared >= outerRadius * outerRadius && isAgileNPC {
      return true;
    };
    return false;
  }

  private final func CanTriggerPanicInCombat(stimEvent: ref<StimuliEvent>) -> Bool {
    let distance: Float;
    let stimDistanceSquared: Float;
    if !this.HasCombatTarget() {
      return true;
    };
    stimDistanceSquared = Vector4.DistanceSquared(this.GetOwner().GetWorldPosition(), stimEvent.sourcePosition);
    distance = TweakDBInterface.GetFloat(t"AIGeneralSettings.panicInCombatReactionDistance", 10.00);
    if stimDistanceSquared <= distance * distance {
      return true;
    };
    return false;
  }

  private final func CanStimInterruptCombat(stimEvent: ref<StimuliEvent>) -> Bool {
    let grenade: ref<BaseGrenade> = stimEvent.sourceObject as BaseGrenade;
    if !stimEvent.IsTagInStimuli(n"Combat") && !(Equals(stimEvent.GetStimType(), gamedataStimType.ProjectileDistraction) && IsDefined(grenade)) {
      return false;
    };
    if this.IsTargetMelee(this.GetOwnerPuppet()) {
      return false;
    };
    if ScriptedPuppet.IsOnOffMeshLink(this.GetOwner()) {
      return false;
    };
    if IsDefined(grenade) && grenade.GetUser() == this.GetOwner() {
      return false;
    };
    return true;
  }

  private final func ShouldAddToIgnoreList(stimType: gamedataStimType) -> Bool {
    if Equals(stimType, gamedataStimType.DeadBody) {
      return true;
    };
    return false;
  }

  private final func IsTargetVisible(target: ref<GameObject>) -> Bool {
    let senseComponent: ref<SenseComponent> = this.GetOwnerPuppet().GetSensesComponent();
    if !IsDefined(senseComponent) && !IsDefined(target) {
      return false;
    };
    if senseComponent.IsAgentVisible(target) {
      return true;
    };
    return false;
  }

  private final func IsTargetDetected(target: ref<GameObject>) -> Bool {
    let senseComponent: ref<SenseComponent> = this.GetOwnerPuppet().GetSensesComponent();
    if !IsDefined(senseComponent) && !IsDefined(target) {
      return false;
    };
    if senseComponent.GetDetection(target.GetEntityID()) >= 100.00 {
      return true;
    };
    return false;
  }

  private final func SourceAttitude(source: wref<GameObject>, attitude: EAIAttitude) -> Bool {
    let attitudeOwner: ref<AttitudeAgent> = this.GetOwner().GetAttitudeAgent();
    let attitudeTarget: ref<AttitudeAgent> = source.GetAttitudeAgent();
    if IsDefined(attitudeOwner) && IsDefined(attitudeTarget) && IsDefined(source) {
      if Equals(attitudeOwner.GetAttitudeTowards(attitudeTarget), attitude) {
        return true;
      };
    };
    return false;
  }

  private final func IsTargetInFront(target: wref<GameObject>, opt frontAngle: Float, opt meInFrontOfTarget: Bool) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPos: Vector4 = owner.GetWorldPosition();
    let ownerFwd: Vector4 = owner.GetWorldForward();
    let ownerUp: Vector4 = owner.GetWorldUp();
    let targetPos: Vector4 = target.GetWorldPosition();
    let direction: Vector4 = targetPos - ownerPos;
    let angleToTarget: Float = Vector4.GetAngleDegAroundAxis(direction, ownerFwd, ownerUp);
    if frontAngle == 0.00 {
      frontAngle = 90.00;
    };
    if meInFrontOfTarget {
      direction = ownerPos - targetPos;
      angleToTarget = Vector4.GetAngleDegAroundAxis(direction, target.GetWorldForward(), target.GetWorldUp());
      if AbsF(angleToTarget) < frontAngle {
        return true;
      };
    } else {
      direction = targetPos - ownerPos;
      angleToTarget = Vector4.GetAngleDegAroundAxis(direction, ownerFwd, ownerUp);
      if AbsF(angleToTarget) < frontAngle {
        return true;
      };
    };
    return false;
  }

  private final func IsTargetBehind(target: wref<GameObject>, opt angle: Float, opt meBehindOfTarget: Bool) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPos: Vector4 = owner.GetWorldPosition();
    let ownerFwd: Vector4 = owner.GetWorldForward();
    let ownerUp: Vector4 = owner.GetWorldUp();
    let targetPos: Vector4 = target.GetWorldPosition();
    let direction: Vector4 = targetPos - ownerPos;
    let angleToTarget: Float = Vector4.GetAngleDegAroundAxis(direction, ownerFwd, ownerUp);
    if angle == 0.00 {
      angle = 120.00;
    };
    if meBehindOfTarget {
      direction = ownerPos - targetPos;
      angleToTarget = Vector4.GetAngleDegAroundAxis(direction, target.GetWorldForward(), target.GetWorldUp());
      if AbsF(angleToTarget) > angle {
        return true;
      };
    } else {
      direction = targetPos - ownerPos;
      angleToTarget = Vector4.GetAngleDegAroundAxis(direction, ownerFwd, ownerUp);
      if AbsF(angleToTarget) > angle {
        return true;
      };
    };
    return false;
  }

  public final func IsTargetInMovementDirection(target: wref<GameObject>) -> Bool {
    let angleToTarget: Float;
    let vecToTarget: Vector4 = target.GetWorldPosition() - this.GetOwner().GetWorldPosition();
    let movementDirection: Vector4 = this.GetOwnerPuppet().GetCrowdMemberComponent().GetMovementDirection();
    if !Vector4.IsZero(movementDirection) {
      angleToTarget = Vector4.GetAngleDegAroundAxis(vecToTarget, movementDirection, this.GetOwner().GetWorldUp());
      if AbsF(angleToTarget) < 90.00 {
        return true;
      };
    };
    return false;
  }

  private final func IsTargetClose(target: wref<GameObject>, opt distance: Float) -> Bool {
    let distanceSquared: Float = Vector4.DistanceSquared(target.GetWorldPosition(), this.GetOwner().GetWorldPosition());
    if distance > 0.00 {
      if distanceSquared < distance * distance {
        return true;
      };
    } else {
      if distanceSquared < this.m_crowdAimingReactionDistance * this.m_crowdAimingReactionDistance {
        return true;
      };
    };
    return false;
  }

  private final func TargetVerticalCheck(target: wref<GameObject>, opt distance: Float) -> Bool {
    let vecToTarget: Vector4 = this.GetOwner().GetWorldPosition() - target.GetWorldPosition();
    if AbsF(vecToTarget.Z) > 2.00 {
      return false;
    };
    return true;
  }

  public final static func ReactOnPlayerStealthStim(owner: wref<GameObject>, target: wref<GameObject>) -> Bool {
    let attitudeTarget: ref<AttitudeAgent>;
    let attitudeTowardsTarget: EAIAttitude;
    let attitudeOwner: ref<AttitudeAgent> = owner.GetAttitudeAgent();
    if IsDefined(attitudeOwner) {
      attitudeTarget = target.GetAttitudeAgent();
      if IsDefined(attitudeTarget) && target.IsPlayer() {
        attitudeTowardsTarget = attitudeOwner.GetAttitudeTowards(attitudeTarget);
      } else {
        if GameObject.IsVehicle(target) {
          target = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
          attitudeTarget = target.GetAttitudeAgent();
          attitudeTowardsTarget = attitudeOwner.GetAttitudeTowards(attitudeTarget);
        };
      };
      if IsDefined(attitudeTarget) {
        if Equals(attitudeTowardsTarget, EAIAttitude.AIA_Hostile) {
          return true;
        };
        if Equals(attitudeTowardsTarget, EAIAttitude.AIA_Neutral) && owner.IsConnectedToSecuritySystem() && owner.IsTargetTresspassingMyZone(target) {
          return true;
        };
      };
    };
    return false;
  }

  private final func CheckHearingDistance(stimEvent: ref<StimuliEvent>) -> Bool {
    let distanceSquared: Float = Vector4.DistanceSquared(this.GetOwner().GetWorldPosition(), stimEvent.sourcePosition);
    let radius: Float = stimEvent.radius * GameInstance.GetStatsSystem(this.GetOwner().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.Hearing);
    if distanceSquared <= radius * radius {
      return true;
    };
    return false;
  }

  private final func CheckVisibilityRaycast(stimEvent: ref<StimuliEvent>) -> Bool {
    let raycastTrace: TraceResult;
    GameInstance.GetSpatialQueriesSystem(this.GetOwner().GetGame()).SyncRaycastByCollisionPreset(this.GetOwner().GetWorldPosition() + new Vector4(0.00, 0.00, 0.50, 0.00), stimEvent.sourcePosition, n"Player Hitbox", raycastTrace);
    if TraceResult.IsValid(raycastTrace) {
      return true;
    };
    return false;
  }

  private final func ValidVisualGunshotTarget(stimEvent: ref<StimuliEvent>, reactionData: ref<AIReactionData>) -> Bool {
    if Equals(reactionData.stimType, gamedataStimType.Gunshot) {
      return false;
    };
    if this.IsTargetClose(stimEvent.sourceObject, 25.00) {
      return false;
    };
    if !this.IsTargetInFront(stimEvent.sourceObject, 60.00) {
      return false;
    };
    if !this.IsTargetInFront(stimEvent.sourceObject, 50.00, true) {
      return false;
    };
    return true;
  }

  private final func IsDirectStimuli(stimType: gamedataStimType) -> Bool {
    if Equals(stimType, gamedataStimType.Combat) {
      return true;
    };
    return false;
  }

  private final func IsPublicZone(stimEvent: ref<StimuliEvent>) -> Bool {
    if Equals(stimEvent.GetStimType(), gamedataStimType.WeaponDisplayed) {
      return true;
    };
    return false;
  }

  private final func IsPlayerInZone(zone: gamePSMZones) -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame());
    let psmBlackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.GetPlayerSystem().GetLocalPlayerMainGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if Equals(IntEnum(psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones)), zone) {
      return true;
    };
    return false;
  }

  private final func IgnoreStimIfNonFriendly(stimEvent: ref<StimuliEvent>) -> Bool {
    if Equals(stimEvent.GetStimType(), gamedataStimType.DeadBody) {
      return true;
    };
    return false;
  }

  private final func IsSameStimulus(stimEvent: ref<StimuliEvent>) -> Bool {
    if IsDefined(this.m_activeReaction) && Equals(this.m_activeReaction.stimType, stimEvent.GetStimType()) {
      return true;
    };
    return false;
  }

  private final func IsSameSourceObject(stimEvent: ref<StimuliEvent>) -> Bool {
    if IsDefined(this.m_activeReaction) && this.m_activeReaction.stimTarget == stimEvent.sourceObject {
      return true;
    };
    return false;
  }

  private final func IgnoreStimIfFromSameSource(stimEvent: ref<StimuliEvent>) -> Bool {
    if Equals(stimEvent.GetStimType(), gamedataStimType.Distract) {
      return true;
    };
    return false;
  }

  private final func IsInList(list: array<StimEventData>, stimData: StimEventData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(list) {
      if list[i].source == stimData.source && Equals(list[i].stimType, stimData.stimType) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsCategory(stimEvent: ref<StimuliEvent>, category: CName) -> Bool {
    if Equals(stimEvent.stimRecord.Category(), category) {
      return true;
    };
    return false;
  }

  private final func IsStimPriorityValid(stimEvent: ref<StimuliEvent>, activePriority: gamedataStimPriority) -> Bool {
    if Equals(stimEvent.stimRecord.Priority().Type(), gamedataStimPriority.Low) && Equals(activePriority, gamedataStimPriority.High) {
      return false;
    };
    return true;
  }

  private final func IsTargetSquadAlly(target: wref<GameObject>) -> Bool {
    let smi: ref<SquadScriptInterface>;
    let squadName: CName;
    if !AISquadHelper.GetSquadMemberInterface(this.GetOwnerPuppet(), smi) {
      return false;
    };
    squadName = smi.GetName();
    if !AISquadHelper.GetSquadMemberInterface(target, smi) {
      return false;
    };
    if NotEquals(squadName, smi.GetName()) {
      return false;
    };
    return true;
  }

  private final func IsTargetMelee(target: ref<GameObject>) -> Bool {
    if IsDefined(GameObject.GetActiveWeapon(target)) && !GameObject.GetActiveWeapon(target).IsRanged() {
      return true;
    };
    return false;
  }

  private final func IsTargetArmed(target: ref<GameObject>) -> Bool {
    if IsDefined(GameObject.GetActiveWeapon(target)) && !WeaponObject.IsFists(GameObject.GetActiveWeapon(target).GetItemID()) {
      return true;
    };
    return false;
  }

  private final const func IsTargetRecentSquadAlly(target: wref<GameObject>) -> Bool {
    let smi: ref<SquadScriptInterface>;
    let squadName: CName;
    let squadCmp: ref<SquadMemberComponent> = target.GetSquadMemberComponent();
    if !IsDefined(squadCmp) {
      return false;
    };
    if !AISquadHelper.GetSquadMemberInterface(this.GetOwner(), smi) {
      return false;
    };
    squadName = smi.GetName();
    if NotEquals(squadName, squadCmp.MySquadNameCurrentOrRecent(AISquadType.Combat)) {
      return false;
    };
    return true;
  }

  private final func ShouldHelpAlly(stimType: gamedataStimType) -> Bool {
    if Equals(stimType, gamedataStimType.Gunshot) || Equals(stimType, gamedataStimType.Call) || Equals(stimType, gamedataStimType.MeleeHit) || Equals(stimType, gamedataStimType.VehicleHit) || Equals(stimType, gamedataStimType.Bullet) || Equals(stimType, gamedataStimType.Alarm) || Equals(stimType, gamedataStimType.Dying) {
      return true;
    };
    return false;
  }

  private final const func ShouldPoliceReact(stimEvent: ref<StimuliEvent>) -> Bool {
    let attackData: stimInvestigateData;
    let stimTargetPuppet: ref<ScriptedPuppet> = stimEvent.sourceObject as ScriptedPuppet;
    if Equals(stimEvent.GetStimType(), gamedataStimType.DeadBody) && IsDefined(stimTargetPuppet) && stimTargetPuppet.IsCharacterGanger() {
      return false;
    };
    attackData = stimEvent.stimInvestigateData;
    if Equals(stimEvent.GetStimType(), gamedataStimType.IllegalAction) && IsDefined(attackData.victimEntity) {
      stimTargetPuppet = attackData.victimEntity as ScriptedPuppet;
      if IsDefined(stimTargetPuppet) && stimTargetPuppet.IsCharacterGanger() {
        return false;
      };
    };
    if this.GetOwner().IsTargetTresspassingMyZone(stimEvent.sourceObject) {
      return true;
    };
    if PreventionSystem.ShouldReactionBeAgressive(this.GetOwner().GetGame()) {
      return true;
    };
    if Equals(stimEvent.GetStimType(), gamedataStimType.CrimeWitness) {
      return true;
    };
    return false;
  }

  private final func ShouldBeDetected(stimType: gamedataStimType) -> Bool {
    if Equals(stimType, gamedataStimType.IllegalInteraction) || Equals(stimType, gamedataStimType.CarryBody) {
      return true;
    };
    return false;
  }

  private final func SetBaseReactionPreset(opt ignoreSavedPreset: Bool) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let savedPresetID: TweakDBID = ownerPuppet.GetReactionPresetID();
    if TDBID.IsValid(savedPresetID) && !ignoreSavedPreset {
      this.m_reactionPreset = TweakDBInterface.GetReactionPresetRecord(savedPresetID);
    } else {
      this.m_reactionPreset = TweakDBInterface.GetCharacterRecord(this.GetOwnerPuppet().GetRecordID()).ReactionPreset();
    };
    if this.m_reactionPreset != null {
      this.m_presetName = this.m_reactionPreset.EnumName();
    };
    ownerPuppet.RefreshCachedReactionPresetData();
  }

  private final func SetReactionPreset(reactionPreset: ref<ReactionPreset_Record>) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if reactionPreset == TweakDBInterface.GetCharacterRecord(ownerPuppet.GetRecordID()).ReactionPreset() {
      this.ReevaluateReactionPreset(true);
    } else {
      this.m_reactionPreset = reactionPreset;
      this.m_presetName = this.m_reactionPreset.EnumName();
      ownerPuppet.SetReactionPresetID(reactionPreset.GetID());
    };
    ownerPuppet.RefreshCachedReactionPresetData();
  }

  private final func MapReactionPreset(mappingName: String) -> Void {
    let basePreset: ref<ReactionPreset_Record>;
    let i: Int32;
    let newPreset: ref<ReactionPreset_Record>;
    let presets: array<wref<PresetMapper_Record>>;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if Equals(mappingName, "NoReaction") {
      newPreset = TweakDBInterface.GetReactionPresetRecord(t"ReactionPresets.NoReaction");
    } else {
      if Equals(mappingName, "Follower") {
        newPreset = TweakDBInterface.GetReactionPresetRecord(t"ReactionPresets.Follower");
      } else {
        basePreset = TweakDBInterface.GetCharacterRecord(ownerPuppet.GetRecordID()).ReactionPreset();
        basePreset.PresetMapper(presets);
        i = 0;
        while i < ArraySize(presets) {
          if Equals(presets[i].MappingName(), mappingName) {
            newPreset = presets[i].Preset();
          };
          i += 1;
        };
      };
    };
    if newPreset == null {
      newPreset = basePreset;
    };
    this.m_reactionPreset = newPreset;
    this.m_presetName = this.m_reactionPreset.EnumName();
    ownerPuppet.RefreshCachedReactionPresetData();
  }

  private final func ReevaluateReactionPreset(opt ignoreSavedPreset: Bool) -> Void {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"Braindance") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"Drunk") {
      this.MapReactionPreset("NoReaction");
    } else {
      if Equals(this.m_aiRole, EAIRole.Follower) {
        this.MapReactionPreset("Follower");
      } else {
        if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"Sleep") {
          this.MapReactionPreset("Sleep");
        } else {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"LoreAnim") {
            this.MapReactionPreset("Lore");
          } else {
            if Equals(this.m_stanceState, gamedataNPCStanceState.Vehicle) || Equals(this.m_stanceState, gamedataNPCStanceState.VehicleWindow) {
              this.MapReactionPreset("Vehicle");
            } else {
              this.SetBaseReactionPreset(ignoreSavedPreset);
            };
          };
        };
      };
    };
  }

  private final func CheckCrowd() -> Void {
    this.m_inCrowd = this.GetOwnerPuppet().IsCrowd();
  }

  private final func SetDeadBodyVisibleComponent(killer: ref<GameObject>) -> Void {
    let attackData: stimInvestigateData;
    let broadcaster: ref<StimBroadcasterComponent>;
    let detectMultEvent: ref<VisibleObjectDetectionMultEvent>;
    let exitEvent: ref<AIEvent>;
    let mountInfo: MountingInfo;
    let visibleObject: ref<VisibleObjectComponent>;
    let visibleObjectPosition: Vector4;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    if IsDefined(killer) && killer.IsPlayer() {
      visibleObject = (owner as NPCPuppet).GetVisibleObjectComponent();
      visibleObject.Toggle(true);
      visibleObjectPosition = visibleObject.GetLocalPosition();
      visibleObjectPosition.Z = visibleObjectPosition.Z + 1.00;
      visibleObject.SetLocalPosition(visibleObjectPosition);
      visibleObject.visibleObject.description = n"Dead_Body";
      visibleObject.visibleObject.visibilityDistance = TweakDBInterface.GetFloat(t"AIGeneralSettings.deadBodyVisibilityDistance", 20.00);
      detectMultEvent = new VisibleObjectDetectionMultEvent();
      detectMultEvent.multiplier = 1.20;
      owner.QueueEvent(detectMultEvent);
      broadcaster = killer.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        attackData.victimEntity = EntityGameInterface.GetEntity(owner.GetEntity());
        broadcaster.SetSingleActiveStimuli(owner, gamedataStimType.IllegalAction, 2.50, attackData);
      };
      broadcaster = owner.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        attackData.attackInstigator = killer;
        attackData.attackInstigatorPosition = killer.GetWorldPosition();
        broadcaster.AddActiveStimuli(owner, gamedataStimType.Dying, 2.00, attackData);
        broadcaster.TriggerSingleBroadcast(owner, gamedataStimType.Dying, 4.00, attackData, true);
        broadcaster.AddActiveStimuli(owner, gamedataStimType.CrowdIllegalAction, -1.00);
      };
    };
    if VehicleComponent.IsMountedToVehicle(game, owner) && this.m_inCrowd {
      exitEvent = new AIEvent();
      exitEvent.name = n"ExitVehicleInPanic";
      mountInfo = GameInstance.GetMountingFacility(game).GetMountingInfoSingleWithObjects(owner);
      VehicleComponent.QueueEventToAllNonFriendlyNonDeadPassengers(game, mountInfo.parentId, exitEvent, owner);
    };
  }

  public final static func SendVOEventToSquad(owner: wref<GameObject>, voEvent: CName, opt setOwnerAsAnsweringEntity: Bool) -> Void {
    let answeringEntityId: EntityID;
    let i: Int32;
    let maxDistBattleCry: Float;
    let member: ref<ScriptedPuppet>;
    let ownerPosition: Vector4;
    let smi: ref<SquadScriptInterface>;
    let squadMembers: array<wref<Entity>>;
    let voiceOverName: CName;
    let ownerPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    if setOwnerAsAnsweringEntity {
      answeringEntityId = ownerPuppet.GetEntityID();
    };
    if !AISquadHelper.GetSquadMemberInterface(ownerPuppet, smi) {
      return;
    };
    squadMembers = smi.ListMembersWeak();
    if ArraySize(squadMembers) <= 1 {
      return;
    };
    ownerPosition = ownerPuppet.GetWorldPosition();
    maxDistBattleCry = TweakDBInterface.GetFloat(t"AIGeneralSettings.maxDistanceBattleCry", 0.00);
    voiceOverName = n"Scripts:SendVOEventToSquad: " + voEvent;
    i = 0;
    while i < ArraySize(squadMembers) {
      member = squadMembers[i] as ScriptedPuppet;
      if member == ownerPuppet {
      } else {
        if !ScriptedPuppet.IsActive(member) {
        } else {
          if Vector4.Distance(member.GetWorldPosition(), ownerPosition) < maxDistBattleCry {
            GameObject.PlayVoiceOver(member, voEvent, voiceOverName, 0.00, answeringEntityId);
          };
        };
      };
      i += 1;
    };
  }

  private final func SendEventToSquad(opt ignoreListEvent: ref<IgnoreListEvent>) -> Void {
    let i: Int32;
    let member: ref<ScriptedPuppet>;
    let smi: ref<SquadScriptInterface>;
    let squadMembers: array<wref<Entity>>;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if !AISquadHelper.GetSquadMemberInterface(ownerPuppet, smi) {
      return;
    };
    squadMembers = smi.ListMembersWeak();
    if ArraySize(squadMembers) <= 1 {
      return;
    };
    i = 0;
    while i < ArraySize(squadMembers) {
      member = squadMembers[i] as ScriptedPuppet;
      if member == ownerPuppet {
      } else {
        if !ScriptedPuppet.IsActive(member) {
        } else {
          if IsDefined(ignoreListEvent) {
            member.QueueEvent(ignoreListEvent);
          };
        };
      };
      i += 1;
    };
  }

  private final func GetThreatDistanceSquared(threat: ref<GameObject>) -> Float {
    let distanceSquared: Float = Vector4.DistanceSquared(this.GetOwner().GetWorldPosition(), threat.GetWorldPosition());
    return distanceSquared;
  }

  private final func GetFearAnimWrapper(fearPhase: Int32) -> CName {
    switch fearPhase {
      case 1:
        if this.m_fastWalk {
          return n"disturbed";
        };
        return n"default";
      case 2:
        return n"fear";
      case 3:
        return n"panic";
      default:
        return n"default";
    };
  }

  public final const func GetRandomFearLocomotionAnimWrapper(fearPhase: Int32, opt stimType: gamedataStimType) -> CName {
    let rand: Float;
    if Equals(stimType, gamedataStimType.Driving) {
      rand = RandF();
      if rand <= 0.33 {
        return n"FearLocomotion1";
      };
      if rand > 0.33 && rand <= 0.66 {
        return n"FearLocomotion3";
      };
      return n"FearLocomotion4";
    };
    if fearPhase > 2 {
      return n"FearLocomotion2";
    };
    rand = RandF();
    if rand > 0.25 && rand <= 0.50 {
      return n"FearLocomotion1";
    };
    if rand > 0.50 && rand <= 0.75 {
      return n"FearLocomotion2";
    };
    if rand <= 0.25 {
      return n"FearLocomotion3";
    };
    return n"FearLocomotion4";
  }

  private final func ResetAllFearAnimWrappers() -> Void {
    let owner: ref<GameObject> = this.GetOwner();
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, n"disturbed", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, n"fear", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, n"panic", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, n"FearLocomotion1", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, n"FearLocomotion2", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, n"FearLocomotion3", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, n"FearLocomotion4", 0.00);
    this.m_fearLocomotionWrapper = false;
  }

  public final const func IsFearLocomotionWrapperSet() -> Bool {
    return this.m_fearLocomotionWrapper;
  }

  private final func ReevaluateReaction() -> Void {
    if this.SourceAttitude(this.m_activeReaction.stimTarget, EAIAttitude.AIA_Friendly) {
      this.GetPuppetReactionBlackboard().SetBool(GetAllBlackboardDefs().PuppetReaction.exitReactionFlag, true);
      NPCPuppet.ChangeHighLevelState(this.GetOwner(), gamedataNPCHighLevelState.Relaxed);
    };
  }

  protected cb func OnStanceLevelChanged(evt: ref<StanceStateChangeEvent>) -> Bool {
    this.m_stanceState = evt.state;
    this.ReevaluateReactionPreset();
    if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) && Equals(this.m_stanceState, gamedataNPCStanceState.Stand) {
      this.TriggerPendingReaction();
    };
    if Equals(this.m_stanceState, gamedataNPCStanceState.Vehicle) || Equals(this.m_stanceState, gamedataNPCStanceState.VehicleWindow) || Equals(this.m_stanceState, gamedataNPCStanceState.Swim) {
      this.GetOwnerPuppet().GetBumpComponent().Toggle(false);
    } else {
      this.GetOwnerPuppet().GetBumpComponent().ToggleComponentOn();
    };
  }

  protected cb func OnHighLevelStateDataEvent(evt: ref<gameHighLevelStateDataEvent>) -> Bool {
    this.m_highLevelState = evt.currentHighLevelState;
    if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Dead) {
      this.DeactiveLookAt();
      this.Toggle(false);
    } else {
      if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) {
        if this.GetOwnerPuppet().IsCharacterCivilian() && !IsDefined(this.m_pendingReaction) {
          this.m_crowdFearStage = gameFearStage.Relaxed;
          this.ResetAllFearAnimWrappers();
        };
        this.TriggerPendingReaction();
      };
    };
    if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) {
      (this.GetOwner() as NPCPuppet).GetComfortZoneComponent().Toggle(false);
    };
    if this.GetOwnerPuppet().IsConnectedToSecuritySystem() && NotEquals(this.m_highLevelState, gamedataNPCHighLevelState.Alerted) && this.m_isAlertedByDeadBody {
      this.m_isAlertedByDeadBody = false;
    };
  }

  protected cb func OnRagdollEnabledEvent(evt: ref<RagdollNotifyEnabledEvent>) -> Bool {
    if this.m_inCrowd {
      this.m_desiredFearPhase = -1;
    };
  }

  private final func OnGameDetach() -> Void {
    let puppetBlackboard: ref<IBlackboard>;
    if IsDefined(this.GetOwnerPuppet()) {
      puppetBlackboard = this.GetOwnerPuppet().GetPuppetStateBlackboard();
    };
    if IsDefined(puppetBlackboard) && IsDefined(this.m_pendingBehaviorCb) {
      puppetBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, this.m_pendingBehaviorCb);
    };
    if ArraySize(this.m_ignoreList) != 0 {
      this.InformInvestigators();
    };
  }

  protected cb func OnDeadBodyEvent(evt: ref<DeadBodyEvent>) -> Bool {
    this.SetDeadBodyVisibleComponent((this.GetOwner() as NPCPuppet).GetMyKiller());
  }

  protected cb func OnIgnoreListEvent(evt: ref<IgnoreListEvent>) -> Bool {
    if evt.removeEvent {
      if ArrayContains(this.m_ignoreList, evt.bodyID) {
        ArrayRemove(this.m_ignoreList, evt.bodyID);
      };
    } else {
      ArrayPush(this.m_ignoreList, evt.bodyID);
      this.AddInvestigatedBody(evt.bodyID);
    };
  }

  protected cb func OnNPCRoleChangeEvent(evt: ref<NPCRoleChangeEvent>) -> Bool {
    this.m_aiRole = evt.m_newRole.GetRoleEnum();
    this.ReevaluateReactionPreset();
    if Equals(this.m_aiRole, EAIRole.Follower) {
      this.GetOwnerPuppet().GetBumpComponent().Toggle(false);
    };
  }

  protected cb func OnWorkspotStartedEvent(evt: ref<WorkspotStartedEvent>) -> Bool;

  protected cb func OnWorkspotFinishedEvent(evt: ref<WorkspotFinishedEvent>) -> Bool;

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let additionalParam: CName = evt.staticData.AdditionalParam();
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.Sleep) || Equals(additionalParam, n"Drunk") || evt.staticData.GameplayTagsContains(n"Braindance") {
      this.ReevaluateReactionPreset();
    };
    if Equals(additionalParam, n"LoreAnim") {
      this.ReevaluateReactionPreset();
      this.m_workspotReactionPlayed = true;
    };
    if Equals(additionalParam, n"LoreVictimSaved") {
      AnimationControllerComponent.SetAnimWrapperWeight(this.GetOwnerPuppet(), n"LoreVictimSaved", 1.00);
    };
    if Equals(additionalParam, n"Busy") {
      this.GetOwnerPuppet().EnableInteraction(n"GenericTalk", false);
    };
  }

  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let startReaction: ref<StimuliEvent>;
    let additionalParam: CName = evt.staticData.AdditionalParam();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.Sleep) || Equals(additionalParam, n"Drunk") || evt.staticData.GameplayTagsContains(n"Braindance") {
      this.ReevaluateReactionPreset();
    };
    if Equals(additionalParam, n"LoreAnim") {
      if IsDefined(this.m_activeReaction) || Equals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Alerted) {
        startReaction = new StimuliEvent();
        startReaction.name = n"loreAnim";
        this.GetOwner().QueueEvent(startReaction);
      };
      if IsDefined(this.m_cacheSecuritySysOutput) {
        this.ReactToSecuritySystemOutputByTask(this.m_cacheSecuritySysOutput);
      };
      this.ReevaluateReactionPreset();
    };
    if Equals(additionalParam, n"LoreVictimSaved") {
      AnimationControllerComponent.SetAnimWrapperWeight(ownerPuppet, n"LoreVictimSaved", 0.00);
    };
    if Equals(additionalParam, n"Busy") {
      ownerPuppet.EnableInteraction(n"GenericTalk", true);
    };
  }

  protected cb func OnReactionFinishedEvent(evt: ref<ReactionFinishedEvent>) -> Bool {
    let crowdSettingsEvent: ref<CrowdSettingsEvent>;
    let mountInfo: MountingInfo;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    this.DeactiveLookAt();
    this.ResetFacial(this.m_facialCooldown);
    this.m_inReactionSequence = false;
    this.m_crowdFearStage = gameFearStage.Relaxed;
    this.GetOwnerPuppet().GetCrowdMemberComponent().ChangeFearStage(this.m_crowdFearStage);
    if VehicleComponent.IsMountedToVehicle(game, owner) {
      crowdSettingsEvent = new CrowdSettingsEvent();
      crowdSettingsEvent.movementType = n"panic";
      mountInfo = GameInstance.GetMountingFacility(game).GetMountingInfoSingleWithObjects(owner);
      GameInstance.FindEntityByID(game, mountInfo.parentId).QueueEvent(crowdSettingsEvent);
    };
  }

  protected cb func OnReevaluatePresetEvent(evt: ref<ReevaluatePresetEvent>) -> Bool {
    let setAggressiveMaskEvent: ref<SetAggressiveMask>;
    this.ReevaluateReactionPreset();
    this.CheckCrowd();
    if IsDefined(this.m_reactionPreset) && this.m_reactionPreset.IsAggressive() {
      setAggressiveMaskEvent = new SetAggressiveMask();
      this.GetOwnerPuppet().QueueEvent(setAggressiveMaskEvent);
    };
  }

  protected cb func OnReactionChangeRequestEvent(evt: ref<ReactionChangeRequestEvent>) -> Bool {
    this.SetReactionPreset(evt.reactionPresetRecord);
  }

  protected cb func OnPendingBehaviorChanged(value: Bool) -> Bool {
    let triggerAIEvent: ref<AIEvent>;
    if value {
      this.m_inPendingBehavior = true;
    } else {
      this.m_inPendingBehavior = false;
      triggerAIEvent = new AIEvent();
      triggerAIEvent.name = n"TriggerCombatReaction";
      this.GetOwnerPuppet().QueueEvent(triggerAIEvent);
    };
  }

  protected cb func OnAttitudeGroupChanged(evt: ref<AttitudeGroupChangedEvent>) -> Bool {
    if IsDefined(this.m_activeReaction) {
      this.ReevaluateReaction();
    };
  }

  protected cb func OnCrosswalkEvent(evt: ref<CrosswalkEvent>) -> Bool {
    let crowdMemberComponent: ref<CrowdMemberBaseComponent>;
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    if Equals(evt.oldTrafficLightColor, worldTrafficLightColor.INVALID) {
      this.m_isInCrosswalk = true;
    };
    if Equals(evt.trafficLightColor, worldTrafficLightColor.INVALID) {
      this.m_isInCrosswalk = false;
    };
    if Equals(evt.oldTrafficLightColor, worldTrafficLightColor.INVALID) || NotEquals(this.m_crowdFearStage, gameFearStage.Relaxed) {
      return false;
    };
    crowdMemberComponent = ownerPuppet.GetCrowdMemberComponent();
    if Equals(evt.trafficLightColor, worldTrafficLightColor.RED) {
      if evt.totalDistance - evt.distanceLeft <= 1.50 {
        crowdMemberComponent.TryChangeMovementDirection();
      } else {
        if evt.distanceLeft > 2.00 {
          crowdMemberComponent.ChangeMoveType(n"jog");
        };
      };
    } else {
      if Equals(evt.trafficLightColor, worldTrafficLightColor.YELLOW) {
        if evt.totalDistance - evt.distanceLeft <= 1.50 {
          crowdMemberComponent.TryChangeMovementDirection();
        } else {
          if evt.distanceLeft > 4.00 {
            crowdMemberComponent.ChangeMoveType(n"jog");
          };
        };
      } else {
        if Equals(evt.trafficLightColor, worldTrafficLightColor.GREEN) {
          crowdMemberComponent.ChangeMoveType(n"walk");
        } else {
          crowdMemberComponent.ChangeMoveType(n"walk");
        };
      };
    };
  }

  protected cb func OnBumpEvent(evt: ref<BumpEvent>) -> Bool {
    let blackboard: ref<IBlackboard>;
    let broadcaster: ref<StimBroadcasterComponent>;
    let crowdSettingsEvent: ref<CrowdSettingsEvent>;
    let distanceBuffer: Float;
    let distanceSquared: Float;
    let mountInfo: MountingInfo;
    let player: ref<GameObject>;
    let speedModifier: Float;
    let triggerDistance: Float;
    let vehicle: ref<VehicleObject>;
    let workspotSystem: ref<WorkspotGameSystem>;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let game: GameInstance = owner.GetGame();
    if !IsDefined(ownerPuppet) || !ownerPuppet.IsActive() {
      return false;
    };
    if Equals(this.m_reactionPreset.Type(), gamedataReactionPresetType.NoReaction) {
      return false;
    };
    if !this.m_initCrowd {
      this.InitCrowd();
      this.m_initCrowd = true;
    };
    player = this.GetPlayerSystem().GetLocalPlayerMainGameObject();
    if evt.isMounted {
      distanceBuffer = this.m_bumpTriggerDistanceBufferMounted;
    } else {
      if ScriptedPuppet.IsBeingGrappled(ownerPuppet) {
        return false;
      };
      blackboard = GameInstance.GetBlackboardSystem(game).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Crouch) {
        distanceBuffer = this.m_bumpTriggerDistanceBufferCrouched;
      };
    };
    mountInfo = GameInstance.GetMountingFacility(game).GetMountingInfoSingleWithObjects(player);
    vehicle = GameInstance.FindEntityByID(game, mountInfo.parentId) as VehicleObject;
    if evt.sourceSpeed > 15.00 {
      speedModifier = 3.50;
    } else {
      if evt.sourceSpeed > 10.00 {
        speedModifier = 2.50;
      } else {
        if evt.sourceSpeed > 5.00 {
          speedModifier = 1.50;
        } else {
          if evt.sourceSpeed > 1.50 {
            speedModifier = 0.50;
          };
        };
      };
    };
    distanceSquared = evt.sourceSquaredDistance;
    triggerDistance = evt.sourceRadius + this.m_NPCRadius + distanceBuffer + speedModifier;
    if evt.isMounted {
      if distanceSquared > triggerDistance * triggerDistance {
        return false;
      };
    } else {
      triggerDistance = evt.sourceRadius + this.m_NPCRadius + distanceBuffer;
      if distanceSquared > triggerDistance * triggerDistance {
        return false;
      };
    };
    if !GameObject.IsCooldownActive(ownerPuppet, n"bumpCooldown") {
      GameObject.StartCooldown(ownerPuppet, n"bumpCooldown", TDB.GetFloat(t"AIGeneralSettings.vehicleBumpCooldown"));
      if evt.isMounted {
        if !(ownerPuppet as NPCPuppet).IsRagdolling() && NotEquals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
          this.TriggerReactionBehaviorForCrowd(vehicle, gamedataOutput.DodgeToSide, false, evt.sourcePosition);
        };
      } else {
        if this.SourceAttitude(player, EAIAttitude.AIA_Friendly) {
          return false;
        };
        GameObject.PlayVoiceOver(owner, n"bump", n"Scripts:OnBumpEvent");
        broadcaster = player.GetStimBroadcasterComponent();
        workspotSystem = GameInstance.GetWorkspotSystem(game);
        if workspotSystem.IsActorInWorkspot(ownerPuppet) {
        } else {
          if this.m_inTrafficLane {
          } else {
            if this.m_inCrowd || this.IsReactionAvailableInPreset(gamedataStimType.Bump) {
              this.TriggerReactionBehaviorForCrowd(player, gamedataOutput.Bump, false);
            };
          };
        };
        if this.m_bumpReactionInProgress {
          if this.m_bumpTimestamp >= EngineTime.ToFloat(GameInstance.GetSimTime(game)) {
            this.m_bumpedRecently += 1;
            if this.m_inCrowd {
              NPCPuppet.ChangeHighLevelState(ownerPuppet, gamedataNPCHighLevelState.Fear);
              if this.m_bumpedRecently > 2 {
                if this.m_inTrafficLane {
                  crowdSettingsEvent = new CrowdSettingsEvent();
                  crowdSettingsEvent.movementType = n"walk";
                  this.GetDelaySystem().DelayEvent(ownerPuppet, crowdSettingsEvent, 1.20);
                  this.m_crowdFearStage = gameFearStage.Stressed;
                  ownerPuppet.GetCrowdMemberComponent().ChangeFearStage(this.m_crowdFearStage);
                  ownerPuppet.GetCrowdMemberComponent().AllowWorkspotsUsage(false);
                  this.m_desiredFearPhase = 1;
                  this.m_fastWalk = true;
                  AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ownerPuppet, this.GetFearAnimWrapper(this.m_desiredFearPhase), 1.00);
                  if !this.m_fearLocomotionWrapper {
                    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ownerPuppet, this.GetRandomFearLocomotionAnimWrapper(this.m_desiredFearPhase), 1.00);
                  };
                  this.m_fearLocomotionWrapper = true;
                } else {
                  this.TriggerFacialLookAtReaction(true, true);
                  if IsDefined(broadcaster) {
                    broadcaster.SendDrirectStimuliToTarget(ownerPuppet, gamedataStimType.Bump, ownerPuppet);
                  };
                };
              };
            } else {
              if this.m_reactionPreset.IsAggressive() && IsDefined(broadcaster) {
                if this.m_bumpedRecently <= 2 {
                  if workspotSystem.IsActorInWorkspot(ownerPuppet) && !ownerPuppet.IsConnectedToSecuritySystem() {
                    broadcaster.SendDrirectStimuliToTarget(ownerPuppet, gamedataStimType.Provoke, ownerPuppet);
                  } else {
                    if IsDefined(this.m_desiredReaction) {
                      this.m_desiredReaction.escalateProvoke = true;
                    };
                  };
                } else {
                  if !this.CanTriggerReprimandOrder() && IsDefined(this.m_activeReaction) && Equals(this.m_activeReaction.reactionBehaviorName, gamedataOutput.Bump) {
                    broadcaster.SendDrirectStimuliToTarget(ownerPuppet, gamedataStimType.Combat, ownerPuppet);
                  };
                };
              };
            };
          } else {
            this.m_bumpedRecently = 0;
            this.m_bumpReactionInProgress = false;
            if this.m_reactionPreset.IsAggressive() {
              if IsDefined(broadcaster) && workspotSystem.IsActorInWorkspot(ownerPuppet) && !ownerPuppet.IsConnectedToSecuritySystem() {
                broadcaster.SendDrirectStimuliToTarget(ownerPuppet, gamedataStimType.Provoke, ownerPuppet);
              };
            };
          };
        } else {
          this.m_bumpReactionInProgress = true;
          this.m_bumpedRecently += 1;
          this.m_bumpTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(game)) + 10.00;
          if this.m_inCrowd {
            this.TriggerFacialLookAtReaction(true);
          } else {
            if this.m_reactionPreset.IsAggressive() {
              if IsDefined(broadcaster) && workspotSystem.IsActorInWorkspot(ownerPuppet) && !ownerPuppet.IsConnectedToSecuritySystem() {
                broadcaster.SendDrirectStimuliToTarget(ownerPuppet, gamedataStimType.Provoke, ownerPuppet);
              };
            };
          };
        };
      };
    };
  }

  private final func PlayBumpInWorkspot(side: gameinteractionsBumpSide, direction: Vector4) -> Void {
    let reactionName: CName;
    let actor: wref<GameObject> = this.GetOwner();
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(actor.GetGame());
    let isBumpFromFront: Bool = Vector4.Dot2D(actor.GetWorldForward(), direction) < 0.00;
    switch side {
      case gameinteractionsBumpSide.Left:
        reactionName = isBumpFromFront ? n"BumpLeftFront" : n"BumpLeftBack";
        break;
      case gameinteractionsBumpSide.Right:
        reactionName = isBumpFromFront ? n"BumpRightFront" : n"BumpRightBack";
        break;
      default:
        return;
    };
    if workspotSystem.IsReactionAvailable(actor, reactionName) {
      workspotSystem.SendReactionSignal(actor, reactionName);
    };
  }

  protected cb func OnVehicleHit(evt: ref<gameVehicleHitEvent>) -> Bool {
    let instigator: ref<GameObject> = evt.attackData.GetInstigator();
    if !IsDefined(instigator) {
      return false;
    };
    if instigator.IsPlayer() {
      StimBroadcasterComponent.BroadcastStim(instigator, gamedataStimType.CrimeWitness);
    };
    if !GameObject.IsCooldownActive(this.GetOwner(), n"vehicleHitCooldown") {
      GameObject.StartCooldown(this.GetOwner(), n"vehicleHitCooldown", 1.00);
      StimBroadcasterComponent.BroadcastStim(instigator, gamedataStimType.VehicleHit, TweakDBInterface.GetFloat(t"AIGeneralSettings.vehicleHitFearSpreadRange", 5.00));
    };
  }

  protected cb func OnPlayerProximityStartEvent(evt: ref<PlayerProximityStartEvent>) -> Bool {
    let proximityLookatEvent: ref<ProximityLookatEvent>;
    let player: wref<PlayerPuppet> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) {
      return false;
    };
    if Equals(evt.profile, n"Crowds") {
      this.m_playerProximity = true;
      if this.m_inCrowd || !this.GetOwnerPuppet().IsConnectedToSecuritySystem() {
        if this.CanTriggerExpressionLookAt() {
          if this.IsTargetInFront(player, 45.00, true) && this.IsTargetInFront(player) {
            if this.m_inCrowd {
              this.ActivateReactionLookAt(player, true, true);
            } else {
              this.ActivateReactionLookAt(player, false);
            };
          };
          proximityLookatEvent = new ProximityLookatEvent();
          this.m_proximityLookatEventId = this.GetDelaySystem().DelayEvent(this.GetOwner(), proximityLookatEvent, 2.00);
        };
      };
    };
  }

  protected cb func OnPlayerProximityStopEvent(evt: ref<PlayerProximityStopEvent>) -> Bool {
    let delaySystem: ref<DelaySystem>;
    if this.m_playerProximity {
      this.m_playerProximity = false;
      if !this.m_inReactionSequence {
        this.DeactiveLookAt();
        this.ResetFacial(this.m_facialCooldown);
      };
    };
    delaySystem = GameInstance.GetDelaySystem(this.GetOwner().GetGame());
    delaySystem.CancelDelay(this.m_disturbComfortZoneEventId);
    delaySystem.CancelDelay(this.m_checkComfortZoneEventId);
    delaySystem.CancelDelay(this.m_proximityLookatEventId);
  }

  protected cb func OnProximityLookatEvent(evt: ref<ProximityLookatEvent>) -> Bool {
    let proximityLookatEvent: ref<ProximityLookatEvent>;
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).CancelDelay(this.m_proximityLookatEventId);
    if this.CanTriggerExpressionLookAt() {
      if this.m_playerProximity && this.IsTargetInFront(this.GetPlayerSystem().GetLocalPlayerControlledGameObject()) && this.IsTargetInFront(this.GetPlayerSystem().GetLocalPlayerControlledGameObject(), 45.00, true) {
        this.TriggerFacialLookAtReaction();
      } else {
        if this.m_playerProximity {
          proximityLookatEvent = new ProximityLookatEvent();
          this.m_proximityLookatEventId = this.GetDelaySystem().DelayEvent(this.GetOwner(), proximityLookatEvent, 1.50);
        };
      };
    };
  }

  protected cb func OnInCrowd(evt: ref<InCrowd>) -> Bool {
    this.m_inTrafficLane = true;
  }

  protected cb func OnOutOfCrowd(evt: ref<OutOfCrowd>) -> Bool {
    this.m_inTrafficLane = false;
  }

  public final func IsInTrafficLane() -> Bool {
    return this.m_inTrafficLane;
  }

  protected cb func OnSwapPreset(evt: ref<SwapPresetEvent>) -> Bool {
    if Equals(evt.mappingName, "Base") {
      this.SetBaseReactionPreset();
    } else {
      this.MapReactionPreset(evt.mappingName);
    };
  }

  protected cb func OnRainEvent(evt: ref<RainEvent>) -> Bool;

  protected cb func OnDistrurbComfortZoneAggressiveEvent(evt: ref<DistrurbComfortZoneAggressiveEvent>) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    this.m_backOffInProgress = true;
    this.m_backOffTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(owner.GetGame())) + 50.00;
    let broadcaster: ref<StimBroadcasterComponent> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject().GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.Provoke, owner);
    };
  }

  protected cb func OnAreaEnter(trigger: ref<AreaEnteredEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let distrurbComfortZoneAggressiveEvent: ref<DistrurbComfortZoneAggressiveEvent>;
    let owner: ref<GameObject> = this.GetOwner();
    let game: GameInstance = owner.GetGame();
    GameObject.PlayVoiceOver(owner, n"stlh_curious_grunt", n"Scripts:ProcessReactionOutput");
    this.ActivateReactionLookAt(GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject(), true);
    if this.m_backOffInProgress && this.m_backOffTimestamp >= EngineTime.ToFloat(GameInstance.GetSimTime(game)) {
      broadcaster = this.GetPlayerSystem().GetLocalPlayerControlledGameObject().GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.SendDrirectStimuliToTarget(owner, gamedataStimType.Provoke, owner);
      };
    } else {
      this.m_backOffInProgress = false;
      distrurbComfortZoneAggressiveEvent = new DistrurbComfortZoneAggressiveEvent();
      this.m_disturbComfortZoneAggressiveEventId = GameInstance.GetDelaySystem(game).DelayEvent(owner, distrurbComfortZoneAggressiveEvent, 2.00);
    };
  }

  protected cb func OnAreaExit(trigger: ref<AreaExitedEvent>) -> Bool {
    this.DeactiveLookAt();
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).CancelDelay(this.m_disturbComfortZoneAggressiveEventId);
  }

  protected cb func OnExplorationEnteredEvent(evt: ref<ExplorationEnteredEvent>) -> Bool {
    this.GetOwnerPuppet().GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, true);
  }

  protected cb func OnExplorationLeftEvent(evt: ref<ExplorationLeftEvent>) -> Bool {
    this.GetOwnerPuppet().GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, false);
  }
}

public static exec func SwapPreset(gameInstance: GameInstance, mappingName: String) -> Void {
  let swap: ref<SwapPresetEvent> = new SwapPresetEvent();
  swap.mappingName = mappingName;
  let localPlayer: ref<GameObject> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject();
  GameInstance.GetTargetingSystem(gameInstance).GetLookAtObject(localPlayer).QueueEvent(swap);
}
