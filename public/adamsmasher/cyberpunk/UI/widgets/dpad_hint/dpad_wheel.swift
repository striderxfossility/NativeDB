
public class DpadWheelGameController extends inkHUDGameController {

  private edit let m_haskMarkContainer: inkCompoundRef;

  private edit let m_itemContainer: inkCompoundRef;

  private edit let m_selectorWrapper: inkWidgetRef;

  private edit let m_centerIcon: inkWidgetRef;

  private edit let m_centerGlow: inkWidgetRef;

  private edit let m_itemLabel: inkTextRef;

  private edit let m_itemDesc: inkTextRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_indicator02: inkImageRef;

  private edit let m_indicator03: inkImageRef;

  private edit let m_indicator04: inkImageRef;

  private edit let m_indicator05: inkImageRef;

  private edit let m_indicator06: inkImageRef;

  private edit let m_indicator07: inkImageRef;

  private edit let m_indicator08: inkImageRef;

  @default(DpadWheelGameController, 450.0)
  private edit let m_itemDistance: Float;

  @default(DpadWheelGameController, 350.0)
  private edit let m_hashMarkDistance: Float;

  @default(DpadWheelGameController, 0.2)
  private edit let m_minDistance: Float;

  private let m_root: wref<inkWidget>;

  private let m_Player: wref<PlayerPuppet>;

  private let m_QuickSlotsManager: wref<QuickSlotsManager>;

  private let m_InventoryDataManager: ref<InventoryDataManagerV2>;

  private let m_dpadItemsList: array<wref<DpadWheelItemController>>;

  private let m_commandsList: array<QuickSlotCommand>;

  private let m_selectedWheelItem: wref<DpadWheelItemController>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_selectedIndicator: inkWidgetRef;

  private let m_angleInterval: Float;

  private let m_previousAmount: Float;

  private let m_previousAngle: Float;

  private let m_data: QuickWheelStartUIStructure;

  private let m_masterListOfAllCyberware: array<AbilityData>;

  private let m_listOfUnassignedCyberware: array<AbilityData>;

  private let m_dpadWheelOpen: Bool;

  private let m_neutralChoiceDelayId: DelayID;

  private let m_previouslySelectedData: QuickSlotCommand;

  private let m_UiQuickItemsBlackboard: wref<IBlackboard>;

  private let m_UiQuickSlotDef: ref<UI_QuickSlotsDataDef>;

  private let m_DPadWheelAngleBBID: ref<CallbackHandle>;

  private let m_DPadWheelInterationStartedBBID: ref<CallbackHandle>;

  private let m_DPadWheelInterationEndedBBID: ref<CallbackHandle>;

