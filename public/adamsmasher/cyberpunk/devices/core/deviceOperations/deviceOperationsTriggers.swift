
public abstract class DeviceOperationsTrigger extends IScriptable {

  public func Initialize(owner: ref<GameObject>) -> Void;

  public func UnInitialize(owner: ref<GameObject>) -> Void;

  protected final func GetOperationsContainer(owner: ref<GameObject>) -> ref<DeviceOperationsContainer> {
    let device: ref<Device> = owner as Device;
    if device != null {
      return device.GetDevicePS().GetDeviceOperationsContainer();
    };
    return null;
  }

  protected final func ExecuteOperationByName(operationName: CName, owner: ref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    if this.GetOperationsContainer(owner) != null {
      this.GetOperationsContainer(owner).Execute(operationName, owner);
    };
  }

  protected final func RestoreOperationByName(operationName: CName, owner: ref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    if this.GetOperationsContainer(owner) != null {
      this.GetOperationsContainer(owner).Restore(operationName, owner);
    };
  }

  protected final func ResolveOperationsOnTrigger(trigger: ref<DeviceOperationTriggerData>, owner: ref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    let i: Int32;
    let namedOperation: ref<OperationExecutionData>;
    if trigger == null {
      return;
    };
    i = 0;
    while i < ArraySize(trigger.operationsToExecute) {
      namedOperation = trigger.operationsToExecute[i];
      if namedOperation == null {
      } else {
        if namedOperation.delay <= 0.00 {
          this.ExecuteOperationByName(trigger.operationsToExecute[i].operationName, owner, container);
        } else {
          if !namedOperation.isDelayActive {
            this.DelayTriggerExecution(namedOperation, owner);
          } else {
            if namedOperation.resetDelay {
              GameInstance.GetDelaySystem(owner.GetGame()).CancelDelay(namedOperation.delayID);
              this.DelayTriggerExecution(namedOperation, owner);
            };
          };
        };
      };
      i += 1;
    };
  }

  protected final func RestoreOperationsOnTrigger(trigger: ref<DeviceOperationTriggerData>, owner: ref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    let i: Int32;
    let namedOperation: ref<OperationExecutionData>;
    if trigger == null {
      return;
    };
    i = 0;
    while i < ArraySize(trigger.operationsToExecute) {
      namedOperation = trigger.operationsToExecute[i];
      if namedOperation == null {
      } else {
        this.RestoreOperationByName(trigger.operationsToExecute[i].operationName, owner, container);
      };
      i += 1;
    };
  }

  protected final func DelayTriggerExecution(namedOperation: ref<OperationExecutionData>, owner: ref<GameObject>) -> Void {
    let delayID: DelayID;
    let evt: ref<DelayedDeviceOperationTriggerEvent>;
    if this.GetOperationsContainer(owner) == null || !this.GetOperationsContainer(owner).IsOperationEnabled(namedOperation.operationName) {
      return;
    };
    evt = new DelayedDeviceOperationTriggerEvent();
    evt.namedOperation = namedOperation;
    evt.triggerHandler = this;
    delayID = GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, evt, namedOperation.delay);
    this.SetDelayIdOnNamedOperation(delayID, namedOperation);
  }

  public func SetDelayIdOnNamedOperation(delayID: DelayID, namedOperation: ref<OperationExecutionData>) -> Void {
    namedOperation.delayID = delayID;
    namedOperation.isDelayActive = true;
  }

  public func ClearDelayIdOnNamedOperation(namedOperation: ref<OperationExecutionData>) -> Void {
    namedOperation.isDelayActive = false;
  }

  protected final func IsPlayerActivator(activator: wref<GameObject>) -> Bool {
    return IsDefined(activator as PlayerPuppet) || IsDefined(activator as Muppet);
  }
}

public class FactOperationsTrigger extends DeviceOperationsTrigger {

  public inline let m_triggerData: ref<FactOperationTriggerData>;

  public func Initialize(owner: ref<GameObject>) -> Void {
    this.RegisterQuestDBCallback(owner);
  }

  public func UnInitialize(owner: ref<GameObject>) -> Void {
    this.UnRegisterQuestDBCallback(owner);
  }

