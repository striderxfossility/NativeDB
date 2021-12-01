
public class QuestMappinController extends BaseQuestMappinController {

  protected edit let m_arrowCanvas: inkWidgetRef;

  protected edit let m_arrowPart: inkWidgetRef;

  protected edit let m_selector: inkWidgetRef;

  protected edit let m_scanningDiamond: inkWidgetRef;

  protected edit let m_portalIcon: inkWidgetRef;

  private let m_aboveWidget: wref<inkWidget>;

  private let m_belowWidget: wref<inkWidget>;

  protected let m_mappin: wref<IMappin>;

  protected let m_questMappin: wref<QuestMappin>;

  protected let m_runtimeMappin: wref<RuntimeMappin>;

  protected let m_root: wref<inkCompoundWidget>;

  protected let m_isMainQuest: Bool;

  @default(QuestMappinController, false)
  protected let m_shouldHideWhenClamped: Bool;

  @default(QuestMappinController, false)
  protected let m_isCompletedPhase: Bool;

  protected let m_animProxy: ref<inkAnimProxy>;

  protected let m_animOptions: inkAnimOptions;

  private let m_vehicleAlreadySummonedTime: EngineTime;

  private let m_vehiclePulseTimeSecs: Float;

  private let m_vehicleMappinComponent: ref<VehicleMappinComponent>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    this.m_animOptions.playReversed = false;
    this.m_animOptions.executionDelay = 0.00;
    this.m_animOptions.loopType = inkanimLoopType.Cycle;
    this.m_animOptions.loopInfinite = true;
    this.m_aboveWidget = this.GetWidget(n"Canvas/above");
    this.m_belowWidget = this.GetWidget(n"Canvas/below");
    inkWidgetRef.SetVisible(this.m_selector, false);
    inkWidgetRef.SetVisible(this.m_portalIcon, false);
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehicleMappinComponent) {
      this.m_vehicleMappinComponent.OnUnitialize();
    };
  }

  protected cb func OnIntro() -> Bool {
    let vehicleMappin: wref<VehicleMappin>;
    this.m_mappin = this.GetMappin();
    this.m_questMappin = this.m_mappin as QuestMappin;
    this.m_runtimeMappin = this.m_mappin as RuntimeMappin;
    let mappinVariant: gamedataMappinVariant = this.m_mappin.GetVariant();
    this.m_isMainQuest = Equals(mappinVariant, gamedataMappinVariant.DefaultQuestVariant);
    if inkWidgetRef.IsValid(this.distanceText) {
      inkWidgetRef.SetVisible(this.distanceText, this.ShouldShowDistance());
    };
    if inkWidgetRef.IsValid(this.displayName) {
      inkWidgetRef.SetVisible(this.displayName, this.ShouldShowDisplayName());
      inkTextRef.SetLetterCase(this.displayName, textLetterCase.UpperCase);
      inkTextRef.SetText(this.displayName, this.m_mappin.GetDisplayName());
    };
    inkWidgetRef.SetVisible(this.iconWidget, true);
    vehicleMappin = this.m_mappin as VehicleMappin;
    if IsDefined(vehicleMappin) {
      this.m_vehicleMappinComponent = new VehicleMappinComponent();
      this.m_vehicleMappinComponent.OnInitialize(this, vehicleMappin);
    };
    this.OnUpdate();
  }

  protected cb func OnUpdate() -> Bool {
    this.UpdateVisibility();
    inkWidgetRef.SetVisible(this.m_arrowPart, this.isCurrentlyClamped);
    if inkWidgetRef.IsValid(this.m_portalIcon) {
      inkWidgetRef.SetVisible(this.m_portalIcon, this.IsGPSPortal());
    };
    this.UpdateDistanceText();
    this.UpdateDisplayName();
    this.UpdateAboveBelowVerticalRelation();
    this.UpdateIcon();
    this.UpdateRootState();
    this.UpdateTrackedState();
  }

  protected final func UpdateAboveBelowVerticalRelation() -> Void {
    let animPlayer: ref<animationPlayer>;
    let distance: Float;
    let isAbove: Bool;
    let isBelow: Bool;
    let shouldShowVertRelation: Bool;
    let vertRelation: gamemappinsVerticalPositioning;
    if this.m_aboveWidget == null && this.m_belowWidget == null {
      return;
    };
    vertRelation = this.GetVerticalRelationToPlayer();
    distance = this.GetDistanceToPlayer();
    shouldShowVertRelation = this.GetRootWidget().IsVisible() && !this.isCurrentlyClamped && !this.nameplateVisible && distance >= MappinUIUtils.GetGlobalProfile().VerticalRelationVisibleRangeMin() && distance <= MappinUIUtils.GetGlobalProfile().VerticalRelationVisibleRangeMax();
    isAbove = shouldShowVertRelation && Equals(vertRelation, gamemappinsVerticalPositioning.Above);
    isBelow = shouldShowVertRelation && Equals(vertRelation, gamemappinsVerticalPositioning.Below);
    this.m_aboveWidget.SetVisible(isAbove);
    this.m_belowWidget.SetVisible(isBelow);
    animPlayer = this.GetAnimPlayer_AboveBelow();
    if animPlayer != null {
      animPlayer.PlayOrStop(isAbove || isBelow);
    };
  }

  protected cb func OnNameplate(isNameplateVisible: Bool, nameplateController: wref<NpcNameplateGameController>) -> Bool {
    this.nameplateVisible = isNameplateVisible;
    if isNameplateVisible {
      this.OverrideScaleByDistance(false);
      this.SetProjectToScreenSpace(false);
    } else {
      this.OverrideScaleByDistance(true);
      this.SetProjectToScreenSpace(true);
    };
    this.OnUpdate();
  }

  public final func OnVehicleAreadySummoned() -> Void {
    let animOptions: inkAnimOptions;
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = false;
    animOptions.loopCounter = 3u;
    this.PlayLibraryAnimation(n"blink", animOptions);
  }

  private final func SetShouldHideWhenClamped(flag: Bool) -> Void {
    this.m_shouldHideWhenClamped = flag;
    this.UpdateVisibility();
  }

  private func UpdateVisibility() -> Void {
    let isInQuestArea: Bool = this.m_questMappin != null && this.m_questMappin.IsInsideTrigger();
    let showWhenClamped: Bool = this.isCurrentlyClamped ? !this.m_shouldHideWhenClamped : true;
    let shouldBeVisible: Bool = this.m_mappin.IsVisible() && showWhenClamped && !isInQuestArea;
    this.SetRootVisible(shouldBeVisible);
  }

  protected func UpdateIcon() -> Void {
    let grenadeData: ref<GrenadeMappinData>;
    let opacity: Float;
    let scale: Float;
    let texturePart: CName;
    let mappinVariant: gamedataMappinVariant = this.m_mappin.GetVariant();
    let mappinPhase: gamedataMappinPhase = this.m_mappin.GetPhase();
    let interactionMappin: ref<InteractionMappin> = this.m_mappin as InteractionMappin;
    if Equals(mappinVariant, gamedataMappinVariant.GrenadeVariant) {
      grenadeData = this.m_mappin.GetScriptData() as GrenadeMappinData;
      if IsDefined(grenadeData) && TDBID.IsValid(grenadeData.m_iconID) {
        this.SetTexture(this.iconWidget, grenadeData.m_iconID);
      } else {
        texturePart = MappinUIUtils.MappinToTexturePart(mappinVariant, mappinPhase);
        inkImageRef.SetTexturePart(this.iconWidget, texturePart);
      };
    } else {
      if IsDefined(interactionMappin) {
        this.SetTexture(this.iconWidget, interactionMappin.GetIconRecordID());
      } else {
        texturePart = MappinUIUtils.MappinToTexturePart(mappinVariant, mappinPhase);
        inkImageRef.SetTexturePart(this.iconWidget, texturePart);
      };
    };
    this.m_isCompletedPhase = Equals(mappinPhase, gamedataMappinPhase.CompletedPhase);
    opacity = this.m_isCompletedPhase ? MappinUIUtils.GetGlobalProfile().CompletedPOIOpacity() : 1.00;
    scale = this.IsGPSPortal() ? MappinUIUtils.GetGlobalProfile().GpsPortalIconScale() : 1.00;
    inkWidgetRef.SetOpacity(this.iconWidget, opacity);
    inkWidgetRef.SetScale(this.iconWidget, new Vector2(scale, scale));
  }

  private func ComputeRootState() -> CName {
    let filterGroup: wref<MappinUIFilterGroup_Record>;
    let grenadeData: ref<GrenadeMappinData>;
    let grenadeType: EGrenadeType;
    let stateName: CName;
    if this.m_isCompletedPhase {
      stateName = n"QuestComplete";
    } else {
      if this.m_mappin != null {
        if this.m_mappin.IsExactlyA(n"gamemappinsGrenadeMappin") {
          grenadeData = this.m_mappin.GetScriptData() as GrenadeMappinData;
          grenadeType = grenadeData.m_grenadeType;
          switch grenadeType {
            case EGrenadeType.Frag:
              stateName = n"FragGrenade";
              break;
            case EGrenadeType.Flash:
              stateName = n"FlashGrenade";
              break;
            case EGrenadeType.Piercing:
              stateName = n"PiercingGrenade";
              break;
            case EGrenadeType.EMP:
              stateName = n"EMPGrenade";
              break;
            case EGrenadeType.Biohazard:
              stateName = n"BiohazardGrenade";
              break;
            case EGrenadeType.Incendiary:
              stateName = n"IncendiaryGrenade";
              break;
            case EGrenadeType.Recon:
              stateName = n"ReconGrenade";
              break;
            case EGrenadeType.Cutting:
              stateName = n"CuttingGrenade";
              break;
            case EGrenadeType.Sonic:
              stateName = n"SonicGrenade";
              break;
            default:
              stateName = n"FragGrenade";
          };
        } else {
          if this.m_mappin.IsExactlyA(n"gamemappinsInteractionMappin") {
            stateName = this.m_mappin.IsQuestImportant() ? n"Quest" : n"InteractionDefault";
          } else {
            filterGroup = MappinUIUtils.GetFilterGroup(this.m_mappin.GetVariant());
            if IsDefined(filterGroup) {
              stateName = filterGroup.WidgetState();
            };
          };
        };
      };
    };
    if Equals(stateName, n"") {
      stateName = n"Quest";
    };
    return stateName;
  }

  protected final func IsTagged() -> Bool {
    return IsDefined(this.GetVisualData()) && this.GetVisualData().m_isTagged;
  }

  protected final func IsQuest() -> Bool {
    return IsDefined(this.GetVisualData()) && this.GetVisualData().m_isQuest;
  }

  protected final func IsVisibleThruWalls() -> Bool {
    return IsDefined(this.GetVisualData()) && this.GetVisualData().m_visibleThroughWalls;
  }

  protected final func GetMappinVisualState() -> EMappinVisualState {
    return IsDefined(this.GetVisualData()) ? this.GetVisualData().m_mappinVisualState : EMappinVisualState.Default;
  }

  protected final func GetQuality() -> gamedataQuality {
    return IsDefined(this.GetVisualData()) ? this.GetVisualData().m_quality : gamedataQuality.Invalid;
  }

  protected final func IsIconic() -> Bool {
    return this.GetVisualData().m_isIconic;
  }

  public const func GetVisualData() -> ref<GameplayRoleMappinData> {
    let dat: ref<GameplayRoleMappinData>;
    if IsDefined(this.m_mappin) {
      dat = this.m_mappin.GetScriptData() as GameplayRoleMappinData;
    };
    return dat;
  }

  protected final func GetMappinVarient() -> gamedataMappinVariant {
    return this.m_mappin.GetVariant();
  }
}

