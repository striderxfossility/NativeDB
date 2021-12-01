
public class ItemPreviewGameController extends inkItemPreviewGameController {

  private edit let m_itemNameText: inkTextRef;

  private edit let m_itemLevelText: inkTextRef;

  private edit let m_itemRarityWidget: inkWidgetRef;

  private let m_data: ref<InventoryItemPreviewData>;

  private let m_isMouseDown: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_data = this.GetRootWidget().GetUserData(n"InventoryItemPreviewData") as InventoryItemPreviewData;
    inkTextRef.SetText(this.m_itemNameText, this.m_data.itemName);
    inkTextRef.SetText(this.m_itemLevelText, "Required level: " + IntToString(this.m_data.requiredLevel));
    inkWidgetRef.SetState(this.m_itemRarityWidget, this.m_data.itemQualityState);
    this.PreviewItem(this.m_data.itemID);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
  }

  protected cb func OnGlobalPress(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"mouse_left") {
      this.m_isMouseDown = true;
    };
  }

  protected cb func OnGlobalRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"mouse_left") {
      this.m_isMouseDown = false;
    };
    if e.IsAction(n"cancel") || e.IsAction(n"click") {
      this.m_data.token.TriggerCallback(null);
    };
  }

  protected func HandleAxisInput(e: ref<inkPointerEvent>) -> Void {
    let amount: Float = e.GetAxisData();
    if e.IsAction(n"right_stick_x") {
      this.RotateVector(new Vector3(0.00, 0.00, amount * 2.00));
    };
    if e.IsAction(n"right_stick_y") {
      this.RotateVector(new Vector3(0.00, amount * 2.00, 0.00));
    };
  }

  protected cb func OnRelativeInput(e: ref<inkPointerEvent>) -> Bool {
    let amount: Float = e.GetAxisData();
    let ration: Float = 0.25;
    if this.m_isMouseDown {
      if e.IsAction(n"mouse_x") {
        this.RotateVector(new Vector3(0.00, 0.00, amount * ration));
      };
      if e.IsAction(n"mouse_y") {
        this.RotateVector(new Vector3(0.00, amount * ration, 0.00));
      };
    };
  }
}

public class ItemCraftingPreviewGameController extends inkItemPreviewGameController {

  protected cb func OnCrafrtingPreview(evt: ref<CraftingItemPreviewEvent>) -> Bool {
    this.PreviewItem(evt.itemID);
  }
}

public class GarmentItemPreviewGameController extends inkInventoryPuppetPreviewGameController {

  protected let m_data: ref<InventoryItemPreviewData>;

  protected let m_placementSlot: TweakDBID;

  protected let m_initialItem: ItemID;

  protected let m_givenItem: ItemID;

  private let m_isMouseDown: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_data = this.GetRootWidget().GetUserData(n"InventoryItemPreviewData") as InventoryItemPreviewData;
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
  }

  protected cb func OnUninitialize() -> Bool {
    let transactionSystem: ref<TransactionSystem>;
    let puppet: ref<gamePuppet> = this.GetGamePuppet();
    if IsDefined(puppet) {
      transactionSystem = GameInstance.GetTransactionSystem(puppet.GetGame());
      transactionSystem.RemoveItemFromSlot(puppet, this.m_placementSlot, true);
      transactionSystem.RemoveItem(puppet, this.m_givenItem, 1);
      transactionSystem.AddItemToSlot(puppet, this.m_placementSlot, this.m_initialItem);
    };
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
    super.OnUninitialize();
  }

  protected cb func OnGlobalPress(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"mouse_left") {
      this.m_isMouseDown = true;
    };
  }

  protected cb func OnGlobalRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"mouse_left") {
      this.m_isMouseDown = false;
    };
    if e.IsAction(n"cancel") || e.IsAction(n"click") {
      this.m_data.token.TriggerCallback(null);
    };
  }

  protected cb func OnPuppetAttached() -> Bool {
    let puppet: ref<gamePuppet>;
    let transactionSystem: ref<TransactionSystem>;
    super.OnPuppetAttached();
    puppet = this.GetGamePuppet();
    if IsDefined(puppet) {
      transactionSystem = GameInstance.GetTransactionSystem(puppet.GetGame());
      this.m_placementSlot = EquipmentSystem.GetPlacementSlot(this.m_data.itemID);
      this.m_initialItem = transactionSystem.GetItemInSlot(puppet, this.m_placementSlot).GetItemID();
      transactionSystem.RemoveItemFromSlot(puppet, this.m_placementSlot, true);
      this.m_givenItem = ItemID.FromTDBID(ItemID.GetTDBID(this.m_data.itemID));
      transactionSystem.GiveItem(puppet, this.m_givenItem, 1);
      transactionSystem.AddItemToSlot(puppet, this.m_placementSlot, this.m_givenItem);
    };
  }

  protected func HandleAxisInput(e: ref<inkPointerEvent>) -> Void {
    let amount: Float = e.GetAxisData();
    if e.IsAction(n"right_stick_x") {
      this.Rotate(amount * 2.00);
    };
    if e.IsAction(n"right_stick_y") {
      this.Rotate(amount * -2.00);
    };
  }

  protected cb func OnRelativeInput(e: ref<inkPointerEvent>) -> Bool {
    let amount: Float = e.GetAxisData();
    let ration: Float = 0.25;
    if this.m_isMouseDown {
      if e.IsAction(n"mouse_x") {
        this.Rotate(amount * ration);
      };
      if e.IsAction(n"mouse_y") {
        this.Rotate(amount * -ration);
      };
    };
  }
}

public abstract class ItemPreviewHelper extends IScriptable {

  public final static func ShowPreviewItem(controller: ref<inkGameController>, itemData: InventoryItemData, isGarment: Bool, callbackName: CName) -> ref<inkGameNotificationToken> {
    return ItemPreviewHelper.ShowPreviewItem(controller, itemData, Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Weapon), isGarment, callbackName);
  }

  public final static func ShowPreviewItem(controller: ref<inkGameController>, itemData: InventoryItemData, isPreviewable: Bool, isGarment: Bool, callbackName: CName) -> ref<inkGameNotificationToken> {
    let token: ref<inkGameNotificationToken>;
    let previewData: ref<InventoryItemPreviewData> = ItemPreviewHelper.GetPreviewData(controller, itemData, isPreviewable, isGarment);
    if IsDefined(previewData) {
      token = controller.ShowGameNotification(previewData);
      token.RegisterListener(controller, callbackName);
    };
    return token;
  }

  private final static func GetPreviewData(controller: ref<IScriptable>, itemData: InventoryItemData, isPreviewable: Bool, isGarment: Bool) -> ref<InventoryItemPreviewData> {
    let itemID: ItemID = InventoryItemData.GetGameItemData(itemData).GetID();
    let previewData: ref<InventoryItemPreviewData> = new InventoryItemPreviewData();
    previewData.itemID = itemID;
    previewData.itemName = InventoryItemData.GetName(itemData);
    previewData.itemQualityState = InventoryItemData.GetQuality(itemData);
    previewData.requiredLevel = InventoryItemData.GetRequiredLevel(itemData);
    previewData.queueName = n"modal_popup_fullscreen";
    previewData.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\item_preview.inkwidget";
    previewData.isBlocking = true;
    previewData.useCursor = true;
    if isPreviewable {
      previewData.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\item_preview.inkwidget";
      return previewData;
    };
    if isGarment {
      previewData.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\garment_item_preview.inkwidget";
      return previewData;
    };
    return null;
  }
}
