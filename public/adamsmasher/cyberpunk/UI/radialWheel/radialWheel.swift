
public class RadialWheelController extends inkHUDGameController {

  private inline edit const let radialWeapons: array<ref<WeaponRadialSlot>>;

  private inline edit let inputHintController: ref<RadialSlot>;

  private inline edit let activeSlotTooltip: ref<RadialSlot>;

  private inline edit let statusEffects: ref<RadialSlot>;

  private edit let pointerRef: inkWidgetRef;

  private let activeSlot: ref<WeaponRadialSlot>;

  private let pointer: wref<PointerController>;

  private let activeIndex: Int32;

  private let initialized: Bool;

  private let isActive: Bool;

  private let pendingRadialSlotAsyncSpawnCount: Int32;

  private let consSlotCachedData: InventoryItemData;

  private let gadgetSlotCachedData: InventoryItemData;

  private let cyclingActionRegistered: CName;

  private let registeredInputHints: array<InputHintData>;

  private let applyInputHint: InputHintData;

  private let cycleInputHintDataLeft: InputHintData;

  private let cycleInputHintDataRight: InputHintData;

  @default(RadialWheelController, ERadialMode.ApplyActiveSlotAndConsumables)
  private let radialMode: ERadialMode;

  private let inventoryManager: ref<InventoryDataManagerV2>;

  private let equipmentSystem: wref<EquipmentSystem>;

  private let transactionSystem: wref<TransactionSystem>;

  private let quickSlotBlackboard: wref<IBlackboard>;

  private let QuickSlotBlackboardDef: ref<UI_QuickSlotsDataDef>;

  private let axisInputCallbackID: ref<CallbackHandle>;

  private let UISystemBB: wref<IBlackboard>;

  private let UISystemDef: ref<UI_SystemDef>;

  private let isInMenuCallbackID: ref<CallbackHandle>;

  private let equipmentUIBlackboard: wref<IBlackboard>;

  private let EquipmentBlackboardDef: ref<UI_EquipmentDef>;

  private let equipmentUICallbackID: ref<CallbackHandle>;

  public let dbg_int: Int32;

  public let dbg_layers: array<Uint32>;

  public let dbg_activeSlotLayers: array<Uint32>;

  protected cb func OnInitialize() -> Bool {
    let playerControlledObject: ref<GameObject>;
    if this.initialized {
      return false;
    };
    this.GetRootWidget().SetVisible(false);
    this.inventoryManager = new InventoryDataManagerV2();
    this.inventoryManager.Initialize(this.GetPlayerControlledObject() as PlayerPuppet, this);
    this.transactionSystem = GameInstance.GetTransactionSystem(this.GetPlayer().GetGame());
    playerControlledObject = this.GetPlayerControlledObject();
    playerControlledObject.RegisterInputListener(this, n"OpenPauseMenu");
    playerControlledObject.RegisterInputListener(this, n"UI_PreviousAbility");
    playerControlledObject.RegisterInputListener(this, n"UI_NextAbility");
    playerControlledObject.RegisterInputListener(this, n"SelectWheelItem");
    playerControlledObject.RegisterInputListener(this, n"CloseWheel");
    this.pointer = inkWidgetRef.GetController(this.pointerRef) as PointerController;
    this.RegisterBlackboards(true);
    this.SpawnRadialWeapons();
    this.SpawnSlotWidget(this.inputHintController);
    this.SpawnSlotWidget(this.activeSlotTooltip);
    this.SpawnSlotWidget(this.statusEffects);
    this.CacheInputHintData();
    PopupStateUtils.SetBackgroundBlurBlendTime(this, 0.10);
  }

  protected cb func OnLateInit(evt: ref<LateInit>) -> Bool {
    this.CacheData();
    this.RefreshSlots();
    this.SetActiveSlot(this.radialWeapons[0]);
    this.pointer.SetRotation(new Vector4(0.00, 0.00, 0.00, 0.00), this.activeSlot.GetAngle(), 0);
    this.pointer.Enable();
    this.initialized = true;
    this.UpdateActiveTooltip();
  }

  protected cb func OnUninitialize() -> Bool {
    this.Shutdown();
    if IsDefined(this.GetPlayerControlledObject()) {
      this.GetPlayerControlledObject().UnregisterInputListener(this);
    };
    this.RegisterBlackboards(false);
    this.initialized = false;
  }

