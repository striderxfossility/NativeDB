
public class InventoryWeaponItemChooser extends InventoryGenericItemChooser {

  protected edit let m_scopeRootContainer: inkCompoundRef;

  protected edit let m_magazineRootContainer: inkCompoundRef;

  protected edit let m_silencerRootContainer: inkCompoundRef;

  protected edit let m_scopeContainer: inkCompoundRef;

  protected edit let m_magazineContainer: inkCompoundRef;

  protected edit let m_silencerContainer: inkCompoundRef;

  protected edit let m_attachmentsLabel: inkTextRef;

  protected edit let m_attachmentsContainer: inkWidgetRef;

  protected edit let m_softwareModsLabel: inkTextRef;

  protected edit let m_softwareModsPush: inkWidgetRef;

  protected edit let m_softwareModsContainer: inkWidgetRef;

  protected func GetSlots() -> array<InventoryItemAttachments> {
    return InventoryUtils.GetMods(this.itemDisplay.GetItemData(), true);
  }

  protected func RebuildSlots() -> Void {
    this.RebuildSlots();
    this.RebuildParts();
  }

  protected func ForceDisplayLabel() -> Bool {
    let itemParts: array<InventoryItemAttachments> = InventoryUtils.GetParts(this.itemDisplay.GetItemData());
    return ArraySize(itemParts) > 0;
  }

  private final func UpdateModsLabel(parts: array<InventoryItemAttachments>) -> Void {
    let hasMods: Bool = InventoryItemData.GetAttachmentsSize(this.itemDisplay.GetItemData()) - ArraySize(parts) > 0;
    let hasParts: Bool = ArraySize(parts) > 0;
    inkWidgetRef.SetVisible(this.m_attachmentsLabel, hasParts);
    inkWidgetRef.SetVisible(this.m_attachmentsContainer, hasParts);
    inkWidgetRef.SetVisible(this.m_softwareModsLabel, hasMods);
    inkWidgetRef.SetVisible(this.m_softwareModsContainer, hasMods);
    inkWidgetRef.SetVisible(this.m_softwareModsPush, hasParts);
  }

  private final func GetRootSlotContainerFromType(partType: WeaponPartType) -> inkCompoundRef {
    let emptyResult: inkCompoundRef;
    switch partType {
      case WeaponPartType.Silencer:
        return this.m_silencerRootContainer;
      case WeaponPartType.Magazine:
        return this.m_magazineRootContainer;
      case WeaponPartType.Scope:
        return this.m_scopeRootContainer;
    };
    return emptyResult;
  }

  private final func GetSlotContainerFromType(partType: WeaponPartType) -> inkCompoundRef {
    let emptyResult: inkCompoundRef;
    switch partType {
      case WeaponPartType.Silencer:
        return this.m_silencerContainer;
      case WeaponPartType.Magazine:
        return this.m_magazineContainer;
      case WeaponPartType.Scope:
        return this.m_scopeContainer;
    };
    return emptyResult;
  }

  private final func GetAtlasPartFromType(partType: WeaponPartType) -> CName {
    switch partType {
      case WeaponPartType.Silencer:
        return n"mod_silencer-1";
      case WeaponPartType.Magazine:
        return n"mod_magazine-1";
      case WeaponPartType.Scope:
        return n"mod_scope-1";
    };
    return n"item_grid_accent";
  }

  private final func GetAllPartsTypes() -> array<WeaponPartType> {
    let result: array<WeaponPartType>;
    ArrayPush(result, WeaponPartType.Silencer);
    ArrayPush(result, WeaponPartType.Magazine);
    ArrayPush(result, WeaponPartType.Scope);
    return result;
  }

  private final func GetPartDataByType(parts: array<InventoryItemAttachments>, type: WeaponPartType) -> InventoryItemAttachments {
    let emptyResult: InventoryItemAttachments;
    let i: Int32 = 0;
    while i < ArraySize(parts) {
      if Equals(InventoryUtils.GetPartType(parts[i]), type) {
        return parts[i];
      };
      i += 1;
    };
    return emptyResult;
  }

  protected func RebuildParts() -> Void {
    let i: Int32;
    let j: Int32;
    let part: InventoryItemAttachments;
    let slot: ref<InventoryItemDisplayController>;
    let slotContainer: inkCompoundRef;
    let slotRootContainer: inkCompoundRef;
    let inventoryItemData: InventoryItemData = this.itemDisplay.GetItemData();
    let itemData: wref<gameItemData> = InventoryItemData.GetGameItemData(inventoryItemData);
    let allParts: array<WeaponPartType> = this.GetAllPartsTypes();
    let itemParts: array<InventoryItemAttachments> = InventoryUtils.GetParts(inventoryItemData);
    this.UpdateModsLabel(itemParts);
    i = 0;
    while i < ArraySize(allParts) {
      slot = null;
      part = this.GetPartDataByType(itemParts, allParts[i]);
      slotRootContainer = this.GetRootSlotContainerFromType(allParts[i]);
      slotContainer = this.GetSlotContainerFromType(allParts[i]);
      if TDBID.IsValid(part.SlotID) {
        inkWidgetRef.SetVisible(slotRootContainer, true);
        j = 0;
        while j < inkCompoundRef.GetNumChildren(slotContainer) {
          if IsDefined(inkCompoundRef.GetWidgetByIndex(slotContainer, j).GetController() as InventoryItemDisplayController) {
            slot = inkCompoundRef.GetWidgetByIndex(slotContainer, j).GetController() as InventoryItemDisplayController;
          };
          j += 1;
        };
        if !IsDefined(slot) {
          slot = ItemDisplayUtils.SpawnCommonSlotController(this, slotContainer, this.GetSlotDisplayToSpawn()) as InventoryItemDisplayController;
          slot.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnItemInventoryClick");
          slot.GetRootWidget().RegisterToCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
          slot.GetRootWidget().RegisterToCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
        };
        slot.SetDefaultShadowIcon(this.GetAtlasPartFromType(allParts[i]));
        slot.SetParentItem(itemData);
        slot.Setup(this.inventoryDataManager, part.ItemData, part.SlotID, ItemDisplayContext.Attachment, true);
      } else {
        inkWidgetRef.SetVisible(slotRootContainer, false);
      };
      i += 1;
    };
  }

  protected func GetDisplayToSpawn() -> CName {
    return n"weaponDisplay";
  }

  protected func GetIntroAnimation() -> CName {
    return n"weaponItemChoser_intro";
  }
}
