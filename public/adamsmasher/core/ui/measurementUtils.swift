
public native struct MeasurementUtils {

  public final static native func ValueUnitToUnit(inValue: Float, inUnit: EMeasurementUnit, outUnit: EMeasurementUnit) -> Float;

  public final static native func ValueToMetric(inValue: Float, inUnit: EMeasurementUnit, out outUnit: EMeasurementUnit) -> Float;

  public final static func ValueToMetric(inValue: Float, inUnit: EMeasurementUnit) -> Float {
    let dummyOut: EMeasurementUnit;
    return MeasurementUtils.ValueToMetric(inValue, inUnit, dummyOut);
  }

  public final static native func ValueToImperial(inValue: Float, inUnit: EMeasurementUnit, out outUnit: EMeasurementUnit) -> Float;

  public final static func ValueToImperial(inValue: Float, inUnit: EMeasurementUnit) -> Float {
    let dummyOut: EMeasurementUnit;
    return MeasurementUtils.ValueToImperial(inValue, inUnit, dummyOut);
  }

  public final static native func ValueToSystem(inValue: Float, inUnit: EMeasurementUnit, outUnitSystem: EMeasurementSystem, out outUnit: EMeasurementUnit) -> Float;

  public final static func ValueToSystem(inValue: Float, inUnit: EMeasurementUnit, outUnitSystem: EMeasurementSystem) -> Float {
    let dummyOut: EMeasurementUnit;
    return MeasurementUtils.ValueToSystem(inValue, inUnit, outUnitSystem, dummyOut);
  }

  public final static native func ValueToPlayerSettingSystem(inValue: Float, inUnit: EMeasurementUnit, out outUnit: EMeasurementUnit) -> Float;

  public final static func ValueToPlayerSettingSystem(inValue: Float, inUnit: EMeasurementUnit) -> Float {
    let dummyOut: EMeasurementUnit;
    return MeasurementUtils.ValueToPlayerSettingSystem(inValue, inUnit, dummyOut);
  }

  public final static native func GetPlayerSettingSystem() -> EMeasurementSystem;

  public final static native func UnitToMetric(inUnit: EMeasurementUnit) -> EMeasurementUnit;

  public final static native func UnitToImperial(inUnit: EMeasurementUnit) -> EMeasurementUnit;

  public final static native func UnitToSystem(inUnit: EMeasurementUnit, outSystem: EMeasurementSystem) -> EMeasurementUnit;

  public final static native func GetSystemForUnit(inUnit: EMeasurementUnit) -> EMeasurementSystem;

  public final static native func GetUnitLocalizationKey(inUnit: EMeasurementUnit) -> CName;
}
