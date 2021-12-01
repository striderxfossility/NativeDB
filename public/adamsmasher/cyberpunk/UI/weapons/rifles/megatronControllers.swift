
public class megatronModeInfoController extends TriggerModeLogicController {

  private let m_ammoBarVisibility: wref<inkWidget>;

  private let m_chargeBarVisibility: wref<inkWidget>;

  private let m_fullAutoModeText: wref<inkWidget>;

  private let m_chargeModeText: wref<inkWidget>;

  private let m_fullAutoModeBG: wref<inkWidget>;

  private let m_chargeModeBG: wref<inkWidget>;

  private let m_bg1: wref<inkWidget>;

  private let m_bg2: wref<inkWidget>;

  private let m_vignette: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_fullAutoModeText = this.GetWidget(n"FullAutoModeText");
    this.m_chargeModeText = this.GetWidget(n"ChargeModeText");
    this.m_fullAutoModeBG = this.GetWidget(n"FullAutoModeBG");
    this.m_chargeModeBG = this.GetWidget(n"ChargeModeBG");
    this.m_ammoBarVisibility = this.GetWidget(n"ammoController/ammoBar");
    this.m_chargeBarVisibility = this.GetWidget(n"chargeController/chargeBar");
    this.m_bg1 = this.GetWidget(n"bg1");
    this.m_bg2 = this.GetWidget(n"bg2");
    this.m_vignette = this.GetWidget(n"vignette");
  }

  public func OnTriggerModeChanged(value: ref<TriggerMode_Record>) -> Void {
    let red: Color = new Color(255u, 122u, 131u, 255u);
    let blue: Color = new Color(127u, 226u, 215u, 255u);
    let isChargeMode: Bool = Equals(value.Type(), gamedataTriggerMode.Charge);
    this.m_chargeModeBG.SetVisible(isChargeMode);
    this.m_fullAutoModeBG.SetVisible(!isChargeMode);
    this.m_chargeBarVisibility.SetVisible(isChargeMode);
    this.m_ammoBarVisibility.SetVisible(!isChargeMode);
    this.m_bg1.SetTintColor(isChargeMode ? red : blue);
    this.m_bg2.SetTintColor(isChargeMode ? red : blue);
    this.m_vignette.SetTintColor(isChargeMode ? red : blue);
    this.m_chargeModeText.SetTintColor(isChargeMode ? new Color(0u, 0u, 0u, 255u) : blue);
    this.m_fullAutoModeText.SetTintColor(isChargeMode ? blue : new Color(0u, 0u, 0u, 255u));
  }
}

public class megatronFullAutoController extends AmmoLogicController {

  private let m_ammoCountText: wref<inkText>;

  private let m_ammoBar: wref<inkImage>;

  protected cb func OnInitialize() -> Bool {
    this.m_ammoCountText = this.GetWidget(n"ammoCountText") as inkText;
    this.m_ammoBar = this.GetWidget(n"ammoBar") as inkImage;
  }

  public func OnMagazineAmmoCountChanged(value: Uint32) -> Void {
    this.OnMagazineAmmoCountChanged(value);
    this.UpdateAmmoCount(value);
  }

  public func OnMagazineAmmoCapacityChanged(value: Uint32) -> Void {
    this.OnMagazineAmmoCapacityChanged(value);
    this.UpdateAmmoCount(value);
  }

  private final func UpdateAmmoCount(value: Uint32) -> Void {
    let fractionValue: Int32 = FloorF(Cast(this.m_count) / Cast(this.m_capacity) * 16.00);
    let texturePath: CName = StringToName("bar_" + IntToString(fractionValue));
    this.m_ammoBar.SetTexturePart(texturePath);
    if value < 10u {
      this.m_ammoCountText.SetText("0" + ToString(value));
    } else {
      this.m_ammoCountText.SetText(ToString(value));
    };
  }
}

public class megatronChargeController extends ChargeLogicController {

  private let m_chargeBar: wref<inkImage>;

  protected cb func OnInitialize() -> Bool {
    this.m_chargeBar = this.GetWidget(n"chargeBar") as inkImage;
  }

  public func OnChargeChanged(value: Float) -> Void {
    this.m_chargeBar.SetSize(new Vector2(57.00, value * 218.00));
  }
}

public class megatronCrosshairGameController extends inkGameController {

  private let m_bulletSpreedBlackboardId: ref<CallbackHandle>;

