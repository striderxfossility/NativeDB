
public class CrosshairGameController_Smart_Rifl extends gameuiCrosshairBaseGameController {

  private edit let m_txtAccuracy: inkTextRef;

  private edit let m_txtTargetsCount: inkTextRef;

  private edit let m_txtFluffStatus: inkTextRef;

  private edit let m_leftPart: inkImageRef;

  private edit let m_rightPart: inkImageRef;

  private edit let m_leftPartExtra: inkImageRef;

  private edit let m_rightPartExtra: inkImageRef;

  @default(CrosshairGameController_Smart_Rifl, .8)
  private let offsetLeftRight: Float;

  @default(CrosshairGameController_Smart_Rifl, 1.2)
  private let offsetLeftRightExtra: Float;

  @default(CrosshairGameController_Smart_Rifl, 40.0)
  private let latchVertical: Float;

  private edit let m_topPart: inkImageRef;

  private edit let m_bottomPart: inkImageRef;

  private edit let m_horiPart: inkWidgetRef;

  private edit let m_vertPart: inkWidgetRef;

  @default(CrosshairGameController_Smart_Rifl, bucket)
  private edit let m_targetWidgetLibraryName: CName;

  @default(CrosshairGameController_Smart_Rifl, 10)
  private edit let m_targetsPullSize: Int32;

  private edit let m_targetColorChange: inkWidgetRef;

  private edit let m_targetingFrame: inkWidgetRef;

  private edit let m_reticleFrame: inkWidgetRef;

  private edit let m_bufferFrame: inkWidgetRef;

  private edit let m_targetHolder: inkCompoundRef;

  private edit let m_lockHolder: inkCompoundRef;

  private edit let m_reloadIndicator: inkCompoundRef;

  private edit let m_reloadIndicatorInv: inkCompoundRef;

  private edit let m_smartLinkDot: inkCompoundRef;

  private edit let m_smartLinkFrame: inkCompoundRef;

  private edit let m_smartLinkFluff: inkCompoundRef;

  private edit let m_smartLinkFirmwareOnline: inkCompoundRef;

  private edit let m_smartLinkFirmwareOffline: inkCompoundRef;

  private let m_weaponBlackboard: wref<IBlackboard>;

  private let m_weaponParamsListenerId: ref<CallbackHandle>;

  private let m_targets: array<wref<inkWidget>>;

  private let m_targetsData: array<smartGunUITargetParameters>;

  private let m_isBlocked: Bool;

  private let m_isAimDownSights: Bool;

  private let m_bufferedSpread: Vector2;

  private let m_reloadAnimationProxy: ref<inkAnimProxy>;

