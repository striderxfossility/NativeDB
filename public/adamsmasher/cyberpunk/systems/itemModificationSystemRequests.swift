
public class InstallItemPart extends ScriptableSystemRequest {

  public let obj: wref<GameObject>;

  public let baseItem: ItemID;

  public let partToInstall: ItemID;

  public let slotID: TweakDBID;

  public final func Set(object: ref<GameObject>, item: ItemID, part: ItemID, placementSlotID: TweakDBID) -> Void {
    this.obj = object;
    this.baseItem = item;
    this.partToInstall = part;
    this.slotID = placementSlotID;
  }
}

public class RemoveItemPart extends ScriptableSystemRequest {

  public let obj: wref<GameObject>;

  public let baseItem: ItemID;

  public let slotToEmpty: TweakDBID;

  public final func Set(object: ref<GameObject>, item: ItemID, slot: TweakDBID) -> Void {
    this.obj = object;
    this.baseItem = item;
    this.slotToEmpty = slot;
  }
}

public class SwapItemPart extends ScriptableSystemRequest {

  public let obj: wref<GameObject>;

  public let baseItem: ItemID;

  public let partToInstall: ItemID;

  public let slotID: TweakDBID;

  public final func Set(object: ref<GameObject>, item: ItemID, part: ItemID, slot: TweakDBID) -> Void {
    this.obj = object;
    this.baseItem = item;
    this.partToInstall = part;
    this.slotID = slot;
  }
}
