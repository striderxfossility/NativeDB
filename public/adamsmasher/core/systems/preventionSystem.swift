
public class District extends IScriptable {

  private let m_districtID: TweakDBID;

  private let m_presetID: TweakDBID;

  public final const func GetDistrictID() -> TweakDBID {
    return this.m_districtID;
  }

  public final const func CreateDistrictRecord() -> wref<District_Record> {
    return TweakDBInterface.GetDistrictRecord(this.m_districtID);
  }

  public final const func GetPresetID() -> TweakDBID {
    return this.m_presetID;
  }

  public final const func GetGunshotStimRange() -> Float {
    return this.CreateDistrictRecord().GunShotStimRange();
  }

  public final const func GetExplosiveDeviceStimRange() -> Float {
    return this.CreateDistrictRecord().ExplosiveDeviceStimRangeMultiplier();
  }

  public final func Initialize(district: TweakDBID) -> Void {
    this.m_districtID = district;
    let createdDistrictRecord: wref<District_Record> = this.CreateDistrictRecord();
    if !IsDefined(createdDistrictRecord) {
      this.m_presetID = t"PreventionData.NCPD";
      return;
    };
    if TDBID.IsValid(createdDistrictRecord.PreventionPreset().GetID()) {
      this.m_presetID = createdDistrictRecord.PreventionPreset().GetID();
    } else {
      if TDBID.IsValid(createdDistrictRecord.ParentDistrict().PreventionPreset().GetID()) {
        this.m_presetID = createdDistrictRecord.ParentDistrict().PreventionPreset().GetID();
      } else {
        this.m_presetID = t"PreventionData.NCPD";
      };
    };
  }
}

public class DistrictManager extends IScriptable {

  private let m_system: wref<PreventionSystem>;

  private let m_stack: array<ref<District>>;

  private persistent let m_visitedDistricts: array<TweakDBID>;

  public final func Initialize(system: ref<PreventionSystem>) -> Void {
    this.m_system = system;
  }

  public final func Update(evt: ref<DistrictEnteredEvent>) -> Void {
    this.ManageDistrictStack(evt);
  }

  private final func ManageDistrictStack(request: ref<DistrictEnteredEvent>) -> Void {
    if request.entered {
      this.PushDistrict(request);
    } else {
      this.PopDistrict(request);
    };
    this.Refresh();
    this.NotifySystem();
  }

  private final func PushDistrict(request: ref<DistrictEnteredEvent>) -> Void {
    let d: ref<District>;
    let i: Int32;
    let playerNotification: ref<PlayerEnteredNewDistrictEvent>;
    if !TDBID.IsValid(request.district) {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_stack) {
      if this.m_stack[i].GetDistrictID() == request.district {
        ArrayErase(this.m_stack, i);
      } else {
        i += 1;
      };
    };
    d = new District();
    d.Initialize(request.district);
    ArrayPush(this.m_stack, d);
    playerNotification = new PlayerEnteredNewDistrictEvent();
    playerNotification.gunshotRange = d.GetGunshotStimRange();
    playerNotification.explosionRange = d.GetExplosiveDeviceStimRange();
    GameInstance.GetPlayerSystem(this.m_system.GetGame()).GetLocalPlayerMainGameObject().QueueEvent(playerNotification);
  }

  private final func PopDistrict(request: ref<DistrictEnteredEvent>) -> Void {
    let i: Int32 = ArraySize(this.m_stack) - 1;
    while i >= 0 {
      if this.m_stack[i].GetDistrictID() == request.district {
        ArrayErase(this.m_stack, i);
        return;
      };
      i -= 1;
    };
  }

  private final func Refresh() -> Void {
    let blackboard: ref<IBlackboard>;
    let districtRecord: wref<District_Record>;
    let isNew: Bool;
    let d: wref<District> = this.GetCurrentDistrict();
    if !IsDefined(d) {
      return;
    };
    if !ArrayContains(this.m_visitedDistricts, d.GetDistrictID()) {
      ArrayPush(this.m_visitedDistricts, d.GetDistrictID());
      isNew = true;
    };
    districtRecord = d.CreateDistrictRecord();
    blackboard = GameInstance.GetBlackboardSystem(this.m_system.GetGame()).Get(GetAllBlackboardDefs().UI_Map);
    if IsDefined(blackboard) {
      blackboard.SetString(GetAllBlackboardDefs().UI_Map.currentLocationEnumName, districtRecord.EnumName(), true);
      blackboard.SetString(GetAllBlackboardDefs().UI_Map.currentLocation, districtRecord.LocalizedName(), true);
      blackboard.SetBool(GetAllBlackboardDefs().UI_Map.newLocationDiscovered, isNew, true);
    };
    GameInstance.GetTelemetrySystem(this.m_system.GetGame()).LogDistrictChanged(districtRecord.EnumName(), isNew);
  }

  private final func NotifySystem() -> Void {
    let request: ref<RefreshDistrictRequest> = new RefreshDistrictRequest();
    request.preventionPreset = TweakDBInterface.GetDistrictPreventionDataRecord(this.GetCurrentDistrict().GetPresetID());
    this.m_system.QueueRequest(request);
  }

  public final const func GetCurrentDistrict() -> wref<District> {
    let size: Int32 = ArraySize(this.m_stack);
    if size == 0 {
      return null;
    };
    return this.m_stack[size - 1];
  }
}

public class PreventionSystem extends ScriptableSystem {

  private persistent let m_districtManager: ref<DistrictManager>;

  private let m_player: wref<PlayerPuppet>;

  private let m_preventionPreset: wref<DistrictPreventionData_Record>;

  private let m_hiddenReaction: Bool;

  private let m_systemDisabled: Bool;

  private let m_systemLockSources: array<CName>;

  private let m_deescalationZeroLockExecution: Bool;

  private let m_heatStage: EPreventionHeatStage;

  private let m_playerIsInSecurityArea: array<PersistentID>;

  private let m_policeSecuritySystems: array<PersistentID>;

  private let m_policeman100SpawnHits: Int32;

  private let m_agentGroupsList: array<ref<PreventionAgents>>;

  private let m_agentsWhoSeePlayer: array<EntityID>;

  private let m_hitNPC: array<SHitNPC>;

  private let m_spawnedAgents: array<wref<ScriptedPuppet>>;

  private let m_lastCrimePoint: Vector4;

  private let m_lastBodyPosition: Vector4;

  private let m_DEBUG_lastCrimeDistance: Float;

  private let m_policemanRandPercent: Int32;

  private let m_policemabProbabilityPercent: Int32;

  private let m_generalPercent: Float;

  private let m_partGeneralPercent: Float;

  private let m_newDamageValue: Float;

  private let m_gameTimeStampPrevious: Float;

  private let m_gameTimeStampLastPoliceRise: Float;

  private let m_gameTimeStampDeescalationZero: Float;

  private let m_deescalationZeroDelayID: DelayID;

  private let m_deescalationZeroCheck: Bool;

  private let m_policemenSpawnDelayID: DelayID;

  private let m_preventionTickDelayID: DelayID;

  private let m_preventionTickCheck: Bool;

  private let m_securityAreaResetDelayID: DelayID;

  private let m_securityAreaResetCheck: Bool;

  private let m_hadOngoingSpawnRequest: Bool;

  private let Debug_PorcessReason: EPreventionDebugProcessReason;

  private let Debug_PsychoLogicType: EPreventionPsychoLogicType;

  private let m_currentPreventionPreset: TweakDBID;

  private let m_failsafePoliceRecordT1: TweakDBID;

  private let m_failsafePoliceRecordT2: TweakDBID;

  private let m_failsafePoliceRecordT3: TweakDBID;

  private let m_blinkReasonsStack: array<CName>;

  private let m_wantedBarBlackboard: wref<IBlackboard>;

  private let m_onPlayerChoiceCallID: ref<CallbackHandle>;

  private let m_playerAttachedCallbackID: Uint32;

  private let m_playerDetachedCallbackID: Uint32;

  private let m_playerHLSID: ref<CallbackHandle>;

  private let m_playerVehicleStateID: ref<CallbackHandle>;

  private let m_playerHLS: gamePSMHighLevel;

  private let m_playerVehicleState: gamePSMVehicle;

  private let m_currentStageFallbackUnitSpawned: Bool;

  private let m_unhandledInputsReceived: Int32;

  private let m_inputlockDelayID: DelayID;

  private let m_preventionUnitKilledDuringLock: Bool;

  private let m_reconDeployed: Bool;

  private let m_vehicles: array<wref<VehicleObject>>;

  private let m_viewers: array<wref<GameObject>>;

  private let m_hasViewers: Bool;

  public final const func IsSystemDissabled() -> Bool {
    return this.m_systemDisabled;
  }

  public final const func GetHeatStage() -> EPreventionHeatStage {
    return this.m_heatStage;
  }

  public final const func GetGeneralPercent() -> Float {
    return this.m_generalPercent;
  }

  public final const func GetPartGeneralPercent() -> Float {
    return this.m_partGeneralPercent;
  }

  public final const func GetNewDamageValue() -> Float {
    return this.m_newDamageValue;
  }

  public final const func IsChasingPlayer() -> Bool {
    return NotEquals(this.m_heatStage, EPreventionHeatStage.Heat_0);
  }

  public final const func AreTurretsActive() -> Bool {
    return Equals(this.m_heatStage, EPreventionHeatStage.Heat_4);
  }

  private final func GetGameTimeStamp() -> Float {
    return EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
  }

  public final const func GetGame() -> GameInstance {
    return this.GetGameInstance();
  }

