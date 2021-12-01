
public class TargetHitIndicatorGameController extends inkGameController {

  private let m_currentAnim: ref<inkAnimProxy>;

  private let m_bonusAnim: ref<inkAnimProxy>;

  private let m_currentAnimWidget: wref<inkWidget>;

  private let m_currentPriority: Int32;

  private let m_currentController: wref<TargetHitIndicatorLogicController>;

  private let m_damageController: wref<TargetHitIndicatorLogicController>;

  private let m_defeatController: wref<TargetHitIndicatorLogicController>;

  private let m_killController: wref<TargetHitIndicatorLogicController>;

  private let m_bonusController: wref<TargetHitIndicatorLogicController>;

  private let m_damageListBlackboardId: ref<CallbackHandle>;

  private let m_killListBlackboardId: ref<CallbackHandle>;

  private let m_indicatorEnabledBlackboardId: ref<CallbackHandle>;

  private let m_weaponSwayBlackboardId: ref<CallbackHandle>;

  private let m_weaponChangeBlackboardId: ref<CallbackHandle>;

  private let m_aimingStatusBlackboardId: ref<CallbackHandle>;

  private let m_zoomLevelBlackboardId: ref<CallbackHandle>;

  private let m_realOwner: wref<GameObject>;

  private let m_hitIndicatorEnabled: Bool;

  private let m_entityHit: wref<GameObject>;

  private let m_rootWidget: wref<inkWidget>;

  private let m_player: wref<PlayerPuppet>;

  private let m_currentSway: Vector2;

  public let m_currentWeaponZoom: Float;

  public let m_weaponZoomNeedsUpdate: Bool;

  private let m_currentZoomLevel: Float;

  private let m_weaponZoomListener: ref<HitIndicatorWeaponZoomListener>;

  private let m_weaponID: StatsObjectID;