public class QuestAnimationMappinController extends BaseQuestMappinController {

  private let m_mappin: wref<QuestMappin>;

  private let m_animationRecord: ref<UIAnimation_Record>;

  private let m_animProxy: ref<inkAnimProxy>;

  @default(QuestAnimationMappinController, false)
  private let m_playing: Bool;

  protected cb func OnInitialize() -> Bool {
    this.SetRootVisible(this.m_playing);
  }

  protected cb func OnIntro() -> Bool {
    this.m_mappin = this.GetMappin() as QuestMappin;
    this.m_animationRecord = TweakDBInterface.GetUIAnimationRecord(this.m_mappin.GetUIAnimationRecordID());
    this.OnUpdate();
  }

  protected cb func OnUpdate() -> Bool {
    let animOptions: inkAnimOptions;
    let isVisible: Bool = this.m_mappin.IsVisible();
    if NotEquals(this.m_playing, isVisible) {
      this.m_playing = isVisible;
      if IsDefined(this.m_animProxy) {
        this.m_animProxy.Stop();
      };
      if this.m_playing {
        if this.m_animationRecord.Loop() {
          animOptions.loopType = inkanimLoopType.Cycle;
          animOptions.loopInfinite = true;
        };
        this.m_animProxy = this.PlayLibraryAnimation(this.m_animationRecord.AnimationName(), animOptions);
      };
      this.SetRootVisible(this.m_playing);
    };
  }
}