  private let m_DpadWheelCyberwareAssignedBBID: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    let buttonHints: wref<inkWidget>;
    this.m_Player = GameInstance.GetPlayerSystem((this.GetOwnerEntity() as GameObject).GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.m_QuickSlotsManager = this.m_Player.GetQuickSlotsManager();
    this.m_InventoryDataManager = new InventoryDataManagerV2();
    this.m_InventoryDataManager.Initialize(this.m_Player);
    this.m_root = this.GetRootCompoundWidget();
    this.m_root.SetVisible(false);
    buttonHints = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root");
    buttonHints.SetHAlign(inkEHorizontalAlign.Right);
    this.m_buttonHintsController = buttonHints.GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_B_CIRCLE, GetLocalizedText("Common-Access-Close"));
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_A_CROSS, GetLocalizedText("Common-Access-Select"));
    inkWidgetRef.SetVisible(this.m_indicator02, false);
    inkWidgetRef.SetVisible(this.m_indicator03, false);
    inkWidgetRef.SetVisible(this.m_indicator04, false);
    inkWidgetRef.SetVisible(this.m_indicator05, false);
    inkWidgetRef.SetVisible(this.m_indicator06, false);
    inkWidgetRef.SetVisible(this.m_indicator07, false);
    inkWidgetRef.SetVisible(this.m_indicator08, false);
    this.SetupBB();
    this.RegisterGameInput();
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnegisterGameInput();
    this.m_InventoryDataManager.UnInitialize();
    this.m_buttonHintsController.ClearButtonHints();
    this.RemoveBB();
  }

  private final func SetupBB() -> Void {
    this.m_UiQuickSlotDef = GetAllBlackboardDefs().UI_QuickSlotsData;
    this.m_UiQuickItemsBlackboard = this.GetBlackboardSystem().Get(this.m_UiQuickSlotDef);
    if IsDefined(this.m_UiQuickItemsBlackboard) {
      this.m_DPadWheelAngleBBID = this.m_UiQuickItemsBlackboard.RegisterDelayedListenerFloat(this.m_UiQuickSlotDef.UIRadialContextRightStickAngle, this, n"OnRadialAngleChanged");
      this.m_DPadWheelInterationStartedBBID = this.m_UiQuickItemsBlackboard.RegisterDelayedListenerVariant(this.m_UiQuickSlotDef.WheelInteractionStarted, this, n"OnWheelInteractionStarted");
      this.m_DPadWheelInterationEndedBBID = this.m_UiQuickItemsBlackboard.RegisterDelayedListenerVariant(this.m_UiQuickSlotDef.WheelInteractionEnded, this, n"OnWheelInteractionEnded");
      this.m_DpadWheelCyberwareAssignedBBID = this.m_UiQuickItemsBlackboard.RegisterDelayedListenerBool(this.m_UiQuickSlotDef.CyberwareAssignmentComplete, this, n"OnCyberwareAssigned");
    };
  }

  private final func RemoveBB() -> Void {
    if IsDefined(this.m_UiQuickItemsBlackboard) {
      this.m_UiQuickItemsBlackboard.UnregisterDelayedListener(this.m_UiQuickSlotDef.UIRadialContextRightStickAngle, this.m_DPadWheelAngleBBID);
      this.m_UiQuickItemsBlackboard.UnregisterDelayedListener(this.m_UiQuickSlotDef.WheelInteractionStarted, this.m_DPadWheelInterationStartedBBID);
      this.m_UiQuickItemsBlackboard.UnregisterDelayedListener(this.m_UiQuickSlotDef.WheelInteractionEnded, this.m_DPadWheelInterationEndedBBID);
    };
    this.m_UiQuickItemsBlackboard = null;
  }

  protected cb func OnRadialAngleChanged(value: Float) -> Bool {
    this.UpdateRotation(value);
  }

  protected cb func OnWheelInteractionStarted(value: Variant) -> Bool {
    let startEvent: QuickWheelStartUIStructure = FromVariant(value);
    if ArraySize(startEvent.WheelItems) <= 0 && Equals(startEvent.dpadSlot, EDPadSlot.Left) {
      return false;
    };
    this.ShowDPadWheel(startEvent);
    this.UnselectAllItems();
    this.m_dpadWheelOpen = true;
    this.InitSelection();
  }

  private final func RegisterGameInput() -> Void {
    this.m_Player.RegisterInputListener(this, n"UI_PreviousAbility");
    this.m_Player.RegisterInputListener(this, n"UI_NextAbility");
    this.m_Player.RegisterInputListener(this, n"UI_MoveX_Axis");
    this.m_Player.RegisterInputListener(this, n"UI_MoveY_Axis");
    this.m_Player.RegisterInputListener(this, n"UI_LookX_Axis");
    this.m_Player.RegisterInputListener(this, n"UI_LookY_Axis");
  }

  private final func UnegisterGameInput() -> Void {
    this.m_Player.UnregisterInputListener(this, n"UI_PreviousAbility");
    this.m_Player.UnregisterInputListener(this, n"UI_NextAbility");
    this.m_Player.UnregisterInputListener(this, n"UI_MoveX_Axis");
    this.m_Player.UnregisterInputListener(this, n"UI_MoveY_Axis");
    this.m_Player.UnregisterInputListener(this, n"UI_LookX_Axis");
    this.m_Player.UnregisterInputListener(this, n"UI_LookY_Axis");
  }

  private final func InitSelection() -> Void {
    let data: QuickSlotCommand;
    let slotController: wref<DpadWheelItemController>;
    let activeItemId: ItemID = EquipmentSystem.GetData(this.m_Player).GetActiveItem(gamedataEquipmentArea.Weapon);
    let i: Int32 = 0;
    while i < ArraySize(this.m_dpadItemsList) {
      slotController = this.m_dpadItemsList[i];
      slotController.SetHover(false);
      data = slotController.GetData();
      if data.ItemId == activeItemId {
        slotController.SetHover(true);
        this.m_selectedWheelItem = slotController;
        if NotEquals(data.ActionType, QuickSlotActionType.Undefined) {
          this.m_QuickSlotsManager.SetWheelItem(data);
        };
        this.UpdateInformationPanel(this.m_selectedWheelItem);
        this.UpdateButtonHints();
      };
      i += 1;
    };
    inkWidgetRef.SetMargin(this.m_centerIcon, 0.00, 0.00, 0.00, 0.00);
  }

  protected cb func OnWheelInteractionEnded(value: Variant) -> Bool {
    this.HideDpadWheel();
    this.DelayUnselsecAllItemsCancel();
    this.SendSelectedItemChangeEventToEntity(this.m_QuickSlotsManager.GetQuickSlotCommandByDpadSlot(EDPadSlot.InteractionWheel), true);
    this.UnselectAllItems();
  }

  protected cb func OnCyberwareAssigned(value: Bool) -> Bool {
    let data: QuickSlotCommand;
    this.RefreshRadial();
    this.UpdateRotation(this.m_previousAngle);
    data = this.m_selectedWheelItem.GetData();
    if NotEquals(data.ActionType, QuickSlotActionType.Undefined) {
      this.m_QuickSlotsManager.SetWheelItem(data);
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if !this.m_dpadWheelOpen {
      return false;
    };
    if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
      if Equals(ListenerAction.GetName(action), n"UI_PreviousAbility") {
        this.CycleToAbility(-1);
      } else {
        if Equals(ListenerAction.GetName(action), n"UI_NextAbility") {
          this.CycleToAbility(1);
        };
      };
    };
    if Equals(ListenerAction.GetType(action), gameinputActionType.AXIS_CHANGE) {
      if Equals(ListenerAction.GetName(action), n"UI_LookX_Axis") || Equals(ListenerAction.GetName(action), n"UI_LookY_Axis") {
        this.UpdateAxisIndicator(ListenerAction.GetValue(action), ListenerAction.GetName(action));
      };
      if Equals(ListenerAction.GetName(action), n"UI_MoveX_Axis") || Equals(ListenerAction.GetName(action), n"UI_MoveY_Axis") {
        this.UpdateAxisIndicator(ListenerAction.GetValue(action), ListenerAction.GetName(action));
      };
    };
  }

  private final func UpdateAxisIndicator(value: Float, actionName: CName) -> Void {
    let applyChange: Bool;
    let emptyDelayID: DelayID;
    let dist: Float = -30.00;
    let amount: Float = value;
    let centerIconOldMargin: inkMargin = inkWidgetRef.GetMargin(this.m_centerIcon);
    if Cast(this.m_previousAngle) {
      if AbsF(amount) > 0.00 {
        if Equals(actionName, n"UI_MoveX_Axis") || Equals(actionName, n"UI_LookX_Axis") {
          centerIconOldMargin.left = dist * -amount;
        };
        if Equals(actionName, n"UI_MoveY_Axis") || Equals(actionName, n"UI_LookY_Axis") {
          centerIconOldMargin.top = dist * amount;
        };
        inkWidgetRef.SetMargin(this.m_centerIcon, centerIconOldMargin);
        applyChange = true;
      };
    } else {
      inkWidgetRef.SetMargin(this.m_centerIcon, centerIconOldMargin);
      applyChange = true;
    };
    if applyChange && centerIconOldMargin.left == 0.00 && centerIconOldMargin.top == 0.00 {
      inkWidgetRef.SetVisible(this.m_centerGlow, true);
      if this.m_neutralChoiceDelayId == emptyDelayID {
      };
    };
    this.m_previousAmount = amount;
  }

  private final func DelayUnselectAllItems() -> Void {
    let delayEvt: ref<UndelectAllItemsDelayedEvent> = new UndelectAllItemsDelayedEvent();
    this.m_neutralChoiceDelayId = GameInstance.GetDelaySystem(this.GetPlayerControlledObject().GetGame()).DelayEvent(this.GetOwnerEntity(), delayEvt, 0.10, false);
  }

  private final func DelayUnselsecAllItemsCancel() -> Void {
    let emptyDelayID: DelayID;
    if this.m_neutralChoiceDelayId != emptyDelayID {
      GameInstance.GetDelaySystem(this.GetPlayerControlledObject().GetGame()).CancelDelay(this.m_neutralChoiceDelayId);
      this.m_neutralChoiceDelayId = emptyDelayID;
    };
  }

  protected cb func OnUndelectAllItemsDelayedEvent(evt: ref<UndelectAllItemsDelayedEvent>) -> Bool {
    this.UnselectAllItems();
  }

  private final func UnselectAllItems() -> Void {
    let emptyData: QuickSlotCommand;
    let emptyItem: wref<DpadWheelItemController>;
    this.m_previouslySelectedData = this.m_selectedWheelItem.GetData();
    emptyData.itemType = this.m_previouslySelectedData.itemType;
    inkWidgetRef.SetVisible(this.m_centerGlow, true);
    this.m_selectedWheelItem.SetHover(false);
    this.m_QuickSlotsManager.SetWheelItem(emptyData);
    this.UpdateInformationPanel(emptyItem);
    emptyData.itemType = QuickSlotItemType.Interaction;
    this.m_QuickSlotsManager.SetWheelItem(emptyData);
  }

  private final func ShowDPadWheel(eventData: QuickWheelStartUIStructure) -> Void {
    this.m_root.SetVisible(true);
    this.m_data = eventData;
    this.RefreshRadial();
  }

  private final func RefreshRadial() -> Void {
    this.GetAllDpadCommands();
    this.CreateHashMarks();
    this.CreateWheelItems();
    this.UpdateVirtualAbilitiesList();
    this.UpdateInformationPanel(this.m_selectedWheelItem);
  }

  private final func GetAllDpadCommands() -> Void {
    ArrayClear(this.m_commandsList);
    this.SetupCommandList(this.m_data.WheelItems);
  }

  private final func AddCommandsToList(originalList: array<QuickSlotCommand>, newList: array<QuickSlotCommand>) -> array<QuickSlotCommand> {
    let i: Int32 = 0;
    while i < ArraySize(originalList) {
      ArrayPush(newList, originalList[i]);
      i += 1;
    };
    return newList;
  }

  private final func SetupCommandList(data: array<QuickSlotCommand>) -> Void {
    this.m_commandsList = data;
    this.m_angleInterval = 360.00 / Cast(ArraySize(this.m_commandsList));
  }

  private final func CreateWheelItems() -> Void {
    let i: Int32;
    let itemAngle: Float;
    let itemController: wref<DpadWheelItemController>;
    let itemWidget: ref<inkWidget>;
    let limit: Int32 = ArraySize(this.m_commandsList);
    while ArraySize(this.m_dpadItemsList) > limit {
      itemController = ArrayPop(this.m_dpadItemsList);
      inkCompoundRef.RemoveChild(this.m_itemContainer, itemController.GetRootWidget());
    };
    while ArraySize(this.m_dpadItemsList) < limit {
      itemWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_itemContainer), n"dpadWheelItem");
      itemController = itemWidget.GetController() as DpadWheelItemController;
      ArrayPush(this.m_dpadItemsList, itemController);
    };
    i = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_itemContainer) {
      itemAngle = this.m_angleInterval * Cast(i);
      itemWidget = inkCompoundRef.GetWidgetByIndex(this.m_itemContainer, i);
      itemWidget.SetMargin(this.CalculatePosition(i, this.m_itemDistance));
      itemWidget.SetRotation(itemAngle);
      i += 1;
    };
    i = 0;
    while i < limit {
      itemController = this.m_dpadItemsList[i];
      if IsDefined(itemController) {
        itemAngle = this.m_angleInterval * Cast(i);
        itemController.SetupData(this.m_commandsList[i], itemAngle, ArraySize(this.m_commandsList), this.m_InventoryDataManager, this.IsLeft(itemWidget.GetMargin()));
      };
      i += 1;
    };
  }

  private final func CreateHashMarks() -> Void {
    let i: Int32;
    let itemWidget: ref<inkWidget>;
    inkCompoundRef.RemoveAllChildren(this.m_haskMarkContainer);
    i = 0;
    while i < ArraySize(this.m_commandsList) {
      itemWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_haskMarkContainer), n"hashMark");
      itemWidget.SetMargin(this.CalculatePosition(i, this.m_hashMarkDistance));
      itemWidget.SetRotation(this.m_angleInterval * Cast(i));
      i += 1;
    };
    inkWidgetRef.SetRotation(this.m_haskMarkContainer, this.m_angleInterval / 2.00);
  }

  private final func SetupSelectorMask() -> Void {
    inkWidgetRef.SetVisible(this.m_indicator02, false);
    inkWidgetRef.SetVisible(this.m_indicator03, false);
    inkWidgetRef.SetVisible(this.m_indicator04, false);
    inkWidgetRef.SetVisible(this.m_indicator05, false);
    inkWidgetRef.SetVisible(this.m_indicator06, false);
    inkWidgetRef.SetVisible(this.m_indicator07, false);
    inkWidgetRef.SetVisible(this.m_indicator08, false);
    switch ArraySize(this.m_commandsList) {
      case 2:
      case 1:
        this.m_selectedIndicator = this.m_indicator02;
        break;
      case 3:
        this.m_selectedIndicator = this.m_indicator03;
        break;
      case 4:
        this.m_selectedIndicator = this.m_indicator04;
        break;
      case 5:
        this.m_selectedIndicator = this.m_indicator05;
        break;
      case 6:
        this.m_selectedIndicator = this.m_indicator06;
        break;
      case 7:
        this.m_selectedIndicator = this.m_indicator07;
        break;
      case 8:
        this.m_selectedIndicator = this.m_indicator08;
    };
    inkWidgetRef.SetVisible(this.m_selectedIndicator, true);
  }

  private final func UpdateRotation(angleFloat: Float) -> Void {
    let currLogicController: wref<DpadWheelItemController>;
    let data: QuickSlotCommand;
    let i: Int32;
    let isSelected: Bool;
    let selectedIndex: Int32;
    let tempAngle: Float;
    let emptyStruct: QuickWheelStartUIStructure = FromVariant(this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData).GetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.WheelInteractionStarted));
    if ArraySize(emptyStruct.WheelItems) <= 0 && Equals(emptyStruct.dpadSlot, EDPadSlot.Left) {
      return;
    };
    this.m_previousAngle = angleFloat;
    tempAngle = angleFloat;
    tempAngle -= 45.00;
    if tempAngle > 360.00 {
      tempAngle = tempAngle - 360.00;
    };
    if tempAngle < 0.00 {
      tempAngle = 360.00 + tempAngle;
    };
    selectedIndex = -1;
    selectedIndex = RoundF(tempAngle / this.m_angleInterval);
    if selectedIndex > ArraySize(this.m_dpadItemsList) {
      selectedIndex = 0;
    };
    i = 0;
    while i < ArraySize(this.m_dpadItemsList) {
      isSelected = selectedIndex == i;
      currLogicController = this.m_dpadItemsList[i];
      currLogicController.SetHover(isSelected);
      if isSelected && (QuickSlotCommand.IsEmpty(this.m_QuickSlotsManager.GetWheelItem(currLogicController.GetData())) || this.m_selectedWheelItem != currLogicController) {
        this.m_selectedWheelItem = currLogicController;
        data = this.m_selectedWheelItem.GetData();
        if NotEquals(data.ActionType, QuickSlotActionType.Undefined) {
          this.m_QuickSlotsManager.SetWheelItem(data);
        };
        this.UpdateInformationPanel(this.m_selectedWheelItem);
        this.UpdateButtonHints();
      };
      i += 1;
    };
    inkWidgetRef.SetRotation(this.m_selectorWrapper, angleFloat += 180.00);
  }

  private final func UpdateInformationPanel(item: wref<DpadWheelItemController>) -> Void {
    let abilityData: AbilityData;
    let assembledString: String;
    let commandData: QuickSlotCommand;
    let itemData: InventoryItemData;
    inkTextRef.SetText(this.m_itemLabel, "");
    inkTextRef.SetText(this.m_itemDesc, "");
    if IsDefined(item) {
      itemData = item.GetItemData();
      commandData = item.GetData();
      inkTextRef.SetText(this.m_itemLabel, commandData.Title);
      switch commandData.ActionType {
        case QuickSlotActionType.QuickHack:
          inkTextRef.SetText(this.m_itemDesc, commandData.Description);
          this.SendSelectedItemChangeEventToEntity(commandData);
          break;
        case QuickSlotActionType.SelectRadioStation:
          inkTextRef.SetText(this.m_itemDesc, commandData.Type);
          break;
        case QuickSlotActionType.SelectItem:
          if Equals(commandData.equipType, gamedataEquipmentArea.CyberwareWheel) {
            abilityData = item.GetAbilityData();
            inkTextRef.SetText(this.m_itemLabel, abilityData.Name);
            inkTextRef.SetText(this.m_itemDesc, abilityData.Description);
          } else {
            if !InventoryItemData.IsEmpty(itemData) {
              if Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Weapon) {
                assembledString += "AMMO: " + ToString(this.m_InventoryDataManager.GetAmmoForWeaponType(itemData));
                assembledString += "\\n" + "DAMAGE TYPE: " + ToString(InventoryItemData.GetDamageType(itemData));
                inkTextRef.SetText(this.m_itemDesc, assembledString);
              } else {
                inkTextRef.SetText(this.m_itemDesc, InventoryItemData.GetDescription(itemData));
              };
            };
          };
          break;
        case QuickSlotActionType.Undefined:
          if Equals(commandData.equipType, gamedataEquipmentArea.CyberwareWheel) {
            abilityData = item.GetAbilityData();
            inkTextRef.SetText(this.m_itemLabel, abilityData.Name);
            inkTextRef.SetText(this.m_itemDesc, abilityData.Description);
          };
      };
    } else {
      this.SendSelectedItemChangeEventToEntity(this.m_previouslySelectedData, true);
      this.m_previouslySelectedData = commandData;
    };
  }

  private final func SendSelectedItemChangeEventToEntity(data: QuickSlotCommand, opt currentEmpty: Bool) -> Void;

  private final func CycleToAbility(dir: Int32) -> Void {
    let commandData: QuickSlotCommand;
    let nextAbility: AbilityData;
    if IsDefined(this.m_selectedWheelItem) {
      commandData = this.m_selectedWheelItem.GetData();
      if Equals(commandData.equipType, gamedataEquipmentArea.CyberwareWheel) {
        nextAbility = this.GetNextAbility(this.m_selectedWheelItem.GetAbilityData(), dir);
        this.m_selectedWheelItem.AddAbility(nextAbility);
        this.m_QuickSlotsManager.AssignItemToCyberwareSlot(nextAbility.ID, commandData.slotIndex);
      };
    };
  }

  private final func HideDpadWheel() -> Void {
    let WheelAssignmentCompleteBB: ref<IBlackboard>;
    if this.m_root.IsVisible() {
      WheelAssignmentCompleteBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData);
      WheelAssignmentCompleteBB.SetBool(GetAllBlackboardDefs().UI_QuickSlotsData.WheelAssignmentComplete, true, true);
      this.m_root.SetVisible(false);
      this.m_dpadWheelOpen = false;
    };
  }

  private final func UpdateButtonHints() -> Void {
    let commandData: QuickSlotCommand;
    if IsDefined(this.m_selectedWheelItem) {
      commandData = this.m_selectedWheelItem.GetData();
      if Equals(commandData.equipType, gamedataEquipmentArea.CyberwareWheel) {
        this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_LeftShoulder, GetLocalizedText("Gameplay-Devices-Interactions-Previous"));
        this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_RightShoulder, GetLocalizedText("Gameplay-Devices-Interactions-Next"));
      } else {
        this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_LeftShoulder, "");
        this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_RightShoulder, "");
      };
    };
  }

  private final func CalculatePosition(index: Int32, dist: Float) -> inkMargin {
    let marginPosition: inkMargin;
    let position: Vector2;
    let itemAngle: Float = this.m_angleInterval * Cast(index);
    let itemRadian: Float = Deg2Rad(itemAngle);
    position.X = dist * CosF(itemRadian);
    position.Y = dist * SinF(itemRadian);
    marginPosition.left = -position.X;
    marginPosition.top = -position.Y;
    return marginPosition;
  }

  private final func IsLeft(margin: inkMargin) -> Bool {
    let isLeft: Bool;
    if margin.left > 0.00 {
      isLeft = true;
    } else {
      isLeft = false;
    };
    return isLeft;
  }

  private final func GetNextAbility(currentAbility: AbilityData, dir: Int32) -> AbilityData {
    let curAbilityIdx: Int32;
    let nextAbility: AbilityData;
    let nextIndex: Int32;
    let selectedData: AbilityData = this.m_selectedWheelItem.GetAbilityData();
    if currentAbility.Empty {
      nextIndex = dir > 0 ? 0 : ArraySize(this.m_masterListOfAllCyberware) - 1;
      nextAbility = this.m_masterListOfAllCyberware[nextIndex];
      if Equals(nextAbility, selectedData) {
        return selectedData;
      };
      if this.CheckIfAbilityIsAssigned(nextAbility) {
        nextAbility = this.GetNextAbility(nextAbility, dir);
      };
    } else {
      curAbilityIdx = ArrayFindFirst(this.m_masterListOfAllCyberware, currentAbility);
      nextIndex = curAbilityIdx += dir;
      if nextIndex >= ArraySize(this.m_masterListOfAllCyberware) {
        nextIndex = 0;
      };
      if nextIndex < 0 {
        nextIndex = ArraySize(this.m_masterListOfAllCyberware) - 1;
      };
      nextAbility = this.m_masterListOfAllCyberware[nextIndex];
      if Equals(nextAbility, selectedData) {
        return selectedData;
      };
      if this.CheckIfAbilityIsAssigned(nextAbility) {
        nextAbility = this.GetNextAbility(nextAbility, dir);
      };
    };
    return nextAbility;
  }

  private final func UpdateVirtualAbilitiesList() -> Void {
    let i: Int32;
    let j: Int32;
    let matchingAbilityData: AbilityData;
    let tempAbilityData: AbilityData;
    let tempCommandData: QuickSlotCommand;
    let tempDpadItem: wref<DpadWheelItemController>;
    ArrayClear(this.m_listOfUnassignedCyberware);
    i = 0;
    while i < ArraySize(this.m_masterListOfAllCyberware) {
      ArrayPush(this.m_listOfUnassignedCyberware, this.m_masterListOfAllCyberware[i]);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_dpadItemsList) {
      tempDpadItem = this.m_dpadItemsList[i];
      tempCommandData = tempDpadItem.GetData();
      if Equals(tempCommandData.equipType, gamedataEquipmentArea.CyberwareWheel) {
        tempAbilityData = tempDpadItem.GetAbilityData();
        if !tempAbilityData.Empty {
          j = ArraySize(this.m_listOfUnassignedCyberware) - 1;
          while j >= 0 {
            matchingAbilityData = this.m_listOfUnassignedCyberware[j];
            if Equals(matchingAbilityData, tempAbilityData) {
              ArrayErase(this.m_listOfUnassignedCyberware, j);
            };
            j -= 1;
          };
        };
      };
      i += 1;
    };
  }

  private final func CheckIfAbilityIsAssigned(ability: AbilityData) -> Bool {
    let tempAbility: AbilityData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_listOfUnassignedCyberware) {
      tempAbility = this.m_listOfUnassignedCyberware[i];
      if Equals(ability, tempAbility) {
        return false;
      };
      i += 1;
    };
    return true;
  }
}

