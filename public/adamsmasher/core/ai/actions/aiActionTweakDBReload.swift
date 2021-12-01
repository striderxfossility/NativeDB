
public static func AIDebugTweakDBReload() -> Bool {
  return TweakDBInterface.GetBool(t"AIGeneralSettings.reloadActionDataFromTweakDB", false);
}
