
public class NPCLocomotionTypePrereqState extends PrereqState {

  public let m_owner: wref<GameObject>;

  public let m_listenerInt: ref<CallbackHandle>;

  protected cb func OnLocomotionTypeChanged(value: Int32) -> Bool {
    let prereq: ref<NPCLocomotionTypePrereq> = this.GetPrereq() as NPCLocomotionTypePrereq;
    let checkPassed: Bool = prereq.Evaluate(this.m_owner, value);
    this.OnChanged(checkPassed);
  }
}

public class NPCLocomotionTypePrereq extends IScriptablePrereq {

  public let m_locomotionMode: array<gamedataLocomotionMode>;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".locomotionType", "");
    ArrayPush(this.m_locomotionMode, IntEnum(Cast(EnumValueFromString("gamedataLocomotionMode", str))));
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard>;
    let castedState: ref<NPCLocomotionTypePrereqState>;
    let owner: wref<ScriptedPuppet> = context as ScriptedPuppet;
    if IsDefined(owner) {
      bb = owner.GetPuppetStateBlackboard();
    };
    castedState = state as NPCLocomotionTypePrereqState;
    castedState.m_owner = owner;
    castedState.m_listenerInt = bb.RegisterListenerInt(GetAllBlackboardDefs().PuppetState.LocomotionMode, castedState, n"OnLocomotionTypeChanged");
    return false;
  }

  public final const func Evaluate(owner: ref<GameObject>, value: Int32) -> Bool {
    if ArrayContains(this.m_locomotionMode, IntEnum(value)) {
      return this.m_invert ? false : true;
    };
    return this.m_invert ? true : false;
  }
}