public class DpadWheelItemController extends inkLogicController {

  private edit let m_selectorWrapper: inkWidgetRef;

  private edit let m_icon: inkImageRef;

  private edit let m_displayWrapper: inkWidgetRef;

  private edit let m_itemWrapper: inkWidgetRef;

  private edit let m_arrows: inkWidgetRef;

  private edit let m_abilityIcon: inkImageRef;

  private edit let m_quickHackIcon: inkImageRef;

  private edit let m_highlight02: inkImageRef;

  private edit let m_highlight03: inkImageRef;

  private edit let m_highlight04: inkImageRef;

  private edit let m_highlight05: inkImageRef;

  private edit let m_highlight06: inkImageRef;

  private edit let m_highlight07: inkImageRef;

  private edit let m_highlight08: inkImageRef;

  @default(DpadWheelItemController, 60)
  private edit let m_textDist: Float;

  @default(DpadWheelItemController, 140)
  private edit let m_weaponTextDist: Float;

  private let m_data: QuickSlotCommand;

  private let m_root: wref<inkWidget>;

  private let m_item: wref<InventoryItemDisplay>;

  private let m_itemWidget: wref<inkWidget>;

  private let m_InventoryDataManager: ref<InventoryDataManagerV2>;

  private let m_highlight: inkImageRef;