  public final func EvaluateTrigger(owner: wref<GameObject>, factName: CName, container: ref<DeviceOperationsContainer>) -> Void {
    let currentValue: Int32;
    if owner != null && Equals(factName, this.m_triggerData.factName) {
      currentValue = GetFact(owner.GetGame(), factName);
      switch this.m_triggerData.comparisionType {
        case EComparisonOperator.Equal:
          if currentValue != this.m_triggerData.factValue {
            return;
          };
          break;
        case EComparisonOperator.NotEqual:
          if currentValue == this.m_triggerData.factValue {
            return;
          };
          break;
        case EComparisonOperator.More:
          if currentValue <= this.m_triggerData.factValue {
            return;
          };
          break;
        case EComparisonOperator.MoreOrEqual:
          if currentValue < this.m_triggerData.factValue {
            return;
          };
          break;
        case EComparisonOperator.Less:
          if currentValue >= this.m_triggerData.factValue {
            return;
          };
          break;
        case EComparisonOperator.LessOrEqual:
          if currentValue > this.m_triggerData.factValue {
            return;
          };
          break;
        default:
      };
    };
    this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
  }

  public final func RegisterQuestDBCallback(owner: ref<GameObject>) -> Void {
    this.m_triggerData.callbackID = GameInstance.GetQuestsSystem(owner.GetGame()).RegisterEntity(this.m_triggerData.factName, owner.GetEntityID());
  }

  public final func UnRegisterQuestDBCallback(owner: ref<GameObject>) -> Void {
    if IsNameValid(this.m_triggerData.factName) && this.m_triggerData.callbackID > 0u {
      GameInstance.GetQuestsSystem(owner.GetGame()).UnregisterEntity(this.m_triggerData.factName, this.m_triggerData.callbackID);
    };
  }
}

public class FocusModeOperationsTrigger extends DeviceOperationsTrigger {

  public inline let m_triggerData: ref<FocusModeOperationTriggerData>;

  public final func EvaluateTrigger(owner: wref<GameObject>, operationType: ETriggerOperationType, container: ref<DeviceOperationsContainer>) -> Void {
    if Equals(this.m_triggerData.operationType, operationType) {
      if Equals(this.m_triggerData.operationType, ETriggerOperationType.ENTER) && this.m_triggerData.isLookedAt && !this.IsLookedAt(owner) {
        return;
      };
      this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }

  private final func IsLookedAt(object: ref<GameObject>) -> Bool {
    let lookedAtObect: ref<GameObject> = GameInstance.GetTargetingSystem(object.GetGame()).GetLookAtObject(GameInstance.GetPlayerSystem(object.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet);
    return lookedAtObect == object;
  }
}

public class SensesOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<SensesOperationTriggerData>;

  public final func EvaluateTrigger(owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType, container: ref<DeviceOperationsContainer>) -> Void {
    let attitudeAgent: ref<AttitudeAgent>;
    let attitudeGroup: CName;
    if this.m_triggerData == null {
      return;
    };
    if Equals(this.m_triggerData.operationType, operationType) {
      if this.IsPlayerActivator(activator) && this.m_triggerData.isActivatorPlayer {
        this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
      } else {
        if !this.IsPlayerActivator(activator) && this.m_triggerData.isActivatorNPC {
          if IsNameValid(this.m_triggerData.attitudeGroup) {
            attitudeAgent = activator.GetAttitudeAgent();
            if attitudeAgent != null {
              attitudeGroup = attitudeAgent.GetAttitudeGroup();
              if NotEquals(attitudeGroup, this.m_triggerData.attitudeGroup) {
                return;
              };
            };
          };
          this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
        };
      };
    };
  }
}

public class HitOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<HitOperationTriggerData>;

  public final func EvaluateTrigger(owner: wref<GameObject>, activator: wref<GameObject>, attackData: ref<AttackData>, container: ref<DeviceOperationsContainer>) -> Void {
    let attackType: gamedataAttackType;
    let healthPercentage: Float;
    let device: ref<Device> = owner as Device;
    if device == null {
      return;
    };
    attackType = attackData.GetAttackType();
    healthPercentage = device.GetCurrentHealth();
    if this.m_triggerData == null {
      return;
    };
    if AttackData.IsBullet(attackType) && !this.m_triggerData.bullets {
      return;
    };
    if AttackData.IsExplosion(attackType) && !this.m_triggerData.explosions {
      return;
    };
    if AttackData.IsMelee(attackType) && !this.m_triggerData.melee {
      return;
    };
    if healthPercentage > this.m_triggerData.healthPercentage {
      return;
    };
    if this.IsPlayerActivator(activator) && this.m_triggerData.isAttackerPlayer {
      this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
    } else {
      if !this.IsPlayerActivator(activator) && this.m_triggerData.isAttackerNPC {
        this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
      };
    };
  }
}

