
public static func OperatorOr(l: FTEntityRequirementsFlag, r: FTEntityRequirementsFlag) -> FTEntityRequirementsFlag {
  let output: Int64 = EnumInt(l) | EnumInt(r);
  return IntEnum(output);
}

public static func OperatorAnd(l: FTEntityRequirementsFlag, r: FTEntityRequirementsFlag) -> FTEntityRequirementsFlag {
  let output: Int64 = EnumInt(l) & EnumInt(r);
  return IntEnum(output);
}
