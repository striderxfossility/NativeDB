
public class TakedownUtils extends IScriptable {

  public final static func SetInGrappleAnimFeature(scriptInterface: ref<StateGameScriptInterface>, b: Bool) -> Void {
    let animFeature: ref<AnimFeature_Grapple> = new AnimFeature_Grapple();
    animFeature.inGrapple = b;
    scriptInterface.SetAnimationParameterFeature(n"Grapple", animFeature, scriptInterface.executionOwner);
  }

  public final static func SetIgnoreLookAtEntity(scriptInterface: ref<StateGameScriptInterface>, target: wref<GameObject>, b: Bool) -> Void {
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    if Equals(b, true) {
      targetingSystem.AddIgnoredLookAtEntity(scriptInterface.executionOwner, target.GetEntityID());
    } else {
      targetingSystem.RemoveIgnoredLookAtEntity(scriptInterface.executionOwner, target.GetEntityID());
    };
  }

  public final static func TakedownActionNameToEnum(actionName: CName) -> ETakedownActionType {
    switch actionName {
      case n"GrappleFailed":
        return ETakedownActionType.GrappleFailed;
      case n"GrappleTarget":
        return ETakedownActionType.Grapple;
      case n"Takedown":
        return ETakedownActionType.Takedown;
      case n"TakedownNonLethal":
        return ETakedownActionType.TakedownNonLethal;
      case n"TakedownNetrunner":
        return ETakedownActionType.TakedownNetrunner;
      case n"TakedownMassiveTarget":
        return ETakedownActionType.TakedownMassiveTarget;
      case n"LeapToTarget":
        return ETakedownActionType.LeapToTarget;
      case n"AerialTakedown":
        return ETakedownActionType.AerialTakedown;
      case n"Struggle":
        return ETakedownActionType.Struggle;
      case n"BreakFree":
        return ETakedownActionType.BreakFree;
      case n"TargetDead":
        return ETakedownActionType.TargetDead;
      case n"KillTarget":
        return ETakedownActionType.KillTarget;
      case n"SpareTarget":
        return ETakedownActionType.SpareTarget;
      case n"ForceShove":
        return ETakedownActionType.ForceShove;
      case n"BossTakedown":
        return ETakedownActionType.BossTakedown;
      default:
    };
    return IntEnum(17l);
  }

  public final static func SetTakedownAction(stateContext: ref<StateContext>, actionName: ETakedownActionType) -> Void {
    let enumName: CName = EnumValueToName(n"ETakedownActionType", Cast(EnumInt(actionName)));
    stateContext.SetPermanentCNameParameter(n"ETakedownActionType", enumName, true);
  }

  public final static func SetTargetBodyType(executionOwner: wref<GameObject>, target: wref<GameObject>, enable: Bool) -> Void {
    let bodyType: CName;
    let bodyTypeVarSetter: ref<AnimWrapperWeightSetter>;
    let targetPuppet: ref<gamePuppet> = target as gamePuppet;
    if !IsDefined(targetPuppet) {
      return;
    };
    bodyType = targetPuppet.GetBodyType();
    bodyTypeVarSetter = new AnimWrapperWeightSetter();
    bodyTypeVarSetter.key = bodyType;
    bodyTypeVarSetter.value = enable ? 1.00 : 0.00;
    executionOwner.QueueEvent(bodyTypeVarSetter);
  }

  public final static func CleanUpGrappleState(caller: ref<DefaultTransition>, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, target: wref<GameObject>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    TakedownUtils.SetInGrappleAnimFeature(scriptInterface, false);
    (target as NPCPuppet).MountingEndEnableComponents();
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.HumanShield");
    StatusEffectHelper.RemoveStatusEffect(target, t"BaseStatusEffect.Grappled");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoRadialMenus");
    TakedownUtils.SetIgnoreLookAtEntity(scriptInterface, target, false);
    caller.SetGameplayCameraParameters(scriptInterface, "cameraDefault");
    TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(n""));
    TakedownUtils.SetTargetBodyType(scriptInterface.executionOwner, target, false);
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.RemoveActiveStimuliByName(scriptInterface.executionOwner, gamedataStimType.IllegalInteraction);
    };
    target.QueueEvent(new EnableAimAssist());
  }

  public final static func ExitWorkspot(scriptInterface: ref<StateGameScriptInterface>, owner: ref<GameObject>) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    workspotSystem.SendFastExitSignal(owner);
  }

  public final static func ShouldForceTakedown(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let tier: Int32;
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones) == EnumInt(gamePSMZones.Safe) {
      return true;
    };
    tier = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    if tier > EnumInt(gamePSMHighLevel.SceneTier1) && tier <= EnumInt(gamePSMHighLevel.SceneTier5) {
      return true;
    };
    return false;
  }
}

public class LocomotionTakedownDecisions extends LocomotionTransition {

  protected final const func IsTakedownAction(actionName: CName) -> Bool {
    return Equals(actionName, n"Takedown") || Equals(actionName, n"TakedownNonLethal") || Equals(actionName, n"TakedownNetrunner");
  }

  protected final const func IsTakedownAndDispose(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return 5 == scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown);
  }

  protected final const func IsPowerLevelDifferentialTooHigh(target: wref<GameObject>) -> Bool {
    let powDifference: EPowerDifferential = RPGManager.CalculatePowerDifferential(target);
    if Equals(powDifference, EPowerDifferential.IMPOSSIBLE) {
      return true;
    };
    return false;
  }

  protected final const func ShouldInstantlyBreakFree(target: wref<ScriptedPuppet>) -> Bool {
    if !IsDefined(target) {
      return false;
    };
    if target.IsMassive() {
      return this.IsPowerLevelDifferentialTooHigh(target);
    };
    return false;
  }
}

