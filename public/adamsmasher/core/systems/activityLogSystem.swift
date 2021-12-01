
public static exec func debug_AddLog(gameInstance: GameInstance) -> Void {
  GameInstance.GetActivityLogSystem(gameInstance).AddLog("Test line 1 lalala " + RandRange(0, 10));
  GameInstance.GetActivityLogSystem(gameInstance).AddLog("Test line 2 lalala " + RandRange(0, 10));
  GameInstance.GetActivityLogSystem(gameInstance).AddLogFromParts("Test1", "Test2", "Test3", "Test4", "Test5");
}
