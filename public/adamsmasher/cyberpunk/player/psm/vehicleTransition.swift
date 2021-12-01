
public abstract class VehicleTransition extends DefaultTransition {

  public const let stateMachineInitData: wref<VehicleTransitionInitData>;

  public final static func CanEnterDriverCombat() -> Bool {
    return TweakDBInterface.GetBool(t"player.vehicle.canEnterDriverCombat", false);
  }

  protected final const func IsPlayerAllowedToEnterCombat(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsNoCombatActionsForced(scriptInterface) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleCombat") {
      return true;
    };
    return true;
  }

  protected final const func IsPlayerAllowedToExitCombat(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleCombatBlockExit") {
      return false;
    };
    return true;
  }

  protected final const func IsPlayerAllowedToExitVehicle(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleScene") {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleCombat") {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleBlockExit") {
      return false;
    };
    if this.IsInPhotoMode(scriptInterface) {
      return false;
    };
    return true;
  }

  protected final const func PlayerWantsToExitVehicle(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let stateTime: Float;
    if scriptInterface.IsActionJustHeld(n"Exit") {
      stateTime = this.GetInStateTime();
      if stateTime >= 0.30 {
        return true;
      };
    };
    return false;
  }

  protected final func SetOneHandedFirearmsGameplayRestriction(scriptInterface: ref<StateGameScriptInterface>, shouleAdd: Bool) -> Void {
    if Equals(shouleAdd, true) {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.OneHandedFirearms");
    } else {
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.OneHandedFirearms");
    };
  }

  protected final func SetFirearmsGameplayRestriction(scriptInterface: ref<StateGameScriptInterface>, shouleAdd: Bool) -> Void {
    if Equals(shouleAdd, true) {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Firearms");
    } else {
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Firearms");
    };
  }

  protected final const func IsDriverInVehicle(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsDriverInVehicle();
  }

  protected final const func IsPassengerInVehicle(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsPassengerInVehicle();
  }

  protected final func SendAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_VehicleData> = new AnimFeature_VehicleData();
    animFeature.isInVehicle = stateContext.GetBoolParameter(n"isInVehicle", true);
    animFeature.isDriver = stateContext.GetBoolParameter(n"isDriver", true);
    animFeature.vehType = stateContext.GetIntParameter(n"vehType", true);
    animFeature.vehSlot = stateContext.GetIntParameter(n"vehSlot", true);
    animFeature.isInCombat = stateContext.GetBoolParameter(n"isInVehCombat", true);
    animFeature.isInWindowCombat = stateContext.GetBoolParameter(n"isInVehWindowCombat", true);
    animFeature.isInDriverCombat = stateContext.GetBoolParameter(n"isInDriverCombat", true);
    animFeature.vehClass = stateContext.GetIntParameter(n"vehClass", true);
    animFeature.isEnteringCombat = stateContext.GetBoolParameter(n"isEnteringCombat", true);
    animFeature.enteringCombatDuration = this.GetVehicleDataPackage(stateContext).ToCombat();
    animFeature.isExitingCombat = stateContext.GetBoolParameter(n"isExitingCombat", true);
    animFeature.exitingCombatDuration = this.GetVehicleDataPackage(stateContext).FromCombat();
    animFeature.isEnteringVehicle = stateContext.GetBoolParameter(n"isEnteringVehicle", true);
    animFeature.isExitingVehicle = stateContext.GetBoolParameter(n"isExitingVehicle", true);
    animFeature.isWorldRenderPlane = stateContext.GetBoolParameter(n"isWorldRenderPlane", true);
    scriptInterface.SetAnimationParameterFeature(n"VehicleData", animFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"VehicleData", animFeature);
  }

  protected final func ResetAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_VehicleData> = new AnimFeature_VehicleData();
    scriptInterface.SetAnimationParameterFeature(n"VehicleData", animFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"VehicleData", animFeature);
  }

  protected final func ResetVehParams(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsInVehicle(stateContext, false);
    this.SetIsVehicleDriver(stateContext, false);
    this.SetVehicleType(stateContext, 0);
    this.SetIsInVehicleCombat(stateContext, false);
    this.SetIsInVehicleWindowCombat(stateContext, false);
    this.SetIsInVehicleDriverCombat(stateContext, false);
    this.SetVehicleClass(stateContext, 0);
    this.SetIsEnteringCombat(stateContext, false);
    this.SetIsExitingCombat(stateContext, false);
    this.SetIsWorldRenderPlane(stateContext, false);
    this.SetIsCar(stateContext, false);
    this.SetWasStolen(stateContext, false);
    stateContext.SetPermanentIntParameter(n"vehSlot", 0, true);
    stateContext.SetPermanentIntParameter(n"vehUnmountDir", 0, true);
  }

  protected final func SendIsCar(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_VehiclePassenger> = new AnimFeature_VehiclePassenger();
    animFeature.isCar = stateContext.GetBoolParameter(n"isCar", true);
    scriptInterface.SetAnimationParameterFeature(n"VehiclePassenger", animFeature, scriptInterface.executionOwner);
  }

  protected final func ResetIsCar(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_VehiclePassenger> = new AnimFeature_VehiclePassenger();
    animFeature.isCar = false;
    scriptInterface.SetAnimationParameterFeature(n"VehiclePassenger", animFeature, scriptInterface.executionOwner);
  }

  protected final func SetIsInVehicle(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isInVehicle", value, true);
  }

  protected final func SetIsVehicleDriver(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isDriver", value, true);
  }

  protected final func SetVehicleType(stateContext: ref<StateContext>, value: Int32) -> Void {
    stateContext.SetPermanentIntParameter(n"vehType", value, true);
  }

  protected final func SetIsInVehicleCombat(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isInVehCombat", value, true);
  }

  protected final func SetIsInVehicleWindowCombat(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isInVehWindowCombat", value, true);
  }

  protected final func SetIsInVehicleDriverCombat(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isInDriverCombat", value, true);
  }

  protected final func SetVehicleClass(stateContext: ref<StateContext>, value: Int32) -> Void {
    stateContext.SetPermanentIntParameter(n"vehClass", value, true);
  }

  protected final func SetIsEnteringCombat(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isEnteringCombat", value, true);
  }

  protected final func SetIsExitingCombat(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isExitingCombat", value, true);
  }

  protected final func SetIsWorldRenderPlane(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isWorldRenderPlane", value, true);
  }

  protected final func SetIsCar(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isCar", value, true);
  }

  protected final func SetWasStolen(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"wasStolen", value, true);
  }

  protected final const func SetWasCombatForced(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"wasCombatForced", value, true);
  }

  protected final const func SetRequestedTPPCamera(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"requestedTPPCamera", value, true);
  }

  protected final func SetSide(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let value: Int32;
    let mountingInfo: MountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    let slotName: CName = mountingInfo.slotId.id;
    if Equals(slotName, n"seat_front_left") {
      value = 1;
    } else {
      if Equals(slotName, n"seat_back_left") {
        value = 1;
      } else {
        if Equals(slotName, n"seat_front_right") {
          value = 2;
        } else {
          if Equals(slotName, n"seat_back_right") {
            value = 2;
          } else {
            value = 0;
          };
        };
      };
    };
    stateContext.SetPermanentIntParameter(n"vehSlot", value, true);
  }

  protected final func IsUnmountDirectionClosest(stateContext: ref<StateContext>, unmountDirection: vehicleExitDirection) -> Bool {
    let side: Int32 = stateContext.GetIntParameter(n"vehSlot", true);
    if side == 1 && Equals(unmountDirection, vehicleExitDirection.Left) {
      return true;
    };
    if side == 2 && Equals(unmountDirection, vehicleExitDirection.Right) {
      return true;
    };
    return false;
  }

  protected final func IsUnmountDirectionOpposite(stateContext: ref<StateContext>, unmountDirection: vehicleExitDirection) -> Bool {
    let side: Int32 = stateContext.GetIntParameter(n"vehSlot", true);
    if side == 1 && Equals(unmountDirection, vehicleExitDirection.Right) {
      return true;
    };
    if side == 2 && Equals(unmountDirection, vehicleExitDirection.Left) {
      return true;
    };
    return false;
  }

  public final static func CheckVehicleDesiredTag(const scriptInterface: ref<StateGameScriptInterface>, desiredTag: CName) -> Bool {
    let tags: array<CName>;
    let recordID: TweakDBID = (scriptInterface.owner as VehicleObject).GetRecordID();
    let vehicleRecord: ref<Vehicle_Record> = TweakDBInterface.GetVehicleRecord(recordID);
    if !IsDefined(vehicleRecord) {
      return false;
    };
    tags = vehicleRecord.Tags();
    if ArrayContains(tags, desiredTag) {
      return true;
    };
    return false;
  }

  protected final func SetVehFppCameraParams(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isPassenger: Bool, opt side: Bool, opt combat: Bool) -> Void {
    let vehCamParamsRecord: ref<VehicleFPPCameraParams_Record>;
    let recordID: TweakDBID = (scriptInterface.owner as VehicleObject).GetRecordID();
    let vehicleRecord: ref<Vehicle_Record> = TweakDBInterface.GetVehicleRecord(recordID);
    let camBodyOffset: ref<AnimFeature_CameraBodyOffset> = new AnimFeature_CameraBodyOffset();
    let camGameplay: ref<AnimFeature_CameraGameplay> = new AnimFeature_CameraGameplay();
    if combat {
      if !isPassenger {
        vehCamParamsRecord = vehicleRecord.VehDriverCombat_FPPCameraParams();
      };
      if isPassenger {
        if Equals(side, true) {
          vehCamParamsRecord = vehicleRecord.VehPassCombatL_FPPCameraParams();
        } else {
          vehCamParamsRecord = vehicleRecord.VehPassCombatR_FPPCameraParams();
        };
      };
    } else {
      if !isPassenger {
        vehCamParamsRecord = vehicleRecord.VehDriver_FPPCameraParams();
      };
      if isPassenger {
        if Equals(side, true) {
          vehCamParamsRecord = vehicleRecord.VehPassL_FPPCameraParams();
        } else {
          vehCamParamsRecord = vehicleRecord.VehPassR_FPPCameraParams();
        };
      };
    };
    camBodyOffset.lookat_pitch_forward_offset = vehCamParamsRecord.Lookat_pitch_forward_offset();
    camBodyOffset.lookat_pitch_forward_down_ratio = vehCamParamsRecord.Lookat_pitch_forward_down_ratio();
    camBodyOffset.lookat_yaw_left_offset = vehCamParamsRecord.Lookat_yaw_left_offset();
    camBodyOffset.lookat_yaw_left_up_offset = vehCamParamsRecord.Lookat_yaw_left_up_offset();
    camBodyOffset.lookat_yaw_right_offset = vehCamParamsRecord.Lookat_yaw_right_offset();
    camBodyOffset.lookat_yaw_right_up_offset = vehCamParamsRecord.Lookat_yaw_right_up_offset();
    camBodyOffset.lookat_yaw_offset_active_angle = vehCamParamsRecord.Lookat_yaw_offset_active_angle();
    camBodyOffset.is_paralax = vehCamParamsRecord.Is_paralax();
    camBodyOffset.paralax_radius = vehCamParamsRecord.Paralax_radius();
    camBodyOffset.paralax_forward_offset = vehCamParamsRecord.Paralax_forward_offset();
    camBodyOffset.lookat_offset_vertical = vehCamParamsRecord.Lookat_offset_vertical();
    camGameplay.is_forward_offset = vehCamParamsRecord.Is_forward_offset();
    camGameplay.forward_offset_value = vehCamParamsRecord.Forward_offset_value();
    camGameplay.upperbody_pitch_weight = vehCamParamsRecord.Upperbody_pitch_weight();
    camGameplay.upperbody_yaw_weight = vehCamParamsRecord.Upperbody_yaw_weight();
    camGameplay.is_pitch_off = vehCamParamsRecord.Is_pitch_off();
    camGameplay.is_yaw_off = vehCamParamsRecord.Is_yaw_off();
    scriptInterface.SetAnimationParameterFeature(n"CameraBodyOffset", camBodyOffset, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"CameraGameplay", camGameplay, scriptInterface.executionOwner);
  }

  protected final func ResetVehFppCameraParams(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.SetAnimationParameterFeature(n"CameraBodyOffset", new AnimFeature_CameraBodyOffset(), scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"CameraGameplay", new AnimFeature_CameraGameplay(), scriptInterface.executionOwner);
  }

  protected final func GetVehType(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
    let recordID: TweakDBID = (scriptInterface.owner as VehicleObject).GetRecordID();
    let vehicleRecord: ref<Vehicle_Record> = TweakDBInterface.GetVehicleRecord(recordID);
    let vehicleDataPackage: wref<VehicleDataPackage_Record> = vehicleRecord.VehDataPackage();
    let templateName: CName = vehicleDataPackage.SeatingTemplateOverride();
    if Equals(templateName, n"standard_vehicle") {
      return 0;
    };
    if Equals(templateName, n"sport_vehicle") || Equals(templateName, n"sport1_vehicle") {
      return 1;
    };
    return 0;
  }

  protected final func GetVehClass(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
    let vehClassInt: Int32;
    let recordID: TweakDBID = (scriptInterface.owner as VehicleObject).GetRecordID();
    let vehicleRecord: ref<Vehicle_Record> = TweakDBInterface.GetVehicleRecord(recordID);
    let vehTypeRecord: ref<VehicleType_Record> = vehicleRecord.Type();
    let vehClassName: String = vehTypeRecord.EnumName();
    switch vehClassName {
      case "Car":
        vehClassInt = 0;
        break;
      case "Bike":
        vehClassInt = 1;
        break;
      case "Panzer":
        vehClassInt = 2;
        break;
      default:
        vehClassInt = 0;
    };
    return vehClassInt;
  }

  protected final func GetAdjacentSeat(slotName: CName, out nextSlotName: CName) -> Bool {
    if !IsNameValid(slotName) {
      return false;
    };
    switch slotName {
      case n"seat_front_left":
        nextSlotName = n"seat_front_right";
        break;
      case n"seat_front_right":
        nextSlotName = n"seat_front_left";
        break;
      case n"seat_back_left":
        nextSlotName = n"seat_back_right";
        break;
      case n"seat_back_right":
        nextSlotName = n"seat_back_left";
    };
    return true;
  }

  protected final func IsAdjacentSeatAvailable(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, slotName: CName) -> Bool {
    let adjacentSeat: CName;
    let doorName: EVehicleDoor;
    let seatInteractionAvailable: Bool;
    let vehicle: wref<VehicleObject>;
    if !IsNameValid(slotName) {
      return false;
    };
    vehicle = scriptInterface.owner as VehicleObject;
    this.GetAdjacentSeat(slotName, adjacentSeat);
    vehicle.GetVehiclePS().GetVehicleDoorEnum(doorName, adjacentSeat);
    seatInteractionAvailable = NotEquals(vehicle.GetVehiclePS().GetDoorInteractionState(doorName), VehicleDoorInteractionState.Disabled);
    if !seatInteractionAvailable {
      return false;
    };
    if !VehicleComponent.IsSlotAvailable(scriptInterface.GetGame(), vehicle, n"seat_front_left") {
      return false;
    };
    return true;
  }

  protected final func SendEquipToHandsRequest(scriptInterface: ref<StateGameScriptInterface>, itemID: ItemID) -> Void {
    let drawItemRequest: ref<DrawItemRequest>;
    let equipmentSystem: ref<EquipmentSystem> = scriptInterface.GetScriptableSystem(n"EquipmentSystem") as EquipmentSystem;
    let equipRequest: ref<EquipRequest> = new EquipRequest();
    equipRequest.itemID = itemID;
    equipRequest.addToInventory = true;
    equipRequest.owner = scriptInterface.executionOwner;
    equipmentSystem.QueueRequest(equipRequest);
    drawItemRequest = new DrawItemRequest();
    drawItemRequest.owner = scriptInterface.executionOwner;
    drawItemRequest.itemID = itemID;
    equipmentSystem.QueueRequest(drawItemRequest);
  }

  protected final func RequestToggleVehicleCamera(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let camEvent: ref<vehicleRequestCameraPerspectiveEvent>;
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) {
      return;
    };
    camEvent = new vehicleRequestCameraPerspectiveEvent();
    switch (scriptInterface.owner as VehicleObject).GetCameraManager().GetActivePerspective() {
      case vehicleCameraPerspective.FPP:
        camEvent.cameraPerspective = vehicleCameraPerspective.TPPFar;
        break;
      case vehicleCameraPerspective.TPPClose:
        camEvent.cameraPerspective = vehicleCameraPerspective.FPP;
        break;
      case vehicleCameraPerspective.TPPFar:
        camEvent.cameraPerspective = vehicleCameraPerspective.TPPClose;
    };
    scriptInterface.executionOwner.QueueEvent(camEvent);
  }

  protected final func ResetVehicleCamera(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let camEvent: ref<vehicleCameraResetEvent> = new vehicleCameraResetEvent();
    scriptInterface.executionOwner.QueueEvent(camEvent);
  }

  protected final func ToggleWindowForOccupiedSeat(scriptInterface: ref<StateGameScriptInterface>, slotName: CName, shouldopen: Bool) -> Void {
    let VehWindowRequestEvent: ref<VehicleExternalWindowRequestEvent> = new VehicleExternalWindowRequestEvent();
    VehWindowRequestEvent.slotName = slotName;
    VehWindowRequestEvent.shouldOpen = shouldopen;
    scriptInterface.owner.QueueEvent(VehWindowRequestEvent);
  }

  protected final const func GetUnmountingEvent(const stateContext: ref<StateContext>) -> ref<MountEventData> {
    let unmountEvent: ref<MountEventData> = stateContext.GetPermanentScriptableParameter(n"Unmount") as MountEventData;
    return unmountEvent;
  }

  protected final const func IsExitForced(const stateContext: ref<StateContext>) -> Bool {
    return IsDefined(this.GetUnmountingEvent(stateContext));
  }

  protected final func RemoveUnmountingRequest(stateContext: ref<StateContext>) -> Void {
    stateContext.RemovePermanentScriptableParameter(n"Unmount");
  }

  protected final func RemoveMountingRequest(stateContext: ref<StateContext>) -> Void {
    stateContext.RemovePermanentScriptableParameter(n"Mount");
  }

  protected final func StartLeavingVehicle(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isInstant: Bool;
    let vehicleUpsideDown: Bool;
    let evt: ref<VehicleStartedMountingEvent> = new VehicleStartedMountingEvent();
    let vehicle: ref<VehicleObject> = scriptInterface.owner as VehicleObject;
    let unmountEvent: ref<MountEventData> = this.GetUnmountingEvent(stateContext);
    if IsDefined(unmountEvent) {
      isInstant = unmountEvent.isInstant;
    } else {
      isInstant = false;
    };
    vehicleUpsideDown = vehicle.IsVehicleUpsideDown();
    if !isInstant && vehicleUpsideDown {
      this.ExitWorkspot(stateContext, scriptInterface, isInstant, true);
    } else {
      this.ExitWorkspot(stateContext, scriptInterface, isInstant);
    };
    this.SetIsInVehicle(stateContext, false);
    this.SendAnimFeature(stateContext, scriptInterface);
    evt.slotID = vehicle.GetSlotIdForMountedObject(scriptInterface.executionOwner);
    evt.isMounting = false;
    evt.character = scriptInterface.executionOwner;
    vehicle.QueueEvent(evt);
  }

  protected final func PlayVehicleExitDoorAnimation(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let vehicle: ref<VehicleObject> = scriptInterface.owner as VehicleObject;
    let mountInfo: MountingInfo = scriptInterface.GetMountingFacility().GetMountingInfoSingleWithObjects(scriptInterface.executionOwner);
    let VehDoorRequestEvent: ref<VehicleExternalDoorRequestEvent> = new VehicleExternalDoorRequestEvent();
    VehDoorRequestEvent.slotName = mountInfo.slotId.id;
    VehDoorRequestEvent.autoCloseTime = this.GetVehicleDataPackage(stateContext).Normal_open();
    VehDoorRequestEvent.autoClose = !VehicleComponent.IsDestroyed(scriptInterface.GetGame(), mountInfo.parentId);
    let tempDisableAutoCloseDoor: ref<SetIgnoreAutoDoorCloseEvent> = new SetIgnoreAutoDoorCloseEvent();
    tempDisableAutoCloseDoor.set = true;
    vehicle.QueueEvent(tempDisableAutoCloseDoor);
    vehicle.QueueEvent(VehDoorRequestEvent);
  }

  protected func ExitWorkspot(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isInstant: Bool, opt upsideDown: Bool) -> Void {
    let workspotSystem: ref<WorkspotGameSystem>;
    let exitSlotName: CName = n"default";
    let unmountDirResult: StateResultInt = stateContext.GetPermanentIntParameter(n"vehUnmountDir");
    if upsideDown {
      exitSlotName = n"exit_upside_down";
    } else {
      if unmountDirResult.valid && this.IsUnmountDirectionOpposite(stateContext, IntEnum(unmountDirResult.value)) {
        exitSlotName = n"exit_opposite";
      };
    };
    workspotSystem = scriptInterface.GetWorkspotSystem();
    workspotSystem.UnmountFromVehicle(scriptInterface.owner, scriptInterface.executionOwner, isInstant, exitSlotName);
  }

  protected final func PlayerStateChange(scriptInterface: ref<StateGameScriptInterface>, newstate: Int32) -> Void {
    let data: VehEntityPlayerStateData;
    data.entID = scriptInterface.ownerEntityID;
    data.state = newstate;
    let activeVehicleBlackboard: ref<IBlackboard> = this.GetVehicleBlackboard(scriptInterface);
    activeVehicleBlackboard.SetVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, ToVariant(data));
  }

  private final func GetVehicleBlackboard(scriptInterface: ref<StateGameScriptInterface>) -> ref<IBlackboard> {
    let owner: ref<GameObject> = scriptInterface.executionOwner;
    return GameInstance.GetBlackboardSystem(owner.GetGame()).Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
  }

  protected final func SetupVehicleDataPackage(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> wref<VehicleDataPackage_Record> {
    let recordID: TweakDBID = (scriptInterface.owner as VehicleObject).GetRecordID();
    let vehicleRecord: ref<Vehicle_Record> = TweakDBInterface.GetVehicleRecord(recordID);
    let vehicleDataPackage: wref<VehicleDataPackage_Record> = vehicleRecord.VehDataPackage();
    stateContext.SetConditionWeakScriptableParameter(n"VehicleDataPackage", vehicleDataPackage, true);
    return vehicleDataPackage;
  }

  protected final const func GetVehicleDataPackage(const stateContext: ref<StateContext>) -> wref<VehicleDataPackage_Record> {
    return stateContext.GetConditionWeakScriptableParameter(n"VehicleDataPackage") as VehicleDataPackage_Record;
  }

  protected final func GetVehicleInventory(scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected final func SetVehicleCameraParameters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let cameraParamName: CName;
    let param: StateResultCName = this.GetStaticCNameParameter("onEnterCameraParamsName");
    let paramSecondary: StateResultCName = this.GetStaticCNameParameter("onEnterCameraParamsNameSecondary");
    let vehClass: Int32 = this.GetVehClass(stateContext, scriptInterface);
    if vehClass == 1 && paramSecondary.valid {
      cameraParamName = paramSecondary.value;
    };
    if (vehClass == 2 || vehClass == 0) && param.valid || vehClass == 1 && !paramSecondary.valid {
      cameraParamName = param.value;
    };
    stateContext.SetPermanentCNameParameter(n"VehicleCameraParams", cameraParamName, true);
    this.UpdateCameraContext(stateContext, scriptInterface);
  }

  protected final const func GetPuppetVehicleSceneTransition(const stateContext: ref<StateContext>) -> PuppetVehicleState {
    let puppetVehicleStateValue: PuppetVehicleState;
    let puppetVehicleState: StateResultInt = stateContext.GetTemporaryIntParameter(n"scenePuppetVehicleState");
    if puppetVehicleState.valid {
      puppetVehicleStateValue = IntEnum(puppetVehicleState.value);
      return puppetVehicleStateValue;
    };
    puppetVehicleState = stateContext.GetPermanentIntParameter(n"scenePuppetVehicleState");
    if puppetVehicleState.valid {
      puppetVehicleStateValue = IntEnum(puppetVehicleState.value);
      return puppetVehicleStateValue;
    };
    return PuppetVehicleState.IdleMounted;
  }

  protected final const func TryToStopVehicle(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, opt force: Bool) -> Void {
    let vehicle: wref<VehicleObject> = scriptInterface.owner as VehicleObject;
    let vehicleBlackboard: ref<IBlackboard> = vehicle.GetBlackboard();
    let speed: Float = vehicleBlackboard.GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue);
    if force {
      vehicle.ForceBrakesUntilStoppedOrFor(4.00);
    } else {
      if speed <= 25.00 {
        vehicle.ForceBrakesUntilStoppedOrFor(2.00);
      };
    };
  }

  protected final const func IsInScene(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let highLevel: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    let isInTier3: Bool = highLevel == EnumInt(gamePSMHighLevel.SceneTier3);
    let isInTier4: Bool = highLevel == EnumInt(gamePSMHighLevel.SceneTier4);
    let isInTier5: Bool = highLevel == EnumInt(gamePSMHighLevel.SceneTier5);
    return isInTier3 || isInTier4 || isInTier5;
  }

  public final func GetVehicleObject(scriptInterface: ref<StateGameScriptInterface>) -> wref<VehicleObject> {
    return scriptInterface.owner as VehicleObject;
  }

  public final func GetVehiclePS(scriptInterface: ref<StateGameScriptInterface>) -> wref<VehicleComponentPS> {
    return (scriptInterface.owner as VehicleObject).GetVehiclePS();
  }

  public final const func IsInVehicleWorkspot(const scriptInterface: ref<StateGameScriptInterface>, slotName: CName) -> Bool {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    let res: Bool = workspotSystem.IsInVehicleWorkspot(scriptInterface.owner, scriptInterface.executionOwner, slotName);
    return res;
  }

  protected final const func DriverSwitchSeatsCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let seatInteractionAvailable: Bool;
    let vehicle: wref<VehicleObject>;
    let questForceSwitchSeats: StateResultBool = stateContext.GetTemporaryBoolParameter(n"switchSeats");
    let switchExitRequest: StateResultBool = stateContext.GetPermanentBoolParameter(n"validSwitchSeatExitRequest");
    let exitAfterRequest: StateResultBool = stateContext.GetPermanentBoolParameter(n"validExitAfterSwitchRequest");
    if switchExitRequest.value && exitAfterRequest.value {
      return true;
    };
    if questForceSwitchSeats.value {
      vehicle = scriptInterface.owner as VehicleObject;
      seatInteractionAvailable = NotEquals(vehicle.GetVehiclePS().GetDoorInteractionState(EVehicleDoor.seat_front_right), VehicleDoorInteractionState.Disabled);
      if seatInteractionAvailable {
        if VehicleComponent.IsSlotAvailable(scriptInterface.GetGame(), scriptInterface.owner as VehicleObject, n"seat_front_right") && this.GetInStateTime() >= 0.20 {
          return true;
        };
      };
    };
    return false;
  }

  protected final const func PassangerSwitchSeatsCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let exitAfterRequest: StateResultBool;
    let seatInteractionAvailable: Bool;
    let slotName: CName;
    let switchExitRequest: StateResultBool;
    let vehicle: wref<VehicleObject>;
    let questForceSwitchSeats: StateResultBool = stateContext.GetTemporaryBoolParameter(n"switchSeats");
    let switchSeatsDisabled: Bool = this.GetVehicleDataPackage(stateContext).DisableSwitchSeats();
    let debugBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().DebugData);
    if switchSeatsDisabled || debugBB.GetBool(GetAllBlackboardDefs().DebugData.Vehicle_BlockSwitchSeats) {
      return false;
    };
    VehicleComponent.GetMountedSlotName(scriptInterface.GetGame(), scriptInterface.executionOwner, slotName);
    switchExitRequest = stateContext.GetPermanentBoolParameter(n"validSwitchSeatExitRequest");
    exitAfterRequest = stateContext.GetPermanentBoolParameter(n"validExitAfterSwitchRequest");
    if switchExitRequest.value && exitAfterRequest.value {
      return true;
    };
    if exitAfterRequest.value {
      return false;
    };
    if Equals(slotName, n"seat_front_right") {
      vehicle = scriptInterface.owner as VehicleObject;
      seatInteractionAvailable = NotEquals(vehicle.GetVehiclePS().GetDoorInteractionState(EVehicleDoor.seat_front_left), VehicleDoorInteractionState.Disabled);
      if seatInteractionAvailable {
        if VehicleComponent.IsSlotAvailable(scriptInterface.GetGame(), scriptInterface.owner as VehicleObject, n"seat_front_left") && this.GetInStateTime() >= 0.20 {
          return true;
        };
      };
    };
    if questForceSwitchSeats.value {
      if Equals(slotName, n"seat_back_left") {
        vehicle = scriptInterface.owner as VehicleObject;
        seatInteractionAvailable = NotEquals(vehicle.GetVehiclePS().GetDoorInteractionState(EVehicleDoor.seat_back_right), VehicleDoorInteractionState.Disabled);
        if seatInteractionAvailable {
          if VehicleComponent.IsSlotAvailable(scriptInterface.GetGame(), scriptInterface.owner as VehicleObject, n"seat_back_right") && this.GetInStateTime() >= 0.20 {
            return true;
          };
        };
      } else {
        if Equals(slotName, n"seat_back_right") {
          vehicle = scriptInterface.owner as VehicleObject;
          seatInteractionAvailable = NotEquals(vehicle.GetVehiclePS().GetDoorInteractionState(EVehicleDoor.seat_back_left), VehicleDoorInteractionState.Disabled);
          if seatInteractionAvailable {
            if VehicleComponent.IsSlotAvailable(scriptInterface.GetGame(), scriptInterface.owner as VehicleObject, n"seat_back_left") && this.GetInStateTime() >= 0.20 {
              return true;
            };
          };
        };
      };
    };
    return false;
  }

  protected final func PauseStateMachines(stateContext: ref<StateContext>, executionOwner: ref<GameObject>) -> Void {
    let upperBody: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    let equipmentRightHand: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    let equipmentLeftHand: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    let coverAction: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    let stamina: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    let aimAssistContext: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    let crosshair: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    let cameraContext: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    if stateContext.IsStateActive(n"UpperBody", n"forceEmptyHands") {
      upperBody.stateMachineIdentifier.definitionName = n"UpperBody";
      executionOwner.QueueEvent(upperBody);
    };
    equipmentRightHand.stateMachineIdentifier.referenceName = n"RightHand";
    equipmentRightHand.stateMachineIdentifier.definitionName = n"Equipment";
    executionOwner.QueueEvent(equipmentRightHand);
    equipmentLeftHand.stateMachineIdentifier.referenceName = n"LeftHand";
    equipmentLeftHand.stateMachineIdentifier.definitionName = n"Equipment";
    executionOwner.QueueEvent(equipmentLeftHand);
    coverAction.stateMachineIdentifier.definitionName = n"CoverAction";
    executionOwner.QueueEvent(coverAction);
    if DefaultTransition.GetBlackboardIntVariable(executionOwner, GetAllBlackboardDefs().PlayerStateMachine.Stamina) == EnumInt(gamePSMStamina.Rested) {
      stamina.stateMachineIdentifier.definitionName = n"Stamina";
      executionOwner.QueueEvent(stamina);
    };
    aimAssistContext.stateMachineIdentifier.definitionName = n"AimAssistContext";
    executionOwner.QueueEvent(aimAssistContext);
    crosshair.stateMachineIdentifier.definitionName = n"Crosshair";
    executionOwner.QueueEvent(crosshair);
    cameraContext.stateMachineIdentifier.definitionName = n"CameraContext";
    executionOwner.QueueEvent(cameraContext);
  }

  protected final func ResumeStateMachines(executionOwner: ref<GameObject>) -> Void {
    let upperBody: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let equipmentRightHand: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let equipmentLeftHand: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let coverAction: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let stamina: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let aimAssistContext: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let locomotion: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let crosshair: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    let cameraContext: ref<PSMStartStateMachine> = new PSMStartStateMachine();
    upperBody.stateMachineIdentifier.definitionName = n"UpperBody";
    executionOwner.QueueEvent(upperBody);
    equipmentRightHand.stateMachineIdentifier.referenceName = n"RightHand";
    equipmentRightHand.stateMachineIdentifier.definitionName = n"Equipment";
    executionOwner.QueueEvent(equipmentRightHand);
    equipmentLeftHand.stateMachineIdentifier.referenceName = n"LeftHand";
    equipmentLeftHand.stateMachineIdentifier.definitionName = n"Equipment";
    executionOwner.QueueEvent(equipmentLeftHand);
    coverAction.stateMachineIdentifier.definitionName = n"CoverAction";
    executionOwner.QueueEvent(coverAction);
    stamina.stateMachineIdentifier.definitionName = n"Stamina";
    executionOwner.QueueEvent(stamina);
    aimAssistContext.stateMachineIdentifier.definitionName = n"AimAssistContext";
    executionOwner.QueueEvent(aimAssistContext);
    locomotion.stateMachineIdentifier.definitionName = n"Locomotion";
    executionOwner.QueueEvent(locomotion);
    crosshair.stateMachineIdentifier.definitionName = n"Crosshair";
    executionOwner.QueueEvent(crosshair);
    cameraContext.stateMachineIdentifier.definitionName = n"CameraContext";
    executionOwner.QueueEvent(cameraContext);
  }
}

