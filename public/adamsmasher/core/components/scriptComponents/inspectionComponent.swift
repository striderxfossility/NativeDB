
public class InspectionComponent extends ScriptableComponent {

  public edit let m_slot: String;

  private let m_cumulatedObjRotationX: Float;

  private let m_cumulatedObjRotationY: Float;

  private let m_maxObjOffset: Float;

  private let m_minObjOffset: Float;

  private let m_zoomSpeed: Float;

  private let m_timeToScan: Float;

  private let m_isPlayerInspecting: Bool;

  private let m_activeClue: String;

  private let m_isScanAvailable: Bool;

  private let m_scanningInProgress: Bool;

  private let m_objectScanned: Bool;

  private let m_animFeature: ref<AnimFeature_Inspection>;

  private let m_listener: ref<IScriptable>;

  private let m_lastInspectedObjID: EntityID;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_animFeature = new AnimFeature_Inspection();
  }

  protected cb func OnInspectionEvent(evt: ref<InspectionEvent>) -> Bool {
    if !evt.enabled {
      this.ExitInspect();
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if this.m_isPlayerInspecting {
      if Equals(ListenerAction.GetName(action), n"InspectionTake") {
        this.LootInspectItem();
      };
      if Equals(ListenerAction.GetName(action), n"InspectionZoom") {
        this.ProcessZoom(ListenerAction.GetValue(action));
      };
      if Equals(ListenerAction.GetName(action), n"InspectionScan") && ListenerAction.IsButtonJustPressed(action) && this.m_isScanAvailable {
        this.ScanInspectableItem();
        this.DisplayScanningUI(true);
      };
      if Equals(ListenerAction.GetName(action), n"RotateObjectX") {
        this.RotateInInspection(ListenerAction.GetValue(action), 0.00);
      };
      if Equals(ListenerAction.GetName(action), n"RotateObjectY") {
        this.RotateInInspection(0.00, ListenerAction.GetValue(action));
      };
      if Equals(ListenerAction.GetName(action), n"RotateObjectX_Mouse") {
        this.RotateInInspectionByMouse(ListenerAction.GetValue(action), 0.00);
      };
      if Equals(ListenerAction.GetName(action), n"RotateObjectY_Mouse") {
        this.RotateInInspectionByMouse(0.00, ListenerAction.GetValue(action));
      };
    };
  }

  private final func RotateInInspection(deltaX: Float, deltaY: Float) -> Void {
    this.m_cumulatedObjRotationX += 5.00 * deltaX;
    this.m_cumulatedObjRotationX = AngleNormalize180(this.m_cumulatedObjRotationX);
    this.m_cumulatedObjRotationY += 5.00 * deltaY;
    this.m_cumulatedObjRotationY = AngleNormalize180(this.m_cumulatedObjRotationY);
    this.m_animFeature.rotationX = this.m_cumulatedObjRotationX;
    this.m_animFeature.rotationY = this.m_cumulatedObjRotationY;
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), n"Inspection", this.m_animFeature);
  }

  private final func RotateInInspectionByMouse(deltaX: Float, deltaY: Float) -> Void {
    let x_axis: Float = deltaX / 20.00;
    let y_axis: Float = deltaY / 20.00;
    this.RotateInInspection(x_axis, y_axis);
  }

  private final func ProcessZoom(val: Float) -> Void {
    this.m_animFeature.offsetY = LerpF(val, this.m_maxObjOffset, this.m_minObjOffset);
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), n"Inspection", this.m_animFeature);
  }

  private final func ToggleInspection(enabled: Bool) -> Void {
    this.SetInputListening(enabled);
    if enabled {
      this.m_listener = this;
    } else {
      this.m_listener = null;
    };
  }

  protected cb func OnInspectTrigger(evt: ref<InspectionTriggerEvent>) -> Bool {
    this.SetIsPlayerInspecting(true);
    this.ToggleInspection(this.m_isPlayerInspecting);
    if EntityID.IsDefined(evt.inspectedObjID) {
      this.SetLastInspectedObjectID(evt.inspectedObjID);
    };
    this.PlaceItemInInspectSlot(evt.item, evt.offset);
    this.SetObjectOffsets(evt.offset, evt.adsOffset);
    this.SetTimeToScan(evt.timeToScan);
  }

  protected cb func OnPreScanEvent(evt: ref<ScanEvent>) -> Bool {
    if NotEquals(evt.clue, "") {
      this.m_isScanAvailable = evt.isAvailable;
      this.m_activeClue = evt.clue;
    };
  }

  private final func DisplayScanningUI(show: Bool) -> Void {
    let item: ref<GameObject> = this.GetTransactionSystem().GetItemInSlot(this.GetOwner(), TDBID.Create(this.m_slot));
    let evt: ref<TEMP_ScanningEvent> = new TEMP_ScanningEvent();
    evt.showUI = show;
    item.QueueEvent(evt);
  }

  private final func ScanInspectableItem() -> Void {
    this.m_scanningInProgress = true;
  }

  private final func OnUpdate(deltaTime: Float) -> Void {
    if this.m_scanningInProgress && !this.m_objectScanned {
      this.m_timeToScan -= deltaTime;
      if this.m_timeToScan <= 0.00 && this.m_isScanAvailable {
        this.m_scanningInProgress = false;
        this.m_objectScanned = true;
        this.DisplayScanningUI(false);
        GameInstance.GetQuestsSystem(this.GetOwner().GetGame()).SetFactStr("inspected_" + this.m_activeClue, 1);
      };
    };
  }

  private final func SetObjectOffsets(offset: Float, adsOffset: Float) -> Void {
    this.m_minObjOffset = adsOffset;
    this.m_maxObjOffset = offset;
  }

  private final func SetTimeToScan(timeVal: Float) -> Void {
    this.m_timeToScan = timeVal;
  }

  private final func SetInputListening(enabled: Bool) -> Void {
    if enabled && !IsDefined(this.m_listener) {
      this.GetOwner().RegisterInputListener(this, n"InspectionTake");
      this.GetOwner().RegisterInputListener(this, n"InspectionZoom");
      this.GetOwner().RegisterInputListener(this, n"InspectionScan");
      this.GetOwner().RegisterInputListener(this, n"RotateObjectX");
      this.GetOwner().RegisterInputListener(this, n"RotateObjectY");
      this.GetOwner().RegisterInputListener(this, n"RotateObjectX_Mouse");
      this.GetOwner().RegisterInputListener(this, n"RotateObjectX_Mouse");
    } else {
      if IsDefined(this.m_listener) {
        this.GetOwner().UnregisterInputListener(this);
      };
    };
  }

  private final func ResetScanningState() -> Void {
    this.m_scanningInProgress = false;
    this.m_isScanAvailable = false;
    this.SetTimeToScan(0.00);
  }

  private final func ExitInspect() -> Void {
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetOwner().GetGame());
    let item: ref<GameObject> = transSystem.GetItemInSlot(this.GetOwner(), TDBID.Create(this.m_slot));
    if item != null {
      this.ToggleInspectObject(true);
    };
    this.ToggleExitInspect();
  }

  private final func ToggleExitInspect() -> Void {
    let id: PersistentID;
    let inspectStateEvt: ref<SetInspectStateEvent>;
    this.RemoveInspectedItem();
    this.SetIsPlayerInspecting(false);
    this.SetInspectionStage(0);
    this.ResetScanningState();
    this.ToggleInspection(this.m_isPlayerInspecting);
    id = CreatePersistentID(this.m_lastInspectedObjID, n"inspectComponent");
    inspectStateEvt = new SetInspectStateEvent();
    inspectStateEvt.state = questObjectInspectEventType.Finished;
    GameInstance.GetPersistencySystem(this.GetOwner().GetGame()).QueuePSEvent(id, n"InspectableObjectComponentPS", inspectStateEvt);
  }

  private final func LootInspectItem() -> Void {
    this.EmptyInspectSlot();
    this.ToggleInspectObject(false);
    this.ToggleExitInspect();
  }

  private final func ToggleInspectObject(show: Bool) -> Void {
    let evt: ref<ObjectInspectEvent> = new ObjectInspectEvent();
    evt.showItem = show;
    this.GetOwner().QueueEventForEntityID(this.m_lastInspectedObjID, evt);
  }

  private final func PlaceItemInInspectSlot(itemTDBIDString: String, offset: Float) -> Void {
    let owner: ref<PlayerPuppet> = this.GetOwner() as PlayerPuppet;
    let itemTDBID: TweakDBID = TDBID.Create(itemTDBIDString);
    let itemID: ItemID = ItemID.FromTDBID(itemTDBID);
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(owner.GetGame());
    transSystem.GiveItem(owner, itemID, 1);
    transSystem.AddItemToSlot(owner, TDBID.Create(this.m_slot), itemID);
    this.ResetAnimFeature();
    this.m_animFeature.offsetY = offset;
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), n"Inspection", this.m_animFeature);
    this.SetInspectionStage(1);
  }

  private final func CleanupInspectSlot(wasLooted: Bool) -> Void {
    if wasLooted {
      this.EmptyInspectSlot();
    } else {
      this.RemoveInspectedItem();
    };
  }

  private final func EmptyInspectSlot() -> Void {
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetOwner().GetGame());
    transSystem.RemoveItemFromSlot(this.GetOwner(), TDBID.Create(this.m_slot));
  }

  private final func RemoveInspectedItem() -> Void {
    let owner: ref<GameObject> = this.GetOwner();
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(owner.GetGame());
    let itemInSlot: ItemID = transSystem.GetItemInSlot(owner, TDBID.Create(this.m_slot)).GetItemID();
    if Equals(ItemID.IsValid(itemInSlot), false) {
      return;
    };
    transSystem.RemoveItem(owner, itemInSlot, 1);
  }

  private final func ResetAnimFeature() -> Void {
    this.m_cumulatedObjRotationX = 0.00;
    this.m_cumulatedObjRotationY = 0.00;
    this.m_animFeature.rotationX = 0.00;
    this.m_animFeature.rotationY = 0.00;
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), n"Inspection", this.m_animFeature);
  }

  private final func SetInspectionStage(stage: Int32) -> Void {
    this.m_animFeature.activeInspectionStage = stage;
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), n"Inspection", this.m_animFeature);
  }

  public final const func GetIsPlayerInspecting() -> Bool {
    return this.m_isPlayerInspecting;
  }

  private final func SetIsPlayerInspecting(enabled: Bool) -> Void {
    this.m_isPlayerInspecting = enabled;
  }

  public final const func GetLastInspectedObjectID() -> EntityID {
    return this.m_lastInspectedObjID;
  }

  private final func SetLastInspectedObjectID(newID: EntityID) -> Void {
    this.m_lastInspectedObjID = newID;
  }

  private final func RememberInspectedObjID(id: EntityID) -> Void {
    this.m_lastInspectedObjID = id;
  }
}
