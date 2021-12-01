
public class PlayerCombatController extends IScriptable {

  private let m_gameplayActiveFlagsRefreshPolicy: PlayerCombatControllerRefreshPolicy;

  private let m_blackboardIds: PlayerCombatControllerBBIds;

  private let m_blackboardValuesIds: PlayerCombatControllerBBValuesIds;

  private let m_blackboardListenersFunctions: PlayerCombatControllerBlackboardListenersFunctions;

  private let m_blackboardListeners: PlayerCombatControllerBBListeners;

  private let m_delayEventsIds: PlayerCombatControllerDelayCallbacksIds;

  private let m_gameplayActiveFlags: PlayerCombatControllerActiveFlags;

  private let m_otherVars: PlayerCombatControllerOtherVars;

  private let m_owner: wref<GameObject>;

  public final func RegisterOwner(owner: ref<GameObject>) -> Void {
    if this.m_owner != null {
      LogError("PlayerCombatController.RegisterOwner is stomping on a previously registered owner.");
      this.UnregisterBlackboardListeners();
    };
    this.m_owner = owner;
    if owner != null {
      this.InitPlayerCombatControllerRefreshPolicy();
      this.InitBlackboardIds();
      this.InitBlackboardValuesIds();
      this.InitBlackboardFunctions();
      this.RegisterBlackboardListeners();
    };
    this.InitOwnerVars(owner);
  }

  private final func InitOwnerVars(owner: ref<GameObject>) -> Void {
    this.m_gameplayActiveFlags.m_usingJhonnyReplacer = owner.IsReplacer();
  }

  public final func UnregisterOwner() -> Void {
    if this.m_owner == null {
      LogError("PlayerCombatController.UnregisterOwner has nothing to unregister.");
    } else {
      this.UnregisterBlackboardListeners();
    };
    this.m_owner = null;
  }

  private final func InitPlayerCombatControllerRefreshPolicy() -> Void {
    this.m_gameplayActiveFlagsRefreshPolicy.m_crouchActive = PlayerCombatControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_squadInCombat = PlayerCombatControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_usingJhonnyReplacer = PlayerCombatControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_usingQuickHack = PlayerCombatControllerRefreshPolicyEnum.Persistent;
  }

  private final func InitBlackboardIds() -> Void {
    this.m_blackboardIds.m_crouchActive = GetAllBlackboardDefs().PlayerStateMachine;
  }

  private final func InitBlackboardValuesIds() -> Void {
    this.m_blackboardValuesIds.m_crouchActive = GetAllBlackboardDefs().PlayerStateMachine.Locomotion;
  }

  private final func InitBlackboardFunctions() -> Void {
    this.m_blackboardListenersFunctions.m_crouchActive = n"OnCrouchActiveChanged";
  }

