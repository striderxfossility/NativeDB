
public class CrosshairGameController_Tech_Hex extends BaseTechCrosshairController {

  private let m_leftBracket: wref<inkImage>;

  private let m_rightBracket: wref<inkImage>;

  private let m_hori: wref<inkWidget>;

  private let m_chargeBar: wref<inkWidget>;

  private let m_ammoLeft: wref<inkWidget>;

  private let m_ammoRight: wref<inkWidget>;

  private let m_ammoLeftFill: wref<inkWidget>;

  private let m_ammoRightFill: wref<inkWidget>;

  private let m_chargeBoth: wref<inkWidget>;

  private let m_chargeLeftBar: wref<inkRectangle>;

  private let m_chargeRightBar: wref<inkRectangle>;

  private let m_centerPart: wref<inkImage>;

  private let m_fluffCanvas: wref<inkWidget>;

  public let m_chargeAnimationProxy: ref<inkAnimProxy>;

  private let m_bufferedSpread: Vector2;

  private let m_weaponlocalBB: wref<IBlackboard>;

  private let m_bbcharge: ref<CallbackHandle>;

  private let m_bbmagazineAmmoCount: ref<CallbackHandle>;

  private let m_bbcurrentFireMode: ref<CallbackHandle>;

  @default(CrosshairGameController_Tech_Hex, 2)
  private let m_currentAmmo: Int32;

  @default(CrosshairGameController_Tech_Hex, 2)
  private let m_currentMaxAmmo: Int32;

  @default(CrosshairGameController_Tech_Hex, 8)
  private let m_maxSupportedAmmo: Int32;

  private let m_currentFireMode: gamedataTriggerMode;

  private let m_bbNPCStatsInfo: ref<CallbackHandle>;

  @default(CrosshairGameController_Tech_Hex, 0)
  public edit let m_horizontalMinSpread: Float;

  @default(CrosshairGameController_Tech_Hex, 0)
  public edit let m_verticalMinSpread: Float;

  @default(CrosshairGameController_Tech_Hex, 1)
  public edit let m_gameplaySpreadMultiplier: Float;

  private let m_charge: Float;

