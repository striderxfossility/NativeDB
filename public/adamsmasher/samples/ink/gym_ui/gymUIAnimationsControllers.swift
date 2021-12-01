
public class sampleUICustomizableAnimationsController extends inkLogicController {

  public edit let imagePath: CName;

  public edit let interpolationType: inkanimInterpolationType;

  public edit let interpolationMode: inkanimInterpolationMode;

  public edit let delayTime: Float;

  private let m_rotation_anim: ref<inkAnimDef>;

  private let m_size_anim: ref<inkAnimDef>;

  private let m_color_anim: ref<inkAnimDef>;

  private let m_alpha_anim: ref<inkAnimDef>;

  private let m_position_anim: ref<inkAnimDef>;

  private let imageWidget: wref<inkWidget>;

  private let animProxy: ref<inkAnimProxy>;

  private let CanRotate: Bool;

  private let CanResize: Bool;

  private let CanChangeColor: Bool;

  private let CanChangeAlpha: Bool;

  private let CanMove: Bool;

  private let m_defaultSize: Vector2;

  private let m_defaultMargin: inkMargin;

  private let m_defaultRotation: Float;

  private let m_defaultColor: HDRColor;

  private let m_defaultAlpha: Float;

  private let m_isHighlighted: Bool;

  private let m_currentTarget: wref<inkWidget>;

