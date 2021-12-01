
public static func OperatorEqual(ebool: EBOOL, rbool: Bool) -> Bool {
  if rbool && Equals(ebool, EBOOL.TRUE) || !rbool && Equals(ebool, EBOOL.FALSE) {
    return true;
  };
  return false;
}

public static func OperatorEqual(rbool: Bool, ebool: EBOOL) -> Bool {
  return ebool == rbool;
}

public static func OperatorNotEqual(rbool: Bool, ebool: EBOOL) -> Bool {
  return !(rbool == ebool);
}

public static func OperatorNotEqual(ebool: EBOOL, rbool: Bool) -> Bool {
  return !(rbool == ebool);
}

public static func OperatorLogicNot(ebool: EBOOL) -> Bool {
  if Equals(ebool, EBOOL.TRUE) {
    return false;
  };
  return true;
}
