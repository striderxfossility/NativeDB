
public class DeviceActionPropertyFunctions extends IScriptable {

  public final static func SetUpProperty_Bool(propertyName: CName, value: Bool, nameOnTrue: CName, nameOnFalse: CName) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"Bool";
    prop.first = ToVariant(value);
    prop.second = ToVariant(nameOnTrue);
    prop.third = ToVariant(nameOnFalse);
    prop.flags = IntEnum(0l);
    return prop;
  }

  public final static func GetProperty_Bool(prop: ref<DeviceActionProperty>, out value: Bool, out nameOnFalse: CName, out nameOnTrue: CName) -> Bool {
    if NotEquals(prop.typeName, n"Bool") {
      return false;
    };
    value = FromVariant(prop.first);
    nameOnTrue = FromVariant(prop.second);
    nameOnFalse = FromVariant(prop.third);
    return true;
  }

  public final static func GetProperty_Bool(prop: ref<DeviceActionProperty>, out value: Bool) -> Bool {
    if NotEquals(prop.typeName, n"Bool") {
      return false;
    };
    value = FromVariant(prop.first);
    return true;
  }

  public final static func SetUpProperty_Float(propertyName: CName, value: Float) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"Float";
    prop.first = ToVariant(value);
    prop.flags = gamedeviceActionPropertyFlags.IsUsedByQuest;
    return prop;
  }

  public final static func GetProperty_Float(prop: ref<DeviceActionProperty>, out value: Float) -> Bool {
    if NotEquals(prop.typeName, n"Float") {
      return false;
    };
    value = FromVariant(prop.first);
    return true;
  }

  public final static func SetUpProperty_Int(propertyName: CName, value: Int32) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"Int";
    prop.first = ToVariant(value);
    prop.flags = gamedeviceActionPropertyFlags.IsUsedByQuest;
    return prop;
  }

  public final static func GetProperty_Int(prop: ref<DeviceActionProperty>, out value: Int32) -> Bool {
    if NotEquals(prop.typeName, n"Int") {
      return false;
    };
    value = FromVariant(prop.first);
    return true;
  }

  public final static func SetUpProperty_IntRanged(propertyName: CName, value: Int32, rangeMin: Int32, rangeMax: Int32) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"IntRanged";
    prop.first = ToVariant(value);
    prop.second = ToVariant(rangeMin);
    prop.third = ToVariant(rangeMax);
    prop.flags = gamedeviceActionPropertyFlags.IsUsedByQuest;
    return prop;
  }

  public final static func GetProperty_IntRanged(prop: ref<DeviceActionProperty>, out value: Int32, out rangeMin: Int32, out rangeMax: Int32) -> Bool {
    if NotEquals(prop.typeName, n"IntRanged") {
      return false;
    };
    value = FromVariant(prop.first);
    rangeMin = FromVariant(prop.second);
    rangeMax = FromVariant(prop.third);
    return true;
  }

  public final static func SetUpProperty_Name(propertyName: CName, value: CName) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"Name";
    prop.first = ToVariant(value);
    prop.flags = gamedeviceActionPropertyFlags.IsUsedByQuest;
    return prop;
  }

  public final static func GetProperty_Name(prop: ref<DeviceActionProperty>, out value: CName) -> Bool {
    if NotEquals(prop.typeName, n"Name") {
      return false;
    };
    value = FromVariant(prop.first);
    return true;
  }

  public final static func SetUpProperty_RadioStatus(propertyName: CName, deviceStatus: Int32, stationName: String) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"RadioStatus";
    prop.first = ToVariant(deviceStatus);
    prop.second = ToVariant(stationName);
    prop.flags = IntEnum(0l);
    return prop;
  }

  public final static func GetProperty_RadioStatus(prop: ref<DeviceActionProperty>, out deviceStatus: Int32, out stationName: String) -> Bool {
    if NotEquals(prop.typeName, n"RadioStatus") {
      return false;
    };
    deviceStatus = FromVariant(prop.first);
    stationName = FromVariant(prop.second);
    return true;
  }

  public final static func SetUpProperty_TvStatus(propertyName: CName, deviceStatus: Int32, stationName: String) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"TvStatus";
    prop.first = ToVariant(deviceStatus);
    prop.second = ToVariant(stationName);
    prop.flags = IntEnum(0l);
    return prop;
  }

  public final static func GetProperty_TvStatus(prop: ref<DeviceActionProperty>, out deviceStatus: Int32, out stationName: String) -> Bool {
    if NotEquals(prop.typeName, n"TvStatus") {
      return false;
    };
    deviceStatus = FromVariant(prop.first);
    stationName = FromVariant(prop.second);
    return true;
  }

  public final static func SetUpProperty_MediaStatus(propertyName: CName, deviceStatus: Int32, stationName: String) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"MediaStatus";
    prop.first = ToVariant(deviceStatus);
    prop.second = ToVariant(stationName);
    prop.flags = IntEnum(0l);
    return prop;
  }

  public final static func GetProperty_MediaStatus(prop: ref<DeviceActionProperty>, out deviceStatus: Int32, out stationName: String) -> Bool {
    if NotEquals(prop.typeName, n"MediaStatus") {
      return false;
    };
    deviceStatus = FromVariant(prop.first);
    stationName = FromVariant(prop.second);
    return true;
  }

  public final static func SetUpProperty_ElevatorInt(propertyName: CName, value: Int32, displayValue: Int32) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"ElevatorInt";
    prop.first = ToVariant(value);
    prop.second = ToVariant(displayValue);
    prop.flags = IntEnum(0l);
    return prop;
  }

  public final static func SetUpProperty_NodeRef(propertyName: CName, value: NodeRef) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"NodeRef";
    prop.first = ToVariant(value);
    prop.flags = gamedeviceActionPropertyFlags.IsUsedByQuest;
    return prop;
  }

  public final static func GetProperty_NodeRef(prop: ref<DeviceActionProperty>, out value: NodeRef) -> Bool {
    if NotEquals(prop.typeName, n"NodeRef") {
      return false;
    };
    value = FromVariant(prop.first);
    return true;
  }

  public final static func SetUpProperty_EntityReference(propertyName: CName, value: EntityReference) -> ref<DeviceActionProperty> {
    let prop: ref<DeviceActionProperty> = new DeviceActionProperty();
    prop.name = propertyName;
    prop.typeName = n"EntityReference";
    prop.first = ToVariant(value);
    prop.flags = gamedeviceActionPropertyFlags.IsUsedByQuest;
    return prop;
  }

  public final static func GetProperty_EntityReference(prop: ref<DeviceActionProperty>, out value: EntityReference) -> Bool {
    if NotEquals(prop.typeName, n"EntityReference") {
      return false;
    };
    value = FromVariant(prop.first);
    return true;
  }
}
