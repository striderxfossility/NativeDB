
public native class AttachmentSlotsScriptCallback extends IScriptable {

  public native let slotID: TweakDBID;

  public native let itemID: ItemID;

  public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void;

  public func OnItemUnequipped(slot: TweakDBID, item: ItemID) -> Void;

  public func OnAttachmentRefreshed(slot: TweakDBID, item: ItemID) -> Void;
}
