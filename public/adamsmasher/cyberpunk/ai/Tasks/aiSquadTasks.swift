
public class CallOffReactionAction extends SquadTask {

  public edit let m_squadActionName: EAISquadAction;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let callOffEvent: ref<AIEvent>;
    let i: Int32;
    let member: ref<ScriptedPuppet>;
    let members: array<wref<Entity>>;
    let smi: ref<SquadScriptInterface>;
    let stimTarget: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    if !IsDefined(stimTarget) || !AISquadHelper.GetSquadMemberInterface(AIBehaviorScriptBase.GetPuppet(context), smi) {
      return;
    };
    members = smi.ListMembersWeak();
    i = 0;
    while i < ArraySize(members) {
      member = members[i] as ScriptedPuppet;
      if member == AIBehaviorScriptBase.GetPuppet(context) {
      } else {
        if NotEquals(member.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Alerted) {
        } else {
          if !ScriptedPuppet.IsActive(member) {
          } else {
            if member.GetStimReactionComponent().GetActiveReactionData().stimTarget == stimTarget && smi.HasOrderBySquadAction(EnumValueToName(n"EAISquadAction", Cast(EnumInt(this.m_squadActionName))), members[i]) {
              callOffEvent = new AIEvent();
              callOffEvent.name = n"ExitReaction";
              member.QueueEvent(callOffEvent);
            };
          };
        };
      };
      i += 1;
    };
  }
}

public class SquadAlertedSync extends SquadTask {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let count: Int32;
    let i: Int32;
    let members: array<ref<Entity>>;
    let psi: ref<PuppetSquadInterface>;
    AISquadHelper.GetSquadBaseInterface(ScriptExecutionContext.GetOwner(context), psi);
    members = psi.ListMembers();
    ArrayRemove(members, ScriptExecutionContext.GetOwner(context));
    count = ArraySize(members);
    i = 0;
    while i < count {
      if Equals((members[i] as ScriptedPuppet).GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Relaxed) {
        NPCPuppet.ChangeHighLevelState(members[i] as GameObject, gamedataNPCHighLevelState.Alerted);
      };
      i += 1;
    };
  }
}