public class LocomotionTakedownEvents extends LocomotionEventsTransition {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final func JumpToIdleAnimation(scriptInterface: ref<StateGameScriptInterface>, target: wref<GameObject>) -> Void {
    this.JumpToAnimationWithID(scriptInterface, scriptInterface.executionOwner, 36, true);
    this.JumpToAnimationWithID(scriptInterface, target, 28, true);
  }

  protected final func JumpToWalkAnimation(scriptInterface: ref<StateGameScriptInterface>, target: wref<GameObject>) -> Void {
    this.JumpToAnimationWithID(scriptInterface, scriptInterface.executionOwner, 40, true);
    this.JumpToAnimationWithID(scriptInterface, target, 32, true);
  }

  protected final func JumpToStruggleAnimation(scriptInterface: ref<StateGameScriptInterface>, target: wref<GameObject>) -> Void {
    this.JumpToAnimationWithID(scriptInterface, scriptInterface.executionOwner, 32, true);
    this.JumpToAnimationWithID(scriptInterface, target, 19, true);
  }

  protected final const func IsTakedownAndDispose(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return 5 == scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown);
  }

  protected final func SetPlayerIsStandingAnimParameter(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.SetAnimationParameterFloat(n"crouch", 0.00);
  }

  protected final func SetGrappleDuration(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, grappleDuration: Float, target: ref<GameObject>) -> Void {
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let coolStat: Float = this.GetStatFloatValue(scriptInterface, gamedataStatType.Cool, statSystem, scriptInterface.executionOwner);
    let grappleTime: Float = grappleDuration + coolStat;
    stateContext.SetPermanentFloatParameter(n"grappleTime", grappleTime, true);
  }

  protected final func ForceTemporaryWeaponUnequip(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", value, true);
  }

  protected final func RequestTimeDilationActivation(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    return stateContext.SetTemporaryBoolParameter(n"requestKerenzikovActivation", true, true);
  }

  protected final func InterruptCameraAim(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetTemporaryBoolParameter(n"InterruptAiming", true, true);
  }

  protected final func GetRightHandItemObject(scriptInterface: ref<StateGameScriptInterface>) -> ref<ItemObject> {
    return scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
  }

  protected final func GetRightHandItemName(scriptInterface: ref<StateGameScriptInterface>) -> CName {
    return StringToName(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.GetRightHandItemObject(scriptInterface).GetItemID())).FriendlyName());
  }

  protected final func GetRightHandItemType(scriptInterface: ref<StateGameScriptInterface>) -> CName {
    return TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.GetRightHandItemObject(scriptInterface).GetItemID())).ItemType().Name();
  }

  protected final func IsTakedownWeapon(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetWeaponItemTag(stateContext, scriptInterface, n"TakedownWeapon");
  }

  protected final func FillAnimWrapperInfoBasedOnEquippedItem(scriptInterface: ref<StateGameScriptInterface>, clearWrapperInfo: Bool) -> Void {
    let animWrapperEvent: ref<FillAnimWrapperInfoBasedOnEquippedItem> = new FillAnimWrapperInfoBasedOnEquippedItem();
    animWrapperEvent.itemID = this.GetRightHandItemObject(scriptInterface).GetItemID();
    animWrapperEvent.itemType = this.GetRightHandItemType(scriptInterface);
    animWrapperEvent.itemName = this.GetRightHandItemName(scriptInterface);
    animWrapperEvent.clearWrapperInfo = clearWrapperInfo;
    scriptInterface.owner.QueueEventForEntityID(scriptInterface.executionOwnerEntityID, animWrapperEvent);
  }

  protected final func PlayExitAnimation(scriptInterface: ref<StateGameScriptInterface>, owner: ref<GameObject>, target: ref<GameObject>, syncedAnimName: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    workspotSystem.SendJumpToAnimEnt(owner, syncedAnimName, true);
  }

  protected final func JumpToNextAnimationInSequence(scriptInterface: ref<StateGameScriptInterface>, owner: ref<GameObject>) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    workspotSystem.SendForwardSignal(owner);
  }

  protected final func JumpToAnimationWithID(scriptInterface: ref<StateGameScriptInterface>, owner: ref<GameObject>, ownerEntryId: Int32, instant: Bool) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    workspotSystem.SendJumpCommandEnt(owner, ownerEntryId, instant);
  }

  protected final func SelectRandomSyncedAnimation(stateContext: ref<StateContext>) -> CName {
    let range: Int32;
    let takedownAction: String;
    let takedownName: CName;
    if this.GetStaticIntParameterDefault("DEBUG_forceSelectTakedownAnimation", -1) >= 0 {
      range = this.GetStaticIntParameterDefault("DEBUG_forceSelectTakedownAnimation", -1);
    } else {
      range = RandRange(0, 3);
    };
    if Equals(this.GetTakedownAction(stateContext), ETakedownActionType.Takedown) {
      takedownAction = NameToString(n"grapple_sync_kill");
    } else {
      if Equals(this.GetTakedownAction(stateContext), ETakedownActionType.TakedownNonLethal) {
        takedownAction = NameToString(n"grapple_sync_nonlethal");
      };
    };
    switch range {
      case 0:
        takedownName = StringToName(takedownAction);
        break;
      case 1:
        takedownAction += "_02";
        takedownName = StringToName(takedownAction);
        break;
      case 2:
        takedownAction += "_03";
        takedownName = StringToName(takedownAction);
        break;
      default:
        takedownName = StringToName(takedownAction);
    };
    return takedownName;
  }

  protected final func GetBossNameBasedOnRecord(target: ref<GameObject>) -> ETakedownBossName {
    let targetPuppet: wref<ScriptedPuppet> = target as ScriptedPuppet;
    switch targetPuppet.GetRecordID() {
      case t"Character.q116_boss_smasher":
      case t"Character.q113_boss_smasher":
      case t"Character.main_boss_adam_smasher":
        return ETakedownBossName.Smasher;
      case t"Character.Cyberninja_Oda":
      case t"Character.main_boss_oda":
        return ETakedownBossName.Oda;
      case t"Character.ma_bls_ina_se1_07_cyberpsycho_1":
      case t"Character.ma_std_rcr_11_cyberpsycho":
      case t"Character.militech_exo":
      case t"Character.arasaka_exo":
      case t"Character.q003_royce_boss":
      case t"Character.main_boss_royce":
        return ETakedownBossName.Royce;
      case t"Character.q110_animals_boss":
      case t"Character.q114_main_boss_sasquatch":
      case t"Character.main_boss_sasquatch":
        return ETakedownBossName.Sasquatch;
      default:
    };
    return IntEnum(4l);
  }

  protected final func GetCurrentBossPhase(target: ref<GameObject>, stateContext: ref<StateContext>, out phase: Int32) -> Void {
    let currentBossPhase: Int32;
    switch this.GetBossNameBasedOnRecord(target) {
      case ETakedownBossName.Smasher:
        if StatusEffectSystem.ObjectHasStatusEffect(target, t"AdamSmasher.Phase3") {
          currentBossPhase = 3;
        } else {
          if StatusEffectSystem.ObjectHasStatusEffect(target, t"AdamSmasher.Phase2") {
            currentBossPhase = 2;
          } else {
            if StatusEffectSystem.ObjectHasStatusEffect(target, t"AdamSmasher.Phase1") {
              currentBossPhase = 1;
            };
          };
        };
        break;
      case ETakedownBossName.Oda:
        if StatusEffectSystem.ObjectHasStatusEffect(target, t"Oda.Masked") {
          currentBossPhase = 1;
        } else {
          currentBossPhase = 2;
        };
        break;
      case ETakedownBossName.Royce:
        if !StatusEffectSystem.ObjectHasStatusEffect(target, t"Royce.Phase2") {
          currentBossPhase = 1;
        } else {
          currentBossPhase = 2;
        };
        break;
      case ETakedownBossName.Sasquatch:
        if StatusEffectSystem.ObjectHasStatusEffect(target, t"BaseStatusEffect.PainInhibitors") {
          currentBossPhase = 1;
        } else {
          currentBossPhase = 2;
        };
        break;
      default:
    };
    phase = currentBossPhase;
  }

  protected final func SelectSyncedAnimationBasedOnPhase(stateContext: ref<StateContext>, target: ref<GameObject>) -> CName {
    let bossSyncAnimName: String;
    let phase: Int32;
    let takedownName: CName;
    switch this.GetBossNameBasedOnRecord(target) {
      case ETakedownBossName.Smasher:
        bossSyncAnimName = "smasher_takedown_phase";
        break;
      case ETakedownBossName.Oda:
        bossSyncAnimName = "oda_takedown_phase";
        break;
      case ETakedownBossName.Royce:
        bossSyncAnimName = "royce_takedown_phase";
        break;
      case ETakedownBossName.Sasquatch:
        bossSyncAnimName = "sasquatch_takedown_phase";
        break;
      default:
    };
    this.GetCurrentBossPhase(target, stateContext, phase);
    if IsStringValid(bossSyncAnimName) {
      switch phase {
        case 1:
          takedownName = StringToName(bossSyncAnimName);
          break;
        case 2:
          bossSyncAnimName += "_02";
          takedownName = StringToName(bossSyncAnimName);
          break;
        case 3:
          bossSyncAnimName += "_03";
          takedownName = StringToName(bossSyncAnimName);
          break;
        case 4:
          bossSyncAnimName += "_04";
          takedownName = StringToName(bossSyncAnimName);
          break;
        default:
          takedownName = StringToName(bossSyncAnimName);
      };
    };
    stateContext.SetPermanentCNameParameter(n"syncedAnimationBasedOnPhaseName", takedownName, true);
    return takedownName;
  }

  protected final func GetSyncedAnimationBasedOnPhase(stateContext: ref<StateContext>) -> CName {
    let syncedAnimationName: CName;
    let param: StateResultCName = stateContext.GetPermanentCNameParameter(n"syncedAnimationBasedOnPhaseName");
    return syncedAnimationName = param.value;
  }

  protected final func SetEffectorBasedOnPhase(stateContext: ref<StateContext>) -> CName {
    let syncedAnimationString: String;
    let param: StateResultCName = stateContext.GetPermanentCNameParameter(n"syncedAnimationBasedOnPhaseName");
    let effectorBasedOnPhaseName: CName = param.value;
    if IsNameValid(effectorBasedOnPhaseName) {
      syncedAnimationString = NameToString(effectorBasedOnPhaseName);
      effectorBasedOnPhaseName = StringToName(syncedAnimationString + "_damage");
    };
    return effectorBasedOnPhaseName;
  }

  protected final func SelectSyncedAnimationBasedOnTargetFacing(owner: ref<GameObject>, target: ref<GameObject>, opt back: Bool, opt front: Bool, opt left: Bool, opt right: Bool, action: CName) -> CName {
    let takedown: String;
    let takedownName: CName = action;
    let result: CName = takedownName;
    let angleBetweenOwnerAndTarget: Float = Vector4.GetAngleBetween(owner.GetWorldForward(), target.GetWorldForward());
    if IsNameValid(takedownName) {
      if back && AbsF(angleBetweenOwnerAndTarget) < 90.00 {
        takedown = NameToString(takedownName);
        takedown += "_Back";
        takedownName = StringToName(takedown);
        result = takedownName;
      } else {
        if front && AbsF(angleBetweenOwnerAndTarget) >= 90.00 {
          result = takedownName;
        };
      };
    };
    return result;
  }

  protected final func SelectSyncedAnimationAndExecuteAction(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, owner: ref<GameObject>, target: ref<GameObject>, action: CName) -> Void {
    let effectTag: CName;
    let syncedAnimName: CName;
    let dataTrackingEvent: ref<TakedownActionDataTrackingRequest> = new TakedownActionDataTrackingRequest();
    let gameEffectName: CName = n"takedowns";
    switch this.GetTakedownAction(stateContext) {
      case ETakedownActionType.GrappleFailed:
        TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName, action, "");
        break;
      case ETakedownActionType.TargetDead:
        syncedAnimName = n"grapple_sync_death";
        break;
      case ETakedownActionType.BreakFree:
        syncedAnimName = n"grapple_sync_recover";
        break;
      case ETakedownActionType.Takedown:
        syncedAnimName = this.SelectRandomSyncedAnimation(stateContext);
        effectTag = n"kill";
        (target as NPCPuppet).SetMyKiller(owner);
        break;
      case ETakedownActionType.TakedownNonLethal:
        if stateContext.GetConditionBool(n"CrouchToggled") {
          syncedAnimName = n"grapple_sync_nonlethal_crouch";
        } else {
          syncedAnimName = this.SelectRandomSyncedAnimation(stateContext);
        };
        effectTag = n"setUnconscious";
        break;
      case ETakedownActionType.TakedownNetrunner:
        syncedAnimName = n"personal_link_takedown_01";
        effectTag = n"setUnconsciousTakedownNetrunner";
        break;
      case ETakedownActionType.TakedownMassiveTarget:
        TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName, action, "");
        effectTag = n"setUnconsciousTakedownMassiveTarget";
        break;
      case ETakedownActionType.AerialTakedown:
        TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName, this.SelectSyncedAnimationBasedOnTargetFacing(owner, target, true, true, false, false, action));
        effectTag = n"setUnconsciousAerialTakedown";
        break;
      case ETakedownActionType.BossTakedown:
        TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName, this.SelectSyncedAnimationBasedOnPhase(stateContext, target), "");
        effectTag = this.SetEffectorBasedOnPhase(stateContext);
        syncedAnimName = this.GetSyncedAnimationBasedOnPhase(stateContext);
        StatusEffectHelper.ApplyStatusEffect(target, t"BaseStatusEffect.BossTakedownCooldown");
        target.GetTargetTrackerComponent().AddThreat(owner, true, owner.GetWorldPosition(), 1.00, 10.00, false);
        break;
      case ETakedownActionType.ForceShove:
        syncedAnimName = n"grapple_sync_shove";
        break;
      default:
        syncedAnimName = n"grapple_sync_kill";
    };
    effectTag = n"kill";
    if IsNameValid(syncedAnimName) && IsDefined(owner) && IsDefined(target) {
      if this.IsTakedownWeapon(stateContext, scriptInterface) {
        this.FillAnimWrapperInfoBasedOnEquippedItem(scriptInterface, false);
      };
      this.PlayExitAnimation(scriptInterface, owner, target, syncedAnimName);
    };
    dataTrackingEvent.eventType = this.GetTakedownAction(stateContext);
    scriptInterface.GetScriptableSystem(n"DataTrackingSystem").QueueRequest(dataTrackingEvent);
    this.DefeatTarget(stateContext, scriptInterface, owner, target, gameEffectName, effectTag);
  }

  private final func DefeatTarget(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, activator: wref<GameObject>, target: wref<GameObject>, effectName: CName, effectTag: CName) -> Void {
    if Equals(effectTag, n"setUnconscious") || Equals(effectTag, n"setUnconsciousAerialTakedown") || Equals(effectTag, n"setUnconsciousTakedownMassiveTarget") {
      ScriptedPuppet.SendActionSignal(target as NPCPuppet, n"takedown_defeat", -1.00);
    };
    TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, activator, target, effectName, effectTag);
    ScriptedPuppet.SetBloodPuddleSettings(target as ScriptedPuppet, false);
  }

  public final func TestNPCOutsideNavmesh(scriptInterface: ref<StateGameScriptInterface>, activator: wref<GameObject>, target: wref<GameObject>, timeToTick: Float, b: Bool) -> Void {
    let evt: ref<TestNPCOutsideNavmeshEvent>;
    if !IsDefined(target) {
      return;
    };
    evt = new TestNPCOutsideNavmeshEvent();
    evt.activator = activator;
    evt.target = target;
    evt.enable = b;
    scriptInterface.GetDelaySystem().DelayEvent(target, evt, timeToTick);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    TakedownUtils.ExitWorkspot(scriptInterface, scriptInterface.executionOwner);
    TakedownUtils.CleanUpGrappleState(this, stateContext, scriptInterface, this.stateMachineInitData.target);
  }
}