  private let m_itemData: InventoryItemData;

  private let m_abilityData: AbilityData;

  private let m_quickHackWheelDefIcon: CName;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_highlight02, false);
    inkWidgetRef.SetVisible(this.m_highlight03, false);
    inkWidgetRef.SetVisible(this.m_highlight04, false);
    inkWidgetRef.SetVisible(this.m_highlight05, false);
    inkWidgetRef.SetVisible(this.m_highlight06, false);
    inkWidgetRef.SetVisible(this.m_highlight07, false);
    inkWidgetRef.SetVisible(this.m_highlight08, false);
    inkWidgetRef.SetVisible(this.m_arrows, false);
    inkWidgetRef.SetVisible(this.m_abilityIcon, false);
    if this.m_itemWidget == null {
      this.m_itemWidget = ItemDisplayUtils.SpawnCommonSlot(this, this.m_itemWrapper, n"inventoryItem");
      this.m_itemWidget.SetScale(new Vector2(0.60, 0.60));
      this.m_itemWidget.SetVAlign(inkEVerticalAlign.Center);
      this.m_itemWidget.SetHAlign(inkEHorizontalAlign.Center);
    };
  }

  public final func SetupData(data: QuickSlotCommand, rotation: Float, numOfWheelItems: Int32, inventoryManager: ref<InventoryDataManagerV2>, isLeft: Bool) -> Void {
    this.m_data = data;
    this.m_InventoryDataManager = inventoryManager;
    this.m_root = this.GetRootWidget();
    this.SetHover(false);
    this.SetIcon(rotation);
    this.SetHighlight(numOfWheelItems);
  }

  private final func SetIcon(rotation: Float) -> Void {
    inkWidgetRef.SetVisible(this.m_abilityIcon, false);
    inkWidgetRef.SetVisible(this.m_icon, false);
    this.m_itemWidget.SetVisible(false);
    inkWidgetRef.SetVisible(this.m_quickHackIcon, false);
    switch this.m_data.ActionType {
      case QuickSlotActionType.SelectItem:
        if ItemID.IsValid(this.m_data.ItemId) {
          if Equals(this.m_data.equipType, gamedataEquipmentArea.CyberwareWheel) {
            this.m_abilityData = this.m_InventoryDataManager.GetAbilityData(this.m_data.ItemId);
            inkWidgetRef.SetVisible(this.m_abilityIcon, true);
          } else {
            this.m_itemData = this.m_InventoryDataManager.GetItemDataFromIDInLoadout(this.m_data.ItemId);
            this.m_item = this.m_itemWidget.GetController() as InventoryItemDisplay;
            this.m_item.Setup(this.m_itemData);
            this.m_itemWidget.SetVisible(true);
          };
        };
        break;
      case QuickSlotActionType.QuickHack:
        if Equals(this.m_quickHackWheelDefIcon, n"") {
          this.m_quickHackWheelDefIcon = inkImageRef.GetTexturePart(this.m_quickHackIcon);
        };
        inkWidgetRef.SetVisible(this.m_quickHackIcon, true);
        if NotEquals(this.m_data.IconName, n"") {
          inkImageRef.SetTexturePart(this.m_quickHackIcon, this.m_data.IconName);
        } else {
          inkImageRef.SetTexturePart(this.m_quickHackIcon, this.m_quickHackWheelDefIcon);
        };
        if this.m_data.IsLocked {
          inkWidgetRef.SetOpacity(this.m_quickHackIcon, 0.30);
        } else {
          inkWidgetRef.SetOpacity(this.m_quickHackIcon, 1.00);
        };
        break;
      default:
        inkWidgetRef.SetVisible(this.m_icon, true);
    };
    inkImageRef.SetTexturePart(this.m_icon, this.m_data.IconName);
    inkWidgetRef.SetRotation(this.m_displayWrapper, -rotation);
    if Equals(this.m_data.equipType, gamedataEquipmentArea.CyberwareWheel) {
      inkWidgetRef.SetVisible(this.m_arrows, true);
    } else {
      inkWidgetRef.SetVisible(this.m_arrows, false);
    };
  }

  private final func SetHighlight(numOfWheelItems: Int32) -> Void {
    switch numOfWheelItems {
      case 2:
      case 1:
        this.m_highlight = this.m_highlight02;
        break;
      case 3:
        this.m_highlight = this.m_highlight03;
        break;
      case 4:
        this.m_highlight = this.m_highlight04;
        break;
      case 5:
        this.m_highlight = this.m_highlight05;
        break;
      case 6:
        this.m_highlight = this.m_highlight06;
        break;
      case 7:
        this.m_highlight = this.m_highlight07;
        break;
      case 8:
        this.m_highlight = this.m_highlight08;
        break;
      default:
        inkWidgetRef.SetVisible(this.m_highlight, false);
    };
    if numOfWheelItems <= 8 {
      inkWidgetRef.SetVisible(this.m_highlight, true);
    };
  }

  public final func SetHover(isHover: Bool) -> Void {
    if isHover {
      this.m_root.SetOpacity(1.00);
      inkWidgetRef.SetVisible(this.m_selectorWrapper, true);
    } else {
      this.m_root.SetOpacity(0.30);
      inkWidgetRef.SetVisible(this.m_selectorWrapper, false);
    };
  }

  public final func AddAbility(abilityData: AbilityData) -> Void {
    if !abilityData.Empty {
      inkWidgetRef.SetVisible(this.m_abilityIcon, true);
      this.m_abilityData = abilityData;
    };
  }

  public final func GetData() -> QuickSlotCommand {
    return this.m_data;
  }

  public final func GetItemData() -> InventoryItemData {
    return this.m_itemData;
  }

  public final func GetAbilityData() -> AbilityData {
    return this.m_abilityData;
  }
}