  private let m_spread: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_leftBracket = this.GetWidget(n"left") as inkImage;
    this.m_rightBracket = this.GetWidget(n"right") as inkImage;
    this.m_hori = this.GetWidget(n"hori");
    this.m_chargeBar = this.GetWidget(n"fg");
    this.m_centerPart = this.GetWidget(n"center") as inkImage;
    this.m_ammoLeft = this.GetWidget(n"ammoLeft");
    this.m_ammoRight = this.GetWidget(n"ammoRight");
    this.m_ammoLeftFill = this.GetWidget(n"ammoLeft/ammoFull");
    this.m_ammoRightFill = this.GetWidget(n"ammoRight/ammoFull");
    this.m_chargeBoth = this.GetWidget(n"chargeBars");
    this.m_chargeLeftBar = this.GetWidget(n"chargeBars/leftBar/leftBarFG") as inkRectangle;
    this.m_chargeRightBar = this.GetWidget(n"chargeBars/rightBar/rightBarFG") as inkRectangle;
    this.m_fluffCanvas = this.GetWidget(n"fluffCanvas");
    this.m_leftBracket.SetMargin(new inkMargin(-(this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X), 0.00, 0.00, 0.00));
    this.m_rightBracket.SetMargin(new inkMargin(this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X, 0.00, 0.00, 0.00));
    this.m_hori.SetSize((this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X) * 2.00 + 64.00, 1.00);
    super.OnInitialize();
    this.m_charge = 0.00;
    this.m_spread = 0.00;
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnPreIntro() -> Bool {
    let m_uiBlackboard: ref<IBlackboard>;
    this.m_weaponlocalBB = this.GetWeaponLocalBlackboard();
    if IsDefined(this.m_weaponlocalBB) {
      this.m_bbcharge = this.m_weaponlocalBB.RegisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this, n"OnChargeChanged");
      this.m_bbmagazineAmmoCount = this.m_weaponlocalBB.RegisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount, this, n"OnAmmoCountChanged");
      this.m_bbcurrentFireMode = this.m_weaponlocalBB.RegisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this, n"OnTriggerModeChanged");
      this.m_weaponlocalBB.SignalUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount);
    };
    m_uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair);
    if IsDefined(m_uiBlackboard) {
      this.m_bbNPCStatsInfo = m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.NameplateData, this, n"OnNPCStatsChanged");
    };
    this.OnChargeChanged(0.00);
    super.OnPreIntro();
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_weaponlocalBB) {
      this.m_weaponlocalBB.UnregisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this.m_bbcharge);
      this.m_weaponlocalBB.UnregisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount, this.m_bbmagazineAmmoCount);
      this.m_weaponlocalBB.UnregisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this.m_bbcurrentFireMode);
    };
    super.OnPreOutro();
  }

  protected final func OnTriggerModeChanged(value: Variant) -> Void {
    let record: ref<TriggerMode_Record> = FromVariant(value);
    this.m_currentFireMode = record.Type();
    this.m_chargeBoth.SetVisible(Equals(this.m_currentFireMode, gamedataTriggerMode.Charge));
    this.m_ammoRight.SetVisible(NotEquals(this.m_currentFireMode, gamedataTriggerMode.Charge));
    this.m_ammoLeft.SetVisible(NotEquals(this.m_currentFireMode, gamedataTriggerMode.Charge));
  }

  protected final func OnAmmoCountChanged(value: Uint32) -> Void {
    this.m_currentAmmo = Cast(value);
    this.m_ammoRightFill.SetVisible(this.m_currentAmmo >= 1);
    this.m_ammoLeftFill.SetVisible(this.m_currentAmmo >= 2);
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
    this.m_bufferedSpread = spread;
    this.UpdateSpread();
  }

  protected final func OnChargeChanged(chargeValue: Float) -> Void {
    let playbackOptions: inkAnimOptions;
    let actualMaxValue: Float = this.GetCurrentChargeLimit();
    let chargeOffset: Float = 0.92;
    this.m_chargeLeftBar.SetSize(new Vector2(MinF(108.00, (chargeValue * 108.00) / chargeOffset), 10.00));
    this.m_chargeRightBar.SetSize(new Vector2(MinF(108.00, (chargeValue * 108.00) / chargeOffset), 10.00));
    if chargeValue >= actualMaxValue {
      if !IsDefined(this.m_chargeAnimationProxy) {
        playbackOptions.loopInfinite = true;
        playbackOptions.loopType = inkanimLoopType.Cycle;
        this.m_chargeAnimationProxy = this.PlayLibraryAnimation(n"chargeMax", playbackOptions);
      };
    } else {
      if IsDefined(this.m_chargeAnimationProxy) {
        this.m_chargeAnimationProxy.Stop();
        this.m_chargeAnimationProxy = null;
      };
    };
    this.m_charge = chargeValue / this.GetCurrentChargeLimit();
    this.UpdateChargeBar();
  }

  private final func UpdateSpread() -> Void {
    this.m_leftBracket.SetMargin(new inkMargin(-(this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X), 0.00, 0.00, 0.00));
    this.m_rightBracket.SetMargin(new inkMargin(this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X, 0.00, 0.00, 0.00));
    this.m_hori.SetSize((this.m_horizontalMinSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X) * 2.00 + 64.00, 3.00);
    this.UpdateChargeBar();
  }

  private final func UpdateChargeBar() -> Void {
    let baseSize: Vector2 = this.m_hori.GetSize();
    this.m_chargeBar.SetSize(baseSize.X * this.m_charge, baseSize.Y);
  }

  protected final func CollapseCrosshair(duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef>;
    let marginInterpolator: ref<inkAnimMargin>;
    let sizeInterpolator: ref<inkAnimSize>;
    if IsDefined(this.m_chargeAnimationProxy) {
      this.m_chargeAnimationProxy.Stop();
    };
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(this.m_leftBracket.GetMargin());
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    this.m_leftBracket.PlayAnimation(anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(this.m_rightBracket.GetMargin());
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    this.m_rightBracket.PlayAnimation(anim);
    anim = new inkAnimDef();
    sizeInterpolator = new inkAnimSize();
    sizeInterpolator.SetStartSize(this.m_hori.GetSize());
    sizeInterpolator.SetEndSize(new Vector2(0.00, 0.00));
    sizeInterpolator.SetDuration(duration);
    sizeInterpolator.SetType(inkanimInterpolationType.Linear);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(sizeInterpolator);
    this.m_hori.PlayAnimation(anim);
    anim = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_rootWidget.PlayAnimation(anim);
  }

  protected final func ExpandCrosshair(duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef>;
    if IsDefined(this.m_chargeAnimationProxy) {
      this.m_chargeAnimationProxy.Stop();
    };
    anim = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(0.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_rootWidget.PlayAnimation(anim);
  }

  private final func ShowCenterPart(duration: Float) -> Void {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_centerPart.GetOpacity());
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_centerPart.PlayAnimation(anim);
  }

  private final func HideCenterPart(duration: Float) -> Void {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_centerPart.GetOpacity());
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_centerPart.PlayAnimation(anim);
  }

  private final func OnShow() -> Void {
    switch this.GetCrosshairState() {
      case gamePSMCrosshairStates.Safe:
        this.ShowCenterPart(0.25);
        break;
      default:
        this.ExpandCrosshair(0.25);
    };
  }

  private final func OnHide() -> Void {
    switch this.GetCrosshairState() {
      case gamePSMCrosshairStates.Safe:
        this.HideCenterPart(0.25);
        break;
      default:
        this.CollapseCrosshair(0.25);
    };
  }

  protected func OnState_Safe() -> Void {
    this.CollapseCrosshair(0.10);
  }

  protected func OnState_HipFire() -> Void {
    this.m_leftBracket.StopAllAnimations();
    this.m_rightBracket.StopAllAnimations();
    this.m_hori.StopAllAnimations();
    this.ExpandCrosshair(0.10);
    this.UpdateSpread();
  }

  protected func OnState_Aim() -> Void {
    this.CollapseCrosshair(0.10);
    this.UpdateSpread();
  }

  protected func OnState_Reload() -> Void {
    this.CollapseCrosshair(0.25);
  }

  protected func OnState_Sprint() -> Void {
    this.CollapseCrosshair(0.10);
  }

  protected func OnState_GrenadeCharging() -> Void {
    this.CollapseCrosshair(0.10);
  }

  protected func OnState_Scanning() -> Void {
    this.CollapseCrosshair(0.10);
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    this.m_rootWidget.SetState(state);
  }
}