public abstract class VehicleEventsTransition extends VehicleTransition {

  protected let isCameraTogglePressed: Bool;

  @default(VehicleEventsTransition, 0.35f)
  private let cameraToggleHoldToResetTimeSeconds: Float;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let exitActionPressCount: Uint32;
    let animFeature: ref<AnimFeature_Mounting> = new AnimFeature_Mounting();
    animFeature.mountingState = 1;
    scriptInterface.SetAnimationParameterFeature(n"Mounting", animFeature);
    exitActionPressCount = scriptInterface.GetActionPressCount(n"Exit");
    stateContext.SetPermanentIntParameter(n"exitPressCountOnEnter", Cast(exitActionPressCount), true);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.SetupVehicleDataPackage(stateContext, scriptInterface);
    this.SetVehicleCameraParameters(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeatureMounting: ref<AnimFeature_Mounting>;
    let workspotSystem: ref<WorkspotGameSystem>;
    this.isCameraTogglePressed = false;
    let wasSwitchingSeat: StateResultBool = stateContext.GetPermanentBoolParameter(n"wasSwitching");
    if wasSwitchingSeat.value {
      return;
    };
    animFeatureMounting = new AnimFeature_Mounting();
    animFeatureMounting.mountingState = 0;
    scriptInterface.SetAnimationParameterFeature(n"Mounting", animFeatureMounting);
    this.ResetVehParams(stateContext, scriptInterface);
    this.ResetAnimFeature(stateContext, scriptInterface);
    this.ResetForceFlags(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Default));
    workspotSystem = scriptInterface.GetWorkspotSystem();
    workspotSystem.UnmountFromVehicle(scriptInterface.owner, scriptInterface.executionOwner, true);
    this.SetOneHandedFirearmsGameplayRestriction(scriptInterface, false);
    this.DisableCameraBobbing(stateContext, scriptInterface, false);
    this.SetWasStolen(stateContext, false);
    this.SetWasCombatForced(stateContext, false);
    this.SetRequestedTPPCamera(stateContext, false);
    stateContext.SetPermanentBoolParameter(n"teleportExitActive", false, true);
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
    this.SetVehicleCameraParameters(stateContext, scriptInterface);
  }

  protected final func HandleCameraInput(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.IsVehicleCameraChangeBlocked(scriptInterface) && scriptInterface.IsActionJustPressed(n"ToggleVehCamera") {
      this.RequestToggleVehicleCamera(scriptInterface);
    };
    if scriptInterface.IsActionJustTapped(n"VehicleCameraInverse") {
      this.ResetVehicleCamera(scriptInterface);
    };
  }

  protected final func HandleExitRequest(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let adjacentSeat: CName;
    let exitActionPressCount: Uint32;
    let exitPressCountResult: StateResultInt;
    let inputStateTime: Float;
    let isSlotOccupied: Bool;
    let mountingInfo: MountingInfo;
    let onDifferentExitPress: Bool;
    let stateTime: Float;
    let validUnmount: vehicleUnmountPosition;
    let vehicle: wref<VehicleObject>;
    let isTeleportExiting: StateResultBool = stateContext.GetPermanentBoolParameter(n"teleportExitActive");
    let isScheduledExit: StateResultBool = stateContext.GetPermanentBoolParameter(n"validExitAfterSwitchRequest");
    let isSwitchingSeats: StateResultBool = stateContext.GetPermanentBoolParameter(n"validSwitchSeatExitRequest");
    if isTeleportExiting.value || isScheduledExit.value || isSwitchingSeats.value {
      return;
    };
    if this.IsPlayerAllowedToExitVehicle(scriptInterface) {
      stateTime = this.GetInStateTime();
      exitActionPressCount = scriptInterface.GetActionPressCount(n"Exit");
      exitPressCountResult = stateContext.GetPermanentIntParameter(n"exitPressCountOnEnter");
      onDifferentExitPress = !exitPressCountResult.valid || exitPressCountResult.value != Cast(exitActionPressCount);
      if onDifferentExitPress && stateTime >= 0.30 && scriptInterface.GetActionValue(n"Exit") > 0.00 {
        vehicle = scriptInterface.owner as VehicleObject;
        inputStateTime = scriptInterface.GetActionStateTime(n"Exit");
        validUnmount = vehicle.CanUnmount(true, scriptInterface.executionOwner);
        stateContext.SetPermanentIntParameter(n"vehUnmountDir", EnumInt(validUnmount.direction), true);
        if scriptInterface.IsActionJustHeld(n"Exit") {
          if vehicle != (vehicle as CarObject) && vehicle != (vehicle as BikeObject) {
            stateContext.SetPermanentBoolParameter(n"validExitRequest", true, true);
            return;
          };
          if this.IsUnmountDirectionClosest(stateContext, validUnmount.direction) {
            stateContext.SetPermanentBoolParameter(n"validExitRequest", true, true);
            return;
          };
          if vehicle == (vehicle as BikeObject) && this.IsUnmountDirectionOpposite(stateContext, validUnmount.direction) {
            stateContext.SetPermanentBoolParameter(n"validExitRequest", true, true);
            return;
          };
        };
        if scriptInterface.GetActionValue(n"Exit") > 0.00 {
          if inputStateTime >= 0.50 && vehicle == (vehicle as CarObject) {
            if this.IsUnmountDirectionOpposite(stateContext, validUnmount.direction) {
              mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
              this.GetAdjacentSeat(mountingInfo.slotId.id, adjacentSeat);
              isSlotOccupied = VehicleComponent.IsSlotOccupied(scriptInterface.GetGame(), scriptInterface.ownerEntityID, adjacentSeat);
              this.TryToStopVehicle(stateContext, scriptInterface, true);
              if !isSlotOccupied {
                stateContext.SetPermanentBoolParameter(n"validSwitchSeatExitRequest", true, true);
                stateContext.SetPermanentBoolParameter(n"validExitAfterSwitchRequest", true, true);
              } else {
                this.ExitWithTeleport(stateContext, scriptInterface, validUnmount, true);
              };
            };
          };
          if inputStateTime >= 1.00 {
            if Equals(validUnmount.direction, vehicleExitDirection.Front) || Equals(validUnmount.direction, vehicleExitDirection.Back) || Equals(validUnmount.direction, vehicleExitDirection.Top) || Equals(validUnmount.direction, vehicleExitDirection.NoDirection) {
              this.TryToStopVehicle(stateContext, scriptInterface, true);
              this.ExitWithTeleport(stateContext, scriptInterface, validUnmount);
            };
          };
        };
      };
      return;
    };
  }

  protected final func ExitWithTeleport(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, validUnmountDirection: vehicleUnmountPosition, opt moveVehicle: Bool, opt skipUnmount: Bool) -> Void {
    let mountingInfo: MountingInfo;
    let teleportPosition: Vector4;
    let unmountEvent: ref<UnmountingRequest>;
    let vehicleTeleportPosition: Vector4;
    let worldPos: Vector4;
    stateContext.SetPermanentBoolParameter(n"teleportExitActive", true, true);
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    unmountEvent = new UnmountingRequest();
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    unmountEvent.mountData = new MountEventData();
    unmountEvent.mountData.isInstant = true;
    scriptInterface.GetMountingFacility().Unmount(unmountEvent);
    if Equals(validUnmountDirection.direction, vehicleExitDirection.NoDirection) {
      worldPos = scriptInterface.executionOwner.GetWorldPosition();
      worldPos.Z = worldPos.Z + 2.00;
      teleportPosition = worldPos;
    } else {
      teleportPosition = WorldPosition.ToVector4(validUnmountDirection.position);
    };
    if moveVehicle {
      vehicleTeleportPosition = scriptInterface.owner.GetWorldPosition();
      vehicleTeleportPosition.Z = vehicleTeleportPosition.Z + 0.25;
      WorldTransform.GetRight(scriptInterface.owner.GetWorldTransform());
      teleportPosition = teleportPosition + WorldTransform.GetRight(scriptInterface.owner.GetWorldTransform());
      vehicleTeleportPosition = vehicleTeleportPosition + WorldTransform.GetRight(scriptInterface.owner.GetWorldTransform());
      GameInstance.GetTeleportationFacility(scriptInterface.GetGame()).Teleport(scriptInterface.owner, vehicleTeleportPosition, Quaternion.ToEulerAngles(scriptInterface.owner.GetWorldOrientation()));
    };
    GameInstance.GetTeleportationFacility(scriptInterface.GetGame()).Teleport(scriptInterface.executionOwner, teleportPosition, Quaternion.ToEulerAngles(scriptInterface.owner.GetWorldOrientation()));
  }
}