  public final const func GetSafeDistance() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.SafeDistance();
    };
    return 170.00;
  }

  public final const func GetBlinkThreshold() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.BlinkThreshold();
    };
    return 30.00;
  }

  public final const func GetInteriorSpawnDelay() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.InteriorSpawnDelay();
    };
    return 7.00;
  }

  public final const func GetExteriorSpawnDelay() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.ExteriorSpawnDelay();
    };
    return 4.00;
  }

  public final const func GetDamagePercentThreshold() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.DamagePercentThreshold();
    };
    return 1.00;
  }

  public final const func GetDeescalationTime() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.DeescalationZeroTime();
    };
    return 30.00;
  }

  public final const func GetNonAggressiveReactionMultipler() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.NonAggressiveReactionMultipler();
    };
    return 5.00;
  }

  public final const func GetPreventionInputLockTime() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.InputLockTime();
    };
    return 3.00;
  }

  public final const func GetInputLockOverrideThreshold() -> Int32 {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.InputLockOverrideThreshold();
    };
    return 4;
  }

  public final const func GetSpawnOriginMaxDistance() -> Float {
    if IsDefined(this.m_preventionPreset) {
      return this.m_preventionPreset.SpawnOriginMaxDistance();
    };
    return 30.00;
  }

  private final func IsPreventionInputLocked() -> Bool {
    return this.m_inputlockDelayID != GetInvalidDelayID();
  }

  private final func RemovePreventionInputLock() -> Void {
    if this.IsPreventionInputLocked() {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_inputlockDelayID);
      this.m_inputlockDelayID = GetInvalidDelayID();
      this.m_unhandledInputsReceived = 0;
      this.m_preventionUnitKilledDuringLock = false;
    };
  }

  private final func ActivatePreventionInputLock() -> Void {
    let request: ref<UnlockPreventionInputRequest>;
    if this.IsPreventionInputLocked() {
      this.RemovePreventionInputLock();
    };
    request = new UnlockPreventionInputRequest();
    this.m_inputlockDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"PreventionSystem", request, this.GetPreventionInputLockTime());
  }

  private final func OnUnlockPreventionInputRequest(request: ref<UnlockPreventionInputRequest>) -> Void {
    if this.m_preventionUnitKilledDuringLock {
      this.SendInternalSystem(1.00);
    };
    this.RemovePreventionInputLock();
  }

  protected final func SetPartGeneralPercent(value: Float) -> Void {
    this.m_partGeneralPercent = value;
  }

  protected final func SetNewDamageValue(value: Float) -> Void {
    this.m_newDamageValue = value;
  }

  protected final func SetHeatStage(value: EPreventionHeatStage) -> Bool {
    if Equals(this.m_heatStage, value) {
      return false;
    };
    this.m_heatStage = value;
    if IsDefined(this.m_wantedBarBlackboard) {
      this.m_wantedBarBlackboard.SetInt(GetAllBlackboardDefs().UI_WantedBar.CurrentWantedLevel, EnumInt(this.m_heatStage), true);
      this.SetWantedLevelFact(EnumInt(this.m_heatStage));
    };
    return true;
  }

  protected final func SetNewLastCrimePoint(value: Vector4) -> Void {
    this.ResetDeescalationZero();
    if this.CheckifNewPointIsCloserThanPrevious(this.m_lastCrimePoint, value) {
      this.m_lastCrimePoint = value;
    };
  }

  protected final func SetNewLastBodyPosition(value: Vector4) -> Void {
    if this.CheckifNewPointIsCloserThanPrevious(this.m_lastBodyPosition, value) {
      this.m_lastBodyPosition = value;
    };
  }

  protected final func AddGeneralPercent(value: Float) -> Void {
    if this.m_unhandledInputsReceived >= this.GetInputLockOverrideThreshold() {
      this.RemovePreventionInputLock();
    };
    if this.IsPreventionInputLocked() {
      this.m_unhandledInputsReceived += 1;
      return;
    };
    this.m_generalPercent += value;
    if this.m_generalPercent < 0.00 {
      this.m_generalPercent = 0.00;
    };
    if this.m_generalPercent < 1.00 && this.m_generalPercent > 0.30 {
      this.m_generalPercent = 1.00;
    };
    this.ActivatePreventionInputLock();
  }

  public final const func CanPreventionReactToInput() -> Bool {
    if !IsDefined(this.m_player) {
      return false;
    };
    if this.IsSystemDissabled() || IsMultiplayer() {
      return false;
    };
    if EnumInt(this.m_playerHLS) > EnumInt(gamePSMHighLevel.SceneTier1) && EnumInt(this.m_playerHLS) <= EnumInt(gamePSMHighLevel.SceneTier5) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_player, n"VehicleCombat") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_player, n"VehicleScene") {
      return false;
    };
    return true;
  }

  private final func GetFallbackUnitSpawnData(heatStage: EPreventionHeatStage, out characterRecord: TweakDBID, out minSpawnRange: Float, out unitsCount: Int32) -> Bool {
    let fallbackUnitData: wref<PreventionFallbackUnitData_Record>;
    let heatData: wref<PreventionHeatData_Record>;
    if IsDefined(this.m_preventionPreset) {
      switch heatStage {
        case EPreventionHeatStage.Heat_0:
          return false;
        case EPreventionHeatStage.Heat_1:
          heatData = this.m_preventionPreset.Heat1();
          break;
        case EPreventionHeatStage.Heat_2:
          heatData = this.m_preventionPreset.Heat2();
          break;
        case EPreventionHeatStage.Heat_3:
          heatData = this.m_preventionPreset.Heat3();
          break;
        case EPreventionHeatStage.Heat_4:
          heatData = this.m_preventionPreset.Heat4();
          break;
        default:
          return false;
      };
      if IsDefined(heatData) {
        fallbackUnitData = heatData.FallbackUnitData();
        if IsDefined(fallbackUnitData) {
          characterRecord = fallbackUnitData.CharacterRecord().GetID();
          minSpawnRange = fallbackUnitData.MinSpawnRange();
          unitsCount = fallbackUnitData.UnitsCount();
          return true;
        };
        return false;
      };
      return false;
    };
    return false;
  }

  private final func GetSpawnDataFromHeatStage(heatStage: EPreventionHeatStage, out characterRecords: array<TweakDBID>, out spawnRange: Vector2, out unitsCount: Uint32, out spawnInterval: Float, out hasRecon: Bool) -> Bool {
    let characterRecord: TweakDBID;
    let characterRecordPool: array<wref<PreventionUnitPoolData_Record>>;
    let heatData: wref<PreventionHeatData_Record>;
    let i: Int32;
    ArrayClear(characterRecords);
    if IsDefined(this.m_preventionPreset) {
      if !this.m_reconDeployed && NotEquals(heatStage, EPreventionHeatStage.Heat_0) {
        heatData = this.m_preventionPreset.Recon();
      };
      if !IsDefined(heatData) {
        switch heatStage {
          case EPreventionHeatStage.Heat_0:
            return false;
          case EPreventionHeatStage.Heat_1:
            heatData = this.m_preventionPreset.Heat1();
            break;
          case EPreventionHeatStage.Heat_2:
            heatData = this.m_preventionPreset.Heat2();
            break;
          case EPreventionHeatStage.Heat_3:
            heatData = this.m_preventionPreset.Heat3();
            break;
          case EPreventionHeatStage.Heat_4:
            heatData = this.m_preventionPreset.Heat4();
            break;
          default:
            return false;
        };
      } else {
        hasRecon = true;
      };
      if IsDefined(heatData) && heatData.GetUnitRecordsPoolCount() > 0 {
        heatData.UnitRecordsPool(characterRecordPool);
        unitsCount = Cast(heatData.UnitsCount());
        spawnRange = heatData.SpawnRange();
        spawnInterval = MaxF(heatData.SpawnInterval(), 0.00);
        i = 0;
        while i < Cast(unitsCount) {
          if this.GetCharacterRecordFromPool(characterRecordPool, characterRecord) {
            ArrayPush(characterRecords, characterRecord);
          } else {
            goto 931;
          };
          i += 1;
        };
        if ArraySize(characterRecords) > 0 {
          return true;
        };
      };
    };
    switch heatStage {
      case EPreventionHeatStage.Heat_0:
        return false;
      case EPreventionHeatStage.Heat_1:
        ArrayPush(characterRecords, this.m_failsafePoliceRecordT1);
        unitsCount = 2u;
        spawnRange.Y = 45.00;
        spawnRange.Y = 65.00;
        break;
      case EPreventionHeatStage.Heat_2:
        ArrayPush(characterRecords, this.m_failsafePoliceRecordT2);
        unitsCount = 2u;
        spawnRange.Y = 45.00;
        spawnRange.Y = 65.00;
        break;
      case EPreventionHeatStage.Heat_4:
      case EPreventionHeatStage.Heat_3:
        ArrayPush(characterRecords, this.m_failsafePoliceRecordT3);
        unitsCount = 2u;
        spawnRange.Y = 45.00;
        spawnRange.Y = 65.00;
        break;
      default:
    };
    if ArraySize(characterRecords) > 0 {
      return true;
    };
    return false;
  }

  private final func GetCharacterRecordFromPool(pool: array<wref<PreventionUnitPoolData_Record>>, out recordID: TweakDBID) -> Bool {
    let accumulator: Float;
    let characterRecord: wref<Character_Record>;
    let weightSum: Float;
    let randomVal: Float = 0.00;
    let i: Int32 = 0;
    while i < ArraySize(pool) {
      weightSum += pool[i].Weight();
      i += 1;
    };
    randomVal = RandRangeF(0.00, weightSum);
    i = 0;
    while i < ArraySize(pool) {
      pool[i].Weight();
      accumulator += pool[i].Weight();
      if randomVal < accumulator {
        characterRecord = pool[i].CharacterRecord();
        if IsDefined(characterRecord) {
          recordID = characterRecord.GetID();
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  private func IsSavingLocked() -> Bool {
    return this.IsChasingPlayer();
  }

  private func OnAttach() -> Void {
    this.m_districtManager = new DistrictManager();
    this.m_districtManager.Initialize(this);
    if !IsFinal() {
      this.RefreshDebug();
    };
    this.RestoreDefaultConfig();
    this.m_failsafePoliceRecordT1 = t"Character.prevention_unit_tier1";
    this.m_failsafePoliceRecordT2 = t"Character.prevention_unit_tier2";
    this.m_failsafePoliceRecordT3 = t"Character.prevention_unit_tier3";
    this.m_wantedBarBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_WantedBar);
    this.RegisterToBBCalls();
    this.ChangeAgentsAttitude(EAIAttitude.AIA_Neutral);
  }

  private func OnDetach() -> Void {
    this.UnregisterBBCalls();
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    this.m_districtManager.Initialize(this);
    if !this.IsChasingPlayer() {
      FastTravelSystem.RemoveFastTravelLock(n"PreventionSystem", this.GetGameInstance());
      this.ChangeAgentsAttitude(EAIAttitude.AIA_Neutral);
    };
  }

  private final func RegisterToBBCalls() -> Void {
    if !IsDefined(this.m_onPlayerChoiceCallID) {
      this.m_onPlayerChoiceCallID = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UIInteractions).RegisterListenerVariant(GetAllBlackboardDefs().UIInteractions.LastAttemptedChoice, this, n"OnPlayerChoice");
    };
    this.m_playerAttachedCallbackID = GameInstance.GetPlayerSystem(this.GetGameInstance()).RegisterPlayerPuppetAttachedCallback(this, n"PlayerAttachedCallback");
    this.m_playerDetachedCallbackID = GameInstance.GetPlayerSystem(this.GetGameInstance()).RegisterPlayerPuppetDetachedCallback(this, n"PlayerDetachedCallback");
  }

  private final func UnregisterBBCalls() -> Void {
    if IsDefined(this.m_onPlayerChoiceCallID) {
      GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UIInteractions).UnregisterListenerVariant(GetAllBlackboardDefs().UIInteractions.LastAttemptedChoice, this.m_onPlayerChoiceCallID);
    };
    GameInstance.GetPlayerSystem(this.GetGameInstance()).UnregisterPlayerPuppetAttachedCallback(this.m_playerAttachedCallbackID);
    GameInstance.GetPlayerSystem(this.GetGameInstance()).UnregisterPlayerPuppetDetachedCallback(this.m_playerDetachedCallbackID);
  }

  private final func PlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {
    let psmBlackboard: ref<IBlackboard>;
    this.m_player = playerPuppet as PlayerPuppet;
    if !IsDefined(this.m_player) {
      return;
    };
    psmBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(psmBlackboard) {
      this.m_playerHLSID = psmBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel, this, n"OnPlayerHLSChange", true);
      this.m_playerVehicleStateID = psmBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle, this, n"OnPlayerVehicleStateChange", true);
    } else {
      this.m_playerHLSID = null;
      this.m_playerVehicleStateID = null;
    };
  }

  private final func PlayerDetachedCallback(playerPuppet: ref<GameObject>) -> Void {
    this.m_player = null;
    let psmBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(psmBlackboard) {
      if IsDefined(this.m_playerHLSID) {
        psmBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel, this.m_playerHLSID);
      };
      if IsDefined(this.m_playerVehicleStateID) {
        psmBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle, this.m_playerVehicleStateID);
      };
    };
  }

  protected cb func OnPlayerHLSChange(value: Int32) -> Bool {
    this.m_playerHLS = IntEnum(value);
    this.ReevaluateSecurityAreaReset();
  }

  protected cb func OnPlayerVehicleStateChange(value: Int32) -> Bool {
    this.m_playerVehicleState = IntEnum(value);
  }

  protected final func AddUniqueHitNPC(entityID: EntityID) -> Bool {
    let i: Int32;
    let newData: SHitNPC;
    if !EntityID.IsDefined(entityID) {
      return false;
    };
    i = ArraySize(this.m_hitNPC) - 1;
    while i >= 0 {
      if this.m_hitNPC[i].entityID == entityID {
        return false;
      };
      i -= 1;
    };
    newData.entityID = entityID;
    newData.calls = 0;
    ArrayPush(this.m_hitNPC, newData);
    return true;
  }

  protected final func WhipeHitNPC() -> Void {
    ArrayClear(this.m_hitNPC);
  }

  protected final func OnDamageInput(request: ref<PreventionDamageRequest>) -> Void {
    if !this.CanPreventionReactToInput() {
      this.Debug_PorcessReason = EPreventionDebugProcessReason.Abort_SystemLockedBySceneTier;
      if !IsFinal() {
        this.RefreshDebugProcessInfo();
      };
      return;
    };
    if !request.isInternal {
      this.ResetDeescalationZero();
      this.CreateCrowdNullArea(request.targetPosition);
    };
    if this.IsPreventionInputLocked() {
      if !request.isTargetPrevention && !request.isTargetAlive {
        this.m_preventionUnitKilledDuringLock = true;
      };
    };
    this.Debug_PorcessReason = EPreventionDebugProcessReason.Process_NewDamage;
    if request.damagePercentValue < 0.00 {
      this.Debug_PorcessReason = EPreventionDebugProcessReason.Abort_DamageZero;
      if !IsFinal() {
        this.RefreshDebugProcessInfo();
      };
      return;
    };
    if !this.AddUniqueHitNPC(request.targetID) && !request.isInternal {
      this.Debug_PorcessReason = EPreventionDebugProcessReason.Abort_EntitySame;
      if !IsFinal() {
        this.RefreshDebugProcessInfo();
      };
      return;
    };
    if request.damagePercentValue > 1.00 {
      this.SetNewDamageValue(1.00);
    } else {
      this.SetNewDamageValue(request.damagePercentValue);
    };
    this.SetNewLastCrimePoint(request.targetPosition);
    this.SetNewLastBodyPosition(request.targetPosition);
    this.StartPipeline();
  }

  private final func ShouldSkipSpawning(opt requester: wref<ScriptedPuppet>) -> Bool {
    if !IsDefined(requester) {
      return false;
    };
    if NPCManager.HasTag(requester.GetRecordID(), n"DoNotTriggerSpawningPolice") {
      return true;
    };
    return false;
  }

  private final func HeatPipeline(opt skipSpawningUnits: Bool) -> Void {
    let flooredGenPercent: Int32 = FloorF(this.GetGeneralPercent());
    if this.SetHeatStage(IntToEPreventionHeatStage(flooredGenPercent)) || Equals(this.m_heatStage, EPreventionHeatStage.Heat_4) {
      this.OnHeatChanged(skipSpawningUnits);
    } else {
      GameInstance.GetAudioSystem(this.GetGame()).Play(n"gmp_ui_prevention_player_commit_crime");
    };
  }

  private final func OnHeatChanged(opt skipSpawningUnits: Bool) -> Void {
    let elevator: wref<GameObject>;
    if this.IsChasingPlayer() {
      this.StartPreventionTickRequest();
      GameInstance.GetAudioSystem(this.GetGame()).Play(n"gmp_ui_prevention_player_marked_psycho");
      this.ChangeAgentsAttitude(EAIAttitude.AIA_Hostile);
      this.TutorialAddPoliceSystemFact();
      FastTravelSystem.AddFastTravelLock(n"PreventionSystem", this.GetGameInstance());
      this.StartDeescalationZero();
      if !skipSpawningUnits {
        this.SpawnPipeline(this.m_heatStage);
      };
    };
    if LiftDevice.GetCurrentElevator(this.GetGame(), elevator) {
      elevator.QueueEvent(new RefreshPlayerAuthorizationEvent());
    };
    switch this.m_heatStage {
      case EPreventionHeatStage.Heat_0:
        GameInstance.GetAudioSystem(this.GetGame()).Play(n"gmp_ui_prevention_player_reset");
        GameInstance.GetAudioSystem(this.GetGame()).RegisterPreventionHeatStage(0u);
        FastTravelSystem.RemoveFastTravelLock(n"PreventionSystem", this.GetGameInstance());
        this.RemovePreventionInputLock();
        this.m_reconDeployed = false;
        break;
      case EPreventionHeatStage.Heat_1:
        GameInstance.GetAudioSystem(this.GetGame()).RegisterPreventionHeatStage(1u);
        break;
      case EPreventionHeatStage.Heat_2:
        GameInstance.GetAudioSystem(this.GetGame()).RegisterPreventionHeatStage(2u);
        break;
      case EPreventionHeatStage.Heat_3:
        GameInstance.GetAudioSystem(this.GetGame()).RegisterPreventionHeatStage(3u);
        break;
      case EPreventionHeatStage.Heat_4:
        GameInstance.GetAudioSystem(this.GetGame()).RegisterPreventionHeatStage(4u);
        this.WakeUpAllAgents(true);
    };
    this.m_currentStageFallbackUnitSpawned = false;
    if !IsFinal() {
      this.RefreshDebug();
    };
  }

  private final func TutorialAddPoliceSystemFact() -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
    if questSystem.GetFact(n"police_system_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"police_system_tutorial", 1);
    };
  }

  private final func SetWantedLevelFact(level: Int32) -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
    if IsDefined(questSystem) {
      questSystem.SetFact(n"wanted_level", level);
    };
  }

  private final func StartPipeline() -> Void {
    this.m_hiddenReaction = false;
    this.PreDamageChange();
    this.DamageChange();
    this.PostDamageChange();
    if !IsFinal() {
      this.RefreshDebug();
    };
    this.m_gameTimeStampPrevious = this.GetGameTimeStamp();
  }

  private final func PreDamageChange() -> Void {
    if this.ShouldReactionBeAggressive() {
      this.SetPartGeneralPercent(this.GetNewDamageValue() / this.GetDamagePercentThreshold());
    } else {
      this.SetPartGeneralPercent(this.GetNewDamageValue() / (this.GetDamagePercentThreshold() * this.GetNonAggressiveReactionMultipler()));
    };
  }

  private final func DamageChange() -> Void {
    this.AddGeneralPercent(this.GetPartGeneralPercent());
  }

  private final func PostDamageChange() -> Void {
    this.HeatPipeline();
  }

  private final func RisePoliceProbability() -> Void {
    this.m_policeman100SpawnHits += 1;
    this.m_gameTimeStampLastPoliceRise = this.GetGameTimeStamp();
  }

  private final func StartDeescalationZero() -> Void {
    let delayedDeescalationZero: ref<PreventionDelayedZeroRequest>;
    if !this.m_deescalationZeroCheck {
      delayedDeescalationZero = new PreventionDelayedZeroRequest();
      this.m_deescalationZeroDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"PreventionSystem", delayedDeescalationZero, this.GetDeescalationTime());
      this.m_deescalationZeroCheck = true;
      if !IsFinal() {
        this.RefreshDebugEvents();
      };
    };
  }

  private final func StopDeescalationZero() -> Void {
    if this.m_deescalationZeroCheck {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_deescalationZeroDelayID);
      this.m_deescalationZeroCheck = false;
      if !IsFinal() {
        this.RefreshDebugEvents();
      };
    };
  }

  private final func ResetDeescalationZero() -> Void {
    if !this.m_deescalationZeroCheck {
      return;
    };
    this.StopDeescalationZero();
    this.m_deescalationZeroLockExecution = false;
    this.StartDeescalationZero();
  }

  private final func OnDeescalationZero(evt: ref<PreventionDelayedZeroRequest>) -> Void {
    if ArraySize(this.m_viewers) > 0 {
      this.ResetDeescalationZero();
      return;
    };
    this.execInstructionSafe();
    if !IsFinal() {
      this.RefreshDebugEvents();
    };
  }

  private final func OnDelayedSpawnRequest(evt: ref<PreventionDelayedSpawnRequest>) -> Void {
    this.m_policemenSpawnDelayID = GetInvalidDelayID();
    this.SpawnPolice(evt.heatStage);
  }

  private final func SpawnPipeline(heatStage: EPreventionHeatStage, opt delay: Float) -> Void {
    if !this.CanPreventionReactToInput() {
      return;
    };
    if ArraySize(this.m_playerIsInSecurityArea) > 0 {
      return;
    };
    if Equals(heatStage, EPreventionHeatStage.Heat_0) {
      return;
    };
    this.CancelSpawnDelay();
    this.UpdateVehicles();
    if delay > 0.00 {
      this.SpawnPoliceWithDelay(heatStage, delay);
    } else {
      if IsEntityInInteriorArea(this.m_player) {
        this.SpawnPoliceWithDelay(heatStage, this.GetInteriorSpawnDelay());
      } else {
        if this.ShouldSpawnVehicle() {
          this.SpawnPoliceVehicle(heatStage);
        } else {
          this.SpawnPoliceWithDelay(heatStage, this.GetExteriorSpawnDelay());
        };
      };
    };
  }

  private final func CancelSpawnDelay() -> Bool {
    if this.m_policemenSpawnDelayID != GetInvalidDelayID() {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_policemenSpawnDelayID);
      this.m_policemenSpawnDelayID = GetInvalidDelayID();
      return true;
    };
    return false;
  }

  private final func SpawnPoliceWithDelay(heatStage: EPreventionHeatStage, delay: Float) -> Void {
    let evt: ref<PreventionDelayedSpawnRequest>;
    this.CancelSpawnDelay();
    evt = new PreventionDelayedSpawnRequest();
    evt.heatStage = heatStage;
    this.m_policemenSpawnDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayScriptableSystemRequest(n"PreventionSystem", evt, delay);
  }

  private final func SpawnPolice(heatStage: EPreventionHeatStage) -> Void {
    let backupSpawnPoints: array<Vector4>;
    let characterRecordIDs: array<TweakDBID>;
    let fallbackSpawnPoints: array<Vector4>;
    let fallbackUnitMinSpawnRange: Float;
    let fallbackUnitRecordID: TweakDBID;
    let fallbackUnitsCount: Int32;
    let hasRecon: Bool;
    let i: Int32;
    let isFallbackValid: Bool;
    let spawnInterval: Float;
    let spawnOriginsData: array<SpawnOriginData>;
    let spawnPoints: array<Vector4>;
    let spawnRange: Vector2;
    let unitsCount: Uint32;
    if !IsDefined(this.m_player) {
      return;
    };
    if this.GetSpawnDataFromHeatStage(heatStage, characterRecordIDs, spawnRange, unitsCount, spawnInterval, hasRecon) {
      this.GetFindSpawnPointsOriginsData(spawnOriginsData);
      i = 0;
      while i < ArraySize(spawnOriginsData) {
        if GameInstance.GetNavigationSystem(this.GetGameInstance()).FindPursuitPointsRange(spawnOriginsData[i].playerPosition, spawnOriginsData[i].position, spawnOriginsData[i].direction, spawnRange.X, spawnRange.Y, ArraySize(characterRecordIDs), false, NavGenAgentSize.Human, spawnPoints, fallbackSpawnPoints) {
          if this.SpawnUnits(spawnPoints, characterRecordIDs, EnumInt(heatStage), spawnInterval) {
            if hasRecon && !this.m_reconDeployed {
              this.m_reconDeployed = true;
              this.SpawnPipeline(heatStage);
            };
            return;
          };
        };
        i += 1;
      };
      if !this.m_currentStageFallbackUnitSpawned && this.GetFallbackUnitSpawnData(heatStage, fallbackUnitRecordID, fallbackUnitMinSpawnRange, fallbackUnitsCount) {
        isFallbackValid = true;
        ArrayClear(fallbackSpawnPoints);
        ArrayClear(characterRecordIDs);
        ArrayPush(characterRecordIDs, fallbackUnitRecordID);
        i = 0;
        while i < ArraySize(spawnOriginsData) {
          if GameInstance.GetNavigationSystem(this.GetGameInstance()).FindPursuitPointsRange(spawnOriginsData[i].playerPosition, spawnOriginsData[i].position, spawnOriginsData[i].direction, fallbackUnitMinSpawnRange, spawnRange.X, fallbackUnitsCount, false, NavGenAgentSize.Human, spawnPoints, fallbackSpawnPoints) {
            if ArraySize(backupSpawnPoints) == 0 {
              backupSpawnPoints = fallbackSpawnPoints;
            };
            if this.SpawnUnits(spawnPoints, characterRecordIDs, EnumInt(heatStage), spawnInterval) {
              this.m_currentStageFallbackUnitSpawned = true;
              if hasRecon && !this.m_reconDeployed {
                this.m_reconDeployed = true;
                this.SpawnPipeline(heatStage);
              } else {
                this.SpawnPoliceWithDelay(heatStage, 1.00);
              };
              return;
            };
          };
          i += 1;
        };
      };
      if !this.m_currentStageFallbackUnitSpawned && isFallbackValid {
        if this.SpawnUnits(backupSpawnPoints, characterRecordIDs, EnumInt(heatStage), spawnInterval) {
          this.m_currentStageFallbackUnitSpawned = true;
          if hasRecon && !this.m_reconDeployed {
            this.m_reconDeployed = true;
            this.SpawnPipeline(heatStage);
          } else {
            this.SpawnPoliceWithDelay(heatStage, 1.00);
          };
        } else {
          this.SpawnPoliceWithDelay(heatStage, 1.00);
        };
      };
    };
  }

  private final func SpawnUnits(spawnPoints: array<Vector4>, characterRecords: array<TweakDBID>, heatStage: Uint32, spawnInterval: Float) -> Bool {
    let currentRecordIdx: Int32;
    let i: Int32;
    let lastRecordIdx: Int32;
    let spawnTransform: WorldTransform;
    if ArraySize(spawnPoints) > 0 {
      lastRecordIdx = ArraySize(characterRecords) - 1;
      i = 0;
      while i < ArraySize(spawnPoints) {
        WorldTransform.SetPosition(spawnTransform, spawnPoints[i]);
        WorldTransform.SetOrientationFromDir(spawnTransform, Vector4.Normalize2D(this.m_player.GetWorldPosition() - spawnPoints[i]));
        PreventionSystem.DelayedSpawnUnitRequest(this.GetGame(), characterRecords[currentRecordIdx], heatStage, spawnTransform, Cast(i + 1) * spawnInterval);
        if currentRecordIdx < lastRecordIdx {
          currentRecordIdx += 1;
        };
        i += 1;
      };
      return true;
    };
    return false;
  }

  private final func GetVehicleIDFromHeatStage(heatStage: EPreventionHeatStage, out vehicleID: TweakDBID) -> Bool {
    let heatData: wref<PreventionHeatData_Record>;
    if IsDefined(this.m_preventionPreset) {
      switch heatStage {
        case EPreventionHeatStage.Heat_0:
          return false;
        case EPreventionHeatStage.Heat_1:
          heatData = this.m_preventionPreset.Heat1();
          break;
        case EPreventionHeatStage.Heat_2:
          heatData = this.m_preventionPreset.Heat2();
          break;
        case EPreventionHeatStage.Heat_3:
          heatData = this.m_preventionPreset.Heat3();
          break;
        case EPreventionHeatStage.Heat_4:
          heatData = this.m_preventionPreset.Heat4();
          break;
        default:
          return false;
      };
      if IsDefined(heatData) && IsDefined(heatData.VehicleRecord()) {
        vehicleID = heatData.VehicleRecord().GetID();
      };
    };
    return TDBID.IsValid(vehicleID);
  }

  private final func ShouldSpawnVehicle() -> Bool {
    return false;
  }

  private final func SpawnPoliceVehicle(heatStage: EPreventionHeatStage) -> Void {
    let spawnPosition: Vector4;
    let spawnTransform: WorldTransform;
    let vehicleID: TweakDBID;
    if !this.GetVehicleIDFromHeatStage(heatStage, vehicleID) {
      return;
    };
    if GameInstance.GetAINavigationSystem(this.GetGameInstance()).GetFurthestNavmeshPointBehind(this.m_player, 3.00, 3, spawnPosition, -this.m_player.GetWorldForward() * 3.00, true) {
      WorldTransform.SetPosition(spawnTransform, spawnPosition);
      WorldTransform.SetOrientationFromDir(spawnTransform, this.m_player.GetWorldForward());
      GameInstance.GetPreventionSpawnSystem(this.GetGameInstance()).RequestSpawn(vehicleID, EnumInt(heatStage), spawnTransform);
    };
  }

  private final func OnSpawnUnitDelayRequest(request: ref<PreventionDelayedSpawnUnitRequest>) -> Void {
    if EnumInt(this.m_heatStage) >= Cast(request.preventionLevel) {
      GameInstance.GetPreventionSpawnSystem(this.GetGameInstance()).RequestSpawn(request.recordID, request.preventionLevel, request.spawnTransform);
    };
  }

  private final func GetFindSpawnPointsOrigin(out pos: Vector4, out dir: Vector4) -> Void {
    let offsetDist: Float;
    let vehSpeed: Float;
    let vehicle: wref<VehicleObject>;
    dir = this.m_player.GetWorldForward();
    if VehicleComponent.GetVehicle(this.m_player.GetGame(), this.m_player, vehicle) {
      vehSpeed = vehicle.GetBlackboard().GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue);
      if vehSpeed > 0.50 {
        offsetDist = LerpF(vehSpeed / 30.00, 20.00, 60.00, true);
        pos = pos + offsetDist * vehicle.GetWorldForward();
        dir *= -1.00;
      };
    } else {
      pos = this.m_lastCrimePoint;
    };
  }

  private final func GetFindSpawnPointsOriginsData(out spawnOriginsData: array<SpawnOriginData>) -> Void {
    let currentOriginData: SpawnOriginData;
    let distanceToCheck: Float;
    let i: Int32;
    let offsetDist: Float;
    let pointData: ref<PointData>;
    let singleSortedResult: HandleWithValue;
    let sortedResults: array<HandleWithValue>;
    let vehSpeed: Float;
    let vehicle: wref<VehicleObject>;
    let viewerPos: Vector4;
    let playerForward: Vector4 = this.m_player.GetWorldForward();
    let playrPos: Vector4 = this.m_player.GetWorldPosition();
    if VehicleComponent.GetVehicle(this.m_player.GetGame(), this.m_player, vehicle) {
      vehSpeed = vehicle.GetBlackboard().GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue);
      if vehSpeed > 0.50 {
        offsetDist = LerpF(vehSpeed / 30.00, 20.00, 60.00, true);
        currentOriginData.position = playrPos + offsetDist * vehicle.GetWorldForward();
        currentOriginData.direction = playerForward * -1.00;
        currentOriginData.playerPosition = playrPos;
      } else {
        currentOriginData.position = playrPos;
        currentOriginData.direction = playerForward;
        currentOriginData.playerPosition = playrPos;
      };
      ArrayPush(spawnOriginsData, currentOriginData);
    } else {
      currentOriginData.position = playrPos;
      currentOriginData.direction = playerForward;
      currentOriginData.playerPosition = playrPos;
      ArrayPush(spawnOriginsData, currentOriginData);
      i = 0;
      while i < ArraySize(this.m_viewers) {
        viewerPos = this.m_viewers[i].GetWorldPosition();
        distanceToCheck = Vector4.Distance(playrPos, viewerPos);
        if distanceToCheck <= this.GetSpawnOriginMaxDistance() {
          pointData = new PointData();
          pointData.position = viewerPos;
          pointData.direction = playerForward;
          singleSortedResult.value = distanceToCheck;
          singleSortedResult.handle = pointData;
          ArrayPush(sortedResults, singleSortedResult);
        };
        i += 1;
      };
      if !Vector4.IsZero(this.m_lastCrimePoint) && NotEquals(this.m_lastCrimePoint, playrPos) {
        distanceToCheck = Vector4.Distance(playrPos, this.m_lastCrimePoint);
        if distanceToCheck <= this.GetSpawnOriginMaxDistance() {
          pointData = new PointData();
          pointData.position = this.m_lastCrimePoint;
          pointData.direction = playerForward;
          singleSortedResult.value = distanceToCheck;
          singleSortedResult.handle = pointData;
          ArrayPush(sortedResults, singleSortedResult);
        };
      };
      if !Vector4.IsZero(this.m_lastBodyPosition) && NotEquals(this.m_lastBodyPosition, this.m_lastCrimePoint) {
        distanceToCheck = Vector4.Distance(playrPos, this.m_lastBodyPosition);
        if distanceToCheck <= this.GetSpawnOriginMaxDistance() {
          pointData = new PointData();
          pointData.position = this.m_lastBodyPosition;
          pointData.direction = playerForward;
          singleSortedResult.value = distanceToCheck;
          singleSortedResult.handle = pointData;
          ArrayPush(sortedResults, singleSortedResult);
        };
      };
      if ArraySize(sortedResults) > 0 {
        SortHandleWithValueArray(sortedResults);
        i = 0;
        while i < ArraySize(sortedResults) {
          pointData = sortedResults[i].handle as PointData;
          if IsDefined(pointData) {
            currentOriginData.position = pointData.position;
            currentOriginData.direction = pointData.direction;
            currentOriginData.playerPosition = playrPos;
            ArrayPush(spawnOriginsData, currentOriginData);
          };
          i += 1;
        };
      };
    };
  }

  private final func DespawnAllPolice() -> Void {
    let i: Int32 = 0;
    while i <= EnumInt(EPreventionHeatStage.Size) {
      GameInstance.GetPreventionSpawnSystem(this.GetGameInstance()).RequestDespawnPreventionLevel(Cast(i));
      i += 1;
    };
  }

  public final static func IsChasingPlayer(game: GameInstance) -> Bool {
    let self: ref<PreventionSystem>;
    if !GameInstance.IsValid(game) {
      return false;
    };
    self = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
    if !IsDefined(self) {
      return false;
    };
    if self.IsChasingPlayer() {
      return true;
    };
    return false;
  }

  public final static func InjectPlayerAsPoliceTarget(police: ref<ScriptedPuppet>) -> Void {
    let m_command: ref<AIInjectCombatThreatCommand>;
    let nullArrayOfNames: array<CName>;
    let player: wref<GameObject>;
    if !IsDefined(police) {
      return;
    };
    if !PreventionSystem.IsChasingPlayer(police.GetGame()) {
      return;
    };
    player = GameInstance.GetPlayerSystem(police.GetGame()).GetLocalPlayerMainGameObject();
    if !IsDefined(player) {
      return;
    };
    m_command = new AIInjectCombatThreatCommand();
    m_command.targetPuppetRef = CreateEntityReference("#player", nullArrayOfNames);
    m_command.duration = 30.00;
    AIComponent.SendCommand(police, m_command);
  }

  private final func CheckDamageThreshold() -> Bool {
    if this.GetGeneralPercent() >= 1.00 || this.IsChasingPlayer() {
      return true;
    };
    if this.GetGeneralPercent() > 0.50 && !this.IsChasingPlayer() {
      return false;
    };
    return false;
  }

  private final func CalculateDeescaletion() -> Void {
    if !this.IsChasingPlayer() {
      this.AddGeneralPercent(-this.CalculateDeescalationPercent());
    };
  }

  private final func CalculateDeescalationPercent() -> Float {
    let timeBetween: Float = this.GetTimeBetweenStamp(this.m_gameTimeStampPrevious);
    if timeBetween - 45.00 < 0.00 {
      return 0.00;
    };
    timeBetween = this.GetTimeBetweenStamp(this.m_gameTimeStampPrevious) / 100.00;
    timeBetween /= 2.50;
    return timeBetween;
  }

  private final func GetTimeBetweenStamp(previousStamp: Float) -> Float {
    let timeBetween: Float = this.GetGameTimeStamp() - previousStamp;
    return timeBetween;
  }

  public final static func ShowMessage(gameInstance: GameInstance, message: String, time: Float) -> Void {
    let warningMsg: SimpleScreenMessage;
    warningMsg.isShown = true;
    warningMsg.duration = time;
    warningMsg.message = message;
    GameInstance.GetBlackboardSystem(gameInstance).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
  }

  private final func OnRefreshDistrict(request: ref<RefreshDistrictRequest>) -> Void {
    if !IsDefined(request.preventionPreset) {
      this.RestoreDefaultPreset();
    } else {
      this.m_preventionPreset = request.preventionPreset;
    };
    if !IsFinal() {
      this.RefreshDebugDistrictInfo();
    };
  }

  private final func RestoreDefaultConfig() -> Void {
    this.RestoreDefaultPreset();
  }

  private final func OnRegisterUnit(request: ref<RegisterUnitRequest>) -> Void {
    let i: Int32;
    if !IsDefined(request.unit) || NotEquals(request.unit.GetNPCType(), gamedataNPCType.Human) {
      return;
    };
    i = ArraySize(this.m_vehicles) - 1;
    while i >= 0 {
      if !this.MountVehicle(request.unit, this.m_vehicles[i]) {
        ArrayErase(this.m_vehicles, i);
      } else {
        goto 348;
      };
      i -= 1;
    };
  }

  private final func MountVehicle(unit: wref<ScriptedPuppet>, vehicle: wref<VehicleObject>) -> Bool {
    let evt: ref<MountAIEvent>;
    let mountData: ref<MountEventData>;
    let slotName: CName;
    if !IsDefined(unit) || !IsDefined(vehicle) {
      return false;
    };
    if !this.IsVehicleValid(vehicle, slotName) {
      return false;
    };
    mountData = new MountEventData();
    mountData.slotName = slotName;
    mountData.mountParentEntityId = vehicle.GetEntityID();
    mountData.isInstant = true;
    mountData.ignoreHLS = true;
    evt = new MountAIEvent();
    evt.name = n"Mount";
    evt.data = mountData;
    unit.QueueEvent(evt);
    return true;
  }

  private final func IsVehicleValid(vehicle: wref<VehicleObject>, out slotName: CName) -> Bool {
    if !IsDefined(vehicle) {
      return false;
    };
    if vehicle.IsDestroyed() {
      return false;
    };
    if VehicleComponent.GetNumberOfOccupiedSlots(vehicle.GetGame(), vehicle) >= 2 {
      return false;
    };
    if !VehicleComponent.GetFirstAvailableSlot(vehicle.GetGame(), vehicle, slotName) {
      return false;
    };
    return true;
  }

  private final func UpdateVehicles() -> Void {
    let slotName: CName;
    let i: Int32 = ArraySize(this.m_vehicles) - 1;
    while i >= 0 {
      if !this.IsVehicleValid(this.m_vehicles[i], slotName) {
        ArrayErase(this.m_vehicles, i);
      };
      i -= 1;
    };
  }

  private final func OnRegisterVehicle(request: ref<RegisterVehicleRequest>) -> Void {
    if !ArrayContains(this.m_vehicles, request.vehicle) {
      ArrayPush(this.m_vehicles, request.vehicle);
    };
  }

  protected final func OnViewerRequest(request: ref<PreventionVisibilityRequest>) -> Void {
    if !IsDefined(this.m_player) {
      return;
    };
    if request.seePlayer {
      this.ViewerRegister(request.requester);
      this.SetNewLastCrimePoint(this.m_player.GetWorldPosition());
    } else {
      this.ViewerUnRegister(request.requester);
    };
  }

  protected final func OnVehicleStolenRequest(request: ref<PreventionVehicleStolenRequest>) -> Void {
    if !this.CanPreventionReactToInput() {
      return;
    };
    if NotEquals(request.vehicleAffiliation, gamedataAffiliation.NCPD) {
      return;
    };
    if !this.IsChasingPlayer() {
      this.AddGeneralPercent(1.00);
      this.HeatPipeline();
    } else {
      this.ResetDeescalationZero();
    };
  }

  protected final func OnCombatStartedRequest(request: ref<PreventionCombatStartedRequest>) -> Void {
    if !this.CanPreventionReactToInput() {
      return;
    };
    if !this.IsChasingPlayer() {
      this.AddGeneralPercent(1.00);
      this.HeatPipeline(this.ShouldSkipSpawning(request.requester as ScriptedPuppet));
      this.CreateCrowdNullArea(request.requesterPosition);
    } else {
      this.ResetDeescalationZero();
    };
    this.SetNewLastCrimePoint(request.requesterPosition);
  }

  protected final func OnCrimeWitnessRequest(request: ref<PreventionCrimeWitnessRequest>) -> Void {
    if !this.CanPreventionReactToInput() {
      return;
    };
    if !this.IsChasingPlayer() {
      this.AddGeneralPercent(1.00);
      this.HeatPipeline();
    } else {
      this.ResetDeescalationZero();
    };
    this.SetNewLastCrimePoint(request.criminalPosition);
  }

  private final func UpdateViewers() -> Bool {
    let i: Int32;
    if ArraySize(this.m_viewers) <= 0 {
      this.HasViewersChanged(false);
      return false;
    };
    i = ArraySize(this.m_viewers) - 1;
    while i >= 0 {
      if !IsDefined(this.m_viewers[i]) || !this.m_viewers[i].IsActive() {
        ArrayErase(this.m_viewers, i);
      };
      i -= 1;
    };
    if ArraySize(this.m_viewers) <= 0 {
      this.HasViewersChanged(false);
      return false;
    };
    this.HasViewersChanged(true);
    return true;
  }

  private final func HasViewersChanged(currentViewerState: Bool) -> Void {
    if NotEquals(currentViewerState, this.m_hasViewers) {
      this.m_hasViewers = currentViewerState;
      this.OnViewersStateChanged();
    };
  }

  private final func OnViewersStateChanged() -> Void {
    if this.AreTurretsActive() {
      this.SetAgentsSupport(this.m_hasViewers);
    };
  }

  private final func ViewerRegister(viewer: wref<GameObject>) -> Void {
    if !IsDefined(viewer) {
      return;
    };
    this.SetNewLastCrimePoint(this.m_player.GetWorldPosition());
    if !ArrayContains(this.m_viewers, viewer) {
      ArrayPush(this.m_viewers, viewer);
    };
  }

  private final func ViewerUnRegister(viewer: wref<GameObject>) -> Void {
    ArrayRemove(this.m_viewers, viewer);
  }

  protected final func OnRegisterRequest(request: ref<PreventionRegisterRequest>) -> Void {
    if request.register {
      this.Register(request.attitudeGroup, request.requester);
    } else {
      this.UnRegister(request.attitudeGroup, request.requester);
    };
  }

  private final func Register(attitudeGroup: CName, ps: wref<PersistentState>) -> Void {
    let newGroup: ref<PreventionAgents>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_agentGroupsList) {
      if Equals(this.m_agentGroupsList[i].GetGroupName(), attitudeGroup) {
        if !this.m_agentGroupsList[i].IsAgentalreadyAdded(ps) {
          this.m_agentGroupsList[i].AddAgent(ps);
        };
        if this.AreTurretsActive() {
          this.WakeUpAgent(ps, true);
        } else {
          this.WakeUpAgent(ps, false);
        };
        return;
      };
      i += 1;
    };
    if IsNameValid(attitudeGroup) {
      newGroup = new PreventionAgents();
      newGroup.CreateGroup(attitudeGroup, ps);
      ArrayPush(this.m_agentGroupsList, newGroup);
    };
  }

  private final func UnRegister(attitudeGroup: CName, ps: wref<PersistentState>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_agentGroupsList) {
      if Equals(this.m_agentGroupsList[i].GetGroupName(), attitudeGroup) {
        this.m_agentGroupsList[i].RemoveAgent(ps);
        if !this.m_agentGroupsList[i].HasAgents() {
          ArrayRemove(this.m_agentGroupsList, this.m_agentGroupsList[i]);
        } else {
          i += 1;
        };
      } else {
      };
      i += 1;
    };
  }

  protected final func OnPreventionSecurityAreaRequest(request: ref<PreventionSecurityAreaRequest>) -> Void {
    if request.playerIsIn {
      if !ArrayContains(this.m_playerIsInSecurityArea, request.areaID) {
        ArrayPush(this.m_playerIsInSecurityArea, request.areaID);
      };
    } else {
      if ArrayContains(this.m_playerIsInSecurityArea, request.areaID) {
        ArrayRemove(this.m_playerIsInSecurityArea, request.areaID);
      };
    };
    this.ReevaluateSecurityAreaReset();
    if !IsFinal() {
      this.RefreshDebugSecAreaInfo();
    };
  }

  protected final func OnPreventionPoliceSecuritySystemRequest(request: ref<PreventionPoliceSecuritySystemRequest>) -> Void {
    let removeFromBlacklist: ref<RemoveFromBlacklistEvent>;
    if !ArrayContains(this.m_policeSecuritySystems, request.securitySystemID) {
      ArrayPush(this.m_policeSecuritySystems, request.securitySystemID);
      if IsDefined(this.m_player) && !this.IsChasingPlayer() {
        removeFromBlacklist = new RemoveFromBlacklistEvent();
        removeFromBlacklist.entityIDToRemove = this.m_player.GetEntityID();
        GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(request.securitySystemID, n"SecuritySystemControllerPS", removeFromBlacklist);
      };
    };
  }

  public final const func ShouldReactionBeAggressive() -> Bool {
    if this.IsChasingPlayer() {
      return true;
    };
    if ArraySize(this.m_playerIsInSecurityArea) > 0 {
      return false;
    };
    if !this.CanPreventionReactToInput() {
      return false;
    };
    return true;
  }

  public final static func ShouldReactionBeAgressive(game: GameInstance) -> Bool {
    let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
    if IsDefined(preventionSystem) {
      return preventionSystem.ShouldReactionBeAggressive();
    };
    return true;
  }

  public final static func CanPreventionReact(game: GameInstance) -> Bool {
    let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
    if IsDefined(preventionSystem) {
      return preventionSystem.CanPreventionReactToInput();
    };
    return true;
  }

  public final static func ShouldPreventionSystemReactToKill(puppet: wref<ScriptedPuppet>) -> Bool {
    if !IsDefined(puppet) || puppet.IsIncapacitated() {
      return false;
    };
    if NPCManager.HasTag(puppet.GetRecordID(), n"DoNotTriggerPrevention") {
      return false;
    };
    if puppet.IsCrowd() || puppet.IsVendor() || puppet.IsCharacterCivilian() || puppet.IsPrevention() || NPCManager.HasTag(puppet.GetRecordID(), n"TriggerPrevention") {
      return true;
    };
    return false;
  }

  public final static func ShouldPreventionSystemReactToDamageDealt(puppet: wref<ScriptedPuppet>) -> Bool {
    if !IsDefined(puppet) || !puppet.IsActive() {
      return false;
    };
    if puppet.IsPrevention() || NPCManager.HasTag(puppet.GetRecordID(), n"TriggerPrevention") {
      return true;
    };
    return false;
  }

  public final static func ShouldPreventionSystemReactToCombat(puppet: wref<ScriptedPuppet>) -> Bool {
    if !IsDefined(puppet) || puppet.IsIncapacitated() {
      return false;
    };
    if puppet.IsPrevention() || NPCManager.HasTag(puppet.GetRecordID(), n"TriggerPrevention") {
      return true;
    };
    return false;
  }

  private final func OnBountyResetRequest(request: ref<BountyResetRequest>) -> Void {
    this.execInstructionSafe();
  }

  protected cb func OnPlayerChoice(value: Variant) -> Bool {
    let attemptedChoice: InteractionAttemptedChoice = FromVariant(value);
    if attemptedChoice.isSuccess && Equals(attemptedChoice.visualizerType, EVisualizerType.Dialog) {
      this.execInstructionSafe();
    };
  }

  private final func OnDistrictAreaEntered(request: ref<DistrictEnteredEvent>) -> Void {
    if IsDefined(this.m_districtManager) {
      this.m_districtManager.Update(request);
    };
  }

  private final func RestoreDefaultPreset() -> Void {
    this.m_preventionPreset = TweakDBInterface.GetDistrictPreventionDataRecord(t"PreventionData.NCPD");
  }

  private final func ChangeAgentsAttitude(desiredAffiliation: EAIAttitude) -> Void {
    let groupName: CName;
    let i: Int32;
    let playerAttitude: CName;
    let spawnedEntities: array<wref<Entity>>;
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
    if !IsDefined(player) {
      return;
    };
    playerAttitude = player.GetAttitudeAgent().GetAttitudeGroup();
    GameInstance.GetAttitudeSystem(this.GetGameInstance()).SetAttitudeGroupRelationPersistent(n"police", playerAttitude, desiredAffiliation);
    i = 0;
    while i < ArraySize(this.m_agentGroupsList) {
      groupName = this.m_agentGroupsList[i].GetGroupName();
      if !CanChangeAttitudeRelationFor(groupName) {
      } else {
        GameInstance.GetAttitudeSystem(this.GetGameInstance()).SetAttitudeGroupRelationPersistent(groupName, playerAttitude, desiredAffiliation);
      };
      i += 1;
    };
    GameInstance.GetCompanionSystem(this.GetGameInstance()).GetSpawnedEntities(spawnedEntities);
    i = 0;
    while i < ArraySize(spawnedEntities) {
      this.ChangeAttitude(spawnedEntities[i] as GameObject, player, desiredAffiliation);
      i += 1;
    };
  }

  private final func ChangeAttitude(owner: wref<GameObject>, target: wref<GameObject>, desiredAttitude: EAIAttitude) -> Void {
    let attitudeOwner: ref<AttitudeAgent>;
    let attitudeTarget: ref<AttitudeAgent>;
    if !IsDefined(owner) || !IsDefined(target) {
      return;
    };
    attitudeOwner = owner.GetAttitudeAgent();
    attitudeTarget = target.GetAttitudeAgent();
    if !IsDefined(attitudeOwner) || !IsDefined(attitudeTarget) {
      return;
    };
    attitudeOwner.SetAttitudeTowards(attitudeTarget, desiredAttitude);
  }

  private final func WakeUpAllAgents(wakeUp: Bool) -> Void {
    let i1: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_agentGroupsList) {
      i1 = 0;
      while i1 < this.m_agentGroupsList[i].GetAgentsNumber() {
        this.WakeUpAgent(this.m_agentGroupsList[i].GetAgetntByIndex(i1), wakeUp);
        i1 += 1;
      };
      i += 1;
    };
  }

  private final func WakeUpAgent(ps: wref<PersistentState>, wakeUp: Bool) -> Void {
    let evt: ref<ReactoToPreventionSystem> = new ReactoToPreventionSystem();
    evt.wakeUp = wakeUp;
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(ps.GetID(), ps.GetClassName(), evt);
    if wakeUp {
      this.SetSingleAgentSupport(ps, this.m_hasViewers);
    } else {
      this.SetSingleAgentSupport(ps, false);
    };
  }

  private final func SetAgentsSupport(hasSupport: Bool) -> Void {
    let i1: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_agentGroupsList) {
      i1 = 0;
      while i1 < this.m_agentGroupsList[i].GetAgentsNumber() {
        this.SetSingleAgentSupport(this.m_agentGroupsList[i].GetAgetntByIndex(i1), hasSupport);
        i1 += 1;
      };
      i += 1;
    };
  }

  private final func SetSingleAgentSupport(ps: wref<PersistentState>, hasSupport: Bool) -> Void {
    let evt: ref<SecuritySystemSupport>;
    if !PersistentID.IsDefined(ps.GetID()) {
      return;
    };
    evt = new SecuritySystemSupport();
    evt.supportGranted = hasSupport;
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(ps.GetID(), ps.GetClassName(), evt);
  }

  private final func StartPreventionTickRequest() -> Void {
    let request: ref<PreventionTickRequest>;
    if !this.m_preventionTickCheck && this.IsChasingPlayer() {
      request = new PreventionTickRequest();
      this.m_preventionTickDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"PreventionSystem", request, 0.30);
      this.m_preventionTickCheck = true;
      if !IsFinal() {
        this.RefreshDebugEvents();
      };
    };
  }

  private final func CancelPreventionTickRequest() -> Void {
    if this.m_preventionTickCheck {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelCallback(this.m_preventionTickDelayID);
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_preventionTickDelayID);
      this.m_preventionTickCheck = false;
      if !IsFinal() {
        this.RefreshDebugEvents();
      };
    };
  }

  private final func OnPreventionTickRequest(request: ref<PreventionTickRequest>) -> Void {
    if this.IsChasingPlayer() {
      if this.UpdateViewers() {
        this.SetNewLastCrimePoint(this.m_player.GetWorldPosition());
      };
      this.CheckLastCrimeDistanceToPlayer();
      StimBroadcasterComponent.BroadcastStim(this.m_player, gamedataStimType.CrimeWitness);
    };
    this.WhipeHitNPC();
    this.m_preventionTickCheck = false;
    if !IsFinal() {
      this.RefreshDebugEvents();
    };
    this.StartPreventionTickRequest();
  }

  private final func ReevaluateSecurityAreaReset() -> Void {
    if EnumInt(this.m_playerHLS) > EnumInt(gamePSMHighLevel.SceneTier1) && EnumInt(this.m_playerHLS) <= EnumInt(gamePSMHighLevel.SceneTier5) {
      this.StartSecurityAreaResetRequest(2.00);
    } else {
      if ArraySize(this.m_playerIsInSecurityArea) > 0 {
        this.StartSecurityAreaResetRequest(4.00);
      } else {
        this.CancelSecurityAreaResetRequest();
      };
    };
  }

  private final func StartSecurityAreaResetRequest(opt resetDelay: Float) -> Void {
    let request: ref<SecurityAreaResetRequest>;
    if !this.IsChasingPlayer() {
      return;
    };
    if this.m_securityAreaResetCheck {
      return;
    };
    request = new SecurityAreaResetRequest();
    if resetDelay <= 0.00 {
      resetDelay = 5.00;
    };
    this.m_securityAreaResetDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"PreventionSystem", request, resetDelay);
    this.ResolveBlinkingStack(n"securityArea", true);
    this.m_securityAreaResetCheck = true;
    if this.CancelSpawnDelay() {
      this.m_hadOngoingSpawnRequest = true;
    };
    if !IsFinal() {
      this.RefreshDebugEvents();
    };
  }

  private final func CancelSecurityAreaResetRequest() -> Void {
    if !this.m_securityAreaResetCheck {
      return;
    };
    GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_securityAreaResetDelayID);
    this.ResolveBlinkingStack(n"securityArea", false);
    this.m_securityAreaResetCheck = false;
    if this.m_hadOngoingSpawnRequest {
      this.m_hadOngoingSpawnRequest = false;
      this.SpawnPipeline(this.m_heatStage, 5.00);
    };
    if !IsFinal() {
      this.RefreshDebugEvents();
    };
  }

  private final func OnSecurityAreaResetRequest(request: ref<SecurityAreaResetRequest>) -> Void {
    this.m_securityAreaResetCheck = false;
    this.execInstructionSafe();
  }

  private final func CheckLastCrimeDistanceToPlayer() -> Void {
    let blinkDistance: Float;
    let currentDistance: Float;
    let safeDistance: Float;
    if Vector4.IsZero(this.m_lastCrimePoint) {
      return;
    };
    currentDistance = Vector4.Distance(this.m_player.GetWorldPosition(), this.m_lastCrimePoint);
    this.m_DEBUG_lastCrimeDistance = currentDistance;
    safeDistance = this.GetSafeDistance();
    blinkDistance = safeDistance - this.GetBlinkThreshold();
    if blinkDistance < currentDistance {
      this.ResolveBlinkingStack(n"distanceCheck", true);
    } else {
      this.ResolveBlinkingStack(n"distanceCheck", false);
    };
    if safeDistance < currentDistance {
      this.execInstructionSafe();
    };
    if !IsFinal() {
      this.RefreshDebugDistanceInfo();
    };
  }

  private final func CheckifNewPointIsCloserThanPrevious(oldValue: Vector4, newValue: Vector4) -> Bool {
    if Vector4.IsZero(oldValue) {
      return true;
    };
    if Vector4.Distance(this.m_player.GetWorldPosition(), newValue) < Vector4.Distance(this.m_player.GetWorldPosition(), oldValue) {
      return true;
    };
    return false;
  }

  private final func CreateCrowdNullArea(targetPos: Vector4) -> Void {
    let box: Box;
    let distance: Float;
    let minMaxPoint: Vector4;
    let position: WorldTransform;
    return;
  }

  private final func CancelAllDelayedEvents() -> Void {
    this.CancelSpawnDelay();
    this.CancelPreventionTickRequest();
    this.CancelSecurityAreaResetRequest();
    this.StopDeescalationZero();
  }

  private final func ResolveBlinkingStack(reasonName: CName, active: Bool) -> Void {
    if !this.IsChasingPlayer() {
      this.WhipeBlinkData();
      return;
    };
    if active {
      if !ArrayContains(this.m_blinkReasonsStack, reasonName) {
        if ArraySize(this.m_blinkReasonsStack) == 0 {
          WantedBarGameController.FlashWantedBar(this.GetGameInstance());
        };
        ArrayPush(this.m_blinkReasonsStack, reasonName);
      };
    } else {
      if !ArrayContains(this.m_blinkReasonsStack, reasonName) {
        return;
      };
      ArrayRemove(this.m_blinkReasonsStack, reasonName);
      if ArraySize(this.m_blinkReasonsStack) == 0 {
        WantedBarGameController.FlashAndShowWantedBar(this.GetGameInstance());
      };
    };
  }

  private final func WhipeBlinkData() -> Void {
    ArrayClear(this.m_blinkReasonsStack);
    WantedBarGameController.EndFlashWantedBar(this.GetGameInstance());
    return;
  }

  private final func OnTogglePreventionSystem(evt: ref<TogglePreventionSystem>) -> Void {
    if !IsNameValid(evt.sourceName) {
      return;
    };
    this.RefreshDebugRemoveAllLockSources();
    if evt.isActive {
      if ArrayContains(this.m_systemLockSources, evt.sourceName) {
        ArrayRemove(this.m_systemLockSources, evt.sourceName);
        if ArraySize(this.m_systemLockSources) <= 0 {
          this.execInstructionOn();
        };
      };
    } else {
      if !ArrayContains(this.m_systemLockSources, evt.sourceName) {
        ArrayPush(this.m_systemLockSources, evt.sourceName);
        if ArraySize(this.m_systemLockSources) > 0 {
          this.execInstructionOff();
        };
      };
    };
    this.RefreshDebugLockSources();
  }

  public final static func DelayedSpawnUnitRequest(context: GameInstance, recordID: TweakDBID, preventionLevel: Uint32, spawnTransform: WorldTransform, delay: Float) -> Void {
    let request: ref<PreventionDelayedSpawnUnitRequest>;
    if delay <= 0.00 {
      GameInstance.GetPreventionSpawnSystem(context).RequestSpawn(recordID, preventionLevel, spawnTransform);
      return;
    };
    request = new PreventionDelayedSpawnUnitRequest();
    request.recordID = recordID;
    request.preventionLevel = preventionLevel;
    request.spawnTransform = spawnTransform;
    PreventionSystem.QueueRequest(context, request, delay);
  }

  public final static func QueueRequest(context: GameInstance, request: ref<ScriptableSystemRequest>, opt delay: Float) -> Bool {
    let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    if IsDefined(preventionSystem) {
      if delay <= 0.00 {
        preventionSystem.QueueRequest(request);
      } else {
        GameInstance.GetDelaySystem(context).DelayScriptableSystemRequest(n"PreventionSystem", request, delay);
      };
      return true;
    };
    return false;
  }

  public final static func CreateNewDamageRequest(context: GameInstance, target: ref<GameObject>, damage: Float) -> Void {
    let preventionSystemRequest: ref<PreventionDamageRequest> = new PreventionDamageRequest();
    if IsDefined(target) {
      preventionSystemRequest.targetID = target.GetEntityID();
      preventionSystemRequest.targetPosition = target.GetWorldPosition();
      preventionSystemRequest.isTargetPrevention = target.IsPrevention();
      preventionSystemRequest.isTargetAlive = target.IsActive();
    };
    preventionSystemRequest.damagePercentValue = damage;
    GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem").QueueRequest(preventionSystemRequest);
  }

  public final static func RegisterToPreventionSystem(context: GameInstance, requester: ref<Device>) -> Void {
    let request: ref<PreventionRegisterRequest> = new PreventionRegisterRequest();
    request.requester = requester.GetDevicePS();
    request.attitudeGroup = requester.GetAttitudeAgent().GetAttitudeGroup();
    request.register = true;
    GameInstance.QueueScriptableSystemRequest(context, n"PreventionSystem", request);
  }

  public final static func UnRegisterToPreventionSystem(context: GameInstance, requester: ref<Device>) -> Void {
    let request: ref<PreventionRegisterRequest> = new PreventionRegisterRequest();
    request.requester = requester.GetDevicePS();
    request.attitudeGroup = requester.GetAttitudeAgent().GetAttitudeGroup();
    request.register = false;
    GameInstance.QueueScriptableSystemRequest(context, n"PreventionSystem", request);
  }

  public final static func RegisterAsViewerToPreventionSystem(context: GameInstance, requester: ref<GameObject>) -> Void {
    let request: ref<PreventionVisibilityRequest>;
    let self: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    if EnumInt(self.GetHeatStage()) == 0 {
      return;
    };
    request = new PreventionVisibilityRequest();
    request.requester = requester;
    request.seePlayer = true;
    GameInstance.QueueScriptableSystemRequest(context, n"PreventionSystem", request);
  }

  public final static func UnRegisterAsViewerToPreventionSystem(context: GameInstance, requester: ref<GameObject>) -> Void {
    let request: ref<PreventionVisibilityRequest>;
    let self: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    if EnumInt(self.GetHeatStage()) == 0 {
      return;
    };
    request = new PreventionVisibilityRequest();
    request.requester = requester;
    request.seePlayer = false;
    self.QueueRequest(request);
  }

  public final static func CombatStartedRequestToPreventionSystem(context: GameInstance, requester: wref<GameObject>) -> Void {
    let request: ref<PreventionCombatStartedRequest>;
    let self: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    if IsDefined(self) {
      request = new PreventionCombatStartedRequest();
      request.requesterPosition = requester.GetWorldPosition();
      request.requester = requester;
      self.QueueRequest(request);
    };
  }

  public final static func VehicleStolenRequestToPreventionSystem(vehicle: wref<VehicleObject>, opt thief: wref<GameObject>) -> Void {
    let request: ref<PreventionVehicleStolenRequest>;
    let self: ref<PreventionSystem>;
    let vehicleRecord: ref<Vehicle_Record>;
    if !IsDefined(vehicle) {
      return;
    };
    self = GameInstance.GetScriptableSystemsContainer(vehicle.GetGame()).Get(n"PreventionSystem") as PreventionSystem;
    if !IsDefined(self) {
      return;
    };
    if !VehicleComponent.GetVehicleRecord(vehicle, vehicleRecord) {
      return;
    };
    request = new PreventionVehicleStolenRequest();
    request.requesterPosition = vehicle.GetWorldPosition();
    if IsDefined(vehicleRecord.Affiliation()) {
      request.vehicleAffiliation = vehicleRecord.Affiliation().Type();
    };
    self.QueueRequest(request);
  }

  public final static func CrimeWitnessRequestToPreventionSystem(context: GameInstance, criminalPosition: Vector4) -> Void {
    let self: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    let request: ref<PreventionCrimeWitnessRequest> = new PreventionCrimeWitnessRequest();
    request.criminalPosition = criminalPosition;
    self.QueueRequest(request);
  }

  public final static func PreventionSecurityAreaEnterRequest(context: GameInstance, playerIsIn: Bool, areaID: PersistentID) -> Void {
    let request: ref<PreventionSecurityAreaRequest>;
    let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    if IsDefined(preventionSystem) {
      request = new PreventionSecurityAreaRequest();
      request.playerIsIn = playerIsIn;
      request.areaID = areaID;
      preventionSystem.QueueRequest(request);
    };
  }

  public final static func PreventionPoliceSecuritySystemRequest(context: GameInstance, securitySystemID: PersistentID) -> Void {
    let request: ref<PreventionPoliceSecuritySystemRequest>;
    let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    if IsDefined(preventionSystem) {
      request = new PreventionPoliceSecuritySystemRequest();
      request.securitySystemID = securitySystemID;
      preventionSystem.QueueRequest(request);
    };
  }

  public final static func PreventionBountyResetRequest(context: GameInstance) -> Void {
    let request: ref<BountyResetRequest>;
    let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"PreventionSystem") as PreventionSystem;
    if IsDefined(preventionSystem) && preventionSystem.IsChasingPlayer() {
      request = new BountyResetRequest();
      preventionSystem.QueueRequest(request);
    };
  }

  public final static func RegisterPoliceUnit(context: GameInstance, unit: wref<ScriptedPuppet>) -> Void {
    let request: ref<RegisterUnitRequest>;
    if IsDefined(unit) {
      PreventionSystem.InjectPlayerAsPoliceTarget(unit);
      request = new RegisterUnitRequest();
      request.unit = unit;
      PreventionSystem.QueueRequest(unit.GetGame(), request);
    };
  }

  public final static func RegisterPoliceVehicle(context: GameInstance, vehicle: wref<VehicleObject>) -> Void {
    let request: ref<RegisterVehicleRequest>;
    if IsDefined(vehicle) {
      request = new RegisterVehicleRequest();
      request.vehicle = vehicle;
      PreventionSystem.QueueRequest(vehicle.GetGame(), request);
    };
  }

  protected final func OnPreventionConsoleInstructionRequest(request: ref<PreventionConsoleInstructionRequest>) -> Void {
    switch request.instruction {
      case EPreventionSystemInstruction.Safe:
        this.execInstructionSafe();
        break;
      case EPreventionSystemInstruction.Active:
        this.execInstructionActive();
        break;
      case EPreventionSystemInstruction.On:
        this.execInstructionOn();
        break;
      case EPreventionSystemInstruction.Off:
        this.execInstructionOff();
        break;
      default:
    };
  }

  private final func RemovePlayerFromSecuritySystemBlacklist() -> Void {
    let i: Int32;
    let removeFromBlacklist: ref<RemoveFromBlacklistEvent>;
    if !IsDefined(this.m_player) {
      return;
    };
    removeFromBlacklist = new RemoveFromBlacklistEvent();
    removeFromBlacklist.entityIDToRemove = this.m_player.GetEntityID();
    i = 0;
    while i < ArraySize(this.m_policeSecuritySystems) {
      if PersistentID.IsDefined(this.m_policeSecuritySystems[i]) {
        GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.m_policeSecuritySystems[i], n"SecuritySystemControllerPS", removeFromBlacklist);
      };
      i += 1;
    };
  }

  private final func execInstructionSafe() -> Void {
    if !this.IsChasingPlayer() {
      return;
    };
    this.m_systemDisabled = false;
    this.WhipeBlinkData();
    this.ChangeAgentsAttitude(EAIAttitude.AIA_Neutral);
    this.WakeUpAllAgents(false);
    this.WhipeHitNPC();
    this.DespawnAllPolice();
    this.RemovePlayerFromSecuritySystemBlacklist();
    this.CancelAllDelayedEvents();
    this.m_generalPercent = 0.00;
    if this.SetHeatStage(EPreventionHeatStage.Heat_0) {
      this.OnHeatChanged();
    };
  }

  private final func execInstructionActive() -> Void {
    this.m_systemDisabled = false;
    this.SendInternalSystem(1000.00);
  }

  private final func SendInternalSystem(damageValue: Float) -> Void {
    this.m_systemDisabled = false;
    let preventionSystemRequest: ref<PreventionDamageRequest> = new PreventionDamageRequest();
    preventionSystemRequest.damagePercentValue = damageValue;
    preventionSystemRequest.isInternal = true;
    this.QueueRequest(preventionSystemRequest);
  }

  private final func execInstructionOn() -> Void {
    this.m_systemDisabled = false;
    if !IsFinal() {
      this.RefreshDebug();
    };
  }

  private final func execInstructionOff() -> Void {
    this.execInstructionSafe();
    this.m_systemDisabled = true;
    if !IsFinal() {
      this.RefreshDebug();
    };
  }

  private final func RefreshDebug() -> Void {
    let district: wref<District>;
    let i: Int32;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    SDOSink.PushString(sink, "Heat", EnumValueToString("EPreventionHeatStage", Cast(EnumInt(this.m_heatStage))));
    SDOSink.PushBool(sink, "Is marked as psycho", this.IsChasingPlayer());
    if this.IsChasingPlayer() {
      SDOSink.SetKeyColor(sink, "Is marked as psycho", new Color(255u, 0u, 0u, 255u));
    } else {
      SDOSink.SetKeyColor(sink, "Is marked as psycho", new Color(0u, 255u, 0u, 255u));
    };
    SDOSink.PushString(sink, "----DISTRICT----", "---------DISTRICT---------");
    SDOSink.SetKeyColor(sink, "----DISTRICT----", new Color(100u, 200u, 100u, 255u));
    district = this.m_districtManager.GetCurrentDistrict();
    if IsDefined(district) {
      SDOSink.PushString(sink, "District", TDBID.ToStringDEBUG(district.GetDistrictID()));
      SDOSink.PushString(sink, "Preset", TDBID.ToStringDEBUG(district.GetPresetID()));
    };
    SDOSink.PushString(sink, "----REACTION---", "---------TYPE---------");
    SDOSink.SetKeyColor(sink, "----REACTION---", new Color(100u, 100u, 200u, 255u));
    SDOSink.PushString(sink, "ProcessInfo", EnumValueToString("EPreventionDebugProcessReason", Cast(EnumInt(this.Debug_PorcessReason))));
    SDOSink.PushString(sink, "----ACTIVE----", "---------ACTIVE---------");
    SDOSink.SetKeyColor(sink, "----ACTIVE----", new Color(100u, 100u, 100u, 255u));
    SDOSink.PushFloat(sink, "General percent (0-1)", this.GetGeneralPercent());
    SDOSink.PushBool(sink, "Should reaction be aggressive", this.ShouldReactionBeAggressive());
    SDOSink.PushBool(sink, "Player is in seciurity area", ArraySize(this.m_playerIsInSecurityArea) > 0);
    SDOSink.PushFloat(sink, "Threshold", this.GetDamagePercentThreshold());
    SDOSink.PushFloat(sink, "New damage percent", this.GetNewDamageValue());
    SDOSink.PushFloat(sink, "Part percent", this.GetPartGeneralPercent());
    SDOSink.PushString(sink, "----DISTANCE----", "---------DISTANCE---------");
    SDOSink.SetKeyColor(sink, "----DISTANCE----", new Color(0u, 0u, 0u, 0u));
    SDOSink.PushFloat(sink, "Distance", this.m_DEBUG_lastCrimeDistance);
    SDOSink.PushString(sink, "----EVENTS----", "---------EVENTS---------");
    SDOSink.SetKeyColor(sink, "----EVENTS----", new Color(255u, 255u, 255u, 255u));
    SDOSink.PushBool(sink, "deescalationZeroCheck", this.m_deescalationZeroCheck);
    SDOSink.PushBool(sink, "preventionTickCheck", this.m_preventionTickCheck);
    SDOSink.PushBool(sink, "securityAreaResetCheck", this.m_securityAreaResetCheck);
    i = 0;
    while i < ArraySize(this.m_systemLockSources) {
      SDOSink.PushName(sink, "sourceName" + i, this.m_systemLockSources[i]);
      i += 1;
    };
  }

  private final func RefreshDebugRemoveAllLockSources() -> Void {
    let i: Int32;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    i = 0;
    while i < ArraySize(this.m_systemLockSources) {
      SDOSink.PushName(sink, "locks/sourceName" + i, n"NONE - debug error ignore");
      i += 1;
    };
  }

  private final func RefreshDebugLockSources() -> Void {
    let i: Int32;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    i = 0;
    while i < ArraySize(this.m_systemLockSources) {
      SDOSink.PushName(sink, "locks/sourceName" + i, this.m_systemLockSources[i]);
      i += 1;
    };
  }

  private final func RefreshDebugEvents() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    SDOSink.PushString(sink, "----EVENTS----", "---------EVENTS---------");
    SDOSink.SetKeyColor(sink, "----EVENTS----", new Color(255u, 255u, 255u, 255u));
    SDOSink.PushBool(sink, "deescalationZeroCheck", this.m_deescalationZeroCheck);
    SDOSink.PushBool(sink, "preventionTickCheck", this.m_preventionTickCheck);
    SDOSink.PushBool(sink, "securityAreaResetCheck", this.m_securityAreaResetCheck);
  }

  private final func RefreshDebugProcessInfo() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    SDOSink.PushString(sink, "ProcessInfo", EnumValueToString("EPreventionDebugProcessReason", Cast(EnumInt(this.Debug_PorcessReason))));
  }

  private final func RefreshDebugDistanceInfo() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    SDOSink.PushFloat(sink, "Distance", this.m_DEBUG_lastCrimeDistance);
  }

  private final func RefreshDebugDistrictInfo() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    SDOSink.PushString(sink, "District", TDBID.ToStringDEBUG(this.m_districtManager.GetCurrentDistrict().GetDistrictID()));
    SDOSink.PushString(sink, "Preset", TDBID.ToStringDEBUG(this.m_districtManager.GetCurrentDistrict().GetPresetID()));
    SDOSink.PushFloat(sink, "Threshold", this.GetDamagePercentThreshold());
  }

  private final func RefreshDebugSecAreaInfo() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Prevention");
    SDOSink.PushBool(sink, "Player is in seciurity area", ArraySize(this.m_playerIsInSecurityArea) > 0);
  }
}

