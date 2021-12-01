
public static func OperatorAdd(s: String, att: EAIAttitude) -> String {
  return s + EnumValueToString("EAIAttitude", EnumInt(att));
}

public static func OperatorAdd(att: EAIAttitude, s: String) -> String {
  return EnumValueToString("EAIAttitude", EnumInt(att)) + s;
}

public static func Max(a: EAIAttitude, b: EAIAttitude) -> EAIAttitude {
  let ai: Int32 = EnumInt(a);
  let bi: Int32 = EnumInt(b);
  return IntEnum(Max(ai, bi));
}
