
public class CrosshairGameController_NoWeapon extends gameuiCrosshairBaseGameController {

  private edit let m_AimDownSightContainer: inkCompoundRef;

  private edit let m_ZoomMovingContainer: inkCompoundRef;

  private edit let m_ZoomNumber: inkTextRef;

  private edit let m_ZoomNumberR: inkTextRef;

  private edit let m_DistanceImageRuler: inkImageRef;

  private edit let m_ZoomMoveBracketL: inkImageRef;

  private edit let m_ZoomMoveBracketR: inkImageRef;

  private let m_ZoomLevelString: String;

  private let m_PlayerSMBB: wref<IBlackboard>;

  private let m_ZoomLevelBBID: ref<CallbackHandle>;

  private let m_sceneTierBlackboardId: ref<CallbackHandle>;

  @default(CrosshairGameController_NoWeapon, gamePSMHighLevel.Default)
  private let m_sceneTier: gamePSMHighLevel;

  private let zoomUpAnim: ref<inkAnimProxy>;

  private let animLockOn: ref<inkAnimProxy>;

  private let zoomDownAnim: ref<inkAnimProxy>;

  private let animLockOff: ref<inkAnimProxy>;

  private let zoomShowAnim: ref<inkAnimProxy>;

  private let zoomHideAnim: ref<inkAnimProxy>;

  private let argZoomBuffered: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    inkWidgetRef.SetVisible(this.m_AimDownSightContainer, false);
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_PlayerSMBB = this.GetPSMBlackboard(playerPuppet);
    this.m_ZoomLevelBBID = this.m_PlayerSMBB.RegisterDelayedListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnZoomLevel");
    this.m_sceneTierBlackboardId = this.m_PlayerSMBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier, this, n"OnPSMSceneTierChanged");
    super.OnPlayerAttach(playerPuppet);
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_PlayerSMBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_ZoomLevelBBID);
    this.m_PlayerSMBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.SceneTier, this.m_sceneTierBlackboardId);
    super.OnPlayerDetach(playerPuppet);
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

  protected func OnState_HipFire() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.zoomHideAnim = this.PlayLibraryAnimation(n"hide");
    inkWidgetRef.SetVisible(this.m_AimDownSightContainer, false);
  }

  protected func OnState_Aim() -> Void {
    inkWidgetRef.SetVisible(this.m_AimDownSightContainer, true);
    this.zoomShowAnim = this.PlayLibraryAnimation(n"show");
  }

  protected func OnState_Sprint() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_Scanning() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_Safe() -> Void {
    this.m_rootWidget.SetVisible(Equals(this.m_sceneTier, gamePSMHighLevel.Default) || Equals(this.m_sceneTier, gamePSMHighLevel.SceneTier1) || Equals(this.m_sceneTier, gamePSMHighLevel.SceneTier2));
  }

  protected cb func OnZoomLevel(argZoom: Float) -> Bool {
    let distanceVector: Vector2 = inkWidgetRef.GetDesiredSize(this.m_DistanceImageRuler);
    let distanceMargin: inkMargin = inkWidgetRef.GetMargin(this.m_DistanceImageRuler);
    let origRulerSize: Float = distanceVector.Y + distanceMargin.bottom;
    let pixelsFromBottom: Float = argZoom == 1.00 ? 0.00 : (argZoom * origRulerSize) / 4.00;
    inkWidgetRef.SetMargin(this.m_ZoomMovingContainer, new inkMargin(0.00, 0.00, 0.00, MinF(origRulerSize, pixelsFromBottom)));
    if argZoom * 2.00 > 2.00 {
      inkTextRef.SetText(this.m_ZoomNumber, FloatToStringPrec(MaxF(1.00, argZoom * 2.00), 1) + "x");
      inkTextRef.SetText(this.m_ZoomNumberR, FloatToStringPrec(MaxF(1.00, argZoom * 2.00), 1) + "x");
    } else {
      inkTextRef.SetText(this.m_ZoomNumber, FloatToStringPrec(MaxF(1.00, argZoom * 2.00 - 1.00), 1) + "x");
      inkTextRef.SetText(this.m_ZoomNumberR, FloatToStringPrec(MaxF(1.00, argZoom * 2.00 - 1.00), 1) + "x");
    };
    inkWidgetRef.SetMargin(this.m_ZoomMoveBracketL, new inkMargin(0.00, 0.00, 560.00 - argZoom * 60.00, 0.00));
    inkWidgetRef.SetMargin(this.m_ZoomMoveBracketR, new inkMargin(560.00 - argZoom * 60.00, 0.00, 0.00, 0.00));
    if argZoom < this.argZoomBuffered {
      if (!IsDefined(this.zoomDownAnim) || !this.zoomDownAnim.IsPlaying()) && (!IsDefined(this.zoomUpAnim) || !this.zoomUpAnim.IsPlaying()) && !this.zoomShowAnim.IsPlaying() {
        this.zoomDownAnim = this.PlayLibraryAnimation(n"zoomDown");
      };
    };
    if argZoom > this.argZoomBuffered {
      if (!IsDefined(this.zoomDownAnim) || !this.zoomDownAnim.IsPlaying()) && (!IsDefined(this.zoomUpAnim) || !this.zoomUpAnim.IsPlaying()) && !this.zoomHideAnim.IsPlaying() {
        this.zoomUpAnim = this.PlayLibraryAnimation(n"zoomUp");
      };
    };
    this.argZoomBuffered = argZoom;
  }

  protected cb func OnPSMSceneTierChanged(value: Int32) -> Bool {
    let tier: gamePSMHighLevel = IntEnum(value);
    if NotEquals(tier, this.m_sceneTier) {
      this.m_sceneTier = tier;
      this.UpdateCrosshairState();
    };
  }
}
