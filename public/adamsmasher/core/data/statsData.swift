
public static func OperatorAdd(s: String, stat: gamedataStatType) -> String {
  return s + EnumValueToString("gamedataStatType", EnumInt(stat));
}

public static func OperatorAdd(stat: gamedataStatType, s: String) -> String {
  return EnumValueToString("gamedataStatType", EnumInt(stat)) + s;
}

public static func OperatorAdd(s: String, mode: gameGodModeType) -> String {
  return s + EnumValueToString("gameGodModeType", EnumInt(mode));
}

public static func OperatorAdd(mode: gameGodModeType, s: String) -> String {
  return EnumValueToString("gameGodModeType", EnumInt(mode)) + s;
}
