
public static func OperatorAdd(s: String, mode: gamecheatsystemFlag) -> String {
  return s + EnumValueToString("gamecheatsystemFlag", EnumInt(mode));
}

public static func OperatorAdd(mode: gamecheatsystemFlag, s: String) -> String {
  return EnumValueToString("gamecheatsystemFlag", EnumInt(mode)) + s;
}

public static exec func IncreaseGlobalTimeDilation(gi: GameInstance) -> Void {
  let cheatSystem: ref<DebugCheatsSystem> = GameInstance.GetDebugCheatsSystem(gi);
  cheatSystem.IncreaseGlobalTimeDilation();
}

public static exec func DecreaseGlobalTimeDilation(gi: GameInstance) -> Void {
  let cheatSystem: ref<DebugCheatsSystem> = GameInstance.GetDebugCheatsSystem(gi);
  cheatSystem.DecreaseGlobalTimeDilation();
}

public static exec func IncreasePlayerTimeDilation(gi: GameInstance) -> Void {
  let cheatSystem: ref<DebugCheatsSystem> = GameInstance.GetDebugCheatsSystem(gi);
  cheatSystem.IncreasePlayerTimeDilation();
}

public static exec func DecreasePlayerTimeDilation(gi: GameInstance) -> Void {
  let cheatSystem: ref<DebugCheatsSystem> = GameInstance.GetDebugCheatsSystem(gi);
  cheatSystem.DecreasePlayerTimeDilation();
}