  private let m_currentAnimProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.imageWidget = this.GetWidget(this.imagePath);
    this.SaveDefaults();
    this.UpdateDefinitions();
  }

  public final func Higlight(e: ref<inkPointerEvent>) -> Void {
    this.m_currentTarget = e.GetTarget();
    this.m_isHighlighted = true;
    this.m_currentTarget.SetTintColor(new Color(180u, 180u, 180u, 255u));
  }

  public final func EndHiglight(e: ref<inkPointerEvent>) -> Void {
    this.m_isHighlighted = false;
    this.m_currentTarget.SetTintColor(new Color(255u, 255u, 255u, 255u));
  }

  private final func SaveDefaults() -> Void {
    this.m_defaultSize = this.imageWidget.GetSize();
    this.m_defaultMargin = this.imageWidget.GetMargin();
    this.m_defaultRotation = 0.00;
    this.m_defaultColor = this.imageWidget.GetTintColor();
    this.m_defaultAlpha = this.imageWidget.GetOpacity();
  }

  public final func Reset(e: ref<inkPointerEvent>) -> Void {
    this.imageWidget.SetSize(this.m_defaultSize);
    this.imageWidget.SetMargin(this.m_defaultMargin);
    this.imageWidget.SetRotation(this.m_defaultRotation);
    this.imageWidget.SetTintColor(this.m_defaultColor);
    this.imageWidget.SetOpacity(this.m_defaultAlpha);
  }

  public final func PlayAnimation(e: ref<inkPointerEvent>) -> Void {
    if this.CanRotate {
      this.imageWidget.PlayAnimation(this.m_rotation_anim);
    };
    if this.CanResize {
      this.imageWidget.PlayAnimation(this.m_size_anim);
    };
    if this.CanChangeColor {
      this.imageWidget.PlayAnimation(this.m_color_anim);
    };
    if this.CanChangeAlpha {
      this.imageWidget.PlayAnimation(this.m_alpha_anim);
    };
    if this.CanMove {
      this.imageWidget.PlayAnimation(this.m_position_anim);
    };
    this.m_currentAnimProxy = this.PlayLibraryAnimation(n"BinkTest");
  }

  private final func SetText(buttonName: CName, status: Bool) -> Void {
    let backgroundWidget: wref<inkRectangle> = this.GetWidget(StringToName("Buttons\\" + ToString(buttonName) + "\\Button_bg")) as inkRectangle;
    let widget: wref<inkText> = this.GetWidget(StringToName("Buttons\\" + ToString(buttonName) + "\\Texts\\animStatus")) as inkText;
    if status {
      widget.SetText("ON");
      backgroundWidget.SetTintColor(new Color(101u, 255u, 145u, 255u));
    } else {
      widget.SetText("OFF");
      backgroundWidget.SetTintColor(new Color(255u, 255u, 255u, 255u));
    };
  }

  public final func ToggleRotationAnim(e: ref<inkPointerEvent>) -> Void {
    this.CanRotate = !this.CanRotate;
    this.SetText(n"Button_1", this.CanRotate);
  }

  public final func ToggleSizeAnim(e: ref<inkPointerEvent>) -> Void {
    this.CanResize = !this.CanResize;
    this.SetText(n"Button_2", this.CanResize);
  }

  public final func ToggleColorAnim(e: ref<inkPointerEvent>) -> Void {
    this.CanChangeColor = !this.CanChangeColor;
    this.SetText(n"Button_3", this.CanChangeColor);
  }

  public final func ToggleAlphaAnim(e: ref<inkPointerEvent>) -> Void {
    this.CanChangeAlpha = !this.CanChangeAlpha;
    this.SetText(n"Button_4", this.CanChangeAlpha);
  }

  public final func TogglePositionAnim(e: ref<inkPointerEvent>) -> Void {
    this.CanMove = !this.CanMove;
    this.SetText(n"Button_5", this.CanMove);
  }

  private final func UpdateDefinitions() -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let colorInterpolator: ref<inkAnimColor>;
    let positionInterpolator: ref<inkAnimMargin>;
    let sizeInterpolator: ref<inkAnimSize>;
    this.m_rotation_anim = new inkAnimDef();
    let rotationInterpolator: ref<inkAnimRotation> = new inkAnimRotation();
    rotationInterpolator.SetStartRotation(0.00);
    rotationInterpolator.SetEndRotation(180.00);
    rotationInterpolator.SetDuration(3.00);
    rotationInterpolator.SetType(this.interpolationType);
    rotationInterpolator.SetMode(this.interpolationMode);
    if this.delayTime > 0.00 {
      rotationInterpolator.SetStartDelay(this.delayTime);
    };
    this.m_rotation_anim.AddInterpolator(rotationInterpolator);
    this.m_size_anim = new inkAnimDef();
    sizeInterpolator = new inkAnimSize();
    sizeInterpolator.SetStartSize(new Vector2(128.00, 128.00));
    sizeInterpolator.SetEndSize(new Vector2(96.00, 96.00));
    sizeInterpolator.SetDuration(3.00);
    sizeInterpolator.SetType(this.interpolationType);
    sizeInterpolator.SetMode(this.interpolationMode);
    if this.delayTime > 0.00 {
      sizeInterpolator.SetStartDelay(this.delayTime);
    };
    this.m_size_anim.AddInterpolator(sizeInterpolator);
    this.m_color_anim = new inkAnimDef();
    colorInterpolator = new inkAnimColor();
    colorInterpolator.SetStartColor(new HDRColor(1.00, 1.00, 1.00, 1.00));
    colorInterpolator.SetEndColor(new HDRColor(1.00, 0.00, 0.00, 1.00));
    colorInterpolator.SetDuration(3.00);
    colorInterpolator.SetType(this.interpolationType);
    colorInterpolator.SetMode(this.interpolationMode);
    if this.delayTime > 0.00 {
      colorInterpolator.SetStartDelay(this.delayTime);
    };
    this.m_color_anim.AddInterpolator(colorInterpolator);
    this.m_alpha_anim = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.20);
    alphaInterpolator.SetDuration(3.00);
    alphaInterpolator.SetType(this.interpolationType);
    alphaInterpolator.SetMode(this.interpolationMode);
    if this.delayTime > 0.00 {
      alphaInterpolator.SetStartDelay(this.delayTime);
    };
    this.m_alpha_anim.AddInterpolator(alphaInterpolator);
    this.m_position_anim = new inkAnimDef();
    positionInterpolator = new inkAnimMargin();
    positionInterpolator.SetStartMargin(new inkMargin(800.00, 150.00, 0.00, 0.00));
    positionInterpolator.SetEndMargin(new inkMargin(600.00, 150.00, 0.00, 0.00));
    positionInterpolator.SetDuration(3.00);
    positionInterpolator.SetType(this.interpolationType);
    positionInterpolator.SetMode(this.interpolationMode);
    if this.delayTime > 0.00 {
      positionInterpolator.SetStartDelay(this.delayTime);
    };
    this.m_position_anim.AddInterpolator(positionInterpolator);
  }
}
