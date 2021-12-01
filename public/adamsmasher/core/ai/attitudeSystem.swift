
public static func CanChangeAttitudeRelationFor(groupName: CName) -> Bool {
  if Equals(groupName, n"friendly") {
    return false;
  };
  if Equals(groupName, n"neutral") {
    return false;
  };
  if Equals(groupName, n"hostile") {
    return false;
  };
  return true;
}