public class IdleDecisions extends VehicleTransition {

  public final const func ToExit(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsExitForced(stateContext) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }
}

public class IdleEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let vehClass: Int32;
    let vehType: Int32;
    this.OnEnter(stateContext, scriptInterface);
    vehType = this.GetVehType(stateContext, scriptInterface);
    this.SetVehicleType(stateContext, vehType);
    vehClass = this.GetVehClass(stateContext, scriptInterface);
    this.SetVehicleClass(stateContext, vehClass);
    VehicleComponent.SetAnimsetOverrideForPassenger(scriptInterface.executionOwner, 1.00);
    if !DefaultTransition.IsInRpgContext(scriptInterface) {
      stateContext.SetPermanentBoolParameter(n"VisionToggled", false, true);
      this.ForceDisableVisionMode(stateContext);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Transition));
    this.PlayerStateChange(scriptInterface, 4);
    this.DisableCameraBobbing(stateContext, scriptInterface, true);
    stateContext.SetPermanentBoolParameter(n"validExitRequest", false, true);
    stateContext.SetPermanentBoolParameter(n"validSwitchSeatExitRequest", false, true);
    stateContext.SetPermanentBoolParameter(n"teleportExitActive", false, true);
  }
}

public class EnteringDecisions extends VehicleTransition {

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let currentTime: Float;
    let targetTime: Float;
    let wasStolen: StateResultBool = stateContext.GetPermanentBoolParameter(n"wasStolen");
    if wasStolen.value {
      currentTime = this.GetInStateTime();
      targetTime = 3.70;
      return currentTime > targetTime || this.stateMachineInitData.instant && stateContext.IsStateActive(n"Locomotion", n"workspot");
    };
    currentTime = this.GetInStateTime();
    targetTime = this.GetVehicleDataPackage(stateContext).Entering();
    return currentTime > targetTime || this.stateMachineInitData.instant && stateContext.IsStateActive(n"Locomotion", n"workspot");
  }

  public final const func ToExiting(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsExitForced(stateContext) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }

  public final const func ToSwitchSeats(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsDriverInVehicle(scriptInterface) {
      return this.DriverSwitchSeatsCondition(stateContext, scriptInterface);
    };
    if this.IsPassengerInVehicle(scriptInterface) {
      return this.PassangerSwitchSeatsCondition(stateContext, scriptInterface);
    };
    return false;
  }
}

