
public static exec func CheckFactValue(gameInstance: GameInstance, fact: String) -> Void {
  let convertedFact: CName = StringToName(fact);
  let value: Int32 = GetFact(gameInstance, convertedFact);
  Log("Fact " + fact + ": " + IntToString(value));
}

public static exec func Hotkeys(gameInstance: GameInstance) -> Void {
  DebugGiveHotkeys(gameInstance);
}

public static exec func HotkeysNOW(gameInstance: GameInstance) -> Void {
  DebugGiveHotkeys(gameInstance);
}

public static func DebugGiveHotkeys(gameInstance: GameInstance) -> Void {
  AddFact(gameInstance, n"dpad_hints_visibility_enabled");
  AddFact(gameInstance, n"unlock_phone_hud_dpad");
  AddFact(gameInstance, n"unlock_car_hud_dpad");
  AddFact(gameInstance, n"initial_gadget_picked");
}

public static exec func AddDebugFact(gameInstance: GameInstance, fact: String) -> Void {
  let convertedFact: CName = StringToName(fact);
  AddFact(gameInstance, convertedFact);
}

public static exec func SetDebugFact(gameInstance: GameInstance, fact: String, value: String) -> Void {
  let convertedFact: CName = StringToName(fact);
  SetFactValue(gameInstance, convertedFact, StringToInt(value));
}

public static func AddFact(game: GameInstance, factName: CName, opt factCount: Int32) -> Bool {
  let currentFactCount: Int32;
  if !GameInstance.IsValid(game) {
    Log("AddFact / Invalid Game Instance");
    return false;
  };
  if !IsNameValid(factName) {
    Log("fact name is not valid, fact not added");
    return false;
  };
  if factCount == 0 {
    factCount = 1;
  };
  currentFactCount = GameInstance.GetQuestsSystem(game).GetFact(factName) + factCount;
  GameInstance.GetQuestsSystem(game).SetFact(factName, currentFactCount);
  return true;
}

public static func SetFactValue(game: GameInstance, factName: CName, factCount: Int32) -> Bool {
  if !GameInstance.IsValid(game) {
    Log("SetFactValue / Invalid Game Instance");
    return false;
  };
  if !IsNameValid(factName) {
    Log(NameToString(factName) + " is not valid, fact not added");
    return false;
  };
  GameInstance.GetQuestsSystem(game).SetFact(factName, factCount);
  return true;
}

public static func GetFact(game: GameInstance, factName: CName) -> Int32 {
  if !IsNameValid(factName) {
    Log("GetFact(" + NameToString(factName) + "): fact name is not valid, cannot get fact value");
    return 0;
  };
  if !GameInstance.IsValid(game) {
    Log("GetFact(" + NameToString(factName) + "): game instance is not valid, cannot get fact value");
    return 0;
  };
  return GameInstance.GetQuestsSystem(game).GetFact(factName);
}