public class PreventionAgents extends IScriptable {

  private let m_groupName: CName;

  private let m_requsteredAgents: array<ref<SPreventionAgentData>>;

  public final func CreateGroup(groupName: CName, ps: wref<PersistentState>) -> Void {
    this.m_groupName = groupName;
    this.AddAgent(ps);
  }

  public final const func GetGroupName() -> CName {
    return this.m_groupName;
  }

  public final const func GetAgentsNumber() -> Int32 {
    return ArraySize(this.m_requsteredAgents);
  }

  public final const func GetAgetntByIndex(index: Int32) -> wref<PersistentState> {
    return this.m_requsteredAgents[index].ps;
  }

  public final const func IsAgentalreadyAdded(ps: wref<PersistentState>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_requsteredAgents) {
      if Equals(this.m_requsteredAgents[i].ps.GetID(), ps.GetID()) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasAgents() -> Bool {
    return ArraySize(this.m_requsteredAgents) > 0;
  }

  public final func AddAgent(ps: wref<PersistentState>) -> Void {
    let newData: ref<SPreventionAgentData> = new SPreventionAgentData();
    newData.ps = ps;
    ArrayPush(this.m_requsteredAgents, newData);
  }

  public final func RemoveAgent(ps: wref<PersistentState>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_requsteredAgents) {
      if Equals(this.m_requsteredAgents[i].ps.GetID(), ps.GetID()) {
        ArrayErase(this.m_requsteredAgents, i);
      } else {
        i += 1;
      };
    };
  }
}

