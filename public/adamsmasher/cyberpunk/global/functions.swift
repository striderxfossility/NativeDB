
public static func CompareF(comparator: ECompareOp, val1: Float, val2: Float) -> Bool {
  switch comparator {
    case ECompareOp.CO_Lesser:
      return val1 < val2;
    case ECompareOp.CO_LesserEq:
      return val1 <= val2;
    case ECompareOp.CO_Greater:
      return val1 > val2;
    case ECompareOp.CO_GreaterEq:
      return val1 >= val2;
    case ECompareOp.CO_Equal:
      return val1 == val2;
    case ECompareOp.CO_NotEqual:
      return val1 != val2;
    default:
      return false;
  };
}

public static func Compare(comparator: ECompareOp, val1: Int32, val2: Int32) -> Bool {
  switch comparator {
    case ECompareOp.CO_Lesser:
      return val1 < val2;
    case ECompareOp.CO_LesserEq:
      return val1 <= val2;
    case ECompareOp.CO_Greater:
      return val1 > val2;
    case ECompareOp.CO_GreaterEq:
      return val1 >= val2;
    case ECompareOp.CO_Equal:
      return val1 == val2;
    case ECompareOp.CO_NotEqual:
      return val1 != val2;
    default:
      return false;
  };
}
