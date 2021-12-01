
public class MemoryListener extends CustomValueStatPoolsListener {

  public let m_player: wref<PlayerPuppet>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let uiBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    uiBlackboard.SetFloat(GetAllBlackboardDefs().UI_PlayerBioMonitor.MemoryPercent, newValue);
    if GameInstance.GetStatsSystem(this.m_player.GetGame()).GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.AutomaticReplenishment) != 0.00 {
      if FloorF(newValue) == 0 {
        GameInstance.GetStatPoolsSystem(this.m_player.GetGame()).RequestSettingStatPoolValue(Cast(this.m_player.GetEntityID()), gamedataStatPoolType.Memory, 100.00, this.m_player);
      };
    };
  }
}

public class StaminaListener extends CustomValueStatPoolsListener {

  public let m_player: wref<PlayerPuppet>;

  public let m_psmAdded: Bool;

  public let m_staminaValue: Float;

  public let m_staminPerc: Float;

  public final func Init(player: wref<PlayerPuppet>) -> Void {
    this.m_psmAdded = false;
    this.m_player = player;
    this.m_staminaValue = 100.00;
    this.m_staminPerc = 100.00;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let addEvent: ref<PSMAddOnDemandStateMachine>;
    let removeEvent: ref<PSMRemoveOnDemandStateMachine>;
    let stateMachineIdentifier: StateMachineIdentifier;
    this.m_staminPerc = newValue;
    this.m_staminaValue = newValue * percToPoints;
    if !this.m_psmAdded && newValue < 100.00 {
      addEvent = new PSMAddOnDemandStateMachine();
      addEvent.stateMachineName = n"Stamina";
      this.m_player.QueueEvent(addEvent);
      this.m_psmAdded = true;
    } else {
      if this.m_psmAdded && newValue >= 100.00 {
        stateMachineIdentifier.definitionName = n"Stamina";
        removeEvent = new PSMRemoveOnDemandStateMachine();
        removeEvent.stateMachineIdentifier = stateMachineIdentifier;
        this.m_player.QueueEvent(removeEvent);
        this.m_psmAdded = false;
      };
    };
  }

  public final func GetStaminaValue() -> Float {
    return this.m_staminaValue;
  }

  public final func GetStaminaPerc() -> Float {
    return this.m_staminPerc;
  }
}

public class AimAssistSettingsListener extends ConfigVarListener {

  private let m_ctrl: wref<PlayerPuppet>;

  private let m_settings: ref<UserSettings>;

  private let m_settingsGroup: ref<ConfigGroup>;

  private let m_aimAssistLevel: EAimAssistLevel;

  private let m_aimAssistMeleeLevel: EAimAssistLevel;

  public let m_currentConfigString: String;

  public let m_settingsRecord: ref<AimAssistSettings_Record>;

  public final func Initialize(ctrl: wref<PlayerPuppet>) -> Void {
    this.m_ctrl = ctrl;
    this.m_settings = GameInstance.GetSettingsSystem(this.m_ctrl.GetGame());
    this.m_settingsGroup = this.m_settings.GetGroup(n"/gameplay/difficulty");
    let aimAssistVar: ref<ConfigVarListInt> = this.m_settingsGroup.GetVar(n"AimAssistanceMelee") as ConfigVarListInt;
    this.m_aimAssistMeleeLevel = IntEnum(aimAssistVar.GetValue());
    aimAssistVar = this.m_settingsGroup.GetVar(n"AimAssistance") as ConfigVarListInt;
    this.m_aimAssistLevel = IntEnum(aimAssistVar.GetValue());
    this.Register(n"/gameplay/difficulty");
  }

  public func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    let aimAssistVar: ref<ConfigVarListInt>;
    if NotEquals(reason, ConfigChangeReason.Accepted) {
      return;
    };
    if Equals(n"AimAssistanceMelee", varName) {
      aimAssistVar = this.m_settingsGroup.GetVar(n"AimAssistanceMelee") as ConfigVarListInt;
      this.m_aimAssistMeleeLevel = IntEnum(aimAssistVar.GetValue());
      this.m_ctrl.ApplyAimAssistSettings();
    } else {
      if Equals(n"AimAssistance", varName) {
        aimAssistVar = this.m_settingsGroup.GetVar(n"AimAssistance") as ConfigVarListInt;
        this.m_aimAssistLevel = IntEnum(aimAssistVar.GetValue());
        this.m_ctrl.ApplyAimAssistSettings();
      };
    };
  }

  public final const func GetAimAssistLevel() -> EAimAssistLevel {
    return this.m_aimAssistLevel;
  }

  public final const func GetAimAssistMeleeLevel() -> EAimAssistLevel {
    return this.m_aimAssistMeleeLevel;
  }
}

public static func GetPlayer(gameInstance: GameInstance) -> ref<PlayerPuppet> {
  if IsDefined(GameInstance.GetPlayerSystem(gameInstance)) {
    return GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  };
  return null;
}

public static func GetPlayerObject(gameInstance: GameInstance) -> ref<GameObject> {
  return GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject();
}

public static func IsHostileTowardsPlayer(object: wref<GameObject>) -> Bool {
  let player: wref<PlayerPuppet>;
  if !IsDefined(object) {
    return false;
  };
  player = GetPlayer(object.GetGame());
  if IsDefined(player) && Equals(GameObject.GetAttitudeTowards(object, player), EAIAttitude.AIA_Hostile) {
    return true;
  };
  return false;
}

public static func IsFriendlyTowardsPlayer(object: wref<GameObject>) -> Bool {
  let player: wref<PlayerPuppet>;
  if !IsDefined(object) {
    return false;
  };
  player = GetPlayer(object.GetGame());
  if IsDefined(player) && Equals(GameObject.GetAttitudeTowards(object, player), EAIAttitude.AIA_Friendly) {
    return true;
  };
  return false;
}

public class PlayerPuppetPS extends ScriptedPuppetPS {

  private persistent let keybindigs: KeyBindings;

  private persistent let m_availablePrograms: array<MinigameProgramData>;

  private persistent let m_hasAutoReveal: Bool;

  private persistent let m_combatExitTimestamp: Float;

  private let m_minigameBB: wref<IBlackboard>;

  public final const func GetCombatExitTimestamp() -> Float {
    return this.m_combatExitTimestamp;
  }

  public final func SetCombatExitTimestamp(timestamp: Float) -> Void {
    this.m_combatExitTimestamp = timestamp;
  }

  public final const func HasAutoReveal() -> Bool {
    return this.m_hasAutoReveal;
  }

  public final func SetAutoReveal(value: Bool) -> Void {
    this.m_hasAutoReveal = value;
  }

  protected final func OnStoreMinigameProgram(evt: ref<StoreMiniGameProgramEvent>) -> EntityNotificationType {
    if evt.add {
      this.AddMinigameProgram(evt.program);
    } else {
      this.RemoveMinigameProgram(evt.program);
    };
    this.GetMinigameBlackboard().SetVariant(GetAllBlackboardDefs().HackingMinigame.PlayerPrograms, ToVariant(this.m_availablePrograms));
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func AddMinigameProgram(program: MinigameProgramData) -> Void {
    let programTemp: MinigameProgramData;
    if !this.HasProgram(program.actionID, this.m_availablePrograms) || program.actionID == t"MinigameAction.NetworkLowerICEMedium" {
      if program.actionID == t"MinigameAction.NetworkLowerICEMedium" || program.actionID == t"MinigameAction.NetworkLowerICEMajor" || program.actionID == t"MinigameAction.NetworkLowerICEMinorFirst" {
        programTemp = this.DecideProgramToAdd(program.actionID);
        if NotEquals(programTemp.programName, n"") {
          ArrayInsert(this.m_availablePrograms, 0, programTemp);
        };
      } else {
        this.UpgradePrograms(program.actionID);
        ArrayPush(this.m_availablePrograms, program);
      };
    };
  }

  protected final func RemoveMinigameProgram(program: MinigameProgramData) -> Void {
    this.RemoveProgram(program.actionID);
  }

  protected final func RemoveProgram(id: TweakDBID) -> Void {
    let i: Int32 = ArraySize(this.m_availablePrograms) - 1;
    while i >= 0 {
      if this.m_availablePrograms[i].actionID == id {
        ArrayRemove(this.m_availablePrograms, this.m_availablePrograms[i]);
      };
      i -= 1;
    };
  }

  protected final func HasProgram(id: TweakDBID) -> Bool {
    let i: Int32 = ArraySize(this.m_availablePrograms) - 1;
    while i >= 0 {
      if this.m_availablePrograms[i].actionID == id {
        return true;
      };
      i -= 1;
    };
    return false;
  }

  protected final func UpgradePrograms(id: TweakDBID) -> Void {
    if id == t"MinigameAction.NetworkCameraFriendly" {
      this.RemoveProgram(t"MinigameAction.NetworkCameraMalfunction");
    } else {
      if id == t"MinigameAction.NetworkCameraShutdown" {
        this.RemoveProgram(t"MinigameAction.NetworkCameraMalfunction");
      } else {
        if id == t"MinigameAction.NetworkTurretFriendly" {
          this.RemoveProgram(t"MinigameAction.NetworkTurretMalfunction");
        } else {
          if id == t"MinigameAction.NetworkTurretShutdown" {
            this.RemoveProgram(t"MinigameAction.NetworkTurretMalfunction");
          };
        };
      };
    };
  }

  protected final func DecideProgramToAdd(id: TweakDBID) -> MinigameProgramData {
    let program: MinigameProgramData;
    if id == t"MinigameAction.NetworkLowerICEMinorFirst" {
      if this.HasProgram(t"MinigameAction.NetworkLowerICEMedium") || this.HasProgram(t"MinigameAction.NetworkLowerICEMajor") {
        program.programName = n"";
        return program;
      };
      program.actionID = t"MinigameAction.NetworkLowerICEMinorFirst";
      program.programName = n"LocKey#34844";
      return program;
    };
    if id == t"MinigameAction.NetworkLowerICEMedium" {
      if this.HasProgram(t"MinigameAction.NetworkLowerICEMedium") {
        program.actionID = t"MinigameAction.NetworkLowerICEMajor";
        program.programName = n"LocKey#34844";
        this.RemoveProgram(t"MinigameAction.NetworkLowerICEMedium");
        return program;
      };
      if this.HasProgram(t"MinigameAction.NetworkLowerICEMajor") {
        program.programName = n"";
        return program;
      };
      program.actionID = t"MinigameAction.NetworkLowerICEMedium";
      program.programName = n"LocKey#34844";
      this.RemoveProgram(t"MinigameAction.NetworkLowerICEMinorFirst");
      return program;
    };
    if id == t"MinigameAction.NetworkLowerICEMajor" {
      if !this.HasProgram(t"MinigameAction.NetworkLowerICEMedium") {
        program.actionID = t"MinigameAction.NetworkLowerICEMedium";
        program.programName = n"LocKey#34844";
        this.RemoveProgram(t"MinigameAction.NetworkLowerICEMinorFirst");
        return program;
      };
      program.actionID = t"MinigameAction.NetworkLowerICEMajor";
      program.programName = n"LocKey#34844";
      this.RemoveProgram(t"MinigameAction.NetworkLowerICEMedium");
      return program;
    };
    return program;
  }

  private final func GetMinigameBlackboard() -> ref<IBlackboard> {
    if this.m_minigameBB == null {
      this.m_minigameBB = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().HackingMinigame);
    };
    return this.m_minigameBB;
  }

  public final const func GetMinigamePrograms() -> array<MinigameProgramData> {
    return this.m_availablePrograms;
  }

  protected final func HasProgram(id: TweakDBID, programs: array<MinigameProgramData>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(programs) {
      if programs[i].actionID == id {
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class CPOMissionDataState extends IScriptable {

  public let m_CPOMissionDataDamagesPreset: CName;

  public let m_compatibleDeviceName: CName;

  public let m_ownerDecidesOnTransfer: Bool;

  @default(CPOMissionDataState, false)
  public let m_isChoiceToken: Bool;

  @default(CPOMissionDataState, 0)
  public let m_choiceTokenTimeout: Uint32;

  public let m_delayedGiveChoiceTokenEventId: DelayID;

  private let m_dataDamageTextLayerId: Uint32;

  public final func OnDamage(puppet: ref<PlayerPuppet>, healthDamage: Bool) -> Void {
    let message: String;
    let soundEvent: ref<SoundPlayEvent>;
    let updateEvent: ref<CPOMissionDataUpdateEvent>;
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(puppet.GetGame());
    if puppet.HasCPOMissionData() && !puppet.m_CPOMissionDataState.m_isChoiceToken {
      message = "Corrupted data - internal damage!";
      this.m_dataDamageTextLayerId = GameInstance.GetDebugVisualizerSystem(puppet.GetGame()).DrawText(new Vector4(500.00, 200.00, 0.00, 1.50), message, gameDebugViewETextAlignment.Center, new Color(255u, 0u, 0u, 255u), 1.00);
      GameInstance.GetDebugVisualizerSystem(puppet.GetGame()).SetScale(this.m_dataDamageTextLayerId, new Vector4(3.00, 3.00, 0.00, 0.00));
      if healthDamage {
        soundEvent = new SoundPlayEvent();
        soundEvent.soundName = n"test_ad_emitter_2_1";
        puppet.QueueEvent(soundEvent);
      };
      GameObject.SetAudioParameter(puppet, n"g_player_health", 30.00);
      GameObject.PlaySoundEvent(puppet, n"ST_Health_Status_Low_Set_State");
      updateEvent = new CPOMissionDataUpdateEvent();
      delaySystem.DelayEvent(puppet, updateEvent, 1.00);
    };
  }

  public final func UpdateSounds(puppet: ref<PlayerPuppet>) -> Void {
    if !puppet.HasCPOMissionData() {
      GameObject.SetAudioParameter(puppet, n"g_player_health", 1.00);
      GameObject.PlaySoundEvent(puppet, n"ST_Health_Status_Hi_Set_State");
    };
  }
}

public class ArmorStatListener extends ScriptStatPoolsListener {

  public let m_ownerPuppet: wref<PlayerPuppet>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_ownerPuppet.m_CPOMissionDataState.OnDamage(this.m_ownerPuppet, false);
  }
}

public class HealthStatListener extends ScriptStatPoolsListener {

  public let m_ownerPuppet: wref<PlayerPuppet>;

  public let healthEvent: ref<HealthUpdateEvent>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if this.m_ownerPuppet.IsControlledByLocalPeer() {
      this.m_ownerPuppet.m_CPOMissionDataState.OnDamage(this.m_ownerPuppet, true);
    };
    this.healthEvent = new HealthUpdateEvent();
    this.healthEvent.value = newValue;
    this.healthEvent.healthDifference = newValue - oldValue;
    this.m_ownerPuppet.QueueEvent(this.healthEvent);
  }
}

public class OxygenStatListener extends CustomValueStatPoolsListener {

  public let m_ownerPuppet: wref<PlayerPuppet>;

  public let m_oxygenVfxBlackboard: ref<worldEffectBlackboard>;

  protected cb func OnStatPoolValueReached(oldValue: Float, newValue: Float, percToPoints: Float) -> Bool {
    this.TestOxygenLevel(oldValue, newValue, percToPoints);
  }

  protected cb func OnStatPoolMinValueReached(value: Float) -> Bool {
    this.IsOutOfOxygen(true);
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if newValue > 0.00 && oldValue <= 0.00 {
      this.IsOutOfOxygen(false);
    };
  }

  public final func IsOutOfOxygen(b: Bool) -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.m_ownerPuppet.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.OutOfOxygen";
    if Equals(b, true) && !statusEffectSystem.HasStatusEffect(this.m_ownerPuppet.GetEntityID(), statusEffectID) {
      statusEffectSystem.ApplyStatusEffect(this.m_ownerPuppet.GetEntityID(), statusEffectID, this.m_ownerPuppet.GetRecordID(), this.m_ownerPuppet.GetEntityID());
    } else {
      if Equals(b, false) && statusEffectSystem.HasStatusEffect(this.m_ownerPuppet.GetEntityID(), statusEffectID) {
        statusEffectSystem.RemoveStatusEffect(this.m_ownerPuppet.GetEntityID(), statusEffectID);
      };
    };
  }

  public final func TestOxygenLevel(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let critOxygenThreshold: Float = TweakDBInterface.GetFloat(t"player.oxygenThresholds.critOxygenThreshold", 10.00);
    if oldValue > critOxygenThreshold && newValue <= critOxygenThreshold {
      this.CriticalOxygenLevel(true);
    } else {
      if newValue >= critOxygenThreshold && oldValue <= critOxygenThreshold {
        this.CriticalOxygenLevel(false);
      };
    };
  }

  public final func CriticalOxygenLevel(b: Bool) -> Void {
    if Equals(b, true) {
      GameObject.PlaySound(this.m_ownerPuppet, n"oxygen_critical_start");
      GameObjectEffectHelper.StartEffectEvent(this.m_ownerPuppet, n"fx_oxygen_critical", false, this.m_oxygenVfxBlackboard);
    } else {
      GameObject.PlaySound(this.m_ownerPuppet, n"oxygen_critical_stop");
      GameObjectEffectHelper.BreakEffectLoopEvent(this.m_ownerPuppet, n"fx_oxygen_critical");
    };
  }
}

public class PlayerPuppet extends ScriptedPuppet {

  private let m_quickSlotsManager: ref<QuickSlotsManager>;

  private let m_inspectionComponent: ref<InspectionComponent>;

  public let m_Phone: ref<PlayerPhone>;

  private let m_fppCameraComponent: ref<FPPCameraComponent>;

  private let m_primaryTargetingComponent: ref<TargetingComponent>;

  public let DEBUG_Visualizer: ref<DEBUG_VisualizerComponent>;

  private let m_Debug_DamageInputRec: ref<DEBUG_DamageInputReceiver>;

  public let m_highDamageThreshold: Float;

  public let m_medDamageThreshold: Float;

  public let m_lowDamageThreshold: Float;

  public let m_meleeHighDamageThreshold: Float;

  public let m_meleeMedDamageThreshold: Float;

  public let m_meleeLowDamageThreshold: Float;

  public let m_explosionHighDamageThreshold: Float;

  public let m_explosionMedDamageThreshold: Float;

  public let m_explosionLowDamageThreshold: Float;

  public let m_effectTimeStamp: Float;

  public let m_curInventoryWeight: Float;

  public let m_healthVfxBlackboard: ref<worldEffectBlackboard>;

  public let m_laserTargettingVfxBlackboard: ref<worldEffectBlackboard>;

  public let m_itemLogBlackboard: wref<IBlackboard>;

  public let m_interactionDataListener: ref<CallbackHandle>;

  public let m_popupIsModalListener: ref<CallbackHandle>;

  public let m_uiVendorContextListener: ref<CallbackHandle>;

  public let m_uiRadialContextistener: ref<CallbackHandle>;

  public let m_contactsActiveListener: ref<CallbackHandle>;

  public let m_currentVisibleTargetListener: ref<CallbackHandle>;

  public let lastScanTarget: wref<GameObject>;

  public let meleeSelectInputProcessed: Bool;

  @default(PlayerPuppet, false)
  private let m_waitingForDelayEvent: Bool;

  private let m_randomizedTime: Float;

  private let m_isResetting: Bool;

  private let m_delayEventID: DelayID;

  private let m_resetTickID: DelayID;

  private let m_katanaAnimProgression: Float;

  private let m_coverModifierActive: Bool;

  private let m_workspotDamageReductionActive: Bool;

  private let m_workspotVisibilityReductionActive: Bool;

  private let m_currentPlayerWorkspotTags: array<CName>;

  private let m_incapacitated: Bool;

  private let m_remoteMappinId: NewMappinID;

  public let m_CPOMissionDataState: ref<CPOMissionDataState>;

  private let m_CPOMissionDataBbId: ref<CallbackHandle>;

  private let m_visibilityListener: ref<VisibilityStatListener>;

  private let m_secondHeartListener: ref<SecondHeartStatListener>;

  private let m_armorStatListener: ref<ArmorStatListener>;

  private let m_healthStatListener: ref<HealthStatListener>;

  private let m_oxygenStatListener: ref<OxygenStatListener>;

  private let m_aimAssistListener: ref<AimAssistSettingsListener>;

  private let m_autoRevealListener: ref<AutoRevealStatListener>;

  private let isTalkingOnPhone: Bool;

  private let m_DataDamageUpdateID: DelayID;

  private let m_playerAttachedCallbackID: Uint32;

  private let m_playerDetachedCallbackID: Uint32;

  private let m_callbackHandles: array<ref<CallbackHandle>>;

  private let m_numberOfCombatants: Int32;

  private let m_equipmentMeshOverlayEffectName: CName;

  private let m_equipmentMeshOverlayEffectTag: CName;

  private let m_equipmentMeshOverlaySlots: array<TweakDBID>;

  private let m_coverVisibilityPerkBlocked: Bool;

  private let m_behindCover: Bool;

  private let m_inCombat: Bool;

  private let m_hasBeenDetected: Bool;

  private let m_inCrouch: Bool;

  private let m_gunshotRange: Float;

  private let m_explosionRange: Float;

  private let m_nextBufferModifier: Int32;

  private let m_attackingNetrunnerID: EntityID;

  private let m_NPCDeathInstigator: wref<NPCPuppet>;

  private let m_bestTargettingWeapon: wref<WeaponObject>;

  private let m_bestTargettingDot: Float;

  private let m_targettingEnemies: Int32;

  private let m_isAimingAtFriendly: Bool;

  private let m_isAimingAtChild: Bool;

  private let m_coverRecordID: TweakDBID;

  private let m_damageReductionRecordID: TweakDBID;

  private let m_visReductionRecordID: TweakDBID;

  private let m_lastDmgInflicted: EngineTime;

  @default(PlayerPuppet, false)
  private let m_critHealthRumblePlayed: Bool;

  private let m_critHealthRumbleDurationID: DelayID;

  private let m_staminaListener: ref<StaminaListener>;

  private let m_memoryListener: ref<MemoryListener>;

  @default(PlayerPuppet, ESecurityAreaType.DISABLED)
  public let m_securityAreaTypeE3HACK: ESecurityAreaType;

  private let m_overlappedSecurityZones: array<PersistentID>;

  private let m_interestingFacts: InterestingFacts;

  private let m_interestingFactsListenersIds: InterestingFactsListenersIds;

  private let m_interestingFactsListenersFunctions: InterestingFactsListenersFunctions;

  private let m_visionModeController: ref<PlayerVisionModeController>;

  private let m_combatController: ref<PlayerCombatController>;

  private let m_cachedGameplayRestrictions: array<TweakDBID>;

  private let m_delayEndGracePeriodAfterSpawnEventID: DelayID;

  private let m_bossThatTargetsPlayer: EntityID;

  @default(PlayerPuppet, 0)
  private let m_choiceTokenTextLayerId: Uint32;

  @default(PlayerPuppet, false)
  private let m_choiceTokenTextDrawn: Bool;

  public const func IsPlayer() -> Bool {
    return true;
  }

  public const func IsReplacer() -> Bool {
    return this.GetRecord().GetID() != t"Character.Player_Puppet_Base";
  }

  public const func IsVRReplacer() -> Bool {
    return this.GetRecord().GetID() == t"Character.q000_vr_replacer";
  }

  public const func IsJohnnyReplacer() -> Bool {
    return this.GetRecord().GetID() == t"Character.johnny_replacer";
  }

  public final const func IsReplicable() -> Bool {
    return true;
  }

  public final const func GetReplicatedStateClass() -> CName {
    return n"gamePlayerPuppetReplicatedState";
  }

