
public class VehicleComponentPS extends ScriptableDeviceComponentPS {

  protected persistent let m_defaultStateSet: Bool;

  protected persistent let m_stateModifiedByQuest: Bool;

  protected persistent let m_playerVehicle: Bool;

  protected let m_npcOccupiedSlots: array<CName>;

  protected persistent let m_isDestroyed: Bool;

  protected persistent let m_isStolen: Bool;

  protected persistent let m_crystalDomeQuestModified: Bool;

  protected persistent let m_crystalDomeQuestState: Bool;

  protected persistent let m_crystalDomeState: Bool;

  protected persistent let m_visualDestructionSet: Bool;

  protected persistent let m_visualDestructionNeeded: Bool;

  protected persistent let m_exploded: Bool;

  protected persistent let m_sirenOn: Bool;

  protected persistent let m_sirenSoundOn: Bool;

  protected persistent let m_sirenLightsOn: Bool;

  protected persistent let m_anyDoorOpen: Bool;

  protected persistent let m_previousInteractionState: array<TemporaryDoorState>;

  protected persistent let m_thrusterState: Bool;

  protected persistent let m_uiQuestModified: Bool;

  protected persistent let m_uiState: Bool;

  protected let m_vehicleSkillChecks: ref<EngDemoContainer>;

  public let m_ready: Bool;

  public let m_isPlayerPerformingBodyDisposal: Bool;

  private let m_vehicleControllerPS: ref<vehicleControllerPS>;

  private final func GetVehicleControllerPS() -> ref<vehicleControllerPS> {
    let persistentId: PersistentID;
    if this.m_vehicleControllerPS == null {
      persistentId = CreatePersistentID(this.GetMyEntityID(), n"VehicleController");
      this.m_vehicleControllerPS = this.GetPersistencySystem().GetConstAccessToPSObject(persistentId, n"gamevehicleControllerPS") as vehicleControllerPS;
    };
    return this.m_vehicleControllerPS;
  }

  private final const func GetVehicleControllerPSConst() -> ref<vehicleControllerPS> {
    let persistentId: PersistentID;
    if this.m_vehicleControllerPS == null {
      persistentId = CreatePersistentID(this.GetMyEntityID(), n"VehicleController");
      return this.GetPersistencySystem().GetConstAccessToPSObject(persistentId, n"gamevehicleControllerPS") as vehicleControllerPS;
    };
    return this.m_vehicleControllerPS;
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.InitializeTempDoorStateStruct();
    this.InitializeDoorInteractionState();
  }

  protected func GameAttached() -> Void {
    this.RefreshSkillchecks();
  }

  protected final const func GetOwnerEntity() -> wref<VehicleObject> {
    return GameInstance.FindEntityByID(this.GetGameInstance(), PersistentID.ExtractEntityID(this.GetID())) as VehicleObject;
  }

  public final func GetHasDefaultStateBeenSet() -> Bool {
    return this.m_defaultStateSet;
  }

  public final func SetHasDefaultStateBeenSet(set: Bool) -> Void {
    this.m_defaultStateSet = set;
  }

  public final func GetHasStateBeenModifiedByQuest() -> Bool {
    return this.m_stateModifiedByQuest;
  }

  public final func GetNpcOccupiedSlots() -> array<CName> {
    return this.m_npcOccupiedSlots;
  }

  public final func GetIsDestroyed() -> Bool {
    return this.m_isDestroyed;
  }

  public final func SetIsDestroyed(value: Bool) -> Void {
    this.m_isDestroyed = value;
  }

  public final func GetIsStolen() -> Bool {
    return this.m_isStolen;
  }

  public final func SetIsStolen(value: Bool) -> Void {
    this.m_isStolen = value;
  }

  public final func SetHasStateBeenModifiedByQuest(set: Bool) -> Void {
    this.m_stateModifiedByQuest = set;
  }

  public final func GetIsPlayerVehicle() -> Bool {
    return this.m_playerVehicle;
  }

  public final func SetIsPlayerVehicle(set: Bool) -> Void {
    this.m_playerVehicle = set;
  }

  public final func GetIsCrystalDomeQuestModified() -> Bool {
    return this.m_crystalDomeQuestModified;
  }

  public final func SetIsCrystalDomeQuestModified(value: Bool) -> Void {
    this.m_crystalDomeQuestModified = value;
  }

  public final func GetCrystalDomeQuestState() -> Bool {
    return this.m_crystalDomeQuestState;
  }

  public final func SetCrystalDomeQuestState(value: Bool) -> Void {
    this.m_crystalDomeQuestState = value;
  }

  public final func GetCrystalDomeState() -> Bool {
    return this.m_crystalDomeState;
  }

  public final func SetCrystalDomeState(value: Bool) -> Void {
    this.m_crystalDomeState = value;
  }

  public final func GetIsUiQuestModified() -> Bool {
    return this.m_uiQuestModified;
  }

  public final func SetIsUiQuestModified(value: Bool) -> Void {
    this.m_uiQuestModified = value;
  }

  public final func GetUiQuestState() -> Bool {
    return this.m_uiState;
  }

  public final func SetUiQuestState(value: Bool) -> Void {
    this.m_uiState = value;
  }

  public final func GetSirenState() -> Bool {
    return this.m_sirenOn;
  }

  public final func SetSirenState(value: Bool) -> Void {
    this.m_sirenOn = value;
  }

  public final func GetSirenLightsState() -> Bool {
    return this.m_sirenLightsOn;
  }

  public final func SetSirenLightsState(value: Bool) -> Void {
    this.m_sirenLightsOn = value;
  }

  public final func GetSirenSoundsState() -> Bool {
    return this.m_sirenSoundOn;
  }

  public final func SetSirenSoundsState(value: Bool) -> Void {
    this.m_sirenSoundOn = value;
  }

  public final func GetHasVisualDestructionBeenSet() -> Bool {
    return this.m_visualDestructionSet;
  }

  public final func SetHasVisualDestructionBeenSet(set: Bool) -> Void {
    this.m_visualDestructionSet = set;
  }

  public final func GetHasExploded() -> Bool {
    return this.m_exploded;
  }

  public final func SetHasExploded(set: Bool) -> Void {
    this.m_exploded = set;
  }

  public final func GetHasAnyDoorOpen() -> Bool {
    return this.m_anyDoorOpen;
  }

  public final func SetHasAnyDoorOpen(set: Bool) -> Void {
    this.m_anyDoorOpen = set;
  }

  public final func GetThrusterState() -> Bool {
    return this.m_thrusterState;
  }

  public final func SetThrusterState(set: Bool) -> Void {
    this.m_thrusterState = set;
  }