public class VehicleMappinComponent extends IScriptable {

  private let m_questMappinController: wref<QuestMappinController>;

  private let m_vehicleMappin: wref<VehicleMappin>;

  private let m_vehicle: wref<VehicleObject>;

  private let m_vehicleEntityID: EntityID;

  @default(VehicleMappinComponent, false)
  private let m_playerMounted: Bool;

  @default(VehicleMappinComponent, false)
  private let m_vehicleEnRoute: Bool;

  private let m_scheduleDiscreteModeDelayID: DelayID;

  private let m_invalidDelayID: DelayID;

  @default(VehicleMappinComponent, false)
  private let m_init: Bool;

  private let m_vehicleSummonDataDef: ref<VehicleSummonDataDef>;

  private let m_vehicleSummonDataBB: wref<IBlackboard>;

  private let m_vehicleSummonStateCallback: ref<CallbackHandle>;

  private let m_uiActiveVehicleDataDef: ref<UI_ActiveVehicleDataDef>;

  private let m_uiActiveVehicleDataBB: wref<IBlackboard>;

  private let m_vehPlayerStateDataCallback: ref<CallbackHandle>;

  public final func OnInitialize(questMappinController: wref<QuestMappinController>, vehicleMappin: wref<VehicleMappin>) -> Void {
    this.m_questMappinController = questMappinController;
    this.m_vehicleMappin = vehicleMappin;
    this.m_vehicle = this.m_vehicleMappin.GetVehicle();
    this.m_vehicleEntityID = this.m_vehicle.GetEntityID();
    this.m_vehicleSummonDataDef = GetAllBlackboardDefs().VehicleSummonData;
    this.m_vehicleSummonDataBB = GameInstance.GetBlackboardSystem(this.m_vehicle.GetGame()).Get(this.m_vehicleSummonDataDef);
    this.m_vehicleSummonStateCallback = this.m_vehicleSummonDataBB.RegisterListenerUint(this.m_vehicleSummonDataDef.SummonState, this, n"OnVehicleSummonStateChanged");
    this.m_uiActiveVehicleDataDef = GetAllBlackboardDefs().UI_ActiveVehicleData;
    this.m_uiActiveVehicleDataBB = GameInstance.GetBlackboardSystem(this.m_vehicle.GetGame()).Get(this.m_uiActiveVehicleDataDef);
    this.m_vehPlayerStateDataCallback = this.m_uiActiveVehicleDataBB.RegisterListenerVariant(this.m_uiActiveVehicleDataDef.VehPlayerStateData, this, n"OnActiveVechicleDataChanged");
    this.OnActiveVechicleDataChanged(this.m_uiActiveVehicleDataBB.GetVariant(this.m_uiActiveVehicleDataDef.VehPlayerStateData));
    this.OnVehicleSummonStateChanged(this.m_vehicleSummonDataBB.GetUint(this.m_vehicleSummonDataDef.SummonState));
  }

