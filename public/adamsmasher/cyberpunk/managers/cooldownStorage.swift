
public class CooldownRequest extends IScriptable {

  private let m_action: ref<BaseScriptableAction>;

  private let m_contactBook: array<PSOwnerData>;

  private let m_requestTriggerType: RequestType;

  public final func SetUp(action: ref<BaseScriptableAction>, shouldTriggerCooldownImmediately: Bool) -> Void {
    let data: PSOwnerData;
    this.m_action = action;
    data.id = this.m_action.GetPersistentID();
    data.className = this.m_action.GetDeviceClassName();
    this.SetUpTriggerType(shouldTriggerCooldownImmediately);
    if PersistentID.IsDefined(data.id) && IsNameValid(data.className) {
      ArrayPush(this.m_contactBook, data);
    };
  }

  public final func SetUp(action: ref<BaseScriptableAction>, go: wref<GameObject>, shouldTriggerCooldownImmediately: Bool) -> Void {
    this.m_action = action;
    this.SetUpTriggerType(shouldTriggerCooldownImmediately);
    if IsDefined(go) {
      ArrayPush(this.m_contactBook, go.GetPSOwnerData());
    };
  }

  public final func SetUp(action: ref<BaseScriptableAction>, ps: wref<PersistentState>, shouldTriggerCooldownImmediately: Bool) -> Void {
    let ownerData: PSOwnerData;
    this.m_action = action;
    this.SetUpTriggerType(shouldTriggerCooldownImmediately);
    if IsDefined(ps) {
      ownerData.id = ps.GetID();
      ownerData.className = ps.GetClassName();
      ArrayPush(this.m_contactBook, ownerData);
    };
  }

  public final func SetUpAdvanced(action: ref<BaseScriptableAction>, addressees: array<PSOwnerData>, shouldTriggerCooldownImmediately: Bool) -> Void {
    this.m_action = action;
    this.m_contactBook = addressees;
    this.SetUpTriggerType(shouldTriggerCooldownImmediately);
  }

  public final func GetAction() -> ref<BaseScriptableAction> {
    return this.m_action;
  }

  public final func GetContactBook() -> array<PSOwnerData> {
    return this.m_contactBook;
  }

  public final const func GetTriggerRequestType() -> RequestType {
    return this.m_requestTriggerType;
  }

  private final func SetUpTriggerType(shouldTriggerImmediately: Bool) -> Void {
    if shouldTriggerImmediately {
      this.m_requestTriggerType = RequestType.INSTANTLY_TRIGGER;
    } else {
      this.m_requestTriggerType = RequestType.MANUALLY_TRIGGERED;
    };
  }
}

public class CooldownPackage extends IScriptable {

  private let m_actionID: TweakDBID;

  private let m_addressees: array<PSOwnerData>;

  private let m_initialCooldown: Float;

  private let m_label: CooldownStorageID;

  private let m_packageStatus: PackageStatus;

  public final func InitializePackage(request: ref<CooldownRequest>, label: CooldownStorageID) -> Void {
    this.m_initialCooldown = request.GetAction().GetCooldownDuration();
    this.m_actionID = request.GetAction().GetObjectActionRecord().GetID();
    this.m_addressees = request.GetContactBook();
    this.SetUpInitialPackageStatus(request.GetTriggerRequestType());
    this.m_label = label;
  }

  public final const func GetActionID() -> TweakDBID {
    return this.m_actionID;
  }

  public final const func GetInitialCooldown() -> Float {
    return this.m_initialCooldown;
  }

  public final const func GetAddressees() -> array<PSOwnerData> {
    return this.m_addressees;
  }

  public final const func GetLabel() -> CooldownStorageID {
    return this.m_label;
  }

  public final const func GetPackageStatus() -> PackageStatus {
    return this.m_packageStatus;
  }

  public final func UpdatePackageStatus(newStatus: PackageStatus) -> Void {
    this.m_packageStatus = newStatus;
  }

