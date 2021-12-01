
public native class PhoneWaveformGameController extends inkGameController {

  private edit let m_barItemName: CName;

  private let m_root: wref<inkCompoundWidget>;

  private let m_bars: array<wref<inkWidget>>;

  private let m_traces: array<wref<inkWidget>>;

  private let m_cachedRootSize: Vector2;

  @default(PhoneWaveformGameController, 200.f)
  private let m_maxValue: Float;

  @default(PhoneWaveformGameController, 4.f)
  private let m_barsPadding: Float;

  private let m_barSize: Vector2;

  public final native func SetMeasurementsCount(value: Int32) -> Void;

  public final native func GetMeasurementsCount() -> Int32;

  public final native func SetMeasurementsIntreval(value: Float) -> Void;

  public final native func GetMeasurementsIntreval() -> Float;

  public final func SetItemName(value: CName) -> Void {
    this.m_barItemName = value;
  }

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootCompoundWidget();
    this.m_cachedRootSize = this.m_root.GetSize();
    this.InitWaveform();
  }

  protected cb func OnUpdate(audioData: ref<gameuiPhoneWaveformData>) -> Bool {
    let rootSize: Vector2;
    if IsDefined(this.m_root) && this.m_root.IsVisible() {
      rootSize = this.m_root.GetSize();
      if NotEquals(this.m_cachedRootSize, rootSize) {
        this.m_cachedRootSize = rootSize;
        this.InitWaveform();
      };
      this.UpdateWaveform(audioData.points);
    };
  }

  private final func InitWaveform() -> Void {
    let bar: wref<inkWidget>;
    let i: Int32;
    let margin: inkMargin;
    let count: Int32 = this.GetMeasurementsCount();
    this.m_barSize = new Vector2((this.m_cachedRootSize.X - this.m_barsPadding * Cast(count)) / Cast(count), this.m_cachedRootSize.Y);
    while ArraySize(this.m_bars) > 0 {
      this.m_root.RemoveChild(ArrayPop(this.m_bars));
    };
    i = 0;
    while i < count {
      margin = new inkMargin(Cast(i) * this.m_barSize.X + this.m_barsPadding * Cast(i), this.m_cachedRootSize.Y, 0.00, 0.00);
      bar = this.SpawnBar(margin);
      ArrayPush(this.m_bars, bar);
      bar = this.SpawnBar(margin);
      bar.SetOpacity(0.50);
      ArrayPush(this.m_traces, bar);
      i += 1;
    };
  }

  private final func SpawnBar(margin: inkMargin) -> wref<inkCompoundWidget> {
    let newBar: wref<inkCompoundWidget> = this.SpawnFromLocal(this.m_root, this.m_barItemName) as inkCompoundWidget;
    newBar.SetAnchorPoint(new Vector2(0.00, 1.00));
    newBar.SetRenderTransformPivot(new Vector2(0.00, 1.00));
    newBar.SetSize(new Vector2(0.00, 0.00));
    newBar.SetMargin(margin);
    return newBar;
  }

  private final func UpdateWaveform(audioData: array<Vector4>) -> Void {
    let bar: wref<inkWidget>;
    let rndValue: Float;
    let size: Vector2;
    let trace: wref<inkWidget>;
    let traceSize: Vector2;
    let value: Float;
    let count: Int32 = ArraySize(this.m_bars);
    let i: Int32 = 0;
    while i < count {
      value = (this.m_maxValue - AbsF(audioData[i].Z)) / this.m_maxValue;
      if value > 0.00 {
        rndValue = 0.75 * value + 0.25 * RandF();
      } else {
        rndValue = 0.00;
      };
      bar = this.m_bars[i];
      trace = this.m_traces[i];
      size = this.FixSize(bar, rndValue);
      traceSize = trace.GetSize();
      if size.Y > traceSize.Y {
        traceSize.Y = size.Y;
        traceSize.X = size.X;
      } else {
        if traceSize.Y > 0.00 {
          traceSize.Y -= 2.00;
          if traceSize.Y < 0.00 {
            traceSize.Y = 0.00;
          };
        };
      };
      trace.SetSize(traceSize);
      i += 1;
    };
  }

  private final func FixSize(bar: wref<inkWidget>, value: Float) -> Vector2 {
    let res: Vector2;
    let intX: Int32 = RoundF(this.m_barSize.X);
    let intY: Int32 = RoundF(this.m_barSize.Y * value);
    if !FloatIsEqual(Cast(intX) / 2.00, Cast(RoundF(Cast(intX) / 2.00))) {
      intX += 1;
    };
    if !FloatIsEqual(Cast(intY) / 2.00, Cast(RoundF(Cast(intY) / 2.00))) {
      intY += 1;
    };
    res = new Vector2(Cast(intX), Cast(intY));
    bar.SetSize(res);
    return res;
  }
}
