
public class PonrRewardsGameController extends BaseModalListPopupGameController {

  private let m_gameInstance: GameInstance;

  private let m_inventoryManager: ref<InventoryDataManagerV2>;

  private let m_tooltipsManager: wref<gameuiTooltipsManager>;

  private edit let m_rewardListInventoryItemGrid: inkWidgetRef;

  private edit let m_rewardListInventoryWeaponGrid: inkWidgetRef;

  private edit let m_rewardListRipperdocGrid: inkWidgetRef;

  private edit let m_rewardListInventoryItemHolder: inkWidgetRef;

  private edit let m_rewardListRipperdocHolder: inkWidgetRef;

  private edit let m_tooltipsManagerRef: inkWidgetRef;

  private edit let m_okayButton: inkWidgetRef;

  private edit let m_endingAchievementArt: inkImageRef;

  private let m_pointOfNoReturnBB: wref<IBlackboard>;

  private let m_pointOfNoReturnRewardScreenDef: ref<UI_PointOfNoReturnRewardScreenDef>;

  protected cb func OnInitialize() -> Bool {
    let owner: wref<GameObject>;
    super.OnInitialize();
    owner = this.GetPlayerControlledObject();
    this.m_gameInstance = owner.GetGame();
    this.m_pointOfNoReturnRewardScreenDef = GetAllBlackboardDefs().UI_PointOfNoReturnRewardScreen;
    this.m_pointOfNoReturnBB = this.GetBlackboardSystem().Get(this.m_pointOfNoReturnRewardScreenDef);
    this.m_tooltipsManager = inkWidgetRef.GetControllerByType(this.m_tooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_tooltipsManager.Setup(ETooltipsStyle.Menus);
    inkWidgetRef.RegisterToCallback(this.m_okayButton, n"OnRelease", this, n"OnOkayRelease");
    this.Show();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    inkWidgetRef.UnregisterFromCallback(this.m_okayButton, n"OnRelease", this, n"OnOkayRelease");
    this.m_tooltipsManager.HideTooltips();
    this.m_inventoryManager.UnInitialize();
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    super.OnPlayerAttach(playerPuppet);
    this.m_inventoryManager = new InventoryDataManagerV2();
    this.m_inventoryManager.Initialize(playerPuppet as PlayerPuppet);
    if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q201_done") == 1 {
      inkImageRef.SetTexturePart(this.m_endingAchievementArt, n"devil");
    } else {
      if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q202_done") == 1 {
        inkImageRef.SetTexturePart(this.m_endingAchievementArt, n"star");
      } else {
        if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q203_done") == 1 {
          inkImageRef.SetTexturePart(this.m_endingAchievementArt, n"sun");
        } else {
          if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q204_done") == 1 {
            inkImageRef.SetTexturePart(this.m_endingAchievementArt, n"temperance");
          };
        };
      };
    };
  }

  protected cb func OnOkayRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.OnClose();
    };
  }

  private final func GetInventoryItemDisplayControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<InventoryItemDisplayController> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<InventoryItemDisplayController> = widget.GetController() as InventoryItemDisplayController;
    return controller;
  }

  protected cb func OnInventoryItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<InventoryItemDisplayController> = this.GetInventoryItemDisplayControllerFromTarget(evt);
    let itemData: InventoryItemData = controller.GetItemData();
    this.InventoryItemHoverOver(itemData, evt.GetCurrentTarget());
  }

  protected cb func OnInventoryItemHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_tooltipsManager.HideTooltips();
  }

  private final func InventoryItemHoverOver(itemData: InventoryItemData, widget: wref<inkWidget>) -> Void {
    let tooltipData: ref<InventoryTooltipData>;
    this.m_tooltipsManager.HideTooltips();
    if !InventoryItemData.IsEmpty(itemData) {
      tooltipData = this.m_inventoryManager.GetTooltipDataForInventoryItem(itemData, InventoryItemData.IsEquipped(itemData), InventoryItemData.IsVendorItem(itemData));
      if InventoryItemData.GetGameItemData(itemData).HasTag(n"Cyberdeck") {
        this.m_tooltipsManager.ShowTooltipAtWidget(n"cyberdeckTooltip", widget, tooltipData, gameuiETooltipPlacement.RightTop, true);
      } else {
        if Equals(InventoryItemData.GetItemType(itemData), gamedataItemType.Prt_Program) {
          this.m_tooltipsManager.ShowTooltipAtWidget(n"programTooltip", widget, tooltipData, gameuiETooltipPlacement.RightTop, true);
        } else {
          this.m_tooltipsManager.ShowTooltipAtWidget(n"itemTooltip", widget, tooltipData, gameuiETooltipPlacement.RightTop, true);
        };
      };
    };
  }

  protected func OnClose() -> Void {
    this.Hide();
    this.m_popupData.token.TriggerCallback(this.m_popupData);
  }

  private final func Show() -> Void {
    this.GetRootWidget().SetVisible(true);
    this.PopulateData();
    PopupStateUtils.SetBackgroundBlur(this, true);
  }

  private final func Hide() -> Void {
    let player: ref<GameObject>;
    player.UnregisterInputListener(this);
    this.GetRootWidget().SetVisible(false);
    PopupStateUtils.SetBackgroundBlur(this, false);
    this.m_tooltipsManager.HideTooltips();
  }

  private final func PopulateData() -> Void {
    let i: Int32;
    let itemCategory: gamedataItemCategory;
    let itemData: InventoryItemData;
    let slot: ref<InventoryItemDisplayController>;
    let itemDataArray: array<ItemID> = FromVariant(this.m_pointOfNoReturnBB.GetVariant(this.m_pointOfNoReturnRewardScreenDef.Rewards));
    inkWidgetRef.SetVisible(this.m_rewardListInventoryItemHolder, false);
    inkWidgetRef.SetVisible(this.m_rewardListRipperdocHolder, false);
    i = 0;
    while i < ArraySize(itemDataArray) {
      itemData = ToInventoryItemData(this.GetPlayerControlledObject(), itemDataArray[i]);
      itemCategory = RPGManager.GetItemCategory(InventoryItemData.GetID(itemData));
      if Equals(itemCategory, gamedataItemCategory.Cyberware) {
        slot = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_rewardListRipperdocGrid, n"itemDisplay") as InventoryItemDisplayController;
        inkWidgetRef.SetVisible(this.m_rewardListRipperdocHolder, true);
      } else {
        if Equals(itemCategory, gamedataItemCategory.Weapon) {
          slot = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_rewardListInventoryWeaponGrid, n"weaponDisplay") as InventoryItemDisplayController;
          inkWidgetRef.SetVisible(this.m_rewardListInventoryItemHolder, true);
        } else {
          slot = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_rewardListInventoryItemGrid, n"itemDisplay") as InventoryItemDisplayController;
          inkWidgetRef.SetVisible(this.m_rewardListInventoryItemHolder, true);
        };
      };
      slot.GetRootWidget().RegisterToCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      slot.GetRootWidget().RegisterToCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      slot.Setup(itemData, ItemDisplayContext.Backpack, true);
      i += 1;
    };
  }
}