public class TakedownBeginDecisions extends LocomotionTakedownDecisions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class TakedownBeginEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let targetPuppet: ref<gamePuppet> = this.stateMachineInitData.target as gamePuppet;
    TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(this.stateMachineInitData.actionName));
    TakedownUtils.SetTargetBodyType(scriptInterface.executionOwner, this.stateMachineInitData.target, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.EnteringGrapple));
    TakedownUtils.SetInGrappleAnimFeature(scriptInterface, true);
    targetPuppet.QueueEvent(new DisableAimAssist());
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoRadialMenus");
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class TakedownLeapToPreyDecisions extends LocomotionTakedownDecisions {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if Equals(this.stateMachineInitData.actionName, n"LeapToTarget") {
      return true;
    };
    return false;
  }

  protected final const func ToTakedownExecuteTakedown(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.TestTakedownEnterConditions(stateContext, scriptInterface);
  }

  protected final const func ToTakedownEnd(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("maxDuration", 3.00) {
      return true;
    };
    if this.CollisionBetweenPlayerAndTarget(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func TestTakedownEnterConditions(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.CollisionBetweenPlayerAndTarget(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }

  protected final const func CollisionBetweenPlayerAndTarget(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let queryFilter: QueryFilter;
    let currentPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    QueryFilter.AddGroup(queryFilter, n"Static");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.AddFlag(worldgeometryDescriptionQueryFlags.DistanceVector);
    geometryDescription.filter = queryFilter;
    geometryDescription.refPosition = currentPosition;
    geometryDescription.refDirection = new Vector4(0.00, 0.00, -1.00, 0.00);
    geometryDescription.primitiveDimension = new Vector4(0.20, 0.10, 0.10, 0.00);
    geometryDescription.maxDistance = 0.50;
    geometryDescription.maxExtent = 0.50;
    geometryDescription.probingPrecision = 10.00;
    geometryDescription.probingMaxDistanceDiff = 0.50;
    geometryDescriptionResult = scriptInterface.GetSpatialQueriesSystem().GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    if Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.NoGeometry) {
      return false;
    };
    return true;
  }
}

public class TakedownLeapToPreyEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.StopEffect(scriptInterface, n"falling");
    this.PlaySound(n"lcm_falling_wind_loop_end", scriptInterface);
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.Leap));
  }

  private final func RequestPositionAdjustmentWithParabolicMotion(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let additionalHorizontalDistance: Float;
    let adjustPosition: Vector4;
    let distanceFromTarget: Vector4;
    let horizontalDistanceFromTarget: Float;
    let playerPuppetOrientation: Quaternion;
    let safetyDisplacement: Vector4;
    let scaledSafetyDisplacement: Vector4;
    safetyDisplacement.Y = this.GetStaticFloatParameterDefault("horizontalDisplacement", 0.00);
    if IsDefined(this.stateMachineInitData.target) {
      playerPuppetOrientation = scriptInterface.executionOwner.GetWorldOrientation();
      distanceFromTarget = this.stateMachineInitData.target.GetWorldPosition() - scriptInterface.executionOwner.GetWorldPosition();
      if distanceFromTarget.Z > 0.00 {
        safetyDisplacement.Y = safetyDisplacement.Y * this.GetStaticFloatParameterDefault("horizontalDisplacementTargetAbovePlayer", 0.00);
      };
      horizontalDistanceFromTarget = Vector4.Length2D(distanceFromTarget);
      additionalHorizontalDistance = MaxF(safetyDisplacement.Y - horizontalDistanceFromTarget, 0.00);
      scaledSafetyDisplacement = safetyDisplacement * additionalHorizontalDistance;
      adjustPosition = Quaternion.Transform(playerPuppetOrientation, scaledSafetyDisplacement);
    };
    this.RequestPlayerPositionAdjustment(stateContext, scriptInterface, this.stateMachineInitData.target, this.GetStaticFloatParameterDefault("slideDuration", 0.00), this.GetStaticFloatParameterDefault("distanceRadius", 0.00), this.GetStaticFloatParameterDefault("rotationDuration", 0.00), adjustPosition, true);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class TakedownSlideToPreyDecisions extends LocomotionTakedownDecisions {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.stateMachineInitData.actionName, n"GrappleTarget");
  }
}

