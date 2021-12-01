
public class InspectableObjectComponentPS extends GameComponentPS {

  private persistent let m_isStarted: Bool;

  private persistent let m_isFinished: Bool;

  private let m_listeners: array<ref<ObjectInspectListener>>;

  public final const func IsState(state: questObjectInspectEventType) -> Bool {
    if Equals(state, questObjectInspectEventType.Started) && this.m_isStarted {
      return true;
    };
    if Equals(state, questObjectInspectEventType.Finished) && this.m_isFinished {
      return true;
    };
    return false;
  }

  public final func OnRegisterListener(evt: ref<InspectListenerEvent>) -> EntityNotificationType {
    if evt.register {
      ArrayPush(this.m_listeners, evt.listener);
    } else {
      ArrayRemove(this.m_listeners, evt.listener);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnSetState(evt: ref<SetInspectStateEvent>) -> EntityNotificationType {
    if Equals(evt.state, questObjectInspectEventType.Started) {
      this.SetStarted();
    } else {
      if Equals(evt.state, questObjectInspectEventType.Finished) {
        this.SetFinished();
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func SetStarted() -> Void {
    this.m_isStarted = true;
    this.NotifyListeners(questObjectInspectEventType.Started);
  }

  public final func SetFinished() -> Void {
    this.m_isFinished = true;
    this.NotifyListeners(questObjectInspectEventType.Finished);
  }

  private final func NotifyListeners(state: questObjectInspectEventType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_listeners) {
      this.m_listeners[i].OnInspect(state);
      i += 1;
    };
  }
}

public class InspectableObjectComponent extends ScriptableComponent {

  public let m_factToAdd: CName;

  public let m_itemID: String;

  @default(InspectableObjectComponent, 0.5f)
  public let m_offset: Float;

  @default(InspectableObjectComponent, 0.25f)
  public let m_adsOffset: Float;

  @default(InspectableObjectComponent, 2.f)
  public let m_timeToScan: Float;

  @default(InspectableObjectComponent, AttachmentSlots.Inspect)
  private let m_slot: String;

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }

  private final func InspectObject(activator: ref<GameObject>) -> Void {
    let evt: ref<InspectionTriggerEvent> = new InspectionTriggerEvent();
    evt.inspectedObjID = this.GetOwner().GetEntityID();
    evt.item = this.m_itemID;
    evt.offset = this.m_offset;
    evt.adsOffset = this.m_adsOffset;
    evt.timeToScan = this.m_timeToScan;
    activator.QueueEvent(evt);
    this.SetInspectableObjectState(false);
    SetFactValue(this.GetOwner().GetGame(), this.m_factToAdd, 1);
    (this.GetPS() as InspectableObjectComponentPS).SetStarted();
  }

  protected cb func OnInspectEvent(evt: ref<ObjectInspectEvent>) -> Bool {
    this.SetInspectableObjectState(evt.showItem);
  }

  private final func GiveInspectableItem(activator: ref<GameObject>) -> Void {
    let inspectEvt: ref<ObjectInspectEvent>;
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetOwner().GetGame());
    transSystem.GiveItem(activator, ItemID.FromTDBID(TDBID.Create(this.m_itemID)), 1);
    inspectEvt = new ObjectInspectEvent();
    inspectEvt.showItem = false;
    this.GetOwner().QueueEvent(inspectEvt);
    (this.GetPS() as InspectableObjectComponentPS).SetFinished();
  }

  protected cb func OnInspectItem(evt: ref<InspectItemInspectionEvent>) -> Bool {
    this.InspectObject(evt.owner);
  }

  protected cb func OnLootItem(evt: ref<InspectItemInspectionEvent>) -> Bool {
    this.GiveInspectableItem(evt.owner);
  }

  private final func SetInspectableObjectState(b: Bool) -> Void {
    let owner: ref<InspectDummy> = this.GetOwner() as InspectDummy;
    let state: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    state.enable = b;
    owner.QueueEvent(state);
    owner.m_mesh.Toggle(b);
  }
}
