
public class VendingTerminal extends InteractiveDevice {

  public let m_position: Vector4;

  protected let m_canMeshComponent: ref<MeshComponent>;

  protected const let m_vendingBlacklist: array<EVendorMode>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"CanMesh", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Trigger", n"gameStaticTriggerAreaComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_canMeshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"CanMesh") as MeshComponent;
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as VendingTerminalController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    (this.GetDevicePS() as VendingTerminalControllerPS).Prepare(this);
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().VendingMachineDeviceBlackboard);
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func PushPersistentData() -> Void {
    this.PushPersistentData();
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    this.RefreshUI();
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    (this.GetDevicePS() as VendingTerminalControllerPS).GetVendorDataManager().ClearCart();
    this.RefreshUI();
  }

  protected cb func OnCraftItemForTarget(evt: ref<CraftItemForTarget>) -> Bool {
    this.RefreshUI();
    GameObject.PlaySoundEvent(this, n"dev_vending_machine_processing");
  }

  protected cb func OnBuyItemFromVendor(evt: ref<BuyItemFromVendor>) -> Bool {
    let buyRequestData: TransactionRequestData;
    buyRequestData.itemID = evt.itemID;
    let buyRequest: ref<BuyRequest> = new BuyRequest();
    buyRequest.owner = this;
    ArrayPush(buyRequest.items, buyRequestData);
    MarketSystem.GetInstance(this.GetGame()).QueueRequest(buyRequest);
    this.RefreshUI();
    GameObject.PlaySoundEvent(this, n"dev_vending_machine_processing");
  }

  protected cb func OnSellItemToVendor(evt: ref<SellItemToVendor>) -> Bool {
    let sellRequestData: TransactionRequestData;
    sellRequestData.itemID = evt.itemID;
    let sellRequest: ref<SellRequest> = new SellRequest();
    sellRequest.owner = this;
    ArrayPush(sellRequest.items, sellRequestData);
    MarketSystem.GetInstance(this.GetGame()).QueueRequest(sellRequest);
    this.RefreshUI();
    GameObject.PlaySoundEvent(this, n"dev_vending_machine_processing");
  }

  protected cb func OnDispenceItemFromVendor(evt: ref<DispenceItemFromVendor>) -> Bool {
    this.RefreshUI();
    this.DelayVendingMachineEvent((this.GetDevicePS() as VendingTerminalControllerPS).GetVendorDataManager().GetTimeToCompletePurchase(), evt.GetItemID());
    GameObject.PlaySoundEvent(this, n"dev_vending_machine_processing");
  }

  protected cb func OnVendingMachineFinishedEvent(evt: ref<VendingMachineFinishedEvent>) -> Bool {
    this.m_position = Matrix.GetTranslation(this.m_canMeshComponent.GetLocalToWorld());
    GameInstance.GetLootManager(this.GetGame()).SpawnItemDrop(this, evt.itemID, this.m_position);
    GameObject.PlaySoundEvent(this, n"dev_vending_machine_can_falls");
    (this.GetDevicePS() as VendingTerminalControllerPS).SetIsReady(true);
    this.RefreshUI();
  }

  protected final func SendDataToUIBlackboard(TopText: String, BottomText: String) -> Void {
    this.GetBlackboard().FireCallbacks();
  }

  protected final func DelayVendingMachineEvent(time: Float, itemID: ItemID) -> Void {
    let evt: ref<VendingMachineFinishedEvent> = new VendingMachineFinishedEvent();
    evt.itemID = itemID;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, time);
  }

  private func InitializeScreenDefinition() -> Void {
    if !TDBID.IsValid(this.m_screenDefinition.screenDefinition) {
      this.m_screenDefinition.screenDefinition = t"DevicesUIDefinitions.Terminal_4x3";
    };
    if !TDBID.IsValid(this.m_screenDefinition.style) {
      this.m_screenDefinition.style = t"DevicesUIStyles.None";
    };
  }
}