  private let m_crosshairStateBlackboardId: ref<CallbackHandle>;

  private let m_leftPart: wref<inkImage>;

  private let m_rightPart: wref<inkImage>;

  private let m_nearCenterPart: wref<inkImage>;

  private let m_farCenterPart: wref<inkImage>;

  private let m_bufferedSpread: Vector2;

  private let m_orgSideSize: Vector2;

  @default(megatronCrosshairGameController, 120)
  public edit let m_minSpread: Float;

  @default(megatronCrosshairGameController, 1)
  public edit let m_gameplaySpreadMultiplier: Float;

  private let m_crosshairState: gamePSMCrosshairStates;

  protected cb func OnInitialize() -> Bool {
    let weaponBB: ref<IBlackboard>;
    this.m_leftPart = this.GetWidget(n"Panel/NearPlane/left") as inkImage;
    this.m_rightPart = this.GetWidget(n"Panel/NearPlane/right") as inkImage;
    this.m_nearCenterPart = this.GetWidget(n"Panel/NearPlane/center") as inkImage;
    this.m_farCenterPart = this.GetWidget(n"Panel/FarPlane/center") as inkImage;
    this.m_leftPart.SetMargin(new inkMargin(-(this.m_minSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X), 0.00, 0.00, 0.00));
    this.m_rightPart.SetMargin(new inkMargin(this.m_minSpread + this.m_gameplaySpreadMultiplier * this.m_bufferedSpread.X, 0.00, 0.00, 0.00));
    this.m_orgSideSize = this.m_leftPart.GetSize();
    weaponBB = this.GetUIActiveWeaponBlackboard();
    this.m_bulletSpreedBlackboardId = weaponBB.RegisterListenerVector2(GetAllBlackboardDefs().UI_ActiveWeaponData.BulletSpread, this, n"OnBulletSpreadChanged");
    this.OnBulletSpreadChanged(weaponBB.GetVector2(GetAllBlackboardDefs().UI_ActiveWeaponData.BulletSpread));
    this.m_crosshairState = gamePSMCrosshairStates.Default;
  }

  protected cb func OnUninitialize() -> Bool {
    let weaponBB: ref<IBlackboard> = this.GetUIActiveWeaponBlackboard();
    weaponBB.UnregisterListenerVector2(GetAllBlackboardDefs().UI_ActiveWeaponData.BulletSpread, this.m_bulletSpreedBlackboardId);
    this.m_leftPart.SetSize(this.m_orgSideSize);
    this.m_rightPart.SetSize(this.m_orgSideSize);
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.RegisterPSMListeners(playerGameObject);
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(playerGameObject);
  }