  protected final func RegisterBlackboards(shouldRegister: Bool) -> Void {
    if shouldRegister {
      this.QuickSlotBlackboardDef = GetAllBlackboardDefs().UI_QuickSlotsData;
      this.quickSlotBlackboard = this.GetBlackboardSystem().Get(this.QuickSlotBlackboardDef);
      if !IsDefined(this.quickSlotBlackboard) {
        return;
      };
      this.axisInputCallbackID = this.quickSlotBlackboard.RegisterDelayedListenerVector4(this.QuickSlotBlackboardDef.leftStick, this, n"OnRadialAngleChanged");
      this.UISystemDef = GetAllBlackboardDefs().UI_System;
      this.UISystemBB = this.GetBlackboardSystem().Get(this.UISystemDef);
      if !IsDefined(this.UISystemBB) {
        return;
      };
      this.isInMenuCallbackID = this.UISystemBB.RegisterDelayedListenerBool(this.UISystemDef.IsInMenu, this, n"OnIsInMenuChanged");
      this.EquipmentBlackboardDef = GetAllBlackboardDefs().UI_Equipment;
      this.equipmentUIBlackboard = this.GetBlackboardSystem().Get(this.EquipmentBlackboardDef);
      if !IsDefined(this.equipmentUIBlackboard) {
        return;
      };
      this.equipmentUICallbackID = this.equipmentUIBlackboard.RegisterDelayedListenerVariant(this.EquipmentBlackboardDef.lastModifiedArea, this, n"OnEquipmentChanged");
    } else {
      if IsDefined(this.quickSlotBlackboard) && IsDefined(this.axisInputCallbackID) {
        this.quickSlotBlackboard.UnregisterDelayedListener(this.QuickSlotBlackboardDef.leftStick, this.axisInputCallbackID);
      };
      if IsDefined(this.UISystemBB) && IsDefined(this.isInMenuCallbackID) {
        this.UISystemBB.UnregisterDelayedListener(this.UISystemDef.IsInMenu, this.isInMenuCallbackID);
      };
      if IsDefined(this.equipmentUIBlackboard) && IsDefined(this.equipmentUICallbackID) {
        this.equipmentUIBlackboard.UnregisterDelayedListener(this.EquipmentBlackboardDef.lastModifiedArea, this.equipmentUICallbackID);
      };
    };
  }

