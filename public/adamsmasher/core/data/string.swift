
public static func NoTrailZeros(f: Float) -> String {
  let tmp: String = FloatToString(f);
  if StrFindFirst(tmp, ",") >= 0 || StrFindFirst(tmp, ".") >= 0 {
    while StrEndsWith(tmp, "0") {
      tmp = StrLeft(tmp, StrLen(tmp) - 1);
    };
  };
  if StrEndsWith(tmp, ",") || StrEndsWith(tmp, ".") {
    tmp = StrLeft(tmp, StrLen(tmp) - 1);
  };
  return tmp;
}

public static func NoTrailZerosStr(str: String) -> String {
  if StrFindFirst(str, ",") >= 0 || StrFindFirst(str, ".") >= 0 {
    while StrEndsWith(str, "0") {
      str = StrLeft(str, StrLen(str) - 1);
    };
  };
  if StrEndsWith(str, ",") || StrEndsWith(str, ".") {
    str = StrLeft(str, StrLen(str) - 1);
  };
  return str;
}

public static func StrUpperFirst(const str: script_ref<String>, opt lenght: Int32) -> String {
  let left: String;
  let right: String;
  if lenght <= 1 {
    lenght = 1;
  };
  left = StrLeft(str, lenght);
  right = StrAfterFirst(str, left);
  left = StrUpper(left);
  return left + right;
}

public static func BoolToString(value: Bool) -> String {
  let tmp: String;
  if value {
    tmp = "TRUE";
  } else {
    tmp = "FALSE";
  };
  return tmp;
}

public static func StringToBool(const s: script_ref<String>) -> Bool {
  return Equals(StrLower(s), "true");
}

public static func SpaceFill(str: String, length: Int32, opt mode: ESpaceFillMode, opt fillChar: String) -> String {
  let addLeft: Int32;
  let addRight: Int32;
  let i: Int32;
  let strLen: Int32;
  let fillLen: Int32 = StrLen(fillChar);
  if fillLen == 0 {
    fillChar = " ";
  } else {
    if fillLen > 1 {
      fillChar = StrChar(0);
    };
  };
  strLen = StrLen(str);
  if strLen >= length {
    return str;
  };
  if Equals(mode, ESpaceFillMode.JustifyLeft) {
    addLeft = 0;
    addRight = length - strLen;
  } else {
    if Equals(mode, ESpaceFillMode.JustifyRight) {
      addLeft = length - strLen;
      addRight = 0;
    } else {
      if Equals(mode, ESpaceFillMode.JustifyCenter) {
        addLeft = FloorF((Cast(length) - Cast(strLen)) / 2.00);
        addRight = length - strLen - addLeft;
      };
    };
  };
  i = 0;
  while i < addLeft {
    str = fillChar + str;
    i += 1;
  };
  i = 0;
  while i < addRight {
    str += fillChar;
    i += 1;
  };
  return str;
}

public static func StrStartsWith(const str: script_ref<String>, const subStr: script_ref<String>) -> Bool {
  return StrFindFirst(str, subStr) == 0;
}

public static func StrContains(const str: script_ref<String>, const subStr: script_ref<String>) -> Bool {
  return StrFindFirst(str, subStr) >= 0;
}

public static func OperatorMultiply(a: String, count: Int32) -> String {
  let result: String;
  let bit: String = a;
  let i: Int32 = 0;
  while i < count {
    result = result + bit;
    i += 1;
  };
  return result;
}

public static func OperatorAdd(s: String, i: Int32) -> String {
  return s + IntToString(i);
}

public static func OperatorAdd(i: Int32, s: String) -> String {
  return IntToString(i) + s;
}

public static func OperatorAdd(s: String, f: Float) -> String {
  return s + NoTrailZeros(f);
}

public static func OperatorAdd(f: Float, s: String) -> String {
  return NoTrailZeros(f) + s;
}

public static func OperatorAdd(s: String, b: Bool) -> String {
  return s + BoolToString(b);
}

public static func OperatorAdd(b: Bool, s: String) -> String {
  return BoolToString(b) + s;
}

public static func OperatorAdd(n1: CName, n2: CName) -> CName {
  let s1: String = NameToString(n1);
  let s2: String = NameToString(n2);
  return StringToName(s1 + s2);
}
