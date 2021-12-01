
public class InventoryEquipmentSlot extends inkLogicController {

  protected edit let m_EquipSlotRef: inkWidgetRef;

  protected edit let m_EmptySlotButtonRef: inkWidgetRef;

  protected edit let m_BackgroundShape: inkImageRef;

  protected edit let m_BackgroundHighlight: inkImageRef;

  protected edit let m_BackgroundFrame: inkImageRef;

  protected edit let m_unavailableIcon: inkWidgetRef;

  protected edit let m_toggleHighlight: inkImageRef;

  protected let m_CurrentItemView: wref<InventoryItemDisplayController>;

  private let m_Empty: Bool;

  private let m_itemData: InventoryItemData;

  private let m_equipmentArea: gamedataEquipmentArea;

  private let m_slotName: String;

  private let m_slotIndex: Int32;

  @default(InventoryEquipmentSlot, false)
  private let m_DisableSlot: Bool;

  protected let m_smallSize: Vector2;

  protected let m_bigSize: Vector2;

  protected cb func OnInitialize() -> Bool {
    this.m_smallSize.X = 174.00;
    this.m_smallSize.Y = 177.00;
    this.m_bigSize.X = 348.00;
    this.m_bigSize.Y = 177.00;
    inkWidgetRef.SetVisible(this.m_unavailableIcon, false);
    this.Clear();
  }

  public func SetDisableSlot(disableSlot: Bool) -> Void {
    this.m_DisableSlot = disableSlot;
  }

  public func Setup(itemData: InventoryItemData, equipmentArea: gamedataEquipmentArea, opt slotName: String, opt slotIndex: Int32, opt ownerEntity: ref<Entity>) -> Void {
    if !IsDefined(this.m_CurrentItemView) {
      if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
        this.m_CurrentItemView = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_EquipSlotRef, n"weaponDisplay") as InventoryItemDisplayController;
      } else {
        this.m_CurrentItemView = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_EquipSlotRef, n"itemDisplay") as InventoryItemDisplayController;
      };
    };
    this.m_CurrentItemView.Setup(itemData);
    this.m_itemData = itemData;
    this.m_equipmentArea = equipmentArea;
    this.m_slotIndex = slotIndex;
    this.m_slotName = slotName;
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) || Equals(equipmentArea, gamedataEquipmentArea.HandsCW) || Equals(equipmentArea, gamedataEquipmentArea.SystemReplacementCW) || Equals(equipmentArea, gamedataEquipmentArea.ArmsCW) {
      InventoryItemData.SetItemShape(itemData, EInventoryItemShape.DoubleSlot);
    };
    inkWidgetRef.SetVisible(this.m_unavailableIcon, (Equals(equipmentArea, gamedataEquipmentArea.HandsCW) || Equals(equipmentArea, gamedataEquipmentArea.SystemReplacementCW) || Equals(equipmentArea, gamedataEquipmentArea.ArmsCW)) && InventoryItemData.IsEmpty(itemData));
    this.SetShape(InventoryItemData.GetItemShape(itemData));
    this.Show();
  }

  public func Show() -> Void {
    let itemData: InventoryItemData;
    if IsDefined(this.m_CurrentItemView) {
      itemData = this.m_CurrentItemView.GetItemData();
      this.m_Empty = InventoryItemData.IsEmpty(itemData);
    } else {
      this.m_Empty = true;
    };
    this.RefreshUI();
  }

  public func Clear() -> Void {
    this.m_Empty = true;
    this.RefreshUI();
  }

  protected func RefreshUI() -> Void {
    this.m_Empty = false;
    if IsDefined(this.m_CurrentItemView) {
      this.m_CurrentItemView.GetRootWidget().SetVisible(!this.m_Empty);
    };
    inkWidgetRef.SetVisible(this.m_EmptySlotButtonRef, this.m_Empty || !this.m_DisableSlot);
    inkWidgetRef.SetInteractive(this.m_EmptySlotButtonRef, this.m_Empty);
  }

  public final func SetShape(shapeType: EInventoryItemShape) -> Void {
    let newSize: Vector2;
    switch shapeType {
      case EInventoryItemShape.SingleSlot:
        newSize = this.m_smallSize;
        break;
      case EInventoryItemShape.DoubleSlot:
        newSize = this.m_bigSize;
    };
    inkWidgetRef.SetSize(this.m_BackgroundShape, newSize);
    inkWidgetRef.SetSize(this.m_BackgroundHighlight, newSize);
    inkWidgetRef.SetSize(this.m_BackgroundFrame, newSize);
    inkWidgetRef.SetSize(this.m_toggleHighlight, newSize);
  }

  public final func Select() -> Void {
    let itemData: InventoryItemData = this.m_CurrentItemView.GetItemData();
    if !InventoryItemData.IsEmpty(itemData) {
      this.m_CurrentItemView.SelectItem();
    };
    if inkWidgetRef.IsValid(this.m_toggleHighlight) {
      inkWidgetRef.SetVisible(this.m_toggleHighlight, true);
    };
  }

  public final func Unselect() -> Void {
    this.m_CurrentItemView.UnselectItem();
    if inkWidgetRef.IsValid(this.m_toggleHighlight) {
      inkWidgetRef.SetVisible(this.m_toggleHighlight, false);
    };
  }

  public final func GetItemData() -> InventoryItemData {
    return this.m_CurrentItemView.GetItemData();
  }

  public func GetSlotWidget() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_EmptySlotButtonRef);
  }

  public func GetCustomizeWidget() -> wref<inkWidget> {
    return this.GetRootWidget();
  }

  public final func GetEquipmentArea() -> gamedataEquipmentArea {
    return this.m_equipmentArea;
  }

  public final func GetEquipmentAreaEnumToInt() -> Int32 {
    return EnumInt(this.m_equipmentArea);
  }

  public final func GetSlotIndex() -> Int32 {
    return this.m_slotIndex;
  }

  public final func GetSlotName() -> String {
    return this.m_slotName;
  }

  public func IsEmpty() -> Bool {
    return this.m_Empty;
  }
}