  private let m_isAimingDownSights: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_realOwner = this.GetOwnerEntity() as GameObject;
    this.m_damageController = this.SpawnIndicator(n"Damage");
    this.m_defeatController = this.SpawnIndicator(n"Defeat");
    this.m_killController = this.SpawnIndicator(n"Kill");
    this.m_bonusController = this.SpawnIndicator(n"Bonus");
    let damageInfoBB: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_DamageInfo);
    this.m_damageListBlackboardId = damageInfoBB.RegisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DamageList, this, n"OnDamageAdded");
    this.m_killListBlackboardId = damageInfoBB.RegisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.KillList, this, n"OnKillAdded");
    this.m_indicatorEnabledBlackboardId = damageInfoBB.RegisterListenerBool(GetAllBlackboardDefs().UI_DamageInfo.HitIndicatorEnabled, this, n"OnHitIndicatorEnabledChanged");
    this.m_hitIndicatorEnabled = damageInfoBB.GetBool(GetAllBlackboardDefs().UI_DamageInfo.HitIndicatorEnabled);
    let weaponInfoBB: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    this.m_weaponSwayBlackboardId = weaponInfoBB.RegisterListenerVector2(GetAllBlackboardDefs().UIGameData.WeaponSway, this, n"OnSway");
    this.m_weaponChangeBlackboardId = weaponInfoBB.RegisterListenerVariant(GetAllBlackboardDefs().UIGameData.RightWeaponRecordID, this, n"OnWeaponChange");
  }

  protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
    let playerStateMachineBB: ref<IBlackboard>;
    let stats: ref<StatsSystem>;
    let weapon: ref<WeaponObject>;
    this.m_realOwner = player;
    this.m_player = player as PlayerPuppet;
    if IsDefined(this.m_player) {
      playerStateMachineBB = this.m_player.GetPlayerStateMachineBlackboard();
      this.m_aimingStatusBlackboardId = playerStateMachineBB.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this, n"OnAimStatusChange");
      this.m_zoomLevelBlackboardId = playerStateMachineBB.RegisterListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnZoomLevelChange");
      this.m_isAimingDownSights = playerStateMachineBB.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
      if !IsDefined(this.m_weaponZoomListener) {
        this.m_weaponZoomListener = new HitIndicatorWeaponZoomListener();
        this.m_weaponZoomListener.m_gameController = this;
      };
      stats = GameInstance.GetStatsSystem(this.m_player.GetGame());
      weapon = GameInstance.GetTransactionSystem(this.m_player.GetGame()).GetItemInSlot(this.m_player, t"AttachmentSlots.WeaponRight") as WeaponObject;
      if IsDefined(weapon) {
        this.m_weaponID = weapon.GetItemData().GetStatsObjectID();
        this.m_weaponZoomListener.SetStatType(gamedataStatType.ZoomLevel);
        stats.RegisterListener(this.m_weaponID, this.m_weaponZoomListener);
        this.m_weaponZoomNeedsUpdate = true;
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    let weaponInfoBB: ref<IBlackboard>;
    let damageInfoBB: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_DamageInfo);
    if IsDefined(this.m_damageListBlackboardId) {
      damageInfoBB.UnregisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DamageList, this.m_damageListBlackboardId);
    };
    if IsDefined(this.m_killListBlackboardId) {
      damageInfoBB.UnregisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.KillList, this.m_killListBlackboardId);
    };
    if IsDefined(this.m_indicatorEnabledBlackboardId) {
      damageInfoBB.UnregisterListenerBool(GetAllBlackboardDefs().UI_DamageInfo.HitIndicatorEnabled, this.m_indicatorEnabledBlackboardId);
    };
    weaponInfoBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    if IsDefined(this.m_weaponSwayBlackboardId) {
      weaponInfoBB.UnregisterListenerVector2(GetAllBlackboardDefs().UIGameData.WeaponSway, this.m_weaponSwayBlackboardId);
    };
    if IsDefined(this.m_weaponChangeBlackboardId) {
      weaponInfoBB.UnregisterListenerVariant(GetAllBlackboardDefs().UIGameData.RightWeaponRecordID, this.m_weaponChangeBlackboardId);
    };
  }

  protected cb func OnPlayerDetach(player: ref<GameObject>) -> Bool {
    let playerStateMachineBB: ref<IBlackboard>;
    if IsDefined(this.m_player) {
      playerStateMachineBB = this.m_player.GetPlayerStateMachineBlackboard();
      if IsDefined(this.m_aimingStatusBlackboardId) {
        playerStateMachineBB.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this.m_aimingStatusBlackboardId);
      };
      if IsDefined(this.m_zoomLevelBlackboardId) {
        playerStateMachineBB.UnregisterListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_zoomLevelBlackboardId);
      };
      GameInstance.GetStatsSystem(this.m_player.GetGame()).UnregisterListener(this.m_weaponID, this.m_weaponZoomListener);
      this.m_player = null;
    };
  }

  private final func SpawnIndicator(type: CName) -> ref<TargetHitIndicatorLogicController> {
    let newInkWidget: ref<inkWidget> = this.SpawnFromLocal(this.GetRootWidget(), type);
    newInkWidget.SetAnchor(inkEAnchor.Centered);
    newInkWidget.SetAnchorPoint(0.50, 0.50);
    return newInkWidget.GetController() as TargetHitIndicatorLogicController;
  }

  protected cb func OnDamageAdded(value: Variant) -> Bool {
    let hitEntity: wref<GameObject>;
    let damageList: array<DamageInfo> = FromVariant(value);
    let i: Int32 = 0;
    while i < ArraySize(damageList) {
      if damageList[i].entityHit != null && this.m_realOwner == damageList[i].instigator && this.ShouldShowDamage(damageList[i]) {
        if this.ShouldShowBonus(damageList[i]) {
          this.ShowBonus();
        };
        hitEntity = damageList[i].entityHit;
      } else {
        i += 1;
      };
    };
    if hitEntity != null {
      this.Show(hitEntity, false);
    };
  }

  protected cb func OnKillAdded(value: Variant) -> Bool {
    let killType: gameKillType;
    let killedEntity: wref<GameObject>;
    let killList: array<KillInfo> = FromVariant(value);
    let i: Int32 = 0;
    while i < ArraySize(killList) {
      if killList[i].victimEntity != null && this.m_realOwner == killList[i].killerEntity {
        killedEntity = killList[i].victimEntity;
        killType = killList[i].killType;
        this.Show(killedEntity, true, killType);
      };
      i += 1;
    };
  }

  private final func ShouldShowDamage(damageInfo: DamageInfo) -> Bool {
    let i: Int32;
    if damageInfo.damageValue == 0.00 {
      return false;
    };
    i = 0;
    while i < ArraySize(damageInfo.userData.flags) {
      if Equals(damageInfo.userData.flags[i].flag, hitFlag.ImmortalTarget) || Equals(damageInfo.userData.flags[i].flag, hitFlag.DealNoDamage) || Equals(damageInfo.userData.flags[i].flag, hitFlag.DontShowDamageFloater) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  private final func ShouldShowBonus(damageInfo: DamageInfo) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(damageInfo.userData.flags) {
      if Equals(damageInfo.userData.flags[i].flag, hitFlag.Headshot) || Equals(damageInfo.userData.flags[i].flag, hitFlag.WeakspotHit) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func Show(entity: wref<GameObject>, isDead: Bool, opt killType: gameKillType) -> Void {
    if this.m_hitIndicatorEnabled {
      if isDead {
        if Equals(killType, gameKillType.Normal) {
          this.m_currentController = this.m_killController;
        } else {
          if Equals(killType, gameKillType.Defeat) {
            this.m_currentController = this.m_defeatController;
          };
        };
      } else {
        this.m_currentController = this.m_damageController;
      };
      this.m_entityHit = entity;
      if this.m_currentPriority <= this.m_currentController.m_animationPriority {
        if IsDefined(this.m_currentAnim) && this.m_currentAnim.IsPlaying() {
          this.m_currentAnimWidget.SetVisible(false);
          this.m_currentAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAnimFinished");
          this.m_currentAnim.Stop();
        };
        this.PlayAnimation();
      };
    };
  }

  public final func PlayAnimation() -> Void {
    this.m_currentAnimWidget = this.m_currentController.GetRootWidget();
    this.m_currentAnimWidget.SetOpacity(1.00);
    this.m_currentAnimWidget.SetVisible(true);
    this.m_currentAnim = this.m_currentController.PlayLibraryAnimation(this.m_currentController.m_animName);
    this.m_currentAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimFinished");
    this.m_currentPriority = this.m_currentController.m_animationPriority;
  }

  protected cb func OnAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_currentAnimWidget.SetVisible(false);
    this.m_currentAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAnimFinished");
    this.m_currentPriority = 0;
  }

  private final func ShowBonus() -> Void {
    let bonusAnimWidget: wref<inkWidget>;
    if this.m_hitIndicatorEnabled {
      if IsDefined(this.m_bonusAnim) && this.m_bonusAnim.IsPlaying() {
        this.m_bonusAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnBonusAnimFinished");
        this.m_bonusAnim.Stop();
      };
      bonusAnimWidget = this.m_bonusController.GetRootWidget();
      bonusAnimWidget.SetOpacity(1.00);
      bonusAnimWidget.SetVisible(true);
      this.m_bonusAnim = this.m_bonusController.PlayLibraryAnimation(this.m_bonusController.m_animName);
      this.m_bonusAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnBonusAnimFinished");
    };
  }

  protected cb func OnBonusAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_bonusController.GetRootWidget().SetVisible(false);
    this.m_bonusAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnBonusAnimFinished");
  }

  protected cb func OnSway(pos: Vector2) -> Bool {
    this.m_currentSway = pos;
    this.UpdateWidgetPosition();
  }

  protected cb func OnAimStatusChange(value: Int32) -> Bool {
    this.m_isAimingDownSights = value == EnumInt(gamePSMUpperBodyStates.Aim);
    if IsDefined(this.m_player) && this.m_weaponZoomNeedsUpdate {
      this.m_currentWeaponZoom = GameInstance.GetStatsSystem(this.m_player.GetGame()).GetStatValue(this.m_weaponID, gamedataStatType.ZoomLevel);
      this.m_weaponZoomNeedsUpdate = false;
    };
    this.UpdateWidgetPosition();
  }

  protected cb func OnZoomLevelChange(value: Float) -> Bool {
    this.m_currentZoomLevel = value;
    this.UpdateWidgetPosition();
  }

  private final func UpdateWidgetPosition() -> Void {
    let multiplier: Float;
    let rFov: Float;
    if this.m_isAimingDownSights {
      if IsDefined(this.m_player) {
        rFov = Deg2Rad(GameInstance.GetCameraSystem(this.m_player.GetGame()).GetActiveCameraFOV());
        if rFov == 0.00 {
          rFov = 0.89;
        };
      } else {
        rFov = 0.89;
      };
      if this.m_currentZoomLevel >= 2.00 {
        multiplier = this.m_currentZoomLevel / TanF(rFov * 0.50);
      } else {
        multiplier = this.m_currentWeaponZoom / TanF(rFov * 0.50);
      };
      this.m_rootWidget.SetMargin(new inkMargin(-19.20 * this.m_currentSway.X * multiplier, -18.90 * this.m_currentSway.Y * multiplier, 0.00, 0.00));
    } else {
      this.m_rootWidget.SetMargin(new inkMargin(0.00, 0.00, 0.00, 0.00));
    };
  }

  protected cb func OnWeaponChange(value: Variant) -> Bool {
    let stats: ref<StatsSystem>;
    let weapon: ref<WeaponObject>;
    if IsDefined(this.m_player) {
      stats = GameInstance.GetStatsSystem(this.m_player.GetGame());
      stats.UnregisterListener(this.m_weaponID, this.m_weaponZoomListener);
      weapon = GameInstance.GetTransactionSystem(this.m_player.GetGame()).GetItemInSlot(this.m_player, t"AttachmentSlots.WeaponRight") as WeaponObject;
      if IsDefined(weapon) {
        this.m_weaponID = weapon.GetItemData().GetStatsObjectID();
        this.m_weaponZoomListener.SetStatType(gamedataStatType.ZoomLevel);
        stats.RegisterListener(this.m_weaponID, this.m_weaponZoomListener);
        this.m_weaponZoomNeedsUpdate = true;
      };
    };
  }

  protected cb func OnHitIndicatorEnabledChanged(value: Bool) -> Bool {
    this.m_hitIndicatorEnabled = value;
  }
}

public class TargetHitIndicatorLogicController extends inkLogicController {

  public edit let m_animName: CName;

  public edit let m_animationPriority: Int32;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVisible(false);
  }
}

public class HitIndicatorWeaponZoomListener extends ScriptStatsListener {

  public let m_gameController: wref<TargetHitIndicatorGameController>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    this.m_gameController.m_currentWeaponZoom = total;
    this.m_gameController.m_weaponZoomNeedsUpdate = false;
  }
}