public class InteractionAreaOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<InteractionAreaOperationTriggerData>;

  public final func EvaluateTrigger(areaTag: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: gameinteractionsEInteractionEventType, container: ref<DeviceOperationsContainer>) -> Void {
    if this.m_triggerData == null {
      return;
    };
    if Equals(this.m_triggerData.areaTag, areaTag) && Equals(this.m_triggerData.operationType, operationType) {
      if this.IsPlayerActivator(activator) && this.m_triggerData.isActivatorPlayer {
        this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
      } else {
        if !this.IsPlayerActivator(activator) && this.m_triggerData.isActivatorNPC {
          this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
        };
      };
    };
  }
}

public class TriggerVolumeOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<TriggerVolumeOperationTriggerData>;

  public final func EvaluateTrigger(componentName: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType, container: ref<DeviceOperationsContainer>) -> Void {
    if this.m_triggerData == null {
      return;
    };
    if Equals(this.m_triggerData.componentName, componentName) && Equals(this.m_triggerData.operationType, operationType) {
      if this.IsPlayerActivator(activator) && this.m_triggerData.isActivatorPlayer {
        this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
      } else {
        if !this.IsPlayerActivator(activator) && this.m_triggerData.isActivatorNPC {
          if this.m_triggerData.canNPCBeDead || activator.IsActive() {
            this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
          };
        };
      };
    };
  }
}

public class DeviceActionOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<DeviceActionOperationTriggerData>;

  public final func EvaluateTrigger(actionClassName: CName, owner: wref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    let currentActionName: CName;
    if this.m_triggerData == null {
      return;
    };
    currentActionName = this.m_triggerData.action.GetClassName();
    if Equals(currentActionName, actionClassName) {
      this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }

  public final func RestoreOperation(actionClassName: CName, owner: wref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    if Equals(this.m_triggerData.action.GetClassName(), actionClassName) {
      this.RestoreOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }
}

public class CustomActionOperationsTriggers extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<CustomActionOperationTriggerData>;

  public final func EvaluateTrigger(actionID: CName, owner: wref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    if this.m_triggerData == null {
      return;
    };
    if Equals(this.m_triggerData.actionID, actionID) {
      this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }

  public final func RestoreOperation(actionID: CName, owner: wref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    if this.m_triggerData == null {
      return;
    };
    if Equals(this.m_triggerData.actionID, actionID) {
      this.RestoreOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }
}

public class DoorStateOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<DoorStateOperationTriggerData>;

  private let m_wasStateCached: Bool;

  private let m_cachedState: EDoorStatus;

  public final func EvaluateTrigger(state: EDoorStatus, owner: wref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    if this.m_wasStateCached && Equals(this.m_cachedState, state) {
      return;
    };
    this.m_cachedState = state;
    this.m_wasStateCached = true;
    if this.m_triggerData == null {
      return;
    };
    if Equals(this.m_triggerData.state, state) {
      this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }
}

public class BaseStateOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<BaseStateOperationTriggerData>;

  private let m_wasStateCached: Bool;

  private let m_cachedState: EDeviceStatus;

  public final func EvaluateTrigger(state: EDeviceStatus, owner: wref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    if this.m_wasStateCached && Equals(this.m_cachedState, state) {
      return;
    };
    this.m_cachedState = state;
    this.m_wasStateCached = true;
    if this.m_triggerData == null {
      return;
    };
    if Equals(this.m_triggerData.state, state) {
      this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }
}

public class ActivatorOperationsTrigger extends DeviceOperationsTrigger {

  protected inline let m_triggerData: ref<ActivatorOperationTriggerData>;

  public final func EvaluateTrigger(owner: wref<GameObject>, container: ref<DeviceOperationsContainer>) -> Void {
    let device: wref<Device>;
    if this.m_triggerData == null {
      return;
    };
    device = owner as Device;
    if IsDefined(device) && !device.GetDevicePS().IsDisabled() {
      this.ResolveOperationsOnTrigger(this.m_triggerData, owner, container);
    };
  }
}