  public final const func IsCoverModifierAdded() -> Bool {
    return this.m_coverModifierActive;
  }

  public final const func IsWorkspotDamageReductionAdded() -> Bool {
    return this.m_workspotDamageReductionActive;
  }

  public final const func IsWorkspotVisibilityReductionActive() -> Bool {
    return this.m_workspotVisibilityReductionActive;
  }

  public final const func GetOverlappedSecurityZones() -> array<PersistentID> {
    return this.m_overlappedSecurityZones;
  }

  protected const func GetPS() -> ref<GameObjectPS> {
    return this.GetBasePS();
  }

  public final const func GetCombatExitTimestamp() -> Float {
    return (this.GetPS() as PlayerPuppetPS).GetCombatExitTimestamp();
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"phone", n"PlayerPhone", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"inspect", n"InspectionComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"DEBUG_Visualizer", n"DEBUG_VisualizerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"quickSlots", n"QuickSlotsManager", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"camera", n"gameFPPCameraComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"targeting_primary", n"gameTargetingComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"vehicleCameraManager", n"vehicleCameraManagerComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"vehicleTPPCamera", n"vehicleTPPCameraComponent", true);
  }

  public final func FindVehicleCameraManager() -> ref<VehicleCameraManager> {
    let component: ref<VehicleCameraManagerComponent> = this.FindComponentByName(n"vehicleCameraManager") as VehicleCameraManagerComponent;
    if IsDefined(component) {
      return component.GetManagerHandle();
    };
    return null;
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_quickSlotsManager = EntityResolveComponentsInterface.GetComponent(ri, n"quickSlots") as QuickSlotsManager;
    this.m_inspectionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"inspect") as InspectionComponent;
    this.DEBUG_Visualizer = EntityResolveComponentsInterface.GetComponent(ri, n"DEBUG_Visualizer") as DEBUG_VisualizerComponent;
    this.m_Phone = EntityResolveComponentsInterface.GetComponent(ri, n"phone") as PlayerPhone;
    this.m_fppCameraComponent = EntityResolveComponentsInterface.GetComponent(ri, n"camera") as FPPCameraComponent;
    this.m_primaryTargetingComponent = EntityResolveComponentsInterface.GetComponent(ri, n"targeting_primary") as TargetingComponent;
    this.m_visionModeController = new PlayerVisionModeController();
    this.m_combatController = new PlayerCombatController();
  }

  protected cb func OnReleaseControl() -> Bool {
    this.m_visionModeController = null;
    this.m_combatController = null;
  }

