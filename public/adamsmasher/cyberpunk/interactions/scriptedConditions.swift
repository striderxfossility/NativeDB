
public class GrappleInteractionCondition extends InteractionScriptedCondition {

  public final const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    return this.IsAreaBetweenPlayerAndVictim(activatorObject, hotSpotObject);
  }

  protected final const func IsAreaBetweenPlayerAndVictim(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    let maxGrabDistOverCover: Float = 1.30;
    let toHotSpot: Vector4 = hotSpotObject.GetWorldPosition() - activatorObject.GetWorldPosition();
    let distanceFromHotspot: Float = Vector4.Length2D(toHotSpot);
    let behindCoverHeightDifferenceLockout: Float = -0.50;
    if !SpatialQueriesHelper.HasSpaceInFront(activatorObject, toHotSpot, 1.30, 0.50, distanceFromHotspot, 0.40) {
      return false;
    };
    if toHotSpot.Z < behindCoverHeightDifferenceLockout && !SpatialQueriesHelper.HasSpaceInFront(activatorObject, toHotSpot, 0.60, 0.50, distanceFromHotspot, 0.70) {
      return false;
    };
    if distanceFromHotspot < maxGrabDistOverCover {
      return true;
    };
    return SpatialQueriesHelper.HasSpaceInFront(hotSpotObject, toHotSpot * -1.00, 0.60, 0.50, distanceFromHotspot - maxGrabDistOverCover, 1.10);
  }
}

public class ContainerStateInteractionCondition extends InteractionScriptedCondition {

  public final const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    let container: ref<gameLootContainerBase> = hotSpotObject as gameLootContainerBase;
    if IsDefined(container) {
      return !container.IsDisabled();
    };
    return false;
  }
}

public class DeviceDirectInteractionCondition extends InteractionScriptedCondition {

  public final const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    return (hotSpotObject as Device).IsDirectInteractionCondition();
  }
}

public class IsPlayerNotInteractingWithDevice extends InteractionScriptedCondition {

  public final const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    let player: ref<PlayerPuppet> = activatorObject as PlayerPuppet;
    let result: Bool = !player.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice);
    return result;
  }
}

public class DeviceRemoteInteractionCondition extends InteractionScriptedCondition {

  public final const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    if !this.IsScannerTarget(hotSpotObject) && !this.IsLookaAtTarget(activatorObject, hotSpotObject) {
      return false;
    };
    return this.ShouldEnableLayer(hotSpotObject);
  }

  private final const func IsScannerTarget(const hotSpotObject: wref<GameObject>) -> Bool {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(hotSpotObject.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    let entityID: EntityID = blackBoard.GetEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject);
    return hotSpotObject.GetEntityID() == entityID;
  }

  private final const func IsLookaAtTarget(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    return GameInstance.GetInteractionManager(activatorObject.GetGame()).IsInteractionLookAtTarget(activatorObject, hotSpotObject);
  }

  private final const func ShouldEnableLayer(const hotSpotObject: wref<GameObject>) -> Bool {
    if IsDefined(hotSpotObject) {
      return hotSpotObject.ShouldEnableRemoteLayer();
    };
    return false;
  }
}

public class PlayerIsSwimmingCondition extends InteractionScriptedCondition {

  public final const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>) -> Bool {
    let player: ref<PlayerPuppet> = activatorObject as PlayerPuppet;
    let result: Bool = player.GetPlayerStateMachineBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) == EnumInt(gamePSMHighLevel.Swimming);
    return result;
  }
}
