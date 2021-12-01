
public native class gamestateMachineComponent extends gamePlayerControlledComponent {

  public final native func AddStateMachine(stateMachineName: CName, instanceData: StateMachineInstanceData, owner: wref<Entity>, opt tryHotSwap: Bool) -> Void;

  public final native func RemoveStateMachine(stateMachineIdentifier: StateMachineIdentifier) -> Void;

  public final native func IsStateMachinePresent(stateMachineIdentifier: StateMachineIdentifier) -> Bool;

  public final native func GetSnapshotContainer() -> StateSnapshotsContainer;

  protected cb func OnStartTakedownEvent(startTakedownEvent: ref<StartTakedownEvent>) -> Bool {
    let instanceData: StateMachineInstanceData;
    let initData: ref<LocomotionTakedownInitData> = new LocomotionTakedownInitData();
    let addEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let record1HitDamage: ref<Record1DamageInHistoryEvent> = new Record1DamageInHistoryEvent();
    initData.target = startTakedownEvent.target;
    initData.slideTime = startTakedownEvent.slideTime;
    initData.actionName = startTakedownEvent.actionName;
    instanceData.initData = initData;
    addEvent.stateMachineName = n"LocomotionTakedown";
    addEvent.instanceData = instanceData;
    let owner: wref<Entity> = this.GetEntity();
    owner.QueueEvent(addEvent);
    if IsDefined(startTakedownEvent.target) {
      record1HitDamage.source = owner as GameObject;
      startTakedownEvent.target.QueueEvent(record1HitDamage);
    };
  }

  protected cb func OnRipOff(evt: ref<RipOff>) -> Bool {
    let instanceData: StateMachineInstanceData;
    let addEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let initData: ref<TurretInitData> = new TurretInitData();
    let owner: wref<GameObject> = this.GetEntity() as GameObject;
    initData.turret = GameInstance.FindEntityByID(owner.GetGame(), evt.GetRequesterID()) as GameObject;
    instanceData.initData = initData;
    addEvent.stateMachineName = n"Turret";
    addEvent.instanceData = instanceData;
    owner.QueueEvent(addEvent);
  }

  protected cb func OnStartMountingEvent(mountingEvent: ref<MountingEvent>) -> Bool {
    let relationship: MountingRelationship = mountingEvent.relationship;
    let owner: ref<Entity> = this.GetEntity();
    switch relationship.relationshipType {
      case gameMountingRelationshipType.Parent:
        this.MountFromParent(mountingEvent, owner);
        break;
      case gameMountingRelationshipType.Child:
        this.MountAsChild(mountingEvent, owner);
        break;
      default:
    };
  }

  protected cb func OnStartUnmountingEvent(unmountingEvent: ref<UnmountingEvent>) -> Bool {
    let relationship: MountingRelationship = unmountingEvent.relationship;
    let owner: ref<Entity> = this.GetEntity();
    switch relationship.relationshipType {
      case gameMountingRelationshipType.Parent:
        this.UnmountFromParent(unmountingEvent, owner);
        break;
      case gameMountingRelationshipType.Child:
        this.UnmountChild(unmountingEvent, owner);
        break;
      default:
    };
  }

  protected final func MountFromParent(mountingEvent: ref<MountingEvent>, ownerEntity: ref<Entity>) -> Void {
    let instanceData: StateMachineInstanceData;
    let initData: ref<VehicleTransitionInitData> = new VehicleTransitionInitData();
    let relationship: MountingRelationship = mountingEvent.relationship;
    let otherObjectType: gameMountingObjectType = relationship.otherMountableType;
    let otherObject: wref<GameObject> = IMountingFacility.RelationshipGetOtherObject(relationship);
    switch otherObjectType {
      case gameMountingObjectType.Vehicle:
        if mountingEvent.request.mountData.mountEventOptions.silentUnmount {
          return;
        };
        initData.instant = mountingEvent.request.mountData.isInstant;
        initData.entityID = mountingEvent.request.mountData.mountEventOptions.entityID;
        initData.alive = mountingEvent.request.mountData.mountEventOptions.alive;
        initData.occupiedByNeutral = mountingEvent.request.mountData.mountEventOptions.occupiedByNeutral;
        instanceData.initData = initData;
        this.AddStateMachine(n"Vehicle", instanceData, otherObject);
        break;
      case gameMountingObjectType.Object:
        break;
      case gameMountingObjectType.Puppet:
        break;
      case gameMountingObjectType.Platform:
        break;
      case gameMountingObjectType.Invalid:
        break;
      default:
    };
  }

  protected final func MountAsChild(mountingEvent: ref<MountingEvent>, ownerEntity: ref<Entity>) -> Void {
    let instanceData: StateMachineInstanceData;
    let stateMachineIdentifier: StateMachineIdentifier;
    let relationship: MountingRelationship = mountingEvent.relationship;
    let otherObjectType: gameMountingObjectType = relationship.otherMountableType;
    let initData: ref<CarriedObjectData> = new CarriedObjectData();
    let otherObject: wref<GameObject> = IMountingFacility.RelationshipGetOtherObject(relationship);
    stateMachineIdentifier.definitionName = n"LocomotionTakedown";
    switch otherObjectType {
      case gameMountingObjectType.Vehicle:
        break;
      case gameMountingObjectType.Puppet:
      case gameMountingObjectType.Object:
        if otherObject != null {
          if !this.IsStateMachinePresent(stateMachineIdentifier) {
            initData.instant = mountingEvent.request.mountData.isInstant;
            instanceData.initData = initData;
            this.AddStateMachine(n"CarriedObject", instanceData, otherObject);
          };
        };
        break;
      case gameMountingObjectType.Platform:
        break;
      case gameMountingObjectType.Invalid:
        break;
      default:
    };
  }

  protected final func UnmountFromParent(unmountingEvent: ref<UnmountingEvent>, ownerEntity: ref<Entity>) -> Void {
    let stateMachineIdentifier: StateMachineIdentifier;
    let relationship: MountingRelationship = unmountingEvent.relationship;
    let otherObjectType: gameMountingObjectType = relationship.otherMountableType;
    let silentUnmount: Bool = unmountingEvent.request.mountData.mountEventOptions.silentUnmount;
    stateMachineIdentifier.definitionName = n"Vehicle";
    switch otherObjectType {
      case gameMountingObjectType.Vehicle:
        if !silentUnmount {
          this.RemoveStateMachine(stateMachineIdentifier);
        };
        break;
      case gameMountingObjectType.Object:
        break;
      case gameMountingObjectType.Puppet:
        break;
      case gameMountingObjectType.Platform:
        break;
      case gameMountingObjectType.Invalid:
        break;
      default:
    };
  }

  protected final func UnmountChild(unmountingEvent: ref<UnmountingEvent>, ownerEntity: ref<Entity>) -> Void {
    let stateMachineIdentifier: StateMachineIdentifier;
    let relationship: MountingRelationship = unmountingEvent.relationship;
    let otherObjectType: gameMountingObjectType = relationship.otherMountableType;
    stateMachineIdentifier.definitionName = n"CarriedObject";
    switch otherObjectType {
      case gameMountingObjectType.Vehicle:
        break;
      case gameMountingObjectType.Puppet:
      case gameMountingObjectType.Object:
        this.RemoveStateMachine(stateMachineIdentifier);
        break;
      case gameMountingObjectType.Platform:
        break;
      case gameMountingObjectType.Invalid:
        break;
      default:
    };
  }
}