  private final func GracePeriodAfterSpawn() -> Void {
    let invisibilityDuration: Float = TweakDBInterface.GetFloat(t"player.stealth.durationOfGracePeriodAfterSpawn", -1.00);
    if invisibilityDuration > 0.00 {
      this.SetInvisible(true);
      GameInstance.GetGodModeSystem(this.GetGame()).AddGodMode(this.GetEntityID(), gameGodModeType.Invulnerable, n"GracePeriodAfterSpawn");
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_delayEndGracePeriodAfterSpawnEventID);
      this.m_delayEndGracePeriodAfterSpawnEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new EndGracePeriodAfterSpawn(), invisibilityDuration);
    };
  }

  protected cb func OnMakePlayerVisibleAfterSpawn(evt: ref<EndGracePeriodAfterSpawn>) -> Bool {
    this.SetInvisible(false);
    GameInstance.GetGodModeSystem(this.GetGame()).RemoveGodMode(this.GetEntityID(), gameGodModeType.Invulnerable, n"GracePeriodAfterSpawn");
  }

  public final func IsAimingAtFriendly() -> Bool {
    return this.m_isAimingAtFriendly;
  }

  public final func IsAimingAtChild() -> Bool {
    return this.m_isAimingAtChild;
  }

  protected cb func OnLookAtObjectChangedEvent(evt: ref<LookAtObjectChangedEvent>) -> Bool {
    if !IsDefined(evt.lookatObject) {
      this.m_isAimingAtFriendly = false;
      this.m_isAimingAtChild = false;
    } else {
      this.m_isAimingAtFriendly = PlayerPuppet.IsTargetFriendlyNPC(this, evt.lookatObject);
      this.m_isAimingAtChild = PlayerPuppet.IsTargetChildNPC(this, evt.lookatObject);
    };
  }

  protected cb func OnWeaponEquipEvent(evt: ref<WeaponEquipEvent>) -> Bool {
    AnimationControllerComponent.ApplyFeature(this, n"WeaponEquipType", evt.animFeature);
    AnimationControllerComponent.ApplyFeature(evt.item, n"WeaponEquipType", evt.animFeature);
  }

  protected cb func OnSetUpEquipmentOverlayEvent(evt: ref<SetUpEquipmentOverlayEvent>) -> Bool {
    this.m_equipmentMeshOverlayEffectName = evt.meshOverlayEffectName;
    this.m_equipmentMeshOverlayEffectTag = evt.meshOverlayEffectTag;
    this.m_equipmentMeshOverlaySlots = evt.meshOverlaySlots;
  }

  protected cb func OnAppearanceChangeFinishEvent(evt: ref<entAppearanceChangeFinishEvent>) -> Bool {
    let effect: ref<EffectInstance>;
    let i: Int32;
    let item: wref<ItemObject>;
    let ts: ref<TransactionSystem>;
    if IsNameValid(this.m_equipmentMeshOverlayEffectName) {
      ts = GameInstance.GetTransactionSystem(this.GetGame());
      i = 0;
      while i < ArraySize(this.m_equipmentMeshOverlaySlots) {
        item = ts.GetItemInSlot(this, this.m_equipmentMeshOverlaySlots[i]);
        if IsDefined(item) {
          effect = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(this.m_equipmentMeshOverlayEffectName, this.m_equipmentMeshOverlayEffectTag, this);
          if IsDefined(effect) {
            EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, true);
            EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.clearMaterialOverlayOnDetach, true);
            EffectData.SetEntity(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, item);
            effect.Run();
          };
        };
        i += 1;
      };
      effect = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(this.m_equipmentMeshOverlayEffectName, this.m_equipmentMeshOverlayEffectTag, this);
      if IsDefined(effect) {
        EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, true);
        EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.clearMaterialOverlayOnDetach, true);
        EffectData.SetEntity(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this);
        effect.Run();
      };
    };
  }

  private final func EvaluateApplyingReplacerGameplayRestrictions() -> Void {
    let mainObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let controlledObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let controlledObjRecordID: TweakDBID = controlledObj.GetRecordID();
    switch controlledObjRecordID {
      case t"Character.johnny_replacer":
        StatusEffectHelper.ApplyStatusEffect(mainObj, t"GameplayRestriction.BlockAllHubMenu");
        GameInstance.GetGodModeSystem(mainObj.GetGame()).AddGodMode(mainObj.GetEntityID(), gameGodModeType.Invulnerable, n"JohnnyReplacerSequence");
        break;
      case t"Character.q000_vr_replacer":
        StatusEffectHelper.ApplyStatusEffect(mainObj, t"GameplayRestriction.BlockAllHubMenu");
        break;
      case t"Character.Player_Puppet_Base":
        StatusEffectHelper.RemoveStatusEffect(mainObj, t"GameplayRestriction.BlockAllHubMenu");
        GameInstance.GetGodModeSystem(mainObj.GetGame()).RemoveGodMode(mainObj.GetEntityID(), gameGodModeType.Invulnerable, n"JohnnyReplacerSequence");
        GameInstance.GetInventoryManager(mainObj.GetGame()).RemoveEquipmentStateFlag(gameEEquipmentManagerState.InfiniteAmmo);
        break;
      default:
        StatusEffectHelper.RemoveStatusEffect(mainObj, t"GameplayRestriction.BlockAllHubMenu");
    };
  }

  private final func ResolveCachedGameplayRestrictions() -> Void {
    let psmBB: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    let i: Int32 = 0;
    while i < ArraySize(this.m_cachedGameplayRestrictions) {
      this.AddGameplayRestriction(psmBB, this.m_cachedGameplayRestrictions[i]);
      i += 1;
    };
    if IsDefined(psmBB) {
      ArrayClear(this.m_cachedGameplayRestrictions);
    };
  }

  private final func AddGameplayRestriction(psmBB: ref<IBlackboard>, actionRestrictionRecordID: TweakDBID) -> Void {
    let actionRestrictions: array<TweakDBID>;
    if IsDefined(psmBB) {
      actionRestrictions = FromVariant(psmBB.GetVariant(GetAllBlackboardDefs().PlayerStateMachine.ActionRestriction));
      ArrayPush(actionRestrictions, actionRestrictionRecordID);
      psmBB.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.ActionRestriction, ToVariant(actionRestrictions));
    } else {
      this.CacheGameplayRestriction(actionRestrictionRecordID);
    };
  }

  private final func RemoveGameplayRestriction(psmBB: ref<IBlackboard>, actionRestrictionRecordID: TweakDBID) -> Void {
    let actionRestrictions: array<TweakDBID>;
    if IsDefined(psmBB) {
      actionRestrictions = FromVariant(psmBB.GetVariant(GetAllBlackboardDefs().PlayerStateMachine.ActionRestriction));
      ArrayRemove(actionRestrictions, actionRestrictionRecordID);
      psmBB.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.ActionRestriction, ToVariant(actionRestrictions));
    };
  }

  private final func CacheGameplayRestriction(actionRestrictionRecordID: TweakDBID) -> Void {
    if !ArrayContains(this.m_cachedGameplayRestrictions, actionRestrictionRecordID) {
      ArrayPush(this.m_cachedGameplayRestrictions, actionRestrictionRecordID);
    };
  }

  private final func PlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    let blackboard: ref<IBlackboard>;
    let pmsBlackboard: ref<IBlackboard>;
    if playerPuppet == this {
      ArrayClear(this.m_callbackHandles);
      pmsBlackboard = this.GetPlayerStateMachineBlackboard();
      allBlackboardDef = GetAllBlackboardDefs();
      ArrayPush(this.m_callbackHandles, pmsBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Locomotion, this, n"OnLocomotionStateChanged"));
      ArrayPush(this.m_callbackHandles, pmsBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Combat, this, n"OnCombatStateChanged"));
      ArrayPush(this.m_callbackHandles, pmsBlackboard.RegisterListenerVariant(allBlackboardDef.PlayerStateMachine.SecurityZoneData, this, n"OnZoneChange"));
      blackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(allBlackboardDef.UI_Stealth);
      if IsDefined(blackboard) {
        ArrayPush(this.m_callbackHandles, blackboard.RegisterListenerUint(allBlackboardDef.UI_Stealth.numberOfCombatants, this, n"OnNumberOfCombatantsChanged"));
      };
      if this.IsJohnnyReplacer() {
        GameplaySettingsSystem.SetWasEverJohnny(this, true);
      };
      this.EvaluateApplyingReplacerGameplayRestrictions();
      this.RestoreMinigamePrograms();
      this.ResolveCachedGameplayRestrictions();
      this.RegisterInterestingFactsListeners();
      this.m_visionModeController.RegisterOwner(this);
      this.m_combatController.RegisterOwner(this);
      PlayerPuppet.ChacheQuickHackListCleanup(playerPuppet);
    };
  }

  private final func PlayerDetachedCallback(playerPuppet: ref<GameObject>) -> Void {
    if playerPuppet == this {
      this.UnregisterInterestingFactsListeners();
      this.m_visionModeController.UnregisterOwner();
      ArrayClear(this.m_callbackHandles);
    };
  }

  protected cb func OnGameAttached() -> Bool {
    let playerAttach: ref<PlayerAttachRequest> = new PlayerAttachRequest();
    playerAttach.owner = this;
    GameInstance.GetScriptableSystemsContainer(GetGameInstance()).QueueRequest(playerAttach);
    super.OnGameAttached();
    if this.IsControlledByLocalPeer() || IsHost() {
      this.RegisterInputListener(this, n"IconicCyberware");
      this.RegisterInputListener(this, n"CallVehicle");
      this.m_Debug_DamageInputRec = new DEBUG_DamageInputReceiver();
      this.m_Debug_DamageInputRec.m_player = this;
      this.RegisterInputListener(this.m_Debug_DamageInputRec, n"Debug_KillAll");
      this.RegisterInputListener(this.m_Debug_DamageInputRec, n"Debug_Kill");
    } else {
      if IsClient() {
        this.RegisterRemoteMappin();
        this.RefreshCPOVisionAppearance();
        this.RegisterCPOMissionDataCallback();
      };
    };
    this.m_CPOMissionDataState = new CPOMissionDataState();
    this.isTalkingOnPhone = false;
    this.m_coverVisibilityPerkBlocked = false;
    this.m_behindCover = false;
    this.m_inCombat = false;
    this.m_hasBeenDetected = false;
    this.m_inCrouch = false;
    this.RegisterToFacts();
    this.EnableUIBlackboardListener(true);
    this.InitializeTweakDBRecords();
    this.DefineModifierGroups();
    this.RegisterStatListeners(this);
    this.UpdateVisibilityModifier();
    this.EnableInteraction(n"Revive", false);
    this.m_incapacitated = false;
    this.UpdatePlayerSettings();
    this.CalculateEncumbrance();
    AnimationControllerComponent.ApplyFeature(this, n"CameraGameplay", new AnimFeature_CameraGameplay());
    AnimationControllerComponent.ApplyFeature(this, n"CameraBodyOffset", new AnimFeature_CameraBodyOffset());
    this.m_playerAttachedCallbackID = GameInstance.GetPlayerSystem(GetGameInstance()).RegisterPlayerPuppetAttachedCallback(this, n"PlayerAttachedCallback");
    this.m_playerDetachedCallbackID = GameInstance.GetPlayerSystem(GetGameInstance()).RegisterPlayerPuppetDetachedCallback(this, n"PlayerDetachedCallback");
    this.UpdateSecondaryVisibilityOffset(false);
    this.EnableCombatVisibilityDistances(false);
    this.SetSenseObjectType(gamedataSenseObjectType.Player);
    this.GracePeriodAfterSpawn();
    StatusEffectHelper.RemoveStatusEffect(this, t"GameplayRestriction.FastForward");
    StatusEffectHelper.RemoveStatusEffect(this, t"GameplayRestriction.FastForwardCrouchLock");
  }

  protected cb func OnDetach() -> Bool {
    let playerDetach: ref<PlayerDetachRequest> = new PlayerDetachRequest();
    playerDetach.owner = this;
    GameInstance.GetScriptableSystemsContainer(GetGameInstance()).QueueRequest(playerDetach);
    this.UnregisterStatListeners(this);
    this.EnableUIBlackboardListener(false);
    if IsClient() {
      this.UnregisterRemoteMappin();
      this.UnregisterCPOMissionDataCallback();
    };
    this.CPOMissionDataOnPlayerDetach();
    this.SetEntityNoticedPlayerBBValue(false);
    if Cast(this.m_playerAttachedCallbackID) {
      GameInstance.GetPlayerSystem(this.GetGame()).UnregisterPlayerPuppetAttachedCallback(this.m_playerAttachedCallbackID);
    };
    if Cast(this.m_playerDetachedCallbackID) {
      GameInstance.GetPlayerSystem(this.GetGame()).UnregisterPlayerPuppetDetachedCallback(this.m_playerDetachedCallbackID);
    };
  }

  protected const func ShouldRegisterToHUD() -> Bool {
    return false;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), n"MP_TriggerPing") {
      this.OnActionMultiplayer(action, consumer);
    };
    if Equals(ListenerAction.GetName(action), n"IconicCyberware") {
      if Equals(ListenerAction.GetType(action), this.DeductGameInputActionType()) && !this.CanCycleLootData() {
        this.ActivateIconicCyberware();
      };
    } else {
      if Equals(ListenerAction.GetName(action), n"CallVehicle") {
        if !GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerStats).GetBool(GetAllBlackboardDefs().UI_PlayerStats.isReplacer) && Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
          this.ProcessCallVehicleAction(ListenerAction.GetType(action));
        };
      };
    };
  }

  private final func CanCycleLootData() -> Bool {
    let interactonsBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UIInteractions);
    let interactionData: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
    let data: LootData = FromVariant(interactonsBlackboard.GetVariant(interactionData.LootData));
    let items: array<ItemID> = data.itemIDs;
    return ArraySize(items) > 1;
  }

  private final func KeybaordAndMouseControlsActive() -> Bool {
    return this.PlayerLastUsedKBM();
  }

  private final func DeductGameInputActionType() -> gameinputActionType {
    if this.KeybaordAndMouseControlsActive() {
      return gameinputActionType.BUTTON_RELEASED;
    };
    return gameinputActionType.BUTTON_HOLD_COMPLETE;
  }

  public func HasPrimaryOrSecondaryEquipment() -> Bool {
    return true;
  }

  private final func ActivateIconicCyberware() -> Void {
    let psmEvent: ref<PSMPostponedParameterBool>;
    let activeItem: ItemID = EquipmentSystem.GetData(this).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    if !ItemID.IsValid(activeItem) {
      return;
    };
    if GameInstance.GetStatsSystem(this.GetGame()).GetStatBoolValue(Cast(this.GetEntityID()), gamedataStatType.HasBerserk) {
      if !StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.BerserkPlayerBuff") {
        GameObject.PlaySound(this, n"slow");
        ItemActionsHelper.UseItem(this, activeItem);
        psmEvent = new PSMPostponedParameterBool();
        psmEvent.id = n"OnBerserkActivated";
        psmEvent.value = true;
        this.QueueEvent(psmEvent);
      };
    } else {
      if GameInstance.GetStatsSystem(this.GetGame()).GetStatBoolValue(Cast(this.GetEntityID()), gamedataStatType.HasSandevistan) {
        if !StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.SandevistanPlayerBuff") {
          ItemActionsHelper.UseItem(this, activeItem);
          psmEvent = new PSMPostponedParameterBool();
          psmEvent.id = n"requestSandevistanActivation";
          psmEvent.value = true;
          this.QueueEvent(psmEvent);
        };
      };
    };
  }

  private final func ProcessCallVehicleAction(type: gameinputActionType) -> Void {
    let dpadAction: ref<DPADActionPerformed>;
    if !VehicleComponent.IsMountedToVehicle(this.GetGame(), this) && this.CheckRadialContextRequest() && !VehicleSystem.IsSummoningVehiclesRestricted(this.GetGame()) {
      this.SendSummonVehicleQuickSlotsManagerRequest();
    };
    dpadAction = new DPADActionPerformed();
    dpadAction.action = EHotkey.DPAD_RIGHT;
    dpadAction.successful = false;
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(dpadAction);
  }

  protected cb func OnMountingEvent(evt: ref<MountingEvent>) -> Bool {
    let allowsCombat: Bool = false;
    let mountedToVehicle: Bool = false;
    let playerStateMachineBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let vehicleObject: ref<VehicleObject> = GameInstance.FindEntityByID(this.GetGame(), evt.request.lowLevelMountingInfo.parentId) as VehicleObject;
    if IsDefined(vehicleObject) {
      mountedToVehicle = true;
      allowsCombat = VehicleComponent.GetVehicleAllowsCombat(this.GetGame(), vehicleObject);
    };
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToCombatVehicle, allowsCombat);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle, mountedToVehicle);
  }

  protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
    let playerStateMachineBlackboard: wref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToCombatVehicle, false);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle, false);
  }

  private final const func IsCallingVehicleRestricted() -> Bool {
    return PlayerGameplayRestrictions.IsHotkeyRestricted(this.GetGame(), EHotkey.DPAD_RIGHT);
  }

  private final func GetUnlockedVehiclesSize() -> Int32 {
    let unlockedVehicles: array<PlayerVehicle>;
    GameInstance.GetVehicleSystem(this.GetGame()).GetPlayerUnlockedVehicles(unlockedVehicles);
    return ArraySize(unlockedVehicles);
  }

  private final func SendSummonVehicleQuickSlotsManagerRequest() -> Void {
    let evt: ref<CallAction> = new CallAction();
    evt.calledAction = QuickSlotActionType.SummonVehicle;
    this.QueueEvent(evt);
  }

  private final func CheckVehicleSystemGarageState() -> Bool {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().VehicleSummonData);
    let garageState: Uint32 = blackboard.GetUint(GetAllBlackboardDefs().VehicleSummonData.GarageState);
    return Equals(IntEnum(garageState), vehicleGarageState.SummonAvailable);
  }

  private final func CheckRadialContextRequest() -> Bool {
    return !GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).GetBool(GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest);
  }

  private final func OnActionMultiplayer(action: ListenerAction, consumer: ListenerActionConsumer) -> Void {
    let isVisionModeActive: Bool;
    let pingSystem: ref<PingSystem>;
    if Equals(ListenerAction.GetName(action), n"MP_TriggerPing") {
      isVisionModeActive = this.GetPlayerStateMachineBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
      if !isVisionModeActive {
        if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
          pingSystem = GameInstance.GetPingSystem(this.GetGame());
          if IsDefined(pingSystem) {
            pingSystem.TriggerPing(this);
          };
        };
      };
    };
  }

  private final func GetCPOQuickSlotID(action: ListenerAction) -> Int32 {
    if GameInstance.GetRuntimeInfo(this.GetGame()).IsMultiplayer() || GameInstance.GetPlayerSystem(this.GetGame()).IsCPOControlSchemeForced() {
      if Equals(ListenerAction.GetName(action), n"QuickSlot1") && ListenerAction.IsButtonJustReleased(action) {
        return 0;
      };
      if Equals(ListenerAction.GetName(action), n"QuickSlot2") && ListenerAction.IsButtonJustReleased(action) {
        return 1;
      };
      if Equals(ListenerAction.GetName(action), n"QuickSlot3") && ListenerAction.IsButtonJustReleased(action) {
        return 2;
      };
    };
    return -1;
  }

  private final func UpdatePlayerSettings() -> Void {
    let meleeCameraShakeWeight: Float = TweakDBInterface.GetFloat(t"player.camera.meleeCameraShakeWeight", 1.00);
    let disableHeadBobbing: Bool = TweakDBInterface.GetBool(t"player.camera.disableHeadBobbing", false);
    AnimationControllerComponent.SetInputFloat(this, n"melee_camera_shake_weight", meleeCameraShakeWeight);
    AnimationControllerComponent.SetInputBool(this, n"disable_camera_bobbing", disableHeadBobbing);
  }

  public final const func GetQuickSlotsManager() -> ref<QuickSlotsManager> {
    return this.m_quickSlotsManager;
  }

  public final const func GetInspectionComponent() -> ref<InspectionComponent> {
    return this.m_inspectionComponent;
  }

  public final const func GetFPPCameraComponent() -> ref<FPPCameraComponent> {
    return this.m_fppCameraComponent;
  }

  public final func GetBufferModifier() -> Int32 {
    return this.m_nextBufferModifier;
  }

  public final func SetBufferModifier(i: Int32) -> Void {
    this.m_nextBufferModifier = i;
  }

  public final static func GetCriticalHealthThreshold() -> Float {
    return TweakDBInterface.GetFloat(t"player.hitVFX.critHealthThreshold", 0.00);
  }

  public final static func GetLowHealthThreshold() -> Float {
    return TweakDBInterface.GetFloat(t"player.hitVFX.lowHealthThreshold", 0.00);
  }

  public final static func IsTargetFriendlyNPC(player: ref<PlayerPuppet>, target: ref<Entity>) -> Bool {
    let attitudeTowardsPlayer: EAIAttitude;
    let targetAsPuppet: ref<ScriptedPuppet>;
    let targetAsWeakspot: ref<WeakspotObject> = target as WeakspotObject;
    if IsDefined(targetAsWeakspot) {
      target = targetAsWeakspot.GetOwner();
    };
    targetAsPuppet = target as ScriptedPuppet;
    if targetAsPuppet.GetRecordID() == t"Character.Silverhand" {
      return false;
    };
    if IsDefined(player) && IsDefined(targetAsPuppet) && ScriptedPuppet.IsAlive(targetAsPuppet) {
      attitudeTowardsPlayer = GameObject.GetAttitudeTowards(player, targetAsPuppet);
      if Equals(attitudeTowardsPlayer, EAIAttitude.AIA_Friendly) {
        return true;
      };
    };
    return false;
  }

  public final static func IsTargetChildNPC(player: ref<PlayerPuppet>, target: ref<Entity>) -> Bool {
    let targetAsPuppet: ref<ScriptedPuppet> = target as ScriptedPuppet;
    if IsDefined(player) && IsDefined(targetAsPuppet) && ScriptedPuppet.IsAlive(targetAsPuppet) {
      if targetAsPuppet.IsCharacterChildren() {
        return true;
      };
    };
    return false;
  }

  public final const func GetPlayerStateMachineBlackboard() -> ref<IBlackboard> {
    let psmBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return psmBlackboard;
  }

  public final const func GetPlayerPerkDataBlackboard() -> ref<IBlackboard> {
    return GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
  }

  public final const func GetHackingDataBlackboard() -> ref<IBlackboard> {
    return GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().HackingData);
  }

  public final static func GetCurrentLocomotionState(player: wref<PlayerPuppet>) -> gamePSMLocomotionStates {
    let blackboard: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
    return IntEnum(blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion));
  }

  public final static func GetCurrentHighLevelState(player: wref<PlayerPuppet>) -> gamePSMHighLevel {
    let blackboard: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
    return IntEnum(blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel));
  }

  public final static func GetCurrentCombatState(player: wref<PlayerPuppet>) -> gamePSMCombat {
    let blackboard: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
    return IntEnum(blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat));
  }

  public final static func GetQuickMeleeCooldown() -> Float {
    return TweakDBInterface.GetFloat(t"player.quickMelee.quickMeleeCooldown", 5.00);
  }

  private final func GetDamageThresholdParams() -> Void {
    this.m_highDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.highDamageThreshold", 0.40);
    this.m_medDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.medDamageThreshold", 0.10);
    this.m_lowDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.lowDamageThreshold", 0.10);
    this.m_meleeHighDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.meleeHighDamageThreshold", 0.10);
    this.m_meleeMedDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.meleeMedDamageThreshold", 0.20);
    this.m_meleeLowDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.meleeLowDamageThreshold", 0.30);
    this.m_explosionHighDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.explosionHighDamageThreshold", 0.00);
    this.m_explosionMedDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.explosionMedDamageThreshold", 0.00);
    this.m_explosionLowDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.explosionLowDamageThreshold", 0.00);
  }

  private final func EnableUIBlackboardListener(enable: Bool) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(GetGameInstance());
    let uiBlackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UIGameData);
    let quickSlotsBlackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    let phoneBlackboard: wref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_ComDevice);
    let targetingBlackBoard: wref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_TargetingInfo);
    if enable {
      this.m_itemLogBlackboard = blackboardSystem.Get(GetAllBlackboardDefs().UI_ItemLog);
      this.m_interactionDataListener = uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UIGameData.InteractionData, this, n"OnInteractionStateChange");
      this.m_popupIsModalListener = uiBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UIGameData.Popup_IsModal, this, n"OnUIContextChange");
      this.m_uiVendorContextListener = uiBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UIGameData.UIVendorContextRequest, this, n"OnUIVendorContextChange");
      this.m_uiRadialContextistener = quickSlotsBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest, this, n"OnUIRadialContextChange");
      this.m_contactsActiveListener = phoneBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_ComDevice.ContactsActive, this, n"OnUIContactListContextChanged");
      this.m_currentVisibleTargetListener = targetingBlackBoard.RegisterListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this, n"OnCurrentVisibleTargetChanged");
    } else {
      uiBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UIGameData.InteractionData, this.m_interactionDataListener);
      uiBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UIGameData.Popup_IsModal, this.m_popupIsModalListener);
      uiBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UIGameData.UIVendorContextRequest, this.m_uiVendorContextListener);
      quickSlotsBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest, this.m_uiRadialContextistener);
      phoneBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_ComDevice.ContactsActive, this.m_contactsActiveListener);
      targetingBlackBoard.UnregisterListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this.m_currentVisibleTargetListener);
      this.m_itemLogBlackboard = null;
      this.m_interactionDataListener = null;
      this.m_popupIsModalListener = null;
      this.m_uiVendorContextListener = null;
      this.m_uiRadialContextistener = null;
      this.m_contactsActiveListener = null;
      this.m_currentVisibleTargetListener = null;
    };
  }

  private final func SetupInPlayerDevelopmentSystem() -> Void {
    let build: gamedataBuildType;
    let cpoStartingBuildName: String;
    let setProgressionBuildReq: ref<SetProgressionBuild>;
    let updatePDS: ref<UpdatePlayerDevelopment> = new UpdatePlayerDevelopment();
    updatePDS.Set(this);
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PlayerDevelopmentSystem").QueueRequest(updatePDS);
    if GameInstance.GetRuntimeInfo(this.GetGame()).IsMultiplayer() {
      cpoStartingBuildName = TweakDBInterface.GetCharacterRecord(this.GetRecordID()).CpoCharacterBuild();
      build = IntEnum(Cast(EnumValueFromString("gamedataBuildType", cpoStartingBuildName)));
      Log("Using cpo starting build: " + cpoStartingBuildName);
      setProgressionBuildReq = new SetProgressionBuild();
      setProgressionBuildReq.Set(this, build);
      GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PlayerDevelopmentSystem").QueueRequest(setProgressionBuildReq);
    };
  }

  private final func UpdateVisibilityModifier() -> Void {
    let detectMultEvent: ref<VisibleObjectDetectionMultEvent>;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let visibilityValue: Float = statsSystem.GetStatValue(Cast(this.GetEntityID()), gamedataStatType.Visibility);
    if visibilityValue >= 0.00 {
      detectMultEvent = new VisibleObjectDetectionMultEvent();
      detectMultEvent.multiplier = visibilityValue;
      this.QueueEvent(detectMultEvent);
    };
  }

  public final static func SendOnBeingNoticed(player: wref<PlayerPuppet>, objectThatNoticed: wref<GameObject>) -> Void {
    let evt: ref<OnBeingNoticed>;
    let revealEvt: ref<RevealObjectEvent>;
    if !IsDefined(player) || !IsDefined(objectThatNoticed) {
      return;
    };
    evt = new OnBeingNoticed();
    evt.objectThatNoticed = objectThatNoticed;
    player.QueueEvent(evt);
    if GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.HasAutomaticTagging) > 0.00 {
      revealEvt = new RevealObjectEvent();
      revealEvt.reveal = true;
      revealEvt.reason.reason = n"AutomaticTagging";
      revealEvt.reason.sourceEntityId = player.GetEntityID();
      revealEvt.lifetime = 15.00;
      objectThatNoticed.QueueEvent(revealEvt);
    };
  }

  protected cb func OnBeingNoticed(evt: ref<OnBeingNoticed>) -> Bool {
    if !IsMultiplayer() {
      this.SetEntityNoticedPlayerBBValue(true);
      if !this.m_inCombat && EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGame()).GetSimTime()) - (this.GetPS() as PlayerPuppetPS).GetCombatExitTimestamp() > 45.00 {
        ReactionManagerComponent.SendVOEventToSquad(this, n"detection_warning");
      };
    };
  }

  private final func SetEntityNoticedPlayerBBValue(b: Bool) -> Void {
    if this.m_inCombat || this.IsReplacer() {
      return;
    };
    if Equals(b, true) {
      this.GetPlayerPerkDataBlackboard().SetUint(GetAllBlackboardDefs().PlayerPerkData.EntityNoticedPlayer, 1u);
      this.QueueEvent(new ClearBeingNoticedBB());
    } else {
      this.GetPlayerPerkDataBlackboard().SetUint(GetAllBlackboardDefs().PlayerPerkData.EntityNoticedPlayer, 0u);
    };
  }

  protected cb func OnClearBeingNoticedBB(evt: ref<ClearBeingNoticedBB>) -> Bool {
    this.SetEntityNoticedPlayerBBValue(false);
  }

  protected cb func OnBeingTargetByLaserSight(evt: ref<BeingTargetByLaserSightUpdateEvent>) -> Bool {
    let dot: Float;
    let forward: Vector4;
    if IsClient() && this.IsControlledByLocalPeer() || !IsMultiplayer() {
      if Equals(evt.state, LaserTargettingState.End) {
        if this.m_bestTargettingWeapon == evt.weapon {
          this.m_bestTargettingDot = -1.00;
          this.m_bestTargettingWeapon = null;
        };
        this.m_targettingEnemies -= 1;
        if this.m_targettingEnemies == 0 {
          GameObjectEffectHelper.StopEffectEvent(this, n"laser_targetting");
          this.m_laserTargettingVfxBlackboard = null;
        };
        return true;
      };
      if Equals(evt.state, LaserTargettingState.Start) {
        this.m_targettingEnemies += 1;
      };
      if !IsDefined(this.m_laserTargettingVfxBlackboard) {
        this.m_laserTargettingVfxBlackboard = new worldEffectBlackboard();
        GameObjectEffectHelper.StartEffectEvent(this, n"laser_targetting", false, this.m_laserTargettingVfxBlackboard);
      };
      forward = Matrix.GetDirectionVector(this.GetFPPCameraComponent().GetLocalToWorld());
      dot = -Vector4.Dot(forward, evt.weapon.GetWorldForward());
      if this.m_bestTargettingWeapon != evt.weapon {
        if dot > this.m_bestTargettingDot {
          this.m_bestTargettingWeapon = evt.weapon;
        } else {
          return true;
        };
      };
      this.m_laserTargettingVfxBlackboard.SetValue(n"laser_angle", dot);
      this.m_bestTargettingDot = dot;
    };
  }

  protected cb func OnBeingTarget(evt: ref<OnBeingTarget>) -> Bool {
    let evtToSend: ref<OnBeingTarget>;
    let puppetTargetingPlayer: wref<ScriptedPuppet> = evt.objectThatTargets as ScriptedPuppet;
    let npcPuppet: ref<NPCPuppet> = puppetTargetingPlayer as NPCPuppet;
    if IsDefined(npcPuppet) {
      evtToSend = new OnBeingTarget();
      evtToSend.objectThatTargets = evt.objectThatTargets;
      evtToSend.noLongerTarget = evt.noLongerTarget;
      npcPuppet.QueueEvent(evtToSend);
    };
  }

  protected cb func OnInteractionStateChange(value: Variant) -> Bool {
    let psmEvent: ref<PSMPostponedParameterBool>;
    let interactionData: bbUIInteractionData = FromVariant(value);
    if bbUIInteractionData.HasAnyInteraction(interactionData) {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnInteractionStateActive";
    } else {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnInteractionStateInactive";
    };
    psmEvent.value = true;
    this.QueueEvent(psmEvent);
  }

  protected cb func OnUpdateVisibilityModifierEvent(evt: ref<UpdateVisibilityModifierEvent>) -> Bool {
    this.UpdateVisibilityModifier();
  }

  protected cb func OnUpdateAutoRevealStatEvent(evt: ref<UpdateAutoRevealStatEvent>) -> Bool {
    (this.GetPS() as PlayerPuppetPS).SetAutoReveal(evt.hasAutoReveal);
  }

  public final const func HasAutoReveal() -> Bool {
    return (this.GetPS() as PlayerPuppetPS).HasAutoReveal();
  }

  protected cb func OnUIContextChange(value: Bool) -> Bool {
    let psmEvent: ref<PSMPostponedParameterBool>;
    if value {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIContextActive";
    } else {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIContextInactive";
    };
    psmEvent.value = true;
    this.QueueEvent(psmEvent);
  }

  protected cb func OnUIRadialContextChange(value: Bool) -> Bool {
    let psmEvent: ref<PSMPostponedParameterBool>;
    if value {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIRadialContextActive";
    } else {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIRadialContextInactive";
    };
    psmEvent.value = true;
    this.QueueEvent(psmEvent);
  }

  protected cb func OnCurrentVisibleTargetChanged(targetId: EntityID) -> Bool {
    let bbSystem: ref<BlackboardSystem>;
    if !EntityID.IsDefined(targetId) {
      bbSystem = GameInstance.GetBlackboardSystem(this.GetGame());
      bbSystem.Get(GetAllBlackboardDefs().UI_NameplateData).SetInt(GetAllBlackboardDefs().UI_NameplateData.DamageProjection, 0, true);
      GameInstance.GetDamageSystem(this.GetGame()).ClearPreviewTargetStruct();
    };
  }

  protected cb func OnUIContactListContextChanged(value: Bool) -> Bool {
    let psmEvent: ref<PSMPostponedParameterBool>;
    if value {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIContactListContextActive";
    } else {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIContactListContextInactive";
    };
    psmEvent.value = true;
    this.QueueEvent(psmEvent);
  }

  protected cb func OnUIVendorContextChange(value: Bool) -> Bool {
    let psmEvent: ref<PSMPostponedParameterBool>;
    if value {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIVendorContextActive";
    } else {
      psmEvent = new PSMPostponedParameterBool();
      psmEvent.id = n"OnUIVendorContextInactive";
    };
    psmEvent.value = true;
    this.QueueEvent(psmEvent);
  }

  protected cb func OnExperienceGained(evt: ref<ExperiencePointsEvent>) -> Bool {
    let addExpRequest: ref<AddExperience> = new AddExperience();
    addExpRequest.Set(this, evt.amount, evt.type, evt.isDebug);
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PlayerDevelopmentSystem").QueueRequest(addExpRequest);
  }

  protected cb func OnLevelUp(evt: ref<LevelUpdateEvent>) -> Bool;

  protected cb func OnRequestStats(evt: ref<RequestStats>) -> Bool {
    let requestStatsEvent: ref<RequestStatsBB> = new RequestStatsBB();
    requestStatsEvent.Set(this);
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PlayerDevelopmentSystem").QueueRequest(requestStatsEvent);
  }

  protected cb func OnBuyAttribute(evt: ref<RequestBuyAttribute>) -> Bool {
    let attType: gamedataStatType = evt.type;
    let request: ref<BuyAttribute> = new BuyAttribute();
    request.Set(this, attType);
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
  }

  protected cb func OnItemAddedToSlot(evt: ref<ItemAddedToSlot>) -> Bool {
    let equipSlot: SEquipSlot;
    let equipmentBB: ref<IBlackboard>;
    let equipmentData: ref<EquipmentSystemPlayerData>;
    let itemType: gamedataItemCategory;
    let newApp: CName;
    let paperdollEquipData: SPaperdollEquipData;
    let itemID: ItemID = evt.GetItemID();
    let itemTDBID: TweakDBID = ItemID.GetTDBID(itemID);
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(itemTDBID);
    let slotID: TweakDBID = evt.GetSlotID();
    if IsDefined(itemRecord) && IsDefined(itemRecord.ItemCategory()) {
      itemType = itemRecord.ItemCategory().Type();
    };
    if Equals(itemType, gamedataItemCategory.Weapon) {
      newApp = TweakDBInterface.GetCName(itemTDBID + t".specific_player_appearance", n"");
      if NotEquals(newApp, n"") {
        GameInstance.GetTransactionSystem(this.GetGame()).ChangeItemAppearance(this, itemID, newApp);
      };
      if slotID == t"AttachmentSlots.WeaponRight" {
        equipmentBB = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Equipment);
        if IsDefined(equipmentBB) {
          paperdollEquipData.equipArea.areaType = TweakDBInterface.GetItemRecord(itemTDBID).EquipArea().Type();
          paperdollEquipData.equipArea.activeIndex = 0;
          equipSlot.itemID = itemID;
          ArrayPush(paperdollEquipData.equipArea.equipSlots, equipSlot);
          paperdollEquipData.equipped = true;
          paperdollEquipData.placementSlot = EquipmentSystem.GetPlacementSlot(itemID);
          equipmentBB.SetVariant(GetAllBlackboardDefs().UI_Equipment.lastModifiedArea, ToVariant(paperdollEquipData));
        };
      };
    } else {
      if Equals(itemType, gamedataItemCategory.Clothing) {
        equipmentData = EquipmentSystem.GetData(GetPlayer(this.GetGame()));
        if IsDefined(equipmentData) {
          equipmentData.OnEquipProcessVisualTags(itemID);
        };
      };
    };
    if slotID == t"AttachmentSlots.WeaponRight" || slotID == t"AttachmentSlots.WeaponLeft" {
      EquipmentSystemPlayerData.UpdateArmSlot(this, evt.GetItemID(), false);
    };
    super.OnItemAddedToSlot(evt);
  }

  protected cb func OnPartAddedToSlotEvent(evt: ref<PartAddedToSlotEvent>) -> Bool {
    let i: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.partID));
    if IsDefined(itemRecord) {
      itemRecord.OnAttach(packages);
    };
    i = 0;
    while i < ArraySize(packages) {
      RPGManager.ApplyGLP(this, packages[i]);
      i += 1;
    };
  }

  protected cb func OnClearItemAppearanceEvent(evt: ref<ClearItemAppearanceEvent>) -> Bool {
    let equipmentData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(GetPlayer(this.GetGame()));
    equipmentData.OnClearItemAppearance(evt.itemID);
  }

  protected cb func OnResetItemAppearanceEvent(evt: ref<ResetItemAppearanceEvent>) -> Bool {
    let equipmentData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(GetPlayer(this.GetGame()));
    equipmentData.OnResetItemAppearance(evt.itemID);
  }

  protected cb func OnItemRemovedFromSlot(evt: ref<ItemRemovedFromSlot>) -> Bool {
    let equipSlot: SEquipSlot;
    let equipmentBB: ref<IBlackboard>;
    let itemType: gamedataItemCategory;
    let paperdollEquipData: SPaperdollEquipData;
    let itemID: ItemID = evt.GetItemID();
    let itemTDBID: TweakDBID = ItemID.GetTDBID(itemID);
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(itemTDBID);
    if IsDefined(itemRecord) && IsDefined(itemRecord.ItemCategory()) {
      itemType = itemRecord.ItemCategory().Type();
    };
    if Equals(itemType, gamedataItemCategory.Weapon) {
      if evt.GetSlotID() == t"AttachmentSlots.WeaponRight" {
        equipmentBB = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Equipment);
        if IsDefined(equipmentBB) {
          equipSlot.itemID = itemID;
          ArrayPush(paperdollEquipData.equipArea.equipSlots, equipSlot);
          paperdollEquipData.equipArea.activeIndex = 0;
          paperdollEquipData.equipArea.areaType = itemRecord.EquipArea().Type();
          paperdollEquipData.equipped = false;
          paperdollEquipData.placementSlot = EquipmentSystem.GetPlacementSlot(itemID);
          equipmentBB.SetVariant(GetAllBlackboardDefs().UI_Equipment.lastModifiedArea, ToVariant(paperdollEquipData));
        };
      };
    };
    if evt.GetSlotID() == t"AttachmentSlots.WeaponRight" || evt.GetSlotID() == t"AttachmentSlots.WeaponLeft" {
      EquipmentSystemPlayerData.UpdateArmSlot(this, evt.GetItemID(), true);
    };
    super.OnItemRemovedFromSlot(evt);
  }

  private final static func RemoveItemGameplayPackage(objectToRemoveFrom: ref<GameObject>, itemID: ItemID) -> Void {
    let i: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    if IsDefined(itemRecord) {
      itemRecord.OnAttach(packages);
    };
    i = 0;
    while i < ArraySize(packages) {
      RPGManager.RemoveGLP(objectToRemoveFrom, packages[i]);
      i += 1;
    };
  }

  protected cb func OnPartRemovedFromSlotEvent(evt: ref<PartRemovedFromSlotEvent>) -> Bool {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    if !transactionSystem.HasItemInAnySlot(this, evt.itemID) {
      PlayerPuppet.RemoveItemGameplayPackage(this, evt.removedPartID);
    };
  }

  protected cb func OnItemChangedEvent(evt: ref<ItemChangedEvent>) -> Bool {
    let assignHotkey: ref<AssignHotkeyIfEmptySlot>;
    let hotkeyRefresh: ref<HotkeyRefreshRequest>;
    let itemData: ref<gameItemData>;
    let itemType: gamedataItemType = gamedataItemType.Invalid;
    let eqSystem: wref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    if IsDefined(eqSystem) {
      itemData = evt.itemData;
      if RPGManager.GetItemRecord(evt.itemID).IsSingleInstance() {
        this.UpdateInventoryWeight(RPGManager.GetItemWeight(itemData) * Cast(evt.difference));
      };
      if IsDefined(itemData) {
        itemType = itemData.GetItemType();
      };
      if eqSystem.IsItemInHotkey(this, evt.itemID) {
        hotkeyRefresh = new HotkeyRefreshRequest();
        hotkeyRefresh.owner = this;
        eqSystem.QueueRequest(hotkeyRefresh);
      } else {
        if evt.currentQuantity > 0 && Hotkey.IsCompatible(EHotkey.DPAD_UP, itemType) || Hotkey.IsCompatible(EHotkey.RB, itemType) {
          assignHotkey = AssignHotkeyIfEmptySlot.Construct(evt.itemID, this);
          eqSystem.QueueRequest(assignHotkey);
        };
      };
    };
  }

  protected cb func OnPartRemovedEvent(evt: ref<PartRemovedEvent>) -> Bool {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    if transactionSystem.HasItemInAnySlot(this, evt.itemID) {
      PlayerPuppet.RemoveItemGameplayPackage(this, evt.removedPartID);
    };
  }

  protected cb func OnItemAddedToInventory(evt: ref<ItemAddedEvent>) -> Bool {
    let drawItemRequest: ref<DrawItemRequest>;
    let entryString: String;
    let eqSystem: wref<EquipmentSystem>;
    let itemData: wref<gameItemData>;
    let itemLogDataData: ItemID;
    let itemName: String;
    let itemQuality: gamedataQuality;
    let itemRecord: ref<Item_Record>;
    let questSystem: ref<QuestsSystem>;
    let scalingMod: ref<gameStatModifierData>;
    let shouldUpdateLog: Bool;
    if !ItemID.IsValid(evt.itemID) {
      return false;
    };
    itemData = evt.itemData;
    questSystem = GameInstance.GetQuestsSystem(this.GetGame());
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.itemID));
    itemLogDataData = evt.itemID;
    if !itemRecord.IsSingleInstance() {
      this.UpdateInventoryWeight(RPGManager.GetItemWeight(itemData));
    };
    if TweakDBInterface.GetBool(ItemID.GetTDBID(evt.itemID) + t".scaleToPlayer", false) && itemData.GetStatValueByType(gamedataStatType.PowerLevel) <= 1.00 {
      GameInstance.GetStatsSystem(this.GetGame()).RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel, true);
      scalingMod = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gameStatModifierType.Additive, GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.PowerLevel));
      GameInstance.GetStatsSystem(this.GetGame()).AddSavedModifier(itemData.GetStatsObjectID(), scalingMod);
    };
    if IsDefined(itemData) {
      itemQuality = RPGManager.GetItemDataQuality(itemData);
      if itemData.HasTag(n"SkipActivityLog") || itemData.HasTag(n"SkipActivityLogOnLoot") || evt.flaggedAsSilent || itemData.HasTag(n"Currency") {
        shouldUpdateLog = false;
      } else {
        shouldUpdateLog = true;
      };
      if shouldUpdateLog {
        itemName = UIItemsHelper.GetItemName(itemRecord, itemData);
        GameInstance.GetActivityLogSystem(this.GetGame()).AddLog(GetLocalizedText("UI-ScriptExports-Looted") + ": " + itemName);
      };
    };
    if IsDefined(this.m_itemLogBlackboard) {
      this.m_itemLogBlackboard.SetVariant(GetAllBlackboardDefs().UI_ItemLog.ItemLogItem, ToVariant(itemLogDataData), true);
    };
    eqSystem = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    if IsDefined(eqSystem) {
      if ItemID.IsValid(evt.itemID) {
      };
      if Equals(RPGManager.GetItemCategory(evt.itemID), gamedataItemCategory.Weapon) && IsDefined(itemData) && itemData.HasTag(n"TakeAndEquip") {
        drawItemRequest = new DrawItemRequest();
        drawItemRequest.owner = this;
        drawItemRequest.itemID = evt.itemID;
        eqSystem.QueueRequest(drawItemRequest);
      };
    };
    if Equals(RPGManager.GetItemType(evt.itemID), gamedataItemType.Con_Skillbook) {
      GameInstance.GetTelemetrySystem(this.GetGame()).LogSkillbookUsed(ToTelemetryInventoryItem(this, evt.itemID));
      ItemActionsHelper.LearnItem(this, evt.itemID, true);
      this.SetWarningMessage(GetLocalizedText("LocKey#46534") + "\\n" + GetLocalizedText(LocKeyToString(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.itemID)).LocalizedDescription())));
    };
    if Equals(RPGManager.GetItemType(evt.itemID), gamedataItemType.Gen_Readable) {
      GameInstance.GetTransactionSystem(this.GetGame()).RemoveItem(this, evt.itemID, 1);
      entryString = ReadAction.GetJournalEntryFromAction(ItemActionsHelper.GetReadAction(evt.itemID).GetID());
      GameInstance.GetJournalManager(this.GetGame()).ChangeEntryState(entryString, "gameJournalOnscreen", gameJournalEntryState.Active, JournalNotifyOption.Notify);
    };
    if Equals(RPGManager.GetItemType(evt.itemID), gamedataItemType.Gen_Junk) && GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.CanAutomaticallyDisassembleJunk) > 0.00 {
      ItemActionsHelper.DisassembleItem(this, evt.itemID, GameInstance.GetTransactionSystem(this.GetGame()).GetItemQuantity(this, evt.itemID));
    };
    if Equals(RPGManager.GetItemType(evt.itemID), gamedataItemType.Con_Ammo) {
      GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_EquipmentData).SetBool(GetAllBlackboardDefs().UI_EquipmentData.ammoLooted, true);
      GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_EquipmentData).SignalBool(GetAllBlackboardDefs().UI_EquipmentData.ammoLooted);
    };
    if Equals(RPGManager.GetItemType(evt.itemID), gamedataItemType.Gen_Keycard) {
      this.GotKeycardNotification();
    };
    if questSystem.GetFact(n"disable_tutorials") == 0 && questSystem.GetFact(n"q001_show_sts_tut") > 0 {
      if Equals(RPGManager.GetWeaponEvolution(evt.itemID), gamedataWeaponEvolution.Smart) && questSystem.GetFact(n"smart_weapon_tutorial") == 0 {
        questSystem.SetFact(n"smart_weapon_tutorial", 1);
      };
      if Equals(RPGManager.GetWeaponEvolution(evt.itemID), gamedataWeaponEvolution.Tech) && RPGManager.IsTechPierceEnabled(this.GetGame(), this, evt.itemID) && questSystem.GetFact(n"tech_weapon_tutorial") == 0 {
        questSystem.SetFact(n"tech_weapon_tutorial", 1);
      };
      if Equals(RPGManager.GetItemCategory(evt.itemID), gamedataItemCategory.Gadget) && questSystem.GetFact(n"grenade_inventory_tutorial") == 0 {
        questSystem.SetFact(n"grenade_inventory_tutorial", 1);
      };
      if Equals(RPGManager.GetItemCategory(evt.itemID), gamedataItemCategory.Cyberware) && questSystem.GetFact(n"cyberware_inventory_tutorial") == 0 {
        questSystem.SetFact(n"cyberware_inventory_tutorial", 1);
      };
      if (Equals(RPGManager.GetItemType(evt.itemID), gamedataItemType.Con_Inhaler) || Equals(RPGManager.GetItemType(evt.itemID), gamedataItemType.Con_Injector)) && questSystem.GetFact(n"consumable_inventory_tutorial") == 0 {
        questSystem.SetFact(n"consumable_inventory_tutorial", 1);
      };
      if Equals(RPGManager.GetWeaponEvolution(evt.itemID), gamedataWeaponEvolution.Power) && RPGManager.IsRicochetChanceEnabled(this.GetGame(), this, evt.itemID) && questSystem.GetFact(n"power_weapon_tutorial") == 0 && evt.itemID != ItemID.CreateQuery(t"Items.Preset_V_Unity_Cutscene") && evt.itemID != ItemID.CreateQuery(t"Items.Preset_V_Unity") {
        questSystem.SetFact(n"power_weapon_tutorial", 1);
      };
      if RPGManager.IsItemIconic(evt.itemData) && questSystem.GetFact(n"iconic_item_tutorial") == 0 {
        questSystem.SetFact(n"iconic_item_tutorial", 1);
      };
    };
    if questSystem.GetFact(n"initial_gadget_picked") == 0 {
      if Equals(RPGManager.GetItemCategory(evt.itemID), gamedataItemCategory.Gadget) {
        questSystem.SetFact(n"initial_gadget_picked", 1);
      };
    };
    RPGManager.ProcessOnLootedPackages(this, evt.itemID);
    if Equals(itemQuality, gamedataQuality.Legendary) || Equals(itemQuality, gamedataQuality.Iconic) {
      GameInstance.GetAutoSaveSystem(this.GetGame()).RequestCheckpoint();
    };
  }

  public final func UpdateInventoryWeight(weightChange: Float) -> Void {
    this.m_curInventoryWeight += weightChange;
    this.EvaluateEncumbrance();
  }

  protected cb func OnItemBeingRemovedFromInventory(evt: ref<ItemBeingRemovedEvent>) -> Bool {
    let dps: ref<DropPointSystem>;
    let equipData: ref<EquipmentSystemPlayerData>;
    let equipmentSystem: ref<EquipmentSystem>;
    let itemName: String;
    let itemRecord: ref<Item_Record>;
    let unequipRequest: ref<UnequipItemsRequest>;
    let dpsRequest: ref<DropPointRequest> = new DropPointRequest();
    dpsRequest.CreateRequest(ItemID.GetTDBID(evt.itemID), DropPointPackageStatus.COLLECTED);
    if !RPGManager.IsItemSingleInstance(evt.itemData) {
      this.UpdateInventoryWeight(-1.00 * RPGManager.GetItemWeight(evt.itemData));
    };
    if IsDefined(evt.itemData) {
      if !evt.itemData.HasTag(n"SkipActivityLog") && !evt.itemData.HasTag(n"SkipActivityLogOnRemove") {
        itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.itemID));
        itemName = UIItemsHelper.GetItemName(itemRecord, evt.itemData);
        GameInstance.GetActivityLogSystem(this.GetGame()).AddLog(GetLocalizedText("LocKey#26163") + ": " + itemName);
      };
    };
    dps = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DropPointSystem") as DropPointSystem;
    if IsDefined(dps) {
      dps.QueueRequest(dpsRequest);
    };
    this.SendCheckRemovedItemWithSlotActiveItemRequest(evt.itemID);
    equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    if IsDefined(equipmentSystem) {
      if equipmentSystem.IsItemInHotkey(this, evt.itemID) {
      };
      equipData = equipmentSystem.GetPlayerData(this);
      if equipData.IsEquipped(evt.itemID) {
        unequipRequest = new UnequipItemsRequest();
        unequipRequest.owner = this;
        ArrayPush(unequipRequest.items, evt.itemID);
        EquipmentSystem.GetInstance(this).QueueRequest(unequipRequest);
      };
    };
  }

  protected cb func OnInventoryEmpty(evt: ref<OnInventoryEmptyEvent>) -> Bool {
    this.m_curInventoryWeight = 0.00;
    this.EvaluateEncumbrance();
  }

  public final func EvaluateEncumbrance() -> Void {
    let carryCapacity: Float;
    let hasEncumbranceEffect: Bool;
    let isApplyingRestricted: Bool;
    let overweightEffectID: TweakDBID;
    let ses: ref<StatusEffectSystem>;
    if this.m_curInventoryWeight < 0.00 {
      this.m_curInventoryWeight = 0.00;
    };
    ses = GameInstance.GetStatusEffectSystem(this.GetGame());
    overweightEffectID = t"BaseStatusEffect.Encumbered";
    hasEncumbranceEffect = ses.HasStatusEffect(this.GetEntityID(), overweightEffectID);
    isApplyingRestricted = StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"NoEncumbrance");
    carryCapacity = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.CarryCapacity);
    if this.m_curInventoryWeight > carryCapacity && !isApplyingRestricted {
      this.SetWarningMessage(GetLocalizedText("UI-Notifications-Overburden"));
    };
    if this.m_curInventoryWeight > carryCapacity && !hasEncumbranceEffect && !isApplyingRestricted {
      ses.ApplyStatusEffect(this.GetEntityID(), overweightEffectID);
    } else {
      if this.m_curInventoryWeight <= carryCapacity && hasEncumbranceEffect || hasEncumbranceEffect && isApplyingRestricted {
        ses.RemoveStatusEffect(this.GetEntityID(), overweightEffectID);
      };
    };
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerStats).SetFloat(GetAllBlackboardDefs().UI_PlayerStats.currentInventoryWeight, this.m_curInventoryWeight, true);
  }

  private final func CalculateEncumbrance() -> Void {
    let i: Int32;
    let items: array<wref<gameItemData>>;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    TS.GetItemList(this, items);
    i = 0;
    while i < ArraySize(items) {
      this.m_curInventoryWeight += RPGManager.GetItemStackWeight(this, items[i]);
      i += 1;
    };
  }

  protected cb func OnEvaluateEncumbranceEvent(evt: ref<EvaluateEncumbranceEvent>) -> Bool {
    this.EvaluateEncumbrance();
  }

  private final func SendCheckRemovedItemWithSlotActiveItemRequest(item: ItemID) -> Void {
    let request: ref<CheckRemovedItemWithSlotActiveItem> = new CheckRemovedItemWithSlotActiveItem();
    request.itemID = item;
    request.owner = this;
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem").QueueRequest(request);
  }

  protected cb func OnTakedownOrder(evt: ref<OrderTakedownEvent>) -> Bool {
    let squadInterface: ref<PlayerSquadInterface>;
    let takedownCommand: ref<AIFollowerTakedownCommand> = new AIFollowerTakedownCommand();
    takedownCommand.combatCommand = true;
    takedownCommand.target = evt.target;
    if AISquadHelper.GetPlayerSquadInterface(this, squadInterface) {
      squadInterface.BroadcastCommand(takedownCommand);
    };
  }

  protected cb func OnSpiderbotOrderTargetEvent(evt: ref<SpiderbotOrderDeviceEvent>) -> Bool {
    let squadInterface: ref<PlayerSquadInterface>;
    let deviceCommand: ref<AIFollowerDeviceCommand> = new AIFollowerDeviceCommand();
    deviceCommand.target = evt.target;
    deviceCommand.overrideMovementTarget = evt.overrideMovementTarget;
    if AISquadHelper.GetPlayerSquadInterface(this, squadInterface) {
      squadInterface.BroadcastCommand(deviceCommand);
    };
  }

  private final func OnHitBlockedOrDeflected(hitEvent: ref<gameHitEvent>) -> Void {
    if hitEvent.attackData.HasFlag(hitFlag.WasDeflected) {
      AnimationControllerComponent.PushEvent(this, n"MeleeDeflect");
      GameObject.PlayVoiceOver(this, n"meleeDeflect", n"Scripts:OnHitBlockedOrDeflected");
    } else {
      if hitEvent.attackData.HasFlag(hitFlag.WasBlocked) {
        AnimationControllerComponent.PushEvent(this, n"MeleeBlock");
      };
    };
  }

  private final func OnHitAnimation(hitEvent: ref<gameHitEvent>) -> Void {
    this.OnHitAnimation(hitEvent);
    this.GetDamageThresholdParams();
    this.PushHitDataToGraph(hitEvent);
    this.AddOnHitRumble(hitEvent);
    if this.GetZoomBlackboardValues() {
      this.SetZoomBlackboardValues(false);
    };
    TakeOverControlSystem.ReleaseControlOnHit(this);
  }

  private final func AddOnHitRumble(hitEvent: ref<gameHitEvent>) -> Void {
    let direction: Int32;
    let soundName: CName;
    let thresholdHigh: Float;
    let thresholdMed: Float;
    let rumbleIntensityPrefix: String = "light_";
    let rumbleDirectionSuffix: String = "";
    let rumbleDuration: String = "pulse";
    let damageDealt: Float = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
    let totalHealth: Float = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolMaxPointValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health);
    if damageDealt < 1.00 {
      return;
    };
    if AttackData.IsDoT(hitEvent.attackData.GetAttackType()) {
      soundName = TDB.GetCName(t"rumble.local.medium_slow");
      GameObject.PlaySound(this, soundName);
      return;
    };
    damageDealt = damageDealt / totalHealth;
    if AttackData.IsMelee(hitEvent.attackData.GetAttackType()) {
      thresholdMed = TDB.GetFloat(t"player.onHitRumble.meleeMedIntensityThreshold");
      thresholdHigh = TDB.GetFloat(t"player.onHitRumble.meleeHighIntensityThreshold");
      rumbleDuration = "slow";
    } else {
      thresholdMed = TDB.GetFloat(t"player.onHitRumble.medIntensityThreshold");
      thresholdHigh = TDB.GetFloat(t"player.onHitRumble.highIntensityThreshold");
    };
    if damageDealt >= thresholdHigh {
      rumbleIntensityPrefix = "heavy_";
    } else {
      if damageDealt >= thresholdMed {
        rumbleIntensityPrefix = "medium_";
      };
    };
    direction = GameObject.GetAttackAngleInInt(hitEvent);
    if direction == 1 {
      rumbleDirectionSuffix = "_left";
    } else {
      if direction == 3 {
        rumbleDirectionSuffix = "_right";
      };
    };
    soundName = TDB.GetCName(TDBID.Create("rumble.local." + rumbleIntensityPrefix + rumbleDuration + rumbleDirectionSuffix));
    GameObject.PlaySound(this, soundName);
  }

  private final func PushHitDataToGraph(hitEvent: ref<gameHitEvent>) -> Void {
    let minShakeStrength: Float;
    let shakeStrength: Float;
    let enableOnHitCameraShake: Bool = TweakDBInterface.GetBool(t"player.cameraShake.enableOnHitCameraShake", true);
    let useMinMaxRangeValues: Bool = TweakDBInterface.GetBool(t"player.cameraShake.useMinMaxRangeValues", true);
    let minShakeStrengthString: String = "player.cameraShake.";
    let maxShakeStrengthString: String = "player.cameraShake.";
    let damageDealt: Float = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
    let totalHealth: Float = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health);
    damageDealt = damageDealt / totalHealth;
    let attackSource: wref<GameObject> = hitEvent.attackData.GetSource();
    if damageDealt <= 0.00 {
      return;
    };
    if enableOnHitCameraShake {
      if IsDefined(attackSource as SecurityTurret) {
        minShakeStrengthString = minShakeStrengthString + "defaultMedMin";
        maxShakeStrengthString = maxShakeStrengthString + "defaultMedMax";
      } else {
        if AttackData.IsDoT(hitEvent.attackData.GetAttackType()) && StatusEffectSystem.ObjectHasStatusEffect(hitEvent.target, t"BaseStatusEffect.OutOfOxygen") {
          minShakeStrengthString = minShakeStrengthString + "outOfOxyMin";
          maxShakeStrengthString = maxShakeStrengthString + "outOfOxyMax";
        } else {
          if AttackData.IsExplosion(hitEvent.attackData.GetAttackType()) {
            if damageDealt >= this.m_explosionHighDamageThreshold {
              minShakeStrengthString = minShakeStrengthString + "explosionHighMin";
              maxShakeStrengthString = maxShakeStrengthString + "explosionHighMax";
            } else {
              if damageDealt >= this.m_explosionMedDamageThreshold {
                minShakeStrengthString = minShakeStrengthString + "explosionMedMin";
                maxShakeStrengthString = maxShakeStrengthString + "explosionMedMax";
              } else {
                if damageDealt >= this.m_explosionLowDamageThreshold {
                  minShakeStrengthString = minShakeStrengthString + "explosionLowMin";
                  maxShakeStrengthString = maxShakeStrengthString + "explosionLowMax";
                };
              };
            };
          } else {
            if AttackData.IsMelee(hitEvent.attackData.GetAttackType()) {
              if damageDealt >= this.m_meleeHighDamageThreshold {
                minShakeStrengthString = minShakeStrengthString + "meleeHighMin";
                maxShakeStrengthString = maxShakeStrengthString + "meleeHighMax";
              } else {
                if damageDealt >= this.m_meleeMedDamageThreshold {
                  minShakeStrengthString = minShakeStrengthString + "meleeMedMin";
                  maxShakeStrengthString = maxShakeStrengthString + "meleeMedMax";
                } else {
                  if damageDealt >= this.m_meleeLowDamageThreshold {
                    minShakeStrengthString = minShakeStrengthString + "meleeLowMin";
                    maxShakeStrengthString = maxShakeStrengthString + "meleeLowMax";
                  };
                };
              };
            } else {
              if damageDealt >= this.m_highDamageThreshold {
                minShakeStrengthString = minShakeStrengthString + "defaultLowMin";
                maxShakeStrengthString = maxShakeStrengthString + "defaultLowMax";
              } else {
                if damageDealt >= this.m_medDamageThreshold {
                  minShakeStrengthString = minShakeStrengthString + "defaultMedMin";
                  maxShakeStrengthString = maxShakeStrengthString + "defaultMedMax";
                } else {
                  if damageDealt >= this.m_lowDamageThreshold {
                    minShakeStrengthString = minShakeStrengthString + "defaultHighMin";
                    maxShakeStrengthString = maxShakeStrengthString + "defaultHighMax";
                  };
                };
              };
            };
          };
        };
      };
      minShakeStrength = TweakDBInterface.GetFloat(TDBID.Create(minShakeStrengthString), 0.00);
      shakeStrength = TweakDBInterface.GetFloat(TDBID.Create(maxShakeStrengthString), 0.00);
    } else {
      shakeStrength = 0.00;
    };
    if useMinMaxRangeValues {
      shakeStrength = RandRangeF(minShakeStrength, shakeStrength);
    };
    this.SendCameraShakeDataToGraph(hitEvent, shakeStrength);
  }

  private final func SendCameraShakeDataToGraph(opt hitEvent: ref<gameHitEvent>, shakeStrength: Float) -> Void {
    let attackRecord: ref<Attack_Melee_Record>;
    let animFeature: ref<AnimFeature_PlayerHitReactionData> = new AnimFeature_PlayerHitReactionData();
    let attackType: gamedataAttackType = hitEvent.attackData.GetAttackType();
    animFeature.isMeleeHit = AttackData.IsMelee(attackType);
    animFeature.isLightMeleeHit = AttackData.IsLightMelee(attackType);
    animFeature.isStrongMeleeHit = AttackData.IsStrongMelee(attackType);
    animFeature.isQuickMeleeHit = AttackData.IsQuickMelee(attackType);
    animFeature.isExplosion = AttackData.IsExplosion(attackType);
    animFeature.isPressureWave = AttackData.IsPressureWave(attackType);
    if animFeature.isMeleeHit {
      attackRecord = hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_Melee_Record;
      animFeature.meleeAttackDirection = EnumInt(attackRecord.AttackDirection().Direction().Type());
    };
    animFeature.hitDirection = GameObject.GetAttackAngleInFloat(hitEvent);
    animFeature.hitStrength = shakeStrength;
    AnimationControllerComponent.ApplyFeature(this, n"HitReactionData", animFeature);
    AnimationControllerComponent.PushEvent(this, n"Hit");
  }

  private final func OnHitUI(hitEvent: ref<gameHitEvent>) -> Void {
    let dmgType: gamedataDamageType;
    let effName: CName;
    let attackValues: array<Float> = hitEvent.attackComputed.GetAttackValues();
    let i: Int32 = 0;
    while i < ArraySize(attackValues) {
      if attackValues[i] > 0.00 {
        dmgType = IntEnum(i);
      } else {
        i += 1;
      };
    };
    switch dmgType {
      case gamedataDamageType.Thermal:
        effName = n"fire_damage_indicator";
        break;
      case gamedataDamageType.Electric:
        effName = n"emp_damage_indicator";
        break;
      default:
    };
    if AttackData.IsDoT(hitEvent.attackData.GetAttackType()) {
      if hitEvent.attackData.GetAttackDefinition().GetRecord().GetID() == t"Attacks.OutOfOxygenDamageOverTime" {
        effName = n"status_pain";
      };
    };
    GameObjectEffectHelper.StartEffectEvent(this, effName);
  }

  private final func OnHitSounds(hitEvent: ref<gameHitEvent>) -> Void {
    let damagePercentage: Float;
    let damageSwitch: ref<SoundSwitchEvent>;
    let damageValue: Float;
    let forwardLocalToWorldAngle: Float;
    let hitDirection: Vector4;
    let playerOutOfOxygen: Bool;
    let soundEvent: ref<SoundPlayEvent>;
    let soundParamAxisX: ref<SoundParameterEvent>;
    let soundParamAxisY: ref<SoundParameterEvent>;
    let target: ref<GameObject>;
    let totalHealth: Float;
    this.OnHitSounds(hitEvent);
    playerOutOfOxygen = hitEvent.attackData.GetAttackDefinition().GetRecord().GetID() == t"Attacks.OutOfOxygenDamageOverTime";
    if playerOutOfOxygen {
      return;
    };
    soundEvent = new SoundPlayEvent();
    damageSwitch = new SoundSwitchEvent();
    soundParamAxisX = new SoundParameterEvent();
    soundParamAxisY = new SoundParameterEvent();
    target = hitEvent.target;
    forwardLocalToWorldAngle = Vector4.Heading(target.GetWorldForward());
    hitDirection = Vector4.RotByAngleXY(hitEvent.hitDirection, forwardLocalToWorldAngle);
    soundParamAxisX.parameterName = n"RTPC_Positioning_2D_LR_axis";
    soundParamAxisX.parameterValue = hitDirection.X * 100.00;
    soundParamAxisY.parameterName = n"RTPC_Positioning_2D_FB_axis";
    soundParamAxisY.parameterValue = hitDirection.Y * 100.00;
    target.QueueEvent(soundParamAxisX);
    target.QueueEvent(soundParamAxisY);
    damageSwitch.switchName = n"SW_Impact_Velocity";
    damageValue = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
    if damageValue >= this.m_highDamageThreshold {
      damageSwitch.switchValue = n"SW_Impact_Velocity_Hi";
    } else {
      if damageValue >= this.m_medDamageThreshold {
        damageSwitch.switchValue = n"SW_Impact_Velocity_Med";
      } else {
        if damageValue >= this.m_lowDamageThreshold {
          damageSwitch.switchValue = n"SW_Impact_Velocity_Low";
        };
      };
    };
    target.QueueEvent(damageSwitch);
    GameObject.PlayVoiceOver(this, n"onPlayerHit", n"Scripts:OnHitSounds");
    if !hitEvent.attackData.GetWeapon().GetItemData().HasTag(WeaponObject.GetMeleeWeaponTag()) {
      totalHealth = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolMaxPointValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health);
      damagePercentage = ClampF(damageValue, 0.00, totalHealth) / totalHealth * 100.00;
      GameInstance.GetAudioSystem(this.GetGame()).GlobalParameter(n"w_feedback_player_damage", damagePercentage);
      soundEvent.soundName = n"w_feedback_player_damage";
      target.QueueEvent(soundEvent);
    };
    if IsClient() && this.IsControlledByLocalPeer() && GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.CPO_Armor) == 0.00 {
      soundEvent.soundName = n"test_ad_emitter_2_1";
      target.QueueEvent(soundEvent);
    };
  }

  protected cb func OnDamageInflicted(evt: ref<DamageInflictedEvent>) -> Bool {
    this.m_lastDmgInflicted = GameInstance.GetSimTime(this.GetGame());
  }

  public final func GetLastDamageInflictedTime() -> EngineTime {
    return this.m_lastDmgInflicted;
  }

  protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let clearDataEvent: ref<CPOMissionDataTransferred>;
    let currentDataOwner: ref<PlayerPuppet>;
    let receivingData: ref<PlayerPuppet>;
    let transferDataEvent: ref<CPOMissionDataTransferred>;
    let choice: String = choiceEvent.choice.choiceMetaData.tweakDBName;
    if Equals(choice, "TakeCPOMissionDataFromPlayer") {
      currentDataOwner = choiceEvent.hotspot as PlayerPuppet;
      receivingData = choiceEvent.activator as PlayerPuppet;
      clearDataEvent = new CPOMissionDataTransferred();
      clearDataEvent.dataDownloaded = false;
      clearDataEvent.isChoiceToken = currentDataOwner.m_CPOMissionDataState.m_isChoiceToken;
      currentDataOwner.QueueEvent(clearDataEvent);
      transferDataEvent = new CPOMissionDataTransferred();
      transferDataEvent.dataDownloaded = true;
      transferDataEvent.compatibleDeviceName = currentDataOwner.m_CPOMissionDataState.m_compatibleDeviceName;
      transferDataEvent.dataDamagesPresetName = currentDataOwner.m_CPOMissionDataState.m_CPOMissionDataDamagesPreset;
      transferDataEvent.ownerDecidesOnTransfer = currentDataOwner.m_CPOMissionDataState.m_ownerDecidesOnTransfer;
      transferDataEvent.isChoiceToken = currentDataOwner.m_CPOMissionDataState.m_isChoiceToken;
      transferDataEvent.choiceTokenTimeout = currentDataOwner.m_CPOMissionDataState.m_choiceTokenTimeout;
      receivingData.QueueEvent(transferDataEvent);
    } else {
      if Equals(choice, "GiveCPOMissionDataToPlayer") {
        receivingData = choiceEvent.hotspot as PlayerPuppet;
        currentDataOwner = choiceEvent.activator as PlayerPuppet;
        clearDataEvent = new CPOMissionDataTransferred();
        clearDataEvent.dataDownloaded = false;
        clearDataEvent.isChoiceToken = currentDataOwner.m_CPOMissionDataState.m_isChoiceToken;
        currentDataOwner.QueueEvent(clearDataEvent);
        transferDataEvent = new CPOMissionDataTransferred();
        transferDataEvent.dataDownloaded = true;
        transferDataEvent.compatibleDeviceName = currentDataOwner.m_CPOMissionDataState.m_compatibleDeviceName;
        transferDataEvent.dataDamagesPresetName = currentDataOwner.m_CPOMissionDataState.m_CPOMissionDataDamagesPreset;
        transferDataEvent.ownerDecidesOnTransfer = currentDataOwner.m_CPOMissionDataState.m_ownerDecidesOnTransfer;
        transferDataEvent.isChoiceToken = currentDataOwner.m_CPOMissionDataState.m_isChoiceToken;
        transferDataEvent.choiceTokenTimeout = currentDataOwner.m_CPOMissionDataState.m_choiceTokenTimeout;
        receivingData.QueueEvent(transferDataEvent);
      };
    };
    super.OnInteraction(choiceEvent);
  }

  protected cb func OnTogglePlayerFlashlightEvent(evt: ref<TogglePlayerFlashlightEvent>) -> Bool {
    let comp: wref<IComponent> = this.FindComponentByName(n"TEMP_flashlight");
    if IsDefined(comp) {
      comp.Toggle(evt.enable);
    };
  }

  protected cb func OnMagFieldHitEvent(evt: ref<MagFieldHitEvent>) -> Bool {
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
    let delayKatanaEvent: ref<KatanaMagFieldHitDelayEvent> = new KatanaMagFieldHitDelayEvent();
    let delayResetEvent: ref<ResetMagFieldHitsEvent> = new ResetMagFieldHitsEvent();
    let minAdditiveTriggerTime: Float = TweakDBInterface.GetFloat(t"playerStateMachineMelee.meleeBendBullets.minAdditiveTriggerTime", 0.10);
    let maxAdditiveTriggerTime: Float = TweakDBInterface.GetFloat(t"playerStateMachineMelee.meleeBendBullets.maxAdditiveTriggerTime", 0.50);
    if !this.m_waitingForDelayEvent {
      this.m_randomizedTime = RandRangeF(minAdditiveTriggerTime, maxAdditiveTriggerTime);
      delaySystem.DelayEvent(this, delayKatanaEvent, this.m_randomizedTime);
      this.m_waitingForDelayEvent = true;
      this.m_katanaAnimProgression += TweakDBInterface.GetFloat(t"playerStateMachineMelee.meleeBendBullets.animProgressToAdd", 0.40);
      this.m_katanaAnimProgression = ClampF(this.m_katanaAnimProgression, 0.00, 1.00);
      this.SendMagFieldAnimFeature();
      AnimationControllerComponent.SetInputFloat(this, n"mag_field_hit_rand", RandRangeF(0.00, 3.00));
      AnimationControllerComponent.PushEvent(this, n"MagFieldOnHit");
    };
    delaySystem.CancelDelay(this.m_delayEventID);
    this.m_delayEventID = delaySystem.DelayEvent(this, delayResetEvent, TweakDBInterface.GetFloat(t"playerStateMachineMelee.meleeBendBullets.delayBeforeResetting", 0.00));
    this.m_isResetting = false;
  }

  protected final func OnKatanaMagFieldHitDelayEvent(evt: ref<KatanaMagFieldHitDelayEvent>) -> Void {
    this.m_waitingForDelayEvent = false;
  }

  protected final func OnResetMagFieldHitsEvent(evt: ref<ResetMagFieldHitsEvent>) -> Void {
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
    let tickableEvent: ref<ResetTickEvent> = new ResetTickEvent();
    delaySystem.CancelTick(this.m_resetTickID);
    this.m_resetTickID = delaySystem.TickOnEvent(this, tickableEvent, 5.00);
    this.m_isResetting = true;
  }

  protected cb func OnResetTickEvent(evt: ref<ResetTickEvent>) -> Bool {
    if this.m_isResetting {
      this.m_katanaAnimProgression -= TweakDBInterface.GetFloat(t"playerStateMachineMelee.meleeBendBullets.animProgressToRemove", 0.01);
      this.m_katanaAnimProgression = ClampF(this.m_katanaAnimProgression, 0.00, 1.00);
      this.SendMagFieldAnimFeature();
    };
  }

  protected final func SendMagFieldAnimFeature() -> Void {
    let animFeature: ref<AnimFeature_BulletBend> = new AnimFeature_BulletBend();
    animFeature.animProgression = this.m_katanaAnimProgression;
    animFeature.isResetting = this.m_isResetting;
    AnimationControllerComponent.ApplyFeature(this, n"BulletBendData", animFeature);
  }

  private final func InitializeTweakDBRecords() -> Void {
    this.m_coverRecordID = t"Character.Player_Cover_Modifier";
    this.m_damageReductionRecordID = t"Character.Player_Workspot_DamageReduction_Modifier";
    this.m_visReductionRecordID = t"Character.Player_Workspot_VisibilityReduction_Modifier";
  }

  protected final func DefineModifierGroups() -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    statsSystem.DefineModifierGroupFromRecord(TDBID.ToNumber(this.m_damageReductionRecordID), this.m_damageReductionRecordID);
    statsSystem.DefineModifierGroupFromRecord(TDBID.ToNumber(this.m_visReductionRecordID), this.m_visReductionRecordID);
    statsSystem.DefineModifierGroupFromRecord(TDBID.ToNumber(this.m_coverRecordID), this.m_coverRecordID);
  }

  protected final func RegisterStatListeners(self: ref<PlayerPuppet>) -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: EntityID = this.GetEntityID();
    this.m_visibilityListener = new VisibilityStatListener();
    this.m_visibilityListener.SetStatType(gamedataStatType.Visibility);
    this.m_visibilityListener.m_owner = self;
    statsSystem.RegisterListener(Cast(entityID), this.m_visibilityListener);
    this.m_secondHeartListener = new SecondHeartStatListener();
    this.m_secondHeartListener.SetStatType(gamedataStatType.HasSecondHeart);
    this.m_secondHeartListener.m_player = self;
    statsSystem.RegisterListener(Cast(entityID), this.m_secondHeartListener);
    this.m_healthStatListener = new HealthStatListener();
    this.m_healthStatListener.m_ownerPuppet = self;
    statPoolsSystem.RequestRegisteringListener(Cast(entityID), gamedataStatPoolType.Health, this.m_healthStatListener);
    this.m_oxygenStatListener = new OxygenStatListener();
    this.m_oxygenStatListener.SetValue(TweakDBInterface.GetFloat(t"player.oxygenThresholds.critOxygenThreshold", 10.00));
    this.m_oxygenStatListener.m_ownerPuppet = self;
    statPoolsSystem.RequestRegisteringListener(Cast(entityID), gamedataStatPoolType.Oxygen, this.m_oxygenStatListener);
    this.m_autoRevealListener = new AutoRevealStatListener();
    this.m_autoRevealListener.SetStatType(gamedataStatType.AutoReveal);
    this.m_autoRevealListener.m_owner = self;
    statsSystem.RegisterListener(Cast(entityID), this.m_autoRevealListener);
    this.m_aimAssistListener = new AimAssistSettingsListener();
    this.m_aimAssistListener.Initialize(self);
    if this.IsControlledByLocalPeer() {
      this.m_armorStatListener = new ArmorStatListener();
      this.m_armorStatListener.m_ownerPuppet = self;
      statPoolsSystem.RequestRegisteringListener(Cast(entityID), gamedataStatPoolType.CPO_Armor, this.m_armorStatListener);
    };
    this.m_memoryListener = new MemoryListener();
    this.m_memoryListener.m_player = this;
    statPoolsSystem.RequestRegisteringListener(Cast(entityID), gamedataStatPoolType.Memory, this.m_memoryListener);
    this.m_staminaListener = new StaminaListener();
    this.m_staminaListener.Init(this);
    statPoolsSystem.RequestRegisteringListener(Cast(entityID), gamedataStatPoolType.Stamina, this.m_staminaListener);
  }

  protected final func UnregisterStatListeners(self: ref<PlayerPuppet>) -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: EntityID = this.GetEntityID();
    statsSystem.UnregisterListener(Cast(entityID), this.m_visibilityListener);
    this.m_visibilityListener = null;
    statsSystem.UnregisterListener(Cast(entityID), this.m_secondHeartListener);
    this.m_secondHeartListener = null;
    statsSystem.UnregisterListener(Cast(entityID), this.m_autoRevealListener);
    this.m_autoRevealListener = null;
    if this.IsControlledByLocalPeer() {
      statPoolsSystem.RequestUnregisteringListener(Cast(entityID), gamedataStatPoolType.CPO_Armor, this.m_armorStatListener);
      this.m_armorStatListener = null;
    };
    this.m_aimAssistListener = null;
    statPoolsSystem.RequestUnregisteringListener(Cast(entityID), gamedataStatPoolType.Health, this.m_healthStatListener);
    this.m_healthStatListener = null;
    statPoolsSystem.RequestUnregisteringListener(Cast(entityID), gamedataStatPoolType.Oxygen, this.m_oxygenStatListener);
    this.m_oxygenStatListener = null;
    statPoolsSystem.RequestUnregisteringListener(Cast(entityID), gamedataStatPoolType.Memory, this.m_memoryListener);
    this.m_memoryListener = null;
    statPoolsSystem.RequestUnregisteringListener(Cast(entityID), gamedataStatPoolType.Memory, this.m_staminaListener);
    this.m_staminaListener = null;
  }

  protected cb func OnCleanUpTimeDilationEvent(evt: ref<CleanUpTimeDilationEvent>) -> Bool {
    let reason: CName;
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(this.GetGame());
    timeSystem.UnsetTimeDilation(evt.reason, n"");
    timeSystem.SetTimeDilationOnLocalPlayerZero(reason, 1.00, 0.10, n"", n"", false);
    timeSystem.SetIgnoreTimeDilationOnLocalPlayerZero(false);
    timeSystem.UnsetTimeDilationOnLocalPlayerZero(n"");
  }

  protected cb func OnHealthUpdateEvent(evt: ref<HealthUpdateEvent>) -> Bool {
    this.UpdateHealthStateSFX(evt);
    this.UpdateHealthStateVFX(evt);
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerStats).SetInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentHealth, Cast(evt.value), true);
  }

  private final func UpdateHealthStateSFX(evt: ref<HealthUpdateEvent>) -> Void {
    let lowHealthThreshold: Float = PlayerPuppet.GetLowHealthThreshold();
    let critHealthThreshold: Float = PlayerPuppet.GetCriticalHealthThreshold();
    GameInstance.GetAudioSystem(this.GetGame()).GlobalParameter(n"g_player_health", evt.value);
    if evt.value > lowHealthThreshold {
      GameInstance.GetAudioSystem(this.GetGame()).NotifyGameTone(n"InNormalHealth");
    } else {
      GameInstance.GetAudioSystem(this.GetGame()).NotifyGameTone(n"InLowHealth");
      if evt.value > TweakDBInterface.GetFloat(t"player.hitVFX.critHealthRumbleEndThreshold", 30.00) {
        this.m_critHealthRumblePlayed = false;
        this.StopCritHealthRumble();
      };
      if evt.value <= critHealthThreshold && evt.value > 0.00 {
        if !this.m_critHealthRumblePlayed {
          this.m_critHealthRumblePlayed = true;
          this.PlayCritHealthRumble();
          GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_critHealthRumbleDurationID);
          this.m_critHealthRumbleDurationID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new StopCritHealthRumble(), TweakDBInterface.GetFloat(t"player.hitVFX.critHealthRumbleMaxDuration", 8.00));
        };
      };
    };
  }

  protected cb func OnStopCritHealthRumble(evt: ref<StopCritHealthRumble>) -> Bool {
    this.StopCritHealthRumble();
  }

  private final func PlayCritHealthRumble() -> Void {
    GameObject.PlaySound(this, TDB.GetCName(t"rumble.local.loop_light"));
  }

  private final func StopCritHealthRumble() -> Void {
    GameObject.StopSound(this, TDB.GetCName(t"rumble.local.loop_light"));
  }

  private final func UpdateHealthStateVFX(evt: ref<HealthUpdateEvent>) -> Void {
    let lowHealthThreshold: Float = PlayerPuppet.GetLowHealthThreshold();
    let critHealthThreshold: Float = PlayerPuppet.GetCriticalHealthThreshold();
    if IsClient() && this.IsControlledByLocalPeer() || !IsMultiplayer() {
      if evt.value >= lowHealthThreshold && IsDefined(this.m_healthVfxBlackboard) {
        GameObjectEffectHelper.BreakEffectLoopEvent(this, n"fx_health_low");
        this.m_healthVfxBlackboard = null;
        GameInstance.GetTelemetrySystem(this.GetGame()).LogPlayerReachedCriticalHealth(false);
        GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().PhotoMode).SetUint(GetAllBlackboardDefs().PhotoMode.PlayerHealthState, 0u);
      } else {
        if evt.value <= critHealthThreshold && TweakDBInterface.GetBool(t"player.hitVFX.useCriticalThreshold", false) {
          if !IsDefined(this.m_healthVfxBlackboard) {
            this.m_healthVfxBlackboard = new worldEffectBlackboard();
            this.m_healthVfxBlackboard.SetValue(n"health_state", evt.value / critHealthThreshold);
            GameObjectEffectHelper.StartEffectEvent(this, n"fx_health_critical", false, this.m_healthVfxBlackboard);
            GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().PhotoMode).SetUint(GetAllBlackboardDefs().PhotoMode.PlayerHealthState, 2u);
          } else {
            this.m_healthVfxBlackboard.SetValue(n"health_state", evt.value / critHealthThreshold);
          };
        } else {
          if evt.value <= lowHealthThreshold {
            if !IsDefined(this.m_healthVfxBlackboard) {
              this.m_healthVfxBlackboard = new worldEffectBlackboard();
              this.m_healthVfxBlackboard.SetValue(n"health_state", evt.value / lowHealthThreshold);
              GameObjectEffectHelper.StartEffectEvent(this, n"fx_health_low", false, this.m_healthVfxBlackboard);
              GameInstance.GetTelemetrySystem(this.GetGame()).LogPlayerReachedCriticalHealth(true);
              ReactionManagerComponent.SendVOEventToSquad(this, n"player_fallback");
              GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().PhotoMode).SetUint(GetAllBlackboardDefs().PhotoMode.PlayerHealthState, 1u);
            } else {
              this.m_healthVfxBlackboard.SetValue(n"health_state", evt.value / lowHealthThreshold);
            };
          };
        };
      };
    };
  }

  private final func SetZoomBlackboardValues(newState: Bool) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice, newState);
    playerStateMachineBlackboard.FireCallbacks();
  }

  private final func GetZoomBlackboardValues() -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return playerStateMachineBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice);
  }

  protected cb func OnRewardEvent(evt: ref<RewardEvent>) -> Bool {
    RPGManager.GiveReward(this.GetGame(), evt.rewardName);
  }

  protected cb func OnManagePersonalLinkChangeEvent(evt: ref<ManagePersonalLinkChangeEvent>) -> Bool {
    RPGManager.TogglePersonalLinkAppearance(this);
    RPGManager.ToggleHolsteredArmAppearance(this, evt.shouldEquip);
  }

  public final const func GetPhoneCallFactName(contactName1: CName, contactName2: CName) -> String {
    let phoneSystem: ref<PhoneSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PhoneSystem") as PhoneSystem;
    return phoneSystem.GetPhoneCallFactName(contactName1, contactName2);
  }

  private final func TriggerInspect(itemID: String, offset: Float, adsOffset: Float, timeToScan: Float) -> Void {
    let evt: ref<InspectionTriggerEvent>;
    let scanEvt: ref<ScanEvent>;
    GameInstance.GetTransactionSystem(this.GetGame()).AddItemToSlot(this, t"AttachmentSlots.Inspect", ItemID.FromTDBID(TDBID.Create(itemID)));
    scanEvt = new ScanEvent();
    scanEvt.isAvailable = true;
    scanEvt.clue = itemID;
    this.QueueEvent(scanEvt);
    evt = new InspectionTriggerEvent();
    evt.item = itemID;
    evt.offset = offset;
    evt.adsOffset = adsOffset;
    evt.timeToScan = timeToScan;
    this.QueueEvent(evt);
  }

  public final func SetInvisible(isInvisible: Bool) -> Void {
    this.m_visibleObjectComponent.Toggle(!isInvisible);
  }

  protected cb func OnHeavyFootstepEvent(evt: ref<HeavyFootstepEvent>) -> Bool {
    this.PlayFootstepCameraShakeBasedOnProximity(evt);
  }

  private final func PlayFootstepCameraShakeBasedOnProximity(evt: ref<HeavyFootstepEvent>) -> Void {
    let distanceToNPC: Float;
    let maxFootstepDistanceThreshold: Float;
    let medFootstepDistanceThreshold: Float;
    let minFootstepDistanceThreshold: Float;
    let rumbleName: CName;
    let shakeStrength: Float;
    let rumbleIntensityPrefix: String = "light_";
    let rumbleDuration: String = "pulse";
    let footstepStylePrefix: String = "footstepWalk";
    switch evt.audioEventName {
      case n"nme_boss_smasher_lcm_walk":
        rumbleIntensityPrefix = "light_";
        footstepStylePrefix = "footstepWalk";
        break;
      case n"nme_boss_smasher_lcm_sprint":
        rumbleIntensityPrefix = "medium_";
        footstepStylePrefix = "footstepSprint";
        break;
      case n"enm_mech_minotaur_loco_fs_heavy":
        rumbleIntensityPrefix = "medium_";
        footstepStylePrefix = "footstepWalk";
        break;
      case n"lcm_npc_exo_":
        rumbleIntensityPrefix = "medium_";
        footstepStylePrefix = "footstepWalk";
    };
    minFootstepDistanceThreshold = TDB.GetFloat(t"player.onFootstepRumble.minFootstepDistanceThreshold");
    medFootstepDistanceThreshold = TDB.GetFloat(t"player.onFootstepRumble.medFootstepDistanceThreshold");
    maxFootstepDistanceThreshold = TDB.GetFloat(t"player.onFootstepRumble.maxFootstepDistanceThreshold");
    distanceToNPC = Vector4.Distance2D(evt.instigator.GetWorldPosition(), this.GetWorldPosition());
    if distanceToNPC > maxFootstepDistanceThreshold {
      return;
    };
    if distanceToNPC >= medFootstepDistanceThreshold {
      shakeStrength = TDB.GetFloat(TDBID.Create("player.cameraShake." + footstepStylePrefix + "Med"));
    } else {
      if distanceToNPC >= minFootstepDistanceThreshold {
        shakeStrength = TDB.GetFloat(TDBID.Create("player.cameraShake." + footstepStylePrefix + "High"));
      } else {
        shakeStrength = TDB.GetFloat(TDBID.Create("player.cameraShake." + footstepStylePrefix + "Low"));
      };
    };
    rumbleName = TDB.GetCName(TDBID.Create("rumble.local." + rumbleIntensityPrefix + rumbleDuration));
    GameObject.PlaySound(this, rumbleName);
    this.SendCameraShakeDataToGraph(shakeStrength);
  }

  public final func UpdateVisibility() -> Void {
    let shouldUseCombatVisibility: Bool = false;
    let shouldCoverModiferBeActive: Bool = this.m_behindCover && !this.m_coverVisibilityPerkBlocked && !this.m_inCombat;
    shouldUseCombatVisibility = this.m_coverVisibilityPerkBlocked || this.m_inCombat;
    this.EnableCombatVisibilityDistances(shouldUseCombatVisibility);
    if shouldCoverModiferBeActive && !this.m_coverModifierActive {
      this.m_coverModifierActive = GameInstance.GetStatsSystem(this.GetGame()).ApplyModifierGroup(Cast(this.GetEntityID()), TDBID.ToNumber(this.m_coverRecordID));
    } else {
      if !shouldCoverModiferBeActive && this.m_coverModifierActive {
        GameInstance.GetStatsSystem(this.GetGame()).RemoveModifierGroup(Cast(this.GetEntityID()), TDBID.ToNumber(this.m_coverRecordID));
        this.m_coverModifierActive = false;
      };
    };
  }

  private final func UpdateSecondaryVisibilityOffset(isCrouching: Bool) -> Void {
    let objectOffsetEvent: ref<VisibleObjectSecondaryPositionEvent> = new VisibleObjectSecondaryPositionEvent();
    objectOffsetEvent.offset.X = 0.00;
    objectOffsetEvent.offset.Y = 0.00;
    objectOffsetEvent.offset.Z = isCrouching ? TweakDBInterface.GetFloat(t"player.stealth.crouchVisibilityZOffset", 0.60) : TweakDBInterface.GetFloat(t"player.stealth.chestVisibilityZOffset", 1.30);
    this.QueueEvent(objectOffsetEvent);
  }

  private final func EnableCombatVisibilityDistances(enable: Bool) -> Void {
    let objectDistanceEvent: ref<VisibleObjectDistanceEvent> = new VisibleObjectDistanceEvent();
    let objectSecondaryDistanceEvent: ref<VisibleObjectetSecondaryDistanceEvent> = new VisibleObjectetSecondaryDistanceEvent();
    let nearDistance: Float = TweakDBInterface.GetFloat(t"player.stealth.nearVisibilityDistance", 200.00);
    let farDistance: Float = TweakDBInterface.GetFloat(t"player.stealth.farVisibilityDistance", 5.00);
    objectDistanceEvent.distance = enable ? farDistance : nearDistance;
    objectSecondaryDistanceEvent.distance = enable ? nearDistance : farDistance;
    this.QueueEvent(objectDistanceEvent);
    this.QueueEvent(objectSecondaryDistanceEvent);
  }

  protected cb func OnLocomotionStateChanged(newState: Int32) -> Bool {
    let isCrouching: Bool = newState == EnumInt(gamePSMLocomotionStates.Crouch);
    if NotEquals(this.m_inCrouch, isCrouching) {
      this.UpdateSecondaryVisibilityOffset(isCrouching);
      this.m_inCrouch = isCrouching;
    };
  }

  protected cb func OnCombatStateChanged(newState: Int32) -> Bool {
    let inCombat: Bool = newState == EnumInt(gamePSMCombat.InCombat);
    if NotEquals(inCombat, this.m_inCombat) {
      if !inCombat {
        (this.GetPS() as PlayerPuppetPS).SetCombatExitTimestamp(EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGame()).GetSimTime()));
      };
      this.m_inCombat = inCombat;
      this.UpdateVisibility();
      if !this.m_inCombat {
        this.m_hasBeenDetected = false;
      } else {
        this.GetPlayerPerkDataBlackboard().SetUint(GetAllBlackboardDefs().PlayerPerkData.EntityNoticedPlayer, 0u);
      };
      GameInstance.GetPlayerSystem(this.GetGame()).PlayerEnteredCombat(this.m_inCombat);
    };
    if inCombat {
      (this.GetTargetTrackerComponent() as TargetTrackingExtension).RemoveHostileCamerasFromThreats();
      this.GetSensorObjectComponent().RemoveForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
    } else {
      this.GetSensorObjectComponent().SetForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
    };
  }

  protected cb func OnNumberOfCombatantsChanged(value: Uint32) -> Bool {
    let rumbleName: CName;
    if this.m_numberOfCombatants == 0 && value > 0u && !this.m_hasBeenDetected {
      this.m_hasBeenDetected = true;
      if TweakDBInterface.GetBool(t"player.stealth.playDetectedSound", false) {
        GameObject.PlaySound(this, n"ui_gmpl_stealth_detection");
        rumbleName = TDB.GetCName(t"rumble.local.medium_fast");
        GameObject.PlaySound(this, rumbleName);
      };
    };
    this.m_numberOfCombatants = Cast(value);
    GameInstance.GetTelemetrySystem(this.GetGame()).LogNumberOfCombatants(this.m_numberOfCombatants);
  }

  protected cb func OnPlayerCoverStatusChangedEvent(evt: ref<PlayerCoverStatusChangedEvent>) -> Bool {
    if NotEquals(this.m_behindCover, evt.fullyBehindCover) {
      this.m_behindCover = evt.fullyBehindCover;
      this.UpdateVisibility();
    };
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let actionRestrictionRecord: ref<ActionRestrictionGroup_Record>;
    let bioMonitorBB: ref<IBlackboard>;
    let cooldowns: array<SPlayerCooldown>;
    let gameplayTags: array<CName>;
    let newCooldown: SPlayerCooldown;
    let psmEvent: ref<PSMPostponedParameterScriptable>;
    let restrictionRecord: ref<GameplayRestrictionStatusEffect_Record>;
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.Defeated) {
      StatusEffectHelper.RemoveStatusEffect(this, evt.staticData.GetID());
      return true;
    };
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.UncontrolledMovement) {
      StatusEffectHelper.RemoveStatusEffect(this, evt.staticData.GetID());
      return true;
    };
    gameplayTags = evt.staticData.GameplayTags();
    if ArrayContains(gameplayTags, n"DoNotApplyOnPlayer") {
      StatusEffectHelper.RemoveStatusEffect(this, evt.staticData.GetID());
      return true;
    };
    psmEvent = new PSMPostponedParameterScriptable();
    psmEvent.id = n"StatusEffect";
    psmEvent.value = evt.staticData;
    this.QueueEvent(psmEvent);
    super.OnStatusEffectApplied(evt);
    if evt.staticData.GetID() == PlayerCoverHelper.GetBlockCoverStatusEffectID() {
      this.m_coverVisibilityPerkBlocked = true;
      this.UpdateVisibility();
    };
    if ArrayContains(gameplayTags, n"NoScanning") {
      this.m_visionModeController.UpdateNoScanningRestriction();
    };
    if ArrayContains(gameplayTags, n"GameplayRestriction") {
      PlayerGameplayRestrictions.OnGameplayRestrictionAdded(this, evt.staticData, gameplayTags);
      restrictionRecord = evt.staticData as GameplayRestrictionStatusEffect_Record;
      if IsDefined(restrictionRecord) && evt.isNewApplication {
        actionRestrictionRecord = restrictionRecord.ActionRestriction();
        if IsDefined(actionRestrictionRecord) {
          this.AddGameplayRestriction(this.GetPlayerStateMachineBlackboard(), actionRestrictionRecord.GetID());
        };
      };
    };
    if ArrayContains(gameplayTags, n"CameraAnimation") {
      if GameplaySettingsSystem.GetAdditiveCameraMovementsSetting(this) <= 0.00 {
        StatusEffectHelper.RemoveStatusEffectsWithTag(this, n"CameraAnimation");
      } else {
        if ArrayContains(gameplayTags, n"Breathing") || ArrayContains(gameplayTags, n"JohnnySickness") {
          this.ProcessBreathingEffectApplication(evt);
        } else {
          StatusEffectHelper.RemoveAllStatusEffectsWithTagBeside(this, n"CameraAnimation", evt.staticData.GetID());
        };
      };
    };
    if ArrayContains(gameplayTags, n"CyberspacePresence") {
      this.DisableFootstepAudio(true);
      this.DisableCameraBobbing(true);
    };
    if ArrayContains(gameplayTags, n"PerfectCloak") {
      this.SetInvisible(true);
    };
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.PlayerCooldown) {
      bioMonitorBB = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
      cooldowns = FromVariant(bioMonitorBB.GetVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.Cooldowns));
      newCooldown.effectID = evt.staticData.GetID();
      newCooldown.instigatorID = StatusEffectHelper.GetStatusEffectByID(this, evt.staticData.GetID()).GetInstigatorStaticDataID();
      ArrayPush(cooldowns, newCooldown);
      bioMonitorBB.SetVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.Cooldowns, ToVariant(cooldowns));
    };
    this.ProcessTieredDrunkEffect(evt);
    this.ProcessTieredDruggedEffect(evt);
    this.m_combatController.OnStatusEffectApplied(evt, gameplayTags);
  }

  private final func DisableFootstepAudio(b: Bool) -> Void {
    let audioEventName: CName = b ? n"disableFootsteps" : n"enableFootsteps";
    GameObject.PlaySoundEvent(this, audioEventName);
  }

  private final func DisableCameraBobbing(b: Bool) -> Void {
    AnimationControllerComponent.SetInputBool(this, n"disable_camera_bobbing", b);
  }

  public final func OnAdditiveCameraMovementsSettingChanged() -> Void {
    if GameplaySettingsSystem.GetAdditiveCameraMovementsSetting(this) <= 0.00 {
      StatusEffectHelper.RemoveStatusEffectsWithTag(this, n"CameraAnimation");
    } else {
      PlayerPuppet.ReevaluateAllBreathingEffects(this);
    };
  }

  public final static func ReevaluateAllBreathingEffects(player: wref<PlayerPuppet>) -> Void {
    if !PlayerPuppet.CanApplyBreathingEffect(player) {
      StatusEffectHelper.RemoveStatusEffectsWithTag(player, n"Breathing");
    } else {
      if StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.BreathingMedium") || StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.BreathingHeavy") || StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.BreathingSick") || PlayerPuppet.IsJohnnySicknessBreathingEffectActive(player) {
        return;
      };
      if GameplaySettingsSystem.GetAdditiveCameraMovementsSetting(player) <= 0.50 {
        StatusEffectHelper.RemoveStatusEffect(player, t"BaseStatusEffect.BreathingLow");
      } else {
        StatusEffectHelper.ApplyStatusEffect(player, t"BaseStatusEffect.BreathingLow");
      };
    };
  }

  public final static func CanApplyBreathingEffect(player: wref<PlayerPuppet>) -> Bool {
    let blackboard: ref<IBlackboard>;
    if !IsDefined(player) {
      return false;
    };
    if GameplaySettingsSystem.GetAdditiveCameraMovementsSetting(player) <= 0.00 {
      return false;
    };
    if !ScriptedPuppet.IsActive(player) {
      return false;
    };
    blackboard = player.GetPlayerStateMachineBlackboard();
    if !IsDefined(blackboard) {
      return false;
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) && !PlayerPuppet.IsJohnnySicknessBreathingEffectActive(player) {
      return false;
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming) != EnumInt(gamePSMSwimming.Default) && !PlayerPuppet.IsJohnnySicknessBreathingEffectActive(player) {
      return false;
    };
    if VehicleComponent.IsMountedToVehicle(player.GetGame(), player) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(player, n"CameraShake") {
      return false;
    };
    return true;
  }

  public final static func IsSwimming(player: wref<PlayerPuppet>) -> Bool {
    let blackboard: ref<IBlackboard>;
    if !IsDefined(player) {
      return false;
    };
    blackboard = player.GetPlayerStateMachineBlackboard();
    return blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming) != EnumInt(gamePSMSwimming.Default);
  }

  public final static func GetSceneTier(player: wref<PlayerPuppet>) -> Int32 {
    let psmBlackboard: ref<IBlackboard>;
    if !IsDefined(player) {
      return 0;
    };
    psmBlackboard = player.GetPlayerStateMachineBlackboard();
    if IsDefined(psmBlackboard) {
      return psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    };
    return 0;
  }

  public final static func IsJohnnySicknessBreathingEffectActive(player: wref<PlayerPuppet>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.JohnnySicknessLow") || StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.JohnnySicknessMedium") || StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.JohnnySicknessHeavy") || StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.JohnnySicknessMediumQuest") {
      return true;
    };
    return false;
  }

  private final func ProcessBreathingEffectApplication(evt: ref<StatusEffectEvent>) -> Void {
    let gameplayTags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(gameplayTags, n"Breathing") {
      if PlayerPuppet.CanApplyBreathingEffect(this) {
        switch evt.staticData.GetID() {
          case t"BaseStatusEffect.BreathingLow":
            if GameplaySettingsSystem.GetAdditiveCameraMovementsSetting(this) <= 0.50 {
              StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.BreathingLow");
            };
            StatusEffectHelper.RemoveAllStatusEffectsWithTagBeside(this, n"Breathing", t"BaseStatusEffect.BreathingLow");
            break;
          default:
            StatusEffectHelper.RemoveAllStatusEffectsWithTagBeside(this, n"Breathing", evt.staticData.GetID());
        };
      } else {
        StatusEffectHelper.RemoveStatusEffectsWithTag(this, n"Breathing");
      };
    } else {
      if PlayerPuppet.CanApplyBreathingEffect(this) {
        StatusEffectHelper.RemoveStatusEffectsWithTag(this, n"Breathing");
        StatusEffectHelper.RemoveAllStatusEffectsWithTagBeside(this, n"JohnnySickness", evt.staticData.GetID());
      };
    };
  }

  private final func ProcessTieredDrunkEffect(evt: ref<StatusEffectEvent>) -> Void {
    let stackCount: Int32;
    let drunkID: TweakDBID = t"BaseStatusEffect.Drunk";
    if evt.staticData.GetID() == drunkID {
      stackCount = Cast(StatusEffectHelper.GetStatusEffectByID(this, drunkID).GetStackCount());
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drunk_level_1");
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drunk_level_2");
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drunk_level_3");
      GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 0.00);
      switch stackCount {
        case 1:
          GameObjectEffectHelper.StartEffectEvent(this, n"status_drunk_level_1");
          GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 1.00);
          break;
        case 2:
          GameObjectEffectHelper.StartEffectEvent(this, n"status_drunk_level_2");
          GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 2.00);
          break;
        case 4:
        case 3:
          GameObjectEffectHelper.StartEffectEvent(this, n"status_drunk_level_3");
          GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 3.00);
      };
    };
  }

  private final func ProcessTieredDruggedEffect(evt: ref<StatusEffectEvent>) -> Void {
    let stackCount: Int32;
    let druggedID: TweakDBID = t"BaseStatusEffect.Drugged";
    if evt.staticData.GetID() == druggedID {
      stackCount = Cast(StatusEffectHelper.GetStatusEffectByID(this, druggedID).GetStackCount());
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drugged_low");
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drugged_medium");
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drugged_heavy");
      GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 0.00);
      switch stackCount {
        case 1:
          GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_low");
          GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 1.00);
          break;
        case 2:
          GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_medium");
          GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 2.00);
          break;
        case 3:
          GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_heavy");
          GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 3.00);
      };
    };
  }

  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let actionRestrictionRecord: ref<ActionRestrictionGroup_Record>;
    let bioMonitorBB: ref<IBlackboard>;
    let cooldowns: array<SPlayerCooldown>;
    let emptyID: EntityID;
    let gameplayTags: array<CName>;
    let i: Int32;
    let removeLinkedQuickhacks: ref<RemoveLinkedStatusEffectsEvent>;
    let restrictionRecord: ref<GameplayRestrictionStatusEffect_Record>;
    let psmEvent: ref<PSMPostponedParameterScriptable> = new PSMPostponedParameterScriptable();
    psmEvent.id = n"StatusEffectRemoved";
    psmEvent.value = evt.staticData;
    this.QueueEvent(psmEvent);
    super.OnStatusEffectRemoved(evt);
    if evt.staticData.GetID() == PlayerCoverHelper.GetBlockCoverStatusEffectID() {
      this.m_coverVisibilityPerkBlocked = false;
      this.UpdateVisibility();
    };
    gameplayTags = evt.staticData.GameplayTags();
    if ArrayContains(gameplayTags, n"NPCQuickhack") && EntityID.IsDefined(this.m_attackingNetrunnerID) {
      removeLinkedQuickhacks = new RemoveLinkedStatusEffectsEvent();
      GameInstance.FindEntityByID(this.GetGame(), this.m_attackingNetrunnerID).QueueEvent(removeLinkedQuickhacks);
      this.m_attackingNetrunnerID = emptyID;
    };
    if ArrayContains(gameplayTags, n"NoScanning") {
      this.m_visionModeController.UpdateNoScanningRestriction();
    };
    if ArrayContains(gameplayTags, n"GameplayRestriction") {
      PlayerGameplayRestrictions.OnGameplayRestrictionRemoved(this, evt, gameplayTags);
      restrictionRecord = evt.staticData as GameplayRestrictionStatusEffect_Record;
      if IsDefined(restrictionRecord) {
        actionRestrictionRecord = restrictionRecord.ActionRestriction();
        if IsDefined(actionRestrictionRecord) {
          this.RemoveGameplayRestriction(this.GetPlayerStateMachineBlackboard(), actionRestrictionRecord.GetID());
        };
      };
    };
    if ArrayContains(gameplayTags, n"CameraAnimation") && evt.staticData.GetID() != t"BaseStatusEffect.BreathingLow" && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"CameraShake") {
      PlayerPuppet.ReevaluateAllBreathingEffects(this);
    };
    if ArrayContains(gameplayTags, n"CyberspacePresence") {
      this.DisableFootstepAudio(false);
      this.DisableCameraBobbing(false);
    };
    if ArrayContains(gameplayTags, n"PerfectCloak") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"PerfectCloak") {
      this.SetInvisible(false);
    };
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.PlayerCooldown) {
      bioMonitorBB = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
      cooldowns = FromVariant(bioMonitorBB.GetVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.Cooldowns));
      i = 0;
      while i < ArraySize(cooldowns) {
        if cooldowns[i].effectID == evt.staticData.GetID() {
          ArrayErase(cooldowns, i);
        } else {
          i += 1;
        };
      };
      bioMonitorBB.SetVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.Cooldowns, ToVariant(cooldowns));
    };
    this.ProcessTieredDrunkEffect(evt);
    this.ProcessTieredDruggedEffect(evt);
    this.m_combatController.OnStatusEffectRemoved(evt, gameplayTags);
  }

  protected cb func OnAttitudeChanged(evt: ref<AttitudeChangedEvent>) -> Bool;

  protected cb func OnAdHocAnimationRequest(evt: ref<AdHocAnimationEvent>) -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().AdHocAnimation);
    blackboard.SetBool(GetAllBlackboardDefs().AdHocAnimation.IsActive, true);
    blackboard.SetBool(GetAllBlackboardDefs().AdHocAnimation.UseBothHands, evt.useBothHands);
    blackboard.SetBool(GetAllBlackboardDefs().AdHocAnimation.UnequipWeapon, evt.unequipWeapon);
    blackboard.SetInt(GetAllBlackboardDefs().AdHocAnimation.AnimationIndex, evt.animationIndex);
  }

  protected cb func OnSceneForceWeaponAimEvent(evt: ref<SceneForceWeaponAim>) -> Bool {
    let eqManipulationRequest: ref<EquipmentSystemWeaponManipulationRequest>;
    let blackboard: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    let tier: Int32 = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    if tier > EnumInt(gamePSMHighLevel.SceneTier1) && tier <= EnumInt(gamePSMHighLevel.SceneTier5) {
      blackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced, true);
      blackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced, false);
      blackboard.SetFloat(GetAllBlackboardDefs().PlayerStateMachine.SceneWeaponLoweringSpeedOverride, 0.00);
      this.SendSceneOverridesAnimFeature(blackboard);
      eqManipulationRequest = new EquipmentSystemWeaponManipulationRequest();
      eqManipulationRequest.requestType = EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon;
      eqManipulationRequest.owner = this;
      GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem").QueueRequest(eqManipulationRequest);
    };
  }

  protected cb func OnSceneForceWeaponSafeEvent(evt: ref<SceneForceWeaponSafe>) -> Bool {
    let eqManipulationRequest: ref<EquipmentSystemWeaponManipulationRequest>;
    let blackboard: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    let tier: Int32 = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    if tier > EnumInt(gamePSMHighLevel.SceneTier1) && tier <= EnumInt(gamePSMHighLevel.SceneTier5) {
      blackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced, false);
      blackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced, true);
      blackboard.SetFloat(GetAllBlackboardDefs().PlayerStateMachine.SceneWeaponLoweringSpeedOverride, evt.weaponLoweringSpeedOverride);
      this.SendSceneOverridesAnimFeature(blackboard);
      eqManipulationRequest = new EquipmentSystemWeaponManipulationRequest();
      eqManipulationRequest.requestType = EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon;
      eqManipulationRequest.owner = this;
      GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem").QueueRequest(eqManipulationRequest);
    };
  }

  protected cb func OnEnableBraindanceActions(evt: ref<EnableBraindanceActions>) -> Bool {
    let bdEvent: ref<BraindanceInputChangeEvent>;
    let maskEvent: ref<EnableFields> = new EnableFields();
    maskEvent.actionMask = evt.actionMask;
    let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"BraindanceSystem") as BraindanceSystem;
    bdSystem.QueueRequest(maskEvent);
    bdEvent = new BraindanceInputChangeEvent();
    bdEvent.bdSystem = bdSystem;
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(bdEvent);
  }

  protected cb func OnDisableBraindanceActions(evt: ref<DisableBraindanceActions>) -> Bool {
    let bdEvent: ref<BraindanceInputChangeEvent>;
    let maskEvent: ref<DisableFields> = new DisableFields();
    maskEvent.actionMask = evt.actionMask;
    let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"BraindanceSystem") as BraindanceSystem;
    bdSystem.QueueRequest(maskEvent);
    bdEvent = new BraindanceInputChangeEvent();
    bdEvent.bdSystem = bdSystem;
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(bdEvent);
  }

  protected cb func OnForceBraindanceCameraToggle(evt: ref<ForceBraindanceCameraToggle>) -> Bool {
    let request: ref<SetBraindanceState> = new SetBraindanceState();
    request.newState = evt.editorState;
    let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"BraindanceSystem") as BraindanceSystem;
    bdSystem.QueueRequest(request);
  }

  protected cb func OnPauseBraindance(evt: ref<PauseBraindance>) -> Bool {
    let request: ref<SendPauseBraindanceRequest> = new SendPauseBraindanceRequest();
    let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"BraindanceSystem") as BraindanceSystem;
    bdSystem.QueueRequest(request);
  }

  protected cb func OnModifyOverlappedSecurityArease(evt: ref<ModifyOverlappedSecurityAreas>) -> Bool {
    if evt.isEntering {
      this.AddOverrlappedSecurityZone(evt.zoneID);
    } else {
      this.RemoveOverrlappedSecurityZone(evt.zoneID);
    };
  }

  public final func AddOverrlappedSecurityZone(zone: PersistentID) -> Void {
    if !ArrayContains(this.m_overlappedSecurityZones, zone) {
      ArrayPush(this.m_overlappedSecurityZones, zone);
    };
  }

  public final func RemoveOverrlappedSecurityZone(zone: PersistentID) -> Void {
    ArrayRemove(this.m_overlappedSecurityZones, zone);
  }

  protected final func SendSceneOverridesAnimFeature(sceneOverridesBlackboard: ref<IBlackboard>) -> Void {
    let animFeature: ref<AnimFeature_SceneGameplayOverrides> = new AnimFeature_SceneGameplayOverrides();
    animFeature.aimForced = sceneOverridesBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced);
    animFeature.safeForced = sceneOverridesBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced);
    if sceneOverridesBlackboard.GetFloat(GetAllBlackboardDefs().PlayerStateMachine.SceneWeaponLoweringSpeedOverride) > 0.00 {
      animFeature.isAimOutTimeOverridden = true;
      animFeature.aimOutTimeOverride = sceneOverridesBlackboard.GetFloat(GetAllBlackboardDefs().PlayerStateMachine.SceneWeaponLoweringSpeedOverride);
    } else {
      animFeature.isAimOutTimeOverridden = false;
      animFeature.aimOutTimeOverride = 0.00;
    };
    AnimationControllerComponent.ApplyFeature(this, n"SceneGameplayOverrides", animFeature);
  }

  protected cb func OnWorkspotStartedEvent(evt: ref<WorkspotStartedEvent>) -> Bool {
    this.m_currentPlayerWorkspotTags = evt.tags;
    if ArrayContains(evt.tags, n"wsPlayerDamageReduction") {
      if !this.IsWorkspotDamageReductionAdded() {
        this.m_workspotDamageReductionActive = GameInstance.GetStatsSystem(this.GetGame()).ApplyModifierGroup(Cast(this.GetEntityID()), TDBID.ToNumber(this.m_damageReductionRecordID));
      };
    };
    if ArrayContains(evt.tags, n"wsPlayerVisibilityReduction") {
      if !this.IsWorkspotVisibilityReductionActive() {
        this.m_workspotVisibilityReductionActive = GameInstance.GetStatsSystem(this.GetGame()).ApplyModifierGroup(Cast(this.GetEntityID()), TDBID.ToNumber(this.m_visReductionRecordID));
      };
    };
  }

  protected cb func OnWorkspotFinishedEvent(evt: ref<WorkspotFinishedEvent>) -> Bool {
    ArrayClear(this.m_currentPlayerWorkspotTags);
    if ArrayContains(evt.tags, n"wsPlayerDamageReduction") {
      if this.IsWorkspotDamageReductionAdded() {
        if GameInstance.GetStatsSystem(this.GetGame()).RemoveModifierGroup(Cast(this.GetEntityID()), TDBID.ToNumber(this.m_damageReductionRecordID)) {
          this.m_workspotDamageReductionActive = false;
        };
      };
    };
    if ArrayContains(evt.tags, n"wsPlayerVisibilityReduction") {
      if this.IsWorkspotVisibilityReductionActive() {
        if GameInstance.GetStatsSystem(this.GetGame()).RemoveModifierGroup(Cast(this.GetEntityID()), TDBID.ToNumber(this.m_visReductionRecordID)) {
          this.m_workspotVisibilityReductionActive = false;
        };
      };
    };
  }

  public final const func GetPlayerCurrentWorkspotTags() -> array<CName> {
    return this.m_currentPlayerWorkspotTags;
  }

  public final const func PlayerContainsWorkspotTag(tag: CName) -> Bool {
    return ArrayContains(this.m_currentPlayerWorkspotTags, tag);
  }

  public final const func IsCooldownForActionActive(actionID: TweakDBID) -> Bool {
    return (this.GetPS() as PlayerPuppetPS).IsActionReady(actionID);
  }

  private final func RegisterToFacts() -> Void {
    GameInstance.GetQuestsSystem(this.GetGame()).RegisterEntity(n"q001_took_vroom_jacket", this.GetEntityID());
    GameInstance.GetQuestsSystem(this.GetGame()).RegisterEntity(n"player_allow_outerwear_clothing", this.GetEntityID());
  }

  protected cb func OnFactChangedEvent(evt: ref<FactChangedEvent>) -> Bool {
    switch evt.GetFactName() {
      case n"player_allow_outerwear_clothing":
      case n"q001_took_vroom_jacket":
        if GameInstance.GetQuestsSystem(this.GetGame()).GetFact(evt.GetFactName()) > 0 {
          this.AllowOuterwearClothing();
        } else {
          this.DisallowOuterwearClothing();
        };
        break;
      default:
    };
  }

  protected cb func OnSysDebuggerEvent(evt: ref<SysDebuggerEvent>) -> Bool {
    let req: ref<RealTimeUpdateRequest> = new RealTimeUpdateRequest();
    req.m_evt = evt;
    req.m_time = EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGame()).GetSimTime());
    let debugger: ref<SecSystemDebugger> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"SecSystemDebugger") as SecSystemDebugger;
    debugger.QueueRequest(req);
  }

  private final func AllowOuterwearClothing() -> Void {
    AnimationControllerComponent.SetInputBool(this, n"allow_outerwear_clothing", true);
  }

  private final func DisallowOuterwearClothing() -> Void {
    AnimationControllerComponent.SetInputBool(this, n"allow_outerwear_clothing", false);
  }

  private final func InitializeFocusModeTagging() -> Void {
    let request: ref<RegisterInputListenerRequest> = new RegisterInputListenerRequest();
    request.object = this;
    this.GetTaggingSystem().QueueRequest(request);
  }

  private final func UnInitializeFocusModeTagging() -> Void {
    let request: ref<UnRegisterInputListenerRequest> = new UnRegisterInputListenerRequest();
    request.object = this;
    this.GetTaggingSystem().QueueRequest(request);
  }

  protected cb func OnRequestEquipHeavyWeapon(evt: ref<RequestEquipHeavyWeapon>) -> Bool {
    let drawItem: ref<DrawItemRequest> = new DrawItemRequest();
    let equipmentSystem: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    drawItem.itemID = evt.itemID;
    drawItem.owner = this;
    equipmentSystem.QueueRequest(drawItem);
  }

  protected cb func OnFillAnimWrapperInfoBasedOnEquippedItem(evt: ref<FillAnimWrapperInfoBasedOnEquippedItem>) -> Bool {
    if ItemID.IsValid(evt.itemID) {
      if evt.clearWrapperInfo {
        AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(this, evt.itemName, 0.00);
      } else {
        AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(this, evt.itemName, 1.00);
      };
    };
  }

  protected func OnIncapacitated() -> Void {
    this.OnIncapacitated();
    if this.IsDead() {
      this.EnableInteraction(n"Revive", true);
    };
    this.m_incapacitated = true;
    this.RefreshCPOVisionAppearance();
    this.SetSenseObjectType(gamedataSenseObjectType.Deadbody);
  }

  private final func RefreshCPOVisionAppearance() -> Void {
    let visionAppearance: VisionAppearance;
    if this.IsControlledByAnotherClient() {
      visionAppearance.showThroughWalls = true;
      if this.IsIncapacitated() {
        visionAppearance.fill = 1;
        if this.HasCPOMissionData() {
          visionAppearance.outline = 2;
        } else {
          visionAppearance.outline = 4;
        };
      } else {
        if this.HasCPOMissionData() {
          visionAppearance.outline = 2;
        } else {
          visionAppearance.outline = 1;
        };
      };
      GameInstance.GetVisionModeSystem(this.GetGame()).ForceVisionAppearance(this, visionAppearance);
    };
  }

  protected func OnResurrected() -> Void {
    if IsMultiplayer() {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestResetingModifier(Cast(this.GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration);
      this.Revive(20.00);
    } else {
      this.Revive(100.00);
    };
    this.OnResurrected();
    this.EnableInteraction(n"Revive", false);
    this.m_incapacitated = false;
    this.RefreshCPOVisionAppearance();
    this.CreateVendettaTimeDelayEvent();
    this.SetSenseObjectType(gamedataSenseObjectType.Player);
  }

  public const func IsIncapacitated() -> Bool {
    return this.m_incapacitated;
  }

  private final func RegisterCPOMissionDataCallback() -> Void {
    this.m_CPOMissionDataBbId = this.GetBlackboard().RegisterListenerBool(GetAllBlackboardDefs().Puppet.HasCPOMissionData, this, n"OnCPOMissionDataChanged");
  }

  private final func UnregisterCPOMissionDataCallback() -> Void {
    if IsDefined(this.m_CPOMissionDataBbId) {
      this.GetBlackboard().UnregisterListenerBool(GetAllBlackboardDefs().Puppet.HasCPOMissionData, this.m_CPOMissionDataBbId);
    };
  }

  protected cb func OnCPOMissionDataTransferred(evt: ref<CPOMissionDataTransferred>) -> Bool {
    if IsServer() {
      this.OnCPOMissionDataTransferredServer(evt);
    } else {
      this.OnCPOMissionDataTransferredClient(evt);
    };
  }

  private final func OnCPOMissionDataTransferredServer(evt: ref<CPOMissionDataTransferred>) -> Void {
    this.SetHasCPOMissionData(evt.dataDownloaded, evt.dataDamagesPresetName, evt.compatibleDeviceName, evt.ownerDecidesOnTransfer);
    if evt.dataDownloaded {
      this.m_CPOMissionDataState.m_choiceTokenTimeout = evt.choiceTokenTimeout;
      if evt.isChoiceToken {
        this.m_CPOMissionDataState.m_delayedGiveChoiceTokenEventId = MultiplayerGiveChoiceTokenEvent.CreateDelayedEvent(this, evt.compatibleDeviceName, evt.choiceTokenTimeout);
      };
    } else {
      if this.m_CPOMissionDataState.m_isChoiceToken && this.m_CPOMissionDataState.m_delayedGiveChoiceTokenEventId != new DelayID() {
        GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_CPOMissionDataState.m_delayedGiveChoiceTokenEventId);
      };
    };
    this.m_CPOMissionDataState.m_isChoiceToken = evt.isChoiceToken;
    this.QueueReplicatedEvent(evt);
  }

  private final func OnCPOMissionDataTransferredClient(evt: ref<CPOMissionDataTransferred>) -> Void {
    this.m_CPOMissionDataState.m_isChoiceToken = evt.isChoiceToken;
    if evt.isChoiceToken {
      this.OnCPOMissionDataTransferredChoiceTokenClient(evt);
    };
  }

  private final func OnCPOMissionDataTransferredChoiceTokenClient(evt: ref<CPOMissionDataTransferred>) -> Void {
    this.SetCPOMissionData(evt.dataDownloaded);
    if this.m_choiceTokenTextDrawn {
      GameInstance.GetDebugVisualizerSystem(this.GetGame()).ClearLayer(this.m_choiceTokenTextLayerId);
      this.m_choiceTokenTextDrawn = false;
    };
    if evt.dataDownloaded {
      this.QueueEvent(new CPOChoiceTokenDrawTextEvent());
    };
  }

  protected cb func OnCPOChoiceTokenDrawTextEvent(evt: ref<CPOChoiceTokenDrawTextEvent>) -> Bool {
    let choiceText: String;
    if this.m_choiceTokenTextDrawn {
      GameInstance.GetDebugVisualizerSystem(this.GetGame()).ClearLayer(this.m_choiceTokenTextLayerId);
    };
    if this.HasCPOMissionData() && this.m_CPOMissionDataState.m_isChoiceToken {
      if this.IsControlledByLocalPeer() {
        choiceText = "Make a choice";
      } else {
        choiceText = "Other player is making choice";
      };
      this.m_choiceTokenTextLayerId = GameInstance.GetDebugVisualizerSystem(this.GetGame()).DrawText(new Vector4(500.00, 300.00, 0.00, 1.50), choiceText, gameDebugViewETextAlignment.Center, new Color(245u, 35u, 32u, 255u), 2.00);
      GameInstance.GetDebugVisualizerSystem(this.GetGame()).SetScale(this.m_choiceTokenTextLayerId, new Vector4(3.00, 3.00, 0.00, 0.00));
      this.m_choiceTokenTextDrawn = true;
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 3.00);
    };
  }

  private final func CPOMissionDataOnPlayerDetach() -> Void {
    let evt: ref<MultiplayerGiveChoiceTokenEvent>;
    if IsServer() && this.HasCPOMissionData() && this.m_CPOMissionDataState.m_isChoiceToken {
      if this.m_CPOMissionDataState.m_delayedGiveChoiceTokenEventId != new DelayID() {
        GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_CPOMissionDataState.m_delayedGiveChoiceTokenEventId);
      };
      evt = MultiplayerGiveChoiceTokenEvent.CreateEvent(this.m_CPOMissionDataState.m_compatibleDeviceName, this.m_CPOMissionDataState.m_choiceTokenTimeout);
      evt.GiveChoiceToken(this);
    };
    if this.m_choiceTokenTextDrawn {
      GameInstance.GetDebugVisualizerSystem(this.GetGame()).ClearLayer(this.m_choiceTokenTextLayerId);
      this.m_choiceTokenTextDrawn = false;
    };
  }

  protected cb func OnCPOMissionPlayerVotedEvent(evt: ref<CPOMissionPlayerVotedEvent>) -> Bool {
    this.SetCPOMissionVoted(evt.compatibleDeviceName, true);
  }

  protected cb func OnPlayerDamageFromDataEvent(e: ref<PlayerDamageFromDataEvent>) -> Bool {
    this.ProcessDamageEvents(true, this.m_CPOMissionDataState.m_CPOMissionDataDamagesPreset);
  }

  protected cb func OnCPOMissionDataUpdateEvent(e: ref<CPOMissionDataUpdateEvent>) -> Bool {
    this.m_CPOMissionDataState.UpdateSounds(this);
  }

  public final const func GetCompatibleCPOMissionDeviceName() -> CName {
    return this.m_CPOMissionDataState.m_compatibleDeviceName;
  }

  protected cb func OnCPOMissionDataChanged(hasData: Bool) -> Bool {
    this.RefreshCPOVisionAppearance();
  }

  public final func SetHasCPOMissionData(setHasData: Bool, damagesPreset: CName, compatibleDeviceName: CName, ownerDecidesOnTransfer: Bool) -> Void {
    this.SetCPOMissionData(setHasData);
    this.m_CPOMissionDataState.m_CPOMissionDataDamagesPreset = damagesPreset;
    this.m_CPOMissionDataState.m_compatibleDeviceName = compatibleDeviceName;
    this.m_CPOMissionDataState.m_ownerDecidesOnTransfer = ownerDecidesOnTransfer;
    this.ProcessDamageEvents(setHasData, damagesPreset);
  }

  protected cb func OnCPOGiveChoiceTokenEvent(e: ref<MultiplayerGiveChoiceTokenEvent>) -> Bool {
    e.GiveChoiceToken(this);
  }

  private final func ProcessDamageEvents(addDamage: Bool, damagesPreset: CName) -> Void {
    let armorDPS: Float;
    let currArmor: Float;
    let currHealth: Float;
    let healthDPS: Float;
    let tickableEvent: ref<PlayerDamageFromDataEvent>;
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
    delaySystem.CancelDelay(this.m_DataDamageUpdateID);
    if addDamage {
      armorDPS = TweakDBInterface.GetFloat(TDBID.Create("player." + NameToString(damagesPreset) + ".armorDPS"), 0.00);
      healthDPS = TweakDBInterface.GetFloat(TDBID.Create("player." + NameToString(damagesPreset) + ".healthDPS"), 0.00);
      currArmor = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.CPO_Armor);
      currHealth = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health);
      if armorDPS > 0.00 && currArmor > 0.00 {
        GameInstance.GetStatPoolsSystem(this.GetGame()).RequestChangingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.CPO_Armor, -armorDPS, null, false);
      } else {
        if healthDPS > 0.00 && currHealth > 0.00 {
          if armorDPS > 0.00 {
            GameInstance.GetStatPoolsSystem(this.GetGame()).RequestChangingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.CPO_Armor, -armorDPS, null, false);
          };
          GameInstance.GetStatPoolsSystem(this.GetGame()).RequestChangingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, -healthDPS, null, false);
        };
      };
      tickableEvent = new PlayerDamageFromDataEvent();
      this.m_DataDamageUpdateID = delaySystem.DelayEvent(this, tickableEvent, 1.00);
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    this.ForceCloseRadialWheel();
    super.OnDeath(evt);
    GameInstance.GetTelemetrySystem(this.GetGame()).LogPlayerDeathEvent(evt);
  }

  private final func ForceCloseRadialWheel() -> Void {
    let closeEvt: ref<ForceRadialWheelShutdown> = new ForceRadialWheelShutdown();
    this.QueueEvent(closeEvt);
  }

  private final func Revive(percAmount: Float) -> Void {
    let playerID: StatsObjectID = Cast(this.GetEntityID());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    if percAmount >= 0.00 && percAmount <= 100.00 {
      statPoolsSystem.RequestSettingStatPoolValue(playerID, gamedataStatPoolType.Health, percAmount, null, true);
    };
  }

  protected cb func OnTargetNeutraliziedEvent(evt: ref<TargetNeutraliziedEvent>) -> Bool {
    let processExpReq: ref<ProcessQueuedCombatExperience>;
    let puppetTarget: wref<NPCPuppet>;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Crosshair);
    bb.SetVariant(GetAllBlackboardDefs().UI_Crosshair.EnemyNeutralized, ToVariant(evt.type));
    processExpReq = new ProcessQueuedCombatExperience();
    processExpReq.owner = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
    processExpReq.m_entity = evt.targetID;
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PlayerDevelopmentSystem").QueueRequest(processExpReq);
    puppetTarget = GameInstance.FindEntityByID(this.GetGame(), evt.targetID) as NPCPuppet;
    if IsDefined(puppetTarget) {
      BountyManager.CompleteBounty(puppetTarget);
    };
    this.CheckVForVendettaAchievement(evt);
  }

  protected cb func OnRewindableSectionEvent(evt: ref<scnRewindableSectionEvent>) -> Bool {
    let psmAdd: ref<PSMAddOnDemandStateMachine>;
    let psmRem: ref<PSMRemoveOnDemandStateMachine>;
    let stateMachineIdentifierRem: StateMachineIdentifier;
    let inBD: ref<SetIsInBraindance> = new SetIsInBraindance();
    let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"BraindanceSystem") as BraindanceSystem;
    if evt.active {
      psmAdd = new PSMAddOnDemandStateMachine();
      psmAdd.stateMachineName = n"BraindanceControls";
      this.QueueEvent(psmAdd);
      this.DisableCameraBobbing(true);
      inBD.newState = true;
      bdSystem.QueueRequest(inBD);
      GameInstance.GetAudioSystem(this.GetGame()).SetBDCameraListenerOverride(true);
    } else {
      psmRem = new PSMRemoveOnDemandStateMachine();
      stateMachineIdentifierRem.definitionName = n"BraindanceControls";
      psmRem.stateMachineIdentifier = stateMachineIdentifierRem;
      this.QueueEvent(psmRem);
      this.DisableCameraBobbing(false);
      inBD.newState = false;
      bdSystem.QueueRequest(inBD);
      GameInstance.GetAudioSystem(this.GetGame()).SetBDCameraListenerOverride(false);
    };
  }

  public final const func IsInCombat() -> Bool {
    return this.m_inCombat;
  }

  public final const func IsNaked() -> Bool {
    if ItemID.IsValid(EquipmentSystem.GetData(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject()).GetActiveItem(gamedataEquipmentArea.Legs)) || ItemID.IsValid(EquipmentSystem.GetData(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject()).GetActiveItem(gamedataEquipmentArea.OuterChest)) || ItemID.IsValid(EquipmentSystem.GetData(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject()).GetActiveItem(gamedataEquipmentArea.InnerChest)) {
      return false;
    };
    return true;
  }

  public final const func IsMoving() -> Bool {
    return this.IsMovingHorizontally() || this.IsMovingVertically();
  }

  public final const func IsMovingHorizontally() -> Bool {
    return this.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsMovingHorizontally);
  }

  public final const func IsMovingVertically() -> Bool {
    return this.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsMovingVertically);
  }

  protected cb func OnZoneChange(value: Variant) -> Bool {
    let securityZoneData: SecurityAreaData = FromVariant(value);
    GameInstance.GetTelemetrySystem(this.GetGame()).LogPlayerInDangerousArea(Equals(securityZoneData.securityAreaType, ESecurityAreaType.RESTRICTED) || Equals(securityZoneData.securityAreaType, ESecurityAreaType.DANGEROUS));
  }

  private final func SetWarningMessage(message: String) -> Void {
    let warningMsg: SimpleScreenMessage;
    warningMsg.isShown = true;
    warningMsg.duration = 5.00;
    warningMsg.message = message;
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
  }

  private final func StartProcessingVForVendettaAchievement(deathInstigator: ref<GameObject>) -> Void {
    let achievement: gamedataAchievement = gamedataAchievement.VForVendetta;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) {
      return;
    };
    if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.HasSecondHeart) > 0.00 && IsDefined(deathInstigator as NPCPuppet) && this.m_NPCDeathInstigator == null {
      this.m_NPCDeathInstigator = deathInstigator as NPCPuppet;
    };
  }

  private final func CreateVendettaTimeDelayEvent() -> Void {
    let vendettaTimeDelayEvent: ref<FinishedVendettaTimeEvent>;
    if IsDefined(this.m_NPCDeathInstigator) {
      vendettaTimeDelayEvent = new FinishedVendettaTimeEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, vendettaTimeDelayEvent, 5.00);
    };
  }

  protected cb func OnFinishedVendettaTimeEvent(evt: ref<FinishedVendettaTimeEvent>) -> Bool {
    this.m_NPCDeathInstigator = null;
  }

  private final const func CheckVForVendettaAchievement(evt: ref<TargetNeutraliziedEvent>) -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.VForVendetta;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) || !IsDefined(this.m_NPCDeathInstigator) {
      return;
    };
    if IsDefined(this.m_NPCDeathInstigator) && this.m_NPCDeathInstigator.GetEntityID() != evt.targetID {
      return;
    };
    achievementRequest = new AddAchievementRequest();
    achievementRequest.achievement = achievement;
    dataTrackingSystem.QueueRequest(achievementRequest);
  }

  protected cb func OnProcessVendettaAchievementEvent(evt: ref<ProcessVendettaAchievementEvent>) -> Bool {
    this.StartProcessingVForVendettaAchievement(evt.deathInstigator);
  }

  protected cb func OnRemoveConsumableDelayedEvent(evt: ref<RemoveConsumableDelayedEvent>) -> Bool {
    evt.consumeAction.RemoveConsumableItem(this.GetGame());
  }

  public const func GetNetworkLinkSlotName() -> CName {
    return n"Chest";
  }

  public const func IsNetworkLinkDynamic() -> Bool {
    return true;
  }

  private final func RegisterRemoteMappin() -> Void {
    let data: MappinData;
    data.mappinType = t"Mappins.CPO_RemotePlayerMappinDefinition";
    data.variant = gamedataMappinVariant.CPO_RemotePlayerVariant;
    data.active = true;
    this.m_remoteMappinId = GameInstance.GetMappinSystem(this.GetGame()).RegisterRemotePlayerMappin(data, this);
  }

  private final func UnregisterRemoteMappin() -> Void {
    if this.m_remoteMappinId.value != 0u {
      GameInstance.GetMappinSystem(this.GetGame()).UnregisterMappin(this.m_remoteMappinId);
      this.m_remoteMappinId.value = 0u;
    };
  }

  protected cb func OnRegisterFastTravelPoints(evt: ref<RegisterFastTravelPointsEvent>) -> Bool {
    let request: ref<RegisterFastTravelPointRequest>;
    let i: Int32 = 0;
    while i < ArraySize(evt.fastTravelNodes) {
      request = new RegisterFastTravelPointRequest();
      request.pointData = evt.fastTravelNodes[i];
      request.requesterID = this.GetEntityID();
      this.GetFastTravelSystem().QueueRequest(request);
      i += 1;
    };
  }

  public const func ShouldShowScanner() -> Bool {
    if IsMultiplayer() {
      return true;
    };
    return false;
  }

  protected cb func OnWoundedInstigated(evt: ref<WoundedInstigated>) -> Bool {
    let value: Uint32 = this.GetPlayerPerkDataBlackboard().GetUint(GetAllBlackboardDefs().PlayerPerkData.WoundedInstigated);
    this.GetPlayerPerkDataBlackboard().SetUint(GetAllBlackboardDefs().PlayerPerkData.WoundedInstigated, value + 1u);
  }

  protected cb func OnDismembermentInstigated(evt: ref<DismembermentInstigated>) -> Bool {
    let value: Uint32 = this.GetPlayerPerkDataBlackboard().GetUint(GetAllBlackboardDefs().PlayerPerkData.DismembermentInstigated);
    this.GetPlayerPerkDataBlackboard().SetUint(GetAllBlackboardDefs().PlayerPerkData.DismembermentInstigated, value + 1u);
  }

  public final func GetPrimaryTargetingComponent() -> ref<TargetingComponent> {
    return this.m_primaryTargetingComponent;
  }

  public final static func SetLevel(inst: GameInstance, stringType: String, stringVal: String, levelGainReason: telemetryLevelGainReason) -> Void {
    let i: Int32;
    let inventory: array<wref<gameItemData>>;
    let itemData: wref<gameItemData>;
    let statMod: ref<gameStatModifierData>;
    let profType: gamedataProficiencyType = IntEnum(Cast(EnumValueFromString("gamedataProficiencyType", stringType)));
    let newLevel: Int32 = StringToInt(stringVal);
    let request: ref<SetProficiencyLevel> = new SetProficiencyLevel();
    request.Set(GetPlayer(inst), newLevel, profType, levelGainReason);
    GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
    if Equals(profType, gamedataProficiencyType.Level) {
      GameInstance.GetTransactionSystem(inst).GetItemList(GetPlayer(inst), inventory);
      statMod = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gameStatModifierType.Additive, StringToFloat(stringVal));
      i = 0;
      while i < ArraySize(inventory) {
        itemData = inventory[i];
        if IsDefined(RPGManager.GetItemRecord(itemData.GetID())) {
          GameInstance.GetStatsSystem(inst).RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel, true);
          GameInstance.GetStatsSystem(inst).AddSavedModifier(itemData.GetStatsObjectID(), statMod);
        };
        i += 1;
      };
    };
  }

  public final static func SetBuild(inst: GameInstance, stringType: String) -> Void {
    let buildRequest: ref<questSetProgressionBuildRequest>;
    let buildType: gamedataBuildType;
    let buildTypeRequest: ref<SetProgressionBuild>;
    let buildInt: Int32 = Cast(EnumValueFromString("gamedataBuildType", stringType));
    let player: ref<PlayerPuppet> = GetPlayer(inst);
    if buildInt >= 0 {
      buildType = IntEnum(buildInt);
      buildTypeRequest = new SetProgressionBuild();
      buildTypeRequest.Set(player, buildType);
      GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(buildTypeRequest);
    } else {
      buildRequest = new questSetProgressionBuildRequest();
      buildRequest.buildID = TDBID.Create(stringType);
      buildRequest.owner = player;
      GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(buildRequest);
    };
  }

  private final func ApplyNPCLevelAndProgressionBuild(npc: wref<GameObject>, actionName: CName) -> Void {
    let NPCLevel: Int32;
    let buildName: String;
    let buildSpacing: Int32;
    let presetBuildLevel: Int32;
    let statsSystem: ref<StatsSystem>;
    let gameInstance: GameInstance = this.GetGame();
    if IsDefined(npc) {
      statsSystem = GameInstance.GetStatsSystem(gameInstance);
      NPCLevel = Cast(statsSystem.GetStatValue(Cast(npc.GetEntityID()), gamedataStatType.PowerLevel));
      buildSpacing = this.FindBuildSpacing("gamedataBuildType", "RangedCombat");
      if buildSpacing <= 0 {
        LogError("[Progression cheat] Can\'t find proper build to apply!!!");
        return;
      };
      presetBuildLevel = NPCLevel - NPCLevel % buildSpacing;
      switch actionName {
        case n"ApplyNPCLevelToPlayerRanged":
          buildName = "RangedCombat";
          break;
        case n"ApplyNPCLevelToPlayerMelee":
          buildName = "MeleeCombat";
          break;
        case n"ApplyNPCLevelToPlayerNetrunner":
          buildName = "CombatNetrunner";
          break;
        default:
      };
      if Equals(buildName, "") {
        LogError("[Progression] wrong build name!!!");
        return;
      };
      buildName = buildName + presetBuildLevel;
      AddFact(gameInstance, n"full_rpg_progression_on");
      PlayerPuppet.SetBuild(gameInstance, buildName);
      PlayerPuppet.SetLevel(gameInstance, "Level", IntToString(NPCLevel), telemetryLevelGainReason.Ignore);
    };
  }

  protected cb func OnMeleeHitEvent(evt: ref<MeleeHitEvent>) -> Bool {
    let isExhuasted: Bool;
    let slowMoDelay: Float;
    let slowMoEvent: ref<MeleeHitSlowMoEvent>;
    let targetAsPuppet: ref<ScriptedPuppet>;
    let validTarget: Bool;
    let slowMoEnabled: Bool = TweakDBInterface.GetBool(t"timeSystem.meleeHit.enabled", false);
    if evt.isStrongAttack {
      slowMoEnabled = TweakDBInterface.GetBool(t"timeSystem.meleeHitStrong.enabled", false);
      slowMoDelay = TweakDBInterface.GetFloat(t"timeSystem.meleeHitStrong.delay", 0.10);
    } else {
      slowMoEnabled = TweakDBInterface.GetBool(t"timeSystem.meleeHit.enabled", false);
      slowMoDelay = TweakDBInterface.GetFloat(t"timeSystem.meleeHit.delay", 0.10);
    };
    if slowMoEnabled {
      targetAsPuppet = evt.target as ScriptedPuppet;
      validTarget = IsDefined(targetAsPuppet) && ScriptedPuppet.IsAlive(targetAsPuppet) || IsDefined(evt.target as WeakspotObject);
      isExhuasted = StatusEffectSystem.ObjectHasStatusEffect(this, PlayerStaminaHelpers.GetExhaustedStatusEffectID());
      if !evt.hitBlocked && evt.instigator == this && !isExhuasted && validTarget {
        slowMoEvent = new MeleeHitSlowMoEvent();
        slowMoEvent.isStrongAttack = evt.isStrongAttack;
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, slowMoEvent, slowMoDelay);
      };
    };
  }

  protected cb func OnMeleeHitSloMo(evt: ref<MeleeHitSlowMoEvent>) -> Bool {
    let dilation: Float;
    let duration: Float;
    let easeInCurve: CName;
    let easeOutCurve: CName;
    if evt.isStrongAttack {
      dilation = TweakDBInterface.GetFloat(t"timeSystem.meleeHitStrong.timeDilation", 0.10);
      duration = TweakDBInterface.GetFloat(t"timeSystem.meleeHitStrong.duration", 0.10);
      easeInCurve = TweakDBInterface.GetCName(t"timeSystem.meleeHitStrong.easeInCurve", n"");
      easeOutCurve = TweakDBInterface.GetCName(t"timeSystem.meleeHitStrong.easeOutCurve", n"");
    } else {
      dilation = TweakDBInterface.GetFloat(t"timeSystem.meleeHit.timeDilation", 0.10);
      duration = TweakDBInterface.GetFloat(t"timeSystem.meleeHit.duration", 0.10);
      easeInCurve = TweakDBInterface.GetCName(t"timeSystem.meleeHit.easeInCurve", n"");
      easeOutCurve = TweakDBInterface.GetCName(t"timeSystem.meleeHit.easeOutCurve", n"");
    };
    if duration < 0.00 {
      duration = 0.10;
    };
    GameInstance.GetTimeSystem(this.GetGame()).SetTimeDilation(n"meleeHit", dilation, duration, easeInCurve, easeOutCurve);
  }

  private final func FindBuildSpacing(enumType: String, buildNameStringPart: String) -> Int32 {
    let buildInt: Int32;
    let fullEnumString: String;
    let i: Int32 = 1;
    while i <= 20 {
      fullEnumString = buildNameStringPart + i;
      buildInt = Cast(EnumValueFromString(enumType, fullEnumString));
      if buildInt >= 0 {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func GotKeycardNotification() -> Void {
    let notify: ref<AuthorisationNotificationEvent> = new AuthorisationNotificationEvent();
    notify.type = gameuiAuthorisationNotificationType.GotKeycard;
    this.QueueEvent(notify);
  }

  protected cb func OnHackPlayerEvent(evt: ref<HackPlayerEvent>) -> Bool {
    super.OnHackPlayerEvent(evt);
    this.m_attackingNetrunnerID = evt.netrunnerID;
  }

  protected cb func OnCarHitPlayer(evt: ref<OnCarHitPlayer>) -> Bool {
    let attack: ref<IAttack>;
    let attackContext: AttackInitContext;
    let broadcaster: ref<StimBroadcasterComponent>;
    let hitEvent: ref<gameHitEvent>;
    let hornEvt: ref<VehicleHornProbsEvent>;
    let soundEvent: ref<SoundPlayEvent>;
    let vehicleObject: ref<VehicleObject>;
    if StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.VehicleKnockdown") {
      return false;
    };
    hitEvent = new gameHitEvent();
    hitEvent.attackData = new AttackData();
    hitEvent.target = this;
    attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.CarHitPlayer");
    attackContext.instigator = this;
    attackContext.source = this;
    attack = IAttack.Create(attackContext);
    hitEvent.attackData.SetAttackDefinition(attack);
    hitEvent.attackData.AddFlag(hitFlag.FriendlyFire, n"vehicle_collision");
    hitEvent.attackData.AddFlag(hitFlag.CanDamageSelf, n"vehicle_collision");
    hitEvent.attackData.SetSource(this);
    hitEvent.attackData.SetInstigator(this);
    hitEvent.attackData.SetAttackDefinition(attack);
    hitEvent.hitDirection = evt.hitDirection;
    GameInstance.GetDamageSystem(this.GetGame()).StartPipeline(hitEvent);
    soundEvent = new SoundPlayEvent();
    soundEvent.soundName = n"v_col_player_impact";
    hitEvent.target.QueueEvent(soundEvent);
    broadcaster = this.GetStimBroadcasterComponent();
    broadcaster.TriggerSingleBroadcast(this, gamedataStimType.CrowdIllegalAction, 10.00);
    vehicleObject = GameInstance.FindEntityByID(this.GetGame(), evt.carId) as VehicleObject;
    hornEvt = new VehicleHornProbsEvent();
    hornEvt.honkMinTime = 1.00;
    hornEvt.honkMaxTime = 2.00;
    hornEvt.probability = 0.80;
    vehicleObject.QueueEvent(hornEvt);
  }

  protected cb func OnDistrictChanged(evt: ref<PlayerEnteredNewDistrictEvent>) -> Bool {
    this.m_gunshotRange = evt.gunshotRange;
    this.m_explosionRange = evt.explosionRange;
  }

  public final const func GetGunshotRange() -> Float {
    return this.m_gunshotRange;
  }

  public final const func GetExplosionRange() -> Float {
    return this.m_explosionRange;
  }

  public final const func GetMinigamePrograms() -> array<MinigameProgramData> {
    return (this.GetPS() as PlayerPuppetPS).GetMinigamePrograms();
  }

  protected cb func OnUpdateMiniGameProgramsEvent(evt: ref<UpdateMiniGameProgramsEvent>) -> Bool {
    this.UpdateMinigamePrograms(evt.program, evt.add);
  }

  private final func UpdateMinigamePrograms(program: MinigameProgramData, add: Bool) -> Void {
    let evt: ref<StoreMiniGameProgramEvent> = new StoreMiniGameProgramEvent();
    evt.program = program;
    evt.add = add;
    this.SendEventToDefaultPS(evt);
  }

  private final func RestoreMinigamePrograms() -> Void {
    let programs: array<MinigameProgramData> = (this.GetPS() as PlayerPuppetPS).GetMinigamePrograms();
    this.GetMinigameBlackboard().SetVariant(GetAllBlackboardDefs().HackingMinigame.PlayerPrograms, ToVariant(programs));
  }

  private final func GetMinigameBlackboard() -> ref<IBlackboard> {
    return GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().HackingMinigame);
  }

  private final func InitInterestingFacts() -> Void {
    this.m_interestingFacts.m_zone = n"CityAreaType";
    this.m_interestingFactsListenersFunctions.m_zone = n"OnZoneFactChanged";
  }

  public final func ApplyAimAssistSettings(opt configName: String) -> Void {
    let configRecord: wref<AimAssistConfigPreset_Record>;
    let aimAssistLevel: EAimAssistLevel = EAimAssistLevel.Standard;
    if Equals(configName, this.m_aimAssistListener.m_currentConfigString) {
      return;
    };
    if NotEquals(configName, "") {
      this.m_aimAssistListener.m_currentConfigString = configName;
      this.m_aimAssistListener.m_settingsRecord = TweakDBInterface.GetAimAssistSettingsRecord(TDBID.Create("AimAssist." + configName));
    };
    if IsDefined(this.m_aimAssistListener.m_settingsRecord) {
      if Equals(this.m_aimAssistListener.m_currentConfigString, "Settings_MeleeCombat") || Equals(this.m_aimAssistListener.m_currentConfigString, "Settings_MeleeCombatIdle") {
        aimAssistLevel = this.m_aimAssistListener.GetAimAssistMeleeLevel();
      } else {
        aimAssistLevel = this.m_aimAssistListener.GetAimAssistLevel();
      };
      if Equals(aimAssistLevel, EAimAssistLevel.Off) {
        configRecord = this.m_aimAssistListener.m_settingsRecord.Off();
      } else {
        if Equals(aimAssistLevel, EAimAssistLevel.Light) {
          configRecord = this.m_aimAssistListener.m_settingsRecord.Light();
        } else {
          configRecord = this.m_aimAssistListener.m_settingsRecord.Standard();
        };
      };
      GameInstance.GetTargetingSystem(this.GetGame()).SetAimAssistConfig(this, configRecord.GetID());
    };
  }

  private final func RegisterInterestingFactsListeners() -> Void {
    this.InitInterestingFacts();
    this.m_interestingFactsListenersIds.m_zone = GameInstance.GetQuestsSystem(this.GetGame()).RegisterListener(this.m_interestingFacts.m_zone, this, this.m_interestingFactsListenersFunctions.m_zone);
    this.InvalidateZone();
  }

  private final func UnregisterInterestingFactsListeners() -> Void {
    GameInstance.GetQuestsSystem(this.GetGame()).UnregisterListener(this.m_interestingFacts.m_zone, this.m_interestingFactsListenersIds.m_zone);
  }

  public final func SetBlackboardIntVariable(id: BlackboardID_Int, value: Int32) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(blackboard) {
      blackboard.SetInt(id, value);
    };
  }

  private final func InvalidateZone() -> Void {
    this.OnZoneFactChanged(GameInstance.GetQuestsSystem(this.GetGame()).GetFact(this.m_interestingFacts.m_zone));
  }

  public final func GetStaminaValueUnsafe() -> Float {
    return this.m_staminaListener.GetStaminaValue();
  }

  public final func GetStaminaPercUnsafe() -> Float {
    return this.m_staminaListener.GetStaminaPerc();
  }

  public final func OnZoneFactChanged(val: Int32) -> Void {
    let zoneType: gameCityAreaType = this.GetCurrentZoneType(val);
    switch zoneType {
      case gameCityAreaType.Undefined:
        this.OnExitPublicZone();
        this.OnExitSafeZone();
        this.OnEnterUndefinedZone();
        break;
      case gameCityAreaType.PublicZone:
        this.OnExitSafeZone();
        this.OnEnterPublicZone();
        break;
      case gameCityAreaType.SafeZone:
        this.OnExitPublicZone();
        this.OnEnterSafeZone();
        break;
      case gameCityAreaType.RestrictedZone:
        this.OnExitPublicZone();
        this.OnExitSafeZone();
        this.OnEnterRestrictedZone();
        break;
      case gameCityAreaType.DangerousZone:
        this.OnExitPublicZone();
        this.OnExitSafeZone();
        this.OnEnterDangerousZone();
    };
  }

  public final func SetSecurityAreaTypeE3HACK(securityAreaType: ESecurityAreaType) -> Void {
    this.m_securityAreaTypeE3HACK = securityAreaType;
    this.InvalidateZone();
  }

  private final func OnEnterUndefinedZone() -> Void;

  private final func OnEnterPublicZone() -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"InPublicZone";
    psmEvent.value = true;
    psmEvent.aspect = gamestateMachineParameterAspect.Permanent;
    this.QueueEvent(psmEvent);
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Zones, EnumInt(gamePSMZones.Public));
    GameInstance.GetAudioSystem(this.GetGame()).NotifyGameTone(n"EnterPublic");
  }

  private final func OnExitPublicZone() -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"InPublicZone";
    psmEvent.value = false;
    psmEvent.aspect = gamestateMachineParameterAspect.Permanent;
    this.QueueEvent(psmEvent);
  }

  private final func OnEnterSafeZone() -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"ForceEmptyHandsByZone";
    psmEvent.value = true;
    psmEvent.aspect = gamestateMachineParameterAspect.Permanent;
    this.QueueEvent(psmEvent);
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Zones, EnumInt(gamePSMZones.Safe));
    GameInstance.GetAudioSystem(this.GetGame()).NotifyGameTone(n"EnterSafe");
  }

  private final func OnExitSafeZone() -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"ForceEmptyHandsByZone";
    psmEvent.value = false;
    psmEvent.aspect = gamestateMachineParameterAspect.Permanent;
    this.QueueEvent(psmEvent);
  }

  private final func OnEnterRestrictedZone() -> Void {
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Zones, EnumInt(gamePSMZones.Restricted));
    GameInstance.GetAudioSystem(this.GetGame()).NotifyGameTone(n"EnterRestricted");
  }

  private final func OnEnterDangerousZone() -> Void {
    GameInstance.GetAudioSystem(this.GetGame()).NotifyGameTone(n"EnterDangerous");
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Zones, EnumInt(gamePSMZones.Dangerous));
  }

  protected final const func GetCurrentZoneType(factValue: Int32) -> gameCityAreaType {
    let questZoneType: gameCityAreaType = IntEnum(factValue);
    if Equals(questZoneType, gameCityAreaType.SafeZone) || Equals(questZoneType, gameCityAreaType.RestrictedZone) || Equals(questZoneType, gameCityAreaType.DangerousZone) {
      return questZoneType;
    };
    return this.GetCurrentSecurityZoneType(this);
  }

  protected final const func GetCurrentSecurityZoneType(owner: ref<GameObject>) -> gameCityAreaType {
    switch this.m_securityAreaTypeE3HACK {
      case ESecurityAreaType.SAFE:
        return gameCityAreaType.PublicZone;
      case ESecurityAreaType.RESTRICTED:
        return gameCityAreaType.RestrictedZone;
      case ESecurityAreaType.DANGEROUS:
        return gameCityAreaType.DangerousZone;
      default:
        return gameCityAreaType.PublicZone;
    };
    return gameCityAreaType.PublicZone;
  }

  protected cb func OnInvalidateVisionModeController(evt: ref<PlayerVisionModeControllerInvalidateEvent>) -> Bool {
    this.m_visionModeController.OnInvalidateActiveState(evt);
  }

  protected cb func OnInvalidateCombatController(evt: ref<PlayerCombatControllerInvalidateEvent>) -> Bool {
    this.m_combatController.OnInvalidateActiveState(evt);
  }

  protected cb func OnStartedBeingTrackedAsHostile(evt: ref<StartedBeingTrackedAsHostile>) -> Bool {
    this.m_combatController.OnStartedBeingTrackedAsHostile(evt);
  }

  protected cb func OnSquadIsTrackedEvent(evt: ref<SquadIsTracked>) -> Bool {
    if !evt.isSquadTracked {
      this.m_combatController.OnSquadStoppedBeingTracked();
    };
  }

  protected cb func OnCrouchDelayEvent(evt: ref<CrouchDelayEvent>) -> Bool {
    this.m_combatController.OnCrouchDelayEvent(evt);
  }

  public final const func GetCachedQuickHackList() -> array<PlayerQuickhackData> {
    let QHList: array<PlayerQuickhackData> = FromVariant(GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().PlayerQuickHackData).GetVariant(GetAllBlackboardDefs().PlayerQuickHackData.CachedQuickHackList));
    return QHList;
  }

  public final static func ChacheQuickHackList(self: wref<PlayerPuppet>, QHList: array<PlayerQuickhackData>) -> Void {
    if !IsDefined(self) {
      return;
    };
    GameInstance.GetBlackboardSystem(self.GetGame()).Get(GetAllBlackboardDefs().PlayerQuickHackData).SetVariant(GetAllBlackboardDefs().PlayerQuickHackData.CachedQuickHackList, ToVariant(QHList), true);
  }

  public final static func ChacheQuickHackListCleanup(object: wref<GameObject>) -> Void {
    let QHList: array<PlayerQuickhackData>;
    if !IsDefined(object) {
      return;
    };
    GameInstance.GetBlackboardSystem(object.GetGame()).Get(GetAllBlackboardDefs().PlayerQuickHackData).SetVariant(GetAllBlackboardDefs().PlayerQuickHackData.CachedQuickHackList, ToVariant(QHList), true);
  }
}