public class EnteringEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animVariables: array<CName>;
    let entrySlotName: CName;
    let exitEvent: ref<AIEvent>;
    let mountingInfo: MountingInfo;
    let slideDuration: Float;
    let syncObjects: array<EntityID>;
    let workspotSystem: ref<WorkspotGameSystem>;
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"VisionToggled", false, true);
    this.ForceDisableVisionMode(stateContext);
    this.ForceDisableRadialWheel(scriptInterface);
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll);
    this.ForceIdleVehicle(stateContext);
    slideDuration = this.GetVehicleDataPackage(stateContext).SlideDuration();
    if this.stateMachineInitData.instant {
      slideDuration = 0.00;
    };
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    workspotSystem = scriptInterface.GetWorkspotSystem();
    animVariables = VehicleComponent.SetAnimsetOverrideForPassenger(scriptInterface.executionOwner, 1.00);
    if EntityID.IsDefined(this.stateMachineInitData.entityID) {
      ArrayPush(syncObjects, this.stateMachineInitData.entityID);
      workspotSystem.StopNpcInWorkspot(scriptInterface.executionOwner);
      if this.stateMachineInitData.alive {
        entrySlotName = n"stealing";
      } else {
        entrySlotName = n"deadstealing";
      };
      workspotSystem.MountToVehicle(scriptInterface.owner, scriptInterface.executionOwner, slideDuration, slideDuration, n"OccupantSlots", mountingInfo.slotId.id, syncObjects, entrySlotName, animVariables);
      this.SetWasStolen(stateContext, true);
    } else {
      workspotSystem.StopNpcInWorkspot(scriptInterface.executionOwner);
      workspotSystem.MountToVehicle(scriptInterface.owner, scriptInterface.executionOwner, slideDuration, slideDuration, n"OccupantSlots", mountingInfo.slotId.id, n"default", animVariables);
    };
    if this.stateMachineInitData.occupiedByNeutral {
      exitEvent = new AIEvent();
      exitEvent.name = n"ExitVehicleInPanic";
      VehicleComponent.QueueEventToAllNonFriendlyNonDeadPassengers(scriptInterface.GetGame(), scriptInterface.ownerEntityID, exitEvent, scriptInterface.executionOwner, true);
    };
    if NotEquals(VehicleComponent.GetDriverSlotName(), mountingInfo.slotId.id) {
      VehicleComponent.QueueHijackExitEventToDeadDriver(scriptInterface.owner.GetGame(), scriptInterface.owner as VehicleObject);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Transition));
    this.PlayerStateChange(scriptInterface, 4);
  }
}

