
public class AnimationSystemForcedVisibilityEntityData extends IScriptable {

  private let m_owner: wref<AnimationSystemForcedVisibilityManager>;

  private let m_entityID: EntityID;

  private let m_forcedVisibilityInAnimSystemRequests: array<ref<ForcedVisibilityInAnimSystemData>>;

  private let m_delayedForcedVisibilityInAnimSystemRequests: array<ref<ForcedVisibilityInAnimSystemData>>;

  private let m_hasVisibilityForcedInAnimSystem: Bool;

  private let m_hasVisibilityForcedOnlyInFrustumInAnimSystem: Bool;

  public final func Initialize(entityID: EntityID, owner: wref<AnimationSystemForcedVisibilityManager>) -> Void {
    this.m_owner = owner;
    this.m_entityID = entityID;
  }

  public final func ClearAllRequests() -> Void {
    ArrayClear(this.m_forcedVisibilityInAnimSystemRequests);
    ArrayClear(this.m_delayedForcedVisibilityInAnimSystemRequests);
  }

  public final const func GetEntityID() -> EntityID {
    return this.m_entityID;
  }

  public final const func HasVisibilityForcedInAnimSystem() -> Bool {
    return this.m_hasVisibilityForcedInAnimSystem;
  }

  public final const func HasActiveRequestsForForcedVisibilityInAnimSystem() -> Bool {
    return ArraySize(this.m_forcedVisibilityInAnimSystemRequests) > 0;
  }

  public final func SetHasVisibilityForcedInAnimSystem(isVisible: Bool) -> Void {
    this.m_hasVisibilityForcedInAnimSystem = isVisible;
  }

  public final const func HasVisibilityForcedOnlyInFrustumInAnimSystem() -> Bool {
    return this.m_hasVisibilityForcedOnlyInFrustumInAnimSystem;
  }

  public final const func HasActiveRequestsForForcedVisibilityOnlyInFrustumInAnimSystem() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedVisibilityInAnimSystemRequests) {
      if this.m_forcedVisibilityInAnimSystemRequests[i].forcedVisibleOnlyInFrustum {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func SetHasVisibilityForcedOnlyInFrustumInAnimSystem(isVisible: Bool) -> Void {
    this.m_hasVisibilityForcedOnlyInFrustumInAnimSystem = isVisible;
  }

  public final func AddForcedVisiblityInAnimSystemRequest(data: ref<ForcedVisibilityInAnimSystemData>) -> Void {
    if !this.HasForcedVisiblityInAnimSystemRequest(data.sourceName) {
      ArrayPush(this.m_forcedVisibilityInAnimSystemRequests, data);
    };
  }

  public final func RemoveForcedVisiblityInAnimSystemRequest(data: ref<ForcedVisibilityInAnimSystemData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_forcedVisibilityInAnimSystemRequests[i].sourceName, data.sourceName) {
        this.m_forcedVisibilityInAnimSystemRequests[i] = null;
        ArrayErase(this.m_forcedVisibilityInAnimSystemRequests, i);
        return;
      };
      i += 1;
    };
  }

  public final func RemoveForcedVisiblityInAnimSystemRequest(sourceName: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_forcedVisibilityInAnimSystemRequests[i].sourceName, sourceName) {
        this.m_forcedVisibilityInAnimSystemRequests[i] = null;
        ArrayErase(this.m_forcedVisibilityInAnimSystemRequests, i);
        return;
      };
      i += 1;
    };
  }

  public final func HasForcedVisiblityInAnimSystemRequest(data: ref<ForcedVisibilityInAnimSystemData>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_forcedVisibilityInAnimSystemRequests[i].sourceName, data.sourceName) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func HasForcedVisiblityInAnimSystemRequest(sourceName: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_forcedVisibilityInAnimSystemRequests[i].sourceName, sourceName) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func GetForcedVisiblityInAnimSystemRequest(sourceName: CName) -> ref<ForcedVisibilityInAnimSystemData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_forcedVisibilityInAnimSystemRequests[i].sourceName, sourceName) {
        return this.m_forcedVisibilityInAnimSystemRequests[i];
      };
      i += 1;
    };
    return null;
  }

  public final func HasDelayedForcedVisiblityInAnimSystemRequest(data: ref<ForcedVisibilityInAnimSystemData>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_delayedForcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_delayedForcedVisibilityInAnimSystemRequests[i].sourceName, data.sourceName) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func HasDelayedForcedVisiblityInAnimSystemRequest(sourceName: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_delayedForcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_delayedForcedVisibilityInAnimSystemRequests[i].sourceName, sourceName) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func GetDelayedForcedVisiblityInAnimSystemRequest(sourceName: CName) -> ref<ForcedVisibilityInAnimSystemData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_delayedForcedVisibilityInAnimSystemRequests) {
      if Equals(this.m_delayedForcedVisibilityInAnimSystemRequests[i].sourceName, sourceName) {
        return this.m_delayedForcedVisibilityInAnimSystemRequests[i];
      };
      i += 1;
    };
    return null;
  }

  public final func RemoveDelayedForcedVisiblityInAnimSystemRequest(data: ref<ForcedVisibilityInAnimSystemData>) -> Void {
    if data == null {
      return;
    };
    ArrayRemove(this.m_delayedForcedVisibilityInAnimSystemRequests, data);
    data = null;
  }

  public final func AddDelayedForcedVisiblityInAnimSystemRequest(data: ref<ForcedVisibilityInAnimSystemData>) -> Void {
    if !this.HasDelayedForcedVisiblityInAnimSystemRequest(data) {
      ArrayPush(this.m_delayedForcedVisibilityInAnimSystemRequests, data);
    };
  }
}

