
public class VehicleComponent extends ScriptableDC {

  public let m_interaction: ref<InteractionComponent>;

  public let m_scanningComponent: ref<ScanningComponent>;

  @default(VehicleComponent, 0)
  public let m_damageLevel: Int32;

  public let m_coolerDestro: Bool;

  public let m_submerged: Bool;

  public let m_bumperFrontState: Int32;

  public let m_bumperBackState: Int32;

  public let m_visualDestructionSet: Bool;

  public let m_healthStatPoolListener: ref<VehicleHealthStatPoolListener>;

  public let m_vehicleBlackboard: wref<IBlackboard>;

  public let m_radioState: Bool;

  public let m_mounted: Bool;

  public let m_enterTime: Float;

  public let m_mappinID: NewMappinID;

  public let m_ignoreAutoDoorClose: Bool;

  public let m_timeSystemCallbackID: Uint32;

  public let m_vehicleTPPCallbackID: ref<CallbackHandle>;

  public let m_vehicleSpeedCallbackID: ref<CallbackHandle>;

  public let m_vehicleRPMCallbackID: ref<CallbackHandle>;

  public let m_broadcasting: Bool;

  public let m_hasSpoiler: Bool;

  public let m_spoilerUp: Float;

  public let m_spoilerDown: Float;

  public let m_spoilerDeployed: Bool;

  public let m_hasTurboCharger: Bool;

  public let m_overheatEffectBlackboard: ref<worldEffectBlackboard>;

  public let m_overheatActive: Bool;

  public let m_hornOn: Bool;

  public let m_hasSiren: Bool;

  public let m_hornPressTime: Float;

  public let m_radioPressTime: Float;

  public let m_raceClockTickID: DelayID;

  public let m_objectActionsCallbackCtrl: ref<gameObjectActionsCallbackController>;

  public let m_trunkNpcBody: wref<GameObject>;

  public let m_mountedPlayer: wref<PlayerPuppet>;

  @default(VehicleComponent, false)
  public let m_isIgnoredInTargetingSystem: Bool;

  @default(VehicleComponent, true)
  public let m_arePlayerHitShapesEnabled: Bool;

  private let m_vehicleController: ref<vehicleController>;

