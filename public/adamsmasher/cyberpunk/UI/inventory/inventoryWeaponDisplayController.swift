
public class InventoryWeaponDisplayController extends InventoryItemDisplayController {

  protected edit let m_weaponSpecyficModsRoot: inkCompoundRef;

  protected edit let m_statsWrapper: inkWidgetRef;

  protected edit let m_dpsText: inkTextRef;

  protected edit let m_damageTypeIndicatorImage: inkImageRef;

  protected edit let m_dpsWrapper: inkWidgetRef;

  protected edit let m_dpsValue: inkTextRef;

  protected edit let m_silencerIcon: inkWidgetRef;

  protected edit let m_scopeIcon: inkWidgetRef;

  protected let weaponAttachmentsDisplay: array<wref<InventoryItemPartDisplay>>;

  protected func RefreshUI() -> Void {
    this.RefreshUI();
    this.UpdateDamage();
    this.UpdateWeaponParts();
  }

  protected func UpdateWeaponParts() -> Void {
    let attachment: InventoryItemAttachments;
    let hasScopeSlot: Bool;
    let hasSilencerSlot: Bool;
    let scopeAttachment: InventoryItemAttachments;
    let silencerAttachment: InventoryItemAttachments;
    let itemData: InventoryItemData = this.GetItemData();
    let attachmentsSize: Int32 = InventoryItemData.GetAttachmentsSize(itemData);
    let i: Int32 = 0;
    while i < attachmentsSize {
      attachment = InventoryItemData.GetAttachment(itemData, i);
      if attachment.SlotID == t"AttachmentSlots.Scope" {
        scopeAttachment = attachment;
        hasScopeSlot = true;
      } else {
        if attachment.SlotID == t"AttachmentSlots.PowerModule" {
          silencerAttachment = attachment;
          hasSilencerSlot = true;
        };
      };
      i += 1;
    };
    inkWidgetRef.SetVisible(this.m_scopeIcon, hasScopeSlot);
    inkWidgetRef.SetState(this.m_scopeIcon, InventoryItemData.IsEmpty(scopeAttachment.ItemData) ? n"Empty" : n"Default");
    inkWidgetRef.SetVisible(this.m_silencerIcon, hasSilencerSlot);
    inkWidgetRef.SetState(this.m_silencerIcon, InventoryItemData.IsEmpty(silencerAttachment.ItemData) ? n"Empty" : n"Default");
  }

  protected func UpdateDamage() -> Void {
    let dpsValue: Float;
    let data: InventoryItemData = this.GetItemData();
    inkWidgetRef.SetVisible(this.m_statsWrapper, !InventoryItemData.IsEmpty(data));
    dpsValue = this.GetDPS(data);
    inkTextRef.SetText(this.m_dpsText, FloatToStringPrec(dpsValue, 1));
    inkImageRef.SetTexturePart(this.m_damageTypeIndicatorImage, WeaponsUtils.GetDamageTypeIcon(InventoryItemData.GetDamageType(data)));
    if InventoryItemData.IsEmpty(data) {
      inkWidgetRef.SetVisible(this.m_dpsWrapper, false);
      return;
    };
    if Equals(this.GetDisplayContext(), ItemDisplayContext.GearPanel) {
      inkWidgetRef.SetVisible(this.m_dpsWrapper, true);
      inkTextRef.SetText(this.m_dpsValue, IntToString(RoundF(dpsValue)));
    } else {
      inkWidgetRef.SetVisible(this.m_dpsWrapper, false);
    };
  }

  protected func GetDPS(itemData: InventoryItemData) -> Float {
    let i: Int32;
    let limit: Int32;
    let stat: StatViewData;
    if !InventoryItemData.IsEmpty(itemData) {
      i = 0;
      limit = InventoryItemData.GetPrimaryStatsSize(itemData);
      while i < limit {
        stat = InventoryItemData.GetPrimaryStat(itemData, i);
        if Equals(stat.type, gamedataStatType.EffectiveDPS) {
          return stat.valueF;
        };
        i += 1;
      };
    };
    return 0.00;
  }

  public func GetDisplayType() -> ItemDisplayType {
    return ItemDisplayType.Weapon;
  }
}
