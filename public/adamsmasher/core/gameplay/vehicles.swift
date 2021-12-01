
public native class VehicleObject extends GameObject {

  private let m_vehicleComponent: wref<VehicleComponent>;

  private let m_uiComponent: wref<worlduiWidgetComponent>;

  protected let m_crowdMemberComponent: ref<CrowdMemberBaseComponent>;

  private let m_hitTimestamp: Float;

  private let m_drivingTrafficPattern: CName;

  private let m_onPavement: Bool;

  private let m_inTrafficLane: Bool;

  private let m_timesSentReactionEvent: Int32;

  private let m_vehicleUpsideDown: Bool;

  public const func IsVehicle() -> Bool {
    return true;
  }

  public final native func GetBlackboard() -> ref<IBlackboard>;

  public final native const func GetRecord() -> wref<Vehicle_Record>;

  public final native const func IsPlayerMounted() -> Bool;

  public final native const func IsPlayerDriver() -> Bool;

  public final native func PreHijackPrepareDriverSlot() -> Void;

  public final native func CanUnmount(isPlayer: Bool, mountedObject: wref<GameObject>, opt checkSpecificDirection: vehicleExitDirection) -> vehicleUnmountPosition;

  public final native func ToggleRadioReceiver(toggle: Bool) -> Void;

  public final native func SetRadioReceiverStation(stationIndex: Uint32) -> Void;

  public final native func NextRadioReceiverStation() -> Void;

  public final native func SetRadioTier(radioTier: Uint32, overrideTier: Bool) -> Void;

  public final native func ToggleHorn(toggle: Bool, opt isPolice: Bool) -> Void;

  public final native func ToggleSiren(toggle: Bool) -> Void;

  public final native func DetachPart(partName: CName) -> Void;

  public final native func DetachAllParts() -> Void;

  public final native func HasOccupantSlot(slotName: CName) -> Bool;

  public final native func GetRecordID() -> TweakDBID;

  public final native func GetController() -> ref<vehicleController>;

  public final native func GetCameraManager() -> ref<VehicleCameraManager>;

  public final native const func IsPlayerVehicle() -> Bool;

  public final native const func IsPlayerActiveVehicle() -> Bool;

  public final native const func IsCrowdVehicle() -> Bool;

  public final native const func IsVehicleParked() -> Bool;

  public final native func IsRadioReceiverActive() -> Bool;

  public final native func GetRadioReceiverStationName() -> CName;

  public final native func GetRadioReceiverTrackName() -> CName;

  public final native func GetAnimsetOverrideForPassenger(slotName: CName) -> CName;

  public final native func GetAnimsetOverrideForPassengerFromSlotName(slotName: CName) -> CName;

  public final native func GetAnimsetOverrideForPassengerFromBoneName(boneName: CName) -> CName;

  public final native func GetBoneNameFromSlot(slotName: CName) -> CName;

  public final native func GetSlotIdForMountedObject(mountedObject: wref<GameObject>) -> CName;

  public final native func TurnOn(on: Bool) -> Void;

  public final native func TurnEngineOn(on: Bool) -> Void;

  public final native const func IsTurnedOn() -> Bool;

  public final native const func IsEngineTurnedOn() -> Bool;

  public final native func ForceBrakesFor(seconds: Float) -> Void;

  public final native func ForceBrakesUntilStoppedOrFor(secondsToTimeout: Float) -> Void;

  public final native func PhysicsWakeUp() -> Void;

  public final native const func IsExecutingAnyCommand() -> Bool;

  public final native func AreFrontWheelsCentered() -> Bool;

  public final native func GetCollisionForce() -> Vector4;

  public final native func GetLinearVelocity() -> Vector4;

  public final native func GetTotalMass() -> Float;

  public final func GetCurrentSpeed() -> Float {
    return this.GetBlackboard().GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue);
  }

  public final native func SetDestructionGridPointValues(layer: Uint32, values: array<Float; 15>, accumulate: Bool) -> Void;

  public final native func DestructionResetGrid() -> Void;

  public final native func DestructionResetGlass() -> Void;

  private final native func GetUIComponents() -> array<ref<worlduiWidgetComponent>>;

  public final native func SendDelayedFinishedMountingEventToPS(isMounting: Bool, slotID: CName, character: ref<GameObject>, delay: Float) -> Void;

  public final const func IsDestroyed() -> Bool {
    return this.GetVehiclePS().GetIsDestroyed();
  }

  public final const func IsStolen() -> Bool {
    return this.GetVehiclePS().GetIsStolen();
  }

  public final const func RecordHasTag(tag: CName) -> Bool {
    let vehicleRecord: ref<Vehicle_Record>;
    if !VehicleComponent.GetVehicleRecord(this, vehicleRecord) {
      return false;
    };
    return this.RecordHasTag(vehicleRecord, tag);
  }

  public final const func RecordHasTag(vehicleRecord: ref<Vehicle_Record>, tag: CName) -> Bool {
    let vehicleTags: array<CName> = vehicleRecord.Tags();
    if ArrayContains(vehicleTags, tag) {
      return true;
    };
    return false;
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"controller", n"VehicleComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"CrowdMember", n"CrowdMemberBaseComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_vehicleComponent = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as VehicleComponent;
    this.m_crowdMemberComponent = EntityResolveComponentsInterface.GetComponent(ri, n"CrowdMember") as CrowdMemberBaseComponent;
    super.OnTakeControl(ri);
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.SetInteriorUIEnabled(false);
  }

  protected cb func OnDeviceLinkRequest(evt: ref<DeviceLinkRequest>) -> Bool {
    let link: ref<VehicleDeviceLinkPS>;
    if this.IsCrowdVehicle() {
      return false;
    };
    link = VehicleDeviceLinkPS.CreateAndAcquirVehicleDeviceLinkPS(this.GetGame(), this.GetEntityID());
    if IsDefined(link) {
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(link.GetID(), link.GetClassName(), evt);
    };
  }

  public const func GetDeviceLink() -> ref<DeviceLinkComponentPS> {
    let link: ref<VehicleDeviceLinkPS> = VehicleDeviceLinkPS.AcquireVehicleDeviceLink(this.GetGame(), this.GetEntityID());
    if IsDefined(link) {
      return link;
    };
    return null;
  }

  protected func SendEventToDefaultPS(evt: ref<Event>) -> Void {
    let persistentState: ref<VehicleComponentPS> = this.GetVehiclePS();
    if persistentState == null {
      LogError("[SendEventToDefaultPS] Unable to send event, there is no presistent state on that entity " + ToString(this.GetEntityID()));
      return;
    };
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(persistentState.GetID(), persistentState.GetClassName(), evt);
  }

  protected cb func OnMountingEvent(evt: ref<MountingEvent>) -> Bool {
    let mountChild: ref<GameObject> = GameInstance.FindEntityByID(this.GetGame(), evt.request.lowLevelMountingInfo.childId) as GameObject;
    if mountChild == null {
      return false;
    };
    if mountChild.IsPlayer() {
      this.SetInteriorUIEnabled(true);
      if this.ReevaluateStealing(mountChild, evt.request.lowLevelMountingInfo.slotId.id, evt.request.mountData.mountEventOptions.occupiedByNeutral) {
        this.StealVehicle(mountChild);
      };
    };
  }

  protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
    let mountChild: ref<GameObject> = GameInstance.FindEntityByID(this.GetGame(), evt.request.lowLevelMountingInfo.childId) as GameObject;
    let isSilentUnmount: Bool = IsDefined(evt.request.mountData) && evt.request.mountData.mountEventOptions.silentUnmount;
    if IsDefined(mountChild) && mountChild.IsPlayer() {
      if !isSilentUnmount {
        this.SetInteriorUIEnabled(false);
      };
    };
  }

  protected cb func OnVehicleFinishedMounting(evt: ref<VehicleFinishedMountingEvent>) -> Bool;

  private final func SetInteriorUIEnabled(enabled: Bool) -> Void {
    let component: ref<worlduiWidgetComponent>;
    let i: Int32;
    let uiComponents: array<ref<worlduiWidgetComponent>> = this.GetUIComponents();
    let total: Int32 = ArraySize(uiComponents);
    if total > 0 {
      i = 0;
      while i < total {
        component = uiComponents[i];
        if IsDefined(component) {
          component.Toggle(enabled);
        };
        i += 1;
      };
      this.GetBlackboard().SetBool(GetAllBlackboardDefs().Vehicle.IsUIActive, enabled);
      this.GetBlackboard().FireCallbacks();
    };
  }

  private final func ReevaluateStealing(character: wref<GameObject>, slotID: CName, stealingAction: Bool) -> Bool {
    let vehicleRecord: ref<Vehicle_Record>;
    if !IsDefined(character) || !character.IsPlayer() {
      return false;
    };
    if stealingAction {
      return true;
    };
    if this.IsStolen() || NotEquals(slotID, VehicleComponent.GetDriverSlotName()) || this.IsPlayerVehicle() {
      return false;
    };
    if !VehicleComponent.GetVehicleRecord(this, vehicleRecord) {
      return false;
    };
    if Equals(vehicleRecord.Affiliation().Type(), gamedataAffiliation.NCPD) || this.RecordHasTag(vehicleRecord, n"TriggerPrevention") {
      return true;
    };
    return false;
  }

  private final func StealVehicle(thief: wref<GameObject>) -> Void {
    StimBroadcasterComponent.BroadcastStim(thief, gamedataStimType.CrowdIllegalAction);
    StimBroadcasterComponent.BroadcastActiveStim(thief, gamedataStimType.CrimeWitness, 4.40);
    this.GetVehiclePS().SetIsStolen(true);
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    if Equals(componentName, n"trunkBodyDisposalPlayer") {
      this.GetVehicleComponent().MountNpcBodyToTrunk();
    } else {
      if Equals(componentName, n"trunkBodyPickupPlayer") {
        this.GetVehicleComponent().FinishTrunkBodyPickup();
      };
    };
  }

  public const func GetVehiclePS() -> ref<VehicleComponentPS> {
    let ps: ref<PersistentState> = this.GetControllerPersistentState();
    return ps as VehicleComponentPS;
  }

  public const func GetPSClassName() -> CName {
    return this.GetVehiclePS().GetClassName();
  }

  protected final const func GetControllerPersistentState() -> ref<PersistentState> {
    let psID: PersistentID = this.GetVehicleComponent().GetPersistentID();
    if PersistentID.IsDefined(psID) {
      return GameInstance.GetPersistencySystem(this.GetGame()).GetConstAccessToPSObject(psID, this.GetVehicleComponent().GetPSName());
    };
    return null;
  }

  public const func GetVehicleComponent() -> ref<VehicleComponent> {
    return this.m_vehicleComponent;
  }

  public final const func GetCrowdMemberComponent() -> ref<CrowdMemberBaseComponent> {
    return this.m_crowdMemberComponent;
  }

  public const func ShouldShowScanner() -> Bool {
    if this.GetHudManager().IsBraindanceActive() && !this.m_scanningComponent.IsBraindanceClue() {
      return false;
    };
    return true;
  }

  protected cb func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> Bool {
    this.RequestHUDRefresh();
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    if this.IsDestroyed() || this.IsPlayerMounted() {
      return null;
    };
    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked() {
      return null;
    };
    highlight = new FocusForcedHighlightData();
    highlight.outlineType = this.GetCurrentOutline();
    if Equals(highlight.outlineType, EFocusOutlineType.INVALID) {
      return null;
    };
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();
    if Equals(highlight.outlineType, EFocusOutlineType.QUEST) {
      highlight.highlightType = EFocusForcedHighlightType.QUEST;
    } else {
      if Equals(highlight.outlineType, EFocusOutlineType.HACKABLE) {
        highlight.highlightType = EFocusForcedHighlightType.HACKABLE;
      };
    };
    if highlight != null {
      if this.IsNetrunner() {
        highlight.patternType = VisionModePatternType.Netrunner;
      } else {
        highlight.patternType = VisionModePatternType.Default;
      };
    };
    return highlight;
  }

  public const func GetCurrentOutline() -> EFocusOutlineType {
    let outlineType: EFocusOutlineType;
    if this.IsDestroyed() {
      return EFocusOutlineType.INVALID;
    };
    if this.IsQuest() {
      outlineType = EFocusOutlineType.QUEST;
    } else {
      if this.IsNetrunner() {
        outlineType = EFocusOutlineType.HACKABLE;
      } else {
        return EFocusOutlineType.INVALID;
      };
    };
    return outlineType;
  }

  public const func IsNetrunner() -> Bool {
    return this.GetVehiclePS().HasPlaystyle(EPlaystyle.NETRUNNER);
  }

  public const func CompileScannerChunks() -> Bool {
    let VehicleManufacturerChunk: ref<ScannerVehicleManufacturer>;
    let driveLayoutChunk: ref<ScannerVehicleDriveLayout>;
    let horsepowerChunk: ref<ScannerVehicleHorsepower>;
    let infoChunk: ref<ScannerVehicleInfo>;
    let massChunk: ref<ScannerVehicleMass>;
    let productionYearsChunk: ref<ScannerVehicleProdYears>;
    let record: ref<Vehicle_Record>;
    let stateChunk: ref<ScannerVehicleState>;
    let uiData: ref<VehicleUIData_Record>;
    let vehicleNameChunk: ref<ScannerVehicleName>;
    let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);
    scannerBlackboard.SetInt(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, EnumInt(ScannerObjectType.VEHICLE), true);
    record = this.GetRecord();
    uiData = record.VehicleUIData();
    vehicleNameChunk = new ScannerVehicleName();
    vehicleNameChunk.Set(LocKeyToString(record.DisplayName()));
    scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleName, ToVariant(vehicleNameChunk));
    VehicleManufacturerChunk = new ScannerVehicleManufacturer();
    VehicleManufacturerChunk.Set(record.Manufacturer().EnumName());
    scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleManufacturer, ToVariant(VehicleManufacturerChunk));
    productionYearsChunk = new ScannerVehicleProdYears();
    productionYearsChunk.Set(uiData.ProductionYear());
    scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleProductionYears, ToVariant(productionYearsChunk));
    massChunk = new ScannerVehicleMass();
    massChunk.Set(RoundMath(MeasurementUtils.ValueToImperial(uiData.Mass(), EMeasurementUnit.Kilogram)));
    scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleMass, ToVariant(massChunk));
    infoChunk = new ScannerVehicleInfo();
    infoChunk.Set(uiData.Info());
    scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleInfo, ToVariant(infoChunk));
    if this == (this as CarObject) || this == (this as BikeObject) {
      horsepowerChunk = new ScannerVehicleHorsepower();
      horsepowerChunk.Set(RoundMath(uiData.Horsepower()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleHorsepower, ToVariant(horsepowerChunk));
      stateChunk = new ScannerVehicleState();
      stateChunk.Set(this.m_vehicleComponent.GetVehicleStateForScanner());
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleState, ToVariant(stateChunk));
      driveLayoutChunk = new ScannerVehicleDriveLayout();
      driveLayoutChunk.Set(uiData.DriveLayout());
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleDriveLayout, ToVariant(driveLayoutChunk));
    };
    return true;
  }

  protected cb func OnLookedAtEvent(evt: ref<LookedAtEvent>) -> Bool {
    super.OnLookedAtEvent(evt);
    VehicleComponent.QueueEventToAllPassengers(this.GetGame(), this, evt);
  }

  protected cb func OnCrowdSettingsEvent(evt: ref<CrowdSettingsEvent>) -> Bool {
    this.m_drivingTrafficPattern = evt.movementType;
    this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
  }

  protected cb func OnHandleReactionEvent(evt: ref<HandleReactionEvent>) -> Bool {
    let carEmptyPathDistance: Float;
    let exitEvent: ref<AIEvent>;
    let npcReactionEvent: ref<DelayedCrowdReactionEvent>;
    let passengersCanLeaveCar: array<wref<GameObject>>;
    let passengersCantLeaveCar: array<wref<GameObject>>;
    if !GameObject.IsCooldownActive(this, n"vehicleReactionCooldown") {
      GameObject.StartCooldown(this, n"vehicleReactionCooldown", 1.00);
      carEmptyPathDistance = TweakDBInterface.GetFloat(t"AIGeneralSettings.carEmptyPathDistance", 20.00);
      if Equals(evt.stimEvent.GetStimType(), gamedataStimType.VehicleHit) || evt.eventResent {
        if this.m_crowdMemberComponent.CheckEmptyPath(carEmptyPathDistance) && this.m_inTrafficLane {
          this.m_drivingTrafficPattern = n"panic";
          this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
          this.ResetTimesSentReactionEvent();
        } else {
          this.m_drivingTrafficPattern = n"stop";
          this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
          npcReactionEvent = new DelayedCrowdReactionEvent();
          npcReactionEvent.stimEvent = evt.stimEvent;
          npcReactionEvent.vehicleFearPhase = 2;
          VehicleComponent.QueueEventToAllPassengers(this.GetGame(), this.GetEntityID(), npcReactionEvent);
          this.ResendHandleReactionEvent(evt);
        };
      } else {
        if this.m_crowdMemberComponent.CheckIsMoving() {
          if this.m_crowdMemberComponent.CheckEmptyPath(carEmptyPathDistance) && this.m_inTrafficLane {
            if Equals(this.m_drivingTrafficPattern, n"stop") {
              this.ResetReactionSequenceOfAllPassengers();
            };
            this.m_drivingTrafficPattern = n"panic";
            this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
            this.ResetTimesSentReactionEvent();
          } else {
            this.m_drivingTrafficPattern = n"stop";
            this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
            npcReactionEvent = new DelayedCrowdReactionEvent();
            npcReactionEvent.stimEvent = evt.stimEvent;
            if evt.fearPhase == 3 && (EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame())) <= this.m_hitTimestamp + 1.00 || Equals(evt.stimEvent.GetStimType(), gamedataStimType.Explosion)) {
              VehicleComponent.CheckIfPassengersCanLeaveCar(this.GetGame(), this.GetEntityID(), passengersCanLeaveCar, passengersCantLeaveCar);
              if ArraySize(passengersCanLeaveCar) > 0 {
                exitEvent = new AIEvent();
                exitEvent.name = n"ExitVehicleInPanic";
                VehicleComponent.QueueEventToPassengers(this.GetGame(), this.GetEntityID(), exitEvent, passengersCanLeaveCar, true);
                npcReactionEvent.vehicleFearPhase = 3;
                VehicleComponent.QueueEventToPassengers(this.GetGame(), this.GetEntityID(), npcReactionEvent, passengersCanLeaveCar, true);
              };
              if ArraySize(passengersCantLeaveCar) > 0 {
                npcReactionEvent.vehicleFearPhase = 2;
                VehicleComponent.QueueEventToPassengers(this.GetGame(), this.GetEntityID(), npcReactionEvent, passengersCantLeaveCar, true);
                this.ResendHandleReactionEvent(evt);
              };
            } else {
              npcReactionEvent.vehicleFearPhase = 2;
              VehicleComponent.QueueEventToAllNonFriendlyNonDeadPassengers(this.GetGame(), this.GetEntityID(), npcReactionEvent, this, false, true);
              this.ResendHandleReactionEvent(evt);
            };
          };
        } else {
          if evt.fearPhase == 2 || !this.m_crowdMemberComponent.CheckEmptyPath(carEmptyPathDistance) || !this.m_inTrafficLane {
            this.m_drivingTrafficPattern = n"stop";
            this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
            npcReactionEvent = new DelayedCrowdReactionEvent();
            npcReactionEvent.stimEvent = evt.stimEvent;
            if evt.fearPhase == 3 && (EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame())) <= this.m_hitTimestamp + 1.00 || Equals(evt.stimEvent.GetStimType(), gamedataStimType.Explosion)) {
              VehicleComponent.CheckIfPassengersCanLeaveCar(this.GetGame(), this.GetEntityID(), passengersCanLeaveCar, passengersCantLeaveCar);
              if ArraySize(passengersCanLeaveCar) > 0 {
                exitEvent = new AIEvent();
                exitEvent.name = n"ExitVehicleInPanic";
                VehicleComponent.QueueEventToPassengers(this.GetGame(), this.GetEntityID(), exitEvent, passengersCanLeaveCar, true);
                npcReactionEvent.vehicleFearPhase = 3;
                VehicleComponent.QueueEventToPassengers(this.GetGame(), this.GetEntityID(), npcReactionEvent, passengersCanLeaveCar, true);
              };
              if ArraySize(passengersCantLeaveCar) > 0 {
                npcReactionEvent.vehicleFearPhase = 2;
                VehicleComponent.QueueEventToPassengers(this.GetGame(), this.GetEntityID(), npcReactionEvent, passengersCantLeaveCar, true);
                this.ResendHandleReactionEvent(evt);
              };
            } else {
              npcReactionEvent.vehicleFearPhase = 2;
              VehicleComponent.QueueEventToAllNonFriendlyNonDeadPassengers(this.GetGame(), this.GetEntityID(), npcReactionEvent, this, false, true);
              this.ResendHandleReactionEvent(evt);
            };
          } else {
            if Equals(this.m_drivingTrafficPattern, n"stop") {
              this.ResetReactionSequenceOfAllPassengers();
            };
            this.m_drivingTrafficPattern = n"panic";
            this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
            this.ResetTimesSentReactionEvent();
          };
        };
      };
    };
  }

  private final func ResendHandleReactionEvent(evt: ref<HandleReactionEvent>) -> Void {
    let reactionEvent: ref<HandleReactionEvent>;
    let timesToResendHandleReactionEvent: Int32 = TweakDBInterface.GetInt(t"AIGeneralSettings.timesToResendHandleReactionEvent", 3);
    if this.m_timesSentReactionEvent >= timesToResendHandleReactionEvent {
      return;
    };
    this.m_timesSentReactionEvent += 1;
    reactionEvent = new HandleReactionEvent();
    reactionEvent = evt;
    reactionEvent.eventResent = true;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, reactionEvent, 4.00);
  }

  private final func ResetTimesSentReactionEvent() -> Void {
    this.m_timesSentReactionEvent = 0;
  }

  private final func ResetReactionSequenceOfAllPassengers() -> Void {
    let mountingInfos: array<MountingInfo> = GameInstance.GetMountingFacility(this.GetGame()).GetMountingInfoMultipleWithObjects(this);
    let count: Int32 = ArraySize(mountingInfos);
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGame());
    let i: Int32 = 0;
    while i < count {
      workspotSystem.HardResetPlaybackToStart(GameInstance.FindEntityByID(this.GetGame(), mountingInfos[i].childId) as GameObject);
      i += 1;
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    super.OnHit(evt);
    if !GameObject.IsCooldownActive(this, n"vehicleHitCooldown") {
      GameObject.StartCooldown(this, n"vehicleHitCooldown", 1.00);
      this.m_hitTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
    };
  }

  public final func IsOnPavement() -> Bool {
    return this.m_onPavement;
  }

  protected cb func OnPavement(evt: ref<OnPavement>) -> Bool {
    this.m_onPavement = true;
  }

  protected cb func OnOffPavement(evt: ref<OffPavement>) -> Bool {
    this.m_onPavement = false;
  }

  protected cb func OnInCrowd(evt: ref<InCrowd>) -> Bool {
    this.m_inTrafficLane = true;
    let vehicleDriver: wref<GameObject> = VehicleComponent.GetDriver(this.GetGame(), this.GetEntityID());
    if Equals((vehicleDriver as ScriptedPuppet).GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Fear) {
      if Equals(this.m_drivingTrafficPattern, n"stop") {
        this.ResetReactionSequenceOfAllPassengers();
      };
      this.m_drivingTrafficPattern = n"panic";
      this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
      this.ResetTimesSentReactionEvent();
    } else {
      if Equals(this.m_drivingTrafficPattern, n"stop") {
        this.m_drivingTrafficPattern = n"normal";
        this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
      };
    };
  }

  protected cb func OnOutOfCrowd(evt: ref<OutOfCrowd>) -> Bool {
    this.m_inTrafficLane = false;
  }

  public final func IsInTrafficLane() -> Bool {
    return this.m_inTrafficLane;
  }

  public final func IsVehicleUpsideDown() -> Bool {
    return this.m_vehicleUpsideDown;
  }

  protected cb func OnVehicleFlippedOverEvent(evt: ref<VehicleFlippedOverEvent>) -> Bool {
    this.m_vehicleUpsideDown = evt.isFlippedOver;
  }

  public const func IsQuest() -> Bool {
    return this.GetVehiclePS().IsMarkedAsQuest();
  }

  protected func MarkAsQuest(isQuest: Bool) -> Void {
    this.GetVehiclePS().SetIsMarkedAsQuest(isQuest);
  }
}

public static func GetMountedVehicle(object: ref<GameObject>) -> wref<VehicleObject> {
  let game: GameInstance = object.GetGame();
  let mountingFacility: ref<IMountingFacility> = GameInstance.GetMountingFacility(game);
  let mountingInfo: MountingInfo = mountingFacility.GetMountingInfoSingleWithObjects(object);
  let vehicle: wref<VehicleObject> = GameInstance.FindEntityByID(game, mountingInfo.parentId) as VehicleObject;
  return vehicle;
}
