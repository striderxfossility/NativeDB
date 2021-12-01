
public static func OperatorEqual(hudInstance1: ref<ModuleInstance>, hudInstance2: ref<ModuleInstance>) -> Bool {
  if IsDefined(hudInstance1) && IsDefined(hudInstance2) {
    return hudInstance1.GetEntityID() == hudInstance2.GetEntityID();
  };
  return false;
}

public static func OperatorGreaterEqual(activeMode1: ActiveMode, activeMode2: ActiveMode) -> Bool {
  if EnumInt(activeMode1) >= EnumInt(activeMode2) {
    return true;
  };
  return false;
}

public static func OperatorLessEqual(activeMode1: ActiveMode, activeMode2: ActiveMode) -> Bool {
  if EnumInt(activeMode1) <= EnumInt(activeMode2) {
    return true;
  };
  return false;
}

public class HUDManagerRequest extends ScriptableSystemRequest {

  public let ownerID: EntityID;

  public final const func IsValid() -> Bool {
    if EntityID.IsDefined(this.ownerID) {
      return true;
    };
    return false;
  }
}

public class HUDManagerRegistrationRequest extends HUDManagerRequest {

  public let isRegistering: Bool;

  public let type: HUDActorType;

  public final func SetProperties(owner: ref<GameObject>, shouldRegister: Bool) -> Void {
    this.ownerID = owner.GetEntityID();
    this.isRegistering = shouldRegister;
    if IsDefined(owner as ScriptedPuppet) {
      this.type = HUDActorType.PUPPET;
    } else {
      if IsDefined(owner as DisposalDevice) {
        this.type = HUDActorType.BODY_DISPOSAL_DEVICE;
      } else {
        if IsDefined(owner as Device) {
          this.type = HUDActorType.DEVICE;
        } else {
          if IsDefined(owner as VehicleObject) {
            this.type = HUDActorType.VEHICLE;
          } else {
            if IsDefined(owner as gameLootObject) {
              this.type = HUDActorType.ITEM;
            } else {
              if IsDefined(owner) {
                this.type = HUDActorType.GAME_OBJECT;
              } else {
                this.type = HUDActorType.UNINITIALIZED;
              };
            };
          };
        };
      };
    };
  }
}

public class RefreshActorRequest extends HUDManagerRequest {

  private let actorUpdateData: ref<HUDActorUpdateData>;

  private let requestedModules: array<wref<HUDModule>>;

  public final static func Construct(requesterID: EntityID, opt updateData: ref<HUDActorUpdateData>, opt suggestedModules: array<wref<HUDModule>>) -> ref<RefreshActorRequest> {
    let i: Int32;
    let request: ref<RefreshActorRequest> = new RefreshActorRequest();
    request.ownerID = requesterID;
    if IsDefined(updateData) {
      request.actorUpdateData = updateData;
    };
    i = 0;
    while i < ArraySize(suggestedModules) {
      if IsDefined(suggestedModules[i]) {
        ArrayPush(request.requestedModules, suggestedModules[i]);
      };
      i += 1;
    };
    return request;
  }

  public final const func GetActorUpdateData() -> ref<HUDActorUpdateData> {
    return this.actorUpdateData;
  }

  public final const func GetRequestedModules() -> array<wref<HUDModule>> {
    return this.requestedModules;
  }
}