public class PassengerDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsPassengerInVehicle(scriptInterface) {
      return true;
    };
    return false;
  }

  public final const func ToCombat(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if Equals(this.GetPuppetVehicleSceneTransition(stateContext), PuppetVehicleState.CombatSeated) {
      return true;
    };
    return false;
  }

  public final const func ToSwitchSeats(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.PassangerSwitchSeatsCondition(stateContext, scriptInterface);
  }
}

public class PassengerEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioEvt: ref<VehicleAudioEvent>;
    let fppCamParamsSide: Bool;
    let mountingInfo: MountingInfo;
    this.OnEnter(stateContext, scriptInterface);
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    this.SetSide(stateContext, scriptInterface);
    this.ForceIdleVehicle(stateContext);
    this.SetIsInVehicle(stateContext, true);
    this.SetIsCar(stateContext, true);
    if Equals(mountingInfo.slotId.id, n"seat_back_left") {
      fppCamParamsSide = true;
    };
    this.SetVehFppCameraParams(stateContext, scriptInterface, true, fppCamParamsSide);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.SendIsCar(stateContext, scriptInterface);
    audioEvt = new VehicleAudioEvent();
    audioEvt.action = vehicleAudioEventAction.OnPlayerPassenger;
    scriptInterface.owner.QueueEvent(audioEvt);
    if stateContext.GetBoolParameter(n"requestedTPPCamera", true) {
      this.RequestVehicleCameraPerspective(scriptInterface, vehicleCameraPerspective.TPPClose);
      this.SetRequestedTPPCamera(stateContext, false);
    };
    this.RemoveMountingRequest(stateContext);
    this.SetOneHandedFirearmsGameplayRestriction(scriptInterface, true);
    this.PlayerStateChange(scriptInterface, 3);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Passenger));
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.isCameraTogglePressed = false;
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
    if Equals(this.GetPuppetVehicleSceneTransition(stateContext), PuppetVehicleState.CombatSeated) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
      stateContext.SetTemporaryBoolParameter(n"vehicleWindowedCombat", false, true);
    };
  }

  public final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetSide(stateContext, scriptInterface);
    this.HandleExitRequest(stateContext, scriptInterface);
  }
}

public class GunnerDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let lowLevelMountingInfo: MountingInfo = scriptInterface.GetMountingFacility().GetMountingInfoSingleWithObjects(scriptInterface.executionOwner);
    let currentSlot: CName = lowLevelMountingInfo.slotId.id;
    if Equals(currentSlot, n"gunner_back_left") || Equals(currentSlot, n"gunner_back_right") {
      return true;
    };
    return false;
  }

  public final const func ToExiting(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsExitForced(stateContext) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }
}

public class GunnerEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioEvt: ref<VehicleAudioEvent>;
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetPermanentIntParameter(n"vehSlot", 3, true);
    this.ForceIdleVehicle(stateContext);
    this.SetIsInVehicle(stateContext, true);
    this.SetIsCar(stateContext, true);
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
    this.SendIsCar(stateContext, scriptInterface);
    audioEvt = new VehicleAudioEvent();
    audioEvt.action = vehicleAudioEventAction.OnPlayerPassenger;
    scriptInterface.owner.QueueEvent(audioEvt);
    this.RemoveMountingRequest(stateContext);
    this.PlayerStateChange(scriptInterface, 3);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Combat));
    this.SetIsInVehicleCombat(stateContext, true);
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon);
    this.SendAnimFeature(stateContext, scriptInterface);
    if this.GetVehClass(stateContext, scriptInterface) == 1 {
      this.SetOneHandedFirearmsGameplayRestriction(scriptInterface, false);
    };
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
    if Equals(this.GetPuppetVehicleSceneTransition(stateContext), PuppetVehicleState.CombatSeated) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
      stateContext.SetTemporaryBoolParameter(n"vehicleWindowedCombat", false, true);
    };
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
  }
}

public class DriveDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsDriverInVehicle(scriptInterface) {
      return true;
    };
    return false;
  }

  public final const func ToDriverCombat(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsPlayerAllowedToEnterCombat(scriptInterface) && VehicleTransition.CanEnterDriverCombat() {
      if UpperBodyTransition.HasAnyWeaponEquipped(scriptInterface) {
        return true;
      };
      if Equals(this.GetPuppetVehicleSceneTransition(stateContext), PuppetVehicleState.CombatSeated) {
        return true;
      };
    };
    return false;
  }

  public final const func ToSwitchSeats(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.DriverSwitchSeatsCondition(stateContext, scriptInterface);
  }
}

public class DriveEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioEvt: ref<VehicleAudioEvent>;
    this.OnEnter(stateContext, scriptInterface);
    this.SetSide(stateContext, scriptInterface);
    this.SetIsInVehicle(stateContext, true);
    this.SetIsVehicleDriver(stateContext, true);
    this.ForceIdleVehicle(stateContext);
    this.PlayerStateChange(scriptInterface, 1);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Driving));
    this.SendAnimFeature(stateContext, scriptInterface);
    this.SetVehFppCameraParams(stateContext, scriptInterface, false);
    audioEvt = new VehicleAudioEvent();
    audioEvt.action = vehicleAudioEventAction.OnPlayerDriving;
    scriptInterface.owner.QueueEvent(audioEvt);
    if stateContext.GetBoolParameter(n"requestedTPPCamera", true) {
      this.RequestVehicleCameraPerspective(scriptInterface, vehicleCameraPerspective.TPPClose);
      this.SetRequestedTPPCamera(stateContext, false);
    };
    if !VehicleTransition.CanEnterDriverCombat() {
      stateContext.SetPermanentBoolParameter(n"ForceEmptyHands", true, true);
    };
    this.RemoveMountingRequest(stateContext);
    this.PauseStateMachines(stateContext, scriptInterface.executionOwner);
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let transition: PuppetVehicleState = this.GetPuppetVehicleSceneTransition(stateContext);
    if Equals(transition, PuppetVehicleState.CombatSeated) || Equals(transition, PuppetVehicleState.CombatWindowed) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
    };
    this.SetIsVehicleDriver(stateContext, false);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
    this.isCameraTogglePressed = false;
    stateContext.SetPermanentBoolParameter(n"ForceEmptyHands", false, true);
    this.ResumeStateMachines(scriptInterface.executionOwner);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.ResumeStateMachines(scriptInterface.executionOwner);
  }

  public final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsInVehicle(stateContext, true);
    this.SetSide(stateContext, scriptInterface);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.HandleCameraInput(scriptInterface);
    this.HandleExitRequest(stateContext, scriptInterface);
  }
}

public class SwitchSeatsDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  public final const func ToDrive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let mountData: ref<MountEventData>;
    let mountOptions: ref<MountEventOptions>;
    let mountingRequest: ref<MountingRequest>;
    let lowLevelMountingInfo: MountingInfo = scriptInterface.GetMountingFacility().GetMountingInfoSingleWithIds(scriptInterface.executionOwnerEntityID);
    let currentSlot: CName = lowLevelMountingInfo.slotId.id;
    if this.GetInStateTime() >= this.GetVehicleDataPackage(stateContext).SwitchSeats() {
      mountingRequest = new MountingRequest();
      mountData = new MountEventData();
      mountOptions = new MountEventOptions();
      lowLevelMountingInfo.parentId = scriptInterface.ownerEntityID;
      lowLevelMountingInfo.childId = scriptInterface.executionOwnerEntityID;
      mountData.isInstant = true;
      mountOptions.silentUnmount = true;
      if Equals(currentSlot, n"seat_front_right") {
        lowLevelMountingInfo.slotId.id = n"seat_front_left";
        mountingRequest.lowLevelMountingInfo = lowLevelMountingInfo;
        mountingRequest.mountData = mountData;
        mountingRequest.mountData.mountEventOptions = mountOptions;
        scriptInterface.GetMountingFacility().Mount(mountingRequest);
        return true;
      };
    };
    return false;
  }

  public final const func ToPassenger(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let mountData: ref<MountEventData>;
    let mountOptions: ref<MountEventOptions>;
    let mountingRequest: ref<MountingRequest>;
    let lowLevelMountingInfo: MountingInfo = scriptInterface.GetMountingFacility().GetMountingInfoSingleWithIds(scriptInterface.executionOwnerEntityID);
    let currentSlot: CName = lowLevelMountingInfo.slotId.id;
    if this.GetInStateTime() >= this.GetVehicleDataPackage(stateContext).SwitchSeats() {
      mountingRequest = new MountingRequest();
      mountData = new MountEventData();
      mountOptions = new MountEventOptions();
      lowLevelMountingInfo.parentId = scriptInterface.ownerEntityID;
      lowLevelMountingInfo.childId = scriptInterface.executionOwnerEntityID;
      mountData.isInstant = true;
      mountOptions.silentUnmount = true;
      if Equals(currentSlot, n"seat_back_left") {
        lowLevelMountingInfo.slotId.id = n"seat_back_right";
        mountingRequest.lowLevelMountingInfo = lowLevelMountingInfo;
        mountingRequest.mountData = mountData;
        mountingRequest.mountData.mountEventOptions = mountOptions;
        scriptInterface.GetMountingFacility().Mount(mountingRequest);
        return true;
      };
      if Equals(currentSlot, n"seat_back_right") {
        lowLevelMountingInfo.slotId.id = n"seat_back_left";
        mountingRequest.lowLevelMountingInfo = lowLevelMountingInfo;
        mountingRequest.mountData = mountData;
        mountingRequest.mountData.mountEventOptions = mountOptions;
        scriptInterface.GetMountingFacility().Mount(mountingRequest);
        return true;
      };
      if Equals(currentSlot, n"seat_front_left") {
        lowLevelMountingInfo.slotId.id = n"seat_front_right";
        mountingRequest.lowLevelMountingInfo = lowLevelMountingInfo;
        mountingRequest.mountData = mountData;
        mountingRequest.mountData.mountEventOptions = mountOptions;
        scriptInterface.GetMountingFacility().Mount(mountingRequest);
        return true;
      };
    };
    return false;
  }
}

