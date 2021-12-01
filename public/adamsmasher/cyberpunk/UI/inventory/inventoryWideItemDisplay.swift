
public class InventoryWideItemDisplay extends InventoryItemDisplay {

  protected edit let m_itemNameText: inkTextRef;

  protected edit let m_rarityBackground: inkWidgetRef;

  protected edit let m_iconWrapper: inkWidgetRef;

  protected edit let m_statsWrapper: inkWidgetRef;

  protected edit let m_dpsText: inkTextRef;

  protected edit let m_damageIndicatorRef: inkWidgetRef;

  protected edit let m_additionalInfoText: inkTextRef;

  protected let singleIconSize: Vector2;

  private let m_damageTypeIndicator: wref<DamageTypeIndicator>;

  protected let additionalInfoToShow: ItemAdditionalInfoType;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.singleIconSize = new Vector2(186.00, 166.00);
    this.m_smallSize.X = 540.00;
    this.m_smallSize.Y = 177.00;
    this.m_bigSize.X = this.m_smallSize.X * 2.00 + 64.00;
    this.m_bigSize.Y = 177.00;
    this.RefreshUI();
    this.m_damageTypeIndicator = inkWidgetRef.GetController(this.m_damageIndicatorRef) as DamageTypeIndicator;
  }

  public func SetAdditinalInfoType(infoType: ItemAdditionalInfoType) -> Void {
    this.additionalInfoToShow = infoType;
  }

  public func Setup(itemData: InventoryItemData, additionalInfo: ItemAdditionalInfoType) -> Void {
    this.Setup(itemData);
    this.SetAdditinalInfoType(additionalInfo);
    this.UpdateAdditionalInfo();
  }

  protected func GetPriceText() -> String {
    let price: String;
    let stackPrice: String;
    let vendorPrice: String;
    let vendorStackPrice: String;
    let euroDolarText: String = GetLocalizedText("Common-Characters-EuroDollar");
    if InventoryItemData.IsVendorItem(this.m_ItemData) {
      vendorPrice = RoundF(InventoryItemData.GetBuyPrice(this.m_ItemData)) + " " + euroDolarText;
      if InventoryItemData.GetQuantity(this.m_ItemData) > 1 {
        vendorStackPrice = RoundF(InventoryItemData.GetBuyPrice(this.m_ItemData)) * InventoryItemData.GetQuantity(this.m_ItemData) + " " + euroDolarText;
        return vendorStackPrice + " (" + vendorPrice + ")";
      };
      return vendorPrice;
    };
    price = RoundF(InventoryItemData.GetPrice(this.m_ItemData)) + " " + euroDolarText;
    if InventoryItemData.GetQuantity(this.m_ItemData) > 1 {
      stackPrice = RoundF(InventoryItemData.GetPrice(this.m_ItemData)) * InventoryItemData.GetQuantity(this.m_ItemData) + " " + euroDolarText;
      return stackPrice + " (" + price + ")";
    };
    return price;
  }

  protected func UpdateAdditionalInfo() -> Void {
    if Equals(this.additionalInfoToShow, ItemAdditionalInfoType.NONE) || InventoryItemData.IsEmpty(this.m_ItemData) {
      inkWidgetRef.SetVisible(this.m_additionalInfoText, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_additionalInfoText, true);
    switch this.additionalInfoToShow {
      case ItemAdditionalInfoType.PRICE:
        inkTextRef.SetText(this.m_additionalInfoText, this.GetPriceText());
        break;
      case ItemAdditionalInfoType.TYPE:
        inkTextRef.SetLocalizedTextScript(this.m_additionalInfoText, InventoryItemData.GetLocalizedItemType(this.m_ItemData));
    };
  }

  protected func RefreshUI() -> Void {
    this.RefreshUI();
    this.SetItemNameText();
    this.UpdateItemStats();
    this.UpdateAdditionalInfo();
  }

  protected func UpdateItemStats() -> Void {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_ItemData)));
    switch record.ItemCategory().Type() {
      case gamedataItemCategory.Weapon:
        inkTextRef.SetText(this.m_dpsText, IntToString(this.GetDPS(this.m_ItemData)));
        inkWidgetRef.SetVisible(this.m_statsWrapper, true);
        break;
      default:
        inkWidgetRef.SetVisible(this.m_statsWrapper, false);
    };
  }

  protected func GetDPS(data: InventoryItemData) -> Int32 {
    let i: Int32;
    let limit: Int32;
    let stat: StatViewData;
    if !InventoryItemData.IsEmpty(data) {
      i = 0;
      limit = InventoryItemData.GetPrimaryStatsSize(data);
      while i < limit {
        stat = InventoryItemData.GetPrimaryStat(data, i);
        if Equals(stat.type, gamedataStatType.DPS) {
          return stat.value;
        };
        i += 1;
      };
    };
    return 0;
  }

  protected func SetItemNameText() -> Void {
    inkTextRef.SetText(this.m_itemNameText, InventoryItemData.GetName(this.m_ItemData));
  }

  protected func UpdateDamageType() -> Void {
    this.m_damageTypeIndicator.Setup(InventoryItemData.GetDamageType(this.m_ItemData));
  }

  protected func SetShape(shapeType: EInventoryItemShape) -> Void {
    let iconSize: Vector2 = this.GetIconSize(shapeType);
    let newSize: Vector2 = this.GetShapeSize(shapeType);
    inkWidgetRef.SetSize(this.m_BackgroundShape, newSize);
    inkWidgetRef.SetSize(this.m_BackgroundHighlight, newSize);
    inkWidgetRef.SetSize(this.m_BackgroundFrame, newSize);
    inkWidgetRef.SetSize(this.m_iconWrapper, iconSize);
    if inkWidgetRef.IsValid(this.m_toggleHighlight) {
      inkWidgetRef.SetSize(this.m_toggleHighlight, newSize);
    };
    if InventoryItemData.IsEmpty(this.m_ItemData) {
      inkImageRef.SetTexturePart(this.m_BackgroundFrame, n"item_grid_frame");
    } else {
      inkImageRef.SetTexturePart(this.m_BackgroundFrame, n"item_frame");
    };
  }

  protected func GetIconSize(shapeType: EInventoryItemShape) -> Vector2 {
    let newSize: Vector2;
    switch shapeType {
      case EInventoryItemShape.SingleSlot:
        newSize = new Vector2(this.singleIconSize.X, this.singleIconSize.Y);
        break;
      case EInventoryItemShape.DoubleSlot:
        newSize = new Vector2(this.m_bigSize.X / 2.00, this.singleIconSize.Y);
    };
    return newSize;
  }
}
