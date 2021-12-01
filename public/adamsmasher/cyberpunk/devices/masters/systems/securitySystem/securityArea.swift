
public class SecurityArea extends InteractiveMasterDevice {

  private let m_area: ref<TriggerComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"area", n"TriggerComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_area = EntityResolveComponentsInterface.GetComponent(ri, n"area") as TriggerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SecurityAreaController;
    this.RegisterTimeSystemListeners();
  }

  protected cb func OnGameAttached() -> Bool {
    let areaType: ESecurityAreaType;
    this.m_area.Toggle((this.GetDevicePS() as SecurityAreaControllerPS).IsActive());
    areaType = (this.GetDevicePS() as SecurityAreaControllerPS).GetSecurityAreaType();
    if Equals(areaType, ESecurityAreaType.SAFE) {
      this.m_area.RegisterSafeArea();
    };
  }

  protected cb func OnDetach() -> Bool {
    this.SendFakeExitEventToObjectsInsideMe();
    this.UnregisterTimeSystemListeners();
  }

  protected cb func OnSlaveStateChanged(evt: ref<PSDeviceChangedEvent>) -> Bool {
    return false;
  }

  protected cb func OnRegisterTimeListeners(evt: ref<RegisterTimeListeners>) -> Bool {
    this.RegisterTimeSystemListeners();
  }

  private final func RegisterTimeSystemListeners() -> Void {
    (this.GetDevicePS() as SecurityAreaControllerPS).RegisterTimeSystemListeners(this);
  }

  private final func UnregisterTimeSystemListeners() -> Void {
    (this.GetDevicePS() as SecurityAreaControllerPS).UnregisterTimeSystemListeners();
  }

  protected cb func OnTransition(evt: ref<Transition>) -> Bool {
    (this.GetDevicePS() as SecurityAreaControllerPS).ApplyTransition(evt.listenerID);
  }

  protected cb func OnManageAreaComponent(evt: ref<ManageAreaComponent>) -> Bool {
    this.m_area.Toggle(evt.enable);
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let isPlayer: Bool;
    let mappinSystem: ref<MappinSystem>;
    let shouldProcess: Bool;
    let obj: ref<GameObject> = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if obj.IsPlayer() {
      shouldProcess = true;
      isPlayer = true;
    } else {
      if IsDefined(obj as ScriptedPuppet) && !(obj as ScriptedPuppet).IsCrowd() {
        shouldProcess = true;
      } else {
        shouldProcess = false;
      };
    };
    if shouldProcess {
      (this.GetDevicePS() as SecurityAreaControllerPS).AreaEntered(evt);
      if isPlayer {
        mappinSystem = GameInstance.GetMappinSystem(this.GetGame());
        if IsDefined(mappinSystem) {
          mappinSystem.OnAreaEntered(evt);
        };
      };
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    this.OnAreaExitInternal(EntityGameInterface.GetEntity(evt.activator) as GameObject, evt.triggerID);
  }

  private final func OnAreaExitInternal(obj: wref<GameObject>, triggerID: EntityID) -> Void {
    let isPlayer: Bool;
    let mappinSystem: ref<MappinSystem>;
    let shouldProcess: Bool;
    if obj.IsPlayer() {
      shouldProcess = true;
      isPlayer = true;
    } else {
      if IsDefined(obj as ScriptedPuppet) && !(obj as ScriptedPuppet).IsCrowd() {
        shouldProcess = true;
      } else {
        shouldProcess = false;
      };
    };
    if shouldProcess {
      (this.GetDevicePS() as SecurityAreaControllerPS).AreaExited(obj);
      if isPlayer {
        mappinSystem = GameInstance.GetMappinSystem(this.GetGame());
        if IsDefined(mappinSystem) {
          mappinSystem.OnAreaExited(obj, triggerID);
        };
      };
    };
  }

  protected func AdjustInteractionComponent() -> Void {
    this.m_interaction.Toggle(false);
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    return null;
  }

  protected cb func OnQuestIllegalActionAreaNotification(evt: ref<QuestIllegalActionAreaNotification>) -> Bool {
    (this.GetDevicePS() as SecurityAreaControllerPS).OnQuestIllegalActionAreaNotification(evt);
  }

  protected cb func OnQuestCombatActionAreaNotification(evt: ref<QuestCombatActionAreaNotification>) -> Bool {
    (this.GetDevicePS() as SecurityAreaControllerPS).OnQuestCombatActionAreaNotification(evt);
  }

  protected cb func OnQuestAddTransition(evt: ref<QuestAddTransition>) -> Bool {
    (this.GetDevicePS() as SecurityAreaControllerPS).OnQuestAddTransition(evt);
  }

  protected cb func OnQuestRemoveTransition(evt: ref<QuestRemoveTransition>) -> Bool {
    (this.GetDevicePS() as SecurityAreaControllerPS).OnQuestRemoveTransition(evt);
  }

  protected cb func OnQuestExecuteTranstion(evt: ref<QuestExecuteTransition>) -> Bool {
    (this.GetDevicePS() as SecurityAreaControllerPS).OnQuestExecuteTransition(evt);
  }

  private final func SendFakeExitEventToObjectsInsideMe() -> Void {
    let object: wref<GameObject>;
    let objectInsideMe: AreaEntry;
    let ps: ref<SecurityAreaControllerPS> = this.GetDevicePS() as SecurityAreaControllerPS;
    let objectsInsideMe: array<AreaEntry> = ps.GetUsersInPerimeter();
    let index: Int32 = 0;
    while index < ArraySize(objectsInsideMe) {
      objectInsideMe = objectsInsideMe[index];
      object = GameInstance.FindEntityByID(GetGameInstance(), objectInsideMe.user) as GameObject;
      this.OnAreaExitInternal(object, this.GetEntityID());
      index += 1;
    };
  }
}