  private final func Shutdown() -> Void {
    this.PlayLibraryAnimation(n"exit");
    this.ClearInputHints();
    this.ClearDebug();
    this.ClearActiveSlotDebug();
    this.GetRootWidget().SetVisible(false);
    if IsDefined(this.GetPlayerControlledObject()) {
      GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).PopGameContext(UIGameContext.RadialWheel);
    };
    PopupStateUtils.SetBackgroundBlur(this, false);
    TimeDilationHelper.SetTimeDilationWithProfile(this.GetPlayer(), "radialMenu", false);
    if this.isActive {
      this.PlaySound(n"RadialMenu", n"OnClose");
    };
    this.isActive = false;
    this.SendPSMRadialCloseRequest();
  }

  private final func SendPSMRadialCloseRequest() -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"RadialWheelCloseRequest";
    psmEvent.value = true;
    this.GetPlayerControlledObject().QueueEvent(psmEvent);
  }

  public func UpdateRequired() -> Void {
    if !this.initialized || !this.isActive {
      return;
    };
    this.RefreshSlots();
  }

  private final func GetValidNeighbouringIndex(arr: array<InventoryItemData>, fromIndex: Int32, searchNext: Bool) -> Int32 {
    if fromIndex > ArraySize(arr) - 1 || fromIndex < 0 {
      return -1;
    };
    if searchNext {
      if fromIndex == ArraySize(arr) - 1 {
        return 0;
      };
      return fromIndex += 1;
    };
    if fromIndex == 0 {
      return ArraySize(arr) - 1;
    };
    return fromIndex -= 1;
  }

  private final func CacheData() -> Void {
    let margin: inkMargin;
    let normalized: Vector4;
    let root_anchorCenter_vector: Vector4;
    let slotAnchorPos: Vector2;
    let slotAnchorWidget: ref<inkWidget>;
    let i: Int32 = 0;
    while i < ArraySize(this.radialWeapons) {
      slotAnchorWidget = inkWidgetRef.Get(this.radialWeapons[i].slotAnchorRef);
      if IsDefined(slotAnchorWidget) {
        margin = slotAnchorWidget.GetMargin();
        slotAnchorPos = this.ConvertMarginToVector(margin);
        root_anchorCenter_vector = new Vector4(slotAnchorPos.X, slotAnchorPos.Y, 0.00, 0.00);
        normalized = Vector4.Normalize2D(root_anchorCenter_vector);
        this.radialWeapons[i].SetTargetAngle(this.ConvertVectorToAngle(normalized));
      };
      this.radialWeapons[i].SetIndex(i);
      i += 1;
    };
  }

  private final func CacheInputHintData() -> Void {
    let source: CName = n"RadialWheel";
    this.applyInputHint.action = n"SelectWheelItem";
    this.applyInputHint.source = source;
    this.applyInputHint.queuePriority = 4;
    this.applyInputHint.sortingPriority = 4;
    this.applyInputHint.localizedLabel = "LocKey#23206";
    this.cycleInputHintDataLeft.action = n"UI_PreviousAbility";
    this.cycleInputHintDataLeft.source = source;
    this.cycleInputHintDataLeft.queuePriority = 3;
    this.cycleInputHintDataLeft.sortingPriority = 3;
    this.cycleInputHintDataLeft.localizedLabel = "LocKey#77776";
    this.cycleInputHintDataRight.action = n"UI_NextAbility";
    this.cycleInputHintDataRight.source = source;
    this.cycleInputHintDataRight.queuePriority = 2;
    this.cycleInputHintDataRight.sortingPriority = 2;
    this.cycleInputHintDataRight.localizedLabel = "LocKey#77775";
  }

  private final func ConvertMarginToVector(margin: inkMargin) -> Vector2 {
    let x: Float = margin.left + margin.right;
    let y: Float = margin.top + margin.bottom;
    let v: Vector2 = new Vector2(x, y);
    v.Y = -v.Y;
    return v;
  }

  private final func DetermineActiveSlot(angle: Float) -> ref<WeaponRadialSlot> {
    let angleDistance: Float;
    let bestSlot: ref<WeaponRadialSlot>;
    let bestAngleDistance: Float = 999.00;
    let i: Int32 = 0;
    while i < ArraySize(this.radialWeapons) {
      angleDistance = AbsF(AngleDistance(this.radialWeapons[i].GetAngle(), angle));
      if angleDistance <= bestAngleDistance {
        bestAngleDistance = angleDistance;
        bestSlot = this.radialWeapons[i];
      };
      i += 1;
    };
    return bestSlot;
  }

  private final func SetActiveSlot(newActiveSlot: ref<WeaponRadialSlot>) -> Bool {
    let cyclableSlot: ref<CyclableRadialSlot>;
    let hintsRequireUpdate: Bool;
    if newActiveSlot == this.activeSlot {
      return false;
    };
    this.PlayLibraryAnimation(n"active_slot");
    if newActiveSlot.IsCyclable() {
      cyclableSlot = newActiveSlot as CyclableRadialSlot;
      cyclableSlot.SetCanCycle(this.CanPlayerCycleSlot(cyclableSlot));
    };
    if IsDefined(this.activeSlot) {
      if !this.activeSlot.CanCycle() && newActiveSlot.CanCycle() || this.activeSlot.CanCycle() && !newActiveSlot.CanCycle() {
        hintsRequireUpdate = true;
      };
    };
    if IsDefined(this.activeSlot) {
      this.activeSlot.Deactivate();
    };
    this.activeSlot = newActiveSlot;
    this.activeIndex = this.activeSlot.GetIndex();
    if IsDefined(this.activeSlot) {
      this.activeSlot.Activate();
    };
    this.DrawActiveSlotDebug();
    if this.GetRootWidget().IsVisible() && hintsRequireUpdate {
      this.UpdateInputHints();
    };
    this.UpdateActiveTooltip();
    return true;
  }

  private final func ConvertVectorToAngle(input: Vector4) -> Float {
    let angle: Float;
    let referenceVector: Vector4 = new Vector4(0.00, 1.00, 0.00, 0.00);
    let dbg_root: Vector4 = new Vector4(500.00, 700.00, 0.00, 0.00);
    if input.X == 0.00 && input.Y == 0.00 {
      return -1.00;
    };
    angle = Vector4.GetAngleBetween(referenceVector, input);
    if input.X < 0.00 {
      angle = 360.00 - angle;
    };
    if !IsFinal() && this.isActive {
      this.ClearDebug();
      this.DrawDebug(GameInstance.GetDebugVisualizerSystem(this.GetPlayerControlledObject().GetGame()).DrawText(new Vector4(500.00, 500.00, 0.00, 0.00), "X: " + FloatToString(input.X) + " | Y: " + FloatToString(input.Y), SColor.White()));
      this.DrawDebug(GameInstance.GetDebugVisualizerSystem(this.GetPlayerControlledObject().GetGame()).DrawText(new Vector4(500.00, 600.00, 0.00, 0.00), "Angle: " + FloatToString(angle), SColor.White()));
      this.DrawDebug(GameInstance.GetDebugVisualizerSystem(this.GetPlayerControlledObject().GetGame()).DrawLine(dbg_root, dbg_root - referenceVector * 40.00, SColor.Blue()));
      this.DrawDebug(GameInstance.GetDebugVisualizerSystem(this.GetPlayerControlledObject().GetGame()).DrawLine(dbg_root, new Vector4(dbg_root.X + input.X * 40.00, dbg_root.Y - input.Y * 40.00, 0.00, 0.00), SColor.Red()));
    };
    return angle;
  }

  private final func SpawnRadialWeapons() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.radialWeapons) {
      this.SpawnSlotWidget(this.radialWeapons[i]);
      i += 1;
    };
  }

  private final func SpawnSlotWidget(slot: ref<RadialSlot>) -> Bool {
    let spawnedWidget: ref<inkWidget>;
    let userData: ref<RadialWheelUserData> = new RadialWheelUserData();
    userData.m_Slot = slot;
    let spawnData: ref<AsyncSpawnData> = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnSlotWidgetSpawned", ToVariant(userData), this);
    if inkWidgetLibraryResource.IsValid(slot.libraryRef.widgetLibrary) {
      this.pendingRadialSlotAsyncSpawnCount += 1;
      this.CreateWidgetAsync(inkWidgetRef.Get(slot.slotAnchorRef), slot.libraryRef.widgetItem, inkWidgetLibraryResource.GetPath(slot.libraryRef.widgetLibrary), spawnData);
    } else {
      spawnedWidget = inkWidgetRef.Get(slot.slotAnchorRef);
      this.SetupWidgetForSlot(spawnedWidget, slot);
    };
    return true;
  }

  protected cb func OnSlotWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let lateInit: ref<LateInit>;
    let radialUserData: ref<RadialWheelUserData>;
    let spawnData: ref<AsyncSpawnData>;
    if !IsDefined(userData) {
      return false;
    };
    spawnData = userData as AsyncSpawnData;
    radialUserData = FromVariant(spawnData.m_widgetData);
    if !IsDefined(radialUserData) {
      return false;
    };
    if !IsDefined(radialUserData.m_Slot) {
      return false;
    };
    this.SetupWidgetForSlot(widget, radialUserData.m_Slot);
    this.pendingRadialSlotAsyncSpawnCount = this.pendingRadialSlotAsyncSpawnCount - 1;
    if this.pendingRadialSlotAsyncSpawnCount == 0 {
      lateInit = new LateInit();
      this.QueueEvent(lateInit);
    };
  }

  private final func SetupWidgetForSlot(widget: ref<inkWidget>, slot: ref<RadialSlot>) -> Void {
    if IsDefined(widget) {
      if Equals(slot.slotType, SlotType.TOOLTIP) {
        widget.SetAnchor(inkEAnchor.TopRight);
        widget.SetAnchorPoint(new Vector2(1.00, 0.00));
      } else {
        widget.SetAnchor(inkEAnchor.Centered);
        widget.SetAnchorPoint(new Vector2(0.50, 0.50));
      };
      slot.Construct(widget);
      return;
    };
  }

  private final func RefreshSlots() -> Void {
    this.RefreshWeapons();
    this.RefreshCyberware();
    this.RefreshHotkeys();
    this.UpdateActiveTooltip();
    this.UpdatePointer(new Vector4(), 0.00);
    this.UpdateStatusEffects();
  }

  private final func RefreshWeapons() -> Void {
    let controller: ref<InventoryItemDisplayController>;
    let i: Int32;
    let itemData: array<InventoryItemData>;
    let size: Int32;
    let player: wref<GameObject> = this.GetPlayerControlledObject();
    if !IsDefined(player) {
      return;
    };
    itemData = this.inventoryManager.GetEquippedWeapons();
    size = ArraySize(itemData);
    if size > 3 {
      size = 3;
    };
    i = 0;
    while i < size {
      controller = this.radialWeapons[i].GetWidget().GetController() as InventoryItemDisplayController;
      if IsDefined(controller) {
        controller.Setup(itemData[i]);
      };
      i += 1;
    };
  }

  private final func RefreshHotkeys() -> Void {
    let slot4: ref<CyclableRadialSlot> = this.radialWeapons[4] as CyclableRadialSlot;
    let slot5: ref<CyclableRadialSlot> = this.radialWeapons[5] as CyclableRadialSlot;
    this.RefreshHotkey(slot4);
    this.RefreshHotkey(slot5);
  }

  private final func RefreshHotkey(slot: ref<CyclableRadialSlot>) -> Void {
    let hotkeyItem: InventoryItemData;
    let i: Int32;
    let validItems: array<InventoryItemData> = this.GetValidItemsForMiscSlot(slot);
    if ArraySize(validItems) == 0 {
      this.GetController(slot).Setup(hotkeyItem, ItemDisplayContext.DPAD_RADIAL);
      return;
    };
    hotkeyItem = this.inventoryManager.GetHotkeyItemData(slot.GetHotkey());
    i = 0;
    while i < ArraySize(validItems) {
      if InventoryItemData.GetID(validItems[i]) == InventoryItemData.GetID(hotkeyItem) {
        this.GetController(slot).Setup(hotkeyItem, ItemDisplayContext.DPAD_RADIAL);
        return;
      };
      i += 1;
    };
    this.GetController(slot).Setup(validItems[0], ItemDisplayContext.DPAD_RADIAL);
  }

  private final func RefreshCyberware() -> Void {
    let armsCyberware: InventoryItemData;
    let baseFists: InventoryItemData;
    let hasCyberwareEquipped: Bool;
    let hasFistsEquipped: Bool;
    let slot: ref<CyclableRadialSlot> = this.radialWeapons[6] as CyclableRadialSlot;
    let controller: ref<InventoryItemDisplayController> = this.GetController(slot);
    let player: wref<GameObject> = this.GetPlayerControlledObject();
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(player.GetGame());
    if !IsDefined(controller) || !IsDefined(player) || !IsDefined(ts) {
      return;
    };
    armsCyberware = this.GetValidCombatCyberware();
    baseFists = this.GetBaseFists();
    if !ItemID.IsValid(InventoryItemData.GetID(baseFists)) {
    };
    if !ItemID.IsValid(InventoryItemData.GetID(armsCyberware)) {
      controller.Setup(baseFists);
      return;
    };
    if Equals(InventoryItemData.GetItemType(armsCyberware), gamedataItemType.Cyb_StrongArms) {
      controller.Setup(armsCyberware);
      return;
    };
    hasCyberwareEquipped = ts.HasItemInAnySlot(player, InventoryItemData.GetID(armsCyberware));
    hasFistsEquipped = ts.HasItemInAnySlot(player, InventoryItemData.GetID(baseFists));
    if hasCyberwareEquipped {
      controller.Setup(baseFists);
    } else {
      if hasFistsEquipped {
        controller.Setup(armsCyberware);
      } else {
        controller.Setup(armsCyberware);
      };
    };
  }

  private final func BindItem(slot: ref<CyclableRadialSlot>, requestType: EHotkeyRequestType) -> Bool {
    let request: ref<HotkeyAssignmentRequest> = HotkeyAssignmentRequest.Construct(this.GetItemID(slot), slot.GetHotkey(), this.GetPlayerControlledObject(), requestType);
    if request.IsValid() {
      this.GetEquipmentSystem().QueueRequest(request);
      return true;
    };
    return false;
  }

  private final func DrawItem(slot: ref<RadialSlot>) -> Bool {
    let draw: ref<DrawItemRequest>;
    let itemData: InventoryItemData = this.GetController(slot).GetItemData();
    let owner: wref<GameObject> = this.GetPlayerControlledObject();
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"NoCombat") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"FirearmsNoSwitch") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"ShootingRangeCompetition") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Fists") || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"FirearmsNoUnequipNoSwitch") {
      return false;
    };
    if ItemID.IsValid(InventoryItemData.GetID(itemData)) {
      draw = new DrawItemRequest();
      draw.owner = owner;
      draw.itemID = InventoryItemData.GetID(itemData);
      this.GetEquipmentSystem().QueueRequest(draw);
      if slot == this.radialWeapons[6] {
        (this.radialWeapons[6] as CyclableRadialSlot).SetCanCycle(false);
      };
      return true;
    };
    return false;
  }

  private final func ApplySlot(slot: ref<RadialSlot>) -> Void {
    let successful: Bool;
    this.PlayLibraryAnimation(n"apply_slot");
    switch slot.slotType {
      case SlotType.MISC:
        successful = this.BindItem(slot as CyclableRadialSlot, EHotkeyRequestType.Assign);
        break;
      case SlotType.HOLSTER:
        successful = true;
        this.DisarmPlayer();
        break;
      default:
        successful = this.DrawItem(slot);
    };
    if successful {
      this.Shutdown();
    };
  }

  private final func DisarmPlayer() -> Void {
    let eqs: ref<EquipmentSystem>;
    let request: ref<EquipmentSystemWeaponManipulationRequest>;
    let owner: wref<GameObject> = this.GetPlayerControlledObject();
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"FirearmsNoUnequip") {
      return;
    };
    eqs = this.GetEquipmentSystem();
    request = new EquipmentSystemWeaponManipulationRequest();
    request.owner = this.GetPlayer();
    request.requestType = EquipmentManipulationAction.UnequipAll;
    request.equipAnimType = gameEquipAnimationType.Default;
    eqs.QueueRequest(request);
  }

  private final func CycleSlot(cyclableSlot: ref<CyclableRadialSlot>, actionName: CName) -> Void {
    let next: Bool;
    this.PlayLibraryAnimation(n"cycle_hotkey");
    if Equals(actionName, n"UI_NextAbility") {
      next = true;
    };
    if NotEquals(cyclableSlot.GetHotkey(), EHotkey.INVALID) {
      this.CycleHotkeys(cyclableSlot, next);
    } else {
      this.CycleCyberware(cyclableSlot);
    };
    this.cyclingActionRegistered = actionName;
    cyclableSlot.CycleStart(next);
    this.DrawActiveSlotDebug();
    this.UpdateActiveTooltip();
    return;
  }

  private final func CycleHotkeys(cyclableSlot: ref<CyclableRadialSlot>, next: Bool) -> Void {
    let i: Int32;
    let matchFound: Bool;
    let slotItemData: InventoryItemData;
    let validIndex: Int32;
    let totalItems: array<InventoryItemData> = this.GetValidItemsForMiscSlot(cyclableSlot);
    if ArraySize(totalItems) == 0 {
      return;
    };
    slotItemData = this.GetController(cyclableSlot).GetItemData();
    validIndex = -1;
    if ItemID.IsValid(InventoryItemData.GetID(slotItemData)) {
      i = 0;
      while i < ArraySize(totalItems) {
        if InventoryItemData.GetID(totalItems[i]) == InventoryItemData.GetID(slotItemData) {
          validIndex = this.GetValidNeighbouringIndex(totalItems, i, next);
          if validIndex >= 0 {
            this.GetController(this.activeSlot).Setup(totalItems[validIndex], ItemDisplayContext.DPAD_RADIAL);
            matchFound = true;
          } else {
            i += 1;
          };
        } else {
        };
        i += 1;
      };
    };
    if !matchFound {
      this.GetController(this.activeSlot).Setup(totalItems[0], ItemDisplayContext.DPAD_RADIAL);
    };
    if Equals(this.radialMode, ERadialMode.ApplyActiveSlotAndConsumables) {
      this.BindItem(this.activeSlot as CyclableRadialSlot, EHotkeyRequestType.Cycle);
    };
  }

  private final func CycleCyberware(cyclableSlot: ref<CyclableRadialSlot>) -> Void {
    let baseFists: InventoryItemData = this.GetBaseFists();
    let armsCyberware: InventoryItemData = this.GetValidCombatCyberware();
    if this.GetItemID(cyclableSlot) == InventoryItemData.GetID(baseFists) {
      this.GetController(cyclableSlot).Setup(armsCyberware);
      return;
    };
    if this.GetItemID(cyclableSlot) == InventoryItemData.GetID(armsCyberware) {
      this.GetController(cyclableSlot).Setup(baseFists);
      return;
    };
  }

  private final func UpdatePointer(rawInputVector: Vector4, rawAngle: Float) -> Void {
    this.pointer.SetRotation(rawInputVector, rawAngle, this.activeIndex);
  }

  private final func UpdateStatusEffects() -> Void;

  private final func UpdateActiveTooltip() -> Void {
    let activeSlotController: ref<InventoryItemDisplayController>;
    let tooltipController: ref<ItemTooltipController>;
    if this.activeSlot == this.radialWeapons[3] || this.GetItemID(this.activeSlot) == ItemID.undefined() {
      inkWidgetRef.Get(this.activeSlotTooltip.slotAnchorRef).SetVisible(false);
      return;
    };
    inkWidgetRef.Get(this.activeSlotTooltip.slotAnchorRef).SetVisible(true);
    tooltipController = this.activeSlotTooltip.GetWidget().GetController() as ItemTooltipController;
    activeSlotController = this.GetController(this.activeSlot);
    if IsDefined(tooltipController) && IsDefined(activeSlotController) && IsDefined(this.inventoryManager) {
      tooltipController.SetData(this.inventoryManager.GetTooltipDataForInventoryItem(activeSlotController.GetItemData(), true));
      tooltipController.ForceNoEquipped();
    };
  }

  private final func RestoreCachedSlots() -> Void {
    this.radialWeapons[4].GetController().Setup(this.consSlotCachedData, ItemDisplayContext.DPAD_RADIAL);
    this.radialWeapons[5].GetController().Setup(this.gadgetSlotCachedData, ItemDisplayContext.DPAD_RADIAL);
    this.BindItem(this.radialWeapons[4] as CyclableRadialSlot, EHotkeyRequestType.Restore);
    this.BindItem(this.radialWeapons[5] as CyclableRadialSlot, EHotkeyRequestType.Restore);
  }

  private final func ClearInputHints() -> Void {
    let i: Int32 = ArraySize(this.registeredInputHints) - 1;
    while i >= 0 {
      this.AddInputHint(this.registeredInputHints[i], false);
      i -= 1;
    };
  }

  private final func UpdateInputHints() -> Void {
    let add: Bool = this.activeSlot.CanCycle();
    this.AddInputHint(this.cycleInputHintDataLeft, add);
    this.AddInputHint(this.cycleInputHintDataRight, add);
  }

  private final func AddInputHint(inputHint: InputHintData, add: Bool) -> Void {
    let i: Int32;
    if add {
      ArrayPush(this.registeredInputHints, inputHint);
    } else {
      i = ArraySize(this.registeredInputHints) - 1;
      while i >= 0 {
        if Equals(this.registeredInputHints[i].action, inputHint.action) {
          ArrayErase(this.registeredInputHints, i);
        };
        i -= 1;
      };
    };
    this.SendInputHintEvent(inputHint, add);
  }

  private final func SendInputHintEvent(inputHint: InputHintData, show: Bool) -> Void {
    let evt: ref<UpdateInputHintEvent>;
    this.PlayLibraryAnimation(n"input_update");
    evt = new UpdateInputHintEvent();
    evt.data = inputHint;
    evt.show = show;
    evt.targetHintContainer = n"RadialInputHintController";
    this.QueueEvent(evt);
  }

  protected cb func OnOpenWheelRequest(evt: ref<QuickSlotButtonHoldStartEvent>) -> Bool {
    if Equals(evt.dPadItemDirection, EDPadSlot.WeaponsWheel) {
      this.AddInputHint(this.applyInputHint, true);
      TimeDilationHelper.SetTimeDilationWithProfile(this.GetPlayer(), "radialMenu", true);
      this.RefreshSlots();
      this.GetRootWidget().SetVisible(true);
      this.PlayLibraryAnimation(n"enter");
      this.PlaySound(n"RadialMenu", n"OnOpen");
      if Equals(this.radialMode, ERadialMode.ApplyActiveSlotAndConsumables) {
        this.consSlotCachedData = this.GetInventoryItemData(this.radialWeapons[4]);
        this.gadgetSlotCachedData = this.GetInventoryItemData(this.radialWeapons[5]);
      };
      GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).PushGameContext(UIGameContext.RadialWheel);
      PopupStateUtils.SetBackgroundBlur(this, true);
      this.isActive = true;
    };
  }

  protected cb func OnForceRadialWheelShutdown(evt: ref<ForceRadialWheelShutdown>) -> Bool {
    if this.isActive {
      this.Shutdown();
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let cyclableSlot: ref<CyclableRadialSlot>;
    let aName: CName = ListenerAction.GetName(action);
    let aType: gameinputActionType = ListenerAction.GetType(action);
    let isJustReleased: Bool = ListenerAction.IsButtonJustReleased(action);
    if !this.isActive {
      return false;
    };
    if isJustReleased && Equals(aName, this.cyclingActionRegistered) && this.activeSlot as CyclableRadialSlot.isCycling {
      (this.activeSlot as CyclableRadialSlot).CycleStop();
      this.cyclingActionRegistered = n"";
      this.RefreshHotkeys();
    };
    if IsDefined(this.activeSlot) && Equals(aType, gameinputActionType.BUTTON_PRESSED) {
      if Equals(aName, n"OpenPauseMenu") {
        ListenerActionConsumer.DontSendReleaseEvent(consumer);
        this.Shutdown();
      };
      if Equals(aName, n"UI_PreviousAbility") || Equals(aName, n"UI_NextAbility") {
        cyclableSlot = this.activeSlot as CyclableRadialSlot;
        if IsDefined(cyclableSlot) && cyclableSlot.CanCycle() {
          this.CycleSlot(cyclableSlot, aName);
        };
      } else {
        if Equals(aName, n"SelectWheelItem") {
          this.ApplySlot(this.activeSlot);
        };
      };
    } else {
      if Equals(aType, gameinputActionType.BUTTON_RELEASED) {
        if Equals(aName, n"CloseWheel") {
          this.Shutdown();
        } else {
          if Equals(aName, this.cyclingActionRegistered) && this.activeSlot as CyclableRadialSlot.isCycling {
            (this.activeSlot as CyclableRadialSlot).CycleStop();
            this.cyclingActionRegistered = n"";
          };
        };
      };
    };
  }

  protected cb func OnRadialAngleChanged(v: Vector4) -> Bool {
    let angle: Float;
    if !this.isActive {
      return false;
    };
    angle = this.ConvertVectorToAngle(v);
    this.pointer.UpdateCenterPiece(v);
    if angle < 0.00 {
      return false;
    };
    this.SetActiveSlot(this.DetermineActiveSlot(angle));
    this.UpdatePointer(v, angle);
  }

  protected cb func OnIsInMenuChanged(param: Bool) -> Bool {
    if this.isActive && param {
      this.Shutdown();
    };
  }

  protected cb func OnEquipmentChanged(value: Variant) -> Bool {
    let i: Int32;
    let itemID: ItemID;
    let itemObject: ref<ItemObject>;
    let player: ref<GameObject>;
    let data: SPaperdollEquipData = FromVariant(value);
    if data.placementSlot == t"AttachmentSlots.WeaponRight" {
      this.RefreshWeapons();
      player = this.GetPlayer();
      itemObject = this.transactionSystem.GetItemInSlot(player, data.placementSlot);
      if IsDefined(itemObject) {
        itemID = itemObject.GetItemID();
        if !ItemID.IsValid(itemID) {
          return false;
        };
        i = 0;
        while i < ArraySize(this.radialWeapons) {
          if this.radialWeapons[i].GetController().GetItemID() == itemID {
            this.SetActiveSlot(this.radialWeapons[i]);
          };
          i += 1;
        };
      };
    };
  }

  private final func GetController(slot: ref<RadialSlot>) -> ref<InventoryItemDisplayController> {
    if IsDefined(slot) && IsDefined(slot.GetWidget()) {
      return slot.GetWidget().GetController() as InventoryItemDisplayController;
    };
    return null;
  }

  private final func CanPlayerCycleCyberware() -> Bool {
    let player: ref<GameObject> = this.GetPlayer();
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(player.GetGame());
    let armsCyberware: InventoryItemData = this.GetValidCombatCyberware();
    let baseFists: InventoryItemData = this.GetBaseFists();
    let hasCyberwareEquipped: Bool = ts.HasItemInAnySlot(player, InventoryItemData.GetID(armsCyberware));
    let hasFistsEquipped: Bool = ts.HasItemInAnySlot(player, InventoryItemData.GetID(baseFists));
    if !ItemID.IsValid(InventoryItemData.GetID(armsCyberware)) || hasCyberwareEquipped || hasFistsEquipped || Equals(InventoryItemData.GetItemType(armsCyberware), gamedataItemType.Cyb_StrongArms) {
      return false;
    };
    return true;
  }

  private final func GetValidItemsForMiscSlot(cyclableSlot: ref<CyclableRadialSlot>) -> array<InventoryItemData> {
    let currentItemID: ItemID;
    let freshItems: array<InventoryItemData>;
    let k: Int32;
    let totalItems: array<InventoryItemData>;
    let slotTypes: array<gamedataItemType> = Hotkey.GetScope(cyclableSlot.GetHotkey());
    let i: Int32 = 0;
    while i < ArraySize(slotTypes) {
      freshItems = this.inventoryManager.GetPlayerItemsByType(slotTypes[i]);
      k = 0;
      while k < ArraySize(freshItems) {
        currentItemID = InventoryItemData.GetID(freshItems[k]);
        if !ItemID.IsValid(currentItemID) || ArrayContains(totalItems, freshItems[k]) {
        } else {
          if Equals(this.GetItemData(currentItemID).GetItemType(), gamedataItemType.Cyb_Ability) || Equals(this.GetItemData(currentItemID).GetItemType(), gamedataItemType.Cyb_Launcher) {
            if !this.GetEquipmentSystem().IsEquipped(this.GetPlayer(), currentItemID) {
            } else {
              ArrayPush(totalItems, freshItems[k]);
            };
          };
          ArrayPush(totalItems, freshItems[k]);
        };
        k += 1;
      };
      i += 1;
    };
    return totalItems;
  }

  private final func CanPlayerCycleMisc(cyclableSlot: ref<CyclableRadialSlot>) -> Bool {
    let validItems: array<InventoryItemData> = this.GetValidItemsForMiscSlot(cyclableSlot);
    return ArraySize(validItems) > 1;
  }

  private final func CanPlayerCycleSlot(slot: ref<CyclableRadialSlot>) -> Bool {
    if Equals(slot.slotType, SlotType.COMBAT_CYBERWARE) {
      return this.CanPlayerCycleCyberware();
    };
    return this.CanPlayerCycleMisc(slot);
  }

  protected final func GetWeapons() -> array<wref<gameItemData>> {
    let allItems: array<wref<gameItemData>>;
    let weapons: array<wref<gameItemData>>;
    let player: ref<GameObject> = this.GetPlayer();
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(player.GetGame());
    if IsDefined(ts) && IsDefined(player) {
      ts.GetItemList(player, allItems);
      RPGManager.ExtractItemsOfEquipArea(gamedataEquipmentArea.Weapon, allItems, weapons);
      RPGManager.ExtractItemsOfEquipArea(gamedataEquipmentArea.QuickSlot, allItems, weapons);
    };
    return weapons;
  }

  private final func GetValidCombatCyberware() -> InventoryItemData {
    let emptyData: InventoryItemData;
    let armsCyberware: InventoryItemData = this.inventoryManager.GetItemDataEquippedInArea(gamedataEquipmentArea.ArmsCW);
    if ItemID.IsValid(InventoryItemData.GetID(armsCyberware)) && NotEquals(InventoryItemData.GetItemType(armsCyberware), gamedataItemType.Cyb_Launcher) {
      return armsCyberware;
    };
    return emptyData;
  }

  private final func GetBaseFists() -> InventoryItemData {
    let emptyData: InventoryItemData;
    let player: ref<GameObject> = this.GetPlayer();
    let fistsIDs: array<ItemID> = EquipmentSystem.GetItemsInArea(player, gamedataEquipmentArea.BaseFists);
    if ArraySize(fistsIDs) > 0 {
      return this.inventoryManager.GetInventoryItemData(player, this.GetItemData(fistsIDs[0]), false, true);
    };
    return emptyData;
  }

  private final func GetEquipmentSystem() -> wref<EquipmentSystem> {
    if !IsDefined(this.equipmentSystem) {
      this.equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    };
    return this.equipmentSystem;
  }

  private final func GetItemData(itemID: ItemID) -> wref<gameItemData> {
    if !IsDefined(this.transactionSystem) {
      this.transactionSystem = GameInstance.GetTransactionSystem(this.GetPlayerControlledObject().GetGame());
    };
    return this.transactionSystem.GetItemData(this.GetPlayerControlledObject(), itemID);
  }

  private final func GetInventoryItemData(slot: ref<RadialSlot>) -> InventoryItemData {
    let slotItemData: InventoryItemData;
    if IsDefined(this.GetController(slot)) {
      slotItemData = this.GetController(slot).GetItemData();
    };
    return slotItemData;
  }

  private final func GetItemID(slot: ref<RadialSlot>) -> ItemID {
    let slotItemData: InventoryItemData = this.GetInventoryItemData(slot);
    return InventoryItemData.GetID(slotItemData);
  }

  private final func GetPlayer() -> ref<GameObject> {
    return this.GetPlayerControlledObject();
  }

  private final func DrawDebug(id: Uint32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.dbg_layers) {
      if id == this.dbg_layers[i] {
        return;
      };
      i += 1;
    };
    ArrayPush(this.dbg_layers, id);
  }

  private final func ClearDebug() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.dbg_layers) {
      GameInstance.GetDebugVisualizerSystem(this.GetPlayer().GetGame()).ClearLayer(this.dbg_layers[i]);
      i += 1;
    };
    ArrayClear(this.dbg_layers);
  }

  private final func ClearActiveSlotDebug() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.dbg_activeSlotLayers) {
      GameInstance.GetDebugVisualizerSystem(this.GetPlayer().GetGame()).ClearLayer(this.dbg_activeSlotLayers[i]);
      i += 1;
    };
    ArrayClear(this.dbg_activeSlotLayers);
  }

  private final func DrawActiveSlotDebug() -> Void {
    let base: array<String>;
    let i: Int32;
    let info: array<String>;
    let itemData: InventoryItemData;
    let potentialItemData: array<InventoryItemData>;
    if !this.isActive || IsFinal() {
      return;
    };
    this.ClearActiveSlotDebug();
    itemData = this.GetInventoryItemData(this.activeSlot);
    ArrayPush(base, TDBID.ToStringDEBUG(ItemID.GetTDBID(InventoryItemData.GetID(itemData))));
    ArrayPush(base, "-" * 32);
    this.activeSlot.GetDebugInfo(info);
    i = 0;
    while i < ArraySize(info) {
      ArrayPush(base, info[i]);
      i += 1;
    };
    if this.activeSlot.CanCycle() {
      if Equals(this.activeSlot.slotType, SlotType.COMBAT_CYBERWARE) {
        ArrayPush(potentialItemData, this.GetValidCombatCyberware());
        ArrayPush(potentialItemData, this.GetBaseFists());
      } else {
        if Equals(this.activeSlot.slotType, SlotType.MISC) {
          potentialItemData = this.GetValidItemsForMiscSlot(this.activeSlot as CyclableRadialSlot);
        };
      };
    };
    i = 0;
    while i < ArraySize(potentialItemData) {
      ArrayPush(base, TDBID.ToStringDEBUG(ItemID.GetTDBID(InventoryItemData.GetID(potentialItemData[i]))));
      i += 1;
    };
    i = 0;
    while i < ArraySize(base) {
      ArrayPush(this.dbg_activeSlotLayers, GameInstance.GetDebugVisualizerSystem(this.GetPlayer().GetGame()).DrawText(new Vector4(300.00, 300.00 + Cast(i) * 30.00, 0.00, 0.00), base[i], SColor.Green()));
      i += 1;
    };
  }
}