  public final func OnUnitialize() -> Void {
    this.m_vehicleSummonDataBB.UnregisterListenerUint(this.m_vehicleSummonDataDef.SummonState, this.m_vehicleSummonStateCallback);
    this.m_uiActiveVehicleDataBB.UnregisterListenerVariant(this.m_uiActiveVehicleDataDef.VehPlayerStateData, this.m_vehPlayerStateDataCallback);
  }

  private final func VehicleIsLatestSummoned() -> Bool {
    return this.m_vehicleEntityID == this.m_vehicleSummonDataBB.GetEntityID(this.m_vehicleSummonDataDef.SummonedVehicleEntityID);
  }

  private final func SetActive(active: Bool) -> Void {
    this.m_vehicleMappin.SetActive(active);
    this.TryScheduleDiscreteMode();
  }

  private final func TryScheduleDiscreteMode() -> Void {
    let vehicleDelayCallback: ref<VehicleMappinDelayedDiscreteModeCallback>;
    this.SetDiscreteMode(false);
    if this.m_scheduleDiscreteModeDelayID != this.m_invalidDelayID {
      GameInstance.GetDelaySystem(this.m_vehicle.GetGame()).CancelCallback(this.m_scheduleDiscreteModeDelayID);
    };
    if !this.m_vehicleEnRoute {
      vehicleDelayCallback = new VehicleMappinDelayedDiscreteModeCallback();
      vehicleDelayCallback.m_vehicleMappinComponent = this;
      this.m_scheduleDiscreteModeDelayID = GameInstance.GetDelaySystem(this.m_vehicle.GetGame()).DelayCallback(vehicleDelayCallback, 10.00);
    };
  }