public class AnimationSystemForcedVisibilityManager extends ScriptableSystem {

  private let m_entities: array<ref<AnimationSystemForcedVisibilityEntityData>>;

  private final func ClearEntity(id: EntityID) -> Void {
    let entityData: ref<AnimationSystemForcedVisibilityEntityData> = this.GetEntityData(id);
    if entityData != null {
      entityData.ClearAllRequests();
      this.ResovleVisibilityInAnimSystem(entityData);
    };
  }

  protected final func ToggleForcedVisibilityInAnimSystem(entityID: EntityID, sourceName: CName, isVisible: Bool, opt transitionTime: Float, opt forcedVisibleOnlyInFrustum: Bool) -> Void {
    let visibilityData: ref<ForcedVisibilityInAnimSystemData>;
    let entityData: ref<AnimationSystemForcedVisibilityEntityData> = this.GetEntityData(entityID);
    if !isVisible && entityData == null {
      return;
    };
    if entityData == null {
      entityData = new AnimationSystemForcedVisibilityEntityData();
      entityData.Initialize(entityID, this);
      ArrayPush(this.m_entities, entityData);
    };
    visibilityData = entityData.GetDelayedForcedVisiblityInAnimSystemRequest(sourceName);
    if IsDefined(visibilityData) {
      this.CancelDelayedRequestForVisilityData(visibilityData);
      entityData.RemoveDelayedForcedVisiblityInAnimSystemRequest(visibilityData);
    };
    if transitionTime > 0.00 {
      visibilityData = new ForcedVisibilityInAnimSystemData();
      visibilityData.sourceName = sourceName;
      visibilityData.forcedVisibleOnlyInFrustum = forcedVisibleOnlyInFrustum;
      this.SendDelayedRequestForVisilityData(entityID, isVisible, transitionTime, visibilityData);
      entityData.AddDelayedForcedVisiblityInAnimSystemRequest(visibilityData);
    } else {
      if isVisible {
        visibilityData = new ForcedVisibilityInAnimSystemData();
        visibilityData.sourceName = sourceName;
        visibilityData.forcedVisibleOnlyInFrustum = forcedVisibleOnlyInFrustum;
        entityData.AddForcedVisiblityInAnimSystemRequest(visibilityData);
      } else {
        entityData.RemoveForcedVisiblityInAnimSystemRequest(sourceName);
      };
    };
    this.ResovleVisibilityInAnimSystem(entityData);
  }

