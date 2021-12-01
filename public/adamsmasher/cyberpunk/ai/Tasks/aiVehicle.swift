
public abstract class AIVehicleTaskAbstract extends AIbehaviortaskScript {

  protected final func SendAIEventToMountedVehicle(context: ScriptExecutionContext, eventName: CName) -> Bool {
    let evt: ref<AIEvent>;
    let vehicle: wref<GameObject>;
    if !IsNameValid(eventName) || !VehicleComponent.GetVehicle(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context), vehicle) {
      return false;
    };
    evt = new AIEvent();
    evt.name = eventName;
    vehicle.QueueEvent(evt);
    return true;
  }

  protected final func SendAICommandToMountedVehicle(context: ScriptExecutionContext, command: ref<AIVehicleCommand>) -> Bool {
    let evt: ref<AICommandEvent>;
    let vehicle: wref<GameObject>;
    if !IsDefined(command) || !VehicleComponent.GetVehicle(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context), vehicle) {
      return false;
    };
    evt = new AICommandEvent();
    evt.command = command;
    vehicle.QueueEvent(evt);
    return true;
  }
}

public class SetAnimWrappersFromMountData extends AIVehicleTaskAbstract {

  protected inline edit let m_mountData: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let mountData: ref<MountEventData> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_mountData) as MountEventData;
    if IsDefined(mountData) {
      VehicleComponent.SetAnimsetOverrideForPassenger(ScriptExecutionContext.GetOwner(context), mountData.mountParentEntityId, mountData.slotName, 1.00);
    };
  }
}

public class EnterVehicle extends AIVehicleTaskAbstract {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    if VehicleComponent.IsDriver(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
      this.SendAIEventToMountedVehicle(context, n"DriverReady");
    };
  }
}

public class ExitFromVehicle extends AIVehicleTaskAbstract {

  public edit let useFastExit: Bool;

  public edit let tryBlendToWalk: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let VehDoorRequestEvent: ref<VehicleExternalDoorRequestEvent>;
    let mountInfo: MountingInfo;
    let ownerPuppet: wref<ScriptedPuppet>;
    let slotName: CName;
    let unmountingEvt: ref<VehicleStartedMountingEvent>;
    let vehicle: wref<VehicleObject>;
    let workspotSystem: ref<WorkspotGameSystem>;
    ScriptExecutionContext.SetArgumentScriptable(context, n"ActiveMountRequest", null);
    VehDoorRequestEvent = new VehicleExternalDoorRequestEvent();
    unmountingEvt = new VehicleStartedMountingEvent();
    mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
    vehicle = GameInstance.FindEntityByID(ScriptExecutionContext.GetOwner(context).GetGame(), mountInfo.parentId) as VehicleObject;
    slotName = mountInfo.slotId.id;
    VehDoorRequestEvent.slotName = vehicle.GetBoneNameFromSlot(slotName);
    VehDoorRequestEvent.autoClose = true;
    unmountingEvt.slotID = slotName;
    unmountingEvt.isMounting = false;
    unmountingEvt.character = ScriptExecutionContext.GetOwner(context);
    workspotSystem = GameInstance.GetWorkspotSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(workspotSystem) {
      ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
      if this.useFastExit {
        workspotSystem.SendFastExitSignal(ScriptExecutionContext.GetOwner(context), true, this.tryBlendToWalk);
      } else {
        if IsDefined(ownerPuppet) && Equals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
          workspotSystem.UnmountFromVehicle(vehicle, ScriptExecutionContext.GetOwner(context), false, n"combat");
        } else {
          workspotSystem.UnmountFromVehicle(vehicle, ScriptExecutionContext.GetOwner(context), false, n"default");
        };
      };
    };
    if VehicleComponent.IsDriver(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
      this.SendAIEventToMountedVehicle(context, n"NoDriver");
    };
    vehicle.QueueEvent(unmountingEvt);
    vehicle.QueueEvent(VehDoorRequestEvent);
  }
}

public class ApproachVehicleDecorator extends AIVehicleTaskAbstract {

  protected inline edit let m_mountData: ref<AIArgumentMapping>;

  protected inline edit let m_mountRequest: ref<AIArgumentMapping>;

  protected inline edit let m_entryPoint: ref<AIArgumentMapping>;

  private let m_doorOpenRequestSent: Bool;

  private let m_closeDoor: Bool;

  private let mountEventData: ref<MountEventData>;

  private let mountRequestData: ref<MountEventData>;

  private let mountEntryPoint: Vector4;

