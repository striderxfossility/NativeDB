
public class Crosshair_Custom_HMG extends gameuiCrosshairBaseGameController {

  private edit let m_leftPart: inkWidgetRef;

  private edit let m_rightPart: inkWidgetRef;

  private edit let m_topPart: inkWidgetRef;

  private edit let m_bottomPart: inkWidgetRef;

  private edit let m_horiPart: inkWidgetRef;

  private edit let m_vertPart: inkWidgetRef;

  private edit let m_overheatContainer: inkWidgetRef;

  private edit let m_overheatWarning: inkWidgetRef;

  private edit let m_overheatMask: inkWidgetRef;

  private edit let m_overheatValueL: inkTextRef;

  private edit let m_overheatValueR: inkTextRef;

  private edit let m_leftPartExtra: inkImageRef;

  private edit let m_rightPartExtra: inkImageRef;

  private edit let m_crosshairContainer: inkCanvasRef;

  @default(Crosshair_Custom_HMG, .8)
  private let offsetLeftRight: Float;

  @default(Crosshair_Custom_HMG, 1.2)
  private let offsetLeftRightExtra: Float;

  @default(Crosshair_Custom_HMG, 40.0)
  private let latchVertical: Float;

  private let m_weaponLocalBB: wref<IBlackboard>;

  private let m_overheatBBID: ref<CallbackHandle>;

  private let m_forcedOverheatBBID: ref<CallbackHandle>;

  private edit let m_targetColorChange: inkWidgetRef;

  private let m_forcedCooldownProxy: ref<inkAnimProxy>;

  private let m_forcedCooldownOptions: inkAnimOptions;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetOpacity(0.00);
    inkWidgetRef.SetVisible(this.m_overheatContainer, false);
    inkWidgetRef.SetVisible(this.m_crosshairContainer, true);
    this.m_forcedCooldownOptions.loopType = inkanimLoopType.Cycle;
    this.m_forcedCooldownOptions.loopInfinite = true;
    super.OnInitialize();
  }

  protected cb func OnPreIntro() -> Bool {
    let isOverheating: Bool;
    let overheatPercentage: Float;
    let overheatValue: String;
    this.m_weaponLocalBB = this.GetWeaponLocalBlackboard();
    if IsDefined(this.m_weaponLocalBB) {
      this.m_overheatBBID = this.m_weaponLocalBB.RegisterDelayedListenerFloat(GetAllBlackboardDefs().Weapon.OverheatPercentage, this, n"OnOverheatChanged");
      overheatPercentage = this.m_weaponLocalBB.GetFloat(GetAllBlackboardDefs().Weapon.OverheatPercentage);
      overheatValue = ToString(RoundF(overheatPercentage)) + "%";
      inkTextRef.SetText(this.m_overheatValueL, overheatValue);
      inkTextRef.SetText(this.m_overheatValueR, overheatValue);
      this.m_forcedOverheatBBID = this.m_weaponLocalBB.RegisterDelayedListenerBool(GetAllBlackboardDefs().Weapon.IsInForcedOverheatCooldown, this, n"OnIsInForcedOverheatCooldown");
      isOverheating = this.m_weaponLocalBB.GetBool(GetAllBlackboardDefs().Weapon.IsInForcedOverheatCooldown);
      inkWidgetRef.SetVisible(this.m_overheatWarning, isOverheating);
      inkWidgetRef.SetVisible(this.m_crosshairContainer, !isOverheating);
      if isOverheating {
        this.m_forcedCooldownProxy = this.PlayLibraryAnimation(n"OverheatAnimation", this.m_forcedCooldownOptions);
      };
    };
    super.OnPreIntro();
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_weaponLocalBB) {
      this.m_weaponLocalBB.UnregisterDelayedListener(GetAllBlackboardDefs().Weapon.OverheatPercentage, this.m_overheatBBID);
      this.m_weaponLocalBB.UnregisterDelayedListener(GetAllBlackboardDefs().Weapon.IsInForcedOverheatCooldown, this.m_forcedOverheatBBID);
    };
    if this.m_forcedCooldownProxy.IsPlaying() {
      this.m_forcedCooldownProxy.Stop();
    };
    super.OnPreOutro();
  }

  public func GetIntroAnimation(firstEquip: Bool) -> ref<inkAnimDef> {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef>;
    this.PlayLibraryAnimation(n"PickUpWeapon");
    anim = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
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
    inkWidgetRef.SetSize(this.m_horiPart, spread.X, 3.00);
    inkWidgetRef.SetMargin(this.m_topPart, new inkMargin(0.00, -spread.Y, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_bottomPart, new inkMargin(0.00, spread.Y, 0.00, 0.00));
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    inkWidgetRef.SetState(this.m_targetColorChange, state);
  }

  protected cb func OnOverheatChanged(argValue: Float) -> Bool {
    argValue = argValue / 100.00;
    inkTextRef.SetText(this.m_overheatValueL, ToString(RoundF(100.00 * argValue)) + "%");
    inkTextRef.SetText(this.m_overheatValueR, ToString(RoundF(100.00 * argValue)) + "%");
    inkWidgetRef.SetVisible(this.m_overheatContainer, argValue > 0.01);
    inkWidgetRef.SetScale(this.m_overheatMask, new Vector2(1.00, argValue));
  }

  protected cb func OnIsInForcedOverheatCooldown(argValue: Bool) -> Bool {
    if argValue && !this.m_forcedCooldownProxy.IsPlaying() {
      this.m_forcedCooldownProxy = this.PlayLibraryAnimation(n"OverheatAnimation", this.m_forcedCooldownOptions);
      inkWidgetRef.SetVisible(this.m_overheatWarning, true);
      inkWidgetRef.SetVisible(this.m_crosshairContainer, false);
    } else {
      this.m_forcedCooldownProxy.Stop();
      inkWidgetRef.SetVisible(this.m_overheatWarning, false);
      inkWidgetRef.SetVisible(this.m_crosshairContainer, true);
    };
  }
}
