
public class InventoryItemPartDisplay extends inkLogicController {

  protected edit let m_PartIconImage: inkImageRef;

  protected edit let m_Rarity: inkWidgetRef;

  protected edit let m_TexturePartName: CName;

  protected let attachmentData: InventoryItemAttachments;

  public final func Setup(attachmentDataArg: InventoryItemAttachments) -> Void {
    this.attachmentData = attachmentDataArg;
    this.UpdateTexture();
    this.UpdateMounted();
    this.SetRarity();
  }

  public final static func GetCorrespondingTexturePartName(weaponPartType: WeaponPartType) -> CName {
    switch weaponPartType {
      case WeaponPartType.Silencer:
        return n"mod_silencer";
      case WeaponPartType.Magazine:
        return n"mod_magazine";
      case WeaponPartType.Scope:
        return n"mod_scope";
    };
    return n"mod_scope";
  }

  protected final func UpdateTexture() -> Void {
    inkImageRef.SetTexturePart(this.m_PartIconImage, InventoryItemPartDisplay.GetCorrespondingTexturePartName(InventoryUtils.GetPartType(this.attachmentData)));
  }

  protected final func UpdateMounted() -> Void {
    if !InventoryItemData.IsEmpty(this.attachmentData.ItemData) {
      this.GetRootWidget().SetState(n"Mounted");
    } else {
      this.GetRootWidget().SetState(n"Default");
    };
  }

  protected final func SetRarity() -> Void {
    inkWidgetRef.SetState(this.m_Rarity, InventoryItemData.GetQuality(this.attachmentData.ItemData));
  }
}
