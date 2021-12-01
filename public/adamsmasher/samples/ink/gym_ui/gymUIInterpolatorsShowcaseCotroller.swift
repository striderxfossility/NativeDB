
public class InterpolatorsShowcaseController extends inkLogicController {

  public edit let interpolationType: inkanimInterpolationType;

  public edit let interpolationMode: inkanimInterpolationMode;

  private let m_overlay: wref<inkWidget>;

  private let m_heightBar: wref<inkWidget>;

  private let m_widthBar: wref<inkWidget>;

  private let m_graphPointer: wref<inkWidget>;

  private let m_counterText: wref<inkText>;

  private let m_sizeWidget: wref<inkWidget>;

  private let m_rotationWidget: wref<inkWidget>;

  private let m_marginWidget: wref<inkWidget>;

  private let m_colorWidget: wref<inkWidget>;

  private let m_sizeAnim: ref<inkAnimDef>;

  private let m_rotationAnim: ref<inkAnimDef>;

  private let m_marginAnim: ref<inkAnimDef>;

  private let m_colorAnim: ref<inkAnimDef>;

  private let m_followTimelineAnim: ref<inkAnimDef>;

  private let m_interpolateAnim: ref<inkAnimDef>;

  private let m_startMargin: inkMargin;

  private let m_animLength: Float;

  private let m_animConstructor: ref<AnimationsConstructor>;

  protected cb func OnInitialize() -> Bool {
    this.m_animConstructor = new AnimationsConstructor();
    this.FillWidgetsVariables();
    this.PrepareGraphPointer();
    this.m_animLength = 3.00;
    this.UpdateCounterText();
    this.ConstructAnimations();
  }

  private final func FillWidgetsVariables() -> Void {
    this.m_overlay = this.GetWidget(n"Graph");
    this.m_heightBar = this.GetWidget(n"Graph/HeightBar");
    this.m_widthBar = this.GetWidget(n"Graph/WidthBar");
    this.m_graphPointer = this.GetWidget(n"GraphPointer");
    this.m_counterText = this.GetWidget(n"TimerPanel/Timer/Text") as inkText;
    this.m_sizeWidget = this.GetWidget(n"AnimatedObjects/Anim_size");
    this.m_rotationWidget = this.GetWidget(n"AnimatedObjects/Anim_rotation");
    this.m_marginWidget = this.GetWidget(n"AnimatedObjects/Anim_margin");
    this.m_colorWidget = this.GetWidget(n"AnimatedObjects/Anim_color");
  }

  private final func PrepareGraphPointer() -> Void {
    this.m_startMargin = this.m_overlay.GetMargin();
    let tempVector: Vector2 = this.m_widthBar.GetSize();
    this.m_startMargin.top -= tempVector.Y;
    tempVector = this.m_heightBar.GetSize();
    this.m_startMargin.left += tempVector.X;
    this.m_graphPointer.SetMargin(this.m_startMargin);
  }

  public final func InterpolatorModeToIn(e: ref<inkPointerEvent>) -> Void {
    this.interpolationMode = inkanimInterpolationMode.EasyIn;
  }

  public final func InterpolatorModeToOut(e: ref<inkPointerEvent>) -> Void {
    this.interpolationMode = inkanimInterpolationMode.EasyOut;
  }

  public final func InterpolatorModeToInOut(e: ref<inkPointerEvent>) -> Void {
    this.interpolationMode = inkanimInterpolationMode.EasyInOut;
  }

  public final func InterpolatorTypeToLinear(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Linear;
  }

  public final func InterpolatorTypeToQuadratic(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Quadratic;
  }

  public final func InterpolatorTypeToQubic(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Qubic;
  }

  public final func InterpolatorTypeToQuartic(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Quartic;
  }

  public final func InterpolatorTypeToQuintic(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Quintic;
  }

  public final func InterpolatorTypeToSinusoidal(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Sinusoidal;
  }

  public final func InterpolatorTypeToExponential(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Exponential;
  }

  public final func InterpolatorTypeToElastic(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Elastic;
  }

  public final func InterpolatorTypeToCircular(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Circular;
  }

  public final func InterpolatorTypeToBack(e: ref<inkPointerEvent>) -> Void {
    this.interpolationType = inkanimInterpolationType.Back;
  }

  public final func RiseTimer_1(e: ref<inkPointerEvent>) -> Void {
    this.m_animLength += 0.01;
    this.UpdateCounterText();
  }

  public final func RiseTimer_2(e: ref<inkPointerEvent>) -> Void {
    this.m_animLength += 0.10;
    this.UpdateCounterText();
  }

  public final func RiseTimer_3(e: ref<inkPointerEvent>) -> Void {
    this.m_animLength += 1.00;
    this.UpdateCounterText();
  }

