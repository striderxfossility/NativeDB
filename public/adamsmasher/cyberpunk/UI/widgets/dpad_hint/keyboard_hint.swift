
public class keyboardHintGameController extends inkHUDGameController {

  @default(keyboardHintGameController, KeyboardHintItem_Top)
  private edit let m_TopElementName: CName;

  @default(keyboardHintGameController, KeyboardHintItem_Bot)
  private edit let m_BottomElementName: CName;

  private edit let m_Layout: inkBasePanelRef;

  private let m_UIItems: array<wref<KeyboardHintItemController>>;

  private let m_Player: wref<PlayerPuppet>;

  private let m_QuickSlotsManager: wref<QuickSlotsManager>;

  private let m_UiQuickItemsBlackboard: wref<IBlackboard>;

  private let m_KeyboardCommandBBID: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_Player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_QuickSlotsManager = this.m_Player.GetQuickSlotsManager();
    let i: Int32 = 0;
    let limit: Int32 = QuickSlotsManager.GetMaxKeyboardItems();
    while i < limit {
      this.AddKeyboardItem(i);
      i += 1;
    };
    this.m_UiQuickItemsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    if IsDefined(this.m_UiQuickItemsBlackboard) {
      this.m_KeyboardCommandBBID = this.m_UiQuickItemsBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_QuickSlotsData.KeyboardCommand, this, n"OnKeyboardCommand");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_UiQuickItemsBlackboard) {
      this.m_UiQuickItemsBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_QuickSlotsData.KeyboardCommand, this.m_KeyboardCommandBBID);
    };
    this.m_UiQuickItemsBlackboard = null;
  }

  private final func AddKeyboardItem(index: Int32) -> Void {
    let controller: wref<KeyboardHintItemController>;
    let itemName: CName;
    if index % 2 == 0 {
      itemName = this.m_TopElementName;
    } else {
      itemName = this.m_BottomElementName;
    };
    controller = this.SpawnFromLocal(inkWidgetRef.Get(this.m_Layout), itemName).GetController() as KeyboardHintItemController;
    if IsDefined(controller) {
      controller.Setup(index + 1);
      ArrayPush(this.m_UIItems, controller);
    };
  }

  private final func OnKeyboardCommand(value: Variant) -> Void {
    let quickSlotInformation: QuickSlotUIStructure = FromVariant(value);
    this.AnimateKeyboardIcons(quickSlotInformation.ItemIndex, quickSlotInformation.OperationResult);
  }

  private final func AnimateKeyboardIcons(choosenItemIndex: Int32, success: Bool) -> Void {
    let currentIndex: Int32;
    let currentItem: QuickSlotCommand;
    let i: Int32;
    let isEnabled: Bool;
    let offset: Int32;
    if choosenItemIndex > 3 {
      offset = 4;
    } else {
      offset = 0;
    };
    i = 0;
    while i < 4 {
      currentIndex = i + offset;
      if this.m_QuickSlotsManager.IsKeyboardActionAvaliable(currentIndex) {
        currentItem = this.m_QuickSlotsManager.GetKeyboardCommandAtSlot(currentIndex);
        isEnabled = success;
        this.m_UIItems[currentIndex].SetState(isEnabled, currentIndex == choosenItemIndex);
        this.m_UIItems[currentIndex].SetIcon(currentItem.AtlasPath, currentItem.IconName);
        this.m_UIItems[currentIndex].Animate(isEnabled);
      };
      i += 1;
    };
  }
}
