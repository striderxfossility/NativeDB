
public class GetFollowTarget extends FollowVehicleTask {

  private let m_blackboard: ref<IBlackboard>;

  private let m_vehicle: wref<VehicleObject>;

  @default(GetFollowTarget, -1.f)
  private let m_lastTime: Float;

  private let m_timeout: Float;

  @default(GetFollowTarget, 0.1f)
  private let m_timeoutDuration: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let slotRequest: ref<RequestSlotEvent>;
    VehicleComponent.GetVehicle(AIBehaviorScriptBase.GetGame(context), GameInstance.GetPlayerSystem(AIBehaviorScriptBase.GetGame(context)).GetLocalPlayerMainGameObject(), this.m_vehicle);
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().AIFollowSlot);
    ScriptExecutionContext.SetArgumentVector(context, n"MovementTarget", this.m_vehicle.GetWorldPosition());
    slotRequest = new RequestSlotEvent();
    slotRequest.blackboard = this.m_blackboard;
    slotRequest.requester = ScriptExecutionContext.GetOwner(context);
    this.m_vehicle.QueueEvent(slotRequest);
    this.m_timeout = this.m_timeoutDuration;
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let actionEvent: ref<ActionEvent>;
    let changeDestinationEvent: ref<gameChangeDestination>;
    let dt: Float;
    let followPointWorldOffset: Vector4;
    let followSlot: Transform;
    let target: Vector4;
    if this.m_lastTime < 0.00 {
      this.m_lastTime = AIBehaviorScriptBase.GetAITime(context);
    };
    dt = AIBehaviorScriptBase.GetAITime(context) - this.m_lastTime;
    this.m_lastTime = AIBehaviorScriptBase.GetAITime(context);
    this.m_timeout -= dt;
    if this.m_timeout > 0.00 {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    this.m_timeout = this.m_timeoutDuration;
    followSlot = FromVariant(this.m_blackboard.GetVariant(GetAllBlackboardDefs().AIFollowSlot.slotTransform));
    if !Vector4.IsZero(Transform.GetPosition(followSlot)) {
      followPointWorldOffset = Vector4.RotByAngleXY(Transform.GetPosition(followSlot), -1.00 * Vector4.Heading(this.m_vehicle.GetWorldForward()));
      target = this.m_vehicle.GetWorldPosition() + followPointWorldOffset;
      changeDestinationEvent = new gameChangeDestination();
      changeDestinationEvent.destination = target;
      actionEvent = new ActionEvent();
      actionEvent.name = n"actionEvent";
      actionEvent.internalEvent = changeDestinationEvent;
      ScriptExecutionContext.GetOwner(context).QueueEvent(actionEvent);
      ScriptExecutionContext.SetArgumentVector(context, n"MovementTarget", target);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let slotReleaseRequest: ref<ReleaseSlotEvent> = new ReleaseSlotEvent();
    slotReleaseRequest.slotID = this.m_blackboard.GetInt(GetAllBlackboardDefs().AIFollowSlot.slotID);
    this.m_vehicle.QueueEvent(slotReleaseRequest);
  }
}

public class CheckFollowTarget extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let nodeRef: Vector4 = ScriptExecutionContext.GetArgumentVector(context, n"MovementTarget");
    if !Vector4.IsZero(nodeRef) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckTargetInVehicle extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let combatTarget: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
    if !IsDefined(combatTarget) || !VehicleComponent.IsDriver(combatTarget.GetGame(), combatTarget) {
      return Cast(false);
    };
    return Cast(true);
  }
}
