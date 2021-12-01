
public static func OperatorEqual(record_1: ItemID, record_2: TweakDBID) -> Bool {
  if ItemID.GetTDBID(record_1) == record_2 {
    return true;
  };
  return false;
}

public static func OperatorEqual(record_1: TweakDBID, record_2: ItemID) -> Bool {
  if record_1 == ItemID.GetTDBID(record_2) {
    return true;
  };
  return false;
}

public static exec func TestDrop(gameInstance: GameInstance) -> Void {
  let itemID: ItemID;
  let request: ref<DropPointRequest>;
  let player: ref<GameObject> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject();
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gameInstance);
  let dps: ref<DropPointSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"DropPointSystem") as DropPointSystem;
  if !IsDefined(ts) {
    return;
  };
  itemID = ItemID.FromTDBID(t"Items.w_special_flak");
  ts.GiveItem(player, itemID, 1);
  request = new DropPointRequest();
  request.CreateRequest(ItemID.GetTDBID(itemID), DropPointPackageStatus.ACTIVE);
  dps.QueueRequest(request);
}

public class DropPointCallback extends InventoryScriptCallback {

  public let dps: wref<DropPointSystem>;

  public func OnItemRemoved(item: ItemID, difference: Int32, currentQuantity: Int32) -> Void {
    let request: ref<DropPointRequest> = new DropPointRequest();
    request.CreateRequest(ItemID.GetTDBID(item), DropPointPackageStatus.COLLECTED);
    this.dps.QueueRequest(request);
  }
}

public class DropPointRequest extends ScriptableSystemRequest {

  @attrib(customEditor, "TweakDBGroupInheritance;Item")
  private edit let record: TweakDBID;

  @attrib(Tooltip, "NOT_ACTIVE = DropPoints will not accept them | ACTIVE = drop points will allow to deposit them | COLLECTED = treated as if it was already deposited")
  private edit let status: DropPointPackageStatus;

  private let holder: PersistentID;

  public final func CreateRequest(_record: TweakDBID, _status: DropPointPackageStatus, opt _holder: PersistentID) -> Void {
    this.record = _record;
    this.status = _status;
    if PersistentID.IsDefined(_holder) {
      this.holder = _holder;
    };
  }

  public final const func Record() -> TweakDBID {
    return this.record;
  }

  public final const func Status() -> DropPointPackageStatus {
    return this.status;
  }

  public final const func Holder() -> PersistentID {
    return this.holder;
  }

  public final func GetFriendlyDescription() -> String {
    return "ENABLE / DISABLE PACKAGE";
  }
}

public class DropPointMappinRegistrationData extends IScriptable {

  private persistent let m_ownerID: EntityID;

  private persistent let m_position: Vector4;

  private let m_mapinID: NewMappinID;

  private let m_trackingAlternativeMappinID: NewMappinID;

  public final func Initalize(ownerID: EntityID, position: Vector4) -> Void {
    this.m_ownerID = ownerID;
    this.m_position = position;
  }

  public final func SetMappinID(id: NewMappinID) -> Void {
    this.m_mapinID = id;
  }

  public final func SetTrackingAlternativeMappinID(id: NewMappinID) -> Void {
    this.m_trackingAlternativeMappinID = id;
  }

  public final const func GetOwnerID() -> EntityID {
    return this.m_ownerID;
  }

  public final const func GetPosition() -> Vector4 {
    return this.m_position;
  }

  public final const func GetMappinID() -> NewMappinID {
    return this.m_mapinID;
  }

  public final const func GetTrackingAlternativeMappinID() -> NewMappinID {
    return this.m_trackingAlternativeMappinID;
  }
}

public class ToggleDropPointSystemRequest extends ScriptableSystemRequest {

  public edit let isEnabled: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle Drop Point System";
  }
}

public class DropPointPackage extends IScriptable {

  private persistent let itemID: TweakDBID;

  @attrib(Tooltip, "NOT_ACTIVE = DropPoints will not accept them | ACTIVE = drop points will allow to deposit them | EXPOSED = treated as if it was already deposited")
  private persistent let status: DropPointPackageStatus;

  private persistent let predefinedDrop: PersistentID;

  private let statusHistory: array<DropPointPackageStatus>;

