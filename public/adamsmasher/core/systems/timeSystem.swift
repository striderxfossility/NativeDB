
public static exec func Slowmo(gameInstance: GameInstance) -> Void {
  GameInstance.GetTimeSystem(gameInstance).SetTimeDilation(n"consoleCommand", 0.10);
}

public static exec func Noslowmo(gameInstance: GameInstance) -> Void {
  GameInstance.GetTimeSystem(gameInstance).UnsetTimeDilation(n"consoleCommand");
}

public static exec func SetTimeDilation(gameInstance: GameInstance, amount: String) -> Void {
  let famount: Float = StringToFloat(amount);
  if famount > 0.00 {
    GameInstance.GetTimeSystem(gameInstance).SetTimeDilation(n"consoleCommand", famount);
  } else {
    GameInstance.GetTimeSystem(gameInstance).UnsetTimeDilation(n"consoleCommand");
  };
}
