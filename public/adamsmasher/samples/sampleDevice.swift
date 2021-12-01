
public class SampleDeviceClassPS extends GameObjectPS {

  @default(SampleDeviceClassPS, 0)
  protected persistent let m_counter: Int32;

  public final func OnActionInt(evt: ref<ActionInt>) -> EntityNotificationType {
    this.m_counter += 1;
    Log("sample counter: " + IntToString(this.m_counter));
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func GetAction_ActionInt() -> ref<ActionInt> {
    let action: ref<ActionInt>;
    return action;
  }

  public final func GetActions() -> array<ref<DeviceAction>> {
    let arr: array<ref<DeviceAction>>;
    ArrayPush(arr, this.GetAction_ActionInt());
    return arr;
  }
}

public class PSD_DetectorPS extends DeviceComponentPS {

  @default(PSD_DetectorPS, 0)
  protected persistent let m_counter: Int32;

  @default(PSD_DetectorPS, false)
  protected persistent let m_toggle: Bool;

  protected persistent let m_lastEntityID: EntityID;

  protected persistent let m_lastPersistentID: PersistentID;

  protected persistent let m_name: CName;

  public final func GetLastEntityID() -> EntityID {
    return this.m_lastEntityID;
  }

  public final func GetLastPersistentID() -> PersistentID {
    return this.m_lastPersistentID;
  }

  public final func GetName() -> CName {
    return this.m_name;
  }

  public final func ReadTheCounter() -> Int32 {
    return this.m_counter;
  }

  public final func OnBumpTheCounter(evt: ref<SampleBumpEvent>) -> EntityNotificationType {
    this.m_counter += evt.m_amount;
    Log("sample counter: " + IntToString(this.m_counter));
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnBumpTheCounter(evt: ref<ActionInt>) -> EntityNotificationType {
    this.m_counter += 1;
    Log("sample counter: " + IntToString(this.m_counter) + "  " + EntityID.ToDebugString(this.m_lastEntityID));
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnLogAction(evt: ref<ActionBool>) -> EntityNotificationType {
    let boolValue: Bool;
    let nameOnFalse: CName;
    let nameOnTrue: CName;
    if Equals(evt.prop.typeName, n"Bool") {
      DeviceActionPropertyFunctions.GetProperty_Bool(evt.prop, boolValue, nameOnFalse, nameOnTrue);
      this.m_toggle = boolValue;
      if Equals(this.m_toggle, true) {
        this.m_counter += 2;
      };
    };
    Log("sample counter: " + IntToString(this.m_counter) + " ## " + NameToString(evt.prop.name) + ": " + BoolToString(FromVariant(evt.prop.first)));
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func GetAction_BumpTheCounter() -> ref<ActionInt> {
    let action: ref<ActionInt>;
    return action;
  }

  public final func GetAction_Log() -> ref<ActionBool> {
    let action: ref<ActionBool>;
    return action;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let action: ref<DeviceAction>;
    Log("Getting Actions!");
    ArrayPush(outActions, this.GetAction_BumpTheCounter());
    action = this.GetAction_Log();
    if Clearance.IsInRange(context.clearance, action.clearanceLevel) {
      ArrayPush(outActions, action);
    };
    return true;
  }
}

public class PSD_Detector extends DeviceComponent {

  public final func LogID() -> Void {
    Log(EntityID.ToDebugString((this.GetPS() as PSD_DetectorPS).GetLastEntityID()));
    Log(PersistentID.ToDebugString((this.GetPS() as PSD_DetectorPS).GetLastPersistentID()));
    Log(NameToString((this.GetPS() as PSD_DetectorPS).GetName()));
  }
}

public class PSD_Trigger extends GameObject {

  public let m_ref: NodeRef;

  @default(PSD_Trigger, PSD_DetectorPS)
  public let m_className: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
  }

  protected cb func OnInteraction(interaction: ref<InteractionChoiceEvent>) -> Bool {
    let actions: array<ref<DeviceAction>>;
    let context: GetActionsContext;
    let propertyArr: array<ref<DeviceActionProperty>>;
    let i: Int32 = 0;
    let j: Int32 = 0;
    let targetEntityID: EntityID = Cast(ResolveNodeRefWithEntityID(this.m_ref, this.GetEntityID()));
    let objPS: ref<GameComponentPS> = GameInstance.GetPersistencySystem(this.GetGame()).GetConstAccessToPSObject(Cast(targetEntityID), this.m_className) as GameComponentPS;
    (objPS as PSD_DetectorPS).GetActions(actions, context);
    Log("Device PS: " + NameToString(this.m_className) + ", number of actions: " + IntToString(ArraySize(actions)));
    i = 0;
    while i < ArraySize(actions) {
      propertyArr = actions[i].GetProperties();
      j = 0;
      while j < ArraySize(propertyArr) {
        if Equals(propertyArr[j].typeName, n"Bool") {
          propertyArr[j].first = ToVariant(!FromVariant(propertyArr[j].first));
        };
        j += 1;
      };
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSDeviceEvent(actions[i]);
      i += 1;
    };
  }
}

public class Slave_Test extends GameObject {

  public let deviceComponent: ref<PSD_Detector>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"detector", n"PSD_Detector", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.deviceComponent = EntityResolveComponentsInterface.GetComponent(ri, n"detector") as PSD_Detector;
  }

  protected cb func OnInteraction(interaction: ref<InteractionChoiceEvent>) -> Bool {
    this.deviceComponent.LogID();
  }
}

public class Master_Test extends GameObject {

  public let deviceComponent: ref<MasterDeviceComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"master", n"MasterDeviceComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.deviceComponent = EntityResolveComponentsInterface.GetComponent(ri, n"master") as MasterDeviceComponent;
  }

  protected cb func OnInteraction(interaction: ref<InteractionChoiceEvent>) -> Bool {
    let actions: array<ref<DeviceAction>>;
    let context: GetActionsContext;
    let propertyArr: array<ref<DeviceActionProperty>>;
    context.clearance = this.deviceComponent.clearance;
    let i: Int32 = 0;
    let j: Int32 = 0;
    Log("Works");
    this.deviceComponent.GetActionsOfConnectedDevices(actions, context);
    Log(IntToString(ArraySize(actions)));
    i = 0;
    while i < ArraySize(actions) {
      Log(NameToString(actions[i].actionName));
      propertyArr = actions[i].GetProperties();
      j = 0;
      while j < ArraySize(propertyArr) {
        if Equals(propertyArr[j].typeName, n"Bool") {
          propertyArr[j].first = ToVariant(!FromVariant(propertyArr[j].first));
        };
        j += 1;
      };
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSDeviceEvent(actions[i]);
      i += 1;
    };
  }

  protected cb func OnSlaveChanged(evt: ref<PSDeviceChangedEvent>) -> Bool {
    Log(EntityID.ToDebugString(this.GetEntityID()) + " notified by " + PersistentID.ToDebugString(evt.persistentID) + " of class " + NameToString(evt.className));
  }
}
