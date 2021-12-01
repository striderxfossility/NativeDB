
public static func OperatorEqual(x: redResourceReferenceScriptToken, y: ResRef) -> Bool {
  return Equals(y, x);
}

public static func OperatorEqual(x: ResRef, y: redResourceReferenceScriptToken) -> Bool {
  return Equals(x, y);
}
