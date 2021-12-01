
public abstract class MineDispenserEventsTransition extends MineDispenserTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class MineDispenserIdleDecisions extends MineDispenserTransition {

  protected final const func ToMineDispenserCycleItem(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }

  protected final const func ToMineDispenserUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"VisionPush") {
      return true;
    };
    return false;
  }
}

public class MineDispenserIdleEvents extends MineDispenserEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let unequipRequest: ref<ItemUnequipRequest>;
    this.OnEnter(stateContext, scriptInterface);
    unequipRequest = new ItemUnequipRequest();
    unequipRequest.slotId = t"AttachmentSlots.WeaponRight";
    stateContext.SetTemporaryScriptableParameter(n"itemUnequipRequest", unequipRequest, true);
  }
}

public class MineDispenserCycleItemDecisions extends MineDispenserTransition {

  protected final const func ToMineDispenserIdle(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 0.50) {
      return true;
    };
    return false;
  }
}

public class MineDispenserCycleItemEvents extends MineDispenserEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class MineDispenserPlaceDecisions extends MineDispenserTransition {

  private let m_spawnPosition: Vector4;

  private let m_spawnNormal: Vector4;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }

  private final const func CanBePlaced(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let raycastResult: TraceResult = this.FindPlaceForMine(scriptInterface);
    return TraceResult.IsValid(raycastResult);
  }

  protected final const func ToMineDispenserUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= 0.50 {
      return true;
    };
    return false;
  }

  private final const func FindPlaceForMine(const scriptInterface: ref<StateGameScriptInterface>) -> TraceResult {
    let cameraTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let playerPosition: Vector4 = Transform.GetPosition(cameraTransform);
    let playerForward: Vector4 = Transform.GetForward(cameraTransform);
    let endPosition: Vector4 = playerPosition + playerForward * 10.00;
    return scriptInterface.RayCast(playerPosition, endPosition, n"Static");
  }
}

public class MineDispenserPlaceEvents extends MineDispenserEventsTransition {

  private let m_spawnPosition: Vector4;

  private let m_spawnNormal: Vector4;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetupSpawnParams(scriptInterface);
    this.PlaceMine(scriptInterface);
  }

  private final func SetupSpawnParams(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let raycastResult: TraceResult = this.FindPlaceForMine(scriptInterface);
    this.m_spawnPosition = Cast(raycastResult.position);
    this.m_spawnNormal = Cast(raycastResult.normal);
  }

  private final func PlaceMine(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let equippedMine: EntityID = scriptInterface.GetTransactionSystem().GetItemInSlot(DefaultTransition.GetPlayerPuppet(scriptInterface), t"AttachmentSlots.WeaponLeft").GetEntityID();
    let placeEvent: ref<PlaceMineEvent> = new PlaceMineEvent();
    placeEvent.m_position = this.m_spawnPosition;
    placeEvent.m_normal = this.m_spawnNormal;
    DefaultTransition.GetPlayerPuppet(scriptInterface).QueueEventForEntityID(equippedMine, placeEvent);
  }

  private final const func FindPlaceForMine(const scriptInterface: ref<StateGameScriptInterface>) -> TraceResult {
    let cameraTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let playerPosition: Vector4 = Transform.GetPosition(cameraTransform);
    let playerForward: Vector4 = Transform.GetForward(cameraTransform);
    let endPosition: Vector4 = playerPosition + playerForward * 10.00;
    return scriptInterface.RayCast(playerPosition, endPosition, n"Static");
  }
}

public class MineDispenserUnequipEvents extends MineDispenserEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let unequipRequest: ref<ItemUnequipRequest>;
    stateContext.SetTemporaryBoolParameter(n"FinishLeftHandAction", true, true);
    unequipRequest = new ItemUnequipRequest();
    unequipRequest.slotId = t"AttachmentSlots.WeaponLeft";
    stateContext.SetTemporaryScriptableParameter(n"itemUnequipRequest", unequipRequest, true);
    stateContext.SetTemporaryBoolParameter(n"FinishLeftHandAction", true, true);
  }
}
