
public class FocusModeOperations extends DeviceOperations {

  protected const let m_focusModeOperations: array<SFocusModeOperationData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_focusModeOperations) {
      this.m_focusModeOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_focusModeOperations[i].operation.components) {
        componentName = this.m_focusModeOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_focusModeOperations) {
      k = 0;
      while k < ArraySize(this.m_focusModeOperations[i].operation.components) {
        componentName = this.m_focusModeOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_focusModeOperations) {
      this.m_focusModeOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_focusModeOperations) {
      return this.m_focusModeOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_focusModeOperations) {
      this.m_focusModeOperations[operationID].operation.delayID = delayId;
      this.m_focusModeOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_focusModeOperations) {
      this.m_focusModeOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(owner: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_focusModeOperations) {
      if Equals(this.m_focusModeOperations[i].operationType, operationType) {
        if Equals(this.m_focusModeOperations[i].operationType, ETriggerOperationType.ENTER) && this.m_focusModeOperations[i].isLookedAt && !this.IsLookedAt(owner) {
          return;
        };
        this.Execute(this.m_focusModeOperations[i].operation, owner);
      };
      i += 1;
    };
  }

  public final func RestoreOperation(owner: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_focusModeOperations) {
      if Equals(this.m_focusModeOperations[i].operationType, operationType) {
        this.Restore(this.m_focusModeOperations[i].operation, owner);
      };
      i += 1;
    };
  }

  private final func IsLookedAt(object: ref<GameObject>) -> Bool {
    let lookedAtObect: ref<GameObject> = GameInstance.GetTargetingSystem(object.GetGame()).GetLookAtObject(GameInstance.GetPlayerSystem(object.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet);
    return lookedAtObect == object;
  }
}

public class SensesOperations extends DeviceOperations {

  protected const let m_sensesOperations: array<SSensesOperationData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_sensesOperations) {
      this.m_sensesOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_sensesOperations[i].operation.components) {
        componentName = this.m_sensesOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_sensesOperations) {
      k = 0;
      while k < ArraySize(this.m_sensesOperations[i].operation.components) {
        componentName = this.m_sensesOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_sensesOperations) {
      this.m_sensesOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_sensesOperations) {
      return this.m_sensesOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_sensesOperations) {
      this.m_sensesOperations[operationID].operation.delayID = delayId;
      this.m_sensesOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_sensesOperations) {
      this.m_sensesOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let attitudeAgent: ref<AttitudeAgent>;
    let attitudeGroup: CName;
    let i: Int32 = 0;
    while i < ArraySize(this.m_sensesOperations) {
      if Equals(this.m_sensesOperations[i].operationType, operationType) {
        if IsDefined(activator as PlayerPuppet) && this.m_sensesOperations[i].isActivatorPlayer {
          this.Execute(this.m_sensesOperations[i].operation, owner);
        } else {
          if (activator as PlayerPuppet) == null && this.m_sensesOperations[i].isActivatorNPC {
            if IsNameValid(this.m_sensesOperations[i].attitudeGroup) {
              attitudeAgent = activator.GetAttitudeAgent();
              if attitudeAgent != null {
                attitudeGroup = attitudeAgent.GetAttitudeGroup();
                if NotEquals(attitudeGroup, this.m_sensesOperations[i].attitudeGroup) {
                  return;
                };
              };
            };
            this.Execute(this.m_sensesOperations[i].operation, owner);
          };
        };
      };
      i += 1;
    };
  }

  public final func RestoreOperation(owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_sensesOperations) {
      if Equals(this.m_sensesOperations[i].operationType, operationType) {
        this.Restore(this.m_sensesOperations[i].operation, owner);
      };
      i += 1;
    };
  }
}

public class HitOperations extends DeviceOperations {