public class TakedownSlideToPreyEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetPlayerIsStandingAnimParameter(scriptInterface);
    stateContext.SetTemporaryBoolParameter(n"requestSandevistanDeactivation", true, true);
    (this.stateMachineInitData.target as NPCPuppet).MountingStartDisableComponents();
    this.SetLocomotionParameters(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class TakedownGrapplePreyDecisions extends LocomotionTakedownDecisions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class TakedownGrapplePreyEvents extends LocomotionTakedownEvents {

  @default(TakedownGrapplePreyEvents, false)
  public let m_isGrappleReactionVOPlayed: Bool;

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let grappleContextName: CName;
    let puppetOwner: wref<ScriptedPuppet>;
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if !this.m_isGrappleReactionVOPlayed && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("delayToPlayNPCReactionVO", 0.40) {
      grappleContextName = n"grapple";
      puppetOwner = scriptInterface.executionOwner as ScriptedPuppet;
      if IsDefined(puppetOwner) && NotEquals(puppetOwner.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
        grappleContextName = n"grapple_grunt";
      };
      GameObject.PlayVoiceOver(this.stateMachineInitData.target, grappleContextName, n"Scripts:TakedownGrapplePreyEvents");
      this.m_isGrappleReactionVOPlayed = true;
    };
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_isGrappleReactionVOPlayed = false;
    this.ForceTemporaryWeaponUnequip(stateContext, scriptInterface, true);
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.SetGameplayCameraParameters(scriptInterface, "cameraGrapple");
    this.InterruptCameraAim(stateContext, scriptInterface);
    this.TriggerNoiseStim(scriptInterface.executionOwner, ETakedownActionType.Grapple);
    TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, scriptInterface.executionOwner, this.stateMachineInitData.target, n"takedowns", this.stateMachineInitData.actionName, "");
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class TakedownGrappleFailedDecisions extends LocomotionTakedownDecisions {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ShouldInstantlyBreakFree(this.stateMachineInitData.target as ScriptedPuppet);
  }
}

