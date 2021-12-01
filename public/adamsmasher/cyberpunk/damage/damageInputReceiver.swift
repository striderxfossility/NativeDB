
public class DEBUG_DamageInputReceiver extends IScriptable {

  public let m_player: wref<PlayerPuppet>;

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if !GameInstance.GetRuntimeInfo(GetGameInstance()).IsClient() {
      if Equals(ListenerAction.GetName(action), n"Debug_KillAll") {
        if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED) {
          KillAll_NonExec(GetGameInstance(), this.m_player);
        };
      } else {
        if Equals(ListenerAction.GetName(action), n"Debug_Kill") {
          if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED) {
            Kill_NonExec(GetGameInstance(), this.m_player);
          };
        };
      };
    };
  }
}
