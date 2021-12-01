
public class Crosshair_Melee_Nano_Wire extends CrosshairGameController_Melee {

  private let m_animEnterADS: ref<inkAnimProxy>;

  private let m_inAimDownSight: Bool;

  private let m_isHoveringOfficer: Bool;

  private let m_inChargedHold: Bool;

  private let anim_EnterHipFire: ref<inkAnimProxy>;

  private let anim_HoverEnterEnemy: ref<inkAnimProxy>;

  private let anim_EnterStrongAttack: ref<inkAnimProxy>;

  private let anim_EnterThrowAttack: ref<inkAnimProxy>;

  private let anim_EnterEveryOtherAttack: ref<inkAnimProxy>;

  private let anim_EnterChargedHold: ref<inkAnimProxy>;

  private let anim_HoverExitEnemy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetOpacity(0.00);
    super.OnInitialize();
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

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    let aimedAtGameObject: wref<GameObject> = aimedAtEntity as GameObject;
    let puppet: wref<ScriptedPuppet> = aimedAtGameObject as ScriptedPuppet;
    this.m_isHoveringOfficer = Equals(puppet.GetPuppetRarity().Type(), gamedataNPCRarity.Officer);
    if Equals(state, n"Hostile") {
      if this.m_inAimDownSight && this.m_isHoveringOfficer {
        if !this.anim_HoverEnterEnemy.IsPlaying() {
          this.anim_HoverEnterEnemy = this.PlayLibraryAnimation(n"HoverEnterEnemy");
        };
      };
    } else {
      if !this.anim_HoverExitEnemy.IsPlaying() {
        this.anim_HoverExitEnemy = this.PlayLibraryAnimation(n"HoverExitEnemy");
      };
    };
    this.ApplyCrosshairGUIState(state, aimedAtEntity);
  }

  protected func OnMeleeState_Update(value: gamePSMMeleeWeapon) -> Void {
    if Equals(value, gamePSMMeleeWeapon.Idle) || Equals(value, gamePSMMeleeWeapon.Default) {
      if this.m_animEnterADS.IsPlaying() {
        this.m_animEnterADS.Stop();
      };
      if !this.anim_EnterHipFire.IsPlaying() {
        this.anim_EnterHipFire = this.PlayLibraryAnimation(n"EnterHipFire");
      };
    } else {
      if Equals(value, gamePSMMeleeWeapon.Targeting) {
        if !this.m_animEnterADS.IsPlaying() {
          this.m_animEnterADS = this.PlayLibraryAnimation(n"EnterAimDownSight");
        };
        if this.m_isHoveringOfficer {
          if !this.anim_HoverEnterEnemy.IsPlaying() {
            this.anim_HoverEnterEnemy = this.PlayLibraryAnimation(n"HoverEnterEnemy");
          };
        };
      } else {
        if Equals(value, gamePSMMeleeWeapon.StrongAttack) {
          if !this.anim_EnterStrongAttack.IsPlaying() {
            this.anim_EnterStrongAttack = this.PlayLibraryAnimation(n"EnterStrongAttack");
          };
        } else {
          if Equals(value, gamePSMMeleeWeapon.ThrowAttack) {
            if !this.anim_EnterThrowAttack.IsPlaying() {
              this.anim_EnterThrowAttack = this.PlayLibraryAnimation(n"EnterThrowAttack");
            };
          } else {
            if Equals(value, gamePSMMeleeWeapon.ComboAttack) || Equals(value, gamePSMMeleeWeapon.FinalAttack) || Equals(value, gamePSMMeleeWeapon.SafeAttack) || Equals(value, gamePSMMeleeWeapon.BlockAttack) || Equals(value, gamePSMMeleeWeapon.SprintAttack) || Equals(value, gamePSMMeleeWeapon.CrouchAttack) || Equals(value, gamePSMMeleeWeapon.JumpAttack) {
              if !this.anim_EnterEveryOtherAttack.IsPlaying() {
                this.anim_EnterEveryOtherAttack = this.PlayLibraryAnimation(n"EnterEveryOtherAttack");
              };
            } else {
              if Equals(value, gamePSMMeleeWeapon.ChargedHold) {
                this.m_inChargedHold = true;
                if !this.anim_EnterChargedHold.IsPlaying() {
                  this.anim_EnterChargedHold = this.PlayLibraryAnimation(n"EnterChargedHold");
                };
              } else {
                if this.m_inChargedHold && NotEquals(value, gamePSMMeleeWeapon.ChargedHold) {
                  this.m_inChargedHold = false;
                  if !this.anim_EnterHipFire.IsPlaying() {
                    this.anim_EnterHipFire = this.PlayLibraryAnimation(n"EnterHipFire");
                  };
                };
              };
            };
          };
        };
      };
    };
    this.m_inAimDownSight = Equals(value, gamePSMMeleeWeapon.Targeting);
    this.OnMeleeState_Update(value);
  }
}