public class SwitchSeatsEvents extends VehicleEventsTransition {

  public let workspotSystem: ref<WorkspotGameSystem>;

  public let enabledSceneMode: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animVariablesActivate: array<CName>;
    let animVariablesDeactivate: array<CName>;
    let curSlotName: CName;
    let evtNextSeat: ref<AnimWrapperWeightSetter>;
    let evtPrevSeat: ref<AnimWrapperWeightSetter>;
    let mountingInfo: MountingInfo;
    let nextSlotName: CName;
    let vehicle: wref<VehicleObject>;
    stateContext.SetPermanentBoolParameter(n"validSwitchSeatExitRequest", false, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Transition));
    vehicle = this.GetVehicleObject(scriptInterface);
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    curSlotName = mountingInfo.slotId.id;
    this.GetAdjacentSeat(curSlotName, nextSlotName);
    this.SetRequestedTPPCamera(stateContext, false);
    evtNextSeat = new AnimWrapperWeightSetter();
    evtNextSeat.key = vehicle.GetAnimsetOverrideForPassenger(nextSlotName);
    evtNextSeat.value = 1.00;
    ArrayPush(animVariablesActivate, evtNextSeat.key);
    scriptInterface.executionOwner.QueueEvent(evtNextSeat);
    evtPrevSeat = new AnimWrapperWeightSetter();
    evtPrevSeat.key = vehicle.GetAnimsetOverrideForPassenger(curSlotName);
    evtPrevSeat.value = 0.00;
    ArrayPush(animVariablesDeactivate, evtPrevSeat.key);
    scriptInterface.executionOwner.QueueEvent(evtPrevSeat);
    this.workspotSystem = scriptInterface.GetWorkspotSystem();
    this.workspotSystem.SwitchSeatVehicle(scriptInterface.owner, scriptInterface.executionOwner, n"OccupantSlots", nextSlotName, n"switch_seat", animVariablesActivate, animVariablesDeactivate);
    this.SetVehicleCameraSceneMode(scriptInterface, true);
    this.enabledSceneMode = true;
    this.OnEnter(stateContext, scriptInterface);
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.enabledSceneMode {
      this.SetVehicleCameraSceneMode(scriptInterface, false);
      this.enabledSceneMode = false;
    };
  }

  public final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class EnteringCombatDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let audioEvt: ref<VehicleAudioEvent>;
    let hasTurret: Bool;
    let questForceEnableCombat: StateResultBool;
    let scenePuppetVehicleTransition: PuppetVehicleState;
    if !this.IsPlayerAllowedToEnterCombat(scriptInterface) {
      return false;
    };
    questForceEnableCombat = stateContext.GetTemporaryBoolParameter(n"startVehicleCombat");
    hasTurret = VehicleTransition.CheckVehicleDesiredTag(scriptInterface, n"Turret");
    scenePuppetVehicleTransition = this.GetPuppetVehicleSceneTransition(stateContext);
    if hasTurret {
      return false;
    };
    if questForceEnableCombat.value && !hasTurret {
      this.SetWasCombatForced(stateContext, true);
      return true;
    };
    if Equals(scenePuppetVehicleTransition, PuppetVehicleState.CombatWindowed) {
      this.SetWasCombatForced(stateContext, true);
      return true;
    };
    audioEvt = new VehicleAudioEvent();
    audioEvt.action = vehicleAudioEventAction.OnPlayerExitCombat;
    scriptInterface.owner.QueueEvent(audioEvt);
    if UpperBodyTransition.HasAnyWeaponEquipped(scriptInterface) {
      return true;
    };
    return false;
  }

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetVehicleDataPackage(stateContext).ToCombat();
  }
}

public class EnteringCombatEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let drawItemRequest: ref<DrawItemRequest>;
    let equipmentSystem: ref<EquipmentSystem>;
    let weaponID: ItemID;
    this.OnEnter(stateContext, scriptInterface);
    if stateContext.GetBoolParameter(n"wasCombatForced", true) && !UpperBodyTransition.HasRangedWeaponEquipped(scriptInterface) {
      weaponID = EquipmentSystem.GetData(scriptInterface.executionOwner).GetLastUsedOrFirstAvailableRangedWeapon();
      if ItemID.IsValid(weaponID) {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon);
      } else {
        equipmentSystem = scriptInterface.GetScriptableSystem(n"EquipmentSystem") as EquipmentSystem;
        drawItemRequest = new DrawItemRequest();
        drawItemRequest.owner = scriptInterface.executionOwner;
        drawItemRequest.itemID = ItemID.CreateQuery(t"Items.Preset_V_Unity_Cutscene");
        equipmentSystem.QueueRequest(drawItemRequest);
      };
    };
    this.SetIsEnteringCombat(stateContext, true);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.PlayerStateChange(scriptInterface, 2);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Transition));
    this.SetVehicleCameraSceneMode(scriptInterface, true);
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsEnteringCombat(stateContext, false);
    this.SendAnimFeature(stateContext, scriptInterface);
    if !stateContext.GetBoolParameter(n"wasCombatForced", true) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
    };
    stateContext.SetTemporaryBoolParameter(n"vehicleWindowedCombat", true, true);
    this.SetWasCombatForced(stateContext, false);
  }
}

public class ExitingCombatDecisions extends VehicleTransition {

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetVehicleDataPackage(stateContext).FromCombat();
  }
}

public class ExitingCombatEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioEvt: ref<VehicleAudioEvent>;
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Transition));
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll);
    this.SetIsExitingCombat(stateContext, true);
    this.SendAnimFeature(stateContext, scriptInterface);
    audioEvt = new VehicleAudioEvent();
    audioEvt.action = vehicleAudioEventAction.OnPlayerExitCombat;
    scriptInterface.owner.QueueEvent(audioEvt);
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetVehicleCameraSceneMode(scriptInterface, false);
    this.SetIsExitingCombat(stateContext, false);
    this.SendAnimFeature(stateContext, scriptInterface);
  }
}

public class SceneExitingCombatDecisions extends VehicleTransition {

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= 0.50 || !scriptInterface.IsSceneAnimationActive() {
      return true;
    };
    return false;
  }
}

public class SceneExitingCombatEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo;
    let slotName: CName;
    this.OnEnter(stateContext, scriptInterface);
    this.SetVehicleCameraSceneMode(scriptInterface, true);
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    slotName = mountingInfo.slotId.id;
    this.SetIsInVehicleCombat(stateContext, true);
    this.SetIsInVehicleWindowCombat(stateContext, true);
    this.SetIsWorldRenderPlane(stateContext, true);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.ToggleWindowForOccupiedSeat(scriptInterface, slotName, true);
    this.SetFirearmsGameplayRestriction(scriptInterface, true);
    this.SetVehFppCameraParams(stateContext, scriptInterface, true, false, true);
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo;
    let slotName: CName;
    this.SetIsInVehicleCombat(stateContext, false);
    this.SetIsInVehicleWindowCombat(stateContext, false);
    this.SetIsWorldRenderPlane(stateContext, true);
    this.SetVehicleCameraSceneMode(scriptInterface, false);
    this.SetIsExitingCombat(stateContext, false);
    this.SendAnimFeature(stateContext, scriptInterface);
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    slotName = mountingInfo.slotId.id;
    this.ToggleWindowForOccupiedSeat(scriptInterface, slotName, false);
    this.SetFirearmsGameplayRestriction(scriptInterface, false);
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Transition));
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll);
  }
}

public class CombatDecisions extends VehicleTransition {

  public final const func ToExitingCombat(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let questForceDisableCombat: StateResultBool = stateContext.GetTemporaryBoolParameter(n"stopVehicleCombat");
    if questForceDisableCombat.value {
      return true;
    };
    if !this.IsPlayerAllowedToExitCombat(scriptInterface) {
      return false;
    };
    if this.IsInEmptyHandsState(stateContext) && this.GetInStateTime() >= 0.50 {
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"Exit") {
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"ToggleVehCamera") {
      this.SetRequestedTPPCamera(stateContext, true);
      return true;
    };
    if !this.IsPlayerAllowedToEnterCombat(scriptInterface) {
      return true;
    };
    return false;
  }

  public final const func ToSceneExitingCombat(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsPlayerAllowedToExitCombat(scriptInterface) {
      return false;
    };
    if !this.IsInScene(stateContext, scriptInterface) {
      return false;
    };
    if !scriptInterface.IsSceneAnimationActive() {
      return false;
    };
    return true;
  }
}

public class CombatEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let fppCamParamsSide: Bool;
    let mountingInfo: MountingInfo;
    let slotName: CName;
    this.OnEnter(stateContext, scriptInterface);
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    slotName = mountingInfo.slotId.id;
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Combat));
    this.SetIsWorldRenderPlane(stateContext, false);
    this.SetIsInVehicleCombat(stateContext, true);
    this.SetIsInVehicleWindowCombat(stateContext, stateContext.GetBoolParameter(n"vehicleWindowedCombat", false));
    this.SendAnimFeature(stateContext, scriptInterface);
    this.ToggleWindowForOccupiedSeat(scriptInterface, slotName, true);
    this.SetFirearmsGameplayRestriction(scriptInterface, true);
    if Equals(mountingInfo.slotId.id, n"seat_back_left") {
      fppCamParamsSide = true;
    };
    this.SetVehFppCameraParams(stateContext, scriptInterface, true, fppCamParamsSide, true);
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    let slotName: CName = mountingInfo.slotId.id;
    this.SetIsInVehicleCombat(stateContext, false);
    this.SetIsInVehicleWindowCombat(stateContext, false);
    this.SetIsWorldRenderPlane(stateContext, true);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.ToggleWindowForOccupiedSeat(scriptInterface, slotName, false);
    this.SetFirearmsGameplayRestriction(scriptInterface, false);
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
  }
}