  public final func OnToggleVehicle(evt: ref<ToggleVehicle>) -> EntityNotificationType {
    let controllerPS: ref<vehicleControllerPS> = this.GetVehicleControllerPS();
    controllerPS.SetState(evt.GetValue() ? vehicleEState.On : vehicleEState.Default);
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnForceCarAlarm(evt: ref<ForceCarAlarm>) -> EntityNotificationType {
    let controllerPS: ref<vehicleControllerPS> = this.GetVehicleControllerPS();
    controllerPS.SetAlarm(true);
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnForceDisableCarAlarm(evt: ref<ForceDisableCarAlarm>) -> EntityNotificationType {
    let controllerPS: ref<vehicleControllerPS> = this.GetVehicleControllerPS();
    controllerPS.SetAlarm(false);
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func DisableAlarm() -> Void {
    let action: ref<ForceDisableCarAlarm> = this.ActionForceDisableCarAlarm();
    this.ExecutePSAction(action);
  }

  private final func InitializeTempDoorStateStruct() -> Void {
    let size: Int32 = Cast(EnumGetMax(n"EVehicleDoor")) + 1;
    ArrayResize(this.m_previousInteractionState, size);
  }

  private final func InitializeDoorInteractionState() -> Void {
    this.SetDoorInteractionState(EVehicleDoor.seat_back_left, VehicleDoorInteractionState.Disabled, "InitializeDoorInteractionState");
    this.SetDoorInteractionState(EVehicleDoor.seat_back_right, VehicleDoorInteractionState.Disabled, "InitializeDoorInteractionState");
  }

  protected final func RefreshSkillchecks() -> Void {
    let demoCheck: ref<DemolitionSkillCheck> = new DemolitionSkillCheck();
    let engCheck: ref<EngineeringSkillCheck> = new EngineeringSkillCheck();
    this.m_vehicleSkillChecks = new EngDemoContainer();
    let difficultyTDBID: TweakDBID = this.GetOwnerEntity().GetRecordID();
    TDBID.Append(difficultyTDBID, t".hijackDifficulty");
    demoCheck.m_difficulty = IntEnum(Cast(EnumValueFromName(n"EGameplayChallengeLevel", StringToName(TweakDBInterface.GetString(difficultyTDBID, "NONE")))));
    demoCheck.m_alternativeName = t"Interactions.HijackVehicle";
    this.m_vehicleSkillChecks.m_demolitionCheck = demoCheck;
    difficultyTDBID = this.GetOwnerEntity().GetRecordID();
    TDBID.Append(difficultyTDBID, t".crackLockDifficulty");
    engCheck.m_difficulty = IntEnum(Cast(EnumValueFromName(n"EGameplayChallengeLevel", StringToName(TweakDBInterface.GetString(difficultyTDBID, "NONE")))));
    engCheck.m_alternativeName = t"Interactions.VehicleCrackLock";
    this.m_vehicleSkillChecks.m_engineeringCheck = engCheck;
    this.InitializeSkillChecks(this.m_vehicleSkillChecks);
  }

  protected final func ChangeToActionContext(vehicleContext: VehicleActionsContext) -> GetActionsContext {
    let getActionsContext: GetActionsContext;
    getActionsContext.requestorID = vehicleContext.requestorID;
    getActionsContext.requestType = vehicleContext.requestType;
    getActionsContext.interactionLayerTag = vehicleContext.interactionLayerTag;
    getActionsContext.processInitiatorObject = vehicleContext.processInitiatorObject;
    return getActionsContext;
  }

  public final func SetDoorState(door: EVehicleDoor, state: VehicleDoorState) -> Void {
    this.GetVehicleControllerPS().SetDoorState(door, state);
  }

  public final func GetDoorState(door: EVehicleDoor) -> VehicleDoorState {
    return this.GetVehicleControllerPS().GetDoorState(door);
  }

  public final func SetWindowState(door: EVehicleDoor, state: EVehicleWindowState) -> Void {
    this.GetVehicleControllerPS().SetWindowState(door, state);
  }

  public final func GetWindowState(door: EVehicleDoor) -> EVehicleWindowState {
    return this.GetVehicleControllerPS().GetWindowState(door);
  }

  public final func SetDoorInteractionState(door: EVehicleDoor, state: VehicleDoorInteractionState, source: String) -> Void {
    this.GetVehicleControllerPS().SetDoorInteractionState(door, state);
  }

  public final func GetDoorInteractionState(door: EVehicleDoor) -> VehicleDoorInteractionState {
    return this.GetVehicleControllerPS().GetDoorInteractionState(door);
  }

  public final func SetTempDoorInteractionState(door: EVehicleDoor, state: VehicleDoorInteractionState) -> Void {
    this.m_previousInteractionState[EnumInt(door)].interactionState = state;
  }

  public final const func GetTempDoorInteractionState(door: EVehicleDoor) -> VehicleDoorInteractionState {
    return this.m_previousInteractionState[EnumInt(door)].interactionState;
  }

  public final func GetVehicleDoorEnum(out door: EVehicleDoor, doorName: CName) -> Bool {
    let res: Int32 = Cast(EnumValueFromName(n"EVehicleDoor", doorName));
    if res < 0 {
      return false;
    };
    door = IntEnum(res);
    return true;
  }

  public final func OnVehicleDoorInteraction(evt: ref<VehicleDoorInteraction>) -> EntityNotificationType {
    if evt.isInteractionSource {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnVehicleForceOccupantOut(evt: ref<VehicleForceOccupantOut>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    this.ProcessVehicleHijackTutorialUsed();
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionDemolition(evt);
    if evt.IsCompleted() {
      this.m_skillCheckContainer.GetDemolitionSlot().SetIsPassed(false);
      this.InitializeSkillChecks(this.m_vehicleSkillChecks);
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    this.ProcessVehicleCrackLockTutorialUsed();
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      this.UnlockAllVehDoors();
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ProcessVehicleCrackLockTutorial() -> Void {
    if GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"tutorial_vehicle_crack_lock") == 0 {
      GameInstance.GetQuestsSystem(this.GetGameInstance()).SetFact(n"tutorial_vehicle_crack_lock", 1);
    };
  }

  protected final func ProcessVehicleCrackLockTutorialUsed() -> Void {
    if GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"tutorial_vehicle_crack_lock") == 1 {
      GameInstance.GetQuestsSystem(this.GetGameInstance()).SetFact(n"tutorial_vehicle_crack_lock", 2);
    };
  }

  protected final func ProcessVehicleHijackTutorial() -> Void {
    if GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"tutorial_vehicle_hijack") == 0 {
      GameInstance.GetQuestsSystem(this.GetGameInstance()).SetFact(n"tutorial_vehicle_hijack", 1);
    };
  }

  protected final func ProcessVehicleHijackTutorialUsed() -> Void {
    if GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"tutorial_vehicle_hijack") == 1 {
      GameInstance.GetQuestsSystem(this.GetGameInstance()).SetFact(n"tutorial_vehicle_hijack", 2);
    };
  }

  public final func OnVehicleDoorOpen(evt: ref<VehicleDoorOpen>) -> EntityNotificationType {
    let curDoorState: VehicleDoorState;
    let doorID: EVehicleDoor = IntEnum(Cast(EnumValueFromName(n"EVehicleDoor", evt.slotID)));
    if EnumInt(doorID) < EnumInt(EVehicleDoor.count) && EnumInt(doorID) != -1 {
      curDoorState = this.GetDoorState(doorID);
      if NotEquals(curDoorState, VehicleDoorState.Detached) {
        this.SetDoorState(doorID, VehicleDoorState.Open);
      };
    } else {
      LogError("Received invalid slotID in VehicleDoorOpen event.");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnVehicleDoorClose(evt: ref<VehicleDoorClose>) -> EntityNotificationType {
    let curDoorState: VehicleDoorState;
    let doorID: EVehicleDoor = IntEnum(Cast(EnumValueFromName(n"EVehicleDoor", evt.slotID)));
    if EnumInt(doorID) < EnumInt(EVehicleDoor.count) && EnumInt(doorID) != -1 {
      curDoorState = this.GetDoorState(doorID);
      if NotEquals(curDoorState, VehicleDoorState.Detached) {
        this.SetDoorState(doorID, VehicleDoorState.Closed);
      };
    } else {
      LogError("Received invalid slotID in VehicleDoorClose event.");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnVehicleDoorInteractionStateChange(evt: ref<VehicleDoorInteractionStateChange>) -> EntityNotificationType {
    let newState: VehicleDoorInteractionState = evt.newState;
    if !this.IsStateValidForVehicle(newState) {
      newState = VehicleDoorInteractionState.Available;
    };
    this.SetDoorInteractionState(evt.door, newState, evt.source);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func GetQuestLockedActions(out actions: array<ref<DeviceAction>>, context: VehicleActionsContext) -> Void {
    ArrayPush(actions, this.ActionVehicleDoorQuestLocked());
  }

  public final func IsStateValidForVehicle(state: VehicleDoorInteractionState) -> Bool {
    if this.GetOwnerEntity() == (this.GetOwnerEntity() as TankObject) {
      if Equals(state, VehicleDoorInteractionState.Locked) || Equals(state, VehicleDoorInteractionState.Reserved) || Equals(state, VehicleDoorInteractionState.QuestLocked) {
        return false;
      };
    };
    return true;
  }

  public final func OnVehicleWindowOpen(evt: ref<VehicleWindowOpen>) -> EntityNotificationType {
    let doorID: EVehicleDoor = IntEnum(Cast(EnumValueFromName(n"EVehicleDoor", evt.slotID)));
    if EnumInt(doorID) < EnumInt(EVehicleDoor.count) && EnumInt(doorID) != -1 {
      this.SetWindowState(doorID, EVehicleWindowState.Open);
    } else {
      LogError("Received invalid slotID in OnVehicleWindowOpen event.");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnVehicleWindowClose(evt: ref<VehicleWindowClose>) -> EntityNotificationType {
    let doorID: EVehicleDoor = IntEnum(Cast(EnumValueFromName(n"EVehicleDoor", evt.slotID)));
    if EnumInt(doorID) < EnumInt(EVehicleDoor.count) && EnumInt(doorID) != -1 {
      this.SetWindowState(doorID, EVehicleWindowState.Closed);
    } else {
      LogError("Received invalid slotID in OnVehicleWindowClose event.");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnOpenTrunk(evt: ref<VehicleOpenTrunk>) -> EntityNotificationType {
    this.SetDoorState(EVehicleDoor.trunk, VehicleDoorState.Open);
    if IsDefined(evt.GetExecutor()) && !this.GetOwnerEntity().IsCrowdVehicle() {
      this.GetOwnerEntity().GetDeviceLink().TriggerSecuritySystemNotification(this.GetOwnerEntity().GetWorldPosition(), evt.GetExecutor(), ESecurityNotificationType.ALARM);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnCloseTrunk(evt: ref<VehicleCloseTrunk>) -> EntityNotificationType {
    this.SetDoorState(EVehicleDoor.trunk, VehicleDoorState.Closed);
    if IsDefined(evt.GetExecutor()) && !this.GetOwnerEntity().IsCrowdVehicle() {
      this.GetOwnerEntity().GetDeviceLink().TriggerSecuritySystemNotification(this.GetOwnerEntity().GetWorldPosition(), evt.GetExecutor(), ESecurityNotificationType.DEESCALATE);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnVehicleDumpBody(evt: ref<VehicleDumpBody>) -> EntityNotificationType {
    this.ProcessBodyDisposalEvent();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnVehicleTakeBody(evt: ref<VehicleTakeBody>) -> EntityNotificationType {
    this.ProcessBodyDisposalEvent();
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ProcessBodyDisposalEvent() -> Void {
    let evt: ref<VehicleBodyDisposalPerformedEvent> = new VehicleBodyDisposalPerformedEvent();
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEvent(this.GetID(), n"VehicleComponentPS", evt, 3.00, true);
    this.m_isPlayerPerformingBodyDisposal = true;
  }

  protected final func OnVehicleBodyDisposalPerformedEvent(evt: ref<VehicleBodyDisposalPerformedEvent>) -> EntityNotificationType {
    this.m_isPlayerPerformingBodyDisposal = false;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnVehiclePlayerTrunk(evt: ref<VehiclePlayerTrunk>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func GetTrunkActions(out actions: array<ref<DeviceAction>>, context: VehicleActionsContext) -> Void {
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    if this.GetOwnerEntity().MatchVisualTag(n"NoTrunk") {
      return;
    };
    if this.GetOwnerEntity().IsCrowdVehicle() {
      return;
    };
    VehicleComponent.GetVehicleDataPackage(this.GetGameInstance(), this.GetOwnerEntity(), vehDataPackage);
    if this.GetIsPlayerVehicle() {
      ArrayPush(actions, this.ActionPlayerTrunk());
    };
    if this.GetOwnerEntity() != (this.GetOwnerEntity() as CarObject) {
      return;
    };
    if Equals(this.GetDoorInteractionState(EVehicleDoor.trunk), VehicleDoorInteractionState.Disabled) {
      return;
    };
    if this.m_isPlayerPerformingBodyDisposal {
      if Equals(this.GetDoorState(EVehicleDoor.trunk), VehicleDoorState.Open) {
        ArrayPush(actions, this.ActionCloseTrunk());
      };
      return;
    };
    if Equals(this.GetDoorState(EVehicleDoor.trunk), VehicleDoorState.Detached) {
      if this.IsPlayerCarryingBody(false) && !VehicleComponent.IsSlotOccupied(this.GetGameInstance(), this.GetOwnerEntity().GetEntityID(), n"trunk_body") && vehDataPackage.CanStoreBody() {
        ArrayPush(actions, this.ActionVehicleDumpBody());
      };
      if VehicleComponent.IsSlotOccupied(this.GetGameInstance(), this.GetOwnerEntity().GetEntityID(), n"trunk_body") {
        ArrayPush(actions, this.ActionVehicleTakeBody());
      };
      return;
    };
    if Equals(this.GetDoorState(EVehicleDoor.trunk), VehicleDoorState.Closed) {
      if this.IsPlayerCarryingBody(false) && !VehicleComponent.IsSlotOccupied(this.GetGameInstance(), this.GetOwnerEntity().GetEntityID(), n"trunk_body") && vehDataPackage.CanStoreBody() {
        ArrayPush(actions, this.ActionVehicleDumpBody());
      } else {
        ArrayPush(actions, this.ActionOpenTrunk());
      };
    };
    if Equals(this.GetDoorState(EVehicleDoor.trunk), VehicleDoorState.Open) {
      if this.IsPlayerCarryingBody(false) && !VehicleComponent.IsSlotOccupied(this.GetGameInstance(), this.GetOwnerEntity().GetEntityID(), n"trunk_body") && vehDataPackage.CanStoreBody() {
        ArrayPush(actions, this.ActionVehicleDumpBody());
        return;
      };
      if !this.IsPlayerCarryingBody(true) && VehicleComponent.IsSlotOccupied(this.GetGameInstance(), this.GetOwnerEntity().GetEntityID(), n"trunk_body") {
        ArrayPush(actions, this.ActionVehicleTakeBody());
      };
      ArrayPush(actions, this.ActionCloseTrunk());
    };
    return;
  }

  public final func IsPlayerCarryingBody(includePickupPhase: Bool) -> Bool {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if includePickupPhase {
      return playerStateMachineBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
    };
    return playerStateMachineBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying) == EnumInt(gamePSMBodyCarrying.Carry);
  }

  public final func GetPlayerTrunkActions(out actions: array<ref<DeviceAction>>, context: VehicleActionsContext) -> Void {
    ArrayPush(actions, this.ActionPlayerTrunk());
    return;
  }

  public final func OnOpenHood(evt: ref<VehicleOpenHood>) -> EntityNotificationType {
    this.SetDoorState(EVehicleDoor.hood, VehicleDoorState.Open);
    if IsDefined(evt.GetExecutor()) && !this.GetOwnerEntity().IsCrowdVehicle() {
      this.GetOwnerEntity().GetDeviceLink().TriggerSecuritySystemNotification(this.GetOwnerEntity().GetWorldPosition(), evt.GetExecutor(), ESecurityNotificationType.ALARM);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnCloseHood(evt: ref<VehicleCloseHood>) -> EntityNotificationType {
    this.SetDoorState(EVehicleDoor.hood, VehicleDoorState.Closed);
    if IsDefined(evt.GetExecutor()) && !this.GetOwnerEntity().IsCrowdVehicle() {
      this.GetOwnerEntity().GetDeviceLink().TriggerSecuritySystemNotification(this.GetOwnerEntity().GetWorldPosition(), evt.GetExecutor(), ESecurityNotificationType.DEESCALATE);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func GetHoodActions(out actions: array<ref<DeviceAction>>, context: VehicleActionsContext) -> Void {
    if this.GetOwnerEntity().MatchVisualTag(n"NoHood") {
      return;
    };
    if this.GetOwnerEntity().IsCrowdVehicle() {
      return;
    };
    if this.GetOwnerEntity() != (this.GetOwnerEntity() as CarObject) {
      return;
    };
    if Equals(this.GetDoorInteractionState(EVehicleDoor.hood), VehicleDoorInteractionState.Disabled) {
      return;
    };
    if Equals(this.GetDoorState(EVehicleDoor.hood), VehicleDoorState.Detached) {
      return;
    };
    if Equals(this.GetDoorState(EVehicleDoor.hood), VehicleDoorState.Closed) {
      ArrayPush(actions, this.ActionOpenHood());
    };
    if Equals(this.GetDoorState(EVehicleDoor.hood), VehicleDoorState.Open) {
      ArrayPush(actions, this.ActionCloseHood());
    };
    return;
  }

  public final func DetermineActionsToPush(interaction: ref<InteractionComponent>, context: VehicleActionsContext, objectActionsCallbackController: wref<gameObjectActionsCallbackController>, isAutoRefresh: Bool) -> Void {
    let actionRecords: array<wref<ObjectAction_Record>>;
    let actionToExtractChoices: ref<ScriptableDeviceAction>;
    let actions: array<ref<DeviceAction>>;
    let choiceTDBname: String;
    let choices: array<InteractionChoice>;
    let door: EVehicleDoor;
    let doorLayer: CName;
    let i: Int32;
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    VehicleComponent.GetVehicleDataPackage(this.GetGameInstance(), this.GetOwnerEntity(), vehDataPackage);
    if this.m_isDestroyed {
      this.PushActionsToInteractionComponent(interaction, choices, context);
      return;
    };
    if this.IsDoorLayer(context.interactionLayerTag) {
      doorLayer = context.interactionLayerTag;
      this.GetVehicleDoorEnum(door, doorLayer);
      if Equals(this.GetDoorInteractionState(door), VehicleDoorInteractionState.Disabled) {
        return;
      };
      if Equals(this.GetDoorInteractionState(door), VehicleDoorInteractionState.Reserved) {
        this.PushActionsToInteractionComponent(interaction, choices, context);
        return;
      };
      if Equals(this.GetDoorInteractionState(door), VehicleDoorInteractionState.QuestLocked) {
        this.GetQuestLockedActions(actions, context);
      };
    };
    if Equals(context.interactionLayerTag, n"trunk") {
      this.GetTrunkActions(actions, context);
    };
    if Equals(context.interactionLayerTag, n"hood") {
      this.GetHoodActions(actions, context);
    };
    if Equals(context.interactionLayerTag, n"Mount") {
      return;
    };
    context.requestType = gamedeviceRequestType.Direct;
    this.GetOwnerEntity().GetRecord().ObjectActions(actionRecords);
    this.GetValidChoices(actionRecords, this.ChangeToActionContext(context), objectActionsCallbackController, choices, isAutoRefresh);
    this.FinalizeGetActions(actions);
    i = 0;
    while i < ArraySize(actions) {
      actionToExtractChoices = actions[i] as ScriptableDeviceAction;
      (actions[i] as ScriptableDeviceAction).SetExecutor(context.processInitiatorObject);
      ArrayPush(choices, actionToExtractChoices.GetInteractionChoice());
      i += 1;
    };
    if !isAutoRefresh {
      i = 0;
      while i < ArraySize(choices) {
        choiceTDBname = choices[i].choiceMetaData.tweakDBName;
        switch choiceTDBname {
          case "ActionDemolition":
            this.ProcessVehicleHijackTutorial();
            break;
          case "ActionEngineering":
            this.ProcessVehicleCrackLockTutorial();
        };
        i += 1;
      };
    };
    this.PushActionsToInteractionComponent(interaction, choices, context);
  }

  protected final func IsDoorLayer(layer: CName) -> Bool {
    return Equals(layer, n"seat_front_right") || Equals(layer, n"seat_front_left") || Equals(layer, n"seat_back_left") || Equals(layer, n"seat_back_right");
  }

  public final func GetValidChoices(objectActionRecords: array<wref<ObjectAction_Record>>, context: GetActionsContext, objectActionsCallbackController: wref<gameObjectActionsCallbackController>, out choices: array<InteractionChoice>, isAutoRefresh: Bool) -> Void {
    let actionName: CName;
    let actionRecord: wref<ObjectAction_Record>;
    let actionType: gamedataObjectActionType;
    let choice: InteractionChoice;
    let compareAction: ref<ScriptableDeviceAction>;
    let i: Int32;
    let instigator: wref<GameObject>;
    let isRemote: Bool;
    let j: Int32;
    let newAction: ref<ScriptableDeviceAction>;
    let objectActionInteractionLayer: CName;
    let playerInteractionLayer: CName;
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    let maxChoices: Int32 = 4;
    VehicleComponent.GetVehicleDataPackage(this.GetGameInstance(), this.GetOwnerEntity(), vehDataPackage);
    playerInteractionLayer = context.interactionLayerTag;
    instigator = context.processInitiatorObject;
    i = 0;
    while i < ArraySize(objectActionRecords) {
      actionType = objectActionRecords[i].ObjectActionType().Type();
      objectActionInteractionLayer = objectActionRecords[i].InteractionLayer();
      if NotEquals(objectActionInteractionLayer, playerInteractionLayer) {
      } else {
        switch actionType {
          case gamedataObjectActionType.Payment:
          case gamedataObjectActionType.Item:
          case gamedataObjectActionType.Direct:
            isRemote = false;
            break;
          case gamedataObjectActionType.MinigameUpload:
          case gamedataObjectActionType.DeviceQuickHack:
          case gamedataObjectActionType.Remote:
            isRemote = true;
            break;
          default:
            isRemote = false;
        };
        if !isRemote && Equals(context.requestType, gamedeviceRequestType.Direct) || isRemote && Equals(context.requestType, gamedeviceRequestType.Remote) {
          actionName = objectActionRecords[i].ActionName();
          switch actionName {
            case n"VehicleHijack":
              newAction = this.ActionDemolition(context);
              newAction.SetIllegal(true);
              break;
            case n"VehicleMount":
              newAction = this.ActionVehicleDoorInteraction(ToString(objectActionRecords[i].InteractionLayer()), true);
              break;
            case n"VehicleCrackLock":
              newAction = this.ActionEngineering(context);
              newAction.SetIllegal(true);
          };
          newAction.SetObjectActionID(objectActionRecords[i].GetID());
          newAction.SetExecutor(instigator);
          if IsDefined(objectActionsCallbackController) {
            if !objectActionsCallbackController.HasObjectAction(objectActionRecords[i]) {
              objectActionsCallbackController.AddObjectAction(objectActionRecords[i]);
            };
          };
          if newAction.IsPossible(this.GetOwnerEntity(), objectActionsCallbackController) {
            if newAction.IsVisible(context, objectActionsCallbackController) {
              actionRecord = objectActionRecords[i];
              choice = newAction.GetInteractionChoice();
              newAction.prop.name = playerInteractionLayer;
              ArrayPush(choice.data, ToVariant(newAction));
              j = 0;
              while j < maxChoices {
                compareAction = FromVariant(choices[j].data[0]);
                if IsDefined(compareAction) {
                  if actionRecord.Priority() >= compareAction.GetObjectActionRecord().Priority() {
                    ArrayInsert(choices, j, choice);
                  } else {
                  };
                } else {
                  ArrayPush(choices, choice);
                  goto 1914;
                };
                j += 1;
              };
            } else {
              newAction.SetInactiveWithReason(false, "LocKey#7009");
            };
          };
        };
      };
      i += 1;
    };
    if ArraySize(choices) > maxChoices {
      ArrayResize(choices, maxChoices);
    };
  }

  public final func PushActionsToInteractionComponent(interaction: ref<InteractionComponent>, choices: array<InteractionChoice>, context: VehicleActionsContext) -> Void {
    if !IsDefined(interaction) {
      return;
    };
    interaction.SetChoices(choices, context.interactionLayerTag);
  }

  protected final func OnVehicleFinishedMounting(evt: ref<VehicleFinishedMountingEvent>) -> EntityNotificationType {
    let i: Int32;
    if !evt.isMounting {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if evt.character.IsPlayer() {
      return EntityNotificationType.SendThisEventToEntity;
    };
    i = 0;
    while i < ArraySize(this.m_npcOccupiedSlots) {
      if Equals(this.m_npcOccupiedSlots[i], evt.slotID) {
        if evt.isMounting {
          return EntityNotificationType.SendThisEventToEntity;
        };
      };
      i = i + 1;
    };
    if evt.isMounting {
      ArrayPush(this.m_npcOccupiedSlots, evt.slotID);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleStartedUnmountingEvent(evt: ref<VehicleStartedUnmountingEvent>) -> EntityNotificationType {
    let i: Int32;
    if evt.character.IsPlayer() || evt.isMounting {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    i = 0;
    while i < ArraySize(this.m_npcOccupiedSlots) {
      if Equals(this.m_npcOccupiedSlots[i], evt.slotID) {
        ArrayErase(this.m_npcOccupiedSlots, i);
        return EntityNotificationType.SendThisEventToEntity;
      };
      i = i + 1;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func IsSlotOccupiedByNPC(slotID: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_npcOccupiedSlots) {
      if Equals(this.m_npcOccupiedSlots[i], slotID) {
        return true;
      };
      i = i + 1;
    };
    return false;
  }

  public func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> EntityNotificationType {
    this.OnSetExposeQuickHacks(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    let controllerPS: ref<vehicleControllerPS> = this.GetVehicleControllerPSConst();
    if IsDefined(controllerPS) && !controllerPS.IsAlarmOn() {
      return true;
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    let controllerPS: ref<vehicleControllerPS> = this.GetVehicleControllerPS();
    let vehicleState: vehicleEState = controllerPS.GetState();
    if Equals(vehicleState, vehicleEState.Default) {
      if !controllerPS.IsAlarmOn() {
        currentAction = this.ActionForceCarAlarm();
        currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
        ArrayPush(actions, currentAction);
      };
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  private final func ActionForceCarAlarm() -> ref<ForceCarAlarm> {
    let action: ref<ForceCarAlarm> = new ForceCarAlarm();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(true);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionForceDisableCarAlarm() -> ref<ForceDisableCarAlarm> {
    let action: ref<ForceDisableCarAlarm> = new ForceDisableCarAlarm();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(false);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionToggleVehicle(toggleOn: Bool) -> ref<ToggleVehicle> {
    let action: ref<ToggleVehicle> = new ToggleVehicle();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(toggleOn);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionOpenTrunk() -> ref<VehicleOpenTrunk> {
    let action: ref<VehicleOpenTrunk> = new VehicleOpenTrunk();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionCloseTrunk() -> ref<VehicleCloseTrunk> {
    let action: ref<VehicleCloseTrunk> = new VehicleCloseTrunk();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionOpenHood() -> ref<VehicleOpenHood> {
    let action: ref<VehicleOpenHood> = new VehicleOpenHood();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionCloseHood() -> ref<VehicleCloseHood> {
    let action: ref<VehicleCloseHood> = new VehicleCloseHood();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionVehicleDumpBody() -> ref<VehicleDumpBody> {
    let action: ref<VehicleDumpBody> = new VehicleDumpBody();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionVehicleTakeBody() -> ref<VehicleTakeBody> {
    let action: ref<VehicleTakeBody> = new VehicleTakeBody();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionPlayerTrunk() -> ref<VehiclePlayerTrunk> {
    let action: ref<VehiclePlayerTrunk> = new VehiclePlayerTrunk();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionVehicleDoorInteraction(slotName: String, opt fromInteraction: Bool, opt locked: Bool) -> ref<VehicleDoorInteraction> {
    let action: ref<VehicleDoorInteraction> = new VehicleDoorInteraction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(slotName, fromInteraction, locked);
    action.AddDeviceName(this.GetDeviceName());
    if !locked {
      action.CreateInteraction(slotName);
    } else {
      action.CreateInteraction();
    };
    return action;
  }

  private final func ActionVehicleDoorInteractionStateChange(doorToChange: EVehicleDoor, desiredState: VehicleDoorInteractionState, source: String) -> ref<VehicleDoorInteractionStateChange> {
    let action: ref<VehicleDoorInteractionStateChange> = new VehicleDoorInteractionStateChange();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(doorToChange, desiredState, source);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionVehicleDoorOpen(slotName: String) -> ref<VehicleDoorOpen> {
    let action: ref<VehicleDoorOpen> = new VehicleDoorOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(slotName);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction(slotName);
    return action;
  }

  private final func ActionVehicleDoorClose(slotName: String) -> ref<VehicleDoorClose> {
    let action: ref<VehicleDoorClose> = new VehicleDoorClose();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(slotName);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction(slotName);
    return action;
  }

  private final func ActionVehicleForceOccupantOut(slotName: String) -> ref<VehicleForceOccupantOut> {
    let action: ref<VehicleForceOccupantOut> = new VehicleForceOccupantOut();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(slotName);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  private final func ActionVehicleDoorQuestLocked() -> ref<VehicleQuestDoorLocked> {
    let action: ref<VehicleQuestDoorLocked> = new VehicleQuestDoorLocked();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.SetInactive();
    return action;
  }

  protected final func OnVehicleQuestChangeDoorStateEvent(evt: ref<VehicleQuestChangeDoorStateEvent>) -> EntityNotificationType {
    let InteractionStateChangeEvent: ref<VehicleDoorInteractionStateChange>;
    let doorCloseEvent: ref<VehicleDoorClose>;
    let doorOpenEvent: ref<VehicleDoorOpen>;
    let desiredState: EQuestVehicleDoorState = evt.newState;
    switch desiredState {
      case EQuestVehicleDoorState.ForceOpen:
        doorOpenEvent = new VehicleDoorOpen();
        doorOpenEvent.slotID = EnumValueToName(n"EVehicleDoor", Cast(EnumInt(evt.door)));
        this.QueuePSEvent(this, doorOpenEvent);
        break;
      case EQuestVehicleDoorState.ForceClose:
        doorCloseEvent = new VehicleDoorClose();
        doorCloseEvent.slotID = EnumValueToName(n"EVehicleDoor", Cast(EnumInt(evt.door)));
        this.QueuePSEvent(this, doorCloseEvent);
        break;
      case EQuestVehicleDoorState.OpenAll:
        this.OpenAllVehDoors();
        break;
      case EQuestVehicleDoorState.CloseAll:
        this.CloseAllVehDoors();
        break;
      case EQuestVehicleDoorState.OpenAllRegular:
        this.OpenAllRegularVehDoors();
        break;
      case EQuestVehicleDoorState.ForceLock:
        InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
        InteractionStateChangeEvent.door = evt.door;
        InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Locked;
        InteractionStateChangeEvent.source = "QuestForceLock";
        this.QueuePSEvent(this, InteractionStateChangeEvent);
        break;
      case EQuestVehicleDoorState.ForceUnlock:
        InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
        InteractionStateChangeEvent.door = evt.door;
        InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Available;
        InteractionStateChangeEvent.source = "QuestForceUnlock";
        this.QueuePSEvent(this, InteractionStateChangeEvent);
        break;
      case EQuestVehicleDoorState.LockAll:
        this.LockAllVehDoors();
        break;
      case EQuestVehicleDoorState.EnableInteraction:
        InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
        InteractionStateChangeEvent.door = evt.door;
        InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Available;
        InteractionStateChangeEvent.source = "QuestEnableInteraction";
        this.QueuePSEvent(this, InteractionStateChangeEvent);
        break;
      case EQuestVehicleDoorState.DisableInteraction:
        InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
        InteractionStateChangeEvent.door = evt.door;
        InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Disabled;
        InteractionStateChangeEvent.source = "QuestDisableInteraction";
        this.QueuePSEvent(this, InteractionStateChangeEvent);
        break;
      case EQuestVehicleDoorState.DisableAllInteractions:
        this.DisableAllVehInteractions();
        break;
      case EQuestVehicleDoorState.ResetInteractions:
        this.ResetVehicleInteractionState();
        break;
      case EQuestVehicleDoorState.ResetVehicle:
        this.ResetVehicle();
        break;
      case EQuestVehicleDoorState.QuestLock:
        InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
        InteractionStateChangeEvent.door = evt.door;
        InteractionStateChangeEvent.newState = VehicleDoorInteractionState.QuestLocked;
        InteractionStateChangeEvent.source = "QuestLock";
        this.QueuePSEvent(this, InteractionStateChangeEvent);
        break;
      case EQuestVehicleDoorState.QuestLockAll:
        this.QuestLockAllVehDoors();
        break;
      default:
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnVehicleQuestChangeWindowStateEvent(evt: ref<vehicleChangeWindowStateEvent>) -> EntityNotificationType {
    let windowCloseEvent: ref<VehicleWindowClose>;
    let windowOpenEvent: ref<VehicleWindowOpen>;
    let desiredState: EQuestVehicleWindowState = evt.state;
    switch desiredState {
      case EQuestVehicleWindowState.OpenAll:
        this.OpenAllVehWindows();
        break;
      case EQuestVehicleWindowState.CloseAll:
        this.CloseAllVehWindows();
        break;
      case EQuestVehicleWindowState.ForceOpen:
        windowOpenEvent = new VehicleWindowOpen();
        windowOpenEvent.slotID = EnumValueToName(n"EVehicleDoor", Cast(EnumInt(evt.door)));
        this.QueuePSEvent(this, windowOpenEvent);
        break;
      case EQuestVehicleWindowState.ForceClose:
        windowCloseEvent = new VehicleWindowClose();
        windowCloseEvent.slotID = EnumValueToName(n"EVehicleDoor", Cast(EnumInt(evt.door)));
        this.QueuePSEvent(this, windowCloseEvent);
        break;
      default:
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnToggleDoorWrapperEvent(evt: ref<vehicleToggleDoorWrapperEvent>) -> EntityNotificationType {
    let newEvt: ref<VehicleQuestChangeDoorStateEvent> = new VehicleQuestChangeDoorStateEvent();
    newEvt.door = evt.door;
    newEvt.newState = evt.action;
    this.OnVehicleQuestChangeDoorStateEvent(newEvt);
    this.SetHasStateBeenModifiedByQuest(true);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func OpenAllVehDoors() -> Void {
    let doorOpenEvent: ref<VehicleDoorOpen>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      doorOpenEvent = new VehicleDoorOpen();
      doorOpenEvent.slotID = EnumValueToName(n"EVehicleDoor", EnumInt(IntEnum(i)));
      this.QueuePSEvent(this, doorOpenEvent);
      i += 1;
    };
  }

  public final func OpenAllRegularVehDoors() -> Void {
    let doorOpenEvent: ref<VehicleDoorOpen>;
    let seatSet: array<wref<VehicleSeat_Record>> = this.GetSeats();
    let i: Int32 = 0;
    while i < ArraySize(seatSet) {
      doorOpenEvent = new VehicleDoorOpen();
      doorOpenEvent.slotID = seatSet[i].SeatName();
      this.QueuePSEvent(this, doorOpenEvent);
      i += 1;
    };
  }

  private final func CloseAllVehDoors() -> Void {
    let doorCloseEvent: ref<VehicleDoorClose>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      if Equals(this.GetDoorState(IntEnum(i)), VehicleDoorState.Open) {
        doorCloseEvent = new VehicleDoorClose();
        doorCloseEvent.slotID = EnumValueToName(n"EVehicleDoor", EnumInt(IntEnum(i)));
        this.QueuePSEvent(this, doorCloseEvent);
      };
      i += 1;
    };
  }

  private final func LockAllVehDoors() -> Void {
    let InteractionStateChangeEvent: ref<VehicleDoorInteractionStateChange>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
      InteractionStateChangeEvent.source = "LockAllVehDoors";
      InteractionStateChangeEvent.door = IntEnum(i);
      InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Locked;
      this.QueuePSEvent(this, InteractionStateChangeEvent);
      i += 1;
    };
  }

  private final func UnlockAllVehDoors() -> Void {
    let InteractionStateChangeEvent: ref<VehicleDoorInteractionStateChange>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
      InteractionStateChangeEvent.source = "UnlockAllVehDoors";
      InteractionStateChangeEvent.door = IntEnum(i);
      InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Available;
      this.QueuePSEvent(this, InteractionStateChangeEvent);
      i += 1;
    };
  }

  private final func OpenAllVehWindows() -> Void {
    let windowOpenEvent: ref<VehicleWindowOpen>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      windowOpenEvent = new VehicleWindowOpen();
      windowOpenEvent.slotID = EnumValueToName(n"EVehicleDoor", EnumInt(IntEnum(i)));
      this.QueuePSEvent(this, windowOpenEvent);
      i += 1;
    };
  }

  private final func CloseAllVehWindows() -> Void {
    let windowCloseEvent: ref<VehicleWindowClose>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      windowCloseEvent = new VehicleWindowClose();
      windowCloseEvent.slotID = EnumValueToName(n"EVehicleDoor", EnumInt(IntEnum(i)));
      this.QueuePSEvent(this, windowCloseEvent);
      i += 1;
    };
  }

  private final func DisableAllVehInteractions() -> Void {
    let InteractionStateChangeEvent: ref<VehicleDoorInteractionStateChange>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
      InteractionStateChangeEvent.source = "DisableAllVehInteractions";
      InteractionStateChangeEvent.door = IntEnum(i);
      InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Disabled;
      this.QueuePSEvent(this, InteractionStateChangeEvent);
      i += 1;
    };
  }

  private final func ResetVehicleInteractionState() -> Void {
    let InteractionStateChangeEvent: ref<VehicleDoorInteractionStateChange>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
      InteractionStateChangeEvent.source = "ResetVehicleInteractionState";
      InteractionStateChangeEvent.door = IntEnum(i);
      if Equals(IntEnum(i), EVehicleDoor.seat_front_left) || Equals(IntEnum(i), EVehicleDoor.seat_front_right) {
        InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Available;
        this.QueuePSEvent(this, InteractionStateChangeEvent);
      } else {
        if Equals(IntEnum(i), EVehicleDoor.seat_back_left) || Equals(IntEnum(i), EVehicleDoor.seat_back_right) {
          InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Disabled;
          this.QueuePSEvent(this, InteractionStateChangeEvent);
        };
      };
      i += 1;
    };
    this.SetHasStateBeenModifiedByQuest(false);
  }

  private final func ResetVehicle() -> Void {
    let InteractionStateChangeEvent: ref<VehicleDoorInteractionStateChange>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
      InteractionStateChangeEvent.door = IntEnum(i);
      InteractionStateChangeEvent.source = "ResetVehicle";
      if Equals(IntEnum(i), EVehicleDoor.seat_front_left) || Equals(IntEnum(i), EVehicleDoor.seat_front_right) {
        InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Available;
        this.QueuePSEvent(this, InteractionStateChangeEvent);
      } else {
        if Equals(IntEnum(i), EVehicleDoor.seat_back_left) || Equals(IntEnum(i), EVehicleDoor.seat_back_right) {
          InteractionStateChangeEvent.newState = VehicleDoorInteractionState.Disabled;
          this.QueuePSEvent(this, InteractionStateChangeEvent);
        };
      };
      i += 1;
    };
    this.SetHasStateBeenModifiedByQuest(false);
  }

  private final func QuestLockAllVehDoors() -> Void {
    let InteractionStateChangeEvent: ref<VehicleDoorInteractionStateChange>;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      InteractionStateChangeEvent = new VehicleDoorInteractionStateChange();
      InteractionStateChangeEvent.source = "QuestLockAllVehDoors";
      InteractionStateChangeEvent.door = IntEnum(i);
      InteractionStateChangeEvent.newState = VehicleDoorInteractionState.QuestLocked;
      this.QueuePSEvent(this, InteractionStateChangeEvent);
      i += 1;
    };
  }

  private final func OnVehicleSeatReservationEvent(evt: ref<VehicleSeatReservationEvent>) -> EntityNotificationType {
    let currentState: VehicleDoorInteractionState;
    let door: EVehicleDoor;
    let previousState: VehicleDoorInteractionState;
    this.GetVehicleDoorEnum(door, evt.slotID);
    if evt.reserve {
      currentState = this.GetDoorInteractionState(door);
      if Equals(currentState, VehicleDoorInteractionState.Disabled) {
        return EntityNotificationType.DoNotNotifyEntity;
      };
      this.SetTempDoorInteractionState(door, this.GetDoorInteractionState(door));
      this.SetDoorInteractionState(door, VehicleDoorInteractionState.Reserved, "ReservationStart");
    };
    if !evt.reserve {
      previousState = this.GetTempDoorInteractionState(door);
      currentState = this.GetDoorInteractionState(door);
      if Equals(currentState, VehicleDoorInteractionState.Reserved) {
        this.SetDoorInteractionState(door, previousState, "ReservationEnd");
      };
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func GetSeats() -> array<wref<VehicleSeat_Record>> {
    let seatSet: array<wref<VehicleSeat_Record>>;
    VehicleComponent.GetSeats(this.GetGameInstance(), this.GetOwnerEntity(), seatSet);
    return seatSet;
  }

  protected final func OnVehicleQuestCrystalDomeEvent(evt: ref<VehicleQuestCrystalDomeEvent>) -> EntityNotificationType {
    let toggle: Bool = evt.toggle;
    this.SetCrystalDomeQuestState(toggle);
    if evt.removeQuestControl {
      this.SetIsCrystalDomeQuestModified(false);
    } else {
      this.SetIsCrystalDomeQuestModified(true);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleQuestSirenEvent(evt: ref<VehicleQuestSirenEvent>) -> EntityNotificationType {
    this.SetSirenLightsState(evt.lights);
    this.SetSirenSoundsState(evt.sounds);
    if evt.lights || evt.sounds {
      this.SetSirenState(true);
    };
    if !evt.lights && !evt.sounds {
      this.SetSirenState(false);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleLightQuestToggleEvent(evt: ref<VehicleLightQuestToggleEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleQuestHornEvent(evt: ref<VehicleQuestHornEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleQuestVisualDestructionEvent(evt: ref<VehicleQuestVisualDestructionEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleQuestAVThrusterEvent(evt: ref<VehicleQuestAVThrusterEvent>) -> EntityNotificationType {
    this.SetThrusterState(evt.enable);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleQuestUIEvent(evt: ref<VehicleQuestEnableUIEvent>) -> EntityNotificationType {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    let forwardEvent: ref<ForwardVehicleQuestEnableUIEvent> = new ForwardVehicleQuestEnableUIEvent();
    forwardEvent.mode = evt.mode;
    uiSystem.QueueEvent(forwardEvent);
    if Equals(evt.mode, vehicleQuestUIEnable.Gameplay) {
      this.SetIsUiQuestModified(false);
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.SetIsUiQuestModified(true);
    if Equals(evt.mode, vehicleQuestUIEnable.ForceEnable) {
      this.SetUiQuestState(true);
    };
    if Equals(evt.mode, vehicleQuestUIEnable.ForceDisable) {
      this.SetUiQuestState(false);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnVehicleQuestUIEffectEvent(evt: ref<VehicleQuestUIEffectEvent>) -> EntityNotificationType {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    let forwardEvent: ref<ForwardVehicleQuestUIEffectEvent> = new ForwardVehicleQuestUIEffectEvent();
    forwardEvent.glitch = evt.glitch;
    forwardEvent.panamVehicleStartup = evt.panamVehicleStartup;
    forwardEvent.panamScreenType1 = evt.panamScreenType1;
    forwardEvent.panamScreenType2 = evt.panamScreenType2;
    forwardEvent.panamScreenType3 = evt.panamScreenType3;
    forwardEvent.panamScreenType4 = evt.panamScreenType4;
    uiSystem.QueueEvent(forwardEvent);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnVehicleRadioEvent(evt: ref<VehicleRadioEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleQuestWindowDestructionEvent(evt: ref<VehicleQuestWindowDestructionEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehicleRaceQuestEvent(evt: ref<VehicleRaceQuestEvent>) -> EntityNotificationType {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    let forwardEvent: ref<ForwardVehicleRaceUIEvent> = new ForwardVehicleRaceUIEvent();
    forwardEvent.mode = evt.mode;
    forwardEvent.maxPosition = evt.maxPosition;
    forwardEvent.maxCheckpoints = evt.maxCheckpoints;
    uiSystem.QueueEvent(forwardEvent);
    switch evt.mode {
      case vehicleRaceUI.PreRaceSetup:
        uiSystem.PushGameContext(UIGameContext.VehicleRace);
        break;
      case vehicleRaceUI.Disable:
        uiSystem.PopGameContext(UIGameContext.VehicleRace);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnVehiclePanzerBootupUIQuestEvent(evt: ref<VehiclePanzerBootupUIQuestEvent>) -> EntityNotificationType {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    let forwardEvent: ref<VehiclePanzerBootupUIQuestEvent> = new VehiclePanzerBootupUIQuestEvent();
    forwardEvent.mode = evt.mode;
    uiSystem.QueueEvent(forwardEvent);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnVehicleQuestToggleEngineEvent(evt: ref<VehicleQuestToggleEngineEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }
}

public class VehicleQuestChangeDoorStateEvent extends Event {

  public let door: EVehicleDoor;

  public let newState: EQuestVehicleDoorState;

  public final func GetFriendlyDescription() -> String {
    return "Change Veh Door states";
  }
}

public class VehicleQuestToggleEngineEvent extends Event {

  public edit let toggle: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Enable/Disable Vehicle Engine";
  }
}

public class VehicleQuestCrystalDomeEvent extends Event {

  public edit let toggle: Bool;

  public edit let removeQuestControl: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle Crystal Dome on and off";
  }
}

public class VehicleQuestSirenEvent extends Event {

  public edit let lights: Bool;

  public edit let sounds: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle Sirens on and off";
  }
}

public class VehicleLightQuestToggleEvent extends Event {

  public edit let toggle: Bool;

  @default(VehicleLightQuestToggleEvent, vehicleELightType.Default)
  public let lightType: vehicleELightType;

  public final func GetFriendlyDescription() -> String {
    return "Toggle lightType ON/OFF";
  }
}

public class VehicleQuestHornEvent extends Event {

  public edit let honkTime: Float;

  public final func GetFriendlyDescription() -> String {
    return "Honk the horn";
  }
}

public class VehicleQuestVisualDestructionEvent extends Event {

  public edit let accumulate: Bool;

  public edit let frontLeft: Float;

  public edit let frontRight: Float;

  public edit let front: Float;

  public edit let right: Float;

  public edit let left: Float;

  public edit let backLeft: Float;

  public edit let backRight: Float;

  public edit let back: Float;

  public edit let roof: Float;

  public final func GetFriendlyDescription() -> String {
    return "Set Visual Deformation";
  }
}

public class VehicleQuestAVThrusterEvent extends Event {

  public edit let enable: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Enable/Disable AV thruster FX";
  }
}

public class VehicleRadioEvent extends Event {

  public edit let toggle: Bool;

  public edit let setStation: Bool;

  @attrib(tooltip, "0: Aggro Ind   1: Elec Ind   2: HipHop   3: Aggro Techno   4: Downtempo   5: Att Rock   6: Pop   7: Latino   8: Metal   9: Minimal Techno   10: Jazz")
  public edit let station: Int32;

  public final func GetFriendlyDescription() -> String {
    return "Toggle radio or set station";
  }
}

public class VehicleQuestEnableUIEvent extends Event {

  @default(VehicleQuestEnableUIEvent, vehicleQuestUIEnable.Gameplay)
  public edit let mode: vehicleQuestUIEnable;

  public final func GetFriendlyDescription() -> String {
    return "Enable/Disable Vehicle UI";
  }
}

public class VehicleQuestUIEffectEvent extends Event {

  public edit let glitch: Bool;

  public edit let panamVehicleStartup: Bool;

  public edit let panamScreenType1: Bool;

  public edit let panamScreenType2: Bool;

  public edit let panamScreenType3: Bool;

  public edit let panamScreenType4: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Trigger vehicle UI effects";
  }
}

public class VehicleRaceQuestEvent extends Event {

  @default(VehicleRaceQuestEvent, vehicleRaceUI.PreRaceSetup)
  public edit let mode: vehicleRaceUI;

  public edit let maxPosition: Int32;

  public edit let maxCheckpoints: Int32;

  public final func GetFriendlyDescription() -> String {
    return "Manage Race UI";
  }
}

public class VehicleQuestWindowDestructionEvent extends Event {

  public edit let windowName: CName;

  @default(VehicleQuestWindowDestructionEvent, vehicleQuestWindowDestruction.window_f)
  public edit let window: vehicleQuestWindowDestruction;

  public final func GetFriendlyDescription() -> String {
    return "Destroy vehicle windows";
  }
}

public class VehiclePanzerBootupUIQuestEvent extends Event {

  @default(VehiclePanzerBootupUIQuestEvent, panzerBootupUI.Loop)
  public edit let mode: panzerBootupUI;

  public final func GetFriendlyDescription() -> String {
    return "Manage Panzer Bootup UI";
  }
}