public class TakedownGrappleFailedEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(n"GrappleFailed"));
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.TriggerNoiseStim(scriptInterface.executionOwner, ETakedownActionType.GrappleFailed);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class GrappleMountDecisions extends LocomotionTakedownDecisions {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let workSpotInfo: ref<ExtendedWorkspotInfo>;
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("transitionTime", 0.60) {
      workSpotInfo = scriptInterface.GetWorkspotSystem().GetExtendedInfo(scriptInterface.executionOwner);
      if workSpotInfo.isActive {
        return true;
      };
    };
    return false;
  }
}

public class GrappleMountEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo;
    let slotId: MountingSlotId;
    let mountEvent: ref<MountingRequest> = new MountingRequest();
    slotId.id = n"grapple";
    mountingInfo.childId = this.stateMachineInitData.target.GetEntityID();
    mountingInfo.parentId = scriptInterface.executionOwnerEntityID;
    mountingInfo.slotId = slotId;
    mountEvent.lowLevelMountingInfo = mountingInfo;
    scriptInterface.GetMountingFacility().Mount(mountEvent);
    this.SetLocomotionParameters(stateContext, scriptInterface);
  }
}

public class GrappleStandDecisions extends LocomotionTakedownDecisions {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final const func ToTakedownExecuteTakedown(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsTakedownAction(this.stateMachineInitData.actionName) {
      return true;
    };
    if TakedownUtils.ShouldForceTakedown(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToTakedownExecuteTakedownAndDispose(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsTakedownAndDispose(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToGrappleStruggle(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= stateContext.GetFloatParameter(n"grappleTime", true) {
      return this.IsBreakingFreeAllowed(stateContext, scriptInterface);
    };
    if this.IsDeepEnoughToSwim(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func IsBreakingFreeAllowed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"GrappleNoBreakFree") {
      return false;
    };
    return true;
  }

  protected final const func ToGrappleBreakFree(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsPowerLevelDifferentialTooHigh(this.stateMachineInitData.target) {
      return this.IsBreakingFreeAllowed(stateContext, scriptInterface);
    };
    return false;
  }
}

public class GrappleStandEvents extends LocomotionTakedownEvents {

  @default(GrappleStandEvents, false)
  public let m_isWalking: Bool;

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if !this.m_isWalking && this.IsPreferredWalkingSpeed(stateContext, scriptInterface) {
      this.JumpToWalkAnimation(scriptInterface, this.stateMachineInitData.target);
      this.m_isWalking = true;
    } else {
      if this.m_isWalking && !this.IsPreferredWalkingSpeed(stateContext, scriptInterface) {
        this.JumpToIdleAnimation(scriptInterface, this.stateMachineInitData.target);
        this.m_isWalking = false;
      };
    };
  }

  protected final func IsPreferredWalkingSpeed(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) > 1.00;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_isWalking = false;
    this.SetLocomotionCameraParameters(stateContext, scriptInterface);
    TakedownUtils.SetIgnoreLookAtEntity(scriptInterface, this.stateMachineInitData.target, true);
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.HumanShield");
    this.SetGrappleDuration(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("stateDuration", 5.00), this.stateMachineInitData.target);
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.Grapple));
    ScriptedPuppet.EvaluateApplyingStatusEffectsFromMountedObjectToPlayer(this.stateMachineInitData.target, scriptInterface.executionOwner);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class GrappleStruggleDecisions extends LocomotionTakedownDecisions {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final const func ToTakedownExecuteTakedown(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsTakedownAction(this.stateMachineInitData.actionName) {
      return true;
    };
    if TakedownUtils.ShouldForceTakedown(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToTakedownExecuteTakedownAndDispose(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsTakedownAndDispose(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class GrappleStruggleEvents extends GrappleStandEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetLocomotionCameraParameters(stateContext, scriptInterface);
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.JumpToStruggleAnimation(scriptInterface, this.stateMachineInitData.target);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class GrapplePreyDeadDecisions extends GrappleStandEvents {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !ScriptedPuppet.IsAlive(this.stateMachineInitData.target) {
      return true;
    };
    if ScriptedPuppet.IsDefeated(this.stateMachineInitData.target) {
      return true;
    };
    return false;
  }
}

public class GrappleFallDecisions extends FallDecisions {

  protected final const func ToGrappleStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ToRegularLand(stateContext, scriptInterface) || this.ToHardLand(stateContext, scriptInterface) || this.ToVeryHardLand(stateContext, scriptInterface);
  }
}

public class GrappleFallEvents extends FallEvents {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    TakedownUtils.ExitWorkspot(scriptInterface, scriptInterface.executionOwner);
    TakedownUtils.CleanUpGrappleState(this, stateContext, scriptInterface, this.stateMachineInitData.target);
  }
}

public class GrapplePreyDeadEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.ForceTemporaryWeaponUnequip(stateContext, scriptInterface, true);
    TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(n"TargetDead"));
    this.SelectSyncedAnimationAndExecuteAction(stateContext, scriptInterface, scriptInterface.executionOwner, this.stateMachineInitData.target, n"TargetDead");
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class GrappleForceShovePreyDecisions extends GrappleStandDecisions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if Equals(this.stateMachineInitData.actionName, n"ForceShove") {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Fall) == EnumInt(gamePSMFallStates.FastFall) {
      return true;
    };
    return false;
  }
}

public class GrappleForceShovePreyEvents extends LocomotionTakedownEvents {

