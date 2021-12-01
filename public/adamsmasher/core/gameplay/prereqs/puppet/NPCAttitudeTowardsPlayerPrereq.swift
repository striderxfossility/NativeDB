
public class NPCAttitudeTowardsPlayerPrereqState extends PrereqState {

  public let attitudeListener: ref<gameScriptedPrereqAttitudeListenerWrapper>;

  protected final func OnAttitudeStateChanged() -> Void {
    let prereq: ref<NPCAttitudeTowardsPlayerPrereq> = this.GetPrereq() as NPCAttitudeTowardsPlayerPrereq;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class NPCAttitudeTowardsPlayerPrereq extends IScriptablePrereq {

  public let m_attitude: EAIAttitude;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".attitude", "");
    this.m_attitude = IntEnum(Cast(EnumValueFromString("EAIAttitude", str)));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let npc: ref<NPCPuppet> = context as NPCPuppet;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let attitude: EAIAttitude = GameObject.GetAttitudeTowards(npc, player);
    if Equals(attitude, this.m_attitude) {
      return true;
    };
    return false;
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.OnChanged(this.IsFulfilled(game, context));
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let puppet: ref<NPCPuppet> = context as NPCPuppet;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let castedState: ref<NPCAttitudeTowardsPlayerPrereqState> = state as NPCAttitudeTowardsPlayerPrereqState;
    if IsDefined(puppet) && IsDefined(player) {
      castedState.attitudeListener = gameScriptedPrereqAttitudeListenerWrapper.CreateListener(game, puppet.GetAttitudeAgent(), player.GetAttitudeAgent(), castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<NPCAttitudeTowardsPlayerPrereqState> = state as NPCAttitudeTowardsPlayerPrereqState;
    castedState.attitudeListener = null;
  }
}
