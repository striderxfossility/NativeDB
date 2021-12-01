
public native class inkTextParams extends IScriptable {

  public final func AddString(value: String) -> Void {
    this.Internal_AddString(value);
  }

  public final func AddString(key: String, value: String) -> Void {
    this.Internal_AddString(value, key);
  }

  public final func UpdateString(index: Int32, value: String) -> Void {
    this.Internal_UpdateString(index, value);
  }

  public final func UpdateString(key: String, value: String) -> Void {
    this.Internal_UpdateStringKey(key, value);
  }

  public final func AddLocalizedString(valueLocKey: String) -> Void {
    this.Internal_AddLocalizedString(valueLocKey);
  }

  public final func AddLocalizedString(key: String, valueLocKey: String) -> Void {
    this.Internal_AddLocalizedString(valueLocKey, key);
  }

  public final func UpdateLocalizedString(index: Int32, valueLocKey: String) -> Void {
    this.Internal_UpdateLocalizedString(index, valueLocKey);
  }

  public final func UpdateLocalizedString(key: String, valueLocKey: String) -> Void {
    this.Internal_UpdateLocalizedStringKey(key, valueLocKey);
  }

  public final func AddLocalizedName(valueLocKey: CName) -> Void {
    this.Internal_AddLocalizedName(valueLocKey);
  }

  public final func AddLocalizedName(key: String, valueLocKey: CName) -> Void {
    this.Internal_AddLocalizedName(valueLocKey, key);
  }

  public final func UpdateLocalizedName(index: Int32, valueLocKey: CName) -> Void {
    this.Internal_UpdateLocalizedName(index, valueLocKey);
  }

  public final func UpdateLocalizedName(key: String, valueLocKey: CName) -> Void {
    this.Internal_UpdateLocalizedNameKey(key, valueLocKey);
  }

  public final func AddNumber(value: Int32) -> Void {
    this.Internal_AddInteger(value);
  }

  public final func AddNumber(key: String, value: Int32) -> Void {
    this.Internal_AddInteger(value, key);
  }

  public final func UpdateNumber(index: Int32, value: Int32) -> Void {
    this.Internal_UpdateInteger(index, value);
  }

  public final func UpdateNumber(key: String, value: Int32) -> Void {
    this.Internal_UpdateIntegerKey(key, value);
  }

  public final func AddNumber(value: Float) -> Void {
    this.Internal_AddFloat(value);
  }

  public final func AddNumber(key: String, value: Float) -> Void {
    this.Internal_AddFloat(value, key);
  }

  public final func UpdateNumber(index: Int32, value: Float) -> Void {
    this.Internal_UpdateFloat(index, value);
  }

  public final func UpdateNumber(key: String, value: Float) -> Void {
    this.Internal_UpdateFloatKey(key, value);
  }

  public final func AddMeasurement(value: Float, valueUnit: EMeasurementUnit) -> Void {
    this.Internal_AddMeasurement(value, valueUnit);
  }

  public final func AddMeasurement(key: String, value: Float, valueUnit: EMeasurementUnit) -> Void {
    this.Internal_AddMeasurement(value, valueUnit, key);
  }

  public final func UpdateMeasurement(index: Int32, value: Float, valueUnit: EMeasurementUnit) -> Void {
    this.Internal_UpdateMeasurement(index, value, valueUnit);
  }

  public final func UpdateMeasurement(key: String, value: Float, valueUnit: EMeasurementUnit) -> Void {
    this.Internal_UpdateMeasurementKey(key, value, valueUnit);
  }

  public final func AddTime(valueSeconds: Int32) -> Void {
    this.Internal_AddTime(valueSeconds);
  }

  public final func AddTime(value: GameTime) -> Void {
    this.Internal_AddTime(GameTime.Seconds(value));
  }

  public final func AddTime(key: String, valueSeconds: Int32) -> Void {
    this.Internal_AddTime(valueSeconds, key);
  }

  public final func AddTime(key: String, value: GameTime) -> Void {
    this.Internal_AddTime(GameTime.GetSeconds(value), key);
  }

  public final func UpdateTime(index: Int32, valueSeconds: Int32) -> Void {
    this.Internal_UpdateTime(index, valueSeconds);
  }

  public final func UpdateTime(index: Int32, value: GameTime) -> Void {
    this.Internal_UpdateTime(index, GameTime.GetSeconds(value));
  }

  public final func UpdateTime(key: String, valueSeconds: Int32) -> Void {
    this.Internal_UpdateTimeKey(key, valueSeconds);
  }

  public final func UpdateTime(key: String, value: GameTime) -> Void {
    this.Internal_UpdateTimeKey(key, GameTime.GetSeconds(value));
  }

  public final func AddNCGameTime(value: GameTime) -> Void {
    this.Internal_AddNCGameTime(GameTime.Seconds(value));
  }

  public final func AddNCGameTime(key: String, value: GameTime) -> Void {
    this.Internal_AddNCGameTime(GameTime.GetSeconds(value), key);
  }

  public final func AddCurrentDate() -> Void {
    this.Internal_AddCurrentDate();
  }

  public final func AddCurrentDate(key: String) -> Void {
    this.Internal_AddCurrentDate(key);
  }

  public final func UpdateCurrentDate(index: Int32) -> Void {
    this.Internal_UpdateCurrentDate(index);
  }

  public final func UpdateCurrentDate(key: String) -> Void {
    this.Internal_UpdateCurrentDateKey(key);
  }

  public final func SetAsyncFormat(value: Bool) -> Void {
    this.Internal_SetAsyncFormat(value);
  }

  private final native func Internal_AddString(value: String, opt key: String) -> Void;

  private final native func Internal_UpdateString(index: Int32, value: String) -> Void;

  private final native func Internal_UpdateStringKey(key: String, value: String) -> Void;

  private final native func Internal_AddLocalizedString(valueLocKey: String, opt key: String) -> Void;

  private final native func Internal_UpdateLocalizedString(index: Int32, valueLocKey: String) -> Void;

  private final native func Internal_UpdateLocalizedStringKey(key: String, valueLocKey: String) -> Void;

  private final native func Internal_AddLocalizedName(valueLocKey: CName, opt key: String) -> Void;

  private final native func Internal_UpdateLocalizedName(index: Int32, valueLocKey: CName) -> Void;

  private final native func Internal_UpdateLocalizedNameKey(key: String, valueLocKey: CName) -> Void;

  private final native func Internal_AddInteger(value: Int32, opt key: String) -> Void;

  private final native func Internal_UpdateInteger(index: Int32, value: Int32) -> Void;

  private final native func Internal_UpdateIntegerKey(key: String, value: Int32) -> Void;

  private final native func Internal_AddFloat(value: Float, opt key: String) -> Void;

  private final native func Internal_UpdateFloat(index: Int32, value: Float) -> Void;

  private final native func Internal_UpdateFloatKey(key: String, value: Float) -> Void;

  private final native func Internal_AddMeasurement(value: Float, valueUnit: EMeasurementUnit, opt key: String) -> Void;

  private final native func Internal_UpdateMeasurement(index: Int32, value: Float, valueUnit: EMeasurementUnit) -> Void;

  private final native func Internal_UpdateMeasurementKey(key: String, value: Float, valueUnit: EMeasurementUnit) -> Void;

  private final native func Internal_AddTime(valueSeconds: Int32, opt key: String) -> Void;

  private final native func Internal_UpdateTime(index: Int32, valueSeconds: Int32) -> Void;

  private final native func Internal_UpdateTimeKey(key: String, valueSeconds: Int32) -> Void;

  private final native func Internal_AddNCGameTime(valueSeconds: Int32, opt key: String) -> Void;

  private final native func Internal_AddCurrentDate(opt key: String) -> Void;

  private final native func Internal_UpdateCurrentDate(index: Int32) -> Void;

  private final native func Internal_UpdateCurrentDateKey(key: String) -> Void;

  private final native func Internal_SetAsyncFormat(value: Bool) -> Void;
}