  public let m_unmountCalled: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetLocomotionParameters(stateContext, scriptInterface);
    TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(n"ForceShove"));
    this.SelectSyncedAnimationAndExecuteAction(stateContext, scriptInterface, scriptInterface.executionOwner, this.stateMachineInitData.target, n"ForceShove");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.Takedown));
    StatusEffectHelper.ApplyStatusEffectForTimeWindow(this.stateMachineInitData.target, t"BaseStatusEffect.UncontrolledMovement_Default", scriptInterface.executionOwnerEntityID, 0.00, 1.00);
    this.m_unmountCalled = false;
    GameObject.PlayVoiceOver(this.stateMachineInitData.target, n"shove", n"Scripts:GrappleForceShovePreyEvents");
  }

  protected final func UnmountPrey(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo;
    let unmountEvent: ref<UnmountingRequest> = new UnmountingRequest();
    mountingInfo.childId = this.stateMachineInitData.target.GetEntityID();
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    scriptInterface.GetMountingFacility().Unmount(unmountEvent);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if !this.m_unmountCalled && this.GetInStateTime() > 0.30 {
      this.UnmountPrey(scriptInterface);
      this.m_unmountCalled = true;
    };
  }

  protected final func InitiateForceShoveAttack(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let colliderBox: Vector4;
    let endPosition: Vector4;
    let startPosition: Vector4;
    startPosition.X = 0.00;
    startPosition.Y = 0.00;
    startPosition.Z = 0.00;
    endPosition.X = 0.00;
    endPosition.Y = this.GetStaticFloatParameterDefault("shoveGameEffectRange", 1.00);
    endPosition.Z = 0.00;
    let dir: Vector4 = endPosition - startPosition;
    colliderBox.X = 1.30;
    colliderBox.Y = 1.30;
    colliderBox.Z = 1.30;
    let attackTime: Float = this.GetStaticFloatParameterDefault("shoveGameEffectDuration", 0.20);
    if dir.Y != 0.00 {
      endPosition.Y = this.GetStaticFloatParameterDefault("shoveGameEffectRange", 1.00);
    };
    this.SpawnShoveAttackGameEffect(stateContext, scriptInterface, startPosition, endPosition, attackTime, colliderBox);
  }

  protected final func SpawnShoveAttackGameEffect(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, startPosition: Vector4, endPosition: Vector4, attackTime: Float, colliderBox: Vector4) -> Void {
    let effect: ref<EffectInstance>;
    let initContext: AttackInitContext;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let attackStartPositionWorld: Vector4 = Transform.TransformPoint(cameraWorldTransform, startPosition);
    attackStartPositionWorld.W = 0.00;
    let attackEndPositionWorld: Vector4 = Transform.TransformPoint(cameraWorldTransform, endPosition);
    attackEndPositionWorld.W = 0.00;
    let attackDirectionWorld: Vector4 = attackEndPositionWorld - attackStartPositionWorld;
    let attackRecord: ref<Attack_Record> = TweakDBInterface.GetAttackRecord(t"Attacks.ForwardPush");
    initContext.record = attackRecord;
    initContext.source = scriptInterface.executionOwner;
    initContext.instigator = scriptInterface.executionOwner;
    let attack: ref<Attack_GameEffect> = IAttack.Create(initContext) as Attack_GameEffect;
    if IsDefined(attack) {
      effect = attack.PrepareAttack(scriptInterface.executionOwner);
    };
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.box, colliderBox);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, attackTime);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, attackStartPositionWorld);
    EffectData.SetQuat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Transform.GetOrientation(cameraWorldTransform));
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, Vector4.Normalize(attackDirectionWorld));
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, Vector4.Length(attackDirectionWorld));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    attack.StartAttack();
  }

  protected func OnExitToTakedownReleasePrey(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SendDrirectStimuliToTarget(scriptInterface.executionOwner, gamedataStimType.Combat, this.stateMachineInitData.target);
    };
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class GrappleBreakFreeDecisions extends GrappleStandEvents {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 4.50) {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vitals) == EnumInt(gamePSMVitals.Dead) {
      return true;
    };
    if Equals(this.GetTakedownAction(stateContext), ETakedownActionType.GrappleFailed) {
      return true;
    };
    if this.IsDeepEnoughToSwim(scriptInterface) && this.GetInStateTime() >= 0.60 {
      return true;
    };
    return false;
  }
}

