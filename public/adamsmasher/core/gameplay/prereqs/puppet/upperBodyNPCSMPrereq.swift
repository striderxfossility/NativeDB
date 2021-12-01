
public class UpperBodyNPCStatePrereq extends NPCStatePrereq {

  public let m_valueToListen: gamedataNPCUpperBodyState;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = (context as ScriptedPuppet).GetPuppetStateBlackboard();
    let castedState: ref<UpperBodyNPCStatePrereqState> = state as UpperBodyNPCStatePrereqState;
    castedState.m_owner = context as GameObject;
    castedState.m_prevValue = bb.GetInt(GetAllBlackboardDefs().PuppetState.UpperBody);
    castedState.m_listenerInt = bb.RegisterListenerInt(GetAllBlackboardDefs().PuppetState.UpperBody, castedState, n"OnStateUpdate");
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<UpperBodyNPCStatePrereqState> = state as UpperBodyNPCStatePrereqState;
    (context as ScriptedPuppet).GetPuppetStateBlackboard().UnregisterListenerInt(GetAllBlackboardDefs().PuppetState.UpperBody, castedState.m_listenerInt);
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.Initialize(recordID);
    this.m_valueToListen = IntEnum(Cast(EnumValueFromString("gamedataNPCUpperBodyState", this.GetStateName(recordID))));
  }

  protected const func GetStateToCheck() -> Int32 {
    return EnumInt(this.m_valueToListen);
  }
}
