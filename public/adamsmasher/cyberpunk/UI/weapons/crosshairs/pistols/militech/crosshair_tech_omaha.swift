
public class Crosshair_Tech_Omaha extends gameuiCrosshairBaseGameController {

  private let m_leftPart: wref<inkWidget>;

  private let m_rightPart: wref<inkWidget>;

  private let m_topPart: wref<inkWidget>;

  private let m_chargeBar: wref<inkRectangle>;

  private let m_sizeOfChargeBar: Vector2;

  private let m_chargeBBID: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_leftPart = this.GetWidget(n"left");
    this.m_rightPart = this.GetWidget(n"right");
    this.m_topPart = this.GetWidget(n"top");
    this.m_chargeBar = this.GetWidget(n"chargeBar/chargeBarFG") as inkRectangle;
    this.m_sizeOfChargeBar = this.m_chargeBar.GetSize();
    this.m_rootWidget.SetOpacity(0.00);
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnPreIntro() -> Bool {
    super.OnPreIntro();
    if IsDefined(this.m_targetBB) {
      this.m_chargeBBID = this.m_targetBB.RegisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this, n"OnChargeChanged");
    };
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_targetBB) {
      this.m_targetBB.UnregisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this.m_chargeBBID);
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
    this.m_leftPart.SetMargin(new inkMargin(-spread.X, 0.00, 0.00, 0.00));
    this.m_rightPart.SetMargin(new inkMargin(spread.X, 0.00, 0.00, 0.00));
    this.m_topPart.SetMargin(new inkMargin(0.00, -spread.Y, 0.00, 0.00));
  }

  protected final func OnChargeChanged(charge: Float) -> Void {
    this.m_chargeBar.SetSize(new Vector2(MinF(this.m_sizeOfChargeBar.X, charge * 100.00), this.m_sizeOfChargeBar.Y));
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    this.m_leftPart.SetState(state);
    this.m_rightPart.SetState(state);
    this.m_topPart.SetState(state);
  }
}
