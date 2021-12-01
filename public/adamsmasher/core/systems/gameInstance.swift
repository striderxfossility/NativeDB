
public static func CanLog() -> Bool {
  return true;
}

public static func GetDamageSystemLogFlags() -> Int64 {
  let flags: Int64;
  if !CanLog() {
    return 0l;
  };
  flags = EnumGetMax(n"damageSystemLogFlags") * 2l - 1l;
  return flags;
}