  protected const let m_hitOperations: array<SHitOperationData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_hitOperations) {
      this.m_hitOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_hitOperations[i].operation.components) {
        componentName = this.m_hitOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_hitOperations) {
      k = 0;
      while k < ArraySize(this.m_hitOperations[i].operation.components) {
        componentName = this.m_hitOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_hitOperations) {
      this.m_hitOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_hitOperations) {
      return this.m_hitOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_hitOperations) {
      this.m_hitOperations[operationID].operation.delayID = delayId;
      this.m_hitOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_hitOperations) {
      this.m_hitOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(owner: wref<GameObject>, activator: wref<GameObject>, attackData: ref<AttackData>) -> Void {
    let attackType: gamedataAttackType;
    let healthPercentage: Float;
    let i: Int32;
    let device: ref<Device> = owner as Device;
    if device == null {
      return;
    };
    attackType = attackData.GetAttackType();
    healthPercentage = device.GetCurrentHealth();
    i = 0;
    while i < ArraySize(this.m_hitOperations) {
      if AttackData.IsBullet(attackType) && !this.m_hitOperations[i].bullets {
        return;
      };
      if AttackData.IsExplosion(attackType) && !this.m_hitOperations[i].explosions {
        return;
      };
      if AttackData.IsMelee(attackType) && !this.m_hitOperations[i].melee {
        return;
      };
      if healthPercentage > this.m_hitOperations[i].healthPercentage {
        return;
      };
      if IsDefined(activator as PlayerPuppet) && this.m_hitOperations[i].isAttackerPlayer {
        this.Execute(this.m_hitOperations[i].operation, owner);
      } else {
        if (activator as PlayerPuppet) == null && this.m_hitOperations[i].isAttackerNPC {
          this.Execute(this.m_hitOperations[i].operation, owner);
        };
      };
      i += 1;
    };
  }

  public final func RestoreOperation(owner: wref<GameObject>, activator: wref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_hitOperations) {
      this.Restore(this.m_hitOperations[i].operation, owner);
      i += 1;
    };
  }
}

public class InteractionAreaOperations extends DeviceOperations {

  protected const let m_interactionAreaOperations: array<SInteractionAreaOperationData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_interactionAreaOperations) {
      this.m_interactionAreaOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_interactionAreaOperations[i].operation.components) {
        componentName = this.m_interactionAreaOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_interactionAreaOperations) {
      k = 0;
      while k < ArraySize(this.m_interactionAreaOperations[i].operation.components) {
        componentName = this.m_interactionAreaOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_interactionAreaOperations) {
      this.m_interactionAreaOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_interactionAreaOperations) {
      return this.m_interactionAreaOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_interactionAreaOperations) {
      this.m_interactionAreaOperations[operationID].operation.delayID = delayId;
      this.m_interactionAreaOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_interactionAreaOperations) {
      this.m_interactionAreaOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(areaTag: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: gameinteractionsEInteractionEventType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_interactionAreaOperations) {
      if Equals(this.m_interactionAreaOperations[i].areaTag, areaTag) && Equals(this.m_interactionAreaOperations[i].operationType, operationType) {
        if IsDefined(activator as PlayerPuppet) && this.m_interactionAreaOperations[i].isActivatorPlayer {
          this.Execute(this.m_interactionAreaOperations[i].operation, owner);
        } else {
          if (activator as PlayerPuppet) == null && this.m_interactionAreaOperations[i].isActivatorNPC {
            this.Execute(this.m_interactionAreaOperations[i].operation, owner);
          };
        };
      };
      i += 1;
    };
  }

  public final func RestoreOperation(areaTag: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: gameinteractionsEInteractionEventType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_interactionAreaOperations) {
      if Equals(this.m_interactionAreaOperations[i].areaTag, areaTag) && Equals(this.m_interactionAreaOperations[i].operationType, operationType) {
        this.Restore(this.m_interactionAreaOperations[i].operation, owner);
      };
      i += 1;
    };
  }
}

public class TriggerVolumeOperations extends DeviceOperations {