  public let m_prevTargetedEntityIDs: array<EntityID>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.SetupLayout();
  }

  protected cb func OnPreIntro() -> Bool {
    this.m_weaponBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    this.m_weaponParamsListenerId = this.m_weaponBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.SmartGunParams, this, n"OnSmartGunParams");
    super.OnPreIntro();
  }

  protected cb func OnPreOutro() -> Bool {
    this.m_weaponBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ActiveWeaponData.SmartGunParams, this.m_weaponParamsListenerId);
    super.OnPreOutro();
  }

  private final func SetupLayout() -> Void {
    let newTarget: wref<inkWidget>;
    let i: Int32 = 0;
    while i < this.m_targetsPullSize {
      newTarget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_targetHolder), this.m_targetWidgetLibraryName);
      newTarget.SetVisible(false);
      ArrayPush(this.m_targets, newTarget);
      i += 1;
    };
    inkWidgetRef.SetVisible(this.m_reloadIndicator, false);
    inkWidgetRef.SetVisible(this.m_reloadIndicatorInv, true);
  }

  protected cb func OnSmartGunParams(argParams: Variant) -> Bool {
    let bufferValue: Vector2;
    let count: Int32;
    let currController: wref<Crosshair_Smart_Rifl_Bucket>;
    let currTargetData: smartGunUITargetParameters;
    let currWidget: wref<inkWidget>;
    let i: Int32;
    let numLockedTargets: Int32;
    let numTargets: Int32;
    let targetList: array<smartGunUITargetParameters>;
    let targetedEntityIDs: array<EntityID>;
    let smartData: ref<smartGunUIParameters> = FromVariant(argParams);
    inkWidgetRef.SetSize(this.m_targetingFrame, smartData.sight.targetableRegionSize);
    inkWidgetRef.SetSize(this.m_reticleFrame, smartData.sight.reticleSize);
    bufferValue.Y = (smartData.sight.targetableRegionSize.Y - smartData.sight.reticleSize.Y) / 2.00;
    inkWidgetRef.SetSize(this.m_bufferFrame, 100.00, bufferValue.Y);
    inkWidgetRef.SetVisible(this.m_smartLinkDot, false);
    inkWidgetRef.SetVisible(this.m_smartLinkFrame, true);
    inkWidgetRef.SetVisible(this.m_smartLinkFluff, true);
    inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOffline, smartData.hasRequiredCyberware ? false : true);
    inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOnline, smartData.hasRequiredCyberware ? true : false);
    targetList = smartData.targets;
    numTargets = ArraySize(targetList);
    count = ArraySize(this.m_targets);
    i = 0;
    while i < count {
      currWidget = this.m_targets[i];
      if i >= numTargets {
        currWidget.SetVisible(false);
      } else {
        currTargetData = targetList[i];
        currWidget.SetVisible(true);
        currWidget.SetMargin(new inkMargin(currTargetData.pos.X * 0.50, currTargetData.pos.Y * 0.50, 0.00, 0.00));
        if Equals(currTargetData.state, gamesmartGunTargetState.Locked) || Equals(currTargetData.state, gamesmartGunTargetState.Unlocking) {
          currWidget.Reparent(inkWidgetRef.Get(this.m_lockHolder) as inkCompoundWidget);
        } else {
          currWidget.Reparent(inkWidgetRef.Get(this.m_targetHolder) as inkCompoundWidget);
        };
        currController = currWidget.GetController() as Crosshair_Smart_Rifl_Bucket;
        currController.SetData(currTargetData);
        if Equals(currTargetData.state, gamesmartGunTargetState.Locked) && !ArrayContains(targetedEntityIDs, currTargetData.entityID) {
          ArrayPush(targetedEntityIDs, currTargetData.entityID);
          if !ArrayContains(this.m_prevTargetedEntityIDs, currTargetData.entityID) {
            numLockedTargets = numLockedTargets + 1;
          };
        };
      };
      i += 1;
    };
    if numLockedTargets > 0 {
      if this.m_isAimDownSights {
        this.PlaySound(n"SmartGunRifle", n"OnTagFromAim");
      } else {
        this.PlaySound(n"SmartGunRifle", n"OnTagFromHip");
      };
    };
    this.m_prevTargetedEntityIDs = targetedEntityIDs;
  }

  protected func ApplyCrosshairGUIState(state: CName, aimedAtEntity: ref<Entity>) -> Void {
    inkWidgetRef.SetState(this.m_targetColorChange, state);
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

  protected func OnCrosshairStateChange(oldState: gamePSMCrosshairStates, newState: gamePSMCrosshairStates) -> Void {
    let playbackOptions: inkAnimOptions;
    this.OnCrosshairStateChange(oldState, newState);
    if Equals(newState, gamePSMCrosshairStates.Reload) {
      playbackOptions.loopInfinite = true;
      playbackOptions.loopType = inkanimLoopType.Cycle;
      this.m_reloadAnimationProxy = this.PlayLibraryAnimation(n"reloading", playbackOptions);
      inkWidgetRef.SetVisible(this.m_reloadIndicator, true);
      inkWidgetRef.SetVisible(this.m_reloadIndicatorInv, false);
    } else {
      if IsDefined(this.m_reloadAnimationProxy) {
        inkWidgetRef.SetVisible(this.m_reloadIndicator, false);
        inkWidgetRef.SetVisible(this.m_reloadIndicatorInv, true);
        this.m_reloadAnimationProxy.Stop();
        this.m_reloadAnimationProxy = null;
      };
    };
  }

  protected cb func OnBulletSpreadChanged(spread: Vector2) -> Bool {
    this.m_bufferedSpread = spread;
    inkWidgetRef.SetMargin(this.m_leftPart, new inkMargin(-spread.X * this.offsetLeftRight, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_rightPart, new inkMargin(spread.X * this.offsetLeftRight, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_leftPartExtra, new inkMargin(-spread.X / 2.00, 0.00, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_rightPartExtra, new inkMargin(spread.X / 2.00, 0.00, 0.00, 0.00));
    inkWidgetRef.SetSize(this.m_vertPart, 3.00, spread.Y * 2.00 + this.latchVertical);
    inkWidgetRef.SetSize(this.m_horiPart, spread.X, 3.00);
    inkWidgetRef.SetMargin(this.m_topPart, new inkMargin(0.00, -spread.Y, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_bottomPart, new inkMargin(0.00, spread.Y, 0.00, 0.00));
  }

  protected func OnState_HipFire() -> Void {
    this.OnState_HipFire();
    this.m_isAimDownSights = false;
    this.m_isBlocked = false;
  }

  protected func OnState_Aim() -> Void {
    this.m_isAimDownSights = true;
    this.m_isBlocked = false;
  }

  protected func OnState_Reload() -> Void {
    this.OnState_Reload();
    this.m_isBlocked = true;
  }

  protected func OnState_Sprint() -> Void {
    this.OnState_Sprint();
    this.m_isBlocked = true;
  }

  protected func OnState_GrenadeCharging() -> Void {
    this.OnState_GrenadeCharging();
    this.m_isBlocked = true;
  }

  protected func OnState_Scanning() -> Void {
    this.OnState_Scanning();
    this.m_isBlocked = true;
  }

  protected func OnState_Safe() -> Void {
    this.OnState_Safe();
    this.m_isBlocked = true;
  }
}

public class Crosshair_Smart_Rifl_Bucket extends inkLogicController {

  private edit let m_progressBar: inkWidgetRef;

  private edit let m_progressBarValue: inkWidgetRef;

  private edit let m_targetIndicator: inkWidgetRef;

  private edit let m_lockedIndicator: inkWidgetRef;

  private edit let m_lockingIndicator: inkWidgetRef;

  private let m_data: smartGunUITargetParameters;

  private let m_lockingAnimationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_progressBar, false);
    inkWidgetRef.SetVisible(this.m_targetIndicator, false);
    inkWidgetRef.SetVisible(this.m_lockedIndicator, false);
    inkWidgetRef.SetVisible(this.m_lockingIndicator, false);
  }

  public final func SetData(data: smartGunUITargetParameters) -> Void {
    this.m_data = data;
    if IsDefined(this.m_lockingAnimationProxy) {
      this.m_lockingAnimationProxy.Stop();
      this.m_lockingAnimationProxy = null;
    };
    switch this.m_data.state {
      case gamesmartGunTargetState.Targetable:
      case gamesmartGunTargetState.Visible:
        inkWidgetRef.SetVisible(this.m_targetIndicator, true);
        inkWidgetRef.SetVisible(this.m_lockingIndicator, false);
        inkWidgetRef.SetVisible(this.m_lockedIndicator, false);
        break;
      case gamesmartGunTargetState.Locking:
        inkWidgetRef.SetVisible(this.m_targetIndicator, false);
        inkWidgetRef.SetVisible(this.m_lockingIndicator, true);
        inkWidgetRef.SetVisible(this.m_lockedIndicator, false);
        break;
      case gamesmartGunTargetState.Unlocking:
      case gamesmartGunTargetState.Locked:
        inkWidgetRef.SetVisible(this.m_targetIndicator, false);
        inkWidgetRef.SetVisible(this.m_lockingIndicator, false);
        inkWidgetRef.SetVisible(this.m_lockedIndicator, true);
    };
  }
}
