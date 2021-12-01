
public class CraftItemForTarget extends ActionBool {

  public let itemID: TweakDBID;

  public final func SetProperties() -> Void {
    this.actionName = n"CraftItem";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Craft Item", true, n"LocKey#17846", n"LocKey#17846");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public final func CreateActionWidgetPackage(displayText: String, additionalText: String, imageAtlasImageID: CName, opt actions: array<ref<DeviceAction>>) -> Void {
    this.m_actionWidgetPackage.wasInitalized = true;
    this.m_actionWidgetPackage.dependendActions = actions;
    this.m_actionWidgetPackage.libraryPath = this.GetInkWidgetLibraryPath();
    this.m_actionWidgetPackage.libraryID = this.GetInkWidgetLibraryID();
    this.m_actionWidgetPackage.widgetName = displayText;
    this.m_actionWidgetPackage.displayName = displayText + ":" + additionalText;
    this.m_actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
    this.ResolveActionWidgetTweakDBData();
  }

  public func GetInkWidgetLibraryID() -> CName {
    return n"";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.VendorItemActionWidget";
  }
}

public class BuyItemFromVendor extends ActionBool {

  public let itemID: ItemID;

  public final func SetProperties() -> Void {
    this.actionName = n"BuyItem";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Buy Item", true, n"LocKey#17847", n"LocKey#17847");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public final func CreateActionWidgetPackage(displayText: String, additionalText: String, imageAtlasImageID: CName, opt actions: array<ref<DeviceAction>>) -> Void {
    this.m_actionWidgetPackage.wasInitalized = true;
    this.m_actionWidgetPackage.dependendActions = actions;
    this.m_actionWidgetPackage.libraryPath = this.GetInkWidgetLibraryPath();
    this.m_actionWidgetPackage.libraryID = this.GetInkWidgetLibraryID();
    this.m_actionWidgetPackage.widgetName = displayText;
    this.m_actionWidgetPackage.displayName = displayText + ":" + additionalText;
    this.m_actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
    this.ResolveActionWidgetTweakDBData();
  }

  public func GetInkWidgetLibraryID() -> CName {
    return n"";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.VendorItemActionWidget";
  }
}

public class SellItemToVendor extends ActionBool {

  public let itemID: ItemID;

  public final func SetProperties() -> Void {
    this.actionName = n"SellItem";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Sell Item", true, n"LocKey#17848", n"LocKey#17848");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public final func CreateActionWidgetPackage(displayText: String, additionalText: String, imageAtlasImageID: CName, opt actions: array<ref<DeviceAction>>) -> Void {
    this.m_actionWidgetPackage.wasInitalized = true;
    this.m_actionWidgetPackage.dependendActions = actions;
    this.m_actionWidgetPackage.libraryPath = this.GetInkWidgetLibraryPath();
    this.m_actionWidgetPackage.libraryID = this.GetInkWidgetLibraryID();
    this.m_actionWidgetPackage.widgetName = displayText;
    this.m_actionWidgetPackage.displayName = displayText + ":" + additionalText;
    this.m_actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
    this.ResolveActionWidgetTweakDBData();
  }

  public func GetInkWidgetLibraryID() -> CName {
    return n"";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.VendorItemActionWidget";
  }
}

public class DispenceItemFromVendor extends ActionBool {

  private let m_itemID: ItemID;

  @default(DispenceItemFromVendor, -1)
  private let m_price: Int32;

  private let m_atlasTexture: CName;

  public final func SetProperties(iteID: ItemID, opt price: Int32, opt texture: CName) -> Void {
    this.actionName = n"DispenceItem";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Dispence Item", true, n"LocKey#17849", n"LocKey#17849");
    this.m_itemID = iteID;
    this.m_price = price;
    this.m_atlasTexture = texture;
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if DispenceItemFromVendor.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }

  public final func CanPay(opt user: ref<GameObject>) -> Bool {
    let price: Int32;
    let transactionSys: ref<TransactionSystem>;
    let userMoney: Int32;
    if !IsDefined(user) {
      user = this.GetExecutor();
    };
    if !IsDefined(user) {
      return false;
    };
    transactionSys = GameInstance.GetTransactionSystem(user.GetGame());
    userMoney = transactionSys.GetItemQuantity(user, MarketSystem.Money());
    price = this.m_price;
    if price == -1 {
      price = MarketSystem.GetBuyPrice(user.GetGame(), PersistentID.ExtractEntityID(this.GetPersistentID()), this.m_itemID);
    };
    return userMoney > price;
  }

  public final const func GetItemID() -> ItemID {
    return this.m_itemID;
  }

  public final const func GetPrice() -> Int32 {
    return this.m_price;
  }

  public final const func GetAtlasTexture() -> CName {
    return this.m_atlasTexture;
  }

  public func CreateActionWidgetPackage(opt actions: array<ref<DeviceAction>>) -> Void {
    let widgetName: String;
    this.CreateActionWidgetPackage(actions);
    if IsNameValid(this.m_atlasTexture) {
      widgetName = NameToString(this.m_atlasTexture);
      this.m_actionWidgetPackage.widgetName = widgetName;
      this.m_actionWidgetPackage.displayName = widgetName;
    };
  }

  public func GetInkWidgetLibraryID() -> CName {
    return n"";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.VendorItemActionWidget";
  }
}

public class VendingTerminalController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class VendingTerminalControllerPS extends ScriptableDeviceComponentPS {

  private persistent let m_vendingTerminalSetup: VendingTerminalSetup;

  private let m_isReady: Bool;

  private let m_VendorDataManager: ref<VendorDataManager>;

  public final func Prepare(vendor: wref<GameObject>) -> Void {
    this.m_VendorDataManager = new VendorDataManager();
    this.m_VendorDataManager.Initialize(vendor, this.m_vendingTerminalSetup);
  }

  public final func GetVendorDataManager() -> wref<VendorDataManager> {
    return this.m_VendorDataManager;
  }

  public final func SetIsReady(value: Bool) -> Void {
    this.m_isReady = value;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().VendingMachineDeviceBlackboard;
  }
}
