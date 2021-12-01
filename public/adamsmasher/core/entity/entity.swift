
public native class Entity extends IScriptable {

  public final native const func GetEntity() -> EntityGameInterface;

  public final native func QueueEvent(evt: ref<Event>) -> Void;

  public final native const func GetEntityID() -> EntityID;

  public final native func QueueEventForNodeID(nodeID: GlobalNodeRef, evt: ref<Event>) -> Bool;

  public final native func QueueEventForEntityID(entityID: EntityID, evt: ref<Event>) -> Bool;

  public final native const func CanServiceEvent(evtName: CName) -> Bool;

  public final native const func IsReplicated() -> Bool;

  public final native const func GetControllingPeerID() -> Uint32;

  public final native const func MatchVisualTag(visualTag: CName) -> Bool;

  public final native const func MatchVisualTags(visualTags: array<CName>) -> Bool;

  public final native const func IsControlledByAnyPeer() -> Bool;

  public final native const func IsControlledByLocalPeer() -> Bool;

  public final native const func IsControlledByAnotherClient() -> Bool;

  public native const func IsAttached() -> Bool;

  protected final native const func FindComponentByName(componentName: CName) -> ref<IComponent>;

  public final native func PrefetchAppearanceChange(newAppearanceName: CName) -> Void;

  public final native func ScheduleAppearanceChange(newAppearanceName: CName) -> Void;

  public final native const func GetCurrentAppearanceName() -> CName;

  public func OnInspectorDebugDraw(out box: ref<InfoBox>) -> Void;

  public final native const func GetWorldPosition() -> Vector4;

  public final native const func GetWorldOrientation() -> Quaternion;

  public final native const func GetWorldYaw() -> Float;

  public final native const func GetWorldForward() -> Vector4;

  public final native const func GetWorldRight() -> Vector4;

  public final native const func GetWorldUp() -> Vector4;

  public final const func GetWorldTransform() -> WorldTransform {
    let worldPosition: WorldPosition;
    let worldTransform: WorldTransform;
    WorldPosition.SetVector4(worldPosition, this.GetWorldPosition());
    WorldTransform.SetWorldPosition(worldTransform, worldPosition);
    WorldTransform.SetOrientation(worldTransform, this.GetWorldOrientation());
    return worldTransform;
  }
}