  protected const let m_triggerVolumeOperations: array<STriggerVolumeOperationData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggerVolumeOperations) {
      this.m_triggerVolumeOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_triggerVolumeOperations[i].operation.components) {
        componentName = this.m_triggerVolumeOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggerVolumeOperations) {
      k = 0;
      while k < ArraySize(this.m_triggerVolumeOperations[i].operation.components) {
        componentName = this.m_triggerVolumeOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_triggerVolumeOperations) {
      this.m_triggerVolumeOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_triggerVolumeOperations) {
      return this.m_triggerVolumeOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_triggerVolumeOperations) {
      this.m_triggerVolumeOperations[operationID].operation.delayID = delayId;
      this.m_triggerVolumeOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_triggerVolumeOperations) {
      this.m_triggerVolumeOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(componentName: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggerVolumeOperations) {
      if Equals(this.m_triggerVolumeOperations[i].componentName, componentName) && Equals(this.m_triggerVolumeOperations[i].operationType, operationType) {
        if IsDefined(activator as PlayerPuppet) && this.m_triggerVolumeOperations[i].isActivatorPlayer {
          this.Execute(this.m_triggerVolumeOperations[i].operation, owner);
        } else {
          if (activator as PlayerPuppet) == null && this.m_triggerVolumeOperations[i].isActivatorNPC {
            this.Execute(this.m_triggerVolumeOperations[i].operation, owner);
          };
        };
      };
      i += 1;
    };
  }

  public final func RestoreOperation(componentName: CName, owner: wref<GameObject>, activator: wref<GameObject>, operationType: ETriggerOperationType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggerVolumeOperations) {
      if Equals(this.m_triggerVolumeOperations[i].componentName, componentName) && Equals(this.m_triggerVolumeOperations[i].operationType, operationType) {
        this.Restore(this.m_triggerVolumeOperations[i].operation, owner);
      };
      i += 1;
    };
  }
}

public class BaseActionOperations extends DeviceOperations {

  protected const let m_baseActionsOperations: array<SBaseActionOperationData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_baseActionsOperations) {
      this.m_baseActionsOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_baseActionsOperations[i].operation.components) {
        componentName = this.m_baseActionsOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_baseActionsOperations) {
      k = 0;
      while k < ArraySize(this.m_baseActionsOperations[i].operation.components) {
        componentName = this.m_baseActionsOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_baseActionsOperations) {
      this.m_baseActionsOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_baseActionsOperations) {
      return this.m_baseActionsOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_baseActionsOperations) {
      this.m_baseActionsOperations[operationID].operation.delayID = delayId;
      this.m_baseActionsOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_baseActionsOperations) {
      this.m_baseActionsOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(actionClassName: CName, owner: wref<GameObject>) -> Void {
    let currentActionName: CName;
    let i: Int32 = 0;
    while i < ArraySize(this.m_baseActionsOperations) {
      currentActionName = this.m_baseActionsOperations[i].action.GetClassName();
      if Equals(currentActionName, actionClassName) {
        this.Execute(this.m_baseActionsOperations[i].operation, owner);
      };
      i += 1;
    };
  }

  public final func RestoreOperation(actionClassName: CName, owner: wref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_baseActionsOperations) {
      if Equals(this.m_baseActionsOperations[i].action.GetClassName(), actionClassName) {
        this.Restore(this.m_baseActionsOperations[i].operation, owner);
      };
      i += 1;
    };
  }
}

public class CustomActionOperations extends DeviceOperations {

  public let m_customActions: SCustomDeviceActionsData;

  protected const let m_customActionsOperations: array<SCustomActionOperationData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_customActionsOperations) {
      this.m_customActionsOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_customActionsOperations[i].operation.components) {
        componentName = this.m_customActionsOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_customActionsOperations) {
      k = 0;
      while k < ArraySize(this.m_customActionsOperations[i].operation.components) {
        componentName = this.m_customActionsOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_customActionsOperations) {
      this.m_customActionsOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_customActionsOperations) {
      return this.m_customActionsOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_customActionsOperations) {
      this.m_customActionsOperations[operationID].operation.delayID = delayId;
      this.m_customActionsOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_customActionsOperations) {
      this.m_customActionsOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(actionID: CName, owner: wref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_customActionsOperations) {
      if Equals(this.m_customActionsOperations[i].actionID, actionID) {
        this.Execute(this.m_customActionsOperations[i].operation, owner);
      };
      i += 1;
    };
  }

  public final func RestoreOperation(actionID: CName, owner: wref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_customActionsOperations) {
      if Equals(this.m_customActionsOperations[i].actionID, actionID) {
        this.Restore(this.m_customActionsOperations[i].operation, owner);
      };
      i += 1;
    };
  }
}