  public final func SetStatus(newStatus: DropPointPackageStatus) -> Void {
    ArrayPush(this.statusHistory, newStatus);
    this.status = newStatus;
  }

  public final func SetRecord(record: TweakDBID) -> Void {
    this.itemID = record;
  }

  public final func SetHolder(_holder: PersistentID) -> Void {
    if PersistentID.IsDefined(_holder) {
      this.predefinedDrop = _holder;
    };
  }

  public final const func Status() -> DropPointPackageStatus {
    return this.status;
  }

  public final const func Record() -> TweakDBID {
    return this.itemID;
  }

  public final const func Holder() -> PersistentID {
    return this.predefinedDrop;
  }
}

public class DropPointSystem extends ScriptableSystem {

  private persistent let m_packages: array<ref<DropPointPackage>>;

  private persistent let m_mappins: array<ref<DropPointMappinRegistrationData>>;

  @default(DropPointSystem, true)
  private persistent let m_isEnabled: Bool;

  private func OnAttach() -> Void;

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    this.RestoreDropPointMappins();
  }

  public final const func CanDeposit(record: TweakDBID, dropPoint: PersistentID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_packages) {
      if this.m_packages[i].Record() == record && Equals(this.m_packages[i].Status(), DropPointPackageStatus.ACTIVE) {
        if !PersistentID.IsDefined(this.m_packages[i].Holder()) || Equals(this.m_packages[i].Holder(), dropPoint) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final const quest func IsCollected(record: TweakDBID) -> Bool {
    return this.Is(record, DropPointPackageStatus.COLLECTED);
  }

  public final const quest func IsActive(record: TweakDBID) -> Bool {
    return this.Is(record, DropPointPackageStatus.ACTIVE);
  }

  public final const func HasItemsThatCanBeDeposited(user: ref<GameObject>, dropPoint: PersistentID) -> Bool {
    let items: array<wref<gameItemData>>;
    let ts: ref<TransactionSystem>;
    if !IsDefined(user) {
      return false;
    };
    ts = GameInstance.GetTransactionSystem(this.GetGameInstance());
    ts.GetItemList(user, items);
    return this.HasMeaningfulItems(items, dropPoint);
  }

  protected final const func HasMeaningfulItems(items: array<wref<gameItemData>>, dropPoint: PersistentID) -> Bool {
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_packages) {
      k = 0;
      while k < ArraySize(items) {
        if this.m_packages[i].Record() == ItemID.GetTDBID(items[k].GetID()) && Equals(this.m_packages[i].Status(), DropPointPackageStatus.ACTIVE) {
          if !PersistentID.IsDefined(this.m_packages[i].Holder()) || Equals(this.m_packages[i].Holder(), dropPoint) {
            return true;
          };
        };
        k += 1;
      };
      i += 1;
    };
    return false;
  }

  public final const func Is(record: TweakDBID, status: DropPointPackageStatus) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_packages) {
      if this.m_packages[i].Record() == record {
        return Equals(this.m_packages[i].Status(), status);
      };
      i += 1;
    };
    return false;
  }

  private final func UpdateRecord(package: ref<DropPointPackage>, status: DropPointPackageStatus, holder: PersistentID) -> Void {
    package.SetStatus(status);
    package.SetHolder(holder);
  }

  private final func CreatePackage(request: ref<DropPointRequest>) -> Void {
    let package: ref<DropPointPackage> = new DropPointPackage();
    package.SetRecord(request.Record());
    package.SetStatus(request.Status());
    package.SetHolder(request.Holder());
    ArrayPush(this.m_packages, package);
  }

  protected final func OnDropPointRequest(dropPointRequest: ref<DropPointRequest>) -> Void {
    this.UpdatePackage(dropPointRequest);
  }

  private final func UpdatePackage(dropPointRequest: ref<DropPointRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_packages) {
      if this.m_packages[i].Record() == dropPointRequest.Record() {
        this.UpdateRecord(this.m_packages[i], dropPointRequest.Status(), dropPointRequest.Holder());
        return;
      };
      i += 1;
    };
    if NotEquals(dropPointRequest.Status(), DropPointPackageStatus.ACTIVE) {
      return;
    };
    this.CreatePackage(dropPointRequest);
  }

  protected final func OnToggleDropPointSystemRequest(request: ref<ToggleDropPointSystemRequest>) -> Void {
    let shouldUpdate: Bool = NotEquals(this.m_isEnabled, request.isEnabled);
    this.m_isEnabled = request.isEnabled;
    if shouldUpdate {
      if this.m_isEnabled {
        this.RestoreDropPointMappins(true);
      } else {
        this.HideDropPointMappins(true);
      };
    };
  }

  protected final func OnRegisterDropPointMappinRequest(request: ref<RegisterDropPointMappinRequest>) -> Void {
    let registrationData: ref<DropPointMappinRegistrationData>;
    if !this.HasMappin(request.ownerID) {
      registrationData = new DropPointMappinRegistrationData();
      registrationData.Initalize(request.ownerID, request.position);
      if this.m_isEnabled {
        this.RegisterDropPointMappin(registrationData);
      };
      ArrayPush(this.m_mappins, registrationData);
    } else {
      registrationData = this.GetMappinData(request.ownerID);
    };
    registrationData.SetTrackingAlternativeMappinID(request.trackingAlternativeMappinID);
    this.GetMappinSystem().SetMappinTrackingAlternative(registrationData.GetMappinID(), registrationData.GetTrackingAlternativeMappinID());
  }

  protected final func OnUnregisterDropPointMappinRequest(request: ref<UnregisterDropPointMappinRequest>) -> Void {
    let registrationData: ref<DropPointMappinRegistrationData> = this.GetMappinData(request.ownerID);
    if IsDefined(registrationData) {
      this.UnregisterDropPointMappin(registrationData);
    };
  }

  private final func RestoreDropPointMappins(opt informDevice: Bool) -> Void {
    let evt: ref<UpdateDropPointEvent>;
    let i: Int32;
    if !this.m_isEnabled {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_mappins) {
      this.RegisterDropPointMappin(this.m_mappins[i]);
      if informDevice {
        evt = new UpdateDropPointEvent();
        evt.isEnabled = true;
        GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.m_mappins[i].GetOwnerID(), evt);
      };
      i += 1;
    };
  }

  private final func HideDropPointMappins(opt informDevice: Bool) -> Void {
    let evt: ref<UpdateDropPointEvent>;
    let i: Int32;
    if this.m_isEnabled {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_mappins) {
      this.UnregisterDropPointMappin(this.m_mappins[i]);
      if informDevice {
        evt = new UpdateDropPointEvent();
        evt.isEnabled = false;
        GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.m_mappins[i].GetOwnerID(), evt);
      };
      i += 1;
    };
  }

  private final func RegisterDropPointMappin(data: ref<DropPointMappinRegistrationData>) -> Void {
    let mappinData: MappinData;
    let mappinID: NewMappinID;
    if data == null || NotEquals(data.GetMappinID(), mappinID) {
      return;
    };
    mappinData.mappinType = t"Mappins.DropPointStaticMappin";
    mappinData.variant = gamedataMappinVariant.ServicePointDropPointVariant;
    mappinData.active = true;
    mappinID = this.GetMappinSystem().RegisterMappin(mappinData, data.GetPosition());
    data.SetMappinID(mappinID);
  }

  private final func UnregisterDropPointMappin(data: ref<DropPointMappinRegistrationData>) -> Void {
    let invalidMappinID: NewMappinID;
    if data == null || Equals(data.GetMappinID(), invalidMappinID) {
      return;
    };
    this.GetMappinSystem().UnregisterMappin(data.GetMappinID());
    data.SetMappinID(invalidMappinID);
  }

  private final func HasMappin(ownerID: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if this.m_mappins[i].GetOwnerID() == ownerID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func GetMappinData(ownerID: EntityID) -> ref<DropPointMappinRegistrationData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if this.m_mappins[i].GetOwnerID() == ownerID {
        return this.m_mappins[i];
      };
      i += 1;
    };
    return null;
  }

  private final func GetMappinSystem() -> ref<MappinSystem> {
    return GameInstance.GetMappinSystem(this.GetGameInstance());
  }

  public final const func IsEnabled() -> Bool {
    return this.m_isEnabled;
  }
}