  private final func SendDelayedRequestForVisilityData(entityID: EntityID, isVisible: Bool, transitionTime: Float, data: ref<ForcedVisibilityInAnimSystemData>) -> Void {
    let request: ref<DelayedVisibilityInAnimSystemRequest> = new DelayedVisibilityInAnimSystemRequest();
    request.isVisible = isVisible;
    request.data = data;
    request.entityID = entityID;
    data.delayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"AnimationSystemForcedVisibilityManager", request, transitionTime, false);
  }

  private final func CancelDelayedRequestForVisilityData(data: ref<ForcedVisibilityInAnimSystemData>) -> Void {
    let invalidDelayID: DelayID;
    if data == null {
      return;
    };
    if data.delayID != invalidDelayID {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(data.delayID);
    };
  }

  protected final func ResovleVisibilityInAnimSystem(entityData: ref<AnimationSystemForcedVisibilityEntityData>) -> Void {
    if entityData == null {
      return;
    };
    if entityData.HasActiveRequestsForForcedVisibilityOnlyInFrustumInAnimSystem() {
      if !entityData.HasVisibilityForcedOnlyInFrustumInAnimSystem() {
        GameInstance.GetAnimationSystem(this.GetGameInstance()).SetForcedVisibleOnlyInFrustum(entityData.GetEntityID(), true);
        entityData.SetHasVisibilityForcedOnlyInFrustumInAnimSystem(true);
      };
    } else {
      if entityData.HasActiveRequestsForForcedVisibilityOnlyInFrustumInAnimSystem() {
        GameInstance.GetAnimationSystem(this.GetGameInstance()).SetForcedVisibleOnlyInFrustum(entityData.GetEntityID(), false);
        entityData.SetHasVisibilityForcedOnlyInFrustumInAnimSystem(false);
      };
    };
    if entityData.HasActiveRequestsForForcedVisibilityInAnimSystem() {
      if !entityData.HasVisibilityForcedInAnimSystem() {
        GameInstance.GetAnimationSystem(this.GetGameInstance()).SetForcedVisible(entityData.GetEntityID(), true);
        entityData.SetHasVisibilityForcedInAnimSystem(true);
      };
    } else {
      if entityData.HasVisibilityForcedInAnimSystem() {
        GameInstance.GetAnimationSystem(this.GetGameInstance()).SetForcedVisible(entityData.GetEntityID(), false);
        entityData.SetHasVisibilityForcedInAnimSystem(false);
      };
      ArrayRemove(this.m_entities, entityData);
    };
  }

  private final func GetEntityData(id: EntityID) -> ref<AnimationSystemForcedVisibilityEntityData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_entities) {
      if this.m_entities[i].GetEntityID() == id {
        return this.m_entities[i];
      };
      i += 1;
    };
    return null;
  }

  private final func IsEntityRegistered(id: EntityID) -> Bool {
    return this.GetEntityData(id) != null;
  }

  private final func OnToggleVisibilityInAnimSystemRequest(request: ref<ToggleVisibilityInAnimSystemRequest>) -> Void {
    this.ToggleForcedVisibilityInAnimSystem(request.entityID, request.sourceName, request.isVisible, request.transitionTime, request.forcedVisibleOnlyInFrustum);
  }

  private final func OnClearVisibilityInAnimSystemRequest(request: ref<ClearVisibilityInAnimSystemRequest>) -> Void {
    this.ClearEntity(request.entityID);
  }

  protected final func OnHandleDelayedVisibilityInAnimSystemRequest(request: ref<DelayedVisibilityInAnimSystemRequest>) -> Void {
    let invalidID: DelayID;
    if request.data == null {
      return;
    };
    request.data.delayID = invalidID;
    this.ToggleForcedVisibilityInAnimSystem(request.entityID, request.data.sourceName, request.isVisible);
  }

  public final const func HasVisibilityForced(id: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_entities) {
      if this.m_entities[i].GetEntityID() == id {
        return true;
      };
      i += 1;
    };
    return false;
  }
}