  public final func SetDiscreteMode(discrete: Bool) -> Void {
    this.m_questMappinController.OverrideClamp(!discrete);
    this.m_vehicleMappin.EnableVisibilityThroughWalls(!discrete);
  }

  protected cb func OnVehicleSummonStateChanged(value: Uint32) -> Bool {
    let summonState: vehicleSummonState = IntEnum(value);
    if this.m_vehicleMappin.IsActive() && (!this.m_init || this.VehicleIsLatestSummoned()) {
      if this.m_vehicleEnRoute && NotEquals(summonState, vehicleSummonState.AlreadySummoned) {
        this.m_vehicleEnRoute = false;
      } else {
        if Equals(summonState, vehicleSummonState.EnRoute) {
          this.m_vehicleEnRoute = true;
        };
      };
      if Equals(summonState, vehicleSummonState.AlreadySummoned) {
        this.m_questMappinController.OnVehicleAreadySummoned();
      };
      this.SetActive(true);
    };
    this.m_init = true;
  }

  protected cb func OnActiveVechicleDataChanged(vehPlayerStateData: Variant) -> Bool {
    let playerMounted: Bool;
    let vehData: VehEntityPlayerStateData = FromVariant(vehPlayerStateData);
    if this.m_vehicleEntityID == vehData.entID {
      playerMounted = vehData.state > 0;
      if NotEquals(this.m_playerMounted, playerMounted) {
        this.m_playerMounted = playerMounted;
        this.SetActive(!this.m_playerMounted);
      };
    };
  }
}

public class VehicleMappinDelayedDiscreteModeCallback extends DelayCallback {

  public let m_vehicleMappinComponent: wref<VehicleMappinComponent>;

  public func Call() -> Void {
    if IsDefined(this.m_vehicleMappinComponent) {
      this.m_vehicleMappinComponent.SetDiscreteMode(true);
    };
  }
}
