
public class InventoryItemDisplay extends BaseButtonView {

  protected edit let m_RarityRoot: inkWidgetRef;

  protected edit let m_ModsRoot: inkCompoundRef;

  protected edit let m_RarityWrapper: inkWidgetRef;

  protected edit let m_IconImage: inkImageRef;

  protected edit let m_IconShadowImage: inkImageRef;

  protected edit let m_IconFallback: inkImageRef;

  protected edit let m_BackgroundShape: inkImageRef;

  protected edit let m_BackgroundHighlight: inkImageRef;

  protected edit let m_BackgroundFrame: inkImageRef;

  protected edit let m_QuantityText: inkTextRef;

  protected edit let m_ModName: CName;

  protected edit let m_toggleHighlight: inkWidgetRef;

  protected edit let m_equippedIcon: inkWidgetRef;

  @default(InventoryItemDisplay, undefined)
  protected edit let m_DefaultCategoryIconName: String;

  protected let m_ItemData: InventoryItemData;

  protected let m_AttachementsDisplay: array<wref<InventoryItemAttachmentDisplay>>;

  protected let m_smallSize: Vector2;

  protected let m_bigSize: Vector2;

  private let owner: wref<GameObject>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.GetRootWidget().SetAnchor(inkEAnchor.TopLeft);
    this.m_smallSize.X = 174.00;
    this.m_smallSize.Y = 177.00;
    this.m_bigSize.X = 399.00;
    this.m_bigSize.Y = 177.00;
    if IsDefined(this.m_ButtonController) {
      this.m_ButtonController.RegisterToCallback(n"OnButtonClick", this, n"OnButtonClick");
    };
    this.RefreshUI();
    if inkWidgetRef.IsValid(this.m_toggleHighlight) {
      inkWidgetRef.SetVisible(this.m_toggleHighlight, false);
    };
  }

  public func Setup(itemData: InventoryItemData, opt ownerEntity: ref<Entity>) -> Void {
    this.owner = ownerEntity as GameObject;
    if InventoryItemData.GetID(this.m_ItemData) != InventoryItemData.GetID(itemData) || InventoryItemData.GetQuantity(this.m_ItemData) != InventoryItemData.GetQuantity(itemData) {
      this.m_ItemData = itemData;
      this.RefreshUI();
    };
  }

  protected func RefreshUI() -> Void {
    this.SetItemSize();
    this.SetRarity(InventoryItemData.GetQuality(this.m_ItemData));
    this.SetQuantity(InventoryItemData.GetQuantity(this.m_ItemData));
    this.SetShape(InventoryItemData.GetItemShape(this.m_ItemData));
    this.ShowMods(InventoryItemData.GetAttachments(this.m_ItemData));
    this.SetEquippedState(InventoryItemData.IsEquipped(this.m_ItemData));
    this.UpdateIcon();
  }

  protected func SetItemSize() -> Void {
    let area: gamedataEquipmentArea = InventoryItemData.GetEquipmentArea(this.m_ItemData);
    if Equals(area, gamedataEquipmentArea.Weapon) || Equals(area, gamedataEquipmentArea.SystemReplacementCW) || Equals(area, gamedataEquipmentArea.ArmsCW) || Equals(area, gamedataEquipmentArea.HandsCW) {
      InventoryItemData.SetItemShape(this.m_ItemData, EInventoryItemShape.DoubleSlot);
    };
  }

  protected func SetRarity(quality: CName) -> Void {
    inkWidgetRef.SetState(this.m_RarityRoot, quality);
    if Equals(quality, n"") {
      inkWidgetRef.SetVisible(this.m_RarityWrapper, false);
    } else {
      inkWidgetRef.SetVisible(this.m_RarityWrapper, true);
    };
  }

  protected func SetQuantity(itemQuantity: Int32) -> Void {
    let ammoQuery: ItemID;
    let category: gamedataItemCategory;
    let itemRecord: ref<Item_Record>;
    let transSystem: ref<TransactionSystem>;
    let weaponRecord: ref<WeaponItem_Record>;
    let ammoCount: Int32 = 0;
    if this.owner != null {
      transSystem = GameInstance.GetTransactionSystem(this.owner.GetGame());
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_ItemData)));
      category = itemRecord.ItemCategory().Type();
      if Equals(category, gamedataItemCategory.Weapon) {
        weaponRecord = itemRecord as WeaponItem_Record;
        ammoQuery = ItemID.CreateQuery(weaponRecord.Ammo().GetID());
        ammoCount = transSystem.GetItemQuantity(this.owner, ammoQuery);
      };
    };
    if itemQuantity > 1 || Equals(InventoryItemData.GetItemType(this.m_ItemData), gamedataItemType.Con_Ammo) {
      inkTextRef.SetText(this.m_QuantityText, "x" + IntToString(itemQuantity));
      inkWidgetRef.SetVisible(this.m_QuantityText, true);
    } else {
      inkWidgetRef.SetVisible(this.m_QuantityText, false);
    };
    if ammoCount > 0 {
      inkTextRef.SetText(this.m_QuantityText, GetLocalizedText("UI-ScriptExports-Ammo0") + ": " + IntToString(ammoCount));
      inkWidgetRef.SetVisible(this.m_QuantityText, true);
    };
  }

  protected func GetShapeSize(shapeType: EInventoryItemShape) -> Vector2 {
    let newSize: Vector2;
    switch shapeType {
      case EInventoryItemShape.SingleSlot:
        newSize = this.m_smallSize;
        break;
      case EInventoryItemShape.DoubleSlot:
        newSize = this.m_bigSize;
    };
    return newSize;
  }

  protected func SetShape(shapeType: EInventoryItemShape) -> Void {
    let newSize: Vector2 = this.GetShapeSize(shapeType);
    inkWidgetRef.SetSize(this.m_BackgroundShape, newSize);
    inkWidgetRef.SetSize(this.m_BackgroundHighlight, newSize);
    inkWidgetRef.SetSize(this.m_BackgroundFrame, newSize);
    if inkWidgetRef.IsValid(this.m_toggleHighlight) {
      inkWidgetRef.SetSize(this.m_toggleHighlight, newSize);
    };
    if InventoryItemData.IsEmpty(this.m_ItemData) {
      inkImageRef.SetTexturePart(this.m_BackgroundFrame, n"item_grid_frame");
    } else {
      inkImageRef.SetTexturePart(this.m_BackgroundFrame, n"item_frame");
    };
  }

  protected func UpdateIcon() -> Void {
    let categoryName: CName;
    let iconName: CName;
    if InventoryItemData.IsEmpty(this.m_ItemData) {
      inkWidgetRef.SetVisible(this.m_IconImage, false);
      inkWidgetRef.SetVisible(this.m_IconFallback, false);
      return;
    };
    iconName = StringToName(InventoryItemData.GetIconPath(this.m_ItemData));
    if !IsStringValid(InventoryItemData.GetIconPath(this.m_ItemData)) || !inkImageRef.IsTexturePartExist(this.m_IconImage, iconName) {
      inkWidgetRef.SetVisible(this.m_IconImage, false);
      inkWidgetRef.SetVisible(this.m_IconFallback, true);
      categoryName = StringToName(InventoryItemData.GetCategoryName(this.m_ItemData));
      if inkImageRef.IsTexturePartExist(this.m_IconFallback, categoryName) {
        inkImageRef.SetTexturePart(this.m_IconFallback, categoryName);
      } else {
        inkImageRef.SetTexturePart(this.m_IconFallback, StringToName(this.m_DefaultCategoryIconName));
      };
    } else {
      inkWidgetRef.SetVisible(this.m_IconFallback, false);
      inkWidgetRef.SetVisible(this.m_IconImage, true);
      inkImageRef.SetTexturePart(this.m_IconImage, StringToName(InventoryItemData.GetIconPath(this.m_ItemData)));
    };
  }

  protected func ShowMods(attachements: array<InventoryItemAttachments>) -> Void {
    let count: Int32;
    let currentItem: wref<InventoryItemAttachmentDisplay>;
    let i: Int32;
    if !inkWidgetRef.IsValid(this.m_ModsRoot) || !IsNameValid(this.m_ModName) {
      return;
    };
    count = ArraySize(attachements);
    while ArraySize(this.m_AttachementsDisplay) > count {
      currentItem = ArrayPop(this.m_AttachementsDisplay);
      inkCompoundRef.RemoveChild(this.m_ModsRoot, currentItem.GetRootWidget());
    };
    while ArraySize(this.m_AttachementsDisplay) < count {
      currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_ModsRoot), this.m_ModName).GetController() as InventoryItemAttachmentDisplay;
      ArrayPush(this.m_AttachementsDisplay, currentItem);
    };
    i = 0;
    while i < count {
      this.m_AttachementsDisplay[i].Setup(attachements[i].ItemData);
      i += 1;
    };
  }

  public final func SetEquippedState(equipped: Bool) -> Void {
    if inkWidgetRef.IsValid(this.m_equippedIcon) {
      if equipped {
        inkWidgetRef.SetVisible(this.m_equippedIcon, true);
      } else {
        inkWidgetRef.SetVisible(this.m_equippedIcon, false);
      };
    };
  }

  public final func SelectItem() -> Void {
    if inkWidgetRef.IsValid(this.m_toggleHighlight) {
      inkWidgetRef.SetVisible(this.m_toggleHighlight, true);
      InventoryItemData.SetIsAvailable(this.m_ItemData, false);
    };
  }

  public final func UnselectItem() -> Void {
    if inkWidgetRef.IsValid(this.m_toggleHighlight) {
      inkWidgetRef.SetVisible(this.m_toggleHighlight, false);
      InventoryItemData.SetIsAvailable(this.m_ItemData, true);
    };
  }

  protected func ButtonStateChanged(oldState: inkEButtonState, newState: inkEButtonState) -> Void {
    if Equals(newState, inkEButtonState.Hover) {
      this.CallCustomCallback(n"OnRequestTooltip");
      this.CallCustomCallback(n"OnItemHoverOver");
    } else {
      if Equals(newState, inkEButtonState.Normal) {
        this.CallCustomCallback(n"OnDismissTooltip");
        this.CallCustomCallback(n"OnItemHoverOut");
      };
    };
  }

  protected cb func OnButtonClick(controller: wref<inkButtonController>) -> Bool {
    this.CallCustomCallback(n"OnClick");
  }

  public final func Mark(index: Int32) -> Void {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_AttachementsDisplay);
    while i < limit {
      this.m_AttachementsDisplay[i].Mark(index == i);
      i += 1;
    };
  }

  public final func PlayIntroAnimation(delay: Float, duration: Float) -> Void;

  public final func GetItemData() -> InventoryItemData {
    return this.m_ItemData;
  }

  public final func GetWidgetForTooltip() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_RarityRoot);
  }
}