public static func IntToEPreventionHeatStage(index: Int32) -> EPreventionHeatStage {
  if index < 0 {
    index = 0;
  };
  if index >= EnumInt(EPreventionHeatStage.Size) {
    index = EnumInt(EPreventionHeatStage.Size) - 1;
  };
  return IntEnum(index);
}

public static exec func PrevSys_on(gameInstance: GameInstance) -> Void {
  let request: ref<PreventionConsoleInstructionRequest>;
  let system: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PreventionSystem") as PreventionSystem;
  if IsDefined(system) {
    request = new PreventionConsoleInstructionRequest();
    request.instruction = EPreventionSystemInstruction.On;
    system.QueueRequest(request);
  };
}

public static exec func PrevSys_off(gameInstance: GameInstance) -> Void {
  let request: ref<PreventionConsoleInstructionRequest>;
  let system: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PreventionSystem") as PreventionSystem;
  if IsDefined(system) {
    request = new PreventionConsoleInstructionRequest();
    request.instruction = EPreventionSystemInstruction.Off;
    system.QueueRequest(request);
  };
}

public static exec func PrevSys_safe(gameInstance: GameInstance) -> Void {
  let request: ref<PreventionConsoleInstructionRequest>;
  let system: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PreventionSystem") as PreventionSystem;
  if IsDefined(system) {
    request = new PreventionConsoleInstructionRequest();
    request.instruction = EPreventionSystemInstruction.Safe;
    system.QueueRequest(request);
  };
}

public static exec func PrevSys_active(gameInstance: GameInstance) -> Void {
  let request: ref<PreventionConsoleInstructionRequest>;
  let system: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PreventionSystem") as PreventionSystem;
  if IsDefined(system) {
    request = new PreventionConsoleInstructionRequest();
    request.instruction = EPreventionSystemInstruction.Active;
    system.QueueRequest(request);
  };
}

public class ShouldPoliceReactionBeAggressive extends PreventionConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if AIBehaviorScriptBase.GetPuppet(context).IsPrevention() && !PreventionSystem.ShouldReactionBeAgressive(ScriptExecutionContext.GetOwner(context).GetGame()) {
      return Cast(false);
    };
    return Cast(true);
  }
}