public class AutoRevealStatListener extends ScriptStatsListener {

  public let m_owner: wref<GameObject>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    let updateRequest: ref<UpdateAutoRevealStatEvent>;
    if Equals(statType, gamedataStatType.AutoReveal) && IsDefined(this.m_owner as PlayerPuppet) {
      updateRequest = new UpdateAutoRevealStatEvent();
      updateRequest.hasAutoReveal = total > 0.00;
      this.m_owner.QueueEvent(updateRequest);
    };
  }
}

public class VisibilityStatListener extends ScriptStatsListener {

  public let m_owner: wref<GameObject>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    let updateRequest: ref<UpdateVisibilityModifierEvent>;
    if Equals(statType, gamedataStatType.Visibility) && IsDefined(this.m_owner as PlayerPuppet) {
      updateRequest = new UpdateVisibilityModifierEvent();
      this.m_owner.QueueEvent(updateRequest);
    };
  }
}

public class SecondHeartStatListener extends ScriptStatsListener {

  public let m_player: wref<PlayerPuppet>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    if !IsDefined(this.m_player) {
      return;
    };
    if total > 0.00 {
      GameInstance.GetGodModeSystem(this.m_player.GetGame()).EnableOverride(this.m_player.GetEntityID(), gameGodModeType.Immortal, n"SecondHeart");
    } else {
      GameInstance.GetGodModeSystem(this.m_player.GetGame()).DisableOverride(this.m_player.GetEntityID(), n"SecondHeart");
    };
  }
}