  private final func SetUpInitialPackageStatus(requestType: RequestType) -> Void {
    if Equals(requestType, RequestType.INSTANTLY_TRIGGER) {
      this.m_packageStatus = PackageStatus.FOR_IMMEDIATE_TRIGGER;
    };
    if Equals(requestType, RequestType.MANUALLY_TRIGGERED) {
      this.m_packageStatus = PackageStatus.ON_HOLD;
    };
  }
}

public class CooldownStorage extends IScriptable {

  private let m_owner: PSOwnerData;

  private let m_initialized: EBOOL;

  private let m_gameInstanceHack: GameInstance;

  private let m_packages: array<ref<CooldownPackage>>;

  private let m_currentID: Uint32;

  private let m_map: array<CooldownPackageDelayIDs>;

  public final func Initialize(id: PersistentID, className: CName, gameInstanceHack: GameInstance) -> Void {
    this.m_owner.id = id;
    this.m_owner.className = className;
    this.m_gameInstanceHack = gameInstanceHack;
    this.m_initialized = EBOOL.TRUE;
  }

  public final func StartSimpleCooldown(action: ref<BaseScriptableAction>) -> CooldownStorageID {
    let cdRequest: ref<CooldownRequest> = new CooldownRequest();
    cdRequest.SetUp(action, true);
    return this.StartCooldownRequest(cdRequest);
  }

  public final func StartCooldownRequest(request: ref<CooldownRequest>) -> CooldownStorageID {
    let invalidID: CooldownStorageID;
    if this.IsActionReady(request.GetAction().GetObjectActionRecord().GetID()) {
      return this.ProcessNewPackage(request);
    };
    invalidID.ID = 0u;
    invalidID.isValid = EBOOL.FALSE;
    Log("Request not valid. This action is already on cooldown");
    return invalidID;
  }

  public final func IsInitialized() -> EBOOL {
    return this.m_initialized;
  }

  public final func IsActionReady(action: TweakDBID) -> Bool {
    let index: Int32 = this.FindPackageIndexByAction(action);
    return this.IsActionReady(index);
  }

  public final func IsActionReady(id: CooldownStorageID) -> Bool {
    let index: Int32 = this.FindPackageIndexByID(id);
    return this.IsActionReady(index);
  }

  private final func IsActionReady(index: Int32) -> Bool {
    if index == -1 {
      return true;
    };
    return false;
  }

  public final func CancelCooldown(id: CooldownStorageID) -> Bool {
    this.CancelDelayEvents(this.GetPackage(id));
    return this.RemoveCooldown(id);
  }

  public final func CancelCooldown(action: TweakDBID) -> Bool {
    return this.RemoveCooldown(action);
  }

  public final func ResolveCooldownEvent(evt: ref<ActionCooldownEvent>) -> Void {
    let label: CooldownStorageID = evt.storageID;
    if this.GetPackage(label).GetInitialCooldown() >= 0.00 {
      this.RemoveCooldown(label);
    };
  }

  private final func RemoveCooldown(label: CooldownStorageID) -> Bool {
    let index: Int32 = this.FindPackageIndexByID(label);
    return this.RemoveCooldown(index);
  }

  private final func RemoveCooldown(action: TweakDBID) -> Bool {
    let index: Int32 = this.FindPackageIndexByAction(action);
    return this.RemoveCooldown(index);
  }