public class DoorStateOperations extends DeviceOperations {

  protected const let m_doorStateOperations: array<SDoorStateOperationData>;

  private let m_wasStateCached: Bool;

  private let m_cachedState: EDoorStatus;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_doorStateOperations) {
      this.m_doorStateOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_doorStateOperations[i].operation.components) {
        componentName = this.m_doorStateOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_doorStateOperations) {
      k = 0;
      while k < ArraySize(this.m_doorStateOperations[i].operation.components) {
        componentName = this.m_doorStateOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_doorStateOperations) {
      this.m_doorStateOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_doorStateOperations) {
      return this.m_doorStateOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_doorStateOperations) {
      this.m_doorStateOperations[operationID].operation.delayID = delayId;
      this.m_doorStateOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_doorStateOperations) {
      this.m_doorStateOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(state: EDoorStatus, owner: wref<GameObject>) -> Void {
    let i: Int32;
    if this.m_wasStateCached && Equals(this.m_cachedState, state) {
      return;
    };
    this.m_cachedState = state;
    this.m_wasStateCached = true;
    i = 0;
    while i < ArraySize(this.m_doorStateOperations) {
      if Equals(this.m_doorStateOperations[i].state, state) {
        this.Execute(this.m_doorStateOperations[i].operation, owner);
      };
      i += 1;
    };
  }
}

public class BaseStateOperations extends DeviceOperations {

  public let m_stateActionsOverrides: SGenericDeviceActionsData;

  protected const let m_baseStateOperations: array<SBaseStateOperationData>;

  private let m_wasStateCached: Bool;

  private let m_cachedState: EDeviceStatus;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void {
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_baseStateOperations) {
      this.m_baseStateOperations[i].operation.id = i;
      k = 0;
      while k < ArraySize(this.m_baseStateOperations[i].operation.components) {
        componentName = this.m_baseStateOperations[i].operation.components[k].componentName;
        EntityRequestComponentsInterface.RequestComponent(ri, componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
  }

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void {
    let component: wref<IPlacedComponent>;
    let componentName: CName;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_baseStateOperations) {
      k = 0;
      while k < ArraySize(this.m_baseStateOperations[i].operation.components) {
        componentName = this.m_baseStateOperations[i].operation.components[k].componentName;
        component = EntityResolveComponentsInterface.GetComponent(ri, componentName) as IPlacedComponent;
        if component != null && !ArrayContains(this.m_components, component) {
          ArrayPush(this.m_components, component);
        };
        k += 1;
      };
      i += 1;
    };
  }

  public func ToggleOperation(enable: Bool, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_baseStateOperations) {
      this.m_baseStateOperations[index].operation.isEnabled = enable;
    };
  }

  public const func IsOperationEnabled(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_baseStateOperations) {
      return this.m_baseStateOperations[index].operation.isEnabled;
    };
    return false;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_baseStateOperations) {
      this.m_baseStateOperations[operationID].operation.delayID = delayId;
      this.m_baseStateOperations[operationID].operation.isDelayActive = true;
    };
  }

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void {
    if operationID >= 0 && operationID < ArraySize(this.m_baseStateOperations) {
      this.m_baseStateOperations[operationID].operation.isDelayActive = false;
    };
  }

  public final func ExecuteOperation(state: EDeviceStatus, owner: wref<GameObject>) -> Void {
    let i: Int32;
    if this.m_wasStateCached && Equals(this.m_cachedState, state) {
      return;
    };
    this.m_cachedState = state;
    this.m_wasStateCached = true;
    i = 0;
    while i < ArraySize(this.m_baseStateOperations) {
      if Equals(this.m_baseStateOperations[i].state, state) {
        this.Execute(this.m_baseStateOperations[i].operation, owner);
      };
      i += 1;
    };
  }
}