public class SceneForceWeaponAim extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Force V to aim weapon";
  }
}

public class SceneForceWeaponSafe extends Event {

  public edit let weaponLoweringSpeedOverride: Float;

  public final func GetFriendlyDescription() -> String {
    return "Force V to equip/lower weapon";
  }
}

public class ManagePersonalLinkChangeEvent extends Event {

  public edit let shouldEquip: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Manager Personal Link Visualisation";
  }
}

public class EnableBraindanceActions extends Event {

  public edit let actionMask: SBraindanceInputMask;

  public final func GetFriendlyDescription() -> String {
    return "Enables all actions that are set to true in the actionMask struct";
  }
}

public class BraindanceInputChangeEvent extends Event {

  public let bdSystem: ref<BraindanceSystem>;

  public final func GetFriendlyDescription() -> String {
    return "signals that braindance controls changed and need a UI refresh";
  }
}

public class DisableBraindanceActions extends Event {

  public edit let actionMask: SBraindanceInputMask;

  public final func GetFriendlyDescription() -> String {
    return "Disables all actions that are set to true in the actionMask struct";
  }
}

public class ForceBraindanceCameraToggle extends Event {

  public edit let editorState: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Setting editorState will force enable the Editor (view from braindance replacer)";
  }
}

public class PauseBraindance extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Forces pause in braindance";
  }
}

public static exec func TestForcePlayerInvisible(gameInstance: GameInstance, value: String) -> Void {
  let setInvisible: Bool = Cast(StringToInt(value));
  let localPlayer: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  localPlayer.SetInvisible(setInvisible);
}