public native class HUDActor extends IScriptable {

  private let entityID: EntityID;

  @default(DEVICE_Actor, HUDActorType.DEVICE)
  @default(GAMEOBJECT_Actor, HUDActorType.GAME_OBJECT)
  @default(PUPPET_ACtor, HUDActorType.PUPPET)
  @default(VEHICLE_Actor, HUDActorType.VEHICLE)
  private let type: HUDActorType;

  private let status: HUDActorStatus;

  private let visibility: ActorVisibilityStatus;

  private let activeModules: array<wref<HUDModule>>;

  private let isRevealed: Bool;

  private let isTagged: Bool;

  private let clueData: HUDClueData;

  private let isRemotelyAccessed: Bool;

  private let canOpenScannerInfo: Bool;

  private let isInIconForcedVisibilityRange: Bool;

  private let isIconForcedVisibleThroughWalls: Bool;

  @default(HUDActor, true)
  private let shouldRefreshQHack: Bool;

  public final static func Construct(self: ref<HUDActor>, entityID: EntityID, type: HUDActorType, status: HUDActorStatus, visibility: ActorVisibilityStatus) -> Void {
    self.entityID = entityID;
    self.type = type;
    self.status = status;
    self.visibility = visibility;
  }

  public final func UpdateActorData(updateData: ref<HUDActorUpdateData>) -> Void {
    if updateData == null {
      return;
    };
    if updateData.updateVisibility {
      this.visibility = updateData.visibilityValue;
    };
    if updateData.updateIsRevealed {
      this.isRevealed = updateData.isRevealedValue;
    };
    if updateData.updateIsTagged {
      this.isTagged = updateData.isTaggedValue;
    };
    if updateData.updateClueData {
      this.clueData = updateData.clueDataValue;
    };
    if updateData.updateIsRemotelyAccessed {
      this.isRemotelyAccessed = updateData.isRemotelyAccessedValue;
    };
    if updateData.updateCanOpenScannerInfo {
      this.canOpenScannerInfo = updateData.canOpenScannerInfoValue;
    };
    if updateData.updateIsInIconForcedVisibilityRange {
      this.isInIconForcedVisibilityRange = updateData.isInIconForcedVisibilityRangeValue;
    };
    if updateData.updateIsIconForcedVisibleThroughWalls {
      this.isIconForcedVisibleThroughWalls = updateData.isIconForcedVisibleThroughWallsValue;
    };
  }

  public final func AddModule(module: ref<HUDModule>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.activeModules) {
      if this.activeModules[i] == module {
        return;
      };
      i += 1;
    };
    ArrayPush(this.activeModules, module);
  }

  public final func RemoveModule(module: ref<HUDModule>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.activeModules) {
      if this.activeModules[i] == module {
        ArrayErase(this.activeModules, i);
        return;
      };
      i += 1;
    };
  }

  public final func SetStatus(newStatus: HUDActorStatus) -> Void {
    this.status = newStatus;
  }

  public final func SetRemotelyAccessed(value: Bool) -> Void {
    this.isRemotelyAccessed = value;
  }

  public final func SetRevealed(value: Bool) -> Void {
    this.isRevealed = value;
  }

  public final func SetTagged(value: Bool) -> Void {
    this.isTagged = value;
  }

  public final func SetClue(value: Bool) -> Void {
    this.clueData.isClue = value;
  }

  public final func SetClueGroup(value: CName) -> Void {
    this.clueData.clueGroupID = value;
  }

  public final func SetCanOpenScannerInfo(value: Bool) -> Void {
    this.canOpenScannerInfo = value;
  }

  public final func SetIsInIconForcedVisibilityRange(value: Bool) -> Void {
    this.isInIconForcedVisibilityRange = value;
  }

  public final func SetIsIconForcedVisibileThroughWalls(value: Bool) -> Void {
    this.isIconForcedVisibleThroughWalls = value;
  }

  public final func SetShouldRefreshQHack(value: Bool) -> Void {
    this.shouldRefreshQHack = value;
  }

  public final const func GetEntityID() -> EntityID {
    return this.entityID;
  }

  public final const func GetType() -> HUDActorType {
    return this.type;
  }

  public final const func GetStatus() -> HUDActorStatus {
    return this.status;
  }

  public final const func GetVisibility() -> ActorVisibilityStatus {
    return this.visibility;
  }

  public final const func IsRevealed() -> Bool {
    return this.isRevealed;
  }

  public final const func IsTagged() -> Bool {
    return this.isTagged;
  }

  public final const func IsClue() -> Bool {
    return this.clueData.isClue;
  }

  public final const func IsGrouppedClue() -> Bool {
    return IsNameValid(this.clueData.clueGroupID);
  }

  public final const func IsRemotelyAccessed() -> Bool {
    return this.isRemotelyAccessed;
  }

  public final const func CanOpenScannerInfo() -> Bool {
    return this.canOpenScannerInfo;
  }

  public final const func IsInIconForcedVisibilityRange() -> Bool {
    return this.isInIconForcedVisibilityRange;
  }

  public final const func IsIconForcedVisibileThroughWalls() -> Bool {
    return this.isIconForcedVisibleThroughWalls;
  }

  public final const func GetShouldRefreshQHack() -> Bool {
    return this.shouldRefreshQHack;
  }

  public final const func GetActiveModules() -> array<wref<HUDModule>> {
    return this.activeModules;
  }
}
