
public class ShardCaseContainer extends ContainerObjectSingleItem {

  public let m_wasOpened: Bool;

  public let m_shardMesh: ref<MeshComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"shard", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"gameVisionModeComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scanning", n"gameScanningComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_shardMesh = EntityResolveComponentsInterface.GetComponent(ri, n"shard") as MeshComponent;
    this.m_visionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision") as VisionModeComponent;
    this.m_scanningComponent = EntityResolveComponentsInterface.GetComponent(ri, n"scanning") as ScanningComponent;
  }

  protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let evt: ref<ShardCaseAnimationEnded>;
    let lootActionWrapper: LootChoiceActionWrapper = LootChoiceActionWrapper.Unwrap(choiceEvent);
    if LootChoiceActionWrapper.IsValid(lootActionWrapper) {
      if !this.m_wasOpened {
        this.OpenContainerWithTransformAnimation();
        this.m_wasOpened = true;
      };
      if NotEquals(lootActionWrapper.action, n"Take") {
        evt = new ShardCaseAnimationEnded();
        evt.activator = choiceEvent.activator;
        evt.item = lootActionWrapper.itemId;
        if Equals(lootActionWrapper.action, n"Read") {
          evt.read = true;
        };
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.55);
      };
    };
  }

  protected cb func OnShardCaseAnimationEnded(evt: ref<ShardCaseAnimationEnded>) -> Bool {
    this.m_shardMesh.Toggle(false);
    if evt.read {
      ItemActionsHelper.ReadItem(evt.activator, evt.item);
    };
  }

  public const func IsShardContainer() -> Bool {
    return true;
  }
}
