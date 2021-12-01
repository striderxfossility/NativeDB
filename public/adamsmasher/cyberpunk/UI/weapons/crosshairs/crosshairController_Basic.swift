
public class CrosshairGameController_Basic extends gameuiCrosshairBaseGameController {

  private edit let m_leftPart: inkImageRef;

  private edit let m_rightPart: inkImageRef;

  private edit let m_upPart: inkImageRef;

  private edit let m_downPart: inkImageRef;

  private edit let m_centerPart: inkImageRef;

  private let m_bufferedSpread: Vector2;

  private let m_currentFireMode: gamedataTriggerMode;

  private let m_weaponlocalBB: wref<IBlackboard>;

  private let m_bbcurrentFireMode: ref<CallbackHandle>;

  private let m_ricochetModeActive: Uint32;

  private let m_RicochetChance: Uint32;

  @default(CrosshairGameController_Basic, 20)
  public edit let m_horizontalMinSpread: Float;

  @default(CrosshairGameController_Basic, 20)
  public edit let m_verticalMinSpread: Float;

  @default(CrosshairGameController_Basic, 1)
  public edit let m_gameplaySpreadMultiplier: Float;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnPreIntro() -> Bool {
    this.GetRootWidget().SetOpacity(0.00);
    this.m_weaponlocalBB = this.GetWeaponLocalBlackboard();
    this.m_bbcurrentFireMode = this.m_weaponlocalBB.RegisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this, n"OnTriggerModeChanged");
    this.m_currentFireMode = gamedataTriggerMode.Invalid;
    super.OnPreIntro();
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_weaponlocalBB) {
      this.m_weaponlocalBB.UnregisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this.m_bbcurrentFireMode);
    };
    super.OnPreOutro();
  }

  protected final func OnTriggerModeChanged(value: Variant) -> Void {
    let anim: ref<inkAnimDef>;
    let rotationInterpolator: ref<inkAnimRotation>;
    let record: ref<TriggerMode_Record> = FromVariant(value);
    let previousFireMode: gamedataTriggerMode = this.m_currentFireMode;
    this.m_currentFireMode = record.Type();
    if Equals(this.m_currentFireMode, gamedataTriggerMode.Burst) {
      anim = new inkAnimDef();
      rotationInterpolator = new inkAnimRotation();
      rotationInterpolator.SetStartRotation(0.00);
      rotationInterpolator.SetEndRotation(-90.00);
      rotationInterpolator.SetDuration(0.10);
      rotationInterpolator.SetType(inkanimInterpolationType.Linear);
      rotationInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      anim.AddInterpolator(rotationInterpolator);
      this.GetRootWidget().PlayAnimation(anim);
    } else {
      if Equals(previousFireMode, gamedataTriggerMode.Burst) {
        anim = new inkAnimDef();
        rotationInterpolator = new inkAnimRotation();
        rotationInterpolator.SetStartRotation(-90.00);
        rotationInterpolator.SetEndRotation(0.00);
        rotationInterpolator.SetDuration(0.10);
        rotationInterpolator.SetType(inkanimInterpolationType.Linear);
        rotationInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
        anim.AddInterpolator(rotationInterpolator);
        this.GetRootWidget().PlayAnimation(anim);
      };
    };
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
    this.OnShow();
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
    this.OnHide();
    return anim;
  }

  protected cb func OnBulletSpreadChanged(spread: Vector2) -> Bool {
    inkWidgetRef.SetMargin(this.m_leftPart, new inkMargin(-(this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * spread.X), 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_rightPart, new inkMargin(this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * spread.X, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_upPart, new inkMargin(0.00, -(this.m_verticalMinSpread + this.m_gameplaySpreadMultiplier * spread.Y), 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_downPart, new inkMargin(0.00, this.m_verticalMinSpread + this.m_gameplaySpreadMultiplier * spread.Y, 0.00, 0.00));
    this.m_bufferedSpread = spread;
  }

  protected final func ColapseCrosshair(full: Bool, duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef>;
    let marginInterpolator: ref<inkAnimMargin>;
    inkWidgetRef.StopAllAnimations(this.m_leftPart);
    inkWidgetRef.StopAllAnimations(this.m_rightPart);
    inkWidgetRef.StopAllAnimations(this.m_upPart);
    inkWidgetRef.StopAllAnimations(this.m_downPart);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(inkWidgetRef.GetMargin(this.m_leftPart));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_leftPart));
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_leftPart, anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(inkWidgetRef.GetMargin(this.m_rightPart));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_rightPart));
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_rightPart, anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(inkWidgetRef.GetMargin(this.m_upPart));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_upPart));
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_upPart, anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(inkWidgetRef.GetMargin(this.m_downPart));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_downPart));
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_downPart, anim);
    if full {
      this.HideCenterPart(duration);
    };
  }

  protected final func ExpandCrosshair(full: Bool, duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef>;
    let marginInterpolator: ref<inkAnimMargin>;
    inkWidgetRef.StopAllAnimations(this.m_leftPart);
    inkWidgetRef.StopAllAnimations(this.m_rightPart);
    inkWidgetRef.StopAllAnimations(this.m_upPart);
    inkWidgetRef.StopAllAnimations(this.m_downPart);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetEndMargin(new inkMargin(-this.m_horizontalMinSpread - this.m_bufferedSpread.X * this.m_gameplaySpreadMultiplier, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_leftPart));
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_leftPart, anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetEndMargin(new inkMargin(this.m_horizontalMinSpread + this.m_bufferedSpread.X * this.m_gameplaySpreadMultiplier, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_rightPart));
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_rightPart, anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, -this.m_verticalMinSpread - this.m_bufferedSpread.Y * this.m_gameplaySpreadMultiplier, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_upPart));
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_upPart, anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, this.m_verticalMinSpread + this.m_bufferedSpread.Y * this.m_gameplaySpreadMultiplier, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_downPart));
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_downPart, anim);
    if full {
      this.ShowCenterPart(duration);
    };
  }

  private final func ShowCenterPart(duration: Float) -> Void {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_centerPart));
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_centerPart, anim);
  }

  private final func HideCenterPart(duration: Float) -> Void {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_centerPart));
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_centerPart, anim);
  }

  private final func OnShow() -> Void {
    switch this.GetCrosshairState() {
      case gamePSMCrosshairStates.Safe:
        this.ShowCenterPart(0.25);
        break;
      default:
        this.ExpandCrosshair(true, 0.25);
    };
  }

  private final func OnHide() -> Void {
    switch this.GetCrosshairState() {
      case gamePSMCrosshairStates.Safe:
        this.HideCenterPart(0.25);
        break;
      default:
        this.ColapseCrosshair(true, 0.25);
    };
  }

  protected func OnState_Safe() -> Void {
    this.ColapseCrosshair(false, 0.10);
  }

  protected func OnState_HipFire() -> Void {
    this.ExpandCrosshair(true, 0.10);
  }

  protected func OnState_Aim() -> Void {
    this.ColapseCrosshair(true, 0.10);
  }

  protected func OnState_Reload() -> Void {
    this.ColapseCrosshair(false, 0.25);
  }

  protected func OnState_Sprint() -> Void {
    this.ColapseCrosshair(false, 0.10);
  }

  protected func OnState_GrenadeCharging() -> Void {
    this.ColapseCrosshair(false, 0.10);
  }

  protected func OnState_Scanning() -> Void {
    this.ColapseCrosshair(true, 0.10);
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    inkWidgetRef.SetState(this.m_leftPart, state);
    inkWidgetRef.SetState(this.m_rightPart, state);
    inkWidgetRef.SetState(this.m_upPart, state);
    inkWidgetRef.SetState(this.m_downPart, state);
  }
}
