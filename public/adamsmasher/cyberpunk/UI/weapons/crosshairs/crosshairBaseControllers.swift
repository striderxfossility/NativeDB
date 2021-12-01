
public native class gameuiCrosshairBaseGameController extends inkGameController {

  protected let m_rootWidget: wref<inkWidget>;

  private let m_crosshairState: gamePSMCrosshairStates;

  private let m_visionState: gamePSMVision;

  private let m_crosshairStateBlackboardId: ref<CallbackHandle>;

  private let m_bulletSpreedBlackboardId: ref<CallbackHandle>;

  private let m_bbNPCStatsId: Uint32;

  private let m_isTargetDead: Bool;

  private let m_lastGUIStateUpdateFrame: Uint64;

  protected let m_targetBB: wref<IBlackboard>;

  protected let m_weaponBB: wref<IBlackboard>;

  private let m_currentAimTargetBBID: ref<CallbackHandle>;

  private let m_targetDistanceBBID: ref<CallbackHandle>;

  private let m_targetAttitudeBBID: ref<CallbackHandle>;

  protected let m_targetEntity: wref<Entity>;

  private let m_healthListener: ref<CrosshairHealthChangeListener>;

  private let m_isActive: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_crosshairState = gamePSMCrosshairStates.Default;
    this.m_healthListener = CrosshairHealthChangeListener.Create(this);
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_targetEntity) {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.m_targetEntity.GetEntityID()), gamedataStatPoolType.Health, this.m_healthListener);
    };
    this.m_healthListener = null;
    this.m_isActive = false;
  }

  protected final func IsActive() -> Bool {
    return this.m_isActive;
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let playerSMBB: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    this.m_crosshairStateBlackboardId = playerSMBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Crosshair, this, n"OnPSMCrosshairStateChanged");
    this.OnPSMCrosshairStateChanged(playerSMBB.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Crosshair));
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    let playerSMBB: ref<IBlackboard>;
    if IsDefined(this.m_crosshairStateBlackboardId) {
      playerSMBB = this.GetPSMBlackboard(playerPuppet);
      playerSMBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Crosshair, this.m_crosshairStateBlackboardId);
    };
  }

  protected cb func OnPreIntro() -> Bool {
    this.m_targetBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_TargetingInfo);
    if IsDefined(this.m_targetBB) {
      this.m_currentAimTargetBBID = this.m_targetBB.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this, n"OnCurrentAimTarget");
      this.m_targetDistanceBBID = this.m_targetBB.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetDistance, this, n"OnTargetDistanceChanged");
      this.m_targetAttitudeBBID = this.m_targetBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetAttitude, this, n"OnTargetAttitudeChanged");
      this.OnCurrentAimTarget(this.m_targetBB.GetEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget));
    };
    this.m_weaponBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    if IsDefined(this.m_weaponBB) {
      this.m_bulletSpreedBlackboardId = this.m_weaponBB.RegisterDelayedListenerVector2(GetAllBlackboardDefs().UI_ActiveWeaponData.BulletSpread, this, n"OnBulletSpreadChanged");
      this.OnBulletSpreadChanged(this.m_weaponBB.GetVector2(GetAllBlackboardDefs().UI_ActiveWeaponData.BulletSpread));
    };
    this.m_isActive = true;
    this.UpdateCrosshairState();
  }

  protected cb func OnPreOutro() -> Bool {
    if IsDefined(this.m_targetBB) {
      this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this.m_currentAimTargetBBID);
      this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetDistance, this.m_targetDistanceBBID);
      this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetAttitude, this.m_targetAttitudeBBID);
    };
    if IsDefined(this.m_weaponBB) {
      this.m_weaponBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ActiveWeaponData.BulletSpread, this.m_bulletSpreedBlackboardId);
    };
    this.m_targetBB = null;
    this.m_weaponBB = null;
    this.m_targetEntity = null;
    this.m_isActive = false;
  }

  protected final native func GetWeaponRecordID() -> ItemID;

  protected final native func GetWeaponLocalBlackboard() -> ref<IBlackboard>;

  protected final native func GetWeaponItemObject() -> ref<ItemObject>;

  protected final func GetUIActiveWeaponBlackboard() -> ref<IBlackboard> {
    return this.m_weaponBB;
  }

  protected final native func IsTargetWithinWeaponEffectiveRange(distanceToTarget: Float) -> Bool;

  public func GetIntroAnimation(firstEquip: Bool) -> ref<inkAnimDef> {
    return null;
  }

  public func GetOutroAnimation() -> ref<inkAnimDef> {
    return null;
  }

  protected func GetCrosshairState() -> gamePSMCrosshairStates {
    return this.m_crosshairState;
  }

  protected final func GetVisionState() -> gamePSMVision {
    return this.m_visionState;
  }

  protected cb func OnNPCStatsChanged(value: Variant) -> Bool {
    let incomingData: NPCNextToTheCrosshair = FromVariant(value);
    this.m_isTargetDead = incomingData.currentHealth < 1;
  }

  protected cb func OnPSMCrosshairStateChanged(value: Int32) -> Bool {
    let oldState: gamePSMCrosshairStates = this.m_crosshairState;
    let newState: gamePSMCrosshairStates = IntEnum(value);
    if NotEquals(oldState, newState) {
      this.m_crosshairState = newState;
      this.OnCrosshairStateChange(oldState, newState);
    };
  }

  protected func OnCrosshairStateChange(oldState: gamePSMCrosshairStates, newState: gamePSMCrosshairStates) -> Void {
    this.UpdateCrosshairState();
  }

  protected final func UpdateCrosshairState() -> Void {
    if this.IsActive() {
      switch this.m_crosshairState {
        case gamePSMCrosshairStates.Safe:
          this.OnState_Safe();
          break;
        case gamePSMCrosshairStates.Scanning:
          this.OnState_Scanning();
          break;
        case gamePSMCrosshairStates.GrenadeCharging:
          this.OnState_GrenadeCharging();
          break;
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
          break;
        case gamePSMCrosshairStates.LeftHandCyberware:
          this.OnState_LeftHandCyberware();
      };
    };
  }

  protected cb func OnBulletSpreadChanged(spread: Vector2) -> Bool;

  protected func OnState_Aim() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_HipFire() -> Void {
    this.m_rootWidget.SetVisible(true);
  }

  protected func OnState_GrenadeCharging() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_Reload() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_Safe() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_Sprint() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_Scanning() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func OnState_LeftHandCyberware() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void;

  protected final func GetGame() -> GameInstance {
    return (this.GetOwnerEntity() as GameObject).GetGame();
  }

  protected final func UpdateCrosshairGUIState(force: Bool) -> Void {
    let currentFrameNumber: Uint64 = GameInstance.GetFrameNumber(this.GetGame());
    if !force && this.m_lastGUIStateUpdateFrame == currentFrameNumber {
      return;
    };
    this.ApplyCrosshairGUIState(this.GetCurrentCrosshairGUIState(), this.m_targetEntity);
    this.m_lastGUIStateUpdateFrame = currentFrameNumber;
  }

  protected final func GetCurrentCrosshairGUIState() -> CName {
    let attitudeTowardsPlayer: EAIAttitude;
    let device: ref<Device>;
    let distanceToTarget: Float;
    let puppet: ref<ScriptedPuppet>;
    let targetGameObject: ref<GameObject> = this.m_targetEntity as GameObject;
    if !IsDefined(targetGameObject) {
      return n"Civilian";
    };
    puppet = targetGameObject as ScriptedPuppet;
    device = targetGameObject as Device;
    attitudeTowardsPlayer = GameObject.GetAttitudeTowards(targetGameObject, this.GetOwnerEntity() as GameObject);
    if IsDefined(puppet) && puppet.IsDead() || IsDefined(device) && device.GetDevicePS().IsBroken() {
      return n"Dead";
    };
    if IsDefined(device) && !device.GetDevicePS().IsON() {
      return n"Civilian";
    };
    if Equals(attitudeTowardsPlayer, EAIAttitude.AIA_Friendly) {
      return n"Friendly";
    };
    if Equals(attitudeTowardsPlayer, EAIAttitude.AIA_Hostile) || IsDefined(puppet) && puppet.IsAggressive() {
      distanceToTarget = this.GetDistanceToTarget();
      if this.IsTargetWithinWeaponEffectiveRange(distanceToTarget) {
        return n"Hostile";
      };
    };
    return n"Civilian";
  }

  protected final func RegisterTargetCallbacks(register: Bool) -> Void {
    if !IsDefined(this.m_targetEntity) || !IsDefined(this.m_healthListener) {
      return;
    };
    if register {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestRegisteringListener(Cast(this.m_targetEntity.GetEntityID()), gamedataStatPoolType.Health, this.m_healthListener);
    } else {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.m_targetEntity.GetEntityID()), gamedataStatPoolType.Health, this.m_healthListener);
    };
  }

  protected cb func OnCurrentAimTarget(entId: EntityID) -> Bool {
    this.RegisterTargetCallbacks(false);
    this.m_targetEntity = GameInstance.FindEntityByID(this.GetGame(), entId);
    this.RegisterTargetCallbacks(true);
    this.UpdateCrosshairGUIState(true);
  }

  protected cb func OnTargetDistanceChanged(distance: Float) -> Bool {
    this.UpdateCrosshairGUIState(false);
  }

  protected cb func OnTargetAttitudeChanged(attitude: Int32) -> Bool {
    this.UpdateCrosshairGUIState(false);
  }

  protected cb func OnRefreshCrosshairEvent(evt: ref<RefreshCrosshairEvent>) -> Bool {
    this.UpdateCrosshairGUIState(evt.force);
  }

  public final func QueueCrosshairRefresh() -> Void {
    let evt: ref<RefreshCrosshairEvent> = new RefreshCrosshairEvent();
    evt.force = false;
    this.QueueEvent(evt);
  }

  protected func GetDistanceToTarget() -> Float {
    let distance: Float = 0.00;
    let targetID: EntityID = this.m_targetBB.GetEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget);
    if EntityID.IsDefined(targetID) {
      distance = this.m_targetBB.GetFloat(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetDistance);
    };
    return distance;
  }
}

public class gameuiCrosshairBaseMelee extends gameuiCrosshairBaseGameController {

  private let m_meleeStateBlackboardId: ref<CallbackHandle>;

  private let m_playerSMBB: wref<IBlackboard>;

  protected cb func OnPreIntro() -> Bool {
    this.m_playerSMBB = this.GetBlackboardSystem().GetLocalInstanced(this.GetOwnerEntity().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    this.m_meleeStateBlackboardId = this.m_playerSMBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, this, n"OnGamePSMMeleeWeapon");
    super.OnPreIntro();
  }

  protected cb func OnPreOutro() -> Bool {
    this.m_playerSMBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, this.m_meleeStateBlackboardId);
    super.OnPreOutro();
  }

  protected cb func OnGamePSMMeleeWeapon(value: Int32) -> Bool {
    let newState: gamePSMMeleeWeapon = IntEnum(value);
    this.OnMeleeState_Update(newState);
  }

  protected func OnMeleeState_Update(value: gamePSMMeleeWeapon) -> Void;
}
