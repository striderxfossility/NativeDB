
public class CyberEquipGameController extends ArmorEquipGameController {

  private let eyesTags: array<CName>;

  private let brainTags: array<CName>;

  private let musculoskeletalTags: array<CName>;

  private let nervousTags: array<CName>;

  private let cardiovascularTags: array<CName>;

  private let immuneTags: array<CName>;

  private let integumentaryTags: array<CName>;

  private let handsTags: array<CName>;

  private let armsTags: array<CName>;

  private let legsTags: array<CName>;

  private let quickSlotTags: array<CName>;

  private let weaponsQuickSlotTags: array<CName>;

  private let fragmentTags: array<CName>;

  protected cb func OnInitialize() -> Bool {
    let currWidget: wref<inkWidget>;
    this.panelPlayer.SetVisible(true);
    this.player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_inventoryManager = new InventoryDataManager();
    this.m_inventoryManager.Initialize(this.player);
    GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemList(this.player, this.m_inventory);
    this.m_equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    this.m_transactionSystem = GameInstance.GetTransactionSystem(this.player.GetGame());
    this.m_operationsMode = operationsMode.PLAYER;
    this.m_tooltipContainer = this.GetWidget(n"tooltipContainer") as inkCompoundWidget;
    this.CreateButton("SYSTEM REPLACEMENT", "cyberware/slotBrain", gamedataEquipmentArea.SystemReplacementCW, 3);
    this.CreateButton("EYES", "cyberware/slotEyes", gamedataEquipmentArea.EyesCW, 3);
    this.CreateButton("CARDIOVASCULAR SYSTEM", "cyberware/slotCardiovascular", gamedataEquipmentArea.CardiovascularSystemCW, 3);
    this.CreateButton("MUSCULOSKELETAL SYSTEM", "cyberware/slotMuscoskeletal0", gamedataEquipmentArea.MusculoskeletalSystemCW, 3);
    this.CreateButton("NERVOUS SYSTEM", "cyberware/slotNervous", gamedataEquipmentArea.NervousSystemCW, 3);
    this.CreateButton("IMMUNE SYSTEM", "cyberware/slotImmune", gamedataEquipmentArea.ImmuneSystemCW, 3);
    this.CreateButton("HANDS", "cyberware/slotHands", gamedataEquipmentArea.HandsCW, 3);
    this.CreateButton("ARMS", "cyberware/slotArms", gamedataEquipmentArea.ArmsCW, 3);
    this.CreateButton("LEGS", "cyberware/slotLegs", gamedataEquipmentArea.LegsCW, 3);
    this.CreateButton("INTEGUMENTARY SYSTEM", "cyberware/slotIntegumentary", gamedataEquipmentArea.IntegumentarySystemCW, 3);
    this.CreateButton("QUICK SLOT", "cyberware/quickSlot", gamedataEquipmentArea.QuickSlot, 5);
    this.buttonScrollUp = this.GetWidget(n"scrollUp") as inkCanvas;
    this.buttonScrollUp.RegisterToCallback(n"OnRelease", this, n"OnScrollUp");
    this.buttonScrollDn = this.GetWidget(n"scrollDn") as inkCanvas;
    this.buttonScrollDn.RegisterToCallback(n"OnRelease", this, n"OnScrollDn");
    this.buttonScrollUp.SetVisible(false);
    this.SetCursorOverWidget(currWidget);
    this.m_uiBB_Equipment = GetAllBlackboardDefs().UI_Equipment;
    this.m_uiBB_EquipmentBlackboard = this.GetBlackboardSystem().Get(this.m_uiBB_Equipment);
    this.CreateTooltip(this.m_tooltipLeft);
    this.CreateTooltip(this.m_tooltipRight);
  }

  private final func CreateButton(title: String, btnPath: String, area: gamedataEquipmentArea, numSlots: Int32) -> Void {
    let currButton: wref<inkCanvas>;
    let i: Int32 = 0;
    while i < numSlots {
      currButton = this.GetWidget(StringToName(btnPath + ToString(i))) as inkCanvas;
      currButton.SetVisible(true);
      this.HelperAddPaperdollButton(title, currButton, area, i, this.headTags);
      ArrayPush(this.m_paperDollList, StringToName(btnPath + ToString(i)));
      i += 1;
    };
  }

  private final func GetPartialViewData(itemID: ItemID) -> ItemViewData {
    let itemRecord: ref<Item_Record>;
    let viewData: ItemViewData;
    let locMgr: ref<UILocalizationMap> = new UILocalizationMap();
    locMgr.Init();
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    viewData.id = itemID;
    viewData.itemName = LocKeyToString(itemRecord.DisplayName());
    viewData.categoryName = locMgr.Localize(itemRecord.ItemCategory().Name());
    viewData.description = LocKeyToString(itemRecord.LocalizedDescription());
    viewData.quality = itemRecord.Quality().Name();
    return viewData;
  }

  protected func RefreshInventoryList() -> Void {
    let i: Int32;
    let inventorySlotId: Int32;
    let validItems: array<wref<gameItemData>>;
    this.m_transactionSystem.GetItemList(this.player, validItems);
    validItems = this.RemovedEverythingButCyberware(validItems);
    i = 0;
    while i < 30 {
      this.HelperClearButton(i);
      i += 1;
    };
    inventorySlotId = 0;
    if this.scrollOffset > ArraySize(validItems) {
      this.scrollOffset = ArraySize(validItems);
      this.buttonScrollDn.SetVisible(false);
    } else {
      this.buttonScrollDn.SetVisible(true);
    };
    i = this.scrollOffset;
    while i < this.scrollOffset + ArraySize(validItems) {
      if !this.m_equipmentSystem.IsEquipped(this.player, validItems[i].GetID()) {
        this.HelperAddInventoryButton(validItems[i], inventorySlotId);
        inventorySlotId += 1;
      };
      i += 1;
    };
  }

  protected final func RemovedEverythingButCyberware(items: array<wref<gameItemData>>) -> array<wref<gameItemData>> {
    let validItems: array<wref<gameItemData>>;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if this.m_transactionSystem.HasTag(this.player, n"Cyberware", items[i].GetID()) {
        ArrayPush(validItems, items[i]);
      };
      i += 1;
    };
    return validItems;
  }
}