public class GrappleBreakFreeEvents extends GrappleStandEvents {

  public let playerPositionVerified: Bool;

  public let shouldPushPlayerAway: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let takedownEndEvent: ref<EndTakedownEvent>;
    this.playerPositionVerified = false;
    if stateContext.GetConditionBool(n"CrouchToggled") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    };
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.ForceTemporaryWeaponUnequip(stateContext, scriptInterface, true);
    if Equals(this.GetTakedownAction(stateContext), ETakedownActionType.GrappleFailed) {
      this.SelectSyncedAnimationAndExecuteAction(stateContext, scriptInterface, scriptInterface.executionOwner, this.stateMachineInitData.target, n"GrappleFailed");
    } else {
      TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(n"BreakFree"));
      this.SelectSyncedAnimationAndExecuteAction(stateContext, scriptInterface, scriptInterface.executionOwner, this.stateMachineInitData.target, n"BreakFree");
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.Takedown));
    takedownEndEvent = new EndTakedownEvent();
    scriptInterface.owner.QueueEvent(takedownEndEvent);
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Combat);
    };
    if !GameInstance.GetAINavigationSystem(scriptInterface.GetGame()).HasPathForward(this.stateMachineInitData.target, 1.00) || !SpatialQueriesHelper.HasSpaceInFront(scriptInterface.executionOwner, 0.35, 0.90, 1.50, 1.25) {
      this.shouldPushPlayerAway = true;
    } else {
      this.shouldPushPlayerAway = false;
      StatusEffectHelper.ApplyStatusEffectForTimeWindow(this.stateMachineInitData.target, t"BaseStatusEffect.UncontrolledMovement_Default", scriptInterface.executionOwnerEntityID, 1.00 - this.GetStaticFloatParameterDefault("playerPositionAdjustmentTime", 0.40), 0.80);
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let pushDistance: Float;
    if !this.playerPositionVerified && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("playerPositionAdjustmentTime", 0.40) {
      this.playerPositionVerified = true;
      if this.shouldPushPlayerAway {
        pushDistance = this.GetStaticFloatParameterDefault("adjustmentDistance", 1.00);
        this.RequestPlayerPositionAdjustment(stateContext, scriptInterface, null, 0.10, 0.00, 0.00, scriptInterface.executionOwner.GetWorldPosition() - pushDistance * scriptInterface.executionOwner.GetWorldForward(), true);
      };
    };
  }
}

