
public class IceMachineController extends VendingMachineController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class IceMachineControllerPS extends VendingMachineControllerPS {

  private let m_vendorTweakID: TweakDBID;

  private let m_iceMachineSFX: IceMachineSFX;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-IceMachine";
    };
    this.m_vendorTweakID = t"Vendors.IceMachine";
  }

  public final func GetVendorTweakID() -> TweakDBID {
    return this.m_vendorTweakID;
  }

  public final func GetProcessingSFX() -> CName {
    return this.m_iceMachineSFX.m_processing;
  }

  public func GetGlitchStartSFX() -> CName {
    return this.m_iceMachineSFX.m_glitchingStart;
  }

  public func GetGlitchStopSFX() -> CName {
    return this.m_iceMachineSFX.m_glitchingStop;
  }

  public final func GetIceFallSFX() -> CName {
    return this.m_iceMachineSFX.m_iceFalls;
  }

  public func GetTimeToCompletePurchase() -> Float {
    return 2.50;
  }

  public func GetHackedItemCount() -> Int32 {
    return 25;
  }

  protected func PushShopStockActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let shopStock: array<SItemStack>;
    if DispenceItemFromVendor.IsDefaultConditionMet(this, context) && this.m_isReady {
      shopStock = MarketSystem.GetVendorItemsForSale(this.GetOwnerEntityWeak() as GameObject, false);
      if ArraySize(shopStock) > 0 {
        ArrayPush(actions, this.ActionDispenceIceCube(shopStock[0].itemID));
      };
    };
  }

  protected final func ActionDispenceIceCube(item: ItemID) -> ref<DispenceItemFromVendor> {
    let action: ref<DispenceItemFromVendor> = new DispenceItemFromVendor();
    let price: Int32 = MarketSystem.GetBuyPrice(this.GetGameInstance(), this.GetMyEntityID(), item);
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(item, price);
    action.AddDeviceName(this.m_deviceName);
    action.SetDurationValue(this.GetTimeToCompletePurchase());
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnDispenceItemFromVendor(evt: ref<DispenceItemFromVendor>) -> EntityNotificationType {
    let transactionSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    if evt.IsStarted() {
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      if evt.CanPay(GetPlayer(this.GetGameInstance())) {
        this.m_isReady = false;
        transactionSys.RemoveItem(GetPlayer(this.GetGameInstance()), MarketSystem.Money(), evt.GetPrice());
        this.UseNotifier(evt);
      } else {
        return EntityNotificationType.DoNotNotifyEntity;
      };
    };
    return EntityNotificationType.SendThisEventToEntity;
  }
}
