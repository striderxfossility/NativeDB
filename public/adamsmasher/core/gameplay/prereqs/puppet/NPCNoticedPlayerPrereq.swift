
public class EntityNoticedPlayerPrereqState extends PrereqState {

  public let m_owner: wref<GameObject>;

  public let m_listenerInt: ref<CallbackHandle>;

  protected cb func OnStateUpdate(value: Uint32) -> Bool {
    let prereq: ref<EntityNoticedPlayerPrereq> = this.GetPrereq() as EntityNoticedPlayerPrereq;
    let checkPassed: Bool = prereq.Evaluate(this.m_owner, value);
    this.OnChanged(checkPassed);
  }
}

public class EntityNoticedPlayerPrereq extends IScriptablePrereq {

  private let m_isPlayerNoticed: Bool;

  @default(EntityNoticedPlayerPrereq, 1)
  private let m_valueToListen: Uint32;

  public final const func Evaluate(owner: ref<GameObject>, value: Uint32) -> Bool {
    if this.m_isPlayerNoticed {
      if value >= this.m_valueToListen {
        return true;
      };
    } else {
      if value != this.m_valueToListen {
        return true;
      };
    };
    return false;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_isPlayerNoticed = TweakDBInterface.GetBool(recordID + t".isPlayerNoticed", false);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard>;
    let castedState: ref<EntityNoticedPlayerPrereqState> = state as EntityNoticedPlayerPrereqState;
    castedState.m_owner = context as GameObject;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      bb = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
      castedState.m_listenerInt = bb.RegisterListenerUint(GetAllBlackboardDefs().PlayerPerkData.EntityNoticedPlayer, castedState, n"OnStateUpdate");
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<EntityNoticedPlayerPrereqState>;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      bb = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
      castedState = state as EntityNoticedPlayerPrereqState;
      bb.UnregisterListenerUint(GetAllBlackboardDefs().PlayerPerkData.EntityNoticedPlayer, castedState.m_listenerInt);
    };
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<EntityNoticedPlayerPrereqState>;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      castedState = state as EntityNoticedPlayerPrereqState;
      castedState.OnChanged(this.IsFulfilled(player.GetGame(), context));
    };
  }

  protected const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
    let checkPassed: Bool = this.Evaluate(player, bb.GetUint(GetAllBlackboardDefs().PlayerPerkData.EntityNoticedPlayer));
    return checkPassed;
  }
}
