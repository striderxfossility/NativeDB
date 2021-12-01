
public class ProgressBarSimpleWidgetLogicController extends inkLogicController {

  private let m_width: Float;

  private let m_height: Float;

  @default(ProgressBarSimpleWidgetLogicController, 1)
  public let m_currentValue: Float;

  @default(ProgressBarSimpleWidgetLogicController, 1)
  public let m_previousValue: Float;

  @default(ProgressBarSimpleWidgetLogicController, 500)
  public let m_MaxCNBarFlashSize: Float;

  public edit let m_fullBar: inkWidgetRef;

  public edit let m_changePBar: inkWidgetRef;

  public edit let m_changeNBar: inkWidgetRef;

  public edit let m_emptyBar: inkWidgetRef;

  public edit let m_barCap: inkWidgetRef;

  @default(ProgressBarSimpleWidgetLogicController, false)
  public edit let m_showBarCap: Bool;

  @default(ProgressBarSimpleWidgetLogicController, 2)
  public edit let m_animDuration: Float;

  private let m_full_anim_proxy: ref<inkAnimProxy>;

  private let m_full_anim: ref<inkAnimDef>;

  private let m_empty_anim_proxy: ref<inkAnimProxy>;

  private let m_empty_anim: ref<inkAnimDef>;

  private let m_changeP_anim_proxy: ref<inkAnimProxy>;

  private let m_changeP_anim: ref<inkAnimDef>;

  private let m_changeN_anim_proxy: ref<inkAnimProxy>;

  private let m_changeN_anim: ref<inkAnimDef>;

  private let m_barCap_anim_proxy: ref<inkAnimProxy>;

  private let m_barCap_anim: ref<inkAnimDef>;

  protected let m_rootWidget: wref<inkCompoundWidget>;

  protected cb func OnInitialize() -> Bool {
    this.SetDefaultValues();
    inkWidgetRef.SetVisible(this.m_barCap, false);
    this.m_rootWidget = this.GetRootWidget() as inkCompoundWidget;
  }

  public final func SetDefaultValues() -> Void {
    let tempSize: Vector2 = inkWidgetRef.GetSize(this.m_fullBar);
    this.m_width = tempSize.X;
    this.m_height = tempSize.Y;
    inkWidgetRef.SetSize(this.m_fullBar, new Vector2(this.m_width, this.m_height));
    inkWidgetRef.SetSize(this.m_changePBar, new Vector2(0.00, this.m_height));
    inkWidgetRef.SetSize(this.m_changeNBar, new Vector2(0.00, this.m_height));
    inkWidgetRef.SetSize(this.m_emptyBar, new Vector2(0.00, this.m_height));
  }

