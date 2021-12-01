
public class CrosshairGameController_Melee extends gameuiCrosshairBaseMelee {

  private edit let m_targetColorChange: inkWidgetRef;

  private let m_chargeBar: wref<inkCanvas>;

  private let m_chargeBarFG: wref<inkRectangle>;

  private let m_chargeBarMonoTop: wref<inkImage>;

  private let m_chargeBarMonoBottom: wref<inkImage>;

  private let m_chargeBarMask: wref<inkMask>;

  private edit let m_chargeValueL: wref<inkText>;

  private edit let m_chargeValueR: wref<inkText>;

  private let m_bbcharge: Uint32;

  private let m_meleeResourcePoolListener: ref<MeleeResourcePoolListener>;

  private let m_weaponID: EntityID;

  private let m_displayChargeBar: Bool;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetOpacity(0.00);
    super.OnInitialize();
    this.m_chargeBar = this.GetWidget(n"chargeBar") as inkCanvas;
    this.m_chargeBarMask = this.GetWidget(n"chargeBar/overheat_mask") as inkMask;
    this.m_chargeBarFG = this.GetWidget(n"chargeBar/chargeBarFG") as inkRectangle;
    this.m_chargeBarMonoTop = this.GetWidget(n"5_hairlines/hair_top") as inkImage;
    this.m_chargeBarMonoBottom = this.GetWidget(n"5_hairlines/hair_bottom") as inkImage;
    this.m_chargeValueL = this.GetWidget(n"chargeBar/fluffL") as inkText;
    this.m_chargeValueR = this.GetWidget(n"chargeBar/fluffR") as inkText;
    super.OnInitialize();
  }

  protected cb func OnPreIntro() -> Bool {
    let chargePct: Float = 0.00;
    let weaponObject: ref<ItemObject> = this.GetWeaponItemObject();
    this.m_displayChargeBar = false;
    let playerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(playerObject.GetGame());
    if IsDefined(weaponObject) && IsDefined(statPoolsSystem) {
      this.m_weaponID = weaponObject.GetEntityID();
      if statPoolsSystem.IsStatPoolAdded(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge) {
        this.m_displayChargeBar = true;
        this.m_meleeResourcePoolListener = new MeleeResourcePoolListener();
        this.m_meleeResourcePoolListener.Bind(this);
        statPoolsSystem.RequestRegisteringListener(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge, this.m_meleeResourcePoolListener);
        chargePct = statPoolsSystem.GetStatPoolValue(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge);
        this.SetChargeScale(chargePct);
      };
    };
    this.m_chargeBar.SetVisible(this.m_displayChargeBar);
    super.OnPreIntro();
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_meleeResourcePoolListener) {
      GameInstance.GetStatPoolsSystem(this.GetPlayerControlledObject().GetGame()).RequestUnregisteringListener(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge, this.m_meleeResourcePoolListener);
      this.m_meleeResourcePoolListener = null;
    };
    super.OnPreOutro();
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    inkWidgetRef.SetState(this.m_targetColorChange, state);
  }

  public final func UpdateResourceValue(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.SetChargeScale(newValue);
  }

  public func SetChargeScale(pct: Float) -> Void {
    let scaleLerp: Float = pct / 100.00;
    scaleLerp = 1.00 - PowF(1.00 - scaleLerp, 0.66);
    let scale: Vector2 = new Vector2(1.00, scaleLerp);
    let scaleFG: Vector2 = new Vector2(scaleLerp, 1.00);
    this.m_chargeBarMask.SetScale(scale);
    this.m_chargeBarFG.SetScale(scaleFG);
    this.m_chargeBarMonoTop.SetScale(scale);
    this.m_chargeBarMonoBottom.SetScale(scale);
    this.m_chargeValueL.SetText(ToString(RoundF(pct)) + "%");
    this.m_chargeValueR.SetText(ToString(RoundF(pct)) + "%");
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_meleeResourcePoolListener) && IsDefined(this.GetPlayerControlledObject()) {
      GameInstance.GetStatPoolsSystem(this.GetPlayerControlledObject().GetGame()).RequestUnregisteringListener(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge, this.m_meleeResourcePoolListener);
      this.m_meleeResourcePoolListener = null;
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

  protected final func ShowCrosshairFromState(show: Bool) -> Void {
    this.m_chargeBar.SetVisible(show && this.m_displayChargeBar);
    this.GetRootWidget().SetOpacity(show ? 1.00 : 0.00);
  }

  protected func OnState_Safe() -> Void {
    this.ShowCrosshairFromState(true);
  }

  protected func OnState_Scanning() -> Void {
    this.ShowCrosshairFromState(false);
  }

  protected func OnState_GrenadeCharging() -> Void {
    this.ShowCrosshairFromState(false);
  }

  protected func OnState_HipFire() -> Void {
    this.ShowCrosshairFromState(true);
  }

  protected func OnState_Reload() -> Void {
    this.ShowCrosshairFromState(true);
  }

  protected func OnState_Aim() -> Void {
    this.ShowCrosshairFromState(true);
  }

  protected func OnState_Sprint() -> Void {
    this.ShowCrosshairFromState(true);
  }

  protected func OnState_LeftHandCyberware() -> Void {
    this.ShowCrosshairFromState(false);
  }
}

public class MeleeResourcePoolListener extends ScriptStatPoolsListener {

  private let m_meleeCrosshair: wref<CrosshairGameController_Melee>;

  public final func Bind(crosshair: wref<CrosshairGameController_Melee>) -> Void {
    this.m_meleeCrosshair = crosshair;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_meleeCrosshair.UpdateResourceValue(oldValue, newValue, percToPoints);
  }
}