  private let m_activationTime: EngineTime;

  private let m_runCompanionCheck: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_doorOpenRequestSent = false;
    this.m_closeDoor = false;
    this.mountEventData = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_mountData) as MountEventData;
    this.mountEntryPoint = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_entryPoint));
    this.m_activationTime = ScriptExecutionContext.GetAITime(context);
    this.m_runCompanionCheck = ScriptedPuppet.IsPlayerCompanion(ScriptExecutionContext.GetOwner(context));
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let distToVehicle: Float;
    let seatReservationEvent: ref<VehicleSeatReservationEvent>;
    let vecToVehicle: Vector4;
    let vehicle: wref<VehicleObject>;
    let vehicleID: EntityID;
    let vehicleSlotID: MountingSlotId;
    let hls: gamedataNPCHighLevelState = AIBehaviorScriptBase.GetPuppet(context).GetHighLevelStateFromBlackboard();
    if Equals(hls, gamedataNPCHighLevelState.Alerted) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(this.mountEventData) {
      if this.m_doorOpenRequestSent {
        this.m_closeDoor = true;
      };
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    this.mountRequestData = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_mountRequest) as MountEventData;
    if this.mountEventData != this.mountRequestData {
      if this.m_doorOpenRequestSent {
        this.m_closeDoor = true;
      };
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    vehicleID = this.mountEventData.mountParentEntityId;
    vehicleSlotID.id = this.mountEventData.slotName;
    if !VehicleComponent.GetVehicleFromID(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID, vehicle) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if vehicle.IsDestroyed() {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if this.m_runCompanionCheck && this.UpdateComponionChecks(context, vehicle) {
      ScriptExecutionContext.SetArgumentBool(context, n"_teleportAfterApproach", true);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    if this.m_doorOpenRequestSent {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    vecToVehicle = this.mountEntryPoint - ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    distToVehicle = Vector4.Length(vecToVehicle);
    if distToVehicle <= 0.10 {
      seatReservationEvent = new VehicleSeatReservationEvent();
      seatReservationEvent.slotID = vehicleSlotID.id;
      seatReservationEvent.reserve = true;
      GameInstance.GetPersistencySystem(vehicle.GetGame()).QueuePSEvent(vehicle.GetVehiclePS().GetID(), vehicle.GetPSClassName(), seatReservationEvent);
      if VehicleComponent.OpenDoor(vehicle, vehicleSlotID) {
        this.m_doorOpenRequestSent = true;
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func UpdateComponionChecks(context: ScriptExecutionContext, ownerVehicle: wref<VehicleObject>) -> Bool {
    let componanion: wref<GameObject>;
    let componanionVehicle: wref<VehicleObject>;
    if ScriptedPuppet.IsPlayerCompanion(ScriptExecutionContext.GetOwner(context), componanion) && VehicleComponent.GetVehicle(ScriptExecutionContext.GetOwner(context).GetGame(), componanion, componanionVehicle) && ownerVehicle == componanionVehicle {
      if this.m_activationTime + 1.00 <= ScriptExecutionContext.GetAITime(context) {
        return true;
      };
    } else {
      this.m_runCompanionCheck = false;
    };
    return false;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let vehicle: wref<VehicleObject>;
    let vehicleID: EntityID;
    let vehicleSlotID: MountingSlotId;
    if !IsDefined(this.mountEventData) || !this.m_closeDoor {
      return;
    };
    vehicleID = this.mountEventData.mountParentEntityId;
    vehicleSlotID.id = this.mountEventData.slotName;
    if VehicleComponent.GetVehicleFromID(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID, vehicle) {
      VehicleComponent.CloseDoor(vehicle, vehicleSlotID);
    };
  }
}

public class SlotReservationDecorator extends AIVehicleTaskAbstract {

  protected inline edit let m_mountData: ref<AIArgumentMapping>;

  private let mountEventData: ref<MountEventData>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.mountEventData = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_mountData) as MountEventData;
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let seatReservationEvent: ref<VehicleSeatReservationEvent>;
    let vehicle: wref<VehicleObject>;
    let vehicleID: EntityID;
    let vehicleSlotID: MountingSlotId;
    if !IsDefined(this.mountEventData) {
      return;
    };
    vehicleID = this.mountEventData.mountParentEntityId;
    vehicleSlotID.id = this.mountEventData.slotName;
    if VehicleComponent.GetVehicleFromID(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID, vehicle) {
      seatReservationEvent = new VehicleSeatReservationEvent();
      seatReservationEvent.slotID = vehicleSlotID.id;
      seatReservationEvent.reserve = false;
      GameInstance.GetPersistencySystem(vehicle.GetGame()).QueuePSEvent(vehicle.GetVehiclePS().GetID(), vehicle.GetPSClassName(), seatReservationEvent);
    };
  }
}

public class GetOnWindowCombatDecorator extends AIVehicleTaskAbstract {

  public let windowOpenEvent: ref<VehicleExternalWindowRequestEvent>;

  public let mountInfo: MountingInfo;

  public let vehicle: wref<GameObject>;

  public let slotName: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
    this.vehicle = GameInstance.FindEntityByID(ScriptExecutionContext.GetOwner(context).GetGame(), this.mountInfo.parentId) as GameObject;
    this.slotName = this.mountInfo.slotId.id;
    this.windowOpenEvent = new VehicleExternalWindowRequestEvent();
    this.windowOpenEvent.slotName = this.slotName;
    this.windowOpenEvent.shouldOpen = true;
    this.vehicle.QueueEvent(this.windowOpenEvent);
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class InVehicleDecorator extends AIVehicleTaskAbstract {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let activeMountRequest: ref<MountEventData>;
    let request: ref<MountEventData> = ScriptExecutionContext.GetArgumentScriptable(context, n"MountRequest") as MountEventData;
    if request != null {
      activeMountRequest = new MountEventData();
      activeMountRequest.slotName = request.slotName;
      activeMountRequest.mountParentEntityId = request.mountParentEntityId;
      activeMountRequest.mountEventOptions = request.mountEventOptions;
      activeMountRequest.isInstant = true;
    };
    ScriptExecutionContext.SetArgumentScriptable(context, n"ActiveMountRequest", activeMountRequest);
    ScriptExecutionContext.SetArgumentScriptable(context, n"MountRequest", null);
    AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, true);
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let mountInfo: MountingInfo;
    let request: ref<MountEventData> = ScriptExecutionContext.GetArgumentScriptable(context, n"MountRequest") as MountEventData;
    if IsDefined(request) {
      mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
      if mountInfo.parentId == request.mountParentEntityId && Equals(mountInfo.slotId.id, request.slotName) {
        ScriptExecutionContext.SetArgumentScriptable(context, n"MountRequest", null);
        ScriptExecutionContext.InvokeBehaviorCallback(context, n"OnMountRequest");
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, false);
  }
}

public class InVehicleCombatDecorator extends AIVehicleTaskAbstract {

  public let targetToChase: wref<GameObject>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let combatTarget: wref<GameObject>;
    if VehicleComponent.IsDriver(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) && VehicleComponent.CanBeDriven(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context).GetEntityID()) {
      combatTarget = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
      if IsDefined(combatTarget) && combatTarget != this.targetToChase {
        this.ChaseNewTarget(context, combatTarget);
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    if IsDefined(this.targetToChase) {
      this.SendAIEventToMountedVehicle(context, n"StopFollowing");
      this.targetToChase = null;
    };
  }

  protected final func ChaseNewTarget(context: ScriptExecutionContext, newTarget: wref<GameObject>) -> Void {
    let command: ref<AIVehicleFollowCommand> = new AIVehicleFollowCommand();
    command.target = newTarget;
    command.stopWhenTargetReached = false;
    command.distanceMin = 5.00;
    command.distanceMax = 6.00;
    command.useTraffic = false;
    command.needDriver = true;
    if this.SendAICommandToMountedVehicle(context, command) {
      this.targetToChase = newTarget;
    };
  }
}

public class MountAssigendVehicle extends AIVehicleTaskAbstract {

  private let result: AIbehaviorUpdateOutcome;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let evt: ref<MountAIEvent>;
    let mountData: ref<MountEventData>;
    let vehicleID: EntityID;
    let vehicleSlotID: MountingSlotId;
    if !AIBehaviorScriptBase.GetAIComponent(context).GetAssignedVehicleData(vehicleID, vehicleSlotID) {
      this.result = AIbehaviorUpdateOutcome.FAILURE;
      return;
    };
    if VehicleComponent.IsSlotOccupied(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID, vehicleSlotID) {
      this.result = AIbehaviorUpdateOutcome.FAILURE;
      return;
    };
    mountData = new MountEventData();
    mountData.slotName = vehicleSlotID.id;
    mountData.mountParentEntityId = vehicleID;
    mountData.isInstant = false;
    mountData.ignoreHLS = true;
    evt = new MountAIEvent();
    evt.name = n"Mount";
    evt.data = mountData;
    ScriptExecutionContext.GetOwner(context).QueueEvent(evt);
    this.result = AIbehaviorUpdateOutcome.SUCCESS;
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    return this.result;
  }
}

public class WaitBeforeExiting extends AIVehicleTaskAbstract {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    if VehicleComponent.IsDriver(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
      this.SendAIEventToMountedVehicle(context, n"NoDriver");
    };
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let vehicle: wref<VehicleObject>;
    let mountInfo: MountingInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
    if !VehicleComponent.GetVehicleFromID(ScriptExecutionContext.GetOwner(context).GetGame(), mountInfo.parentId, vehicle) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if vehicle.GetCurrentSpeed() < 0.50 {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public abstract class AIVehicleConditionAbstract extends AIbehaviorconditionScript {

  protected final func IsVehicleOccupiedByHostile(context: ScriptExecutionContext, vehicleID: EntityID) -> Bool {
    return VehicleComponent.IsVehicleOccupiedByHostile(vehicleID, ScriptExecutionContext.GetOwner(context));
  }
}

public class HasVehicleAssigned extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(AIBehaviorScriptBase.GetAIComponent(context).HasVehicleAssigned());
  }
}

public class CanMountVehicle extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let vehicleID: EntityID;
    let vehicleSlotID: MountingSlotId;
    if !AIBehaviorScriptBase.GetAIComponent(context).GetAssignedVehicleData(vehicleID, vehicleSlotID) {
      return Cast(false);
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(ScriptExecutionContext.GetOwner(context), n"BlockMountVehicle") {
      return Cast(false);
    };
    if VehicleComponent.IsDestroyed(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID) {
      return Cast(false);
    };
    if VehicleComponent.IsSlotOccupied(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID, vehicleSlotID) {
      return Cast(false);
    };
    if this.IsVehicleOccupiedByHostile(context, vehicleID) {
      return Cast(false);
    };
    if NotEquals(vehicleSlotID.id, VehicleComponent.GetDriverSlotName()) && !VehicleComponent.HasActiveDriver(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class DoesVehicleSupportCombat extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let vehicleRecord: ref<Vehicle_Record>;
    let vehicleTags: array<CName>;
    if !VehicleComponent.GetVehicleRecord(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context), vehicleRecord) {
      return Cast(false);
    };
    vehicleTags = vehicleRecord.Tags();
    if ArraySize(vehicleTags) > 0 && ArrayContains(vehicleTags, n"CombatDisabled") {
      return Cast(false);
    };
    if IsDefined(vehicleRecord.VehDataPackage()) && !vehicleRecord.VehDataPackage().SupportsCombat() {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class IsNPCDriver extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if !VehicleComponent.IsDriver(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class IsNPCAloneInVehicle extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let vehicleID: EntityID;
    if !VehicleComponent.GetVehicleID(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context), vehicleID) {
      return Cast(false);
    };
    if !VehicleComponent.HasOnlyOneActivePassenger(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class IsDriverActive extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let vehicleID: EntityID;
    if !VehicleComponent.GetVehicleID(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context), vehicleID) {
      return Cast(false);
    };
    if !VehicleComponent.HasActiveDriver(ScriptExecutionContext.GetOwner(context).GetGame(), vehicleID) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class HasNewMountRequest extends AIVehicleConditionAbstract {

  protected inline edit let m_mountRequest: ref<AIArgumentMapping>;

  protected edit let m_checkOnlyInstant: Bool;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let mountInfo: MountingInfo;
    let mountRequestData: ref<MountEventData> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_mountRequest) as MountEventData;
    if !IsDefined(mountRequestData) {
      return Cast(false);
    };
    if this.m_checkOnlyInstant && !mountRequestData.isInstant {
      return Cast(false);
    };
    mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
    if mountInfo.parentId != mountRequestData.mountParentEntityId {
      return Cast(true);
    };
    if NotEquals(mountInfo.slotId.id, mountRequestData.slotName) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class ShouldExitVehicle extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let mountInfo: MountingInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
    if this.IsVehicleOccupiedByHostile(context, mountInfo.parentId) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class IsInVehicle extends AIVehicleConditionAbstract {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let vehicleID: EntityID;
    if !VehicleComponent.GetVehicleID(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context), vehicleID) {
      return Cast(false);
    };
    return Cast(true);
  }
}
