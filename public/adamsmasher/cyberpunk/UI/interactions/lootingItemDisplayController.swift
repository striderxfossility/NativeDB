
public class LootingListItemController extends inkLogicController {

  protected edit let m_widgetWrapper: inkWidgetRef;

  protected edit let m_itemName: inkTextRef;

  protected edit let m_itemRarity: inkWidgetRef;

  protected edit let m_iconicLines: inkWidgetRef;

  protected edit let m_itemQuantity: inkTextRef;

  protected edit let m_defaultIcon: inkWidgetRef;

  protected edit let m_specialIcon: inkImageRef;

  protected edit let m_comparisionArrow: inkImageRef;

  protected edit let m_itemTypeIconWrapper: inkWidgetRef;

  protected edit let m_itemTypeIcon: inkImageRef;

  protected edit const let m_highlightFrames: array<inkWidgetRef>;

  protected let m_tooltipData: ref<InventoryTooltipData>;

  protected let m_lootingData: ref<MinimalLootingListItemData>;

  protected cb func OnInitialize() -> Bool;

  public final func SetData(tooltipData: ref<ATooltipData>) -> Void {
    this.Setup(tooltipData as InventoryTooltipData, true);
  }

  public final func SetData(tooltipData: ref<ATooltipData>, isSelected: Bool) -> Void {
    this.Setup(tooltipData as InventoryTooltipData);
    this.SetHighlighted(isSelected);
  }

  protected func GetDPSDiff(tooltipData: ref<InventoryTooltipData>) -> Float {
    let i: Int32 = 0;
    while i < ArraySize(tooltipData.primaryStats) {
      if Equals(tooltipData.primaryStats[i].statType, gamedataStatType.EffectiveDPS) {
        return tooltipData.primaryStats[i].diffValueF;
      };
      i += 1;
    };
    return 0.00;
  }

  protected func GetArmorDiff(tooltipData: ref<InventoryTooltipData>) -> Float {
    let i: Int32 = 0;
    while i < ArraySize(tooltipData.primaryStats) {
      if Equals(tooltipData.primaryStats[i].statType, gamedataStatType.Armor) {
        return tooltipData.primaryStats[i].diffValueF;
      };
      i += 1;
    };
    return 0.00;
  }

  public func Setup(tooltipData: ref<InventoryTooltipData>, opt force: Bool) -> Void {
    let itemData: InventoryItemData;
    if this.m_tooltipData != tooltipData || force {
      itemData = tooltipData.inventoryItemData;
      this.m_tooltipData = tooltipData;
      this.m_lootingData = new MinimalLootingListItemData();
      this.m_lootingData.gameItemData = InventoryItemData.GetGameItemData(itemData);
      if ItemID.IsValid(this.m_tooltipData.itemID) {
        this.m_lootingData.itemName = this.m_tooltipData.itemName;
      } else {
        this.m_lootingData.itemName = InventoryItemData.GetName(itemData);
      };
      this.m_lootingData.itemType = InventoryItemData.GetItemType(itemData);
      this.m_lootingData.equipmentArea = InventoryItemData.GetEquipmentArea(itemData);
      this.m_lootingData.quality = RPGManager.GetItemDataQuality(this.m_lootingData.gameItemData);
      this.m_lootingData.isIconic = RPGManager.IsItemIconic(this.m_lootingData.gameItemData);
      this.m_lootingData.quantity = InventoryItemData.GetQuantity(itemData);
      this.m_lootingData.lootItemType = InventoryItemData.GetLootItemType(itemData);
      this.m_lootingData.dpsDiff = this.GetDPSDiff(this.m_tooltipData);
      this.m_lootingData.armorDiff = this.GetArmorDiff(this.m_tooltipData);
    };
    this.RefreshUI();
  }

  public func Setup(lootingData: ref<MinimalLootingListItemData>, opt force: Bool) -> Void {
    if this.m_lootingData != lootingData || force {
      this.m_lootingData = lootingData;
    };
    this.RefreshUI();
  }

  public final func SetData(data: ref<MinimalLootingListItemData>) -> Void {
    this.Setup(data, true);
  }

  public final func SetData(data: ref<MinimalLootingListItemData>, isSelected: Bool) -> Void {
    this.Setup(data);
    this.SetHighlighted(isSelected);
  }

