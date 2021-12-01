
public class CrosshairGameController_Simple extends gameuiCrosshairBaseGameController {

  private edit let m_leftPart: inkImageRef;

  private edit let m_rightPart: inkImageRef;

  private edit let m_leftPartExtra: inkImageRef;

  private edit let m_rightPartExtra: inkImageRef;

  @default(CrosshairGameController_Simple, .8)
  private let offsetLeftRight: Float;

  @default(CrosshairGameController_Simple, 1.2)
  private let offsetLeftRightExtra: Float;

  @default(CrosshairGameController_Simple, 40.0)
  private let latchVertical: Float;

  private edit let m_topPart: inkImageRef;

  private edit let m_bottomPart: inkImageRef;

  private edit let m_horiPart: inkWidgetRef;

  private edit let m_vertPart: inkWidgetRef;

  private edit let m_targetColorChange: inkWidgetRef;

  private edit let m_middlePart: inkWidgetRef;

  private edit let m_overheatShake: inkWidgetRef;

  private edit let m_overheatTL: inkWidgetRef;

  private edit let m_overheatBL: inkWidgetRef;

  private edit let m_overheatTR: inkWidgetRef;

  private edit let m_overheatBR: inkWidgetRef;

  private let m_weaponLocalBB: wref<IBlackboard>;

  private let m_onChargeChangeBBID: ref<CallbackHandle>;

  private let m_shakeAnimation: ref<inkAnimProxy>;

  private let m_isInForcedCool: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetOpacity(0.00);
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnPreIntro() -> Bool {
    this.m_weaponLocalBB = this.GetWeaponLocalBlackboard();
    if IsDefined(this.m_weaponLocalBB) {
      this.m_onChargeChangeBBID = this.m_weaponLocalBB.RegisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this, n"OnChargeChanged");
    };
    super.OnPreIntro();
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_weaponLocalBB) {
      this.m_weaponLocalBB.UnregisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this.m_onChargeChangeBBID);
    };
    super.OnPreOutro();
  }

  public func GetIntroAnimation(firstEquip: Bool) -> ref<inkAnimDef> {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(0.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(0.25);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    return anim;
  }

  public func GetOutroAnimation() -> ref<inkAnimDef> {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(0.25);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    return anim;
  }

  protected cb func OnBulletSpreadChanged(spread: Vector2) -> Bool {
    inkWidgetRef.SetMargin(this.m_leftPart, new inkMargin(-spread.X * this.offsetLeftRight, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_rightPart, new inkMargin(spread.X * this.offsetLeftRight, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_leftPartExtra, new inkMargin(-spread.X / 2.00, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_rightPartExtra, new inkMargin(spread.X / 2.00, 0.00, 0.00, 0.00));
    inkWidgetRef.SetSize(this.m_vertPart, 3.00, spread.Y * 2.00 + this.latchVertical);
    inkWidgetRef.SetSize(this.m_horiPart, spread.X * 2.00, 3.00);
    inkWidgetRef.SetMargin(this.m_topPart, new inkMargin(0.00, -spread.Y, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_bottomPart, new inkMargin(0.00, spread.Y, 0.00, 0.00));
  }

  protected cb func OnChargeChanged(argCharge: Float) -> Bool;

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    inkWidgetRef.SetState(this.m_targetColorChange, state);
  }

  protected func OnState_HipFire() -> Void {
    this.m_rootWidget.SetVisible(true);
  }

  protected func OnState_Aim() -> Void {
    this.m_rootWidget.SetVisible(false);
  }
}
