
public native class AICommandNodeFunctionProvider extends IScriptable {

  private final static func Add(out functions: array<AICommandNodeFunction>, nodeType: CName, category: CName, friendlyName: String, paramsType: CName, color: Color) -> Void {
    let fn: AICommandNodeFunction;
    fn.order = Cast(ArraySize(functions));
    fn.nodeType = nodeType;
    fn.commandCategory = category;
    fn.friendlyName = friendlyName;
    fn.paramsType = paramsType;
    fn.nodeColor = color;
    ArrayPush(functions, fn);
  }

  public final static func CollectFunctions() -> array<AICommandNodeFunction> {
    let functions: array<AICommandNodeFunction>;
    let green: Color = new Color(100u, 200u, 100u, 255u);
    let red: Color = new Color(150u, 27u, 27u, 255u);
    let yellow: Color = new Color(204u, 202u, 99u, 255u);
    let gray: Color = new Color(128u, 128u, 128u, 255u);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Move On Spline", n"questMoveOnSplineParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Move To", n"questMoveToParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Rotate To", n"questRotateToParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Patrol", n"questPatrolParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Follow", n"questFollowParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Move To Cover", n"AIMoveToCoverCommandParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Stop Cover", n"AIStopCoverCommandParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Hold Position", n"AIHoldPositionCommandParams", green);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Combat Target", n"questCombatNodeParams_CombatTarget", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Combat Threat", n"AIInjectCombatThreatCommandParams", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Shoot", n"questCombatNodeParams_ShootAt", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Force Shoot", n"AIForceShootCommandParams", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Use Cover", n"questCombatNodeParams_UseCover", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Throw Grenade", n"questCombatNodeParams_ThrowGrenade", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Primary Weapon", n"questCombatNodeParams_PrimaryWeapon", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Secondary Weapon", n"questCombatNodeParams_SecondaryWeapon", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Takedown", n"AIFollowerTakedownCommandParams", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Look At Target", n"questCombatNodeParams_LookAtTarget", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Aim At Target", n"AIAimAtTargetCommandParams", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Melee Attack", n"AIMeleeAttackCommandParams", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Set Combat Preset", n"AISetCombatPresetCommandParams", red);
    AICommandNodeFunctionProvider.Add(functions, n"Combat", n"combat", "Background Combat", n"AIBackgroundCombatCommandParams", red);
    AICommandNodeFunctionProvider.Add(functions, n"Immediate", n"immediate", "Assign Role", n"AIAssignRoleCommandParams", yellow);
    AICommandNodeFunctionProvider.Add(functions, n"Immediate", n"immediate", "Clear Role", n"AIClearRoleCommandParams", yellow);
    AICommandNodeFunctionProvider.Add(functions, n"Immediate", n"immediate", "Restrict Movement", n"questCombatNodeParams_RestrictMovementToArea", yellow);
    AICommandNodeFunctionProvider.Add(functions, n"Immediate", n"immediate", "Join Target\'s Squad", n"AIJoinTargetsSquadCommandParams", yellow);
    AICommandNodeFunctionProvider.Add(functions, n"Immediate", n"immediate", "Flathead Set Solo Mode", n"AIFlatheadSetSoloModeCommandParams", yellow);
    AICommandNodeFunctionProvider.Add(functions, n"Move", n"move", "Scan Target", n"AIScanTargetCommandParams", gray);
    return functions;
  }
}