  protected final func RegisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(playerStateMachineBlackboard) {
      this.m_crosshairStateBlackboardId = playerStateMachineBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Crosshair, this, n"OnPSMCrosshairStateChanged");
    };
  }

  protected final func UnregisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(playerStateMachineBlackboard) {
      playerStateMachineBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Crosshair, this.m_crosshairStateBlackboardId);
    };
  }

  protected cb func OnBulletSpreadChanged(spread: Vector2) -> Bool {
    this.m_bufferedSpread = spread;
    this.m_leftPart.SetMargin(new inkMargin(-(this.m_minSpread + this.m_gameplaySpreadMultiplier * spread.X), 0.00, 0.00, 0.00));
    this.m_rightPart.SetMargin(new inkMargin(this.m_minSpread + this.m_gameplaySpreadMultiplier * spread.X, 0.00, 0.00, 0.00));
  }

  protected cb func OnPSMCrosshairStateChanged(value: Int32) -> Bool {
    let oldState: gamePSMCrosshairStates = this.m_crosshairState;
    let newState: gamePSMCrosshairStates = IntEnum(value);
    this.m_crosshairState = newState;
    this.OnCrosshairStateChange(oldState, newState);
  }

  private func OnCrosshairStateChange(oldState: gamePSMCrosshairStates, newState: gamePSMCrosshairStates) -> Void {
    switch newState {
      case gamePSMCrosshairStates.HipFire:
        this.OnState_HipFire();
        break;
      case gamePSMCrosshairStates.Aim:
        this.OnState_Aim();
        break;
      case gamePSMCrosshairStates.Reload:
        this.OnState_Reload();
        break;
      case gamePSMCrosshairStates.Sprint:
        this.OnState_Sprint();
    };
  }

  public final func ColapseCrosshair(full: Bool, duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let marginInterpolator: ref<inkAnimMargin> = new inkAnimMargin();
    marginInterpolator.SetStartMargin(this.m_leftPart.GetMargin());
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_leftPart.GetOpacity());
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_leftPart.PlayAnimation(anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(this.m_rightPart.GetMargin());
    marginInterpolator.SetEndMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_rightPart.GetOpacity());
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_rightPart.PlayAnimation(anim);
    if full {
      anim = new inkAnimDef();
      alphaInterpolator = new inkAnimTransparency();
      alphaInterpolator.SetStartTransparency(this.m_nearCenterPart.GetOpacity());
      alphaInterpolator.SetEndTransparency(0.00);
      alphaInterpolator.SetDuration(duration);
      alphaInterpolator.SetType(inkanimInterpolationType.Linear);
      alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      anim.AddInterpolator(alphaInterpolator);
      this.m_nearCenterPart.PlayAnimation(anim);
      this.m_farCenterPart.PlayAnimation(anim);
    };
  }

  public final func ExpandCrosshair(full: Bool, duration: Float) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let marginInterpolator: ref<inkAnimMargin> = new inkAnimMargin();
    marginInterpolator.SetStartMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetEndMargin(new inkMargin(-this.m_minSpread - this.m_bufferedSpread.X * this.m_gameplaySpreadMultiplier, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_leftPart.GetOpacity());
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_leftPart.PlayAnimation(anim);
    anim = new inkAnimDef();
    marginInterpolator = new inkAnimMargin();
    marginInterpolator.SetStartMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    marginInterpolator.SetEndMargin(new inkMargin(this.m_minSpread + this.m_bufferedSpread.X * this.m_gameplaySpreadMultiplier, 0.00, 0.00, 0.00));
    marginInterpolator.SetDuration(duration);
    marginInterpolator.SetType(inkanimInterpolationType.Linear);
    marginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(marginInterpolator);
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(this.m_rightPart.GetOpacity());
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(duration);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    this.m_rightPart.PlayAnimation(anim);
    if full {
      anim = new inkAnimDef();
      alphaInterpolator = new inkAnimTransparency();
      alphaInterpolator.SetStartTransparency(this.m_nearCenterPart.GetOpacity());
      alphaInterpolator.SetEndTransparency(1.00);
      alphaInterpolator.SetDuration(duration);
      alphaInterpolator.SetType(inkanimInterpolationType.Linear);
      alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      anim.AddInterpolator(alphaInterpolator);
      this.m_nearCenterPart.PlayAnimation(anim);
      this.m_farCenterPart.PlayAnimation(anim);
    };
  }

  public final func OnState_HipFire() -> Void {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let sizeInterpolator: ref<inkAnimSize> = new inkAnimSize();
    sizeInterpolator.SetStartSize(new Vector2(this.m_orgSideSize.X / 2.00, this.m_orgSideSize.Y / 2.00));
    sizeInterpolator.SetEndSize(this.m_orgSideSize);
    sizeInterpolator.SetDuration(0.10);
    sizeInterpolator.SetType(inkanimInterpolationType.Linear);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(sizeInterpolator);
    this.m_leftPart.PlayAnimation(anim);
    this.m_rightPart.PlayAnimation(anim);
    this.ExpandCrosshair(false, 0.10);
  }

  private final func OnState_Aim() -> Void {
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let sizeInterpolator: ref<inkAnimSize> = new inkAnimSize();
    sizeInterpolator.SetStartSize(this.m_orgSideSize);
    sizeInterpolator.SetEndSize(new Vector2(this.m_orgSideSize.X / 2.00, this.m_orgSideSize.Y / 2.00));
    sizeInterpolator.SetDuration(0.10);
    sizeInterpolator.SetType(inkanimInterpolationType.Linear);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(sizeInterpolator);
    this.m_leftPart.PlayAnimation(anim);
    this.m_rightPart.PlayAnimation(anim);
    this.ExpandCrosshair(false, 0.10);
  }

  private final func OnState_Reload() -> Void {
    this.ColapseCrosshair(false, 0.25);
  }

  public final func OnState_Sprint() -> Void {
    this.ColapseCrosshair(false, 0.10);
  }

  public final func GetUIActiveWeaponBlackboard() -> ref<IBlackboard> {
    return this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
  }
}
