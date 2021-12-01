
public class MountCommandHandlerTask extends AIbehaviortaskScript {

  public inline edit let m_command: ref<AIArgumentMapping>;

  public inline edit let m_mountEventData: ref<AIArgumentMapping>;

  public edit let m_callbackName: CName;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let command: ref<AIBaseMountCommand> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_command) as AIBaseMountCommand;
    ScriptExecutionContext.SetMappingValue(context, this.m_mountEventData, ToVariant(command.mountData));
    ScriptExecutionContext.InvokeBehaviorCallback(context, this.m_callbackName);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class MountRequestCondition extends AIbehaviorconditionScript {

  @default(MountRequestCondition, true)
  public inline edit let m_testMountRequest: Bool;

  @default(MountRequestCondition, false)
  public inline edit let m_testUnmountRequest: Bool;

  @default(MountRequestCondition, true)
  public inline edit let m_acceptInstant: Bool;

  @default(MountRequestCondition, true)
  public inline edit let m_acceptNotInstant: Bool;

  protected final func TestRequest(context: script_ref<ScriptExecutionContext>, argumentName: CName) -> AIbehaviorConditionOutcomes {
    let hls: gamedataNPCHighLevelState;
    let request: ref<MountEventData> = ScriptExecutionContext.GetArgumentScriptable(Deref(context), argumentName) as MountEventData;
    if !IsDefined(request) {
      return AIbehaviorConditionOutcomes.False;
    };
    if request.isInstant {
      return Cast(this.m_acceptInstant);
    };
    if !request.ignoreHLS {
      hls = (ScriptExecutionContext.GetOwner(Deref(context)) as ScriptedPuppet).GetHighLevelStateFromBlackboard();
      if Equals(hls, gamedataNPCHighLevelState.Alerted) || Equals(hls, gamedataNPCHighLevelState.Combat) {
        return Cast(false);
      };
    };
    return Cast(this.m_acceptNotInstant);
  }

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let outcome: AIbehaviorConditionOutcomes;
    if this.m_testMountRequest {
      outcome = this.TestRequest(context, n"MountRequest");
      if NotEquals(outcome, AIbehaviorConditionOutcomes.False) {
        return outcome;
      };
    };
    if this.m_testUnmountRequest {
      return this.TestRequest(context, n"UnmountRequest");
    };
    return AIbehaviorConditionOutcomes.Failure;
  }
}

public class MountRequestPassiveCondition extends AIbehaviorexpressionScript {

  @default(MountRequestPassiveCondition, false)
  private edit let m_unmountRequest: Bool;

  @default(MountRequestPassiveCondition, true)
  private edit let m_acceptInstant: Bool;

  @default(MountRequestPassiveCondition, true)
  private edit let m_acceptNotInstant: Bool;

  @default(MountRequestPassiveCondition, false)
  private edit let m_acceptForcedTransition: Bool;

  @default(MountRequestPassiveCondition, false)
  private edit let m_succeedOnMissingMountedEntity: Bool;

  private let m_callbackId: Uint32;

  private let m_highLevelStateCallbackId: Uint32;

  private final func GetCallbackName() -> CName {
    return this.m_unmountRequest ? n"OnUnmountRequest" : n"OnMountRequest";
  }

  private final func GetRequestArgumentName() -> CName {
    return this.m_unmountRequest ? n"UnmountRequest" : n"MountRequest";
  }

  public final func Activate(ctx: ScriptExecutionContext) -> Void {
    this.m_callbackId = ScriptExecutionContext.AddBehaviorCallback(ctx, this.GetCallbackName(), this);
    if this.m_acceptNotInstant {
      this.m_highLevelStateCallbackId = ScriptExecutionContext.AddBehaviorCallback(ctx, n"OnHighLevelChanged", this);
    };
  }

  public final func Deactivate(ctx: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(ctx, this.m_callbackId);
    if this.m_acceptNotInstant {
      ScriptExecutionContext.RemoveBehaviorCallback(ctx, this.m_highLevelStateCallbackId);
    };
  }

  public final func CalculateValue(ctx: ScriptExecutionContext) -> Variant {
    let hls: gamedataNPCHighLevelState;
    let mountInfo: MountingInfo;
    let ss: gamedataNPCStanceState;
    let vehicle: wref<VehicleObject>;
    let request: ref<MountEventData> = ScriptExecutionContext.GetArgumentScriptable(ctx, this.GetRequestArgumentName()) as MountEventData;
    if !IsDefined(request) {
      return ToVariant(false);
    };
    if !this.m_unmountRequest {
      if !request.isInstant && !request.ignoreHLS {
        hls = (ScriptExecutionContext.GetOwner(ctx) as ScriptedPuppet).GetHighLevelStateFromBlackboard();
        if Equals(hls, gamedataNPCHighLevelState.Alerted) || Equals(hls, gamedataNPCHighLevelState.Combat) {
          return ToVariant(false);
        };
      };
      ss = (ScriptExecutionContext.GetOwner(ctx) as ScriptedPuppet).GetStanceStateFromBlackboard();
      if Equals(ss, gamedataNPCStanceState.Vehicle) || Equals(ss, gamedataNPCStanceState.VehicleWindow) {
        mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(ctx).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(ctx));
        if mountInfo.parentId == request.mountParentEntityId && Equals(mountInfo.slotId.id, request.slotName) {
          return ToVariant(false);
        };
      };
    } else {
      if !request.isInstant && !request.ignoreHLS {
        hls = (ScriptExecutionContext.GetOwner(ctx) as ScriptedPuppet).GetHighLevelStateFromBlackboard();
        if Equals(hls, gamedataNPCHighLevelState.Alerted) && AIBehaviorScriptBase.GetPuppet(ctx).IsAggressive() && !ScriptedPuppet.IsPlayerCompanion(AIBehaviorScriptBase.GetPuppet(ctx)) {
          return ToVariant(false);
        };
      };
    };
    if request.isInstant && this.m_acceptInstant {
      return ToVariant(true);
    };
    if !request.isInstant && this.m_acceptNotInstant {
      return ToVariant(true);
    };
    if request.IsTransitionForced() && this.m_acceptForcedTransition {
      return ToVariant(true);
    };
    if this.m_succeedOnMissingMountedEntity && EntityID.IsDefined(request.mountParentEntityId) {
      if !VehicleComponent.GetVehicleFromID(ScriptExecutionContext.GetOwner(ctx).GetGame(), request.mountParentEntityId, vehicle) {
        return ToVariant(true);
      };
    };
    return ToVariant(false);
  }
}