  public final func GetTooltipData() -> ref<InventoryTooltipData> {
    return this.m_tooltipData;
  }

  protected func RefreshUI() -> Void {
    this.UpdateItemName();
    this.UpdateRarity();
    this.UpdateQuantity();
    this.UpdateLootIcon();
    this.UpdateIcon();
  }

  protected func UpdateIcon() -> Void {
    let iconName: CName = UIItemsHelper.GetLootingtShadowIcon(TDBID.undefined(), this.m_lootingData.itemType, this.m_lootingData.equipmentArea);
    if IsNameValid(iconName) && NotEquals(iconName, n"UIIcon.LootingShadow_Default") {
      inkWidgetRef.SetVisible(this.m_itemTypeIconWrapper, true);
      InkImageUtils.RequestSetImage(this, this.m_itemTypeIcon, iconName);
    } else {
      inkWidgetRef.SetVisible(this.m_itemTypeIconWrapper, false);
    };
  }

  protected func UpdateItemName() -> Void {
    if IsDefined(inkWidgetRef.Get(this.m_itemName)) {
      inkTextRef.SetText(this.m_itemName, this.m_lootingData.itemName);
    };
  }

  protected func UpdateRarity() -> Void {
    let qualityName: CName = UIItemsHelper.QualityEnumToName(this.m_lootingData.quality);
    inkWidgetRef.SetVisible(this.m_itemRarity, NotEquals(this.m_lootingData.quality, gamedataQuality.Invalid));
    inkWidgetRef.SetState(this.m_itemRarity, this.m_lootingData.isIconic ? n"Iconic" : qualityName);
    inkWidgetRef.SetVisible(this.m_iconicLines, this.m_lootingData.isIconic);
  }

  protected func UpdateQuantity() -> Void {
    let quantityText: String;
    let displayQuantityText: Bool = false;
    if IsDefined(this.m_lootingData) {
      if this.m_lootingData.quantity > 0 || Equals(this.m_lootingData.itemType, gamedataItemType.Con_Ammo) {
        quantityText = this.m_lootingData.quantity > 9999 ? "9999+" : IntToString(this.m_lootingData.quantity);
        inkTextRef.SetText(this.m_itemQuantity, quantityText);
        displayQuantityText = true;
      };
      if Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.Weapon) {
        displayQuantityText = false;
      };
    };
    inkWidgetRef.SetVisible(this.m_itemQuantity, displayQuantityText);
  }

  protected func UpdateLootIcon() -> Void {
    let diff: Float;
    if Equals(this.m_lootingData.lootItemType, LootItemType.Default) {
      inkWidgetRef.SetVisible(this.m_comparisionArrow, false);
      inkWidgetRef.SetVisible(this.m_defaultIcon, false);
      inkWidgetRef.SetVisible(this.m_specialIcon, false);
      if Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.Weapon) {
        diff = this.m_lootingData.dpsDiff;
      } else {
        if Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.Face) || Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.Feet) || Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.Head) || Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.InnerChest) || Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.Legs) || Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.OuterChest) || Equals(this.m_lootingData.equipmentArea, gamedataEquipmentArea.Outfit) {
          diff = this.m_lootingData.armorDiff;
        };
      };
      if diff > 0.01 {
        inkWidgetRef.SetVisible(this.m_comparisionArrow, true);
        inkWidgetRef.SetState(this.m_comparisionArrow, n"Better");
        inkWidgetRef.SetRotation(this.m_comparisionArrow, 0.00);
      } else {
        if diff < -0.01 {
          inkWidgetRef.SetVisible(this.m_comparisionArrow, true);
          inkWidgetRef.SetState(this.m_comparisionArrow, n"Worse");
          inkWidgetRef.SetRotation(this.m_comparisionArrow, 180.00);
        };
      };
    } else {
      inkWidgetRef.SetVisible(this.m_defaultIcon, false);
      inkWidgetRef.SetVisible(this.m_comparisionArrow, false);
      inkWidgetRef.SetVisible(this.m_specialIcon, true);
      if Equals(this.m_lootingData.lootItemType, LootItemType.Quest) {
        inkImageRef.SetTexturePart(this.m_specialIcon, n"quest");
      };
    };
  }

  public func SetHighlighted(value: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_highlightFrames) {
      inkWidgetRef.SetVisible(this.m_highlightFrames[i], value);
      i += 1;
    };
  }
}
