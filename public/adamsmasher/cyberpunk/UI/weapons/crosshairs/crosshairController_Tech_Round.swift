
public class CrosshairGameController_Tech_Round extends BaseTechCrosshairController {

  private let m_root: wref<inkWidget>;

  private edit let m_leftPart: inkImageRef;

  private edit let m_rightPart: inkImageRef;

  @default(CrosshairGameController_Tech_Round, .8)
  private let offsetLeftRight: Float;

  @default(CrosshairGameController_Tech_Round, 1.2)
  private let offsetLeftRightExtra: Float;

  @default(CrosshairGameController_Tech_Round, 40.0)
  private let latchVertical: Float;

  private edit let m_topPart: inkImageRef;

  private edit let m_bottomPart: inkImageRef;

  private edit let m_horiPart: inkWidgetRef;

  private edit let m_vertPart: inkWidgetRef;

  private let m_chargeBar: wref<inkCanvas>;

  private let m_chargeBarFG: wref<inkRectangle>;

  private let m_chargeBarBG: wref<inkRectangle>;

  private let m_chargeBarMG: wref<inkRectangle>;

  private let m_centerPart: wref<inkWidget>;

  private let m_bottom_hip_bar: wref<inkWidget>;

  private let m_realFluffText_1: wref<inkText>;

  private let m_realFluffText_2: wref<inkText>;

  private let m_bufferedSpread: Vector2;

  private let m_weaponlocalBB: wref<IBlackboard>;

  private let m_bbcharge: ref<CallbackHandle>;

  private let m_bbmagazineAmmoCapacity: ref<CallbackHandle>;

  private let m_bbmagazineAmmoCount: ref<CallbackHandle>;

  private let m_bbcurrentFireMode: ref<CallbackHandle>;

  @default(CrosshairGameController_Tech_Round, 2)
  private let m_currentAmmo: Int32;

  @default(CrosshairGameController_Tech_Round, 2)
  private let m_currentMaxAmmo: Int32;

  @default(CrosshairGameController_Tech_Round, 8)
  private let m_maxSupportedAmmo: Int32;

  private let m_currentFireMode: gamedataTriggerMode;

  private let m_orgSideSize: Vector2;

  private let m_sidesScale: Float;

  private let m_bbNPCStatsInfo: ref<CallbackHandle>;

  private let m_currentObstructedTargetBBID: ref<CallbackHandle>;

  private let m_potentialVisibleTarget: wref<GameObject>;

  private let m_potentialObstructedTarget: wref<GameObject>;

  @default(CrosshairGameController_Tech_Round, true)
  private let m_useVisibleTarget: Bool;

  @default(CrosshairGameController_Tech_Round, 0)
  public edit let m_horizontalMinSpread: Float;

  @default(CrosshairGameController_Tech_Round, 0)
  public edit let m_verticalMinSpread: Float;

  @default(CrosshairGameController_Tech_Round, 1)
  public edit let m_gameplaySpreadMultiplier: Float;

  public let m_chargeAnimationProxy: ref<inkAnimProxy>;