  private final func OnGameAttach() -> Void {
    this.m_interaction = this.FindComponentByName(n"interaction") as InteractionComponent;
    this.m_scanningComponent = this.FindComponentByName(n"scanning") as ScanningComponent;
    this.m_ignoreAutoDoorClose = false;
    this.SetImmortalityMode();
    this.m_healthStatPoolListener = new VehicleHealthStatPoolListener();
    this.m_healthStatPoolListener.m_owner = this.GetVehicle();
    GameInstance.GetStatPoolsSystem(this.GetVehicle().GetGame()).RequestRegisteringListener(Cast(this.GetVehicle().GetEntityID()), gamedataStatPoolType.Health, this.m_healthStatPoolListener);
    this.m_vehicleBlackboard = this.GetVehicle().GetBlackboard();
    this.m_vehicleBlackboard.SetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, n"Gameplay-Devices-Radio-RadioStationDownTempo");
    this.InitialVehcileSetup();
    this.RegisterToHUDManager(true);
    this.IsPlayerVehicle();
    this.LoadExplodedState();
    this.SetupThrusterFX();
    if this.GetVehicle().IsPlayerVehicle() && !(this.GetPS() as VehicleComponentPS).GetIsDestroyed() {
      this.CreateMappin();
    };
  }

  private final func OnGameDetach() -> Void {
    this.DestroyObjectActionsCallbackController();
    this.ClearImmortalityMode();
    GameInstance.GetStatPoolsSystem(this.GetVehicle().GetGame()).RequestUnregisteringListener(Cast(this.GetVehicle().GetEntityID()), gamedataStatPoolType.Health, this.m_healthStatPoolListener);
    this.DestroyMappin();
    this.RegisterToHUDManager(false);
    this.UnregisterListeners();
    this.UnregisterInputListener();
    this.DoPanzerCleanup();
  }

  public final static func IsDestroyed(gi: GameInstance, vehicleID: EntityID) -> Bool {
    let vehicle: wref<VehicleObject>;
    VehicleComponent.GetVehicleFromID(gi, vehicleID, vehicle);
    if !IsDefined(vehicle) {
      return false;
    };
    return vehicle.IsDestroyed();
  }

  public final static func GetDriverSlotName() -> CName {
    return n"seat_front_left";
  }

  public final static func GetFrontPassengerSlotName() -> CName {
    return n"seat_front_right";
  }

  public final static func GetBackLeftPassengerSlotName() -> CName {
    return n"seat_back_left";
  }

  public final static func GetBackRightPassengerSlotName() -> CName {
    return n"seat_back_right";
  }

  public final static func GetPassengersSlotNames(out slotNames: array<CName>) -> Void {
    ArrayResize(slotNames, 4);
    slotNames[0] = VehicleComponent.GetDriverSlotName();
    slotNames[1] = VehicleComponent.GetFrontPassengerSlotName();
    slotNames[2] = VehicleComponent.GetBackLeftPassengerSlotName();
    slotNames[3] = VehicleComponent.GetBackRightPassengerSlotName();
  }

  public final static func GetDriverSlotID() -> MountingSlotId {
    let slotID: MountingSlotId;
    slotID.id = VehicleComponent.GetDriverSlotName();
    return slotID;
  }

  public final static func IsMountedToVehicle(gi: GameInstance, owner: wref<GameObject>) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    return VehicleComponent.IsMountedToVehicle(gi, owner.GetEntityID());
  }

  public final static func IsMountedToVehicle(gi: GameInstance, ownerID: EntityID) -> Bool {
    let vehicle: wref<VehicleObject>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(ownerID) {
      return false;
    };
    if !VehicleComponent.GetVehicle(gi, ownerID, vehicle) {
      return false;
    };
    return true;
  }

  public final static func IsMountedToProvidedVehicle(gi: GameInstance, ownerID: EntityID, vehicle: wref<VehicleObject>) -> Bool {
    let mountInfo: MountingInfo;
    let mountedVeh: EntityID;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(ownerID) || !IsDefined(vehicle) {
      return false;
    };
    if VehicleComponent.IsMountedToVehicle(gi, ownerID) {
      mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithIds(ownerID);
      mountedVeh = mountInfo.parentId;
      if mountedVeh == vehicle.GetEntityID() {
        return true;
      };
    };
    return false;
  }

  public final static func IsDriver(gi: GameInstance, owner: wref<GameObject>) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    return VehicleComponent.IsDriver(gi, owner.GetEntityID());
  }

  public final static func IsDriver(gi: GameInstance, ownerID: EntityID) -> Bool {
    let mountInfo: MountingInfo;
    let vehicle: wref<VehicleObject>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(ownerID) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithIds(ownerID);
    if !EntityID.IsDefined(mountInfo.parentId) {
      return false;
    };
    if NotEquals(mountInfo.slotId.id, VehicleComponent.GetDriverSlotName()) {
      return false;
    };
    if !VehicleComponent.GetVehicle(gi, ownerID, vehicle) {
      return false;
    };
    if vehicle == (vehicle as AVObject) {
      return false;
    };
    return true;
  }

  public final static func GetVehicle(gi: GameInstance, owner: wref<GameObject>, out vehicle: wref<GameObject>) -> Bool {
    let vehicleObj: wref<VehicleObject>;
    if !IsDefined(owner) {
      return false;
    };
    if !VehicleComponent.GetVehicle(gi, owner.GetEntityID(), vehicleObj) {
      return false;
    };
    vehicle = vehicleObj;
    return vehicle != null;
  }

  public final static func GetVehicle(gi: GameInstance, owner: wref<GameObject>, out vehicle: wref<VehicleObject>) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    return VehicleComponent.GetVehicle(gi, owner.GetEntityID(), vehicle);
  }

  public final static func GetVehicle(gi: GameInstance, ownerID: EntityID, out vehicle: wref<VehicleObject>) -> Bool {
    let mountInfo: MountingInfo;
    let vehicleID: EntityID;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(ownerID) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithIds(ownerID);
    vehicleID = mountInfo.parentId;
    if !EntityID.IsDefined(vehicleID) {
      return false;
    };
    return VehicleComponent.GetVehicleFromID(gi, vehicleID, vehicle);
  }

  public final static func GetVehicleFromID(gi: GameInstance, vehicleID: EntityID, out vehicle: wref<VehicleObject>) -> Bool {
    if !EntityID.IsDefined(vehicleID) {
      return false;
    };
    vehicle = GameInstance.FindEntityByID(gi, vehicleID) as VehicleObject;
    if IsDefined(vehicle) {
      return true;
    };
    return false;
  }

  public final static func GetVehicleID(gi: GameInstance, owner: wref<GameObject>, out vehicleID: EntityID) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    return VehicleComponent.GetVehicleID(gi, owner.GetEntityID(), vehicleID);
  }

  public final static func GetVehicleID(gi: GameInstance, ownerID: EntityID, out vehicleID: EntityID) -> Bool {
    let vehicle: wref<VehicleObject>;
    if !VehicleComponent.GetVehicle(gi, ownerID, vehicle) {
      return false;
    };
    vehicleID = vehicle.GetEntityID();
    if !EntityID.IsDefined(vehicleID) {
      return false;
    };
    return true;
  }

  public final static func GetVehicleRecord(gi: GameInstance, owner: wref<GameObject>, out vehicleRecord: ref<Vehicle_Record>) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    return VehicleComponent.GetVehicleRecord(gi, owner.GetEntityID(), vehicleRecord);
  }

  public final static func GetVehicleRecord(gi: GameInstance, ownerID: EntityID, out vehicleRecord: ref<Vehicle_Record>) -> Bool {
    let vehicle: wref<VehicleObject>;
    if !VehicleComponent.GetVehicle(gi, ownerID, vehicle) {
      return false;
    };
    vehicleRecord = TweakDBInterface.GetVehicleRecord(vehicle.GetRecordID());
    if !IsDefined(vehicleRecord) {
      return false;
    };
    return true;
  }

  public final static func GetVehicleRecord(vehicle: wref<VehicleObject>, out vehicleRecord: ref<Vehicle_Record>) -> Bool {
    if !IsDefined(vehicle) {
      return false;
    };
    vehicleRecord = TweakDBInterface.GetVehicleRecord(vehicle.GetRecordID());
    if !IsDefined(vehicleRecord) {
      return false;
    };
    return true;
  }

  public final static func GetVehicleRecordFromID(gi: GameInstance, vehicleID: EntityID, out vehicleRecord: ref<Vehicle_Record>) -> Bool {
    let vehicle: wref<VehicleObject>;
    if !VehicleComponent.GetVehicleFromID(gi, vehicleID, vehicle) {
      return false;
    };
    vehicleRecord = TweakDBInterface.GetVehicleRecord(vehicle.GetRecordID());
    if !IsDefined(vehicleRecord) {
      return false;
    };
    return true;
  }

  public final static func GetDriver(gi: GameInstance, vehicleID: EntityID) -> wref<GameObject> {
    let i: Int32;
    let mountInfos: array<MountingInfo>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) {
      return null;
    };
    mountInfos = GameInstance.GetMountingFacility(gi).GetMountingInfoMultipleWithIds(vehicleID);
    i = 0;
    while i < ArraySize(mountInfos) {
      if Equals(mountInfos[i].slotId.id, VehicleComponent.GetDriverSlotName()) {
        return GameInstance.FindEntityByID(gi, mountInfos[i].childId) as GameObject;
      };
      i += 1;
    };
    return null;
  }

  public final static func CanBeDriven(gi: GameInstance, ownerID: EntityID) -> Bool {
    let vehicle: wref<VehicleObject>;
    if !VehicleComponent.GetVehicle(gi, ownerID, vehicle) {
      return false;
    };
    return VehicleComponent.CanBeDriven(gi, vehicle);
  }

  public final static func CanBeDriven(gi: GameInstance, vehicle: wref<VehicleObject>) -> Bool {
    if !IsDefined(vehicle) || vehicle.IsDestroyed() || VehicleComponent.HasActiveAutopilot(gi, vehicle) || VehicleComponent.IsExecutingAnyCommand(gi, vehicle) {
      return false;
    };
    return true;
  }

  public final static func HasActiveAutopilot(gi: GameInstance, vehicle: wref<VehicleObject>) -> Bool {
    if IsDefined(vehicle) {
      return vehicle.GetBlackboard().GetBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn);
    };
    return false;
  }

  public final static func HasActiveAutopilot(gi: GameInstance, ownerID: EntityID) -> Bool {
    let vehicle: wref<VehicleObject>;
    if !VehicleComponent.GetVehicle(gi, ownerID, vehicle) {
      return false;
    };
    return VehicleComponent.HasActiveAutopilot(gi, vehicle);
  }

  public final static func IsExecutingAnyCommand(gi: GameInstance, vehicle: wref<VehicleObject>) -> Bool {
    if IsDefined(vehicle) {
      return vehicle.IsExecutingAnyCommand();
    };
    return false;
  }

  public final static func HasActiveDriver(gi: GameInstance, vehicleID: EntityID) -> Bool {
    let driver: wref<GameObject> = VehicleComponent.GetDriver(gi, vehicleID);
    if IsDefined(driver) && ScriptedPuppet.IsActive(driver) {
      return true;
    };
    return false;
  }

  public final static func QueueEventToAllPassengers(gi: GameInstance, vehicleID: EntityID, evt: ref<Event>, opt delay: Float) -> Bool {
    let i: Int32;
    let mountInfos: array<MountingInfo>;
    let passenger: wref<GameObject>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) {
      return false;
    };
    mountInfos = GameInstance.GetMountingFacility(gi).GetMountingInfoMultipleWithIds(vehicleID);
    i = 0;
    while i < ArraySize(mountInfos) {
      if Equals(mountInfos[i].slotId.id, n"trunk_body") {
      } else {
        passenger = GameInstance.FindEntityByID(gi, mountInfos[i].childId) as GameObject;
        if IsDefined(passenger) {
          if delay > 0.00 {
            GameInstance.GetDelaySystem(gi).DelayEvent(passenger, evt, delay);
          } else {
            passenger.QueueEvent(evt);
          };
        };
      };
      i += 1;
    };
    if !IsDefined(passenger) {
      return false;
    };
    return true;
  }

  public final static func QueueEventToAllPassengers(gi: GameInstance, vehicle: wref<VehicleObject>, evt: ref<Event>, opt delay: Float) -> Bool {
    if !IsDefined(vehicle) {
      return false;
    };
    return VehicleComponent.QueueEventToAllPassengers(gi, vehicle.GetEntityID(), evt, delay);
  }

  public final static func QueueEventToAllNonFriendlyAggressivePassengers(gi: GameInstance, vehicleID: EntityID, evt: ref<Event>, opt delay: Float) -> Bool {
    let i: Int32;
    let mountInfos: array<MountingInfo>;
    let passenger: wref<ScriptedPuppet>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) {
      return false;
    };
    mountInfos = GameInstance.GetMountingFacility(gi).GetMountingInfoMultipleWithIds(vehicleID);
    i = 0;
    while i < ArraySize(mountInfos) {
      if Equals(mountInfos[i].slotId.id, n"trunk_body") {
      } else {
        passenger = GameInstance.FindEntityByID(gi, mountInfos[i].childId) as ScriptedPuppet;
        if IsDefined(passenger) && !IsFriendlyTowardsPlayer(passenger) && passenger.IsAggressive() {
          if delay > 0.00 {
            GameInstance.GetDelaySystem(gi).DelayEvent(passenger, evt, delay);
          } else {
            passenger.QueueEvent(evt);
          };
        };
      };
      i += 1;
    };
    if !IsDefined(passenger) {
      return false;
    };
    return true;
  }

  public final static func QueueEventToPassengers(gi: GameInstance, vehicleID: EntityID, evt: ref<Event>, passengers: array<wref<GameObject>>, opt delay: Bool) -> Bool {
    let delayTime: Float;
    let i: Int32;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) || ArraySize(passengers) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(passengers) {
      if IsDefined(passengers[i]) {
        if delay {
          delayTime = delayTime + RandRangeF(0.20, 0.40);
          GameInstance.GetDelaySystem(gi).DelayEvent(passengers[i], evt, delayTime);
        } else {
          passengers[i].QueueEvent(evt);
        };
      };
      i += 1;
    };
    return true;
  }

  public final static func QueueEventToAllNonFriendlyNonDeadPassengers(gi: GameInstance, vehicleID: EntityID, evt: ref<Event>, executionOwner: ref<GameObject>, opt broadcastHijack: Bool, opt delay: Bool) -> Bool {
    let active: Bool;
    let attitude: EAIAttitude;
    let broadcaster: ref<StimBroadcasterComponent>;
    let delayTime: Float;
    let i: Int32;
    let mountInfos: array<MountingInfo>;
    let passenger: wref<GameObject>;
    let playerMountInfo: MountingInfo;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) {
      return false;
    };
    playerMountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithObjects(GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject());
    mountInfos = GameInstance.GetMountingFacility(gi).GetMountingInfoMultipleWithIds(vehicleID);
    i = 0;
    while i < ArraySize(mountInfos) {
      if Equals(mountInfos[i].slotId.id, n"trunk_body") {
        ArrayErase(mountInfos, i);
      } else {
        i += 1;
      };
    };
    delayTime = RandRangeF(0.20, 0.40);
    broadcaster = GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject().GetStimBroadcasterComponent();
    i = 0;
    while i < ArraySize(mountInfos) {
      passenger = GameInstance.FindEntityByID(gi, mountInfos[i].childId) as GameObject;
      active = VehicleComponent.IsSlotOccupiedByActivePassenger(gi, vehicleID, mountInfos[i].slotId.id);
      VehicleComponent.GetAttitudeOfPassenger(gi, vehicleID, mountInfos[i].slotId, attitude);
      if NotEquals(playerMountInfo.slotId.id, mountInfos[i].slotId.id) {
        if IsDefined(passenger) && active && NotEquals(attitude, EAIAttitude.AIA_Friendly) {
          if delay {
            delayTime = delayTime + RandRangeF(0.20, 0.40);
            GameInstance.GetDelaySystem(gi).DelayEvent(passenger, evt, delayTime);
          } else {
            passenger.QueueEvent(evt);
          };
        };
      };
      if IsDefined(broadcaster) && broadcastHijack {
        broadcaster.SendDrirectStimuliToTarget(executionOwner, gamedataStimType.HijackVehicle, passenger);
      };
      i += 1;
    };
    if !IsDefined(passenger) {
      return false;
    };
    return true;
  }

  public final static func QueueHijackExitEventToDeadDriver(gi: GameInstance, vehicle: wref<VehicleObject>) -> Bool {
    let alive: Bool;
    let driver: wref<GameObject>;
    let workspotSystem: ref<WorkspotGameSystem>;
    if !GameInstance.IsValid(gi) || !IsDefined(vehicle) {
      return false;
    };
    driver = VehicleComponent.GetDriver(gi, vehicle.GetEntityID());
    if driver == null {
      return false;
    };
    alive = ScriptedPuppet.IsAlive(driver);
    if alive {
      return false;
    };
    workspotSystem = GameInstance.GetWorkspotSystem(vehicle.GetGame());
    workspotSystem.UnmountFromVehicle(vehicle, driver, false, n"deadstealing");
    VehicleComponent.OpenDoor(vehicle, VehicleComponent.GetDriverSlotID(), 1.00);
    return true;
  }

  public final static func CheckIfPassengersCanLeaveCar(gi: GameInstance, vehicleID: EntityID, out passengersCanLeaveCar: array<wref<GameObject>>, out passengersCantLeaveCar: array<wref<GameObject>>) -> Void {
    let active: Bool;
    let passenger: wref<GameObject>;
    let mountInfos: array<MountingInfo> = GameInstance.GetMountingFacility(gi).GetMountingInfoMultipleWithIds(vehicleID);
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(gi);
    let i: Int32 = 0;
    while i < ArraySize(mountInfos) {
      passenger = GameInstance.FindEntityByID(gi, mountInfos[i].childId) as GameObject;
      active = VehicleComponent.IsSlotOccupiedByActivePassenger(gi, vehicleID, mountInfos[i].slotId.id);
      if IsDefined(passenger) && active {
        if workspotSystem.HasExitNodes(passenger, true, false, true) {
          ArrayPush(passengersCanLeaveCar, passenger);
        } else {
          ArrayPush(passengersCantLeaveCar, passenger);
        };
      };
      i += 1;
    };
  }

  public final static func IsAnyPassengerCrowd(gi: GameInstance, vehicle: wref<VehicleObject>) -> Bool {
    let i: Int32;
    let mountInfos: array<MountingInfo>;
    let passenger: wref<NPCPuppet>;
    if !GameInstance.IsValid(gi) || !IsDefined(vehicle) {
      return false;
    };
    mountInfos = GameInstance.GetMountingFacility(gi).GetMountingInfoMultipleWithObjects(vehicle);
    i = 0;
    while i < ArraySize(mountInfos) {
      passenger = GameInstance.FindEntityByID(gi, mountInfos[i].childId) as NPCPuppet;
      if passenger.IsCrowd() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func IsSlotAvailable(gi: GameInstance, vehicle: wref<VehicleObject>, slotName: CName) -> Bool {
    if !IsDefined(vehicle) || !IsNameValid(slotName) {
      return false;
    };
    if !VehicleComponent.HasSlot(gi, vehicle, slotName) {
      return false;
    };
    if VehicleComponent.IsSlotOccupied(gi, vehicle.GetEntityID(), slotName) {
      return false;
    };
    return true;
  }

  public final static func IsSlotOccupied(gi: GameInstance, vehicleID: EntityID, slotName: CName) -> Bool {
    let vehicleSlotID: MountingSlotId;
    if !IsNameValid(slotName) {
      return false;
    };
    vehicleSlotID.id = slotName;
    if !VehicleComponent.IsSlotOccupied(gi, vehicleID, vehicleSlotID) {
      return false;
    };
    return true;
  }

  public final static func IsSlotOccupied(gi: GameInstance, vehicleID: EntityID, vehicleSlotID: MountingSlotId) -> Bool {
    let mountInfo: MountingInfo;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithIds(vehicleID, vehicleSlotID);
    if !EntityID.IsDefined(mountInfo.childId) {
      return false;
    };
    return true;
  }

  public final static func IsSlotOccupiedByActivePassenger(gi: GameInstance, vehicleID: EntityID, slotName: CName) -> Bool {
    let vehicleSlotID: MountingSlotId;
    if !IsNameValid(slotName) {
      return false;
    };
    vehicleSlotID.id = slotName;
    if !VehicleComponent.IsSlotOccupiedByActivePassenger(gi, vehicleID, vehicleSlotID) {
      return false;
    };
    return true;
  }

  public final static func IsSlotOccupiedByActivePassenger(gi: GameInstance, vehicleID: EntityID, vehicleSlotID: MountingSlotId) -> Bool {
    let mountInfo: MountingInfo;
    let passanger: wref<GameObject>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithIds(vehicleID, vehicleSlotID);
    if !EntityID.IsDefined(mountInfo.childId) {
      return false;
    };
    passanger = GameInstance.FindEntityByID(gi, mountInfo.childId) as GameObject;
    if !IsDefined(passanger) || !ScriptedPuppet.IsActive(passanger) {
      return false;
    };
    return true;
  }

  public final static func HasOnlyOneActivePassenger(gi: GameInstance, vehicleID: EntityID) -> Bool {
    let activePassangers: Int32;
    if !VehicleComponent.GetNumberOfActivePassengers(gi, vehicleID, activePassangers) {
      return false;
    };
    if activePassangers == 1 {
      return true;
    };
    return false;
  }

  public final static func GetNumberOfActivePassengers(gi: GameInstance, vehicleID: EntityID, out activePassangers: Int32) -> Bool {
    let i: Int32;
    let mountInfos: array<MountingInfo>;
    let passanger: wref<GameObject>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(vehicleID) {
      return false;
    };
    mountInfos = GameInstance.GetMountingFacility(gi).GetMountingInfoMultipleWithIds(vehicleID);
    i = 0;
    while i < ArraySize(mountInfos) {
      passanger = GameInstance.FindEntityByID(gi, mountInfos[i].childId) as GameObject;
      if IsDefined(passanger) && ScriptedPuppet.IsActive(passanger) {
        activePassangers += 1;
      };
      i += 1;
    };
    return true;
  }

  public final static func IsVehicleOccupied(gi: GameInstance, vehicle: wref<VehicleObject>) -> Bool {
    let mountInfo: MountingInfo;
    if !GameInstance.IsValid(gi) || !IsDefined(vehicle) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithObjects(vehicle);
    return IMountingFacility.InfoHasChild(mountInfo);
  }

  public final static func IsVehicleOccupiedByHostile(vehicleID: EntityID, passanger: wref<GameObject>) -> Bool {
    let attitudeOwner: ref<AttitudeAgent>;
    let attitudeTarget: ref<AttitudeAgent>;
    let i: Int32;
    let mountInfos: array<MountingInfo>;
    let target: wref<GameObject>;
    if !IsDefined(passanger) {
      return false;
    };
    attitudeOwner = passanger.GetAttitudeAgent();
    mountInfos = GameInstance.GetMountingFacility(passanger.GetGame()).GetMountingInfoMultipleWithIds(vehicleID);
    i = 0;
    while i < ArraySize(mountInfos) {
      if Equals(mountInfos[i].slotId.id, n"trunk_body") {
      } else {
        target = GameInstance.FindEntityByID(passanger.GetGame(), mountInfos[i].childId) as GameObject;
        if !IsDefined(target) || !ScriptedPuppet.IsActive(target) {
        } else {
          attitudeTarget = target.GetAttitudeAgent();
          if Equals(attitudeOwner.GetAttitudeTowards(attitudeTarget), EAIAttitude.AIA_Hostile) {
            return true;
          };
        };
      };
      i += 1;
    };
    return false;
  }

  public final func IsVehicleParked() -> Bool {
    return this.GetVehicle().IsVehicleParked();
  }

  public final static func SetAnimsetOverrideForPassenger(passenger: wref<GameObject>, value: Float) -> array<CName> {
    let animsetOverides: array<CName>;
    let mountInfo: MountingInfo;
    if !IsDefined(passenger) {
      return animsetOverides;
    };
    mountInfo = GameInstance.GetMountingFacility(passenger.GetGame()).GetMountingInfoSingleWithIds(passenger.GetEntityID());
    if !EntityID.IsDefined(mountInfo.parentId) {
      return animsetOverides;
    };
    return VehicleComponent.SetAnimsetOverrideForPassenger(passenger, mountInfo.parentId, mountInfo.slotId.id, value);
  }

  public final static func SetAnimsetOverrideForPassenger(passenger: wref<GameObject>, vehicleID: EntityID, slotName: CName, value: Float) -> array<CName> {
    let animsetOverides: array<CName>;
    let boneName: CName;
    let evt: ref<AnimWrapperWeightSetter>;
    let i: Int32;
    let vehicle: wref<VehicleObject>;
    if !IsDefined(passenger) {
      return animsetOverides;
    };
    if !EntityID.IsDefined(vehicleID) || !IsNameValid(slotName) {
      return animsetOverides;
    };
    vehicle = GameInstance.FindEntityByID(passenger.GetGame(), vehicleID) as VehicleObject;
    if !IsDefined(vehicle) {
      return animsetOverides;
    };
    if vehicle == (vehicle as BikeObject) {
      boneName = slotName;
    } else {
      boneName = vehicle.GetBoneNameFromSlot(slotName);
    };
    ArrayPush(animsetOverides, vehicle.GetAnimsetOverrideForPassenger(boneName));
    ArrayPush(animsetOverides, boneName);
    i = 0;
    while i < ArraySize(animsetOverides) {
      evt = new AnimWrapperWeightSetter();
      evt.key = animsetOverides[i];
      evt.value = value;
      passenger.QueueEvent(evt);
      i += 1;
    };
    return animsetOverides;
  }

  public final static func CheckVehicleDesiredTag(vehicle: wref<VehicleObject>, desiredTag: CName) -> Bool {
    let tags: array<CName>;
    let vehicleRecord: ref<Vehicle_Record>;
    if !VehicleComponent.GetVehicleRecord(vehicle, vehicleRecord) {
      return false;
    };
    tags = vehicleRecord.Tags();
    if ArrayContains(tags, desiredTag) {
      return true;
    };
    return false;
  }

  public final static func CheckVehicleDesiredTag(gi: GameInstance, owner: wref<GameObject>, desiredTag: CName) -> Bool {
    let vehicleRecord: ref<Vehicle_Record>;
    if !VehicleComponent.GetVehicleRecord(gi, owner, vehicleRecord) {
      return false;
    };
    if vehicleRecord.TagsContains(desiredTag) {
      return true;
    };
    return false;
  }

  public final static func GetVehicleType(gi: GameInstance, owner: wref<GameObject>, out type: String) -> Bool {
    let vehTypeRecord: ref<VehicleType_Record>;
    let vehicleRecord: ref<Vehicle_Record>;
    if !VehicleComponent.GetVehicleRecord(gi, owner, vehicleRecord) {
      return false;
    };
    vehTypeRecord = vehicleRecord.Type();
    type = vehTypeRecord.EnumName();
    return true;
  }

  public final static func GetAttitudeOfPassenger(gi: GameInstance, ownerID: EntityID, slotID: MountingSlotId, out attitude: EAIAttitude) -> Bool {
    let mountInfo: MountingInfo;
    let npcObject: wref<GameObject>;
    if !GameInstance.IsValid(gi) || !EntityID.IsDefined(ownerID) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithIds(ownerID, slotID);
    npcObject = GameInstance.FindEntityByID(gi, mountInfo.childId) as GameObject;
    attitude = GameObject.GetAttitudeTowards(GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject(), npcObject);
    return true;
  }

  public final static func GetVehicleNPCData(gi: GameInstance, owner: ref<GameObject>, out vehicleNPCData: ref<AnimFeature_VehicleNPCData>) -> Bool {
    let mountInfo: MountingInfo;
    let slotName: CName;
    if !GameInstance.IsValid(gi) || !IsDefined(owner) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithObjects(owner);
    slotName = mountInfo.slotId.id;
    if Equals(slotName, n"seat_front_left") || Equals(slotName, n"seat_back_left") {
      vehicleNPCData.side = 1;
    } else {
      if Equals(slotName, n"seat_front_right") || Equals(slotName, n"seat_back_right") {
        vehicleNPCData.side = 2;
      } else {
        vehicleNPCData.side = 0;
      };
    };
    if Equals(slotName, VehicleComponent.GetDriverSlotName()) {
      vehicleNPCData.isDriver = true;
    };
    return true;
  }

  public final static func HasSlot(gi: GameInstance, vehicle: wref<VehicleObject>, slotName: CName) -> Bool {
    let i: Int32;
    let seats: array<wref<VehicleSeat_Record>>;
    if !IsNameValid(slotName) || !VehicleComponent.GetSeats(gi, vehicle, seats) {
      return false;
    };
    i = 0;
    while i < ArraySize(seats) {
      if Equals(slotName, seats[i].SeatName()) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func GetMountedSlotName(gi: GameInstance, owner: wref<GameObject>, out slotName: CName) -> Bool {
    let mountInfo: MountingInfo;
    if !IsDefined(owner) {
      return false;
    };
    mountInfo = GameInstance.GetMountingFacility(gi).GetMountingInfoSingleWithObjects(owner);
    slotName = mountInfo.slotId.id;
    return true;
  }

  public final static func GetSeats(gi: GameInstance, vehicle: wref<VehicleObject>, out seats: array<wref<VehicleSeat_Record>>) -> Bool {
    let seatSet: wref<VehicleSeatSet_Record>;
    let vehicleDataPackage: wref<VehicleDataPackage_Record>;
    let vehicleRecord: ref<Vehicle_Record>;
    if !VehicleComponent.GetVehicleRecord(vehicle, vehicleRecord) {
      return false;
    };
    vehicleDataPackage = vehicleRecord.VehDataPackage();
    if !IsDefined(vehicleDataPackage) {
      return false;
    };
    seatSet = vehicleDataPackage.VehSeatSet();
    if !IsDefined(seatSet) {
      return false;
    };
    seatSet.VehSeats(seats);
    if ArraySize(seats) == 0 {
      return false;
    };
    return true;
  }

  public final static func GetFirstAvailableSlot(gi: GameInstance, vehicle: wref<VehicleObject>, out slotName: CName) -> Bool {
    let i: Int32;
    let seats: array<wref<VehicleSeat_Record>>;
    if !VehicleComponent.GetSeats(gi, vehicle, seats) {
      return false;
    };
    i = 0;
    while i < ArraySize(seats) {
      slotName = seats[i].SeatName();
      if !VehicleComponent.IsSlotOccupied(gi, vehicle.GetEntityID(), slotName) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func GetNumberOfOccupiedSlots(gi: GameInstance, vehicle: wref<VehicleObject>) -> Int32 {
    let i: Int32;
    let occupiedSlots: Int32;
    let seats: array<wref<VehicleSeat_Record>>;
    let slotName: CName;
    if !VehicleComponent.GetSeats(gi, vehicle, seats) {
      return occupiedSlots;
    };
    i = 0;
    while i < ArraySize(seats) {
      slotName = seats[i].SeatName();
      if VehicleComponent.IsSlotOccupied(gi, vehicle.GetEntityID(), slotName) {
        occupiedSlots += 1;
      };
      i += 1;
    };
    return occupiedSlots;
  }

  public final static func GetVehicleDataPackage(gi: GameInstance, vehicle: wref<VehicleObject>, out vehDataPackage: wref<VehicleDataPackage_Record>) -> Bool {
    let vehicleRecord: ref<Vehicle_Record>;
    if !GameInstance.IsValid(gi) || !IsDefined(vehicle) {
      return false;
    };
    VehicleComponent.GetVehicleRecord(vehicle, vehicleRecord);
    vehDataPackage = vehicleRecord.VehDataPackage();
    return true;
  }

  public final static func GetVehicleAllowsCombat(gi: GameInstance, vehicle: wref<VehicleObject>) -> Bool {
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    if !GameInstance.IsValid(gi) || !IsDefined(vehicle) {
      return false;
    };
    VehicleComponent.GetVehicleDataPackage(gi, vehicle, vehDataPackage);
    return vehDataPackage.SupportsCombat();
  }

  public final static func ToggleVehicleWindow(gi: GameInstance, vehicle: wref<VehicleObject>, slotID: MountingSlotId, toggle: Bool, opt speed: CName) -> Bool {
    let windowToggleEvent: ref<VehicleExternalWindowRequestEvent>;
    if !GameInstance.IsValid(gi) || !IsDefined(vehicle) {
      return false;
    };
    windowToggleEvent = new VehicleExternalWindowRequestEvent();
    windowToggleEvent.slotName = slotID.id;
    windowToggleEvent.shouldOpen = toggle;
    windowToggleEvent.speed = speed;
    vehicle.QueueEvent(windowToggleEvent);
    return true;
  }

  protected final const func GetVehicle() -> wref<VehicleObject> {
    return this.GetEntity() as VehicleObject;
  }

  private final func GetVehicleController() -> ref<vehicleController> {
    if this.m_vehicleController == null {
      this.m_vehicleController = (this.GetEntity() as VehicleObject).GetController();
    };
    return this.m_vehicleController;
  }

  private final func GetVehicleControllerPS() -> ref<vehicleControllerPS> {
    let persistentId: PersistentID = CreatePersistentID(this.GetEntity().GetEntityID(), n"VehicleController");
    let vehicleControllerPS: ref<vehicleControllerPS> = GameInstance.GetPersistencySystem((this.GetEntity() as VehicleObject).GetGame()).GetConstAccessToPSObject(persistentId, n"gamevehicleControllerPS") as vehicleControllerPS;
    return vehicleControllerPS;
  }

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }

  public final static func OpenDoor(vehicle: wref<VehicleObject>, vehicleSlotID: MountingSlotId, opt delay: Float) -> Bool {
    let doorOpenRequest: ref<VehicleDoorOpen>;
    let persistentId: PersistentID;
    if !IsDefined(vehicle) {
      return false;
    };
    persistentId = CreatePersistentID(vehicle.GetEntityID(), n"controller");
    doorOpenRequest = new VehicleDoorOpen();
    if Equals(vehicleSlotID.id, n"trunk") || Equals(vehicleSlotID.id, n"hood") {
      doorOpenRequest.slotID = vehicleSlotID.id;
    } else {
      doorOpenRequest.slotID = vehicle.GetBoneNameFromSlot(vehicleSlotID.id);
    };
    doorOpenRequest.shouldAutoClose = false;
    if delay > 0.00 {
      GameInstance.GetDelaySystem(vehicle.GetGame()).DelayPSEvent(persistentId, n"VehicleComponentPS", doorOpenRequest, delay);
    } else {
      GameInstance.GetPersistencySystem(vehicle.GetGame()).QueuePSEvent(persistentId, n"VehicleComponentPS", doorOpenRequest);
    };
    return true;
  }

  public final static func CloseDoor(vehicle: wref<VehicleObject>, vehicleSlotID: MountingSlotId) -> Bool {
    let doorOpenRequest: ref<VehicleDoorClose>;
    let persistentId: PersistentID;
    if !IsDefined(vehicle) {
      return false;
    };
    persistentId = CreatePersistentID(vehicle.GetEntityID(), n"controller");
    doorOpenRequest = new VehicleDoorClose();
    if Equals(vehicleSlotID.id, n"trunk") || Equals(vehicleSlotID.id, n"hood") {
      doorOpenRequest.slotID = vehicleSlotID.id;
    } else {
      doorOpenRequest.slotID = vehicle.GetBoneNameFromSlot(vehicleSlotID.id);
    };
    GameInstance.GetPersistencySystem(vehicle.GetGame()).QueuePSEvent(persistentId, n"VehicleComponentPS", doorOpenRequest);
    return true;
  }

  protected cb func OnMountingEvent(evt: ref<MountingEvent>) -> Bool {
    let PSvehicleDooropenRequest: ref<VehicleDoorOpen>;
    let vehicleDataPackage: wref<VehicleDataPackage_Record>;
    let vehicleNPCData: ref<AnimFeature_VehicleNPCData>;
    let mountChild: ref<GameObject> = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), evt.request.lowLevelMountingInfo.childId) as GameObject;
    VehicleComponent.GetVehicleDataPackage(this.GetVehicle().GetGame(), this.GetVehicle(), vehicleDataPackage);
    if mountChild.IsPlayer() {
      this.m_mountedPlayer = mountChild as PlayerPuppet;
      VehicleComponent.QueueEventToAllPassengers(this.m_mountedPlayer.GetGame(), this.GetVehicle().GetEntityID(), PlayerMuntedToMyVehicle.Create(this.m_mountedPlayer));
      PlayerPuppet.ReevaluateAllBreathingEffects(mountChild as PlayerPuppet);
      if !this.GetVehicle().IsCrowdVehicle() {
        this.GetVehicle().GetDeviceLink().TriggerSecuritySystemNotification(this.GetVehicle().GetWorldPosition(), mountChild, ESecurityNotificationType.ALARM);
      };
      this.ToggleScanningComponent(false);
      if this.GetVehicle().GetHudManager().IsRegistered(this.GetVehicle().GetEntityID()) {
        this.RegisterToHUDManager(false);
      };
      this.RegisterInputListener();
      FastTravelSystem.AddFastTravelLock(n"InVehicle", this.GetVehicle().GetGame());
      this.m_mounted = true;
      this.m_ignoreAutoDoorClose = true;
      this.SetupListeners();
      this.DisableTargetingComponents();
      if EntityID.IsDefined(evt.request.mountData.mountEventOptions.entityID) {
        this.m_enterTime = vehicleDataPackage.Stealing() + vehicleDataPackage.SlideDuration();
      } else {
        this.m_enterTime = vehicleDataPackage.Entering() + vehicleDataPackage.SlideDuration();
      };
      this.DrivingStimuli(true);
      if Equals(evt.request.lowLevelMountingInfo.slotId.id, VehicleComponent.GetDriverSlotName()) {
        if IsDefined(this.GetVehicle() as TankObject) {
          this.TogglePlayerHitShapesForPanzer(this.m_mountedPlayer, false);
          this.ToggleTargetingSystemForPanzer(this.m_mountedPlayer, true);
        };
        this.SetSteeringLimitAnimFeature(1);
      };
      if evt.request.mountData.isInstant {
        this.DetermineShouldCrystalDomeBeOn(0.00);
      } else {
        this.DetermineShouldCrystalDomeBeOn(0.75);
      };
    };
    if !mountChild.IsPlayer() {
      if evt.request.mountData.isInstant {
        mountChild.QueueEvent(CreateDisableRagdollEvent());
      };
      vehicleNPCData = new AnimFeature_VehicleNPCData();
      VehicleComponent.GetVehicleNPCData(this.GetVehicle().GetGame(), mountChild, vehicleNPCData);
      AnimationControllerComponent.ApplyFeatureToReplicate(mountChild, n"VehicleNPCData", vehicleNPCData);
      AnimationControllerComponent.PushEventToReplicate(mountChild, n"VehicleNPCData");
      if mountChild.IsPuppet() && !this.GetVehicle().IsPlayerVehicle() && (IsHostileTowardsPlayer(mountChild) || (mountChild as ScriptedPuppet).IsAggressive()) {
        this.EnableTargetingComponents();
      };
    };
    if !evt.request.mountData.isInstant {
      PSvehicleDooropenRequest = new VehicleDoorOpen();
      PSvehicleDooropenRequest.slotID = this.GetVehicle().GetBoneNameFromSlot(evt.request.lowLevelMountingInfo.slotId.id);
      if EntityID.IsDefined(evt.request.mountData.mountEventOptions.entityID) {
        PSvehicleDooropenRequest.autoCloseTime = vehicleDataPackage.Stealing_open();
      } else {
        PSvehicleDooropenRequest.autoCloseTime = vehicleDataPackage.Normal_open();
      };
      if !(this.GetPS() as VehicleComponentPS).GetIsDestroyed() {
        PSvehicleDooropenRequest.shouldAutoClose = true;
      };
      GameInstance.GetPersistencySystem(this.GetVehicle().GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), PSvehicleDooropenRequest);
    };
    this.ManageAdditionalAnimFeatures(mountChild, true);
  }

  protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
    let activePassengers: Int32;
    let engineOn: Bool;
    let turnedOn: Bool;
    let mountChild: ref<GameObject> = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), evt.request.lowLevelMountingInfo.childId) as GameObject;
    VehicleComponent.SetAnimsetOverrideForPassenger(mountChild, evt.request.lowLevelMountingInfo.parentId, evt.request.lowLevelMountingInfo.slotId.id, 0.00);
    if IsDefined(mountChild) && mountChild.IsPlayer() {
      PlayerPuppet.ReevaluateAllBreathingEffects(mountChild as PlayerPuppet);
      this.ToggleScanningComponent(true);
      if this.GetVehicle().ShouldRegisterToHUD() {
        this.RegisterToHUDManager(true);
      };
      this.UnregisterInputListener();
      FastTravelSystem.RemoveFastTravelLock(n"InVehicle", this.GetVehicle().GetGame());
      this.m_mounted = false;
      this.UnregisterListeners();
      this.ToggleSiren(false, false);
      if this.m_broadcasting {
        this.DrivingStimuli(false);
      };
      if Equals(evt.request.lowLevelMountingInfo.slotId.id, n"seat_front_left") {
        turnedOn = this.GetVehicle().IsTurnedOn();
        engineOn = this.GetVehicle().IsEngineTurnedOn();
        if turnedOn {
          turnedOn = !turnedOn;
        };
        if engineOn {
          engineOn = !engineOn;
        };
        this.ToggleVehicleSystems(false, turnedOn, engineOn);
        this.GetVehicleControllerPS().SetState(vehicleEState.Default);
        this.SetSteeringLimitAnimFeature(0);
        this.m_ignoreAutoDoorClose = false;
      };
      this.DoPanzerCleanup();
      this.m_mountedPlayer = null;
      this.CleanUpRace();
    };
    if IsDefined(mountChild) && VehicleComponent.GetNumberOfActivePassengers(mountChild.GetGame(), this.GetVehicle().GetEntityID(), activePassengers) {
      if activePassengers <= 0 {
        this.DisableTargetingComponents();
      };
    };
    this.ManageAdditionalAnimFeatures(mountChild, false);
  }

  protected cb func OnVehicleFinishedMountingEvent(evt: ref<VehicleFinishedMountingEvent>) -> Bool {
    let isDestroyed: Bool;
    if evt.isMounting {
      isDestroyed = (this.GetPS() as VehicleComponentPS).GetIsDestroyed();
      if !isDestroyed {
        if Equals(evt.slotID, VehicleComponent.GetDriverSlotName()) {
          this.ToggleVehicleSystems(true, true, true);
        };
      };
    };
    this.m_ignoreAutoDoorClose = false;
  }

  protected cb func OnVehicleStartedUnmountingEvent(evt: ref<VehicleStartedUnmountingEvent>) -> Bool;

  protected cb func OnVehicleStartedMountingEvent(evt: ref<VehicleStartedMountingEvent>) -> Bool {
    if !evt.isMounting {
      this.SendVehicleStartedUnmountingEventToPS(evt.isMounting, evt.slotID, evt.character);
      if Equals(evt.slotID, n"seat_front_left") {
        this.ToggleVehicleSystems(false, true, true);
        this.GetVehicleControllerPS().SetState(vehicleEState.Default);
      };
    } else {
      this.GetVehicle().SendDelayedFinishedMountingEventToPS(evt.isMounting, evt.slotID, evt.character, evt.instant ? 0.00 : this.m_enterTime);
    };
  }

  protected final func SendVehicleStartedUnmountingEventToPS(isMounting: Bool, slotID: CName, character: ref<GameObject>) -> Void {
    let evt: ref<VehicleStartedUnmountingEvent> = new VehicleStartedUnmountingEvent();
    evt.slotID = slotID;
    evt.isMounting = isMounting;
    evt.character = character;
    GameInstance.GetPersistencySystem(this.GetVehicle().GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), evt);
  }

  protected final func SetSteeringLimitAnimFeature(limit: Int32) -> Void {
    let steeringLimitAnimFeature: ref<AnimFeature_VehicleSteeringLimit> = new AnimFeature_VehicleSteeringLimit();
    steeringLimitAnimFeature.state = limit;
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), n"SteeringLimit", steeringLimitAnimFeature);
  }

  protected final func ManageAdditionalAnimFeatures(object: ref<GameObject>, value: Bool) -> Void {
    let animFeature: ref<AnimFeature_NPCVehicleAdditionalFeatures>;
    let animFeatureName: CName;
    let animFeatures: array<CName>;
    let i: Int32;
    let vehicleDataPackage: wref<VehicleDataPackage_Record>;
    VehicleComponent.GetVehicleDataPackage(this.GetVehicle().GetGame(), this.GetVehicle(), vehicleDataPackage);
    animFeatures = vehicleDataPackage.AdditionalAnimFeatures();
    if ArraySize(animFeatures) == 0 {
      return;
    };
    i = 0;
    while i < ArraySize(animFeatures) {
      animFeature = new AnimFeature_NPCVehicleAdditionalFeatures();
      animFeatureName = animFeatures[i];
      animFeature.state = value;
      AnimationControllerComponent.ApplyFeatureToReplicate(object, animFeatureName, animFeature);
      i += 1;
    };
  }

  protected cb func OnVehicleSeatReservationEvent(evt: ref<VehicleSeatReservationEvent>) -> Bool;

  protected cb func OnVehicleBodyDisposalPerformedEvent(evt: ref<VehicleBodyDisposalPerformedEvent>) -> Bool {
    this.DetermineInteractionState(n"trunk");
  }

  protected final func DetermineInteractionState() -> Void {
    let activeInteractions: array<gameinteractionsActiveLayerData>;
    let activeLayerData: gameinteractionsActiveLayerData;
    let context: VehicleActionsContext;
    let i: Int32;
    this.m_interaction.GetActiveInputLayers(activeInteractions);
    i = 0;
    while i < ArraySize(activeInteractions) {
      activeLayerData = activeInteractions[i];
      context.requestorID = this.GetVehicle().GetEntityID();
      context.processInitiatorObject = activeLayerData.activator;
      context.interactionLayerTag = activeLayerData.layerName;
      context.eventType = gameinteractionsEInteractionEventType.EIET_activate;
      (this.GetPS() as VehicleComponentPS).DetermineActionsToPush(this.m_interaction, context, this.m_objectActionsCallbackCtrl, true);
      i += 1;
    };
  }

  protected final func DetermineInteractionState(layerName: CName) -> Void {
    let activeInteractions: array<gameinteractionsActiveLayerData>;
    let activeLayerData: gameinteractionsActiveLayerData;
    let context: VehicleActionsContext;
    let i: Int32;
    this.m_interaction.GetActivatorsForLayer(layerName, activeInteractions);
    i = 0;
    while i < ArraySize(activeInteractions) {
      activeLayerData = activeInteractions[i];
      context.requestorID = this.GetVehicle().GetEntityID();
      context.processInitiatorObject = activeLayerData.activator;
      context.interactionLayerTag = layerName;
      context.eventType = gameinteractionsEInteractionEventType.EIET_activate;
      (this.GetPS() as VehicleComponentPS).DetermineActionsToPush(this.m_interaction, context, this.m_objectActionsCallbackCtrl, true);
      i += 1;
    };
  }

  protected final func GetIsMounted() -> Bool {
    return this.m_mounted;
  }

  private final func InitialVehcileSetup() -> Void {
    let lightEvent: ref<VehicleLightSetupEvent>;
    this.m_overheatActive = false;
    this.SetupAuxillary();
    this.VehicleDefaultStateSetup();
    this.EvaluateInteractions();
    this.EvaluateDoorState();
    this.EvaluateWindowState();
    this.SendParkEvent(true);
    lightEvent = new VehicleLightSetupEvent();
    this.GetVehicle().QueueEvent(lightEvent);
    this.SetupCrystalDome();
    this.SetupWheels();
    this.ShouldVisualDestructionBeSet();
  }

  private final func VehicleDefaultStateSetup() -> Void {
    let door: EVehicleDoor;
    let i: Int32;
    let seatStateRecord: ref<SeatState_Record>;
    let sirenDelayEvent: ref<VehicleSirenDelayEvent>;
    let sirenLight: Bool;
    let sirenSound: Bool;
    let spawnDestroyed: Bool;
    let state: EQuestVehicleDoorState;
    let thrusters: Bool;
    let recordID: TweakDBID = this.GetVehicle().GetRecordID();
    let record: ref<Vehicle_Record> = TweakDBInterface.GetVehicleRecord(recordID);
    let defaultState: ref<VehicleDefaultState_Record> = record.VehDefaultState();
    let size: Int32 = EnumInt(EVehicleDoor.count);
    if !(this.GetPS() as VehicleComponentPS).GetHasDefaultStateBeenSet() {
      if defaultState.DisableAllInteractions() {
        state = EQuestVehicleDoorState.DisableAllInteractions;
        this.CreateAndSendDefaultStateEvent(door, state);
      };
      if defaultState.LockAll() || this.IsVehicleParked() {
        state = EQuestVehicleDoorState.LockAll;
        this.CreateAndSendDefaultStateEvent(door, state);
      };
      if defaultState.OpenAll() {
        state = EQuestVehicleDoorState.OpenAll;
        this.CreateAndSendDefaultStateEvent(door, state);
      };
      if defaultState.CloseAll() {
        state = EQuestVehicleDoorState.CloseAll;
        this.CreateAndSendDefaultStateEvent(door, state);
      };
      if defaultState.QuestLockAll() {
        state = EQuestVehicleDoorState.QuestLockAll;
        this.CreateAndSendDefaultStateEvent(door, state);
      };
      i = 0;
      while i < size {
        switch IntEnum(i) {
          case EVehicleDoor.seat_front_left:
            seatStateRecord = defaultState.Seat_front_left();
            if IsDefined(seatStateRecord) {
              door = EVehicleDoor.seat_front_left;
              if seatStateRecord.EnableInteraction() {
                state = EQuestVehicleDoorState.EnableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.DisableInteraction() {
                state = EQuestVehicleDoorState.DisableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceOpen() {
                state = EQuestVehicleDoorState.ForceOpen;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceClose() {
                state = EQuestVehicleDoorState.ForceClose;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceLock() {
                state = EQuestVehicleDoorState.ForceLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceUnlock() {
                state = EQuestVehicleDoorState.ForceUnlock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.QuestLock() {
                state = EQuestVehicleDoorState.QuestLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
            };
            break;
          case EVehicleDoor.seat_front_right:
            seatStateRecord = defaultState.Seat_front_right();
            if IsDefined(seatStateRecord) {
              door = EVehicleDoor.seat_front_right;
              if seatStateRecord.EnableInteraction() {
                state = EQuestVehicleDoorState.EnableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.DisableInteraction() {
                state = EQuestVehicleDoorState.DisableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceOpen() {
                state = EQuestVehicleDoorState.ForceOpen;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceClose() {
                state = EQuestVehicleDoorState.ForceClose;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceLock() {
                state = EQuestVehicleDoorState.ForceLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceUnlock() {
                state = EQuestVehicleDoorState.ForceUnlock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.QuestLock() {
                state = EQuestVehicleDoorState.QuestLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
            };
            break;
          case EVehicleDoor.seat_back_left:
            seatStateRecord = defaultState.Seat_back_left();
            if IsDefined(seatStateRecord) {
              door = EVehicleDoor.seat_back_left;
              if seatStateRecord.EnableInteraction() {
                state = EQuestVehicleDoorState.EnableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.DisableInteraction() {
                state = EQuestVehicleDoorState.DisableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceOpen() {
                state = EQuestVehicleDoorState.ForceOpen;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceClose() {
                state = EQuestVehicleDoorState.ForceClose;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceLock() {
                state = EQuestVehicleDoorState.ForceLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceUnlock() {
                state = EQuestVehicleDoorState.ForceUnlock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.QuestLock() {
                state = EQuestVehicleDoorState.QuestLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
            };
            break;
          case EVehicleDoor.seat_back_right:
            seatStateRecord = defaultState.Seat_back_right();
            if IsDefined(seatStateRecord) {
              door = EVehicleDoor.seat_back_right;
              if seatStateRecord.EnableInteraction() {
                state = EQuestVehicleDoorState.EnableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.DisableInteraction() {
                state = EQuestVehicleDoorState.DisableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceOpen() {
                state = EQuestVehicleDoorState.ForceOpen;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceClose() {
                state = EQuestVehicleDoorState.ForceClose;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceLock() {
                state = EQuestVehicleDoorState.ForceLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceUnlock() {
                state = EQuestVehicleDoorState.ForceUnlock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.QuestLock() {
                state = EQuestVehicleDoorState.QuestLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
            };
            break;
          case EVehicleDoor.trunk:
            seatStateRecord = defaultState.Trunk();
            if IsDefined(seatStateRecord) {
              door = EVehicleDoor.trunk;
              if seatStateRecord.EnableInteraction() {
                state = EQuestVehicleDoorState.EnableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.DisableInteraction() {
                state = EQuestVehicleDoorState.DisableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceOpen() {
                state = EQuestVehicleDoorState.ForceOpen;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceClose() {
                state = EQuestVehicleDoorState.ForceClose;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceLock() {
                state = EQuestVehicleDoorState.ForceLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceUnlock() {
                state = EQuestVehicleDoorState.ForceUnlock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.QuestLock() {
                state = EQuestVehicleDoorState.QuestLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
            };
            break;
          case EVehicleDoor.hood:
            seatStateRecord = defaultState.Hood();
            if IsDefined(seatStateRecord) {
              door = EVehicleDoor.hood;
              if seatStateRecord.EnableInteraction() {
                state = EQuestVehicleDoorState.EnableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.DisableInteraction() {
                state = EQuestVehicleDoorState.DisableInteraction;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceOpen() {
                state = EQuestVehicleDoorState.ForceOpen;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceClose() {
                state = EQuestVehicleDoorState.ForceClose;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceLock() {
                state = EQuestVehicleDoorState.ForceLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.ForceUnlock() {
                state = EQuestVehicleDoorState.ForceUnlock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
              if seatStateRecord.QuestLock() {
                state = EQuestVehicleDoorState.QuestLock;
                this.CreateAndSendDefaultStateEvent(door, state);
              };
            };
            break;
          default:
        };
        i += 1;
      };
      sirenLight = defaultState.SirenLight();
      sirenSound = defaultState.SirenSounds();
      if sirenLight || sirenSound {
        sirenDelayEvent = new VehicleSirenDelayEvent();
        sirenDelayEvent.lights = sirenLight;
        sirenDelayEvent.sounds = sirenSound;
        GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), sirenDelayEvent, 0.50);
      };
      thrusters = defaultState.Thrusters();
      if thrusters {
        (this.GetPS() as VehicleComponentPS).SetThrusterState(true);
      };
    };
    spawnDestroyed = defaultState.SpawnDestroyed();
    if spawnDestroyed {
      (this.GetPS() as VehicleComponentPS).SetIsDestroyed(true);
      if !this.m_submerged {
        (this.GetPS() as VehicleComponentPS).SetHasExploded(true);
      };
    };
  }

  private final func CreateAndSendDefaultStateEvent(door: EVehicleDoor, state: EQuestVehicleDoorState) -> Void {
    let vehicleQuestEvent: ref<VehicleQuestChangeDoorStateEvent> = new VehicleQuestChangeDoorStateEvent();
    vehicleQuestEvent.door = door;
    vehicleQuestEvent.newState = state;
    GameInstance.GetPersistencySystem(this.GetVehicle().GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), vehicleQuestEvent);
    (this.GetPS() as VehicleComponentPS).SetHasDefaultStateBeenSet(true);
  }

  private final func ShouldVisualDestructionBeSet() -> Void {
    let vehVisualDestroRecord: wref<VehicleVisualDestruction_Record> = this.GetVehicle().GetRecord().VisualDestruction();
    if IsDefined(vehVisualDestroRecord) && vehVisualDestroRecord.SetVisualDestruction() {
      this.VehicleVisualDestructionSetup();
    };
  }

  private final func VehicleVisualDestructionSetup() -> Void {
    let i: Int32;
    let pointValues: Float[15];
    let vehVisualDestroRecord: wref<VehicleVisualDestruction_Record> = this.GetVehicle().GetRecord().VisualDestruction();
    pointValues[0] = vehVisualDestroRecord.BackLeft();
    pointValues[1] = vehVisualDestroRecord.Back();
    pointValues[2] = vehVisualDestroRecord.BackRight();
    pointValues[3] = vehVisualDestroRecord.Left();
    pointValues[4] = 0.00;
    pointValues[5] = vehVisualDestroRecord.Right();
    pointValues[6] = vehVisualDestroRecord.Left();
    pointValues[7] = 0.00;
    pointValues[8] = vehVisualDestroRecord.Right();
    pointValues[9] = vehVisualDestroRecord.Left();
    pointValues[10] = 0.00;
    pointValues[11] = vehVisualDestroRecord.Right();
    pointValues[12] = vehVisualDestroRecord.FrontLeft();
    pointValues[13] = vehVisualDestroRecord.Front();
    pointValues[14] = vehVisualDestroRecord.FrontRight();
    this.GetVehicle().SetDestructionGridPointValues(0u, pointValues, false);
    i = 0;
    while i < ArraySize(pointValues) {
      pointValues[i] = vehVisualDestroRecord.Roof();
      i += 1;
    };
    this.GetVehicle().SetDestructionGridPointValues(1u, pointValues, false);
  }

  protected cb func OnVehicleQuestVisualDestructionEvent(evt: ref<VehicleQuestVisualDestructionEvent>) -> Bool {
    let i: Int32;
    let pointValues: Float[15];
    pointValues[0] = evt.backLeft;
    pointValues[1] = evt.back;
    pointValues[2] = evt.backRight;
    pointValues[3] = evt.left;
    pointValues[4] = 0.00;
    pointValues[5] = evt.right;
    pointValues[6] = evt.left;
    pointValues[7] = 0.00;
    pointValues[8] = evt.right;
    pointValues[9] = evt.left;
    pointValues[10] = 0.00;
    pointValues[11] = evt.right;
    pointValues[12] = evt.frontLeft;
    pointValues[13] = evt.front;
    pointValues[14] = evt.frontRight;
    this.GetVehicle().SetDestructionGridPointValues(0u, pointValues, evt.accumulate);
    i = 0;
    while i < ArraySize(pointValues) {
      pointValues[i] = evt.roof;
      i += 1;
    };
    this.GetVehicle().SetDestructionGridPointValues(1u, pointValues, evt.accumulate);
  }

  private final func EvaluateInteractions() -> Void {
    this.EvaluateTrunkAndHoodInteractions();
    if VehicleComponent.CheckVehicleDesiredTag(this.GetVehicle(), n"player_bike") {
      this.ToggleVehReadyInteractions(true);
    };
    this.ToggleInitialVehDoorInteractions();
  }

  private final func ToggleInitialVehDoorInteractions() -> Void {
    let i: Int32;
    let seats: array<wref<VehicleSeat_Record>>;
    let evt: ref<InteractionMultipleSetEnableEvent> = new InteractionMultipleSetEnableEvent();
    VehicleComponent.GetSeats(this.GetVehicle().GetGame(), this.GetVehicle(), seats);
    i = 0;
    while i < ArraySize(seats) {
      evt.PushBack(true, seats[i].SeatName());
      i += 1;
    };
    this.GetVehicle().QueueEvent(evt);
  }

  private final func EvaluateTrunkAndHoodInteractions() -> Void {
    let evt: ref<InteractionMultipleSetEnableEvent> = new InteractionMultipleSetEnableEvent();
    evt.PushBack(true, n"trunk");
    evt.PushBack(true, n"hood");
    this.GetVehicle().QueueEvent(evt);
  }

  private final func EvaluateTrunkInteractions() -> Void {
    this.ToggleInteraction(n"trunk", true);
  }

  private final func EvaluateHoodInteractions() -> Void {
    this.ToggleInteraction(n"hood", true);
  }

  protected final func ToggleVehReadyInteractions(toggle: Bool, opt layer: CName) -> Void {
    let evt: ref<InteractionMultipleSetEnableEvent> = new InteractionMultipleSetEnableEvent();
    if IsNameValid(layer) {
      evt.PushBack(toggle, layer);
    } else {
      evt.PushBack(toggle, n"PuppetClose");
      evt.PushBack(toggle, n"PuppetFar");
    };
    this.GetVehicle().QueueEvent(evt);
  }

  private final func EvaluateDoorState() -> Void {
    let state: VehicleDoorState;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      state = (this.GetPS() as VehicleComponentPS).GetDoorState(IntEnum(i));
      this.SetDoorAnimFeatureData(IntEnum(i), state);
      i += 1;
    };
  }

  protected final func SetDoorAnimFeatureData(door: EVehicleDoor, state: VehicleDoorState) -> Void {
    let animFeature: ref<AnimFeature_PartData>;
    let animFeatureName: CName;
    if Equals(state, VehicleDoorState.Open) {
      animFeature = new AnimFeature_PartData();
      animFeature.state = 2;
      animFeatureName = EnumValueToName(n"EVehicleDoor", EnumInt(door));
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), animFeatureName, animFeature);
    };
  }

  protected cb func OnVehicleLightSetupEvent(evt: ref<VehicleLightSetupEvent>) -> Bool {
    let vehicleRecord: ref<Vehicle_Record> = this.GetVehicle().GetRecord();
    let headlightCount: Int32 = vehicleRecord.GetHeadlightColorCount();
    let interiorlightCount: Int32 = vehicleRecord.GetInteriorColorCount();
    let brakelightCount: Int32 = vehicleRecord.GetBrakelightColorCount();
    let leftBlinkerlightCount: Int32 = vehicleRecord.GetLeftBlinkerlightColorCount();
    let rightBLinkerlightCount: Int32 = vehicleRecord.GetRightBLinkerlightColorCount();
    let reverselightCount: Int32 = vehicleRecord.GetReverselightColorCount();
    if headlightCount == 4 {
      this.GetVehicleController().SetLightColor(vehicleELightType.Head, new Color(Cast(vehicleRecord.GetHeadlightColorItem(0)), Cast(vehicleRecord.GetHeadlightColorItem(1)), Cast(vehicleRecord.GetHeadlightColorItem(2)), Cast(vehicleRecord.GetHeadlightColorItem(3))));
    };
    if interiorlightCount == 4 {
      this.GetVehicleController().SetLightColor(vehicleELightType.Interior, new Color(Cast(vehicleRecord.GetInteriorColorItem(0)), Cast(vehicleRecord.GetInteriorColorItem(1)), Cast(vehicleRecord.GetInteriorColorItem(2)), Cast(vehicleRecord.GetInteriorColorItem(3))));
    };
    if brakelightCount == 4 {
      this.GetVehicleController().SetLightColor(vehicleELightType.Brake, new Color(Cast(vehicleRecord.GetBrakelightColorItem(0)), Cast(vehicleRecord.GetBrakelightColorItem(1)), Cast(vehicleRecord.GetBrakelightColorItem(2)), Cast(vehicleRecord.GetBrakelightColorItem(3))));
    };
    if leftBlinkerlightCount == 4 {
      this.GetVehicleController().SetLightColor(vehicleELightType.LeftBlinker, new Color(Cast(vehicleRecord.GetLeftBlinkerlightColorItem(0)), Cast(vehicleRecord.GetLeftBlinkerlightColorItem(1)), Cast(vehicleRecord.GetLeftBlinkerlightColorItem(2)), Cast(vehicleRecord.GetLeftBlinkerlightColorItem(3))));
    };
    if rightBLinkerlightCount == 4 {
      this.GetVehicleController().SetLightColor(vehicleELightType.RightBlinker, new Color(Cast(vehicleRecord.GetRightBLinkerlightColorItem(0)), Cast(vehicleRecord.GetRightBLinkerlightColorItem(1)), Cast(vehicleRecord.GetRightBLinkerlightColorItem(2)), Cast(vehicleRecord.GetRightBLinkerlightColorItem(3))));
    };
    if reverselightCount == 4 {
      this.GetVehicleController().SetLightColor(vehicleELightType.Reverse, new Color(Cast(vehicleRecord.GetReverselightColorItem(0)), Cast(vehicleRecord.GetReverselightColorItem(1)), Cast(vehicleRecord.GetReverselightColorItem(2)), Cast(vehicleRecord.GetReverselightColorItem(3))));
    };
  }

  private final func RegisterInputListener() -> Void {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    playerPuppet.RegisterInputListener(this, n"VehicleInsideWheel");
    playerPuppet.RegisterInputListener(this, n"VehicleHorn");
  }

  private final func UnregisterInputListener() -> Void {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(playerPuppet) {
      playerPuppet.UnregisterInputListener(this);
    };
  }

  private final func LoadExplodedState() -> Void {
    let destroyedAppearanceName: CName;
    let vehicleRecord: ref<Vehicle_Record>;
    if (this.GetPS() as VehicleComponentPS).GetHasExploded() {
      vehicleRecord = this.GetVehicle().GetRecord();
      destroyedAppearanceName = vehicleRecord.DestroyedAppearance();
      if IsNameValid(destroyedAppearanceName) {
        this.GetVehicle().ScheduleAppearanceChange(destroyedAppearanceName);
      };
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"fire", false);
      this.GetVehicle().DetachAllParts();
    };
  }

  private final func SetupThrusterFX() -> Void {
    let toggle: Bool = (this.GetPS() as VehicleComponentPS).GetThrusterState();
    if toggle {
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"thrusters", true);
    } else {
      GameObjectEffectHelper.BreakEffectLoopEvent(this.GetVehicle(), n"thrusters");
    };
  }

  protected final func ToggleScanningComponent(toggle: Bool) -> Void {
    this.m_scanningComponent.Toggle(toggle);
  }

  private final func EnableTargetingComponents() -> Void {
    this.ToggleTargetingComponents(true);
  }

  private final func DisableTargetingComponents() -> Void {
    this.ToggleTargetingComponents(false);
  }

  private final func ToggleTargetingComponents(on: Bool) -> Void {
    let front_left_tire: ref<TargetingComponent> = this.FindComponentByName(n"front_left_tire") as TargetingComponent;
    let front_right_tire: ref<TargetingComponent> = this.FindComponentByName(n"front_right_tire") as TargetingComponent;
    let back_left_tire: ref<TargetingComponent> = this.FindComponentByName(n"back_left_tire") as TargetingComponent;
    let back_right_tire: ref<TargetingComponent> = this.FindComponentByName(n"back_right_tire") as TargetingComponent;
    let gas_tank: ref<TargetingComponent> = this.FindComponentByName(n"gas_tank") as TargetingComponent;
    if IsDefined(front_left_tire) {
      front_left_tire.Toggle(on);
    };
    if IsDefined(front_right_tire) {
      front_right_tire.Toggle(on);
    };
    if IsDefined(back_left_tire) {
      back_left_tire.Toggle(on);
    };
    if IsDefined(back_right_tire) {
      back_right_tire.Toggle(on);
    };
    if IsDefined(gas_tank) {
      gas_tank.Toggle(on);
    };
  }

  private final func BroadcastEnvironmentalHazardStimuli() -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetVehicle().GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.AddActiveStimuli(this.GetVehicle(), gamedataStimType.EnvironmentalHazard, 10.00);
    };
  }

  private final func RemoveEnvironmentalHazardStimuli() -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetVehicle().GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.RemoveActiveStimuliByName(this.GetVehicle(), gamedataStimType.EnvironmentalHazard);
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    this.ToggleSiren(false, false);
    (this.GetPS() as VehicleComponentPS).SetIsDestroyed(true);
    this.m_interaction.Toggle(false);
    this.ExplodeVehicle(evt.instigator);
    this.GetVehicle().FindAndRewardKiller(gameKillType.Normal);
    this.DisableTargetingComponents();
    VehicleComponent.QueueEventToAllPassengers(this.GetVehicle().GetGame(), this.GetVehicle(), AIEvents.ExitVehicleEvent(), 0.50);
    this.UnmountTrunkBody();
    this.ToggleInteraction(n"", false);
    this.TryToKnockDownBike();
    this.DestroyMappin();
    this.RemoveEnvironmentalHazardStimuli();
  }

  protected cb func OnVehicleWaterEvent(evt: ref<VehicleWaterEvent>) -> Bool {
    if evt.isInWater {
      this.m_submerged = true;
      this.BreakAllDamageStageFX(true);
      GameObjectEffectHelper.BreakEffectLoopEvent(this.GetVehicle(), n"fire");
      this.DestroyVehicle();
      this.DestroyRandomWindow();
      this.ApplyVehicleDOT(n"high");
    };
    ScriptedPuppet.ReevaluateOxygenConsumption(this.m_mountedPlayer);
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    let context: VehicleActionsContext;
    if this.GetVehicle().IsCrowdVehicle() && StatusEffectSystem.ObjectHasStatusEffectWithTag(evt.activator, n"BlockTrafficInteractions") {
      return false;
    };
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      if evt.IsInputLayerEvent() {
        this.CreateObjectActionsCallbackController(evt.activator);
      };
    } else {
      if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_deactivate) {
        if evt.IsInputLayerEvent() {
          this.DestroyObjectActionsCallbackController();
        };
      };
    };
    context.requestorID = this.GetVehicle().GetEntityID();
    context.processInitiatorObject = evt.activator;
    context.interactionLayerTag = evt.layerData.tag;
    context.eventType = evt.eventType;
    (this.GetPS() as VehicleComponentPS).DetermineActionsToPush(this.m_interaction, context, this.m_objectActionsCallbackCtrl, false);
    if this.GetVehicle() == (this.GetVehicle() as TankObject) {
      this.EvaluatePanzerInteractions();
    };
  }

  protected cb func OnInteractionUsed(evt: ref<InteractionChoiceEvent>) -> Bool {
    this.ExecuteAction(evt.choice, evt.activator);
    this.m_interaction.ResetChoices();
  }

  protected final func EvaluatePanzerInteractions() -> Void {
    let state: VehicleDoorInteractionState = (this.GetPS() as VehicleComponentPS).GetDoorInteractionState(EVehicleDoor.seat_front_left);
    if Equals(state, VehicleDoorInteractionState.Locked) || Equals(state, VehicleDoorInteractionState.Reserved) || Equals(state, VehicleDoorInteractionState.QuestLocked) {
      (this.GetPS() as VehicleComponentPS).SetDoorInteractionState(EVehicleDoor.seat_front_left, VehicleDoorInteractionState.Available, "PanzerTankFailsafe");
    };
  }

  private final func RegisterToHUDManager(shouldRegister: Bool) -> Void {
    let hudManager: ref<HUDManager>;
    let registration: ref<HUDManagerRegistrationRequest>;
    if this.GetVehicle().IsCrowdVehicle() && !this.GetVehicle().ShouldForceRegisterInHUDManager() {
      return;
    };
    hudManager = GameInstance.GetScriptableSystemsContainer(this.GetVehicle().GetGame()).Get(n"HUDManager") as HUDManager;
    if IsDefined(hudManager) {
      registration = new HUDManagerRegistrationRequest();
      registration.SetProperties(this.GetVehicle(), shouldRegister);
      hudManager.QueueRequest(registration);
    };
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    if Equals(evt.highlightInstructions.GetState(), InstanceState.ON) {
      (this.GetPS() as VehicleComponentPS).SetFocusModeData(true);
    } else {
      if evt.highlightInstructions.WasProcessed() {
        (this.GetPS() as VehicleComponentPS).SetFocusModeData(false);
      };
    };
  }

  public final func GetVehicleStateForScanner() -> String {
    if (this.GetPS() as VehicleComponentPS).GetIsDestroyed() {
      return "LocKey#49082";
    };
    if this.GetAnyDoorAvailable() && VehicleComponent.IsAnyPassengerCrowd(this.GetVehicle().GetGame(), this.GetVehicle()) {
      return "LocKey#49085";
    };
    if !this.GetAnySlotAvailable() {
      return "LocKey#49083";
    };
    return "LocKey#49084";
  }

  private final func GetAnySlotAvailable(opt checkOccupied: Bool) -> Bool {
    let door: EVehicleDoor;
    let i: Int32;
    let seatSet: array<wref<VehicleSeat_Record>>;
    let slotName: CName;
    VehicleComponent.GetSeats(this.GetVehicle().GetGame(), this.GetVehicle(), seatSet);
    i = 0;
    while i < ArraySize(seatSet) {
      slotName = seatSet[i].SeatName();
      (this.GetPS() as VehicleComponentPS).GetVehicleDoorEnum(door, slotName);
      if Equals((this.GetPS() as VehicleComponentPS).GetDoorInteractionState(door), VehicleDoorInteractionState.Available) {
        if !VehicleComponent.IsSlotOccupiedByActivePassenger(this.GetVehicle().GetGame(), this.GetVehicle().GetEntityID(), slotName) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  private final func GetAnyDoorAvailable(opt checkOccupied: Bool) -> Bool {
    let door: EVehicleDoor;
    let i: Int32;
    let seatSet: array<wref<VehicleSeat_Record>>;
    let slotName: CName;
    VehicleComponent.GetSeats(this.GetVehicle().GetGame(), this.GetVehicle(), seatSet);
    i = 0;
    while i < ArraySize(seatSet) {
      slotName = seatSet[i].SeatName();
      (this.GetPS() as VehicleComponentPS).GetVehicleDoorEnum(door, slotName);
      if Equals((this.GetPS() as VehicleComponentPS).GetDoorInteractionState(door), VehicleDoorInteractionState.Available) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func SetVehicleScannerDirty() -> Void {
    this.GetVehicle().SetScannerDirty(true);
  }

  private final func ExecuteAction(choice: InteractionChoice, executor: wref<GameObject>) -> Void {
    let action: ref<DeviceAction>;
    let i: Int32 = 0;
    while i < ArraySize(choice.data) {
      action = FromVariant(choice.data[i]);
      if IsDefined(action) {
        this.ExecuteAction(action, executor);
      };
      i += 1;
    };
  }

  private final func ExecuteAction(action: ref<DeviceAction>, opt executor: wref<GameObject>) -> Void {
    let sAction: ref<ScriptableDeviceAction> = action as ScriptableDeviceAction;
    if sAction != null {
      sAction.RegisterAsRequester(this.GetEntity().GetEntityID());
      if executor != null {
        sAction.SetExecutor(executor);
      };
      GameInstance.GetPersistencySystem((this.GetEntity() as VehicleObject).GetGame()).QueuePSDeviceEvent(sAction);
    };
  }

  private final func ToggleInteraction(layer: CName, toggle: Bool) -> Void {
    let interactionEvent: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    interactionEvent.enable = toggle;
    interactionEvent.layer = layer;
    this.GetVehicle().QueueEvent(interactionEvent);
  }

  private final func ProcessExplosionEffects() -> Void {
    this.BreakAllDamageStageFX(true);
    GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"explosion", false);
    GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"fire", false);
    GameObject.PlaySoundEvent(this.GetVehicle(), n"v_car_test_explosion");
  }

  private final func ExplodeVehicle(instigator: wref<GameObject>) -> Void {
    let attackID: TweakDBID;
    let broadcaster: ref<StimBroadcasterComponent>;
    let explosionAttack: ref<Attack_GameEffect>;
    let hitFlags: array<SHitFlag>;
    let vehicleRecord: ref<Vehicle_Record> = this.GetVehicle().GetRecord();
    let destroyedAppearanceName: CName = vehicleRecord.DestroyedAppearance();
    if this.m_submerged {
      return;
    };
    attackID = t"Attacks.CarMediumKill";
    if !IsDefined(instigator) {
      instigator = this.GetVehicle();
    };
    if TDBID.IsValid(attackID) {
      explosionAttack = RPGManager.PrepareGameEffectAttack(this.GetVehicle().GetGame(), instigator, this.GetVehicle(), attackID, hitFlags);
      if IsDefined(explosionAttack) {
        explosionAttack.StartAttack();
        this.GetVehicle().DetachAllParts();
        this.ProcessExplosionEffects();
        (this.GetPS() as VehicleComponentPS).SetHasExploded(true);
        if IsNameValid(destroyedAppearanceName) {
          this.GetVehicle().ScheduleAppearanceChange(destroyedAppearanceName);
        };
        this.ApplyStatusEffectOnPassangers(t"BaseStatusEffect.ForceKill", instigator);
        broadcaster = this.GetVehicle().GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          broadcaster.TriggerSingleBroadcast(this.GetVehicle(), gamedataStimType.DeviceExplosion);
        };
      };
    };
  }

  protected final func ApplyStatusEffectOnPassangers(statusEffectID: TweakDBID, instigator: wref<GameObject>) -> Void {
    let i: Int32;
    let seSystem: ref<StatusEffectSystem>;
    let mountInfos: array<MountingInfo> = GameInstance.GetMountingFacility(this.GetVehicle().GetGame()).GetMountingInfoMultipleWithIds(this.GetVehicle().GetEntityID());
    if ArraySize(mountInfos) <= 0 {
      return;
    };
    seSystem = GameInstance.GetStatusEffectSystem(this.GetVehicle().GetGame());
    if !IsDefined(seSystem) {
      return;
    };
    i = 0;
    while i < ArraySize(mountInfos) {
      if EntityID.IsDefined(mountInfos[i].childId) {
        if !GameInstance.GetGodModeSystem(this.GetVehicle().GetGame()).HasGodMode(mountInfos[i].childId, gameGodModeType.Immortal) && !GameInstance.GetGodModeSystem(this.GetVehicle().GetGame()).HasGodMode(mountInfos[i].childId, gameGodModeType.Invulnerable) {
          seSystem.ApplyStatusEffect(mountInfos[i].childId, statusEffectID, GameObject.GetTDBID(instigator), instigator.GetEntityID());
        };
      };
      i += 1;
    };
  }

  private final func SetImmortalityMode() -> Void {
    let vehicleID: EntityID = this.GetVehicle().GetEntityID();
    let recordID: TweakDBID = this.GetVehicle().GetRecordID();
    let record: ref<Vehicle_Record> = TweakDBInterface.GetVehicleRecord(recordID);
    if IsDefined(record) {
      if record.TagsContains(n"Invulnerable") {
        GameInstance.GetGodModeSystem(this.GetVehicle().GetGame()).AddGodMode(vehicleID, gameGodModeType.Invulnerable, n"Default");
        return;
      };
      if record.TagsContains(n"Immortal") {
        GameInstance.GetGodModeSystem(this.GetVehicle().GetGame()).AddGodMode(vehicleID, gameGodModeType.Immortal, n"Default");
        return;
      };
    };
  }

  private final func ClearImmortalityMode() -> Void {
    GameInstance.GetGodModeSystem(this.GetVehicle().GetGame()).ClearGodMode(this.GetVehicle().GetEntityID(), n"Default");
  }

  private final func StealVehicle() -> Void {
    let ev: ref<StealVehicleEvent> = new StealVehicleEvent();
    this.GetVehicle().QueueEvent(ev);
  }

  protected final func ToggleVehicleSystems(toggle: Bool, vehicle: Bool, engine: Bool) -> Void {
    if vehicle {
      this.GetVehicle().TurnOn(toggle);
    };
    if engine {
      this.GetVehicle().TurnEngineOn(toggle);
    };
  }

  protected cb func OnForceCarAlarm(evt: ref<ForceCarAlarm>) -> Bool {
    let delayEvt: ref<DisableAlarmEvent>;
    let broadcaster: ref<StimBroadcasterComponent> = this.GetVehicle().GetStimBroadcasterComponent();
    if this.GetVehicleControllerPS().IsAlarmOn() {
      if IsDefined(broadcaster) {
        broadcaster.SetSingleActiveStimuli(this.GetVehicle(), gamedataStimType.CarAlarm, 5.00);
      };
      delayEvt = new DisableAlarmEvent();
      GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), delayEvt, 5.00);
    };
  }

  protected cb func OnDisableAlarm(evt: ref<DisableAlarmEvent>) -> Bool {
    (this.GetPS() as VehicleComponentPS).DisableAlarm();
  }

  protected cb func OnChangeState(evt: ref<vehicleChangeStateEvent>) -> Bool {
    let crystalDomeQuestModified: Bool = (this.GetPS() as VehicleComponentPS).GetIsCrystalDomeQuestModified();
    if Equals(evt.state, vehicleEState.On) {
      if !crystalDomeQuestModified {
        if this.GetVehicle() != (this.GetVehicle() as AVObject) {
          this.ToggleCrystalDome(true);
        };
      };
      if this.m_mounted {
        this.DrivingStimuli(true);
      };
    };
    if NotEquals(evt.state, vehicleEState.On) {
      if !crystalDomeQuestModified {
        if this.GetVehicle() != (this.GetVehicle() as AVObject) {
          this.ToggleCrystalDome(false);
        };
      };
      this.DrivingStimuli(false);
    };
  }

  protected cb func OnVehicleQuestCrystalDomeEvent(evt: ref<VehicleQuestCrystalDomeEvent>) -> Bool {
    let toggle: Bool = (this.GetPS() as VehicleComponentPS).GetCrystalDomeQuestState();
    this.ToggleCrystalDome(toggle, true);
  }

  private final func DrivingStimuli(broadcast: Bool) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetVehicle().GetStimBroadcasterComponent();
    if !IsDefined(broadcaster) {
      return;
    };
    if broadcast && !this.m_broadcasting {
      broadcaster.SetSingleActiveStimuli(this.GetVehicle(), gamedataStimType.Driving, -1.00);
      this.m_broadcasting = true;
    } else {
      if !broadcast && this.m_broadcasting {
        broadcaster.RemoveActiveStimuliByName(this.GetVehicle(), gamedataStimType.Driving);
        this.m_broadcasting = false;
      };
    };
  }

  private final func SetupCrystalDome() -> Void {
    if (this.GetPS() as VehicleComponentPS).GetCrystalDomeState() {
      this.ToggleCrystalDome(true, false, true, 0.50);
    };
  }

  private final func DetermineShouldCrystalDomeBeOn(meshVisibilityDelay: Float) -> Void {
    if Equals(this.GetVehicleControllerPS().GetState(), vehicleEState.On) && !(this.GetPS() as VehicleComponentPS).GetIsCrystalDomeQuestModified() {
      if this.GetVehicle() != (this.GetVehicle() as AVObject) {
        this.ToggleCrystalDome(true, false, true, 0.00, meshVisibilityDelay);
      };
    };
  }

  private final func ToggleCrystalDome(toggle: Bool, opt force: Bool, opt instant: Bool, opt instantDelay: Float, opt meshVisibilityDelay: Float) -> Void {
    let animFeature: ref<AnimFeature_VehicleState>;
    let crystalDomeMeshDelayEvent: ref<VehicleCrystalDomeMeshVisibilityDelayEvent>;
    let crystalDomeOffDelayEvent: ref<VehicleCrystalDomeOffDelayEvent>;
    let crystalDomeOnDelayEvent: ref<VehicleCrystalDomeOnDelayEvent>;
    let vehicle: ref<VehicleObject> = this.GetVehicle();
    let gameInstance: GameInstance = vehicle.GetGame();
    let player: ref<PlayerPuppet> = GetPlayer(gameInstance);
    if !force && !VehicleComponent.IsMountedToProvidedVehicle(gameInstance, player.GetEntityID(), vehicle) && !instant {
      return;
    };
    animFeature = new AnimFeature_VehicleState();
    if toggle {
      this.ToggleTargetingSystemForPanzer(this.m_mountedPlayer, true);
      if instant {
        if instantDelay == 0.00 {
          GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_instant_on", true);
        } else {
          crystalDomeOnDelayEvent = new VehicleCrystalDomeOnDelayEvent();
          GameInstance.GetDelaySystem(gameInstance).DelayEvent(vehicle, crystalDomeOnDelayEvent, instantDelay);
        };
        if meshVisibilityDelay == 0.00 {
          animFeature.tppEnabled = !vehicle.GetCameraManager().IsTPPActive();
          AnimationControllerComponent.ApplyFeatureToReplicate(vehicle, n"VehicleState", animFeature);
          this.TogglePanzerShadowMeshes(vehicle.GetCameraManager().IsTPPActive());
        } else {
          crystalDomeMeshDelayEvent = new VehicleCrystalDomeMeshVisibilityDelayEvent();
          GameInstance.GetDelaySystem(gameInstance).DelayEvent(vehicle, crystalDomeMeshDelayEvent, meshVisibilityDelay);
        };
      } else {
        GameObjectEffectHelper.StartEffectEvent(vehicle, n"crystal_dome_start", true);
        animFeature.tppEnabled = !vehicle.GetCameraManager().IsTPPActive();
        AnimationControllerComponent.ApplyFeatureToReplicate(vehicle, n"VehicleState", animFeature);
        this.TogglePanzerShadowMeshes(vehicle.GetCameraManager().IsTPPActive());
      };
      (this.GetPS() as VehicleComponentPS).SetCrystalDomeState(true);
    } else {
      this.ToggleTargetingSystemForPanzer(this.m_mountedPlayer, false);
      GameObjectEffectHelper.StartEffectEvent(vehicle, n"crystal_dome_stop", true);
      crystalDomeOffDelayEvent = new VehicleCrystalDomeOffDelayEvent();
      GameInstance.GetDelaySystem(gameInstance).DelayEvent(vehicle, crystalDomeOffDelayEvent, 1.49);
    };
  }

  private final func TogglePanzerShadowMeshes(toggle: Bool) -> Void {
    let shadowMesh1: ref<IComponent>;
    if this.GetVehicle() != (this.GetVehicle() as TankObject) {
      return;
    };
    shadowMesh1 = this.FindComponentByName(n"av_militech_basilisk__ext01_canopy_a_shadow");
    shadowMesh1.Toggle(toggle);
  }

  protected cb func OnVehicleCrystalDomeOffDelayEvent(evt: ref<VehicleCrystalDomeOffDelayEvent>) -> Bool {
    let animFeature: ref<AnimFeature_VehicleState> = new AnimFeature_VehicleState();
    (this.GetPS() as VehicleComponentPS).SetCrystalDomeState(false);
    animFeature.tppEnabled = false;
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), n"VehicleState", animFeature);
  }

  protected cb func OnVehicleCrystalDomeOnDelayEvent(evt: ref<VehicleCrystalDomeOnDelayEvent>) -> Bool {
    GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_instant_on", true);
  }

  protected cb func OnVehicleCrystalDomeMeshVisibilityDelayEvent(evt: ref<VehicleCrystalDomeMeshVisibilityDelayEvent>) -> Bool {
    let animFeature: ref<AnimFeature_VehicleState> = new AnimFeature_VehicleState();
    animFeature.tppEnabled = !this.GetVehicle().GetCameraManager().IsTPPActive();
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), n"VehicleState", animFeature);
    this.TogglePanzerShadowMeshes(!this.GetVehicle().GetCameraManager().IsTPPActive());
  }

  private final func ToggleTargetingSystemForPanzer(mountedPlayer: ref<PlayerPuppet>, enable: Bool) -> Void {
    let targetingSystem: ref<TargetingSystem>;
    let vehicle: ref<VehicleObject> = this.GetVehicle();
    if IsDefined(mountedPlayer) {
      if enable && !this.m_isIgnoredInTargetingSystem {
        targetingSystem = GameInstance.GetTargetingSystem(vehicle.GetGame());
        targetingSystem.AddIgnoredCollisionEntities(vehicle);
        targetingSystem.AddIgnoredLookAtEntity(mountedPlayer, vehicle.GetEntityID());
        this.m_isIgnoredInTargetingSystem = true;
      } else {
        if this.m_isIgnoredInTargetingSystem {
          targetingSystem = GameInstance.GetTargetingSystem(vehicle.GetGame());
          targetingSystem.RemoveIgnoredCollisionEntities(vehicle);
          targetingSystem.RemoveIgnoredLookAtEntity(mountedPlayer, vehicle.GetEntityID());
          this.m_isIgnoredInTargetingSystem = false;
        };
      };
    };
  }

  private final func TogglePlayerHitShapesForPanzer(mountedPlayer: ref<PlayerPuppet>, enable: Bool) -> Void {
    if IsDefined(mountedPlayer) {
      if enable && !this.m_arePlayerHitShapesEnabled {
        HitShapeUserDataBase.EnableHitShape(mountedPlayer, n"head", false);
        HitShapeUserDataBase.EnableHitShape(mountedPlayer, n"chest", false);
        HitShapeUserDataBase.EnableHitShape(mountedPlayer, n"legs", false);
        this.m_arePlayerHitShapesEnabled = true;
      } else {
        if this.m_arePlayerHitShapesEnabled {
          HitShapeUserDataBase.DisableHitShape(mountedPlayer, n"head", false);
          HitShapeUserDataBase.DisableHitShape(mountedPlayer, n"chest", false);
          HitShapeUserDataBase.DisableHitShape(mountedPlayer, n"legs", false);
          this.m_arePlayerHitShapesEnabled = false;
        };
      };
    };
  }

  private final func DoPanzerCleanup() -> Void {
    if !this.m_arePlayerHitShapesEnabled {
      this.TogglePlayerHitShapesForPanzer(this.m_mountedPlayer, true);
    };
    if this.m_isIgnoredInTargetingSystem {
      this.ToggleTargetingSystemForPanzer(this.m_mountedPlayer, false);
    };
  }

  protected cb func OnVehicleForceOccupantOut(evt: ref<VehicleForceOccupantOut>) -> Bool {
    this.StealVehicle();
  }

  protected cb func OnActionDemolition(evt: ref<ActionDemolition>) -> Bool {
    this.StealVehicle();
  }

  protected cb func OnActionEngineering(evt: ref<ActionEngineering>) -> Bool {
    this.StealVehicle();
  }

  protected cb func OnVehicleQuestDoorLocked(evt: ref<VehicleQuestDoorLocked>) -> Bool;

  protected cb func OnVehicleDoorInteraction(evt: ref<VehicleDoorInteraction>) -> Bool {
    let doorID: CName = evt.slotID;
    this.EvaluateDoorReaction(doorID);
  }

  protected cb func OnVehicleDoorOpen(evt: ref<VehicleDoorOpen>) -> Bool {
    let PSVehicleDoorCloseRequest: ref<VehicleDoorClose>;
    let autoCloseDelay: Float;
    this.EvaluateDoorReaction(evt.slotID);
    if evt.shouldAutoClose {
      PSVehicleDoorCloseRequest = new VehicleDoorClose();
      PSVehicleDoorCloseRequest.slotID = evt.slotID;
      autoCloseDelay = evt.autoCloseTime;
      if autoCloseDelay == 0.00 {
        autoCloseDelay = 1.50;
      };
      GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayPSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), PSVehicleDoorCloseRequest, autoCloseDelay, true);
    };
    (this.GetPS() as VehicleComponentPS).SetHasAnyDoorOpen(true);
  }

  protected cb func OnVehicleDoorClose(evt: ref<VehicleDoorClose>) -> Bool {
    this.EvaluateDoorReaction(evt.slotID);
  }

  protected final func GetVehicleDoorEnum(out door: EVehicleDoor, doorName: CName) -> Bool {
    let res: Int32 = Cast(EnumValueFromName(n"EVehicleDoor", doorName));
    if res < 0 {
      return false;
    };
    door = IntEnum(res);
    return true;
  }

  protected cb func OnVehicleDoorInteractionStateChange(evt: ref<VehicleDoorInteractionStateChange>) -> Bool {
    let layerName: CName = EnumValueToName(n"EVehicleDoor", EnumInt(evt.door));
    this.DetermineInteractionState(layerName);
  }

  protected final func EvaluateDoorReaction(doorID: CName) -> Void {
    let animFeature: ref<AnimFeature_PartData>;
    let animFeatureName: CName;
    let door: EVehicleDoor;
    let doorState: VehicleDoorState;
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    VehicleComponent.GetVehicleDataPackage(this.GetVehicle().GetGame(), this.GetVehicle(), vehDataPackage);
    animFeature = new AnimFeature_PartData();
    animFeatureName = doorID;
    if !this.GetVehicleDoorEnum(door, doorID) {
      return;
    };
    doorState = (this.GetPS() as VehicleComponentPS).GetDoorState(door);
    if Equals(doorState, VehicleDoorState.Open) {
      animFeature.state = 1;
      animFeature.duration = vehDataPackage.Open_close_duration();
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), animFeatureName, animFeature);
      AnimationControllerComponent.PushEvent(this.GetVehicle(), this.GetAnimEventName(doorState, door));
    };
    if Equals(doorState, VehicleDoorState.Closed) {
      animFeature.state = 3;
      animFeature.duration = vehDataPackage.Open_close_duration();
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), animFeatureName, animFeature);
      AnimationControllerComponent.PushEvent(this.GetVehicle(), this.GetAnimEventName(doorState, door));
    };
  }

  private final func GetAnimEventName(doorState: VehicleDoorState, door: EVehicleDoor) -> CName {
    if Equals(door, EVehicleDoor.seat_front_left) {
      if Equals(doorState, VehicleDoorState.Open) {
        return n"doorOpenFrontLeft";
      };
      if Equals(doorState, VehicleDoorState.Closed) {
        return n"doorCloseFrontLeft";
      };
    };
    if Equals(door, EVehicleDoor.seat_front_right) {
      if Equals(doorState, VehicleDoorState.Open) {
        return n"doorOpenFrontRight";
      };
      if Equals(doorState, VehicleDoorState.Closed) {
        return n"doorCloseFrontRight";
      };
    };
    if Equals(door, EVehicleDoor.seat_back_left) {
      if Equals(doorState, VehicleDoorState.Open) {
        return n"doorOpenBackLeft";
      };
      if Equals(doorState, VehicleDoorState.Closed) {
        return n"doorCloseBackLeft";
      };
    };
    if Equals(door, EVehicleDoor.seat_back_right) {
      if Equals(doorState, VehicleDoorState.Open) {
        return n"doorOpenBackRight";
      };
      if Equals(doorState, VehicleDoorState.Closed) {
        return n"doorCloseBackRight";
      };
    };
    return n"";
  }

  protected cb func OnVehicleExternalDoorRequestEvent(evt: ref<VehicleExternalDoorRequestEvent>) -> Bool {
    let PSvehicleDooropenRequest: ref<VehicleDoorOpen> = new VehicleDoorOpen();
    PSvehicleDooropenRequest.slotID = evt.slotName;
    PSvehicleDooropenRequest.shouldAutoClose = evt.autoClose;
    PSvehicleDooropenRequest.autoCloseTime = evt.autoCloseTime;
    GameInstance.GetPersistencySystem(this.GetVehicle().GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), PSvehicleDooropenRequest);
  }

  protected cb func OnVehicleExternalWindowRequestEvent(evt: ref<VehicleExternalWindowRequestEvent>) -> Bool {
    let PSvehicleWindowcloseRequest: ref<VehicleWindowClose>;
    let PSvehicleWindowopenRequest: ref<VehicleWindowOpen>;
    if evt.shouldOpen {
      PSvehicleWindowopenRequest = new VehicleWindowOpen();
      PSvehicleWindowopenRequest.slotID = evt.slotName;
      PSvehicleWindowopenRequest.speed = evt.speed;
      GameInstance.GetPersistencySystem(this.GetVehicle().GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), PSvehicleWindowopenRequest);
    } else {
      PSvehicleWindowcloseRequest = new VehicleWindowClose();
      PSvehicleWindowcloseRequest.slotID = evt.slotName;
      PSvehicleWindowcloseRequest.speed = evt.speed;
      GameInstance.GetPersistencySystem(this.GetVehicle().GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), PSvehicleWindowcloseRequest);
    };
  }

  protected cb func OnVehicleWindowOpen(evt: ref<VehicleWindowOpen>) -> Bool {
    this.EvaluateWindowReaction(evt.slotID, evt.speed);
  }

  protected cb func OnVehicleWindowClose(evt: ref<VehicleWindowClose>) -> Bool {
    this.EvaluateWindowReaction(evt.slotID, evt.speed);
  }

  protected final func EvaluateWindowReaction(doorID: CName, speed: CName) -> Void {
    let door: EVehicleDoor;
    let windowState: EVehicleWindowState;
    let animFeature: ref<AnimFeature_PartData> = new AnimFeature_PartData();
    let animFeatureName: CName = StringToName(NameToString(doorID) + "_window");
    if !this.GetVehicleDoorEnum(door, doorID) {
      return;
    };
    windowState = (this.GetPS() as VehicleComponentPS).GetWindowState(door);
    if Equals(speed, n"Fast") {
      animFeature.duration = 0.20;
    } else {
      animFeature.duration = -1.00;
    };
    if Equals(windowState, EVehicleWindowState.Open) {
      animFeature.state = 1;
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), animFeatureName, animFeature);
    };
    if Equals(windowState, EVehicleWindowState.Closed) {
      animFeature.state = 3;
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), animFeatureName, animFeature);
    };
  }

  private final func EvaluateWindowState() -> Void {
    let state: EVehicleWindowState;
    let size: Int32 = EnumInt(EVehicleDoor.count);
    let i: Int32 = 0;
    while i < size {
      state = (this.GetPS() as VehicleComponentPS).GetWindowState(IntEnum(i));
      this.SetWindowAnimFeatureData(IntEnum(i), state);
      i += 1;
    };
  }

  protected final func SetWindowAnimFeatureData(door: EVehicleDoor, state: EVehicleWindowState) -> Void {
    let animFeature: ref<AnimFeature_PartData>;
    let animFeatureName: CName;
    if Equals(state, EVehicleWindowState.Open) {
      animFeature = new AnimFeature_PartData();
      animFeature.state = 2;
      animFeatureName = StringToName(NameToString(EnumValueToName(n"EVehicleDoor", EnumInt(door))) + "_window");
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), animFeatureName, animFeature);
    };
  }

  protected cb func OnToggleDoorInteractionEvent(evt: ref<ToggleDoorInteractionEvent>) -> Bool {
    this.EvaluateTrunkAndHoodInteractions();
  }

  protected cb func OnOpenTrunk(evt: ref<VehicleOpenTrunk>) -> Bool {
    let delayEvt: ref<ToggleDoorInteractionEvent> = new ToggleDoorInteractionEvent();
    let vehicle: wref<VehicleObject> = this.GetEntity() as VehicleObject;
    AnimationControllerComponent.PushEvent(vehicle, n"doorOpenTrunk");
    this.EvaluateDoorReaction(n"trunk");
    this.ToggleInteraction(n"trunk", false);
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetEntity() as VehicleObject, delayEvt, 1.00);
    (this.GetPS() as VehicleComponentPS).SetHasAnyDoorOpen(true);
  }

  protected cb func OnCloseTrunk(evt: ref<VehicleCloseTrunk>) -> Bool {
    let delayEvt: ref<ToggleDoorInteractionEvent> = new ToggleDoorInteractionEvent();
    let vehicle: wref<VehicleObject> = this.GetEntity() as VehicleObject;
    AnimationControllerComponent.PushEvent(vehicle, n"doorCloseTrunk");
    this.EvaluateDoorReaction(n"trunk");
    this.ToggleInteraction(n"trunk", false);
    GameInstance.GetDelaySystem((this.GetEntity() as VehicleObject).GetGame()).DelayEvent(this.GetVehicle(), delayEvt, 1.00);
  }

  protected cb func OnVehicleDumpBody(evt: ref<VehicleDumpBody>) -> Bool {
    let mountingInfo: MountingInfo;
    let playerPuppet: ref<PlayerPuppet>;
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let slotID: MountingSlotId;
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    let unmountEvent: ref<UnmountingRequest> = new UnmountingRequest();
    let dumpBodyWorkspotEvent: ref<DumpBodyWorkspotDelayEvent> = new DumpBodyWorkspotDelayEvent();
    let vehicleDumpBodyCloseTrunkEvent: ref<VehicleDumpBodyCloseTrunkEvent> = new VehicleDumpBodyCloseTrunkEvent();
    slotID.id = n"trunk";
    VehicleComponent.OpenDoor(this.GetVehicle(), slotID);
    this.ToggleInteraction(n"trunk", false);
    playerPuppet = GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetVehicle().GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    mountingInfo = GameInstance.GetMountingFacility(this.GetVehicle().GetGame()).GetMountingInfoSingleWithObjects(playerPuppet);
    this.m_trunkNpcBody = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), mountingInfo.childId) as GameObject;
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.CarryingDisposal, true);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyDisposalDetailed, EnumInt(gamePSMDetailedBodyDisposal.Dispose));
    GameInstance.GetMountingFacility(this.GetVehicle().GetGame()).Unmount(unmountEvent);
    VehicleComponent.GetVehicleDataPackage(this.GetVehicle().GetGame(), this.GetVehicle(), vehDataPackage);
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), dumpBodyWorkspotEvent, 0.00);
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), vehicleDumpBodyCloseTrunkEvent, TweakDBInterface.GetFloat(vehDataPackage.GetID() + t".body_dump_close_trunk_delay", 2.00));
  }

  protected cb func OnDumpBodyWorkspotDelayEvent(evt: ref<DumpBodyWorkspotDelayEvent>) -> Bool {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetVehicle().GetGame());
    workspotSystem.PlayNpcInWorkspot(this.m_trunkNpcBody, GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject(), this.GetVehicle(), n"trunkBodyDisposalNpc", n"", 0.00);
    workspotSystem.PlayInDevice(this.GetVehicle(), GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject(), n"lockedCamera", n"trunkBodyDisposalPlayer", n"", n"bodyDisposalSync", 0.10, WorkspotSlidingBehaviour.DontPlayAtResourcePosition);
  }

  public final func MountNpcBodyToTrunk() -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetVehicle().GetGame()).GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.CarryingDisposal, false);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, false);
    playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyDisposalDetailed, EnumInt(gamePSMDetailedBodyDisposal.Default));
    this.MountEntityToSlot(this.GetVehicle().GetEntityID(), this.m_trunkNpcBody.GetEntityID(), n"trunk_body");
    if !RPGManager.IsInventoryEmpty(this.m_trunkNpcBody) {
      this.m_trunkNpcBody as NPCPuppet.DropLootBag();
    };
  }

  protected cb func OnVehicleDumpBodyCloseTrunkEvent(evt: ref<VehicleDumpBodyCloseTrunkEvent>) -> Bool {
    let slotID: MountingSlotId;
    slotID.id = n"trunk";
    VehicleComponent.CloseDoor(this.GetVehicle(), slotID);
    this.EvaluateTrunkInteractions();
  }

  protected cb func OnVehicleTakeBody(evt: ref<VehicleTakeBody>) -> Bool {
    let slotID: MountingSlotId;
    let pickupBodyWorkspotEvent: ref<PickupBodyWorkspotDelayEvent> = new PickupBodyWorkspotDelayEvent();
    slotID.id = n"trunk_body";
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(this.GetVehicle().GetGame()).GetMountingInfoSingleWithObjects(this.GetVehicle(), slotID);
    this.m_trunkNpcBody = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), mountingInfo.childId) as GameObject;
    let trunkPickUpAIevent: ref<AIEvent> = new AIEvent();
    trunkPickUpAIevent.name = n"InstantUnmount";
    this.m_trunkNpcBody.QueueEvent(trunkPickUpAIevent);
    (this.m_trunkNpcBody as NPCPuppet).SetDisableRagdoll(true);
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), pickupBodyWorkspotEvent, 0.00);
  }

  protected cb func OnPickupBodyWorkspotDelayEvent(evt: ref<PickupBodyWorkspotDelayEvent>) -> Bool {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetVehicle().GetGame());
    workspotSystem.PlayNpcInWorkspot(this.m_trunkNpcBody, GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject(), this.GetVehicle(), n"trunkBodyPickupNpc", n"", 0.00);
    workspotSystem.PlayInDevice(this.GetVehicle(), GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject(), n"lockedCamera", n"trunkBodyPickupPlayer", n"", n"bodyPickupSync", 0.10, WorkspotSlidingBehaviour.DontPlayAtResourcePosition);
  }

  public final func FinishTrunkBodyPickup() -> Void {
    this.MountBodyToPlayer(this.m_trunkNpcBody);
    this.ToggleInteraction(n"trunk", false);
    this.EvaluateTrunkInteractions();
    (this.m_trunkNpcBody as NPCPuppet).SetDisableRagdoll(false);
  }

  private final func MountBodyToPlayer(npcBody: wref<GameObject>) -> Void {
    let addCarriedObjectSM: ref<PSMAddOnDemandStateMachine>;
    if !IsDefined(npcBody) {
      return;
    };
    GameInstance.GetStatusEffectSystem(this.GetVehicle().GetGame()).ApplyStatusEffect(npcBody.GetEntityID(), t"BaseStatusEffect.VehicleTrunkBodyPickup", this.GetVehicle().GetRecordID(), this.GetVehicle().GetEntityID());
    addCarriedObjectSM = new PSMAddOnDemandStateMachine();
    addCarriedObjectSM.owner = npcBody;
    addCarriedObjectSM.stateMachineName = n"CarriedObject";
    GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerControlledGameObject().QueueEvent(addCarriedObjectSM);
  }

  protected final func MountEntityToSlot(parentID: EntityID, childId: EntityID, slot: CName) -> Void {
    let lowLevelMountingInfo: MountingInfo;
    let mountingRequest: ref<MountingRequest> = new MountingRequest();
    let mountData: ref<MountEventData> = new MountEventData();
    let mountOptions: ref<MountEventOptions> = new MountEventOptions();
    lowLevelMountingInfo.parentId = parentID;
    lowLevelMountingInfo.childId = childId;
    lowLevelMountingInfo.slotId.id = slot;
    mountingRequest.lowLevelMountingInfo = lowLevelMountingInfo;
    mountingRequest.preservePositionAfterMounting = true;
    mountingRequest.mountData = mountData;
    mountOptions.alive = false;
    mountOptions.occupiedByNeutral = false;
    mountingRequest.mountData.mountEventOptions = mountOptions;
    GameInstance.GetMountingFacility(this.GetEntity() as GameObject.GetGame()).Mount(mountingRequest);
  }

  private final func UnmountTrunkBody() -> Void {
    let instantUnmount: ref<AIEvent>;
    let slotID: MountingSlotId;
    slotID.id = n"trunk_body";
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(this.GetVehicle().GetGame()).GetMountingInfoSingleWithObjects(this.GetVehicle(), slotID);
    let npcBody: wref<GameObject> = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), mountingInfo.childId) as GameObject;
    if !IsDefined(npcBody) {
      return;
    };
    instantUnmount = new AIEvent();
    instantUnmount.name = n"InstantUnmount";
    npcBody.QueueEvent(instantUnmount);
  }

  protected cb func OnVehiclePlayerTrunk(evt: ref<VehiclePlayerTrunk>) -> Bool {
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerMainGameObject();
    let storageData: ref<StorageUserData> = new StorageUserData();
    storageData.storageObject = this.GetVehicle();
    let storageBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().StorageBlackboard);
    if IsDefined(storageBB) {
      storageBB.SetVariant(GetAllBlackboardDefs().StorageBlackboard.StorageData, ToVariant(storageData), true);
    };
  }

  protected cb func OnOpenHood(evt: ref<VehicleOpenHood>) -> Bool {
    let delayEvt: ref<ToggleDoorInteractionEvent> = new ToggleDoorInteractionEvent();
    this.EvaluateDoorReaction(n"hood");
    this.ToggleInteraction(n"hood", false);
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetEntity() as VehicleObject, delayEvt, 1.00);
    (this.GetPS() as VehicleComponentPS).SetHasAnyDoorOpen(true);
  }

  protected cb func OnCloseHood(evt: ref<VehicleCloseHood>) -> Bool {
    let delayEvt: ref<ToggleDoorInteractionEvent> = new ToggleDoorInteractionEvent();
    this.EvaluateDoorReaction(n"hood");
    this.ToggleInteraction(n"hood", false);
    GameInstance.GetDelaySystem((this.GetEntity() as VehicleObject).GetGame()).DelayEvent(this.GetVehicle(), delayEvt, 1.00);
  }

  protected cb func OnSummonStartedEvent(evt: ref<SummonStartedEvent>) -> Bool {
    if Equals(evt.state, vehicleSummonState.EnRoute) || Equals(evt.state, vehicleSummonState.AlreadySummoned) {
      this.CreateMappin();
      if Equals(evt.state, vehicleSummonState.EnRoute) {
        this.SendParkEvent(false);
      };
      if Equals(evt.state, vehicleSummonState.AlreadySummoned) {
        this.HonkAndFlash();
      };
    };
  }

  protected cb func OnSummonFinishedEvent(evt: ref<SummonFinishedEvent>) -> Bool {
    if Equals(evt.state, vehicleSummonState.Arrived) {
      this.CreateMappin();
      this.HonkAndFlash();
      this.SendParkEvent(true);
      this.PlaySummonArrivalSFX();
    };
  }

  private final func PlaySummonArrivalSFX() -> Void {
    let audioEvent: ref<SoundPlayEvent> = new SoundPlayEvent();
    audioEvent.soundName = n"ui_jingle_vehicle_arrive";
    GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerControlledGameObject().QueueEvent(audioEvent);
  }

  private final func HonkAndFlash() -> Void {
    let hornEvt: ref<VehicleQuestHornEvent>;
    let lightsEvt: ref<VehicleLightQuestToggleEvent> = new VehicleLightQuestToggleEvent();
    lightsEvt.toggle = true;
    lightsEvt.lightType = vehicleELightType.Default;
    this.OnVehicleLightQuestToggleEvent(lightsEvt);
    lightsEvt = new VehicleLightQuestToggleEvent();
    lightsEvt.toggle = false;
    lightsEvt.lightType = vehicleELightType.Default;
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), lightsEvt, 1.00);
    hornEvt = new VehicleQuestHornEvent();
    hornEvt.honkTime = 2.00;
    this.GetVehicle().QueueEvent(hornEvt);
  }

  private final func IsPlayerVehicle() -> Void {
    if this.GetVehicle().IsPlayerVehicle() {
      (this.GetPS() as VehicleComponentPS).SetIsPlayerVehicle(true);
    };
  }

  private final func SetupAuxillary() -> Void {
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    VehicleComponent.GetVehicleDataPackage(this.GetVehicle().GetGame(), this.GetVehicle(), vehDataPackage);
    this.m_hasSpoiler = vehDataPackage.HasSpoiler();
    this.m_hasSiren = vehDataPackage.HasSiren();
    if this.m_hasSpoiler {
      this.m_spoilerUp = vehDataPackage.SpoilerSpeedToDeploy();
      this.m_spoilerDown = vehDataPackage.SpoilerSpeedToRetract();
    };
    this.m_hasTurboCharger = vehDataPackage.HasTurboCharger();
    if this.m_hasTurboCharger {
      this.m_overheatEffectBlackboard = new worldEffectBlackboard();
      this.m_overheatEffectBlackboard.SetValue(n"overheatValue", 1.00);
    };
  }

  private final func SetupWheels() -> Void {
    let record: ref<Vehicle_Record> = this.GetVehicle().GetRecord();
    let wheelAnimFeature: ref<AnimFeature_CamberData> = new AnimFeature_CamberData();
    let animFeatureName: CName = n"wheel_data";
    wheelAnimFeature.rightFrontCamber = record.RightFrontCamber();
    wheelAnimFeature.leftFrontCamber = record.LeftFrontCamber();
    wheelAnimFeature.rightBackCamber = record.RightBackCamber();
    wheelAnimFeature.leftBackCamber = record.LeftBackCamber();
    wheelAnimFeature.rightFrontCamberOffset = Vector4.Vector3To4(record.RightFrontCamberOffset());
    wheelAnimFeature.leftFrontCamberOffset = Vector4.Vector3To4(record.LeftFrontCamberOffset());
    wheelAnimFeature.rightBackCamberOffset = Vector4.Vector3To4(record.RightBackCamberOffset());
    wheelAnimFeature.leftBackCamberOffset = Vector4.Vector3To4(record.LeftBackCamberOffset());
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), animFeatureName, wheelAnimFeature);
  }

  protected cb func OnGridDestruction(evt: ref<VehicleGridDestructionEvent>) -> Bool {
    let biggestImpact: Float;
    let broadcaster: ref<StimBroadcasterComponent>;
    let desiredChange: Float;
    let gridState: Float;
    let owner: wref<VehicleObject> = this.GetVehicle();
    let vehicleDriver: wref<GameObject> = VehicleComponent.GetDriver(owner.GetGame(), this.GetVehicle().GetEntityID());
    let i: Int32 = 0;
    while i < ArraySize(evt.rawChange) {
      gridState = evt.state[i];
      desiredChange = evt.desiredChange[i];
      this.SendDestructionDataToGraph(i, gridState);
      this.DetermineAdditionalEngineFX(i, gridState);
      if desiredChange > biggestImpact {
        biggestImpact = desiredChange;
      };
      i += 1;
    };
    this.CreateHitEventOnSelf(biggestImpact);
    broadcaster = owner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      if biggestImpact < 0.03 {
        broadcaster.TriggerSingleBroadcast(owner, gamedataStimType.CrowdIllegalAction, 10.00);
      } else {
        broadcaster.TriggerSingleBroadcast(owner, gamedataStimType.VehicleHit, 5.00);
      };
    };
    if VehicleComponent.IsMountedToVehicle(owner.GetGame(), vehicleDriver) && IsDefined(vehicleDriver as NPCPuppet) {
      GameObject.PlayVoiceOver(vehicleDriver, n"vehicle_bump", n"Scripts:OnGridDestruction/vehicle", true);
    };
  }

  private final func CreateHitEventOnSelf(force: Float) -> Void {
    let attack: ref<IAttack>;
    let attackContext: AttackInitContext;
    let evt: ref<gameHitEvent>;
    let instigator: wref<GameObject>;
    let mountInfo: MountingInfo;
    let slotId: MountingSlotId;
    let statsDataSystem: ref<StatsDataSystem>;
    let vehHealthPrecent: Float;
    let vehicleID: StatsObjectID;
    if force >= 0.10 {
      vehicleID = Cast(this.GetVehicle().GetEntityID());
      vehHealthPrecent = GameInstance.GetStatPoolsSystem(this.GetVehicle().GetGame()).GetStatPoolValue(vehicleID, gamedataStatPoolType.Health);
      statsDataSystem = GameInstance.GetStatsDataSystem(this.GetVehicle().GetGame());
      if vehHealthPrecent >= 10.00 {
        evt = new gameHitEvent();
        evt.attackData = new AttackData();
        slotId.id = VehicleComponent.GetDriverSlotName();
        mountInfo = GameInstance.GetMountingFacility(this.GetVehicle().GetGame()).GetMountingInfoSingleWithObjects(this.GetVehicle(), slotId);
        instigator = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), mountInfo.childId) as GameObject;
        attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.VehicleImpact");
        attackContext.instigator = instigator;
        attackContext.source = this.GetVehicle();
        attack = IAttack.Create(attackContext);
        evt.target = this.GetVehicle();
        evt.attackData.SetVehicleImpactForce(statsDataSystem.GetValueFromCurve(n"vehicle_collision_damage", force, n"collision_damage"));
        evt.attackData.AddFlag(hitFlag.VehicleImpact, n"VehicleImpact");
        evt.attackData.AddFlag(hitFlag.CannotModifyDamage, n"VehicleImpact");
        evt.attackData.SetSource(this.GetVehicle());
        evt.attackData.SetInstigator(instigator);
        evt.attackData.SetAttackDefinition(attack);
        GameInstance.GetDamageSystem(this.GetVehicle().GetGame()).StartPipeline(evt);
      };
    };
  }

  private final func TryToKnockDownBike() -> Void {
    let knockOverBike: ref<KnockOverBikeEvent> = new KnockOverBikeEvent();
    this.GetVehicle().QueueEvent(knockOverBike);
  }

  public final func ReactToHPChange(destruction: Float) -> Void {
    let damageStageTurnOffDelayEvent: ref<VehicleDamageStageTurnOffEvent>;
    let destroyedAppearanceName: CName;
    let vehicleRecord: wref<Vehicle_Record>;
    let currDmgLevel: Int32 = this.m_damageLevel;
    this.m_damageLevel = this.EvaluateDamageLevel(destruction);
    if this.m_submerged {
      return;
    };
    if this.m_damageLevel > currDmgLevel {
      if this.m_damageLevel == 1 {
        this.BreakAllDamageStageFX();
        GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"damage_engine_stage1", false);
      } else {
        if this.m_damageLevel == 2 {
          this.BreakAllDamageStageFX();
          GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"damage_engine_stage2", false);
          this.GetVehicle().DetachPart(n"Hood");
          damageStageTurnOffDelayEvent = new VehicleDamageStageTurnOffEvent();
          GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), damageStageTurnOffDelayEvent, RandRangeF(35.00, 55.00));
        } else {
          if this.m_damageLevel == 3 {
            vehicleRecord = this.GetVehicle().GetRecord();
            this.BreakAllDamageStageFX();
            destroyedAppearanceName = vehicleRecord.DestroyedAppearance();
            this.TutorialCarDamageFact();
            GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"damage_engine_stage3", false);
            this.DestroyVehicle();
            if IsNameValid(destroyedAppearanceName) {
              this.GetVehicle().PrefetchAppearanceChange(destroyedAppearanceName);
            };
            this.BroadcastEnvironmentalHazardStimuli();
          };
        };
      };
      this.m_vehicleBlackboard.SetInt(GetAllBlackboardDefs().Vehicle.DamageState, this.m_damageLevel);
    };
  }

  private final func DestroyVehicle() -> Void {
    let exitVehicleEvent: ref<AIEvent>;
    if !GameInstance.GetGodModeSystem(this.GetVehicle().GetGame()).HasGodMode(this.GetVehicle().GetEntityID(), gameGodModeType.Immortal) {
      (this.GetPS() as VehicleComponentPS).SetIsDestroyed(true);
      this.DestroyMappin();
      this.ToggleInteraction(n"", false);
      this.ToggleVehicleSystems(false, true, true);
      this.DisableRadio();
      exitVehicleEvent = new AIEvent();
      exitVehicleEvent.name = n"ExitVehicle";
      VehicleComponent.QueueEventToAllPassengers(this.GetVehicle().GetGame(), this.GetVehicle(), exitVehicleEvent);
    };
  }

  private final func RepairVehicle() -> Void {
    (this.GetPS() as VehicleComponentPS).SetIsDestroyed(false);
    this.CreateMappin();
    this.ToggleInteraction(n"", true);
    this.ToggleVehicleSystems(true, true, true);
  }

  protected cb func OnVehicleRepairEvent(re: ref<VehicleRepairEvent>) -> Bool {
    this.RepairVehicle();
  }

  private final func DisableRadio() -> Void {
    let radioEvent: ref<VehicleRadioEvent> = new VehicleRadioEvent();
    radioEvent.toggle = false;
    this.GetVehicle().QueueEvent(radioEvent);
  }

  private final func DestroyRandomWindow() -> Void {
    let destructionEvent: ref<VehicleGlassDestructionEvent>;
    let glassArray: array<wref<VehicleDestructibleGlass_Record>>;
    let vehicleRecord: ref<Vehicle_Record>;
    if VehicleComponent.GetVehicleRecord(this.GetVehicle(), vehicleRecord) && IsDefined(vehicleRecord.Destruction()) && vehicleRecord.Destruction().GetGlassCount() > 1 {
      vehicleRecord.Destruction().Glass(glassArray);
      destructionEvent = new VehicleGlassDestructionEvent();
      destructionEvent.glassName = glassArray[RandRange(1, ArraySize(glassArray))].Component();
      this.GetVehicle().QueueEvent(destructionEvent);
    };
  }

  private final func TutorialCarDamageFact() -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetVehicle().GetGame());
    if VehicleComponent.IsMountedToVehicle(this.GetVehicle().GetGame(), GameInstance.GetPlayerSystem(this.GetVehicle().GetGame()).GetLocalPlayerControlledGameObject()) && questSystem.GetFact(n"car_damage_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"car_damage_tutorial", 1);
    };
  }

  private final func BreakAllDamageStageFX(opt auxillaryFX: Bool) -> Void {
    let vehicle: ref<GameObject> = this.GetVehicle();
    GameObjectEffectHelper.BreakEffectLoopEvent(vehicle, n"damage_engine_stage1");
    GameObjectEffectHelper.BreakEffectLoopEvent(vehicle, n"damage_engine_stage2");
    GameObjectEffectHelper.BreakEffectLoopEvent(vehicle, n"damage_engine_stage3");
    if auxillaryFX {
      GameObjectEffectHelper.BreakEffectLoopEvent(vehicle, n"cooler_destro_fx");
    };
  }

  private final func SendDestructionDataToGraph(gridID: Int32, gridState: Float) -> Void {
    if gridState >= 0.15 {
      this.PlayCrystalDomeGlitchEffect();
      this.m_vehicleBlackboard.SetBool(GetAllBlackboardDefs().Vehicle.Collision, true);
      this.m_vehicleBlackboard.SignalBool(GetAllBlackboardDefs().Vehicle.Collision);
    };
    if gridState >= 0.40 {
      if gridID == 6 {
        if gridState >= 0.80 {
          AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"wheel_f_l_destruction", 1.00);
        };
        AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"bumper_f_destruction_side_2", 1.00);
        AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"hood_destruction", 1.00);
        AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"destruction", 1.00);
      } else {
        if gridID == 7 {
          if gridState >= 0.80 {
            AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"wheel_f_r_destruction", 1.00);
          };
          AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"bumper_f_destruction", 1.00);
          AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"hood_destruction", 1.00);
          AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"destruction", 1.00);
        } else {
          if gridID == 5 {
            AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"door_f_r_destruction", 1.00);
            AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"destruction", 1.00);
          } else {
            if gridID == 3 {
            } else {
              if gridID == 1 {
                AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"bumper_b_destruction", 1.00);
                AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"trunk_destruction", 1.00);
                AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"destruction", 1.00);
              } else {
                if gridID == 0 {
                  AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"bumper_b_destruction_side_2", 1.00);
                  AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"trunk_destruction", 1.00);
                  AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"destruction", 1.00);
                } else {
                  if gridID == 2 {
                  } else {
                    if gridID == 4 {
                      AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"door_f_l_destruction", 1.00);
                      AnimationControllerComponent.SetInputFloat(this.GetVehicle(), n"destruction", 1.00);
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  }

  private final func DetermineAdditionalEngineFX(gridID: Int32, gridState: Float) -> Void {
    if !this.m_coolerDestro {
      if gridID == 6 || gridID == 7 {
        if gridState >= 0.80 {
          GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"cooler_destro_fx", true);
          this.m_coolerDestro = true;
        };
      };
    };
  }

  private final func EvaluateDamageLevel(destruction: Float) -> Int32 {
    let statPoolMod: ref<PoolValueModifier_Record> = TweakDBInterface.GetPoolValueModifierRecord(t"BaseStatPools.VehicleHealthDecay");
    if destruction <= 75.00 && destruction > 55.00 {
      this.m_damageLevel = 1;
    } else {
      if destruction <= 55.00 && destruction > statPoolMod.RangeEnd() {
        this.m_damageLevel = 2;
      } else {
        if destruction <= statPoolMod.RangeEnd() && destruction > 0.00 {
          this.m_damageLevel = 3;
        };
      };
    };
    if GameInstance.GetGodModeSystem(this.GetVehicle().GetGame()).HasGodMode(this.GetVehicle().GetEntityID(), gameGodModeType.Immortal) {
      if this.m_damageLevel > 2 {
        this.m_damageLevel = 2;
      };
    };
    return this.m_damageLevel;
  }

  protected cb func OnVehicleDamageStageTurnOffEvent(evt: ref<VehicleDamageStageTurnOffEvent>) -> Bool {
    if this.m_damageLevel == 2 {
      this.BreakAllDamageStageFX();
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"damage_engine_stage1", false);
      this.m_damageLevel = 1;
    };
  }

  private final func PlayCrystalDomeGlitchEffect() -> Void {
    if (this.GetPS() as VehicleComponentPS).GetCrystalDomeState() {
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_fl_b", true);
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_fl_f", true);
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_fr_b", true);
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_fr_f", true);
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_ml", true);
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_mr", true);
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_ol", true);
      GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"crystal_dome_or", true);
    };
  }

  protected cb func OnVehicleOnPartDetached(evt: ref<VehicleOnPartDetachedEvent>) -> Bool {
    let partName: CName = evt.partName;
    if Equals(partName, n"Trunk") {
      (this.GetPS() as VehicleComponentPS).SetDoorState(EVehicleDoor.trunk, VehicleDoorState.Detached);
    } else {
      if Equals(partName, n"Hood") {
        (this.GetPS() as VehicleComponentPS).SetDoorState(EVehicleDoor.hood, VehicleDoorState.Detached);
      } else {
        if Equals(partName, n"DoorFrontLeft") || Equals(partName, n"DoorFrontLeft_A") || Equals(partName, n"DoorFrontLeft_B") || Equals(partName, n"DoorFrontLeft_C") {
          (this.GetPS() as VehicleComponentPS).SetDoorState(EVehicleDoor.seat_front_left, VehicleDoorState.Detached);
        } else {
          if Equals(partName, n"DoorFrontRight") || Equals(partName, n"DoorFrontRight_A") || Equals(partName, n"DoorFrontRight_B") || Equals(partName, n"DoorFrontRight_C") {
            (this.GetPS() as VehicleComponentPS).SetDoorState(EVehicleDoor.seat_front_right, VehicleDoorState.Detached);
          } else {
            if Equals(partName, n"DoorBackLeft") {
              (this.GetPS() as VehicleComponentPS).SetDoorState(EVehicleDoor.seat_back_left, VehicleDoorState.Detached);
            } else {
              if Equals(partName, n"DoorBackRight") {
                (this.GetPS() as VehicleComponentPS).SetDoorState(EVehicleDoor.seat_back_right, VehicleDoorState.Detached);
              };
            };
          };
        };
      };
    };
  }

  protected cb func OnVehicleRadioEvent(evt: ref<VehicleRadioEvent>) -> Bool {
    let toggle: Bool = evt.toggle;
    let setStation: Bool = evt.setStation;
    let station: Int32 = evt.station;
    if toggle {
      if !this.m_radioState {
        this.GetVehicle().ToggleRadioReceiver(true);
        this.m_radioState = true;
        this.m_vehicleBlackboard.SetBool(GetAllBlackboardDefs().Vehicle.VehRadioState, true);
        this.m_vehicleBlackboard.SetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.GetVehicle().GetRadioReceiverStationName());
      } else {
        this.GetVehicle().NextRadioReceiverStation();
        this.m_vehicleBlackboard.SetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.GetVehicle().GetRadioReceiverStationName());
      };
    } else {
      if !toggle {
        this.GetVehicle().ToggleRadioReceiver(false);
        if this.m_radioState {
          this.m_radioState = false;
          this.m_vehicleBlackboard.SetBool(GetAllBlackboardDefs().Vehicle.VehRadioState, false);
        };
      };
    };
    if setStation {
      this.GetVehicle().SetRadioReceiverStation(Cast(station));
      this.m_radioState = true;
      this.m_vehicleBlackboard.SetBool(GetAllBlackboardDefs().Vehicle.VehRadioState, true);
      this.m_vehicleBlackboard.SetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.GetVehicle().GetRadioReceiverStationName());
      return false;
    };
  }

  protected cb func OnVehicleRadioTierEvent(evt: ref<VehicleRadioTierEvent>) -> Bool {
    this.GetVehicle().SetRadioTier(evt.radioTier, evt.overrideTier);
  }

  private final func SendParkEvent(park: Bool) -> Void {
    let parkEvent: ref<VehicleParkedEvent>;
    if this.GetVehicle() == (this.GetVehicle() as BikeObject) {
      parkEvent = new VehicleParkedEvent();
      parkEvent.park = park;
      this.GetVehicle().QueueEvent(parkEvent);
    };
  }

  protected cb func OnVehicleLightQuestToggleEvent(evt: ref<VehicleLightQuestToggleEvent>) -> Bool {
    let toggle: Bool = evt.toggle;
    let lightType: vehicleELightType = evt.lightType;
    let vehController: ref<vehicleController> = this.GetVehicleController();
    vehController.ToggleLights(toggle, lightType);
  }

  protected cb func OnVehicleCycleLightsEvent(evt: ref<VehicleCycleLightsEvent>) -> Bool {
    this.GetVehicleControllerPS().CycleLightMode();
  }

  protected cb func OnVehicleQuestSirenEvent(evt: ref<VehicleQuestSirenEvent>) -> Bool {
    if this.m_hasSiren {
      this.ToggleSiren((this.GetPS() as VehicleComponentPS).GetSirenLightsState(), (this.GetPS() as VehicleComponentPS).GetSirenSoundsState());
    };
  }

  private final func CanShowMappin() -> Bool {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetVehicle().GetGame()).Get(GetAllBlackboardDefs().VehicleSummonData);
    if IsDefined(bb) {
      return Equals(vehicleGarageState.SummonAvailable, IntEnum(bb.GetUint(GetAllBlackboardDefs().VehicleSummonData.GarageState)));
    };
    return false;
  }

  private final func CreateMappin() -> Void {
    let isBike: Bool;
    let mappinData: MappinData;
    let system: ref<MappinSystem>;
    if this.CanShowMappin() {
      if this.m_mappinID.value == 0u {
        system = GameInstance.GetMappinSystem(this.GetVehicle().GetGame());
        isBike = this.GetVehicle() == (this.GetVehicle() as BikeObject);
        mappinData.mappinType = t"Mappins.QuestDynamicMappinDefinition";
        mappinData.variant = isBike ? gamedataMappinVariant.Zzz03_MotorcycleVariant : gamedataMappinVariant.VehicleVariant;
        mappinData.active = true;
        this.m_mappinID = system.RegisterVehicleMappin(mappinData, this.GetVehicle(), n"vehMappin");
      };
    };
  }

  private final func DestroyMappin() -> Void {
    let system: ref<MappinSystem>;
    if this.m_mappinID.value != 0u {
      system = GameInstance.GetMappinSystem(this.GetVehicle().GetGame());
      system.UnregisterMappin(this.m_mappinID);
    };
  }

  protected final func RequestHUDRefresh() -> Void {
    let request: ref<RefreshActorRequest> = new RefreshActorRequest();
    request.ownerID = this.GetVehicle().GetEntityID();
    this.GetVehicle().GetHudManager().QueueRequest(request);
  }

  protected final func SetupListeners() -> Void {
    this.SetupGameTimeToBBListener();
    this.SetupVehicleTPPBBListener();
    this.SetupVehicleSpeedBBListener();
    this.SetupVehicleRPMBBListener();
  }

  protected final func UnregisterListeners() -> Void {
    this.UnregisterGameTimeToBBListener();
    this.UnregisterVehicleTPPBBListener();
    this.UnregisterVehicleSpeedBBListener();
    this.UnregisterVehicleRPMBBListener();
  }

  protected final func SetupGameTimeToBBListener() -> Void {
    let delay: GameTime;
    let evt: ref<MinutePassedEvent>;
    if this.m_timeSystemCallbackID == 0u {
      evt = new MinutePassedEvent();
      delay = GameTime.MakeGameTime(0, 0, 1, 0);
      this.m_timeSystemCallbackID = GameInstance.GetTimeSystem(this.GetVehicle().GetGame()).RegisterDelayedListener(this.GetVehicle(), evt, delay, -1);
      this.PassGameTimeToVehBB();
    };
  }

  protected cb func OnMinutePassedEvent(evt: ref<MinutePassedEvent>) -> Bool {
    this.PassGameTimeToVehBB();
  }

  protected final func PassGameTimeToVehBB() -> Void {
    let timeString: String;
    let timeSys: ref<TimeSystem> = GameInstance.GetTimeSystem(this.GetVehicle().GetGame());
    let currTime: GameTime = timeSys.GetGameTime();
    let hours: Int32 = GameTime.Hours(currTime);
    if hours > 12 {
      hours = hours - 12;
    };
    timeString = StrReplace(SpaceFill(IntToString(hours), 2, ESpaceFillMode.JustifyRight), " ", "0") + ":" + StrReplace(SpaceFill(IntToString(GameTime.Minutes(currTime)), 2, ESpaceFillMode.JustifyRight), " ", "0");
    this.m_vehicleBlackboard.SetString(GetAllBlackboardDefs().Vehicle.GameTime, timeString);
  }

  protected final func UnregisterGameTimeToBBListener() -> Void {
    if this.m_timeSystemCallbackID > 0u {
      GameInstance.GetTimeSystem(this.GetVehicle().GetGame()).UnregisterListener(this.m_timeSystemCallbackID);
      this.m_timeSystemCallbackID = 0u;
    };
  }

  protected final func SetupVehicleTPPBBListener() -> Void {
    let activeVehicleUIBlackboard: wref<IBlackboard>;
    let bbSys: ref<BlackboardSystem>;
    if !IsDefined(this.m_vehicleTPPCallbackID) {
      bbSys = GameInstance.GetBlackboardSystem(this.GetVehicle().GetGame());
      activeVehicleUIBlackboard = bbSys.Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
      this.m_vehicleTPPCallbackID = activeVehicleUIBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsTPPCameraOn, this, n"OnVehicleCameraChange");
    };
  }

  protected final func UnregisterVehicleTPPBBListener() -> Void {
    let activeVehicleUIBlackboard: wref<IBlackboard>;
    let bbSys: ref<BlackboardSystem>;
    if IsDefined(this.m_vehicleTPPCallbackID) {
      bbSys = GameInstance.GetBlackboardSystem(this.GetVehicle().GetGame());
      activeVehicleUIBlackboard = bbSys.Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
      activeVehicleUIBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsTPPCameraOn, this.m_vehicleTPPCallbackID);
    };
  }

  protected final func OnVehicleCameraChange(state: Bool) -> Void {
    let animFeature: ref<AnimFeature_VehicleState>;
    if (this.GetPS() as VehicleComponentPS).GetCrystalDomeState() {
      animFeature = new AnimFeature_VehicleState();
      animFeature.tppEnabled = !state;
      AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), n"VehicleState", animFeature);
      this.TogglePanzerShadowMeshes(state);
    };
  }

  protected final func SetupVehicleSpeedBBListener() -> Void {
    let vehicleDefBlackboard: wref<IBlackboard>;
    if !IsDefined(this.m_vehicleSpeedCallbackID) {
      vehicleDefBlackboard = this.GetVehicle().GetBlackboard();
      this.m_vehicleSpeedCallbackID = vehicleDefBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnVehicleSpeedChange");
    };
  }

  protected final func UnregisterVehicleSpeedBBListener() -> Void {
    let vehicleDefBlackboard: wref<IBlackboard>;
    if IsDefined(this.m_vehicleSpeedCallbackID) {
      vehicleDefBlackboard = this.GetVehicle().GetBlackboard();
      vehicleDefBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_vehicleSpeedCallbackID);
    };
  }

  protected final func SetupVehicleRPMBBListener() -> Void {
    let vehicleDefBlackboard: wref<IBlackboard>;
    if !IsDefined(this.m_vehicleRPMCallbackID) {
      vehicleDefBlackboard = this.GetVehicle().GetBlackboard();
      this.m_vehicleRPMCallbackID = vehicleDefBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnVehicleRPMChange");
    };
  }

  protected final func UnregisterVehicleRPMBBListener() -> Void {
    let vehicleDefBlackboard: wref<IBlackboard>;
    if IsDefined(this.m_vehicleRPMCallbackID) {
      vehicleDefBlackboard = this.GetVehicle().GetBlackboard();
      vehicleDefBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_vehicleRPMCallbackID);
    };
  }

  protected final func OnVehicleSpeedChange(speed: Float) -> Void {
    let animFeature: ref<AnimFeature_PartData>;
    let doors: array<CName>;
    let vehDataPackage: wref<VehicleDataPackage_Record>;
    if this.m_hasSpoiler {
      if !this.m_spoilerDeployed {
        if speed >= this.m_spoilerUp {
          animFeature = new AnimFeature_PartData();
          animFeature.state = 1;
          animFeature.duration = 0.75;
          AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), n"spoiler", animFeature);
          this.m_spoilerDeployed = true;
        };
      } else {
        if speed <= this.m_spoilerDown {
          animFeature = new AnimFeature_PartData();
          animFeature.state = 3;
          animFeature.duration = 0.75;
          AnimationControllerComponent.ApplyFeatureToReplicate(this.GetVehicle(), n"spoiler", animFeature);
          this.m_spoilerDeployed = false;
        };
      };
    };
    if (this.GetPS() as VehicleComponentPS).GetHasAnyDoorOpen() {
      if this.m_ignoreAutoDoorClose {
        return;
      };
      VehicleComponent.GetVehicleDataPackage(this.GetVehicle().GetGame(), this.GetVehicle(), vehDataPackage);
      if speed < 0.00 {
        speed = AbsF(speed);
      };
      if speed < 0.50 {
        return;
      };
      if speed >= vehDataPackage.SpeedToClose() {
        ArrayPush(doors, n"seat_front_left");
        ArrayPush(doors, n"seat_front_right");
        ArrayPush(doors, n"hood");
        if !vehDataPackage.SlidingRearDoors() {
          ArrayPush(doors, n"seat_back_left");
          ArrayPush(doors, n"seat_back_right");
        };
        if !vehDataPackage.BarnDoorsTailgate() {
          ArrayPush(doors, n"trunk");
        };
        this.CloseSelectedDoors(doors);
        ArrayClear(doors);
      };
    };
  }

  private final func CloseSelectedDoors(doors: array<CName>) -> Void {
    let PSVehicleDoorCloseRequest: ref<VehicleDoorClose>;
    let size: Int32 = ArraySize(doors);
    let i: Int32 = 0;
    while i < size {
      PSVehicleDoorCloseRequest = new VehicleDoorClose();
      PSVehicleDoorCloseRequest.slotID = doors[i];
      GameInstance.GetPersistencySystem(this.GetVehicle().GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), PSVehicleDoorCloseRequest);
      i += 1;
    };
    (this.GetPS() as VehicleComponentPS).SetHasAnyDoorOpen(false);
  }

  protected final func OnVehicleRPMChange(rpm: Float) -> Void {
    let value: Float;
    if rpm >= 2500.00 {
      if !this.m_overheatActive {
        if !IsDefined(this.m_overheatEffectBlackboard) {
          this.m_overheatEffectBlackboard = new worldEffectBlackboard();
          this.m_overheatEffectBlackboard.SetValue(n"overheatValue", 1.00);
        };
        GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"overheating", false, this.m_overheatEffectBlackboard);
        this.m_overheatActive = true;
      };
      value = (7100.00 - rpm) / 7100.00;
      this.m_overheatEffectBlackboard.SetValue(n"overheatValue", value);
    } else {
      if this.m_overheatActive {
        GameObjectEffectHelper.BreakEffectLoopEvent(this.GetVehicle(), n"overheating");
        this.m_overheatActive = false;
      };
    };
  }

  protected final func StartEffectEvent(self: ref<GameObject>, effectName: CName, opt shouldPersist: Bool, opt blackboard: ref<worldEffectBlackboard>) -> Void {
    let evt: ref<entSpawnEffectEvent>;
    if !IsNameValid(effectName) {
      return;
    };
    evt = new entSpawnEffectEvent();
    evt.effectName = effectName;
    evt.persistOnDetach = shouldPersist;
    evt.blackboard = blackboard;
    this.GetVehicle().QueueEvent(evt);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let radioEvent: ref<VehicleRadioEvent>;
    let releaseTime: Float;
    let sirenState: Bool;
    let vehicle: ref<VehicleObject>;
    if (this.GetPS() as VehicleComponentPS).GetIsDestroyed() {
      return false;
    };
    vehicle = this.GetVehicle();
    if !IsDefined(vehicle) {
      return false;
    };
    if Equals(ListenerAction.GetName(action), n"VehicleInsideWheel") {
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(vehicle, n"VehicleBlockRadioInput") {
        if ListenerAction.IsButtonJustPressed(action) {
          this.m_radioPressTime = EngineTime.ToFloat(GameInstance.GetEngineTime(vehicle.GetGame()));
        };
        if ListenerAction.IsButtonJustReleased(action) {
          releaseTime = EngineTime.ToFloat(GameInstance.GetEngineTime(vehicle.GetGame()));
          if releaseTime <= this.m_radioPressTime + 0.20 {
            radioEvent = new VehicleRadioEvent();
            radioEvent.toggle = true;
            vehicle.QueueEvent(radioEvent);
          };
        };
      };
    };
    if Equals(ListenerAction.GetName(action), n"VehicleHorn") {
      if this.m_hasSiren {
        sirenState = (this.GetPS() as VehicleComponentPS).GetSirenState();
        if ListenerAction.IsButtonJustPressed(action) {
          this.m_hornPressTime = EngineTime.ToFloat(GameInstance.GetEngineTime(vehicle.GetGame()));
        };
        if ListenerAction.IsButtonJustReleased(action) {
          releaseTime = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetVehicle().GetGame()));
          if releaseTime <= this.m_hornPressTime + 0.20 {
            this.ToggleSiren(!sirenState, !sirenState);
          };
          if sirenState {
            vehicle.ToggleHorn(false, true);
          } else {
            vehicle.ToggleHorn(false);
          };
          this.m_hornOn = false;
        };
        if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_HOLD_COMPLETE) {
          if sirenState {
            vehicle.ToggleHorn(true, true);
          } else {
            vehicle.ToggleHorn(true);
          };
          vehicle.GetStimBroadcasterComponent().TriggerSingleBroadcast(vehicle, gamedataStimType.VehicleHorn);
          this.m_hornOn = true;
        };
      } else {
        if ListenerAction.GetValue(action) == 1.00 && !this.m_hornOn {
          vehicle.GetStimBroadcasterComponent().TriggerSingleBroadcast(vehicle, gamedataStimType.VehicleHorn);
          vehicle.ToggleHorn(true);
          this.m_hornOn = true;
        } else {
          if ListenerAction.GetValue(action) < 1.00 && this.m_hornOn {
            vehicle.ToggleHorn(false);
            this.m_hornOn = false;
          };
        };
      };
    };
  }

  protected cb func OnVehicleQuestHornEvent(evt: ref<VehicleQuestHornEvent>) -> Bool {
    let delayTimer: Float;
    let hornOffDelayEvent: ref<VehicleHornOffDelayEvent>;
    this.GetVehicle().ToggleHorn(true);
    this.m_hornOn = true;
    delayTimer = evt.honkTime;
    if delayTimer == 0.00 {
      delayTimer = 4.00;
    };
    hornOffDelayEvent = new VehicleHornOffDelayEvent();
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).DelayEvent(this.GetVehicle(), hornOffDelayEvent, delayTimer);
  }

  protected cb func OnVehicleHornProbEvent(evt: ref<VehicleHornProbsEvent>) -> Bool {
    let delayTimer: Float;
    let hornOffDelayEvent: ref<VehicleHornOffDelayEvent>;
    let vehicleObject: wref<VehicleObject>;
    let randomDraw: Float = RandRangeF(0.00, 1.00);
    if randomDraw <= evt.probability {
      vehicleObject = this.GetVehicle();
      vehicleObject.ToggleHorn(true);
      this.m_hornOn = true;
      delayTimer = RandRangeF(evt.honkMinTime, evt.honkMaxTime);
      if delayTimer == 0.00 {
        delayTimer = 3.00;
      };
      hornOffDelayEvent = new VehicleHornOffDelayEvent();
      GameInstance.GetDelaySystem(vehicleObject.GetGame()).DelayEvent(vehicleObject, hornOffDelayEvent, delayTimer);
    };
  }

  protected cb func OnVehicleHornOffDelayEvent(evt: ref<VehicleHornOffDelayEvent>) -> Bool {
    this.GetVehicle().ToggleHorn(false);
    this.m_hornOn = false;
  }

  protected final func ToggleSiren(lights: Bool, sounds: Bool) -> Void {
    if this.m_hasSiren && !(this.GetPS() as VehicleComponentPS).GetIsDestroyed() {
      this.GetVehicleController().ToggleLights(lights, vehicleELightType.Utility);
      if lights {
        this.StartEffectEvent(this.GetVehicle(), n"police_sign_combat", true);
      } else {
        if !lights {
          this.StartEffectEvent(this.GetVehicle(), n"police_sign_default", true);
        };
      };
      (this.GetPS() as VehicleComponentPS).SetSirenLightsState(lights);
      this.GetVehicle().ToggleSiren(sounds);
      (this.GetPS() as VehicleComponentPS).SetSirenSoundsState(sounds);
      if lights || sounds {
        (this.GetPS() as VehicleComponentPS).SetSirenState(true);
      } else {
        (this.GetPS() as VehicleComponentPS).SetSirenState(false);
      };
    };
  }

  protected cb func OnVehicleSirenDelayEvent(evt: ref<VehicleSirenDelayEvent>) -> Bool {
    this.ToggleSiren(evt.lights, evt.sounds);
  }

  protected cb func OnVehicleFlippedOverEvent(evt: ref<VehicleFlippedOverEvent>) -> Bool {
    if !evt.isFlippedOver {
      this.RemoveVehicleDOT();
    };
  }

  protected cb func OnHasVehicleBeenFlippedOverForSomeTimeEvent(evt: ref<HasVehicleBeenFlippedOverForSomeTimeEvent>) -> Bool {
    let godMode: gameGodModeType;
    let isDestroyed: Bool = (this.GetPS() as VehicleComponentPS).GetIsDestroyed();
    if isDestroyed {
      return false;
    };
    if GetImmortality(this.GetVehicle(), godMode) {
      return false;
    };
    this.ApplyVehicleDOT();
  }

  protected final func ApplyVehicleDOT(opt type: CName) -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetVehicle().GetGame());
    switch type {
      case n"high":
        if !statusEffectSystem.HasStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleHighDamageOverTimeEffect") {
          statusEffectSystem.ApplyStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleHighDamageOverTimeEffect", this.GetVehicle().GetRecordID(), this.GetVehicle().GetEntityID());
        };
        break;
      default:
        if !statusEffectSystem.HasStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleBaseDamageOverTimeEffect") {
          statusEffectSystem.ApplyStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleBaseDamageOverTimeEffect", this.GetVehicle().GetRecordID(), this.GetVehicle().GetEntityID());
        };
    };
  }

  protected final func RemoveVehicleDOT() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetVehicle().GetGame());
    if statusEffectSystem.HasStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleHighDamageOverTimeEffect") {
      statusEffectSystem.RemoveStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleHighDamageOverTimeEffect");
    };
    if statusEffectSystem.HasStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleBaseDamageOverTimeEffect") {
      statusEffectSystem.RemoveStatusEffect(this.GetVehicle().GetEntityID(), t"BaseStatusEffect.VehicleBaseDamageOverTimeEffect");
    };
  }

  protected cb func OnVehicleQuestAVThrusterEvent(evt: ref<VehicleQuestAVThrusterEvent>) -> Bool {
    this.SetupThrusterFX();
  }

  protected cb func OnVehicleQuestWindowDestructionEvent(evt: ref<VehicleQuestWindowDestructionEvent>) -> Bool {
    let windowName: CName;
    let windowDestructionEvent: ref<VehicleGlassDestructionEvent> = new VehicleGlassDestructionEvent();
    if NotEquals(evt.windowName, n"") {
      windowName = evt.windowName;
    } else {
      windowName = EnumValueToName(n"vehicleQuestWindowDestruction", Cast(EnumInt(evt.window)));
    };
    windowDestructionEvent.glassName = windowName;
    this.GetVehicle().QueueEvent(windowDestructionEvent);
  }

  protected cb func OnFactChangedEvent(evt: ref<FactChangedEvent>) -> Bool {
    let forwardEvent: ref<VehicleForwardRaceCheckpointFactEvent>;
    let uiSystem: ref<UISystem>;
    if Equals(evt.GetFactName(), n"sq024_current_race_checkpoint_fact_add") {
      uiSystem = GameInstance.GetUISystem(this.GetVehicle().GetGame());
      forwardEvent = new VehicleForwardRaceCheckpointFactEvent();
      uiSystem.QueueEvent(forwardEvent);
    };
  }

  protected cb func OnVehicleRaceQuestEvent(evt: ref<VehicleRaceQuestEvent>) -> Bool {
    switch evt.mode {
      case vehicleRaceUI.RaceStart:
        this.ToggleRaceClock(true);
        break;
      case vehicleRaceUI.RaceEnd:
        this.ToggleRaceClock(false);
    };
  }

  private final func ToggleRaceClock(toggle: Bool) -> Void {
    let raceClockEvent: ref<VehicleRaceClockUpdateEvent>;
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetVehicle().GetGame());
    if toggle {
      raceClockEvent = new VehicleRaceClockUpdateEvent();
      this.m_raceClockTickID = delaySystem.TickOnEvent(this.GetVehicle(), raceClockEvent, 600.00);
    } else {
      delaySystem.CancelTick(this.m_raceClockTickID);
    };
  }

  protected cb func OnVehicleRaceClockUpdateEvent(evt: ref<VehicleRaceClockUpdateEvent>) -> Bool {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetVehicle().GetGame());
    let forwardEvent: ref<VehicleForwardRaceClockUpdateEvent> = new VehicleForwardRaceClockUpdateEvent();
    uiSystem.QueueEvent(forwardEvent);
  }

  protected final func CleanUpRace() -> Void {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetVehicle().GetGame());
    GameInstance.GetDelaySystem(this.GetVehicle().GetGame()).CancelTick(this.m_raceClockTickID);
    uiSystem.PopGameContext(UIGameContext.VehicleRace);
  }

  private final func CreateObjectActionsCallbackController(instigator: wref<Entity>) -> Void {
    this.m_objectActionsCallbackCtrl = gameObjectActionsCallbackController.Create(this.GetEntity(), instigator, this.GetVehicle().GetGame());
    this.m_objectActionsCallbackCtrl.RegisterSkillCheckCallbacks();
  }

  private final func DestroyObjectActionsCallbackController() -> Void {
    this.m_objectActionsCallbackCtrl.UnregisterSkillCheckCallbacks();
    this.m_objectActionsCallbackCtrl = null;
  }

  protected cb func OnObjectActionRefreshEvent(evt: ref<gameObjectActionRefreshEvent>) -> Bool {
    if IsDefined(this.m_objectActionsCallbackCtrl) {
      this.m_objectActionsCallbackCtrl.UnlockNotifications();
      this.DetermineInteractionState();
    };
  }

  protected cb func OnVehicleQuestToggleEngineEvent(evt: ref<VehicleQuestToggleEngineEvent>) -> Bool {
    this.ToggleVehicleSystems(evt.toggle, true, true);
  }

  protected cb func OnSetIgnoreAutoDoorCloseEvent(evt: ref<SetIgnoreAutoDoorCloseEvent>) -> Bool {
    this.m_ignoreAutoDoorClose = evt.set;
  }
}

public class VehicleHealthStatPoolListener extends CustomValueStatPoolsListener {

  public let m_owner: wref<VehicleObject>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if IsDefined(this.m_owner) && IsDefined(this.m_owner.GetVehicleComponent()) {
      this.m_owner.GetVehicleComponent().ReactToHPChange(newValue);
    };
  }
}

public class VehicleRadioTierEvent extends Event {

  @default(VehicleRadioTierEvent, 1)
  public edit let radioTier: Uint32;

  public edit let overrideTier: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle or set Radio Tier";
  }
}

public static exec func EnableVehicleToggleSummonMode(gameInstance: GameInstance, value: String) -> Void {
  let intValue: Int32 = StringToInt(value);
  let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(gameInstance).Get(GetAllBlackboardDefs().GameplaySettings);
  if intValue == 1 {
    blackboard.SetBool(GetAllBlackboardDefs().GameplaySettings.EnableVehicleToggleSummonMode, true);
  } else {
    blackboard.SetBool(GetAllBlackboardDefs().GameplaySettings.EnableVehicleToggleSummonMode, false);
  };
}