  public final func SetProgress(newValue: Float, silent: Bool) -> Bool {
    let barSize: Vector2;
    let fullBarSize: Vector2;
    let negativeMargin: inkMargin;
    let playNegativeFlashAnim: Bool;
    let sizeCN: Float;
    let sizeCP: Float;
    let sizeE: Float;
    let sizeF: Float;
    let sizeInterpolator: ref<inkAnimSize>;
    let visualCNMax: Float;
    this.m_previousValue = this.m_currentValue;
    this.m_currentValue = newValue;
    if this.m_showBarCap {
      inkWidgetRef.SetVisible(this.m_barCap, newValue != 1.00);
    };
    if silent {
      if IsDefined(this.m_full_anim_proxy) {
        this.m_full_anim_proxy.Stop();
      };
      if IsDefined(this.m_empty_anim_proxy) {
        this.m_empty_anim_proxy.Stop();
      };
      if IsDefined(this.m_changeP_anim_proxy) {
        this.m_changeP_anim_proxy.Stop();
      };
      if IsDefined(this.m_changeN_anim_proxy) {
        this.m_changeN_anim_proxy.Stop();
      };
      if IsDefined(this.m_barCap_anim_proxy) {
        this.m_barCap_anim_proxy.Stop();
      };
      inkWidgetRef.SetSize(this.m_fullBar, new Vector2(this.m_width * this.m_currentValue, this.m_height));
      inkWidgetRef.SetSize(this.m_changePBar, new Vector2(0.00, this.m_height));
      inkWidgetRef.SetSize(this.m_changeNBar, new Vector2(0.00, this.m_height));
      inkWidgetRef.SetSize(this.m_emptyBar, new Vector2(this.m_width * (1.00 - this.m_currentValue), this.m_height));
    } else {
      if this.m_previousValue - this.m_currentValue < 0.00 {
        barSize = inkWidgetRef.GetSize(this.m_changePBar);
        sizeCP = ClampF(barSize.X / this.m_width + AbsF(this.m_previousValue - this.m_currentValue), 0.00, 1.00);
        if this.m_changeN_anim_proxy.IsPlaying() {
          barSize = inkWidgetRef.GetSize(this.m_changeNBar);
          sizeCN = ClampF(barSize.X / this.m_width - AbsF(this.m_previousValue - this.m_currentValue), 0.00, 1.00);
        } else {
          sizeCN = 0.00;
        };
      } else {
        barSize = inkWidgetRef.GetSize(this.m_changeNBar);
        sizeCN = ClampF(barSize.X / this.m_width + AbsF(this.m_previousValue - this.m_currentValue), 0.00, 1.00);
        if IsDefined(this.m_changeP_anim_proxy) && this.m_changeP_anim_proxy.IsPlaying() {
          barSize = inkWidgetRef.GetSize(this.m_changePBar);
          sizeCP = ClampF(barSize.X / this.m_width - AbsF(this.m_previousValue - this.m_currentValue), 0.00, 1.00);
        } else {
          sizeCP = 0.00;
        };
      };
      sizeF = ClampF(this.m_currentValue - sizeCP, 0.00, 1.00);
      sizeE = ClampF(1.00 - this.m_currentValue - sizeCN, 0.00, 1.00);
      if IsDefined(this.m_full_anim_proxy) {
        this.m_full_anim_proxy.Stop();
      };
      if IsDefined(this.m_empty_anim_proxy) {
        this.m_empty_anim_proxy.Stop();
      };
      if IsDefined(this.m_changeP_anim_proxy) {
        this.m_changeP_anim_proxy.Stop();
      };
      if IsDefined(this.m_changeN_anim_proxy) {
        this.m_changeN_anim_proxy.Stop();
      };
      this.m_full_anim = new inkAnimDef();
      sizeInterpolator = new inkAnimSize();
      sizeInterpolator.SetStartSize(new Vector2(this.m_width * sizeF, this.m_height));
      sizeInterpolator.SetEndSize(new Vector2(this.m_width * this.m_currentValue, this.m_height));
      sizeInterpolator.SetDuration((sizeF + sizeCP) * this.m_animDuration);
      sizeInterpolator.SetStartDelay(0.00);
      sizeInterpolator.SetType(inkanimInterpolationType.Linear);
      sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      this.m_full_anim.AddInterpolator(sizeInterpolator);
      this.m_changeP_anim = new inkAnimDef();
      sizeInterpolator = new inkAnimSize();
      sizeInterpolator.SetStartSize(new Vector2(this.m_width * sizeCP, this.m_height));
      sizeInterpolator.SetEndSize(new Vector2(0.00, this.m_height));
      sizeInterpolator.SetDuration((sizeF + sizeCP) * this.m_animDuration);
      sizeInterpolator.SetStartDelay(0.00);
      sizeInterpolator.SetType(inkanimInterpolationType.Linear);
      sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      this.m_changeP_anim.AddInterpolator(sizeInterpolator);
      visualCNMax = MinF(this.m_MaxCNBarFlashSize, this.m_width * AbsF(sizeCN));
      this.m_changeN_anim = new inkAnimDef();
      sizeInterpolator = new inkAnimSize();
      sizeInterpolator.SetStartSize(new Vector2(visualCNMax, this.m_height));
      sizeInterpolator.SetEndSize(new Vector2(0.00, this.m_height));
      sizeInterpolator.SetDuration((sizeE + sizeCN) * this.m_animDuration);
      sizeInterpolator.SetStartDelay(0.00);
      sizeInterpolator.SetType(inkanimInterpolationType.Linear);
      sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      this.m_changeN_anim.AddInterpolator(sizeInterpolator);
      this.m_empty_anim = new inkAnimDef();
      sizeInterpolator = new inkAnimSize();
      sizeInterpolator.SetStartSize(new Vector2(this.m_width * sizeE, this.m_height));
      sizeInterpolator.SetEndSize(new Vector2(this.m_width * (1.00 - this.m_currentValue), this.m_height));
      sizeInterpolator.SetDuration((sizeE + sizeCN) * this.m_animDuration);
      sizeInterpolator.SetStartDelay(0.00);
      sizeInterpolator.SetType(inkanimInterpolationType.Linear);
      sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      this.m_empty_anim.AddInterpolator(sizeInterpolator);
      if sizeF + sizeCP > 0.00 {
        this.m_full_anim_proxy = inkWidgetRef.PlayAnimation(this.m_fullBar, this.m_full_anim);
        this.m_changeP_anim_proxy = inkWidgetRef.PlayAnimation(this.m_changePBar, this.m_changeP_anim);
      };
      if sizeE + sizeCN > 0.00 {
        playNegativeFlashAnim = true;
        this.m_changeN_anim_proxy = inkWidgetRef.PlayAnimation(this.m_changeNBar, this.m_changeN_anim);
        this.m_empty_anim_proxy = inkWidgetRef.PlayAnimation(this.m_emptyBar, this.m_empty_anim);
      };
      if sizeF + sizeCP <= 0.00 {
        inkWidgetRef.SetSize(this.m_fullBar, new Vector2(this.m_width * sizeF, this.m_height));
        inkWidgetRef.SetSize(this.m_changePBar, new Vector2(this.m_width * sizeCP, this.m_height));
      };
      if sizeE + sizeCN <= 0.00 {
        inkWidgetRef.SetSize(this.m_changeNBar, new Vector2(this.m_width * sizeCN, this.m_height));
        inkWidgetRef.SetSize(this.m_emptyBar, new Vector2(this.m_width * sizeE, this.m_height));
      };
    };
    fullBarSize = inkWidgetRef.GetSize(this.m_fullBar);
    negativeMargin.left = fullBarSize.X;
    inkWidgetRef.SetMargin(this.m_changeNBar, negativeMargin);
    return playNegativeFlashAnim;
  }

  public final func GetFullSize() -> Vector2 {
    return new Vector2(this.m_width, this.m_height);
  }
}

public class NameplateBarLogicController extends ProgressBarSimpleWidgetLogicController {

  private let damagePreview: wref<DamagePreviewController>;

  public final func SetNameplateBarProgress(newValue: Float, silent: Bool) -> Void {
    let playNegativeFlashAnim: Bool = this.SetProgress(newValue, silent);
    if playNegativeFlashAnim {
      this.PlayLibraryAnimation(n"ProgressBar_Change_Flash");
    };
  }

  public final func SetDamagePreview(damage: Float, offset: Float) -> Void {
    if this.damagePreview == null {
      this.damagePreview = this.SpawnFromLocal(this.m_rootWidget, n"damagePreview").GetController() as DamagePreviewController;
    };
    this.damagePreview.SetPreview(damage, offset);
  }
}
