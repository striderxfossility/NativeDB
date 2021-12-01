
public class VendingMachine extends InteractiveDevice {

  private let m_vendorID: ref<VendorComponent>;

  protected let m_advUiComponent: ref<IComponent>;

  protected let m_isShortGlitchActive: Bool;

  protected let m_shortGlitchDelayID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ads", n"AdvertisementWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"VendorID", n"VendorComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    this.m_advUiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ads");
    this.m_vendorID = EntityResolveComponentsInterface.GetComponent(ri, n"VendorID") as VendorComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as VendingMachineController;
  }

  protected final func AttachVendor() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"AttachVendorTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func AttachVendorTask(data: ref<ScriptTaskData>) -> Void {
    let request: ref<AttachVendorRequest>;
    let vendorID: TweakDBID = this.GetVendorID();
    if TDBID.IsValid(vendorID) {
      request = new AttachVendorRequest();
      request.owner = this;
      request.vendorID = vendorID;
      MarketSystem.GetInstance(this.GetGame()).QueueRequest(request);
    };
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.AttachVendor();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  public func GetVendorID() -> TweakDBID {
    return this.m_vendorID.GetVendorID();
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    this.TurnOffDevice();
  }

  protected func TurnOffDevice() -> Void {
    this.m_uiComponent.Toggle(false);
    this.m_advUiComponent.Toggle(false);
    this.ToggleLights(false);
    this.TurnOffDevice();
  }

  protected func TurnOnDevice() -> Void {
    this.m_uiComponent.Toggle(true);
    this.m_advUiComponent.Toggle(true);
    this.ToggleLights(true);
    this.TurnOnDevice();
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    this.RefreshUI();
  }

  protected func GetProcessingSFX() -> CName {
    return this.m_vendorID.GetProcessingSFX();
  }

  protected cb func OnDispenceItemFromVendor(evt: ref<DispenceItemFromVendor>) -> Bool {
    let playerMoney: Int32;
    let price: Int32;
    let transactionSys: ref<TransactionSystem>;
    if evt.IsStarted() {
      transactionSys = GameInstance.GetTransactionSystem(this.GetGame());
      price = MarketSystem.GetBuyPrice(this, evt.GetItemID());
      playerMoney = transactionSys.GetItemQuantity(GetPlayer(this.GetGame()), MarketSystem.Money());
      if playerMoney > price {
        this.DelayVendingMachineEvent((this.GetDevicePS() as VendingMachineControllerPS).GetTimeToCompletePurchase(), false, true, evt.GetItemID());
        GameObject.PlaySoundEvent(this, this.GetProcessingSFX());
        this.SendDataToUIBlackboard(PaymentStatus.IN_PROGRESS);
      } else {
        this.SendDataToUIBlackboard(PaymentStatus.NO_MONEY);
      };
    } else {
      this.SendDataToUIBlackboard(PaymentStatus.DEFAULT);
    };
  }

  protected final func DelayVendingMachineEvent(time: Float, isFree: Bool, isReady: Bool, opt itemID: ItemID) -> Void {
    let evt: ref<VendingMachineFinishedEvent> = new VendingMachineFinishedEvent();
    if ItemID.IsValid(itemID) {
      evt.itemID = itemID;
    };
    evt.isFree = isFree;
    evt.isReady = isReady;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, time);
  }

  protected cb func OnVendingMachineFinishedEvent(evt: ref<VendingMachineFinishedEvent>) -> Bool {
    if (this.GetDevicePS() as VendingMachineControllerPS).IsSoldOut() {
      this.SendSoldOutToUIBlackboard(true);
    } else {
      if evt.isReady {
        (this.GetDevicePS() as VendingMachineControllerPS).SetIsReady(true);
      };
    };
    this.DispenseItems(this.CreateDispenseRequest(!evt.isFree, evt.itemID));
    this.PlayItemFall();
    this.RefreshUI();
  }

  protected func DispenseItems(request: ref<DispenseRequest>) -> Void {
    MarketSystem.GetInstance(this.GetGame()).QueueRequest(request);
  }

  protected func CreateDispenseRequest(shouldPay: Bool, item: ItemID) -> ref<DispenseRequest> {
    let dispenseRequest: ref<DispenseRequest> = new DispenseRequest();
    dispenseRequest.owner = this;
    dispenseRequest.position = this.RandomizePosition();
    dispenseRequest.shouldPay = shouldPay;
    if ItemID.IsValid(item) {
      dispenseRequest.itemID = item;
    };
    return dispenseRequest;
  }

  protected func BuyItems(request: ref<BuyRequest>) -> Void {
    let uiSys: ref<UISystem> = GameInstance.GetUISystem(this.GetGame());
    let evt: ref<VendorBoughtItemEvent> = new VendorBoughtItemEvent();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(request.items);
    while i < limit {
      ArrayPush(evt.items, request.items[i].itemID);
      i += 1;
    };
    uiSys.QueueEvent(evt);
    MarketSystem.GetInstance(this.GetGame()).QueueRequest(request);
  }

  protected final func CreateBuyRequest(opt itemID: ItemID) -> ref<BuyRequest> {
    let buyRequest: ref<BuyRequest>;
    let buyRequestData: TransactionRequestData;
    if ItemID.IsValid(itemID) {
      buyRequestData.itemID = itemID;
    };
    buyRequest = new BuyRequest();
    buyRequest.owner = this;
    ArrayPush(buyRequest.items, buyRequestData);
    return buyRequest;
  }

  protected func PlayItemFall() -> Void {
    GameObject.PlaySoundEvent(this, this.m_vendorID.GetItemFallSFX());
  }

  protected final func RandomizePosition() -> Vector4 {
    let offset: Vector4;
    let position: Vector4;
    let transform: WorldTransform;
    this.GetSlotComponent().GetSlotTransform(n"itemSpawn", transform);
    offset.X = RandRangeF(-0.10, 0.10);
    offset.Y = RandRangeF(-0.02, 0.02);
    offset.Z = RandRangeF(-0.05, 0.02);
    offset.W = 1.00;
    position = WorldPosition.ToVector4(WorldTransform.TransformPoint(transform, offset));
    return position;
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    this.HackedEffect();
    this.AdvertGlitch(true, this.GetGlitchData(glitchState));
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as VendingMachineControllerPS).GetGlitchStartSFX());
    this.RefreshUI();
  }

  protected func StopGlitching() -> Void {
    this.AdvertGlitch(false, this.GetGlitchData(EGlitchState.NONE));
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as VendingMachineControllerPS).GetGlitchStopSFX());
    (this.GetDevicePS() as VendingMachineControllerPS).SetIsReady(true);
    this.RefreshUI();
  }

  protected final func GetGlitchData(glitchState: EGlitchState) -> GlitchData {
    let data: GlitchData;
    data.state = glitchState;
    if NotEquals(glitchState, EGlitchState.NONE) {
      data.intensity = 1.00;
    };
    return data;
  }

  protected func HackedEffect() -> Void {
    let TS: ref<TransactionSystem>;
    let i: Int32;
    let index: Int32;
    let itemCount: Int32;
    let junkItem: ItemID;
    let junkPool: array<JunkItemRecord>;
    let max: Int32;
    if this.GetBlackboard().GetBool(GetAllBlackboardDefs().VendingMachineDeviceBlackboard.SoldOut) {
      return;
    };
    TS = GameInstance.GetTransactionSystem(this.GetGame());
    max = (this.GetDevicePS() as VendingMachineControllerPS).GetHackedItemCount();
    itemCount = this.m_vendorID.GetJunkCount();
    junkPool = this.m_vendorID.GetJunkItemIDs();
    i = 0;
    while i < max {
      if itemCount > 1 {
        index = RandRange(0, itemCount);
      };
      if ArraySize(junkPool) > 0 {
        junkItem = ItemID.FromTDBID(junkPool[index].m_junkItemID);
        if ItemID.IsValid(junkItem) {
          TS.GiveItem(this, junkItem, 1);
          this.DelayHackedEvent(Cast(i) / 5.00, junkItem);
        };
      };
      i += 1;
    };
    if (this.GetDevicePS() as VendingMachineControllerPS).IsSoldOut() {
      this.SendSoldOutToUIBlackboard(true);
    };
  }

  protected func GetJunkItem() -> ItemID {
    return ItemID.undefined();
  }

  protected final func DelayHackedEvent(time: Float, itemID: ItemID) -> Void {
    let evt: ref<DelayHackedEvent> = new DelayHackedEvent();
    if ItemID.IsValid(itemID) {
      evt.itemID = itemID;
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, time);
    };
  }

  protected cb func OnDelayHackedEvent(evt: ref<DelayHackedEvent>) -> Bool {
    GameInstance.GetLootManager(this.GetGame()).SpawnItemDrop(this, evt.itemID, this.RandomizePosition());
    this.PlayItemFall();
  }

  protected final func AdvertGlitch(start: Bool, data: GlitchData) -> Void {
    this.SimpleGlitch(start);
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(data), true);
    this.GetBlackboard().FireCallbacks();
  }

  protected final func SimpleGlitch(on: Bool) -> Void {
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    if on {
      evt.SetShouldGlitch(1.00);
    } else {
      evt.SetShouldGlitch(0.00);
    };
    this.QueueEvent(evt);
  }

  protected cb func OnQuestDispenseFreeItem(evt: ref<DispenseFreeItem>) -> Bool {
    this.DelayVendingMachineEvent(0.50, true, true);
  }

  protected cb func OnQuestDispenseSpecificItem(evt: ref<DispenseFreeSpecificItem>) -> Bool {
    this.DelayVendingMachineEvent(0.50, true, true, ItemID.FromTDBID(evt.item));
  }

  protected final func ToggleLights(on: Bool) -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = on;
    this.QueueEvent(evt);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }

  private func InitializeScreenDefinition() -> Void {
    if !TDBID.IsValid(this.m_screenDefinition.screenDefinition) {
      this.m_screenDefinition.screenDefinition = t"DevicesUIDefinitions.Terminal_4x3";
    };
    if !TDBID.IsValid(this.m_screenDefinition.style) {
      this.m_screenDefinition.style = t"DevicesUIStyles.None";
    };
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().VendingMachineDeviceBlackboard);
  }

  protected final func SendDataToUIBlackboard(status: PaymentStatus) -> Void {
    this.GetBlackboard().SetVariant(GetAllBlackboardDefs().VendingMachineDeviceBlackboard.ActionStatus, ToVariant(status));
    this.GetBlackboard().FireCallbacks();
  }

  protected final func SendSoldOutToUIBlackboard(soldOut: Bool) -> Void {
    this.GetBlackboard().SetBool(GetAllBlackboardDefs().VendingMachineDeviceBlackboard.SoldOut, soldOut);
    this.GetBlackboard().FireCallbacks();
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  private final func StartShortGlitch() -> Void {
    let evt: ref<StopShortGlitchEvent>;
    if this.GetDevicePS().IsGlitching() {
      return;
    };
    if !this.m_isShortGlitchActive {
      evt = new StopShortGlitchEvent();
      this.SimpleGlitch(true);
      this.m_shortGlitchDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.25);
      this.m_isShortGlitchActive = true;
    };
  }

  protected cb func OnStopShortGlitch(evt: ref<StopShortGlitchEvent>) -> Bool {
    this.m_isShortGlitchActive = false;
    if !this.GetDevicePS().IsGlitching() {
      this.SimpleGlitch(false);
    };
  }
}

public class DispenseFreeItem extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Dispense Free Item";
  }
}

public class DispenseFreeSpecificItem extends Event {

  @attrib(customEditor, "TweakDBGroupInheritance;Items.Drink;Items.Food")
  public edit let item: TweakDBID;

  public final func GetFriendlyDescription() -> String {
    return "Dispense Specific Free Item";
  }
}
