
public native class ScriptedAICommandParams extends MiscAICommandNodeParams {

  public func CreateCommand() -> ref<AICommand> {
    return null;
  }
}

public class AIAssignRoleCommandParams extends ScriptedAICommandParams {

  public inline edit let role: ref<AIRole>;

  public final func GetCommandName() -> String {
    return "Assign AI Role";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIAssignRoleCommand> = new AIAssignRoleCommand();
    command.role = this.role;
    return command;
  }
}

public class AIClearRoleCommandParams extends ScriptedAICommandParams {

  public final func GetCommandName() -> String {
    return "Clear AI Role";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIAssignRoleCommand> = new AIAssignRoleCommand();
    command.role = new AINoRole();
    return command;
  }
}

public class AISetCombatPresetCommandParams extends ScriptedAICommandParams {

  public inline edit let combatPreset: EAICombatPreset;

  public final func GetCommandName() -> String {
    return "Set Combat Preset";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AISetCombatPresetCommand> = new AISetCombatPresetCommand();
    command.combatPreset = this.combatPreset;
    return command;
  }
}

public class AIInjectCombatThreatCommandParams extends ScriptedAICommandParams {

  public inline edit let targetNodeRef: NodeRef;

  @attrib(customEditor, "scnbPerformerPuppetRefSelector")
  public inline edit let targetPuppetRef: EntityReference;

  public inline edit let dontForceHostileAttitude: Bool;

  @default(AIInjectCombatThreatCommandParams, -1.f)
  public inline edit let duration: Float;

  public inline edit let isPersistent: Bool;

  public final func GetCommandName() -> String {
    return "Set Threat";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIInjectCombatThreatCommand> = new AIInjectCombatThreatCommand();
    command.targetNodeRef = this.targetNodeRef;
    command.targetPuppetRef = this.targetPuppetRef;
    command.dontForceHostileAttitude = this.dontForceHostileAttitude;
    command.duration = this.duration;
    command.isPersistent = this.isPersistent;
    return command;
  }
}

public class AIMeleeAttackCommandParams extends ScriptedAICommandParams {

  public inline edit let targetOverrideNodeRef: NodeRef;

  @attrib(customEditor, "scnbPerformerPuppetRefSelector")
  public inline edit let targetOverridePuppetRef: EntityReference;

  @default(AIMeleeAttackCommandParams, -1.f)
  public inline edit let duration: Float;

  public final func GetCommandName() -> String {
    return "Melee Attack";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIMeleeAttackCommand> = new AIMeleeAttackCommand();
    command.targetOverrideNodeRef = this.targetOverrideNodeRef;
    command.targetOverridePuppetRef = this.targetOverridePuppetRef;
    command.duration = this.duration;
    return command;
  }
}

public class AIForceShootCommandParams extends ScriptedAICommandParams {

  public inline edit let targetOverrideNodeRef: NodeRef;

  @attrib(customEditor, "scnbPerformerPuppetRefSelector")
  public inline edit let targetOverridePuppetRef: EntityReference;

  @default(AIForceShootCommandParams, -1.f)
  public inline edit let duration: Float;

  public final func GetCommandName() -> String {
    return "Force Shoot";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIForceShootCommand> = new AIForceShootCommand();
    command.targetOverrideNodeRef = this.targetOverrideNodeRef;
    command.targetOverridePuppetRef = this.targetOverridePuppetRef;
    command.duration = this.duration;
    return command;
  }
}

public class AIAimAtTargetCommandParams extends ScriptedAICommandParams {

  public inline edit let targetOverrideNodeRef: NodeRef;

  @attrib(customEditor, "scnbPerformerPuppetRefSelector")
  public inline edit let targetOverridePuppetRef: EntityReference;

  @default(AIAimAtTargetCommandParams, -1.f)
  public inline edit let duration: Float;

  public final func GetCommandName() -> String {
    return "Aim at Target";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIAimAtTargetCommand> = new AIAimAtTargetCommand();
    command.targetOverrideNodeRef = this.targetOverrideNodeRef;
    command.targetOverridePuppetRef = this.targetOverridePuppetRef;
    command.duration = this.duration;
    return command;
  }
}

public class AIHoldPositionCommandParams extends ScriptedAICommandParams {

  @default(AIHoldPositionCommandParams, -1.f)
  public inline edit let duration: Float;

  public final func GetCommandName() -> String {
    return "Hold Position";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIHoldPositionCommand> = new AIHoldPositionCommand();
    command.duration = this.duration;
    return command;
  }
}

public class AIMoveToCoverCommandParams extends ScriptedAICommandParams {

  public inline edit let coverNodeRef: NodeRef;

  public inline edit let alwaysUseStealth: Bool;

  public inline edit let specialAction: ECoverSpecialAction;

  public final func GetCommandName() -> String {
    return "Move To Cover";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIMoveToCoverCommand> = new AIMoveToCoverCommand();
    command.coverNodeRef = this.coverNodeRef;
    command.alwaysUseStealth = this.alwaysUseStealth;
    command.specialAction = this.specialAction;
    return command;
  }
}

public class AIStopCoverCommandParams extends ScriptedAICommandParams {

  public final func GetCommandName() -> String {
    return "Stop Cover";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIStopCoverCommand> = new AIStopCoverCommand();
    return command;
  }
}

public class AIJoinTargetsSquadCommandParams extends ScriptedAICommandParams {

  public inline edit let targetPuppetRef: EntityReference;

  public final func GetCommandName() -> String {
    return "Join Target\'s Squad";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIJoinTargetsSquad> = new AIJoinTargetsSquad();
    command.targetPuppetRef = this.targetPuppetRef;
    return command;
  }
}

public class AIFollowerCommand extends AICommand {

  @default(AIFollowerCombatCommand, true)
  public let combatCommand: Bool;

  public final func IsCombatCommand() -> Bool {
    return this.combatCommand;
  }
}

public class AIFollowerTakedownCommandParams extends ScriptedAICommandParams {

  @attrib(customEditor, "scnbPerformerPuppetRefSelector")
  public inline edit let targetRef: EntityReference;

  public inline edit let approachBeforeTakedown: Bool;

  public inline edit let doNotTeleportIfTargetIsVisible: Bool;

  public final func GetCommandName() -> String {
    return "Takedown";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIFollowerTakedownCommand> = new AIFollowerTakedownCommand();
    command.targetRef = this.targetRef;
    command.approachBeforeTakedown = this.approachBeforeTakedown;
    command.doNotTeleportIfTargetIsVisible = this.doNotTeleportIfTargetIsVisible;
    return command;
  }
}

public class AIFlatheadSetSoloModeCommandParams extends ScriptedAICommandParams {

  public inline edit let soloMode: Bool;

  public final func GetCommandName() -> String {
    return "Flathead Set Solo Mode";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIFlatheadSetSoloModeCommand> = new AIFlatheadSetSoloModeCommand();
    command.soloModeState = this.soloMode;
    return command;
  }
}

public class AIScanTargetCommandParams extends ScriptedAICommandParams {

  public inline edit let targetPuppetRef: EntityReference;

  public final func GetCommandName() -> String {
    return "Scan Target";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIScanTargetCommand> = new AIScanTargetCommand();
    command.targetPuppetRef = this.targetPuppetRef;
    return command;
  }
}
