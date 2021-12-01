
public class DeviceOperationsContainer extends IScriptable {

  private inline persistent const let m_operations: array<ref<DeviceOperationBase>>;

  private inline const let m_triggers: array<ref<DeviceOperationsTrigger>>;

  public final func Initialize(owner: ref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      this.m_triggers[i].Initialize(owner);
      i += 1;
    };
  }

  public final func UnInitialize(owner: ref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      this.m_triggers[i].UnInitialize(owner);
      i += 1;
    };
  }

  public final func ToggleOperationByIndex(enable: Bool, index: Int32) -> Void {
    this.m_operations[index].SetIsEnabled(enable);
  }

  public final func ToggleOperationByName(enable: Bool, operationName: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_operations) {
      if this.m_operations[i] == null {
      } else {
        if Equals(this.m_operations[i].operationName, operationName) {
          this.m_operations[i].SetIsEnabled(enable);
        };
      };
      i += 1;
    };
  }

  public final const func IsOperationEnabled(index: Int32) -> Bool {
    return this.m_operations[index].IsEnabled();
  }

  public final const func HasOperation(className: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_operations) {
      if Equals(this.m_operations[i].GetClassName(), className) && this.m_operations[i].IsEnabled() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsOperationEnabled(operationName: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_operations) {
      if this.m_operations[i] == null {
      } else {
        if this.m_operations[i].IsEnabled() {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final func Execute(operationName: CName, owner: wref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_operations) {
      if this.m_operations[i] == null {
      } else {
        if Equals(this.m_operations[i].operationName, operationName) && this.m_operations[i].IsEnabled() {
          this.m_operations[i].Execute(owner);
          this.ToggleOperations(this.m_operations[i].toggleOperations);
        };
      };
      i += 1;
    };
  }

  public final func Restore(operationName: CName, owner: wref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_operations) {
      if this.m_operations[i] == null {
      } else {
        if Equals(this.m_operations[i].operationName, operationName) {
          this.m_operations[i].Restore(owner);
        };
      };
      i += 1;
    };
  }

  private final func ToggleOperations(operations: array<SToggleDeviceOperationData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(operations) {
      this.ToggleOperationByName(operations[i].enable, operations[i].operationName);
      i += 1;
    };
  }

  public final func EvaluateActivatorTriggers(owner: wref<GameObject>) -> Void {
    let trigger: ref<ActivatorOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as ActivatorOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(owner, this);
      };
      i += 1;
    };
  }

  public final func EvaluateFactTriggers(owner: wref<GameObject>, factName: CName) -> Void {
    let trigger: ref<FactOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as FactOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(owner, factName, this);
      };
      i += 1;
    };
  }

  public final func EvaluateFocusModeTriggers(owner: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let trigger: ref<FocusModeOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as FocusModeOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(owner, operationType, this);
      };
      i += 1;
    };
  }

  public final func EvaluateSenseTriggers(owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let trigger: ref<SensesOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as SensesOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(owner, activator, operationType, this);
      };
      i += 1;
    };
  }

  public final func EvaluateHitTriggers(owner: wref<GameObject>, activator: wref<GameObject>, attackData: ref<AttackData>) -> Void {
    let trigger: ref<HitOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as HitOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(owner, activator, attackData, this);
      };
      i += 1;
    };
  }

  public final func EvaluateInteractionAreaTriggers(areaTag: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: gameinteractionsEInteractionEventType) -> Void {
    let trigger: ref<InteractionAreaOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as InteractionAreaOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(areaTag, owner, activator, operationType, this);
      };
      i += 1;
    };
  }

  public final func EvaluateTriggerVolumeTriggers(componentName: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let trigger: ref<TriggerVolumeOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as TriggerVolumeOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(componentName, owner, activator, operationType, this);
      };
      i += 1;
    };
  }

  public final func EvaluateDeviceActionTriggers(actionClassName: CName, owner: wref<GameObject>) -> Void {
    let trigger: ref<DeviceActionOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as DeviceActionOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(actionClassName, owner, this);
      };
      i += 1;
    };
  }

  public final func RestoreDeviceActionOperations(actionClassName: CName, owner: wref<GameObject>) -> Void {
    let trigger: ref<DeviceActionOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as DeviceActionOperationsTrigger;
      if trigger != null {
        trigger.RestoreOperation(actionClassName, owner, this);
      };
      i += 1;
    };
  }

  public final func EvaluateCustomActionTriggers(actionID: CName, owner: wref<GameObject>) -> Void {
    let trigger: ref<CustomActionOperationsTriggers>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as CustomActionOperationsTriggers;
      if trigger != null {
        trigger.EvaluateTrigger(actionID, owner, this);
      };
      i += 1;
    };
  }

  public final func RestoreCustomActionOperations(actionID: CName, owner: wref<GameObject>) -> Void {
    let trigger: ref<CustomActionOperationsTriggers>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as CustomActionOperationsTriggers;
      if trigger != null {
        trigger.RestoreOperation(actionID, owner, this);
      };
      i += 1;
    };
  }

  public final func EvaluateDoorStateTriggers(state: EDoorStatus, owner: wref<GameObject>) -> Void {
    let trigger: ref<DoorStateOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as DoorStateOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(state, owner, this);
      };
      i += 1;
    };
  }

  public final func EvaluateBaseStateTriggers(state: EDeviceStatus, owner: wref<GameObject>) -> Void {
    let trigger: ref<BaseStateOperationsTrigger>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggers) {
      trigger = this.m_triggers[i] as BaseStateOperationsTrigger;
      if trigger != null {
        trigger.EvaluateTrigger(state, owner, this);
      };
      i += 1;
    };
  }
}