  private final func RegisterBlackboardListeners() -> Void {
    let bb: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    if this.m_owner != null {
      blackboardSystem = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    };
    if blackboardSystem != null {
      bb = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), this.m_blackboardIds.m_crouchActive);
      if bb != null {
        this.m_blackboardListeners.m_crouchActive = bb.RegisterListenerInt(this.m_blackboardValuesIds.m_crouchActive, this, this.m_blackboardListenersFunctions.m_crouchActive);
        Log("GOOD!!!");
      } else {
        Log("WAHT!!!!");
      };
    } else {
      LogError("PlayerCombatController.RegisterBlackboardListeners cannot register blackboard listeners.");
    };
  }

  private final func UnregisterBlackboardListeners() -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    blackboardSystem.Get(this.m_blackboardIds.m_crouchActive).UnregisterListenerInt(this.m_blackboardValuesIds.m_crouchActive, this.m_blackboardListeners.m_crouchActive);
  }

  private final func VerifyActivation() -> Void {
    if this.m_gameplayActiveFlags.m_crouchActive && !this.m_gameplayActiveFlags.m_squadInCombat && !this.m_gameplayActiveFlags.m_usingJhonnyReplacer {
      if NotEquals(this.m_otherVars.m_state, PlayerCombatState.Stealth) {
        this.InvalidateActivationState(PlayerCombatState.Stealth);
      };
    } else {
      if !this.m_gameplayActiveFlags.m_crouchActive && !this.m_gameplayActiveFlags.m_squadInCombat {
        if NotEquals(this.m_otherVars.m_state, PlayerCombatState.OutOfCombat) {
          this.InvalidateActivationState(PlayerCombatState.OutOfCombat);
        };
      } else {
        if this.m_gameplayActiveFlags.m_squadInCombat {
          if NotEquals(this.m_otherVars.m_state, PlayerCombatState.InCombat) {
            this.InvalidateActivationState(PlayerCombatState.InCombat);
          };
        };
      };
    };
  }

  private final func InvalidateActivationState(state: PlayerCombatState) -> Void {
    let invalidateEvent: ref<PlayerCombatControllerInvalidateEvent> = new PlayerCombatControllerInvalidateEvent();
    invalidateEvent.m_state = state;
    this.m_owner.QueueEvent(invalidateEvent);
  }

  public final func OnInvalidateActiveState(evt: ref<PlayerCombatControllerInvalidateEvent>) -> Void {
    this.m_otherVars.m_state = evt.m_state;
    switch evt.m_state {
      case PlayerCombatState.InCombat:
        this.ActivateCombat();
        break;
      case PlayerCombatState.OutOfCombat:
        this.ActivateOutOfCombat();
        break;
      case PlayerCombatState.Stealth:
        this.ActivateStealth();
    };
    this.ProcessFlagsRefreshPolicy();
  }

  private final func ProcessFlagsRefreshPolicy() -> Void {
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_crouchActive, PlayerCombatControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_crouchActive = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_squadInCombat, PlayerCombatControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_squadInCombat = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_usingJhonnyReplacer, PlayerCombatControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_usingJhonnyReplacer = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_usingQuickHack, PlayerCombatControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_usingQuickHack = false;
    };
  }

  private final func OnCrouchActiveChanged(value: Int32) -> Void {
    let active: Bool;
    let crouchDelayEvent: ref<CrouchDelayEvent> = new CrouchDelayEvent();
    if value == EnumInt(gamePSMLocomotionStates.Crouch) {
      active = true;
    } else {
      active = false;
    };
    if NotEquals(this.m_gameplayActiveFlags.m_crouchActive, active) {
      this.m_gameplayActiveFlags.m_crouchActive = active;
      if active {
        this.m_delayEventsIds.m_crouch = GameInstance.GetDelaySystem(this.m_owner.GetGame()).DelayEvent(this.m_owner, crouchDelayEvent, 0.15);
      } else {
        GameInstance.GetDelaySystem(this.m_owner.GetGame()).CancelCallback(this.m_delayEventsIds.m_crouch);
        this.m_gameplayActiveFlags.m_crouchTimerPassed = false;
        this.VerifyActivation();
      };
    };
  }

  public final func OnStartedBeingTrackedAsHostile(evt: ref<StartedBeingTrackedAsHostile>) -> Void {
    this.m_gameplayActiveFlags.m_squadInCombat = true;
    this.VerifyActivation();
  }

  public final func OnSquadStoppedBeingTracked() -> Void {
    this.m_gameplayActiveFlags.m_squadInCombat = false;
    this.VerifyActivation();
  }

  public final func OnCrouchDelayEvent(evt: ref<CrouchDelayEvent>) -> Void {
    if NotEquals(this.m_gameplayActiveFlags.m_crouchTimerPassed, true) {
      this.m_gameplayActiveFlags.m_crouchTimerPassed = true;
      this.VerifyActivation();
    };
  }

  public final func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>, gameplayTags: script_ref<array<CName>>) -> Void {
    if ArrayContains(Deref(gameplayTags), n"Quickhack") {
      if NotEquals(this.m_gameplayActiveFlags.m_usingQuickHack, true) {
        this.m_gameplayActiveFlags.m_usingQuickHack = true;
        this.VerifyActivation();
      };
    };
  }

  public final func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>, gameplayTags: script_ref<array<CName>>) -> Void {
    if ArrayContains(Deref(gameplayTags), n"Quickhack") {
      if NotEquals(this.m_gameplayActiveFlags.m_usingQuickHack, false) {
        this.m_gameplayActiveFlags.m_usingQuickHack = false;
        this.VerifyActivation();
      };
    };
  }

  private final func SetBlackboardIntVariable(id: BlackboardID_Int, value: Int32) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.SetInt(id, value);
  }

  public final const func GetBoolFromQuestDB(varName: CName) -> Bool {
    return GameInstance.GetQuestsSystem(this.m_owner.GetGame()).GetFact(varName) != 0;
  }

  private final func SendAnimFeatureData(inCombat: Bool) -> Void {
    let animFeature: ref<AnimFeature_CombatState> = new AnimFeature_CombatState();
    let evt: ref<AnimInputSetterAnimFeature> = new AnimInputSetterAnimFeature();
    animFeature.isInCombat = inCombat;
    evt.key = n"CombatData";
    evt.value = animFeature;
    this.m_owner.QueueEvent(evt);
  }

  private final func TutorialSetFact(factName: CName) -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_owner.GetGame());
    if questSystem.GetFact(factName) == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(factName, 1);
    };
  }

  private final const func IsRightHandInUnequippedState() -> Bool {
    return GameInstance.GetTransactionSystem(this.m_owner.GetGame()).IsSlotEmpty(this.m_owner, t"RightHand");
  }

  private final func ActivateCombat() -> Void {
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Combat, EnumInt(gamePSMCombat.InCombat));
    this.SendAnimFeatureData(true);
    PlayerPuppet.ReevaluateAllBreathingEffects(this.m_owner as PlayerPuppet);
    if !IsMultiplayer() && !Cast(GetFact(this.m_owner.GetGame(), n"story_mode")) && !this.m_owner.IsReplacer() {
      GameInstance.GetStatPoolsSystem(this.m_owner.GetGame()).RequestSettingModifierWithRecord(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration, t"BaseStatPools.PlayerBaseInCombatHealthRegen");
      GameInstance.GetStatPoolsSystem(this.m_owner.GetGame()).RequestSettingModifierWithRecord(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Memory, gameStatPoolModificationTypes.Regeneration, t"BaseStatPools.PlayerBaseInCombatMemoryRegen");
    };
    FastTravelSystem.AddFastTravelLock(n"InCombat", this.m_owner.GetGame());
    ChatterHelper.TryPlayEnterCombatChatter(this.m_owner);
    GameInstance.GetAudioSystem(this.m_owner.GetGame()).NotifyGameTone(n"EnterCombat");
    GameInstance.GetAudioSystem(this.m_owner.GetGame()).HandleCombatMix(this.m_owner);
    if !this.GetBoolFromQuestDB(n"block_combat_scripts_tutorials") && this.IsRightHandInUnequippedState() && !this.GetBoolFromQuestDB(n"disable_tutorials") {
      this.TutorialSetFact(n"combat_tutorial");
    };
    GameObjectEffectHelper.BreakEffectLoopEvent(this.m_owner, n"stealth_mode");
  }

  private final func ActivateStealth() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this.m_owner, n"stealth_mode", false);
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Combat, EnumInt(gamePSMCombat.Stealth));
  }

  private final func ActivateOutOfCombat() -> Void {
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Combat, EnumInt(gamePSMCombat.OutOfCombat));
    this.SendAnimFeatureData(false);
    PlayerPuppet.ReevaluateAllBreathingEffects(this.m_owner as PlayerPuppet);
    if !IsMultiplayer() && ScriptedPuppet.IsActive(this.m_owner) {
      GameInstance.GetStatPoolsSystem(this.m_owner.GetGame()).RequestSettingModifierWithRecord(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration, t"BaseStatPools.PlayerBaseOutOfCombatHealthRegen");
      GameInstance.GetStatPoolsSystem(this.m_owner.GetGame()).RequestSettingModifierWithRecord(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Memory, gameStatPoolModificationTypes.Regeneration, t"BaseStatPools.PlayerBaseOutOfCombatMemoryRegen");
    };
    ChatterHelper.TryPlayLeaveCombatChatter(this.m_owner);
    GameInstance.GetAudioSystem(this.m_owner.GetGame()).NotifyGameTone(n"LeaveCombat");
    GameInstance.GetAudioSystem(this.m_owner.GetGame()).HandleOutOfCombatMix(this.m_owner);
    FastTravelSystem.RemoveFastTravelLock(n"InCombat", this.m_owner.GetGame());
    GameObjectEffectHelper.BreakEffectLoopEvent(this.m_owner, n"stealth_mode");
  }
}