public class TakedownExecuteTakedownEvents extends LocomotionTakedownEvents {

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let actionName: CName;
    if TakedownUtils.ShouldForceTakedown(scriptInterface) {
      actionName = n"TakedownNonLethal";
    } else {
      actionName = this.stateMachineInitData.actionName;
    };
    if Equals(this.GetTakedownAction(stateContext), ETakedownActionType.LeapToTarget) {
      actionName = n"AerialTakedown";
    };
    TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(actionName));
    this.ForceTemporaryWeaponUnequip(stateContext, scriptInterface, true);
    this.SelectSyncedAnimationAndExecuteAction(stateContext, scriptInterface, scriptInterface.executionOwner, this.stateMachineInitData.target, actionName);
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.Takedown));
    if !scriptInterface.HasStatFlag(gamedataStatType.CanTakedownSilently) {
      this.TriggerNoiseStim(scriptInterface.executionOwner, TakedownUtils.TakedownActionNameToEnum(actionName));
    };
    if Equals(this.GetTakedownAction(stateContext), ETakedownActionType.TakedownNonLethal) && stateContext.GetConditionBool(n"CrouchToggled") {
      scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
    };
    GameInstance.GetTelemetrySystem(scriptInterface.GetGame()).LogTakedown(actionName, this.stateMachineInitData.target);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class TakedownExecuteTakedownAndDisposeDecisions extends LocomotionTakedownDecisions {

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !DefaultTransition.IsInWorkspot(scriptInterface);
  }
}

public class TakedownExecuteTakedownAndDisposeEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetStaticBoolParameterDefault("exitToStandState", true) {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    TakedownUtils.CleanUpGrappleState(this, stateContext, scriptInterface, this.stateMachineInitData.target);
  }
}

public class TakedownReleasePreyDecisions extends LocomotionTakedownDecisions {

  public const let stateMachineInitData: wref<LocomotionTakedownInitData>;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() > 0.10 && !DefaultTransition.IsInWorkspot(scriptInterface) {
      return true;
    };
    if !this.stateMachineInitData.target.IsAttached() {
      return true;
    };
    return false;
  }
}

public class TakedownReleasePreyEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    TakedownUtils.ExitWorkspot(scriptInterface, scriptInterface.executionOwner);
    this.SetGameplayCameraParameters(scriptInterface, "cameraDefault");
    this.SetLocomotionParameters(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class TakedownUnmountPreyDecisions extends LocomotionTakedownDecisions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class TakedownUnmountPreyEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo;
    let unmountEvent: ref<UnmountingRequest> = new UnmountingRequest();
    mountingInfo.childId = this.stateMachineInitData.target.GetEntityID();
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    scriptInterface.GetMountingFacility().Unmount(unmountEvent);
    this.SetLocomotionParameters(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    TakedownUtils.CleanUpGrappleState(this, stateContext, scriptInterface, this.stateMachineInitData.target);
  }
}

public class PickUpBodyAfterTakedownDecisions extends LocomotionTakedownDecisions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.HasStatFlag(gamedataStatType.CanPickUpBodyAfterTakedown) && scriptInterface.GetActionValue(n"PickUpBodyFromTakedown") > 0.00 && scriptInterface.GetActionStateTime(n"PickUpBodyFromTakedown") >= 0.10 {
      return Equals(this.GetTakedownAction(stateContext), ETakedownActionType.Takedown) || Equals(this.GetTakedownAction(stateContext), ETakedownActionType.TakedownNonLethal);
    };
    return false;
  }
}

public class PickUpBodyAfterTakedownEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let addCarriedObjectSM: ref<PSMAddOnDemandStateMachine>;
    let addLocomotionSM: ref<PSMAddOnDemandStateMachine>;
    TakedownUtils.SetTakedownAction(stateContext, TakedownUtils.TakedownActionNameToEnum(this.stateMachineInitData.actionName));
    addCarriedObjectSM = new PSMAddOnDemandStateMachine();
    addCarriedObjectSM.owner = this.stateMachineInitData.target;
    addCarriedObjectSM.stateMachineName = n"CarriedObject";
    scriptInterface.executionOwner.QueueEvent(addCarriedObjectSM);
    addLocomotionSM = new PSMAddOnDemandStateMachine();
    addLocomotionSM.stateMachineName = n"Locomotion";
    scriptInterface.executionOwner.QueueEvent(addLocomotionSM);
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.Default));
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class TakedownEndDecisions extends LocomotionTakedownDecisions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class TakedownEndEvents extends LocomotionTakedownEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    swapEvent.stateMachineName = n"Locomotion";
    scriptInterface.executionOwner.QueueEvent(swapEvent);
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Takedown, EnumInt(gamePSMTakedown.Default));
    this.ForceTemporaryWeaponUnequip(stateContext, scriptInterface, false);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}