public class InventoryItemModSlotDisplay extends inkLogicController {

  private edit let m_slotBorder: inkWidgetRef;

  private edit let m_slotBackground: inkWidgetRef;

  public final func Setup(itemData: InventoryItemData) -> Void {
    let quality: CName;
    let isEmpty: Bool = InventoryItemData.IsEmpty(itemData);
    inkWidgetRef.SetVisible(this.m_slotBackground, !isEmpty);
    inkWidgetRef.SetVisible(this.m_slotBorder, isEmpty);
    quality = InventoryItemData.GetQuality(itemData);
    inkWidgetRef.SetState(this.m_slotBackground, IsNameValid(quality) ? quality : n"Empty");
  }
}

public class InventoryItemAttachmentDisplay extends inkLogicController {

  private edit let m_QualityRootRef: inkWidgetRef;

  private edit let m_ShapeRef: inkWidgetRef;

  private edit let m_BorderRef: inkWidgetRef;

  @default(InventoryItemAttachmentDisplay, Marked)
  private edit let m_MarkedStateName: CName;

  public final func Setup(itemData: InventoryItemData) -> Void {
    this.Setup(!InventoryItemData.IsEmpty(itemData), InventoryItemData.GetQuality(itemData));
  }

  public final func Setup(visible: Bool, quality: CName) -> Void {
    inkWidgetRef.SetVisible(this.m_ShapeRef, visible);
    if inkWidgetRef.IsValid(this.m_QualityRootRef) {
      inkWidgetRef.SetState(this.m_QualityRootRef, quality);
    };
    this.Mark(visible);
  }

  public final func Mark(marked: Bool) -> Void {
    let stateName: CName = marked ? this.m_MarkedStateName : inkWidget.DefaultState();
    inkWidgetRef.SetState(this.m_ShapeRef, stateName);
  }
}
