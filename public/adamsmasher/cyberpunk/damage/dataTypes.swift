
public static func OperatorLess(f1: hitFlag, f2: hitFlag) -> Bool {
  return EnumInt(f1) < EnumInt(f2);
}

public static func OperatorOr(f1: damageSystemLogFlags, f2: damageSystemLogFlags) -> Int64 {
  let temp: Int64 = EnumInt(f1) | EnumInt(f2);
  return temp;
}

public static func OperatorOr(i: Int64, f: damageSystemLogFlags) -> Int64 {
  return i | EnumInt(f);
}

public static func OperatorOr(f: damageSystemLogFlags, i: Int64) -> Int64 {
  return EnumInt(f) | i;
}

public static func OperatorAnd(i: Int64, f: damageSystemLogFlags) -> Int64 {
  return i & EnumInt(f);
}
