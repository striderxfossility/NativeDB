
public class PatrolControllerTask extends AIbehaviortaskScript {

  protected final func GetBlackboardDef() -> ref<AIPatrolDef> {
    return GetAllBlackboardDefs().AIPatrol;
  }

  protected final func GetBlackboard(context: ScriptExecutionContext) -> ref<IBlackboard> {
    return AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIPatrolBlackboard();
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let pathOverride: ref<AIPatrolPathParameters>;
    let selectedPath: ref<AIPatrolPathParameters>;
    let bbDef: ref<AIPatrolDef> = this.GetBlackboardDef();
    let bb: ref<IBlackboard> = this.GetBlackboard(context);
    let pathVariant: Variant = bb.GetVariant(bbDef.selectedPath);
    let pathOverrideVariant: Variant = bb.GetVariant(bbDef.patrolPathOverride);
    if VariantIsValid(pathVariant) {
      selectedPath = FromVariant(pathVariant);
    };
    if VariantIsValid(pathOverrideVariant) {
      pathOverride = FromVariant(pathOverrideVariant);
    };
    if IsDefined(pathOverride) && selectedPath != pathOverride {
      selectedPath = pathOverride;
      bb.SetVariant(bbDef.selectedPath, ToVariant(selectedPath));
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class PatrolCommandHandler extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let bb: ref<IBlackboard>;
    let bbDef: ref<AIPatrolDef>;
    let pathParams: ref<AIPatrolPathParameters>;
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AIPatrolCommand>;
    if !IsDefined(this.m_inCommand) {
      LogAIError("Patrol command argument mapping is null.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AIPatrolCommand;
    if !IsDefined(typedCommand) {
      LogAIError("\'inCommand\' doesn\'t have type \'AIPatrolCommand\'.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(typedCommand.pathParams) {
      LogAIError("Patrol command has null \'pathParams\'.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    pathParams = typedCommand.pathParams;
    if !ScriptExecutionContext.GetArgumentBool(context, n"PatrolInitialized") && Equals(AIBehaviorScriptBase.GetPuppet(context).GetNPCType(), gamedataNPCType.Drone) {
      DroneComponent.SetLocomotionWrappers(AIBehaviorScriptBase.GetPuppet(context), EnumValueToName(n"moveMovementType", EnumInt(pathParams.movementType)));
      pathParams.movementType = moveMovementType.Walk;
    };
    bbDef = GetAllBlackboardDefs().AIPatrol;
    bb = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIPatrolBlackboard();
    bb.SetVariant(bbDef.patrolPathOverride, ToVariant(pathParams));
    bb.SetBool(bbDef.patrolWithWeapon, pathParams.patrolWithWeapon);
    bb.SetVariant(bbDef.patrolAction, ToVariant(pathParams.patrolAction));
    bb.SetBool(bbDef.sprint, Equals(pathParams.movementType, moveMovementType.Sprint));
    ScriptExecutionContext.SetArgumentBool(context, n"PatrolInitialized", true);
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class PatrolRoleHandler extends AIbehaviortaskScript {

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let bb: ref<IBlackboard>;
    let bbDef: ref<AIPatrolDef>;
    let pathParams: ref<AIPatrolPathParameters>;
    let patrolRole: ref<AIPatrolRole>;
    let aiComponent: ref<AIHumanComponent> = AIBehaviorScriptBase.GetAIComponent(context);
    if !IsDefined(aiComponent) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    patrolRole = aiComponent.GetCurrentRole() as AIPatrolRole;
    if !IsDefined(patrolRole) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(patrolRole.GetPathParams()) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    pathParams = patrolRole.GetPathParams();
    if !ScriptExecutionContext.GetArgumentBool(context, n"PatrolInitialized") && Equals(AIBehaviorScriptBase.GetPuppet(context).GetNPCType(), gamedataNPCType.Drone) {
      DroneComponent.SetLocomotionWrappers(AIBehaviorScriptBase.GetPuppet(context), EnumValueToName(n"moveMovementType", EnumInt(pathParams.movementType)));
      pathParams.movementType = moveMovementType.Walk;
    };
    bbDef = GetAllBlackboardDefs().AIPatrol;
    bb = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIPatrolBlackboard();
    bb.SetVariant(bbDef.patrolPathOverride, ToVariant(pathParams));
    bb.SetBool(bbDef.patrolWithWeapon, pathParams.patrolWithWeapon);
    bb.SetVariant(bbDef.patrolAction, ToVariant(pathParams.patrolAction));
    bb.SetBool(bbDef.sprint, Equals(pathParams.movementType, moveMovementType.Sprint));
    ScriptExecutionContext.SetArgumentBool(context, n"PatrolInitialized", true);
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class PatrolAlertedControllerTask extends AIbehaviortaskScript {

  protected final func GetBlackboardDef() -> ref<AIAlertedPatrolDef> {
    return GetAllBlackboardDefs().AIAlertedPatrol;
  }

  protected final func GetBlackboard(context: ScriptExecutionContext) -> ref<IBlackboard> {
    return AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIAlertedPatrolBlackboard();
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let pathOverride: ref<AIPatrolPathParameters>;
    let selectedPath: ref<AIPatrolPathParameters>;
    let bbDef: ref<AIAlertedPatrolDef> = this.GetBlackboardDef();
    let bb: ref<IBlackboard> = this.GetBlackboard(context);
    let tmpVariant: Variant = bb.GetVariant(bbDef.selectedPath);
    if VariantIsValid(tmpVariant) {
      selectedPath = FromVariant(tmpVariant);
    };
    tmpVariant = bb.GetVariant(bbDef.patrolPathOverride);
    if VariantIsValid(tmpVariant) {
      pathOverride = FromVariant(tmpVariant);
    };
    if IsDefined(pathOverride) && selectedPath != pathOverride {
      selectedPath = pathOverride;
      bb.SetVariant(bbDef.selectedPath, ToVariant(selectedPath));
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class PatrolAlertedCommandHandler extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let bb: ref<IBlackboard>;
    let bbDef: ref<AIAlertedPatrolDef>;
    let pathParams: ref<AIPatrolPathParameters>;
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AIPatrolCommand>;
    if !IsDefined(this.m_inCommand) {
      LogAIError("Patrol command argument mapping is null.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AIPatrolCommand;
    if !IsDefined(typedCommand) {
      LogAIError("\'inCommand\' doesn\'t have type \'AIPatrolCommand\'.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(typedCommand.alertedPathParams) {
      LogAIError("Patrol command has null \'pathParams\'.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetArgumentFloat(context, n"InfluenceRadius", typedCommand.alertedRadius);
    pathParams = typedCommand.alertedPathParams;
    if !ScriptExecutionContext.GetArgumentBool(context, n"PatrolInitialized") && Equals(AIBehaviorScriptBase.GetPuppet(context).GetNPCType(), gamedataNPCType.Drone) {
      DroneComponent.SetLocomotionWrappers(AIBehaviorScriptBase.GetPuppet(context), EnumValueToName(n"moveMovementType", EnumInt(pathParams.movementType)));
      pathParams.movementType = moveMovementType.Walk;
    };
    bbDef = GetAllBlackboardDefs().AIAlertedPatrol;
    bb = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIAlertedPatrolBlackboard();
    bb.SetVariant(bbDef.patrolPathOverride, ToVariant(pathParams));
    bb.SetVariant(bbDef.patrolAction, ToVariant(pathParams.patrolAction));
    bb.SetBool(bbDef.sprint, Equals(pathParams.movementType, moveMovementType.Sprint));
    ScriptExecutionContext.SetArgumentBool(context, n"PatrolInitialized", true);
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AlertedRoleHandler extends AIbehaviortaskScript {

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let bb: ref<IBlackboard>;
    let bbDef: ref<AIAlertedPatrolDef>;
    let pathParams: ref<AIPatrolPathParameters>;
    let patrolRole: ref<AIPatrolRole>;
    let aiComponent: ref<AIHumanComponent> = AIBehaviorScriptBase.GetAIComponent(context);
    if !IsDefined(aiComponent) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    patrolRole = aiComponent.GetCurrentRole() as AIPatrolRole;
    if !IsDefined(patrolRole) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetArgumentScriptable(context, n"AlertedSpots", patrolRole.GetAlertedSpots());
    if !IsDefined(patrolRole.GetAlertedPathParams()) && !IsDefined(patrolRole.GetPathParams()) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetArgumentFloat(context, n"InfluenceRadius", patrolRole.GetAlertedRadius());
    pathParams = patrolRole.GetAlertedPathParams();
    if !IsDefined(pathParams) {
      ScriptExecutionContext.SetArgumentBool(context, n"IgnoreWorkspots", true);
      pathParams = patrolRole.GetPathParams();
      if !(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).IsBoss() {
        pathParams.isInfinite = false;
        pathParams.numberOfLoops = 2u;
      };
    };
    if !ScriptExecutionContext.GetArgumentBool(context, n"PatrolInitialized") && Equals(AIBehaviorScriptBase.GetPuppet(context).GetNPCType(), gamedataNPCType.Drone) {
      DroneComponent.SetLocomotionWrappers(AIBehaviorScriptBase.GetPuppet(context), EnumValueToName(n"moveMovementType", EnumInt(pathParams.movementType)));
      pathParams.movementType = moveMovementType.Walk;
    };
    pathParams.enterClosest = true;
    bbDef = GetAllBlackboardDefs().AIAlertedPatrol;
    bb = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIAlertedPatrolBlackboard();
    if !IsDefined(bb) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    bb.SetVariant(bbDef.patrolPathOverride, ToVariant(pathParams));
    bb.SetBool(bbDef.forceAlerted, patrolRole.IsForceAlerted());
    if IsDefined(pathParams) {
      bb.SetVariant(bbDef.patrolAction, ToVariant(pathParams.patrolAction));
      bb.SetBool(bbDef.sprint, Equals(pathParams.movementType, moveMovementType.Sprint));
    };
    ScriptExecutionContext.SetArgumentBool(context, n"PatrolInitialized", true);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class CheckCurrentWorkspotTag extends AIbehaviorconditionScript {

  public inline edit let m_tag: ref<AIArgumentMapping>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast((ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).HasWorkspotTag(FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_tag))));
  }
}

public class GetCurrentPatrolSpotActionPath extends AIbehaviortaskScript {

  public inline edit let m_outPathArgument: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let currentPatrolActionPath: CName;
    let currentWorkspotTags: array<CName> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetCurrentWorkspotTags();
    if ArraySize(currentWorkspotTags) < 2 {
      return;
    };
    currentPatrolActionPath = currentWorkspotTags[1];
    ScriptExecutionContext.SetMappingValue(context, this.m_outPathArgument, ToVariant(currentPatrolActionPath));
  }
}

public class HasPatrolAction extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let patrolAction: TweakDBID = FromVariant(AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIPatrolBlackboard().GetVariant(GetAllBlackboardDefs().AIPatrol.patrolAction));
    if TDBID.IsValid(patrolAction) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class SendPatrolEndSignal extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    ScriptedPuppet.SendActionSignal(puppet, n"PatrolEnded", 0.10);
  }
}
