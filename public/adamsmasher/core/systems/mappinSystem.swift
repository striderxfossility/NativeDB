
public static exec func testLocationUpdate(gameInstance: GameInstance, value: String) -> Void {
  GameInstance.GetMappinSystem(gameInstance).UpdateCurrentLocationName(value, true);
}