public class DriverCombatDecisions extends VehicleTransition {

  public final const func ToDrive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.IsStateActive(n"UpperBody", n"emptyHands") && this.GetInStateTime() >= 0.50 {
      return true;
    };
    if !this.IsPlayerAllowedToEnterCombat(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class DriverCombatEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo;
    let slotName: CName;
    this.OnEnter(stateContext, scriptInterface);
    mountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    slotName = mountingInfo.slotId.id;
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.DriverCombat));
    this.SetIsInVehicleDriverCombat(stateContext, true);
    this.SetVehFppCameraParams(stateContext, scriptInterface, false, true);
    this.SetIsWorldRenderPlane(stateContext, true);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.SetVehicleCameraSceneMode(scriptInterface, true);
    this.ToggleWindowForOccupiedSeat(scriptInterface, slotName, true);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.IsActionJustPressed(n"Exit") {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll);
    };
    if scriptInterface.IsActionJustPressed(n"ToggleVehCamera") {
      this.SetRequestedTPPCamera(stateContext, true);
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll);
    };
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    let slotName: CName = mountingInfo.slotId.id;
    this.SetVehicleCameraSceneMode(scriptInterface, false);
    this.ToggleWindowForOccupiedSeat(scriptInterface, slotName, false);
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll);
    this.SetIsInVehicleDriverCombat(stateContext, false);
    this.ResetVehFppCameraParams(stateContext, scriptInterface);
    this.SetIsWorldRenderPlane(stateContext, true);
    this.SendAnimFeature(stateContext, scriptInterface);
  }
}

public class ExitingDecisions extends VehicleTransition {

  public const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let exitRequest: StateResultBool = stateContext.GetPermanentBoolParameter(n"validExitRequest");
    let switchExitRequest: StateResultBool = stateContext.GetPermanentBoolParameter(n"validSwitchSeatExitRequest");
    let exitAfterRequest: StateResultBool = stateContext.GetPermanentBoolParameter(n"validExitAfterSwitchRequest");
    if exitRequest.value {
      return true;
    };
    if !switchExitRequest.value && exitAfterRequest.value && this.GetInStateTime() >= 0.05 {
      return true;
    };
    if this.IsExitForced(stateContext) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let unmountData: ref<MountEventData>;
    if this.IsExitForced(stateContext) {
      unmountData = this.GetUnmountingEvent(stateContext);
      return !this.IsInVehicleWorkspot(scriptInterface, unmountData.slotName);
    };
    return !scriptInterface.GetWorkspotSystem().IsActorInWorkspot(scriptInterface.executionOwner);
  }
}

public class ExitingEventsBase extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"validExitRequest", false, true);
    stateContext.SetPermanentBoolParameter(n"validExitAfterSwitchRequest", false, true);
    stateContext.SetConditionBoolParameter(n"VisionToggled", false, true);
    this.ForceDisableVisionMode(stateContext);
    this.TryToStopVehicle(stateContext, scriptInterface);
    this.PlayVehicleExitDoorAnimation(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Transition));
    this.PlayerStateChange(scriptInterface, 4);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetOneHandedFirearmsGameplayRestriction(scriptInterface, false);
    this.SendAnimFeature(stateContext, scriptInterface);
    if this.IsPlayerInCombat(scriptInterface) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedWeapon);
    };
  }

  protected final func StartExiting(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioEvt: ref<VehicleAudioEvent>;
    this.StartLeavingVehicle(stateContext, scriptInterface);
    audioEvt = new VehicleAudioEvent();
    audioEvt.action = vehicleAudioEventAction.OnPlayerExitVehicle;
    scriptInterface.owner.QueueEvent(audioEvt);
    stateContext.SetPermanentBoolParameter(n"startedExiting", true, true);
  }
}

public class ExitingEvents extends ExitingEventsBase {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let exitDelay: Float;
    this.OnEnter(stateContext, scriptInterface);
    exitDelay = this.GetVehicleDataPackage(stateContext).ExitDelay();
    if exitDelay == 0.00 {
      this.StartExiting(stateContext, scriptInterface);
    };
  }

  public final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let oldExitDirection: vehicleExitDirection;
    let unmountDirResult: StateResultInt;
    let validUnmount: vehicleUnmountPosition;
    let vehicle: wref<VehicleObject>;
    let exitDelay: Float = this.GetVehicleDataPackage(stateContext).ExitDelay();
    let startedExiting: StateResultBool = stateContext.GetPermanentBoolParameter(n"startedExiting");
    let isTeleportExiting: StateResultBool = stateContext.GetPermanentBoolParameter(n"teleportExitActive");
    if exitDelay > 0.00 {
      if this.GetInStateTime() >= exitDelay && !startedExiting.value {
        this.StartExiting(stateContext, scriptInterface);
      };
    };
    if startedExiting.value && !isTeleportExiting.value && this.GetInStateTime() >= 1.00 {
      vehicle = scriptInterface.owner as VehicleObject;
      unmountDirResult = stateContext.GetPermanentIntParameter(n"vehUnmountDir");
      if unmountDirResult.valid {
        oldExitDirection = IntEnum(unmountDirResult.value);
        validUnmount = vehicle.CanUnmount(true, scriptInterface.executionOwner, oldExitDirection);
        if NotEquals(validUnmount.direction, oldExitDirection) {
          validUnmount = vehicle.CanUnmount(true, scriptInterface.executionOwner, vehicleExitDirection.Back);
          validUnmount = vehicle.CanUnmount(true, scriptInterface.executionOwner, vehicleExitDirection.Back);
          if Equals(validUnmount.direction, vehicleExitDirection.NoDirection) {
            validUnmount = vehicle.CanUnmount(true, scriptInterface.executionOwner);
          };
          if NotEquals(validUnmount.direction, vehicleExitDirection.NoDirection) {
            scriptInterface.GetWorkspotSystem().StopNpcInWorkspot(scriptInterface.executionOwner);
            this.ExitWithTeleport(stateContext, scriptInterface, validUnmount, false, true);
          };
        };
      };
    };
  }
}

public class ImmediateExitWithForceEvents extends ExitingEventsBase {

  public let exitForce: StateResultVector;

  public let bikeForce: StateResultVector;

  public let knockOverBike: ref<KnockOverBikeEvent>;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.knockOverBike = new KnockOverBikeEvent();
    this.knockOverBike.forceKnockdown = true;
    this.Unmount(scriptInterface, stateContext);
    scriptInterface.owner.QueueEvent(this.knockOverBike);
    this.exitForce = stateContext.GetTemporaryVectorParameter(n"ExitForce");
    this.bikeForce = stateContext.GetTemporaryVectorParameter(n"BikeForce");
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.ApplyCounterForce(scriptInterface, stateContext);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.ApplyCounterForce(scriptInterface, stateContext);
  }

  protected func ExitWorkspot(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isInstant: Bool, opt isUpsidedown: Bool) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    workspotSystem.StopNpcInWorkspot(scriptInterface.executionOwner);
  }

  protected final func Unmount(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let mountingInfo: MountingInfo;
    let unmountEvent: ref<UnmountingRequest> = new UnmountingRequest();
    mountingInfo.childId = scriptInterface.executionOwnerEntityID;
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    unmountEvent.mountData = new MountEventData();
    unmountEvent.mountData.isInstant = true;
    scriptInterface.GetMountingFacility().Unmount(unmountEvent);
  }

  protected final func ApplyCounterForce(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let bikeImpulseEvent: ref<PhysicalImpulseEvent>;
    let impulseEvent: ref<PSMImpulse>;
    let tempVec4: Vector4;
    let vehicle: wref<VehicleObject>;
    if this.exitForce.valid {
      impulseEvent = new PSMImpulse();
      impulseEvent.id = n"impulse";
      impulseEvent.impulse = this.exitForce.value;
      scriptInterface.executionOwner.QueueEvent(impulseEvent);
    };
    if this.bikeForce.valid {
      vehicle = scriptInterface.owner as VehicleObject;
      bikeImpulseEvent = new PhysicalImpulseEvent();
      tempVec4 = vehicle.GetWorldPosition();
      bikeImpulseEvent.worldPosition.X = tempVec4.X;
      bikeImpulseEvent.worldPosition.Y = tempVec4.Y;
      bikeImpulseEvent.worldPosition.Z = tempVec4.Z;
      tempVec4 = this.bikeForce.value;
      bikeImpulseEvent.worldImpulse.X = tempVec4.X;
      bikeImpulseEvent.worldImpulse.Y = tempVec4.Y;
      bikeImpulseEvent.worldImpulse.Z = tempVec4.Z;
      vehicle.QueueEvent(bikeImpulseEvent);
    };
  }
}

public class CollisionExitingDecisions extends ExitingDecisions {

  public const func EnterCondition(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let collForceSqr: Float;
    let collisionForce: Vector4;
    let collisionUp: Vector4;
    let impulse: Vector4;
    let knockOffForceSqr: Float;
    let recordID: TweakDBID;
    let vehicle: ref<VehicleObject>;
    let vehicleDataPackage: wref<VehicleDataPackage_Record>;
    let vehicleRecord: ref<Vehicle_Record>;
    let vehicleUp: Vector4;
    if stateContext.GetIntParameter(n"vehClass", true) != 1 {
      return false;
    };
    vehicle = scriptInterface.owner as VehicleObject;
    if IsDefined(vehicle) {
      collisionForce = vehicle.GetCollisionForce();
      collForceSqr = Vector4.LengthSquared(collisionForce);
      if collForceSqr > 0.10 {
        recordID = (scriptInterface.owner as VehicleObject).GetRecordID();
        vehicleRecord = TweakDBInterface.GetVehicleRecord(recordID);
        vehicleDataPackage = vehicleRecord.VehDataPackage();
        knockOffForceSqr = vehicleDataPackage.KnockOffForce();
        knockOffForceSqr *= knockOffForceSqr;
        if collForceSqr > knockOffForceSqr {
          vehicleUp = vehicle.GetWorldUp();
          collisionUp = vehicleUp * Vector4.Dot(collisionForce, vehicleUp);
          collisionForce -= collisionUp;
          if Vector4.LengthSquared(collisionForce) > knockOffForceSqr {
            impulse = -collisionForce;
            impulse += 4.00 * vehicle.GetWorldUp();
            stateContext.SetTemporaryVectorParameter(n"ExitForce", impulse, true);
            this.SetBikeForce(stateContext, vehicle, collisionForce);
            return true;
          };
        };
      };
    };
    return false;
  }

  public final const func SetBikeForce(stateContext: ref<StateContext>, vehicle: ref<VehicleObject>, collisionForce: Vector4) -> Void {
    let bikeImpulse: Vector4 = collisionForce;
    bikeImpulse = Vector4.Normalize(bikeImpulse);
    let bikeMass: Float = vehicle.GetTotalMass();
    bikeImpulse *= bikeMass * 3.80;
    stateContext.SetTemporaryVectorParameter(n"BikeForce", bikeImpulse, true);
  }
}

public class CollisionExitingEvents extends ImmediateExitWithForceEvents {