  private let spreadRA: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    if IsDefined(this.m_rootWidget) {
      this.m_rootWidget.SetOpacity(0.00);
    };
    this.m_chargeBar = this.GetWidget(n"chargeBar") as inkCanvas;
    this.m_chargeBarBG = this.GetWidget(n"chargeBar/chargeBarBG") as inkRectangle;
    this.m_chargeBarMG = this.GetWidget(n"chargeBar/chargeBarMG") as inkRectangle;
    this.m_chargeBarFG = this.GetWidget(n"chargeBar/chargeBarFG") as inkRectangle;
    this.m_bottom_hip_bar = this.GetWidget(n"bottom_hip_bar");
    this.m_realFluffText_1 = this.GetWidget(n"realFluffText_1") as inkText;
    this.m_realFluffText_2 = this.GetWidget(n"realFluffText_2") as inkText;
    this.m_orgSideSize = inkWidgetRef.GetSize(this.m_leftPart);
    this.m_sidesScale = 1.00;
    this.m_chargeBar.SetVisible(false);
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnPreIntro() -> Bool {
    let m_uiBlackboard: ref<IBlackboard>;
    super.OnPreIntro();
    this.GetRootWidget().SetOpacity(0.00);
    this.m_weaponlocalBB = this.GetWeaponLocalBlackboard();
    if IsDefined(this.m_targetBB) {
      this.m_currentObstructedTargetBBID = this.m_targetBB.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentObstructedTarget, this, n"OnCurrentObstructedTarget");
      this.OnCurrentObstructedTarget(this.m_targetBB.GetEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentObstructedTarget));
    };
    if IsDefined(this.m_weaponlocalBB) {
      this.m_bbcharge = this.m_weaponlocalBB.RegisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this, n"OnChargeChanged");
      this.m_bbmagazineAmmoCount = this.m_weaponlocalBB.RegisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount, this, n"OnAmmoCountChanged");
      this.m_bbmagazineAmmoCapacity = this.m_weaponlocalBB.RegisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCapacity, this, n"OnAmmoCapacityChanged");
      this.m_bbcurrentFireMode = this.m_weaponlocalBB.RegisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this, n"OnTriggerModeChanged");
    };
    m_uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair);
    if IsDefined(m_uiBlackboard) {
      this.m_bbNPCStatsInfo = m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.NameplateData, this, n"OnNPCStatsChanged");
    };
    this.OnChargeChanged(0.00);
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_targetBB) {
      this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.CurrentObstructedTarget, this.m_currentObstructedTargetBBID);
    };
    if IsDefined(this.m_weaponlocalBB) {
      this.m_weaponlocalBB.UnregisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this.m_bbcharge);
      this.m_weaponlocalBB.UnregisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount, this.m_bbmagazineAmmoCount);
      this.m_weaponlocalBB.UnregisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCapacity, this.m_bbmagazineAmmoCapacity);
      this.m_weaponlocalBB.UnregisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this.m_bbcurrentFireMode);
    };
    super.OnPreOutro();
  }

  protected final func OnTriggerModeChanged(value: Variant) -> Void {
    let record: ref<TriggerMode_Record> = FromVariant(value);
    this.m_currentFireMode = record.Type();
    if Equals(this.m_currentFireMode, gamedataTriggerMode.Charge) {
      this.m_chargeBar.SetVisible(true);
      this.m_bottom_hip_bar.SetVisible(false);
    } else {
      this.m_chargeBar.SetVisible(false);
      this.m_bottom_hip_bar.SetVisible(true);
    };
  }

  protected final func OnAmmoCountChanged(value: Uint32) -> Void {
    this.m_currentAmmo = Cast(value);
  }

  protected final func OnAmmoCapacityChanged(value: Uint32) -> Void {
    this.m_currentMaxAmmo = Cast(value);
  }

  protected final func OnChargeChanged(charge: Float) -> Void {
    let playbackOptions: inkAnimOptions;
    let actualMaxValue: Float = this.GetCurrentChargeLimit();
    this.m_chargeBar.SetVisible(charge > 0.00);
    this.m_bottom_hip_bar.SetVisible(charge > 0.00);
    this.m_realFluffText_1.SetVisible(charge > 0.00);
    this.m_realFluffText_2.SetVisible(charge > 0.00);
    this.m_chargeBarFG.SetSize(new Vector2(charge * 3.00, 6.00));
    this.m_chargeBarBG.SetSize(new Vector2(WeaponObject.GetBaseMaxChargeThreshold() * 3.00, 6.00));
    this.m_chargeBarMG.SetSize(new Vector2(WeaponObject.GetFullyChargedThreshold() * 3.00, 6.00));
    if charge >= actualMaxValue {
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
    inkWidgetRef.SetMargin(this.m_bottomPart, new inkMargin(0.00, this.spreadRA, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_leftPart, new inkMargin(-spread.X * this.offsetLeftRight, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_rightPart, new inkMargin(spread.X * this.offsetLeftRight, 0.00, 0.00, 0.00));
    inkWidgetRef.SetSize(this.m_vertPart, 3.00, spread.Y * 2.00 + this.latchVertical);
    inkWidgetRef.SetSize(this.m_horiPart, spread.X * 2.00, 3.00);
    inkWidgetRef.SetMargin(this.m_topPart, new inkMargin(0.00, -spread.Y, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_bottomPart, new inkMargin(0.00, spread.Y, 0.00, 0.00));
  }

  protected final func ColapseCrosshair(full: Bool, duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let marginInterpolator: ref<inkAnimMargin> = new inkAnimMargin();
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
    marginInterpolator.SetStartMargin(inkWidgetRef.GetMargin(this.m_bottomPart));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_bottomPart));
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_bottomPart, anim);
    anim = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_root.GetOpacity());
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    if IsDefined(this.m_centerPart) {
      this.m_centerPart.SetVisible(false);
    };
    if full {
      this.HideCenterPart(duration);
    };
    if IsDefined(this.m_chargeAnimationProxy) {
      this.m_chargeAnimationProxy.Stop();
    };
  }

  protected final func ExpandCrosshair(full: Bool, duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let marginInterpolator: ref<inkAnimMargin> = new inkAnimMargin();
    marginInterpolator.SetStartMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, SinF(20.00) * this.spreadRA, CosF(20.00) * this.spreadRA));
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
    marginInterpolator.SetEndMargin(new inkMargin(SinF(20.00) * this.spreadRA, 0.00, 0.00, CosF(20.00) * this.spreadRA));
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
    marginInterpolator.SetEndMargin(new inkMargin(0.00, this.spreadRA, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_bottomPart));
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    inkWidgetRef.PlayAnimation(this.m_bottomPart, anim);
    anim = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_root.GetOpacity());
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    if IsDefined(this.m_centerPart) {
      this.m_centerPart.SetVisible(true);
    };
    if full {
      this.ShowCenterPart(duration);
    };
    if IsDefined(this.m_chargeAnimationProxy) {
      this.m_chargeAnimationProxy.Stop();
    };
  }

  private final func ShowCenterPart(duration: Float) -> Void {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    if IsDefined(this.m_centerPart) {
      alphaInterpolator.SetStartTransparency(this.m_centerPart.GetOpacity());
    };
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    if IsDefined(this.m_centerPart) {
      this.m_centerPart.PlayAnimation(anim);
    };
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
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let sizeInterpolator: ref<inkAnimSize> = new inkAnimSize();
    sizeInterpolator.SetStartSize(new Vector2(this.m_orgSideSize.X / 2.00, this.m_orgSideSize.Y / 2.00));
    sizeInterpolator.SetEndSize(this.m_orgSideSize);
    sizeInterpolator.SetDuration(0.10);
    sizeInterpolator.SetType(inkanimInterpolationType.Linear);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(sizeInterpolator);
    inkWidgetRef.PlayAnimation(this.m_leftPart, anim);
    inkWidgetRef.PlayAnimation(this.m_rightPart, anim);
    inkWidgetRef.PlayAnimation(this.m_bottomPart, anim);
    this.ExpandCrosshair(true, 0.10);
  }

  protected func OnState_Aim() -> Void {
    this.ColapseCrosshair(false, 0.10);
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

  protected cb func OnCurrentAimTarget(entId: EntityID) -> Bool {
    this.m_potentialVisibleTarget = GameInstance.FindEntityByID(this.GetGame(), entId) as GameObject;
    this.OnTargetsChanged();
  }

  protected cb func OnCurrentObstructedTarget(entId: EntityID) -> Bool {
    this.m_potentialObstructedTarget = GameInstance.FindEntityByID(this.GetGame(), entId) as GameObject;
    this.OnTargetsChanged();
  }

  private final func OnTargetsChanged() -> Void {
    let newTarget: wref<GameObject>;
    let revealRequest: gameVisionModeSystemRevealIdentifier;
    revealRequest.sourceEntityId = this.GetOwnerEntity().GetEntityID();
    revealRequest.reason = n"TechWeapon";
    if IsDefined(this.m_potentialVisibleTarget) {
      newTarget = this.m_potentialVisibleTarget;
      this.m_useVisibleTarget = true;
    } else {
      if IsDefined(this.m_potentialObstructedTarget) && this.m_potentialObstructedTarget.HasRevealRequest(revealRequest) {
        newTarget = this.m_potentialObstructedTarget;
        this.m_useVisibleTarget = false;
      };
    };
    if newTarget != this.m_targetEntity {
      this.RegisterTargetCallbacks(false);
      this.m_targetEntity = newTarget;
      this.RegisterTargetCallbacks(true);
      this.UpdateCrosshairGUIState(true);
    };
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    this.m_root.SetState(state);
    inkWidgetRef.SetState(this.m_leftPart, state);
    inkWidgetRef.SetState(this.m_rightPart, state);
    inkWidgetRef.SetState(this.m_bottomPart, state);
    this.m_chargeBarBG.SetState(state);
    this.m_chargeBarFG.SetState(state);
  }

  protected func GetDistanceToTarget() -> Float {
    let distanceBBID: BlackboardID_Float;
    let targetBBID: BlackboardID_EntityID;
    let targetID: EntityID;
    let distance: Float = 0.00;
    if this.m_useVisibleTarget {
      targetBBID = GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget;
      distanceBBID = GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetDistance;
    } else {
      targetBBID = GetAllBlackboardDefs().UI_TargetingInfo.CurrentObstructedTarget;
      distanceBBID = GetAllBlackboardDefs().UI_TargetingInfo.ObstructedTargetDistance;
    };
    targetID = this.m_targetBB.GetEntityID(targetBBID);
    if EntityID.IsDefined(targetID) {
      distance = this.m_targetBB.GetFloat(distanceBBID);
    };
    return distance;
  }
}