  public final func LowerTimer_1(e: ref<inkPointerEvent>) -> Void {
    this.m_animLength -= 0.01;
    this.UpdateCounterText();
  }

  public final func LowerTimer_2(e: ref<inkPointerEvent>) -> Void {
    this.m_animLength -= 0.10;
    this.UpdateCounterText();
  }

  public final func LowerTimer_3(e: ref<inkPointerEvent>) -> Void {
    this.m_animLength -= 1.00;
    this.UpdateCounterText();
  }

  private final func UpdateCounterText() -> Void {
    this.m_counterText.SetText(FloatToString(this.m_animLength));
  }

  public final func PlayAnimation(e: ref<inkPointerEvent>) -> Void {
    this.StopAllAnimations();
    this.ConstructAnimations();
    this.m_graphPointer.SetMargin(this.m_overlay.GetMargin());
    this.m_graphPointer.PlayAnimation(this.m_interpolateAnim);
    this.m_graphPointer.PlayAnimation(this.m_followTimelineAnim);
    this.m_sizeWidget.PlayAnimation(this.m_sizeAnim);
    this.m_rotationWidget.PlayAnimation(this.m_rotationAnim);
    this.m_colorWidget.PlayAnimation(this.m_colorAnim);
    this.m_marginWidget.PlayAnimation(this.m_marginAnim);
  }

  private final func StopAllAnimations() -> Void {
    this.m_graphPointer.StopAllAnimations();
    this.m_sizeWidget.StopAllAnimations();
    this.m_rotationWidget.StopAllAnimations();
    this.m_colorWidget.StopAllAnimations();
    this.m_marginWidget.StopAllAnimations();
  }

  private final func ConstructAnimations() -> Void {
    this.m_animConstructor.SetGenericSettings(this.m_animLength, this.interpolationType, this.interpolationMode, true);
    this.ConstructInterpolatorAnim();
    this.ConstructTimelineFollow();
    this.m_animConstructor.SetGenericSettings(this.m_animLength, this.interpolationType, this.interpolationMode, false);
    this.ConstructShowcaseAnimations();
  }

  private final func ConstructInterpolatorAnim() -> Void {
    let endMargin: inkMargin;
    let interpolatedMovement: ref<inkAnimMargin>;
    let tempVector: Vector2 = this.m_heightBar.GetSize();
    endMargin.top = -tempVector.Y;
    tempVector = this.m_widthBar.GetSize();
    endMargin.top += tempVector.Y;
    this.m_interpolateAnim = new inkAnimDef();
    interpolatedMovement = this.m_animConstructor.NewMarginInterpolator(new inkMargin(0.00, 0.00, 0.00, 0.00), endMargin);
    this.m_interpolateAnim.AddInterpolator(interpolatedMovement);
  }

  private final func ConstructTimelineFollow() -> Void {
    let endMargin: inkMargin;
    let linearMovementInterpolator: ref<inkAnimMargin>;
    let tempVector: Vector2 = this.m_widthBar.GetSize();
    endMargin.left = tempVector.X;
    tempVector = this.m_heightBar.GetSize();
    endMargin.left -= tempVector.X;
    this.m_followTimelineAnim = new inkAnimDef();
    linearMovementInterpolator = this.m_animConstructor.NewMarginInterpolator(new inkMargin(0.00, 0.00, 0.00, 0.00), endMargin);
    linearMovementInterpolator.SetType(inkanimInterpolationType.Linear);
    this.m_followTimelineAnim.AddInterpolator(linearMovementInterpolator);
  }

  private final func ConstructShowcaseAnimations() -> Void {
    this.m_sizeAnim = new inkAnimDef();
    this.m_rotationAnim = new inkAnimDef();
    this.m_colorAnim = new inkAnimDef();
    this.m_marginAnim = new inkAnimDef();
    this.m_sizeAnim.AddInterpolator(this.m_animConstructor.NewSizeInterpolator(new Vector2(96.00, 96.00), new Vector2(192.00, 192.00)));
    this.m_rotationAnim.AddInterpolator(this.m_animConstructor.NewRotationInterpolator(0.00, 180.00));
    this.m_colorAnim.AddInterpolator(this.m_animConstructor.NewColorInterpolator(new HDRColor(1.00, 1.00, 1.00, 1.00), new HDRColor(1.00, 0.00, 0.00, 1.00)));
    this.m_marginAnim.AddInterpolator(this.m_animConstructor.NewMarginInterpolator(new inkMargin(475.00, 400.00, 0.00, 0.00), new inkMargin(875.00, 400.00, 0.00, 0.00)));
  }
}