  public let m_animFeatureStatusEffect: ref<AnimFeature_StatusEffect>;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let impulse: StateResultVector;
    let statusEffectRecord: wref<StatusEffect_Record>;
    let collisionDirection: Vector4 = new Vector4(0.00, 0.00, 0.00, 0.00);
    let stackcount: Uint32 = 1u;
    this.OnEnter(stateContext, scriptInterface);
    impulse = stateContext.GetTemporaryVectorParameter(n"ExitForce");
    if impulse.valid {
      collisionDirection = -impulse.value;
    };
    statusEffectRecord = TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.BikeKnockdown");
    GameInstance.GetStatusEffectSystem(scriptInterface.GetGame()).ApplyStatusEffect(scriptInterface.executionOwnerEntityID, statusEffectRecord.GetID(), GameObject.GetTDBID(scriptInterface.owner), scriptInterface.ownerEntityID, stackcount, collisionDirection);
    this.m_animFeatureStatusEffect = new AnimFeature_StatusEffect();
    StatusEffectHelper.PopulateStatusEffectAnimData(scriptInterface.executionOwner, statusEffectRecord, EKnockdownStates.Start, collisionDirection, this.m_animFeatureStatusEffect);
    scriptInterface.SetAnimationParameterFeature(n"StatusEffect", this.m_animFeatureStatusEffect, scriptInterface.executionOwner);
    stateContext.SetPermanentFloatParameter(StatusEffectHelper.GetStateStartTimeKey(), EngineTime.ToFloat(scriptInterface.GetTimeSystem().GetSimTime()), true);
    stateContext.SetPermanentScriptableParameter(StatusEffectHelper.GetForceKnockdownKey(), statusEffectRecord, true);
    if this.exitForce.valid {
      stateContext.SetPermanentVectorParameter(StatusEffectHelper.GetForcedKnockdownImpulseKey(), this.exitForce.value, true);
    };
    this.PlaySound(n"v_mbike_dst_crash_fall", scriptInterface);
  }
}

public class DeathExitingDecisions extends ExitingDecisions {

  public const func EnterCondition(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let impulse: Vector4;
    let playerOwner: ref<PlayerPuppet>;
    let vehicle: ref<VehicleObject>;
    let vehicleVelocity: Vector4;
    if stateContext.GetIntParameter(n"vehClass", true) != 1 {
      return false;
    };
    playerOwner = scriptInterface.executionOwner as PlayerPuppet;
    if IsDefined(playerOwner) {
      if playerOwner.IsDead() {
        vehicle = scriptInterface.owner as VehicleObject;
        vehicleVelocity = vehicle.GetLinearVelocity();
        if Vector4.LengthSquared(vehicleVelocity) < 0.10 {
          impulse = playerOwner.GetWorldForward();
        } else {
          impulse = Vector4.Normalize(vehicleVelocity);
        };
        impulse *= -9.00;
        stateContext.SetTemporaryVectorParameter(n"ExitForce", impulse, true);
        return true;
      };
    };
    return false;
  }
}

public class ExitEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo;
    let startedExiting: Bool;
    let startedExitingResult: StateResultBool;
    let unmountEvent: ref<UnmountingRequest>;
    this.OnEnter(stateContext, scriptInterface);
    startedExitingResult = stateContext.GetPermanentBoolParameter(n"startedExiting");
    startedExiting = startedExitingResult.valid && startedExitingResult.value;
    stateContext.SetPermanentBoolParameter(n"startedExiting", false, true);
    VehicleComponent.SetAnimsetOverrideForPassenger(scriptInterface.executionOwner, 0.00);
    this.RemoveUnmountingRequest(stateContext);
    unmountEvent = new UnmountingRequest();
    mountingInfo.childId = scriptInterface.executionOwnerEntityID;
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    if !startedExiting {
      unmountEvent.mountData = new MountEventData();
      unmountEvent.mountData.isInstant = true;
    };
    scriptInterface.GetMountingFacility().Unmount(unmountEvent);
    this.ResetAnimFeature(stateContext, scriptInterface);
    this.ResetIsCar(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Default));
    this.PlayerStateChange(scriptInterface, 0);
    this.DisableCameraBobbing(stateContext, scriptInterface, false);
    this.SetWasStolen(stateContext, false);
    this.SetWasCombatForced(stateContext, false);
    this.SetRequestedTPPCamera(stateContext, false);
    stateContext.SetPermanentBoolParameter(n"validExitRequest", false, true);
    stateContext.SetPermanentBoolParameter(n"validExitAfterSwitchRequest", false, true);
    stateContext.SetPermanentBoolParameter(n"validSwitchSeatExitRequest", false, true);
    stateContext.SetPermanentBoolParameter(n"teleportExitActive", false, true);
  }

  protected func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class WaitingForSceneDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"sceneActionInProgress", false) {
      return true;
    };
    return false;
  }

  public final const func ToExit(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsExitForced(stateContext) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }

  public final const func ToEntering(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"sceneActionFinished", false) {
      return true;
    };
    return false;
  }
}

public class SceneDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsInScene(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsExitForced(stateContext) || !this.IsInScene(stateContext, scriptInterface) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }

  public final const func ToVehicleTurret(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.GetPuppetVehicleSceneTransition(stateContext), PuppetVehicleState.Turret);
  }

  public final const func ToCombat(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsPassengerInVehicle(scriptInterface) {
      if this.CanTransitionToCombat(stateContext) {
        return true;
      };
    };
    return false;
  }

  public final const func ToDriverCombat(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsDriverInVehicle(scriptInterface) && VehicleTransition.CanEnterDriverCombat() {
      if this.CanTransitionToCombat(stateContext) {
        return true;
      };
    };
    return false;
  }

  protected final const func CanTransitionToCombat(const stateContext: ref<StateContext>) -> Bool {
    let puppetVehicleState: PuppetVehicleState = this.GetPuppetVehicleSceneTransition(stateContext);
    if Equals(puppetVehicleState, PuppetVehicleState.CombatSeated) || Equals(puppetVehicleState, PuppetVehicleState.CombatWindowed) {
      if !this.IsInEmptyHandsState(stateContext) {
        return true;
      };
    };
    return false;
  }
}

public class SceneEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mountingInfo: MountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    this.SetSide(stateContext, scriptInterface);
    this.ForceIdleVehicle(stateContext);
    this.SetIsCar(stateContext, true);
    this.SendIsCar(stateContext, scriptInterface);
    this.PlayerStateChange(scriptInterface, 3);
    this.SetVehicleCameraSceneMode(scriptInterface, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vehicle, EnumInt(gamePSMVehicle.Scene));
    this.SendAnimFeature(stateContext, scriptInterface);
    if !scriptInterface.GetWorkspotSystem().IsActorInWorkspot(scriptInterface.executionOwner) && !scriptInterface.IsSceneAnimationActive() {
      this.FallbackMountToWorkspot(scriptInterface, mountingInfo);
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let sceneGameplayTransition: PuppetVehicleState;
    let isInVehicleCombat: Bool = false;
    let puppetVehicleState: StateResultInt = stateContext.GetTemporaryIntParameter(n"scenePuppetVehicleState");
    if puppetVehicleState.valid {
      stateContext.SetPermanentIntParameter(n"scenePuppetVehicleState", puppetVehicleState.value, true);
      sceneGameplayTransition = this.GetPuppetVehicleSceneTransition(stateContext);
      if Equals(sceneGameplayTransition, PuppetVehicleState.GunnerSlot) {
        stateContext.SetPermanentIntParameter(n"vehSlot", 3, true);
        isInVehicleCombat = true;
      } else {
        if Equals(sceneGameplayTransition, PuppetVehicleState.CombatWindowed) || Equals(sceneGameplayTransition, PuppetVehicleState.CombatSeated) {
          isInVehicleCombat = true;
        };
      };
      if Equals(sceneGameplayTransition, PuppetVehicleState.IdleMounted) || Equals(sceneGameplayTransition, PuppetVehicleState.CombatWindowed) || Equals(sceneGameplayTransition, PuppetVehicleState.CombatSeated) {
        this.SetSide(stateContext, scriptInterface);
      };
      if isInVehicleCombat {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
      };
      this.SetIsInVehicleWindowCombat(stateContext, Equals(sceneGameplayTransition, PuppetVehicleState.CombatWindowed));
      this.SetIsInVehicle(stateContext, NotEquals(sceneGameplayTransition, PuppetVehicleState.IdleStand));
      this.SetIsInVehicleCombat(stateContext, isInVehicleCombat);
    };
    this.SendAnimFeature(stateContext, scriptInterface);
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let sceneGameplayTransition: PuppetVehicleState = this.GetPuppetVehicleSceneTransition(stateContext);
    stateContext.RemovePermanentIntParameter(n"scenePuppetVehicleState");
    stateContext.SetTemporaryBoolParameter(n"vehicleWindowedCombat", Equals(sceneGameplayTransition, PuppetVehicleState.CombatWindowed), true);
    stateContext.SetTemporaryIntParameter(n"scenePuppetVehicleState", EnumInt(sceneGameplayTransition), true);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.SetVehicleCameraSceneMode(scriptInterface, false);
    this.SetOneHandedFirearmsGameplayRestriction(scriptInterface, false);
  }

  protected func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  public final func FallbackMountToWorkspot(scriptInterface: ref<StateGameScriptInterface>, mountingInfo: MountingInfo) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    workspotSystem.MountToVehicle(scriptInterface.owner, scriptInterface.executionOwner, 0.00, 0.00, n"OccupantSlots", mountingInfo.slotId.id);
  }
}

public class SceneExitingDecisions extends VehicleTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsExitForced(stateContext) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.GetWorkspotSystem().IsActorInWorkspot(scriptInterface.executionOwner) || !IsDefined(scriptInterface.owner) {
      return true;
    };
    return false;
  }
}

public class SceneExitingEvents extends VehicleEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let startedMountingEvent: ref<VehicleStartedMountingEvent>;
    let unmountEvent: ref<MountEventData>;
    this.OnEnter(stateContext, scriptInterface);
    unmountEvent = this.GetUnmountingEvent(stateContext);
    if unmountEvent != null {
      startedMountingEvent = new VehicleStartedMountingEvent();
      startedMountingEvent.slotID = unmountEvent.slotName;
      startedMountingEvent.isMounting = false;
      startedMountingEvent.character = scriptInterface.executionOwner;
      startedMountingEvent.instant = false;
      scriptInterface.owner.QueueEvent(startedMountingEvent);
      stateContext.SetPermanentBoolParameter(n"startedExiting", true, true);
    };
    if this.IsExitForced(stateContext) && scriptInterface.GetWorkspotSystem().IsActorInWorkspot(scriptInterface.executionOwner) {
      if !scriptInterface.IsSceneAnimationActive() {
        this.ExitWorkspot(stateContext, scriptInterface, unmountEvent.isInstant);
        this.PlayVehicleExitDoorAnimation(stateContext, scriptInterface);
      };
    };
    this.SetIsInVehicle(stateContext, false);
    this.SendAnimFeature(stateContext, scriptInterface);
    this.RemoveUnmountingRequest(stateContext);
  }
}

public static exec func BlockSwitchSeats(gi: GameInstance, block: String) -> Void {
  let debugBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().DebugData);
  debugBB.SetBool(GetAllBlackboardDefs().DebugData.Vehicle_BlockSwitchSeats, StringToBool(block));
}
