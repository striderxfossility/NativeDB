
public class CrosshairGameController_Launcher extends gameuiCrosshairBaseGameController {

  private let m_weaponBBID: ref<CallbackHandle>;

  private let m_animationProxy: ref<inkAnimProxy>;

  private edit let m_Cori_S: inkCanvasRef;

  private edit let m_Cori_M: inkCanvasRef;

  private let m_rightStickX: Float;

  private let m_rightStickY: Float;

  private let m_currentState: gamePSMLeftHandCyberware;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetOpacity(0.00);
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
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

  protected cb func OnPSMLeftHandCyberwareStateChanged(value: Int32) -> Bool {
    this.UpdateCrosshairState(IntEnum(value));
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let playerSMBB: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    this.m_weaponBBID = playerSMBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, this, n"OnPSMLeftHandCyberwareStateChanged");
    this.OnPSMLeftHandCyberwareStateChanged(playerSMBB.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware));
    this.OnPreIntro();
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    let playerSMBB: ref<IBlackboard>;
    if IsDefined(this.m_weaponBBID) {
      playerSMBB = this.GetPSMBlackboard(playerPuppet);
      playerSMBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, this.m_weaponBBID);
    };
  }

  private final func UpdateCrosshairState(state: gamePSMLeftHandCyberware) -> Void {
    if Equals(state, this.m_currentState) {
      return;
    };
    this.m_currentState = state;
    switch this.m_currentState {
      case gamePSMLeftHandCyberware.QuickAction:
        this.OnState_Equip();
        this.OnState_QuickLaunch();
        break;
      case gamePSMLeftHandCyberware.Charge:
        this.OnState_Equip();
        this.OnState_Aim();
        break;
      case gamePSMLeftHandCyberware.ChargeAction:
        this.OnState_Equip();
        this.OnState_ChargeLaunch();
        break;
      case gamePSMLeftHandCyberware.Safe:
        this.OnState_Safe();
        break;
      case gamePSMLeftHandCyberware.Unequip:
        this.OnState_Unequip();
        break;
      default:
    };
  }

  protected final func OnState_Equip() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.PlayLibraryAnimation(n"go_to_equip_state");
  }

  protected final func OnState_QuickLaunch() -> Void {
    this.PlayLibraryAnimation(n"go_to_quick_launch_state");
  }

  protected func OnState_Aim() -> Void {
    this.PlayLibraryAnimation(n"go_to_charge_state");
  }

  protected final func OnState_ChargeLaunch() -> Void {
    this.PlayLibraryAnimation(n"go_to_charge_launch_state");
  }

  protected final func OnState_Unequip() -> Void {
    this.m_rootWidget.SetVisible(false);
  }
}