public abstract class DeviceOperations extends IScriptable {

  protected let m_components: array<wref<IPlacedComponent>>;

  protected let m_fxInstances: array<SVfxInstanceData>;

  public func RequestComponents(ri: EntityRequestComponentsInterface) -> Void;

  public func TakeControl(ri: EntityResolveComponentsInterface) -> Void;

  public func ToggleOperation(enable: Bool, index: Int32) -> Void;

  public const func IsOperationEnabled(index: Int32) -> Bool {
    return true;
  }

  public func SetDelayIdOnOperation(delayId: DelayID, operationID: Int32) -> Void;

  public func ClearDelayIdOnOperation(operationID: Int32) -> Void;

  protected final func SendToggleOperataionEvent(enable: Bool, index: Int32, type: EOperationClassType, owner: wref<GameObject>) -> Void {
    let evt: ref<ToggleOperationEvent> = new ToggleOperationEvent();
    evt.enable = enable;
    evt.index = index;
    evt.type = type;
    owner.QueueEvent(evt);
  }

  protected final func DelayOperation(operation: SBaseDeviceOperationData, owner: wref<GameObject>) -> Void {
    let evt: ref<DelayedOperationEvent> = new DelayedOperationEvent();
    evt.operationHandler = this;
    evt.operation = operation;
    let delayID: DelayID = GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, evt, operation.delay);
    this.SetDelayIdOnOperation(delayID, operation.id);
  }

  public final func Execute(operation: SBaseDeviceOperationData, owner: wref<GameObject>) -> Void {
    if !this.IsOperationEnabled(operation.id) {
      return;
    };
    if operation.delay <= 0.00 {
      this.ClearDelayIdOnOperation(operation.id);
      this.ResolveVFXs(operation.VFXs, owner);
      this.ResolveSFXs(operation.SFXs, owner);
      this.ResolveFacts(operation.facts, owner);
      this.ResolveComponents(operation.components);
      this.ResolveMeshesAppearence(operation.meshesAppearence, owner);
      this.ResolveTransformAnimations(operation.transformAnimations, owner);
      this.ResolveWorkspots(operation.playerWorkspot, owner);
      this.ResolveStims(operation.stims, owner);
      this.ResolveStatusEffects(operation.statusEffects, owner);
      this.ResolveDamages(operation.damages, owner);
      this.ResolveItems(operation.items, owner);
      this.ResolveTeleport(operation.teleport, owner);
      this.ResolveOperations(operation.toggleOperations, owner);
      this.ResolveDisable(operation.disableDevice, owner);
      if operation.executeOnce {
        this.ToggleOperation(false, operation.id);
      };
    } else {
      if !operation.isDelayActive {
        this.DelayOperation(operation, owner);
      } else {
        if operation.resetDelay {
          GameInstance.GetDelaySystem(owner.GetGame()).CancelDelay(operation.delayID);
          this.DelayOperation(operation, owner);
        };
      };
    };
  }

  public final func Restore(operation: SBaseDeviceOperationData, owner: wref<GameObject>) -> Void {
    this.ResolveVFXs(operation.VFXs, owner);
    this.ResolveSFXs(operation.SFXs, owner);
    this.ResolveComponents(operation.components);
    this.ResolveMeshesAppearence(operation.meshesAppearence, owner);
    this.ResolveTransformAnimations(operation.transformAnimations, owner);
    this.ResolveWorkspots(operation.playerWorkspot, owner);
    this.ResolveStims(operation.stims, owner);
    this.ResolveStatusEffects(operation.statusEffects, owner);
  }

  private final func ResolveDisable(disable: Bool, owner: wref<GameObject>) -> Void {
    let device: ref<Device>;
    if disable {
      device = owner as Device;
      if device == null {
        return;
      };
      device.GetDevicePS().ForceDisableDevice();
    };
  }

  private final func ResolveOperations(operations: array<SToggleOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(operations) {
      if Equals(operations[i].classType, EOperationClassType.Local) {
        this.ToggleOperation(operations[i].enable, operations[i].index);
      } else {
        this.SendToggleOperataionEvent(operations[i].enable, operations[i].index, operations[i].classType, owner);
      };
      i += 1;
    };
  }

  private final func ResolveTeleport(teleport: STeleportOperationData, owner: wref<GameObject>) -> Void {
    let puppet: ref<GameObject>;
    if owner == null {
      return;
    };
    puppet = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if puppet == null {
      return;
    };
    GameInstance.GetTeleportationFacility(owner.GetGame()).TeleportToNode(puppet, teleport.nodeRef);
  }

  private final func ResolveItems(items: array<SInventoryOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    let puppet: ref<GameObject>;
    let transactionSystem: ref<TransactionSystem>;
    if owner == null {
      return;
    };
    puppet = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if puppet == null {
      return;
    };
    transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    i = 0;
    while i < ArraySize(items) {
      if Equals(items[i].operationType, EItemOperationType.ADD) {
        transactionSystem.GiveItem(puppet, ItemID.FromTDBID(items[i].itemName), items[i].quantity);
      } else {
        if Equals(items[i].operationType, EItemOperationType.REMOVE) {
          transactionSystem.RemoveItem(puppet, ItemID.FromTDBID(items[i].itemName), items[i].quantity);
        };
      };
      i += 1;
    };
  }

  private final func ResolveVFXs(VFXs: array<SVFXOperationData>, owner: wref<GameObject>) -> Void {
    let effectBlackboard: ref<worldEffectBlackboard>;
    let fxInstance: ref<FxInstance>;
    let i: Int32;
    let position: WorldPosition;
    let target: ref<GameEntity>;
    let targetID: EntityID;
    let transform: WorldTransform;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(VFXs) {
      targetID = Cast(ResolveNodeRefWithEntityID(VFXs[i].nodeRef, owner.GetEntityID()));
      target = GameInstance.FindEntityByID(owner.GetGame(), targetID) as GameEntity;
      if target == null {
        target = owner;
      };
      if target == null {
      } else {
        if Equals(VFXs[i].operationType, EEffectOperationType.START) {
          if FxResource.IsValid(VFXs[i].vfxResource) {
            fxInstance = this.GetFxInstance(VFXs[i].vfxName);
            if fxInstance != null {
              this.RemoveFxInstance(VFXs[i].vfxName);
              fxInstance.Kill();
            };
            WorldPosition.SetVector4(position, target.GetWorldPosition());
            WorldTransform.SetWorldPosition(transform, position);
            fxInstance = this.CreateFxInstance(owner, VFXs[i].vfxName, VFXs[i].vfxResource, transform);
            fxInstance.SetBlackboardValue(n"change_size", VFXs[i].size);
            this.StoreFxInstance(VFXs[i].vfxName, fxInstance);
          } else {
            effectBlackboard = new worldEffectBlackboard();
            effectBlackboard.SetValue(n"change_size", VFXs[i].size);
            GameObjectEffectHelper.StartEffectEvent(target as GameObject, VFXs[i].vfxName, VFXs[i].shouldPersist, effectBlackboard);
          };
        } else {
          if Equals(VFXs[i].operationType, EEffectOperationType.STOP) {
            fxInstance = this.GetFxInstance(VFXs[i].vfxName);
            if fxInstance == null {
              GameObjectEffectHelper.StopEffectEvent(target as GameObject, VFXs[i].vfxName);
            } else {
              this.RemoveFxInstance(VFXs[i].vfxName);
              fxInstance.Kill();
            };
          } else {
            if Equals(VFXs[i].operationType, EEffectOperationType.BRAKE_LOOP) {
              fxInstance = this.GetFxInstance(VFXs[i].vfxName);
              if fxInstance == null {
                GameObjectEffectHelper.BreakEffectLoopEvent(target as GameObject, VFXs[i].vfxName);
              } else {
                fxInstance.BreakLoop();
              };
            };
          };
        };
      };
      i += 1;
    };
  }

  private final func ResolveSFXs(SFXs: array<SSFXOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(SFXs) {
      GameObject.PlaySoundEvent(owner, SFXs[i].sfxName);
      i += 1;
    };
  }

  private final func ResolveFacts(facts: array<SFactOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(facts) {
      if IsNameValid(facts[i].factName) {
        if Equals(facts[i].operationType, EMathOperationType.Add) {
          AddFact(owner.GetGame(), facts[i].factName, facts[i].factValue);
        } else {
          SetFactValue(owner.GetGame(), facts[i].factName, facts[i].factValue);
        };
      };
      i += 1;
    };
  }

  private final func ResolveComponents(componentsData: array<SComponentOperationData>) -> Void {
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(componentsData) {
      k = 0;
      while k < ArraySize(this.m_components) {
        if this.m_components[k] == null {
        } else {
          if Equals(componentsData[i].componentName, this.m_components[k].GetName()) {
            if Equals(componentsData[i].operationType, EComponentOperation.Enable) {
              this.m_components[k].Toggle(true);
            } else {
              this.m_components[k].Toggle(false);
            };
          };
        };
        k += 1;
      };
      i += 1;
    };
  }

  private final func ResolveMeshesAppearence(appearanceName: CName, owner: wref<GameObject>) -> Void {
    if owner == null {
      return;
    };
    if IsNameValid(appearanceName) {
      GameObject.SetMeshAppearanceEvent(owner, appearanceName);
    };
  }

  private final func ResolveTransformAnimations(animations: array<STransformAnimationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    let pauseEvent: ref<gameTransformAnimationPauseEvent>;
    let playEvent: ref<gameTransformAnimationPlayEvent>;
    let resetEvent: ref<gameTransformAnimationResetEvent>;
    let skipEvent: ref<gameTransformAnimationSkipEvent>;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(animations) {
      if Equals(animations[i].operationType, ETransformAnimationOperationType.PLAY) {
        playEvent = new gameTransformAnimationPlayEvent();
        playEvent.animationName = animations[i].animationName;
        playEvent.timeScale = animations[i].playData.timeScale;
        playEvent.looping = animations[i].playData.looping;
        playEvent.timesPlayed = animations[i].playData.timesPlayed;
        owner.QueueEvent(playEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.PAUSE) {
        pauseEvent = new gameTransformAnimationPauseEvent();
        pauseEvent.animationName = animations[i].animationName;
        owner.QueueEvent(pauseEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.RESET) {
        resetEvent = new gameTransformAnimationResetEvent();
        resetEvent.animationName = animations[i].animationName;
        owner.QueueEvent(resetEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.SKIP) {
        skipEvent = new gameTransformAnimationSkipEvent();
        skipEvent.animationName = animations[i].animationName;
        skipEvent.time = animations[i].skipData.time;
        skipEvent.skipToEnd = animations[i].skipData.skipToEnd;
        owner.QueueEvent(skipEvent);
        return;
      };
      i += 1;
    };
  }

  private final func ResolveWorkspots(workspot: SWorkspotData, owner: wref<GameObject>) -> Void {
    let player: ref<GameObject>;
    let device: ref<Device> = owner as Device;
    if device == null {
      return;
    };
    player = GameInstance.GetPlayerSystem(device.GetGame()).GetLocalPlayerMainGameObject();
    if player == null {
      return;
    };
    if Equals(workspot.operationType, EWorkspotOperationType.ENTER) {
      if IsNameValid(workspot.componentName) {
        this.EnterWorkspot(device, player, workspot.freeCamera, workspot.componentName);
      };
    } else {
      if Equals(workspot.operationType, EWorkspotOperationType.LEAVE) {
        this.LeaveWorkspot(player);
      };
    };
  }

  private final func ResolveStims(stims: array<SStimOperationData>, owner: wref<GameObject>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let stimType: gamedataStimType;
    let target: ref<GameObject>;
    let targetID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(stims) {
      stimType = Device.MapStimType(stims[i].stimType);
      targetID = Cast(ResolveNodeRefWithEntityID(stims[i].nodeRef, owner.GetEntityID()));
      target = GameInstance.FindEntityByID(owner.GetGame(), targetID) as GameObject;
      if target == null {
        target = owner;
      };
      if target == null {
      } else {
        if Equals(stimType, gamedataStimType.Invalid) {
        } else {
          broadcaster = target.GetStimBroadcasterComponent();
          if IsDefined(broadcaster) {
            if Equals(stims[i].operationType, EEffectOperationType.START) {
              broadcaster.SetSingleActiveStimuli(owner, stimType, stims[i].lifeTime, stims[i].radius);
            } else {
              broadcaster.RemoveActiveStimuliByName(owner, stimType);
            };
          };
        };
      };
      i += 1;
    };
  }

  private final func ResolveStatusEffects(statusEffects: array<SStatusEffectOperationData>, owner: wref<GameObject>) -> Void {
    let effect: ref<EffectInstance>;
    let i: Int32;
    let position: Vector4;
    if owner == null {
      return;
    };
    position = owner.GetWorldPosition();
    i = 0;
    while i < ArraySize(statusEffects) {
      if statusEffects[i].range > 0.00 {
        effect = GameInstance.GetGameEffectSystem(owner.GetGame()).CreateEffectStatic(n"applyStatusEffect", n"inRange", owner);
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position + statusEffects[i].offset);
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, statusEffects[i].range);
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, statusEffects[i].duration);
        EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.statusEffect, ToVariant(statusEffects[i].effect.statusEffect));
        effect.Run();
      };
      i += 1;
    };
  }

  private final func ResolveDamages(damages: array<SDamageOperationData>, owner: wref<GameObject>) -> Void {
    let attackContext: AttackInitContext;
    let damageEffect: ref<EffectInstance>;
    let explosionAttack: ref<Attack_GameEffect>;
    let i: Int32;
    let player: ref<GameObject>;
    let position: Vector4;
    let statMods: array<ref<gameStatModifierData>>;
    if owner == null {
      return;
    };
    player = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    position = owner.GetWorldPosition();
    attackContext.instigator = player;
    attackContext.source = owner;
    i = 0;
    while i < ArraySize(damages) {
      if damages[i].range > 0.00 {
        attackContext.record = TweakDBInterface.GetAttackRecord(damages[i].damageType);
        explosionAttack = IAttack.Create(attackContext) as Attack_GameEffect;
        damageEffect = explosionAttack.PrepareAttack(owner);
        explosionAttack.GetStatModList(statMods);
        EffectData.SetFloat(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, damages[i].range);
        EffectData.SetVector(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position + damages[i].offset);
        EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
        EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
        explosionAttack.StartAttack();
      };
      i += 1;
    };
  }

  protected func EnterWorkspot(target: ref<Device>, activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDeviceSimple(target, activator, freeCamera, componentName);
  }

  protected func LeaveWorkspot(activator: ref<GameObject>) -> Void {
    let direction: Vector4;
    let orientation: Quaternion;
    let workspotSystem: ref<WorkspotGameSystem>;
    Quaternion.SetIdentity(orientation);
    direction = new Vector4(0.00, 0.00, 0.00, 1.00);
    workspotSystem = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.StopInDevice(activator, direction, orientation);
  }

  private final func GetFxInstance(id: CName) -> ref<FxInstance> {
    let fx: ref<FxInstance>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fxInstances) {
      if Equals(this.m_fxInstances[i].id, id) {
        fx = this.m_fxInstances[i].fx;
        if fx == null {
          ArrayErase(this.m_fxInstances, i);
        };
      } else {
        i += 1;
      };
    };
    return fx;
  }

  private final func RemoveFxInstance(id: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fxInstances) {
      if Equals(this.m_fxInstances[i].id, id) {
        ArrayErase(this.m_fxInstances, i);
      } else {
        i += 1;
      };
    };
  }

  private final func CreateFxInstance(owner: wref<GameObject>, id: CName, resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(owner.GetGame());
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }

  private final func StoreFxInstance(id: CName, fx: ref<FxInstance>) -> Void {
    let fxInstanceData: SVfxInstanceData;
    fxInstanceData.id = id;
    fxInstanceData.fx = fx;
    ArrayPush(this.m_fxInstances, fxInstanceData);
  }
}