  private final func RemoveCooldown(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_packages) {
      this.RemoveMapEntry(this.FindMapEntry(this.m_packages[index]));
      ArrayErase(this.m_packages, index);
      return true;
    };
    return false;
  }

  public final func GetPackage(label: CooldownStorageID) -> ref<CooldownPackage> {
    let foundPackage: ref<CooldownPackage> = this.m_packages[this.FindPackageIndexByID(label)];
    return foundPackage;
  }

  public final func ManuallyTriggerCooldown(actionID: TweakDBID) -> Bool {
    let foundPackage: ref<CooldownPackage> = this.m_packages[this.FindPackageIndexByAction(actionID)];
    if Equals(foundPackage.GetPackageStatus(), PackageStatus.ON_HOLD) {
      this.TriggerPackageListeners(foundPackage);
      return true;
    };
    LogWarning("Cooldown Storage \\\\ Cooldown not found or cooldown was not viable for manual trigger");
    return false;
  }

  private final func GetPackage(action: TweakDBID) -> ref<CooldownPackage> {
    let foundPackage: ref<CooldownPackage> = this.m_packages[this.FindPackageIndexByAction(action)];
    return foundPackage;
  }

  private final func FindPackageIndexByID(label: CooldownStorageID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_packages) {
      if Equals(this.m_packages[i].GetLabel(), label) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func FindPackageIndexByAction(actionID: TweakDBID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_packages) {
      if this.m_packages[i].GetActionID() == actionID {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func ProcessNewPackage(request: ref<CooldownRequest>) -> CooldownStorageID {
    let package: ref<CooldownPackage> = new CooldownPackage();
    package.InitializePackage(request, this.AttachUniqueLabel());
    if Equals(package.GetPackageStatus(), PackageStatus.FOR_IMMEDIATE_TRIGGER) {
      this.TriggerPackageListeners(package);
    };
    ArrayPush(this.m_packages, package);
    return package.GetLabel();
  }

  private final func TriggerPackageListeners(package: ref<CooldownPackage>) -> Void {
    let delayIDs: array<DelayID>;
    let i: Int32;
    let cooldownEvent: ref<ActionCooldownEvent> = new ActionCooldownEvent();
    cooldownEvent.storageID = package.GetLabel();
    let addressees: array<PSOwnerData> = package.GetAddressees();
    ArrayPush(addressees, this.m_owner);
    i = 0;
    while i < ArraySize(addressees) {
      ArrayPush(delayIDs, GameInstance.GetDelaySystem(this.m_gameInstanceHack).DelayPSEvent(addressees[i].id, addressees[i].className, cooldownEvent, package.GetInitialCooldown()));
      i += 1;
    };
    package.UpdatePackageStatus(PackageStatus.TRIGGERED);
    this.UpdateMap(package.GetLabel(), delayIDs);
  }

  private final func UpdateMap(label: CooldownStorageID, ids: array<DelayID>) -> Void {
    let mapEntry: CooldownPackageDelayIDs;
    mapEntry.packageID = label;
    mapEntry.delayIDs = ids;
    ArrayPush(this.m_map, mapEntry);
  }

  private final func AttachUniqueLabel() -> CooldownStorageID {
    let label: CooldownStorageID;
    this.m_currentID += 1u;
    if this.m_currentID == 0u {
      this.m_currentID += 1u;
    };
    label = this.GenerateLabel(this.m_currentID);
    return label;
  }

  private final func GenerateLabel(id: Uint32) -> CooldownStorageID {
    let label: CooldownStorageID;
    label.ID = id;
    label.isValid = EBOOL.TRUE;
    return label;
  }

  private final func CancelDelayEvents(package: ref<CooldownPackage>) -> Void {
    let ids: array<DelayID>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_map) {
      if Equals(this.m_map[i].packageID, package.GetLabel()) {
        ids = this.m_map[i].delayIDs;
      } else {
        i += 1;
      };
    };
    i = 0;
    while i < ArraySize(ids) {
      GameInstance.GetDelaySystem(this.m_gameInstanceHack).CancelDelay(ids[i]);
      i += 1;
    };
  }

  private final func RemoveMapEntry(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_map) {
      ArrayErase(this.m_map, index);
      return true;
    };
    return false;
  }

  private final func FindMapEntry(id: CooldownStorageID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_map) {
      if Equals(this.m_map[i].packageID, id) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func FindMapEntry(package: ref<CooldownPackage>) -> Int32 {
    return this.FindMapEntry(package.GetLabel());
  }
}
