
public class InventoryUtils extends IScriptable {

  public final static func IsPart(attachmentSlotID: TweakDBID) -> Bool {
    return attachmentSlotID == t"AttachmentSlots.PowerModule" || attachmentSlotID == t"AttachmentSlots.Magazine" || attachmentSlotID == t"AttachmentSlots.Scope";
  }

  public final static func GetMods(itemData: InventoryItemData, opt onlyGeneric: Bool) -> array<InventoryItemAttachments> {
    let attachments: InventoryItemAttachments;
    let resultMods: array<InventoryItemAttachments>;
    let allModsSize: Int32 = InventoryItemData.GetAttachmentsSize(itemData);
    let i: Int32 = 0;
    while i < allModsSize {
      attachments = InventoryItemData.GetAttachment(itemData, i);
      if !InventoryUtils.IsPart(attachments.SlotID) {
        if onlyGeneric {
          if NotEquals(attachments.SlotType, InventoryItemAttachmentType.Generic) {
          } else {
            ArrayPush(resultMods, attachments);
          };
        };
        ArrayPush(resultMods, attachments);
      };
      i += 1;
    };
    return resultMods;
  }

  public final static func GetParts(itemData: InventoryItemData) -> array<InventoryItemAttachments> {
    let attachments: InventoryItemAttachments;
    let resultParts: array<InventoryItemAttachments>;
    let allModsSize: Int32 = InventoryItemData.GetAttachmentsSize(itemData);
    let i: Int32 = 0;
    while i < allModsSize {
      attachments = InventoryItemData.GetAttachment(itemData, i);
      if InventoryUtils.IsPart(attachments.SlotID) {
        ArrayPush(resultParts, attachments);
      };
      i += 1;
    };
    return resultParts;
  }

  public final static func GetPartType(attachmentData: InventoryItemAttachments) -> WeaponPartType {
    switch attachmentData.SlotID {
      case t"AttachmentSlots.PowerModule":
        return WeaponPartType.Silencer;
      case t"AttachmentSlots.Magazine":
        return WeaponPartType.Magazine;
      case t"AttachmentSlots.Scope":
        return WeaponPartType.Scope;
    };
    return WeaponPartType.Scope;
  }
}
