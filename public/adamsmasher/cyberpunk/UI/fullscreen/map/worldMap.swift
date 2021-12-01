
public native class WorldMapMenuGameController extends MappinsContainerController {

  private edit native let tooltipContainer: inkCompoundRef;

  private edit native let tooltipOffset: inkMargin;

  private edit native let districtsContainer: inkCompoundRef;

  private edit native let subdistrictsContainer: inkCompoundRef;

  private edit native const let isZoomToMappinEnabled: Bool;

  private edit let m_contentWidget: inkWidgetRef;

  private edit let m_timeSkipBtn: inkWidgetRef;

  private edit let m_gameTimeText: inkTextRef;

  private edit let m_zoomContainer: inkWidgetRef;

  private edit let m_zoomLevelContainer: inkWidgetRef;

  private edit let m_zoomLevelText: inkTextRef;

  private edit let m_filterContainer: inkWidgetRef;

  private edit let m_filterText: inkTextRef;

  private edit let m_fastTravelInstructions: inkWidgetRef;

  private edit let m_legendWrapper: inkWidgetRef;

  private edit let m_districtIconImage: inkImageRef;

  private edit let m_districtNameText: inkTextRef;

  private edit let m_subdistrictNameText: inkTextRef;

  private edit let m_questLinkInputHint: inkWidgetRef;

  private edit let m_questContainer: inkWidgetRef;

  private edit let m_questName: inkTextRef;

  private edit let m_objectiveName: inkTextRef;

  @default(WorldMapMenuGameController, 0.8f)
  private edit let m_rightAxisZoomThreshold: Float;

  private native const let districtView: gameuiEWorldMapDistrictView;

  private native const let selectedDistrict: gamedataDistrict;

  private native const let canChangeCustomFilter: Bool;

  private native let selectedMappin: wref<BaseWorldMapMappinController>;

  private let m_view: EWorldMapView;

  private let m_cameraMode: gameuiEWorldMapCameraMode;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_tooltipController: wref<WorldMapTooltipContainer>;

  private let m_legendController: wref<WorldMapLegendController>;

  private let m_timeSkipPopupToken: ref<inkGameNotificationToken>;

  private let m_gameTimeTextParams: ref<inkTextParams>;

  private let m_player: wref<GameObject>;

  private let m_journalManager: wref<JournalManager>;

  private let m_mappinSystem: wref<MappinSystem>;

  private let m_mapBlackboard: wref<IBlackboard>;

  private let m_mapDefinition: ref<UI_MapDef>;

  private let m_trackedObjective: wref<JournalQuestObjectiveBase>;

  private let m_trackedQuest: wref<JournalQuest>;

  private let m_mappinsPositions: array<Vector3>;

  @default(WorldMapMenuGameController, 0.f)
  private let m_lastRightAxisYAmount: Float;

  @default(WorldMapMenuGameController, false)
  private let m_justOpenedQuestJournal: Bool;

  public let m_initPosition: Vector3;

  protected final native func IsEntitySetup() -> Bool;

  protected final native func IsEntityAttachedAndSetup() -> Bool;

  protected final native func GetSettings() -> ref<WorldMapSettings_Record>;

  protected final native func GetEntityPreview() -> wref<inkWorldMapPreviewGameController>;

  protected final native func SetSelectedMappin(mappinController: ref<BaseWorldMapMappinController>) -> Void;

  protected final native func GetCustomFilter() -> gamedataWorldMapFilter;

  protected final native func SetCustomFilter(filter: gamedataWorldMapFilter) -> Void;

  protected final native func SetMapCursorEnabled(enabled: Bool) -> Void;

  protected final native func SetFloorPlanVisible(visible: Bool) -> Void;

  protected final native func TrackMappin(mappinController: ref<BaseMappinBaseController>) -> Void;

  protected final native func UntrackMappin() -> Void;

  protected final native func TrackCustomPositionMappin() -> Void;

  protected final native func UntrackCustomPositionMappin() -> Void;

  protected final native func SetMappinVisited(mappinController: ref<BaseWorldMapMappinController>) -> Void;

  protected final native func MoveToPlayer() -> Void;

  protected final native func ZoomToMappin(mappinController: ref<BaseWorldMapMappinController>) -> Void;

  protected final native func ZoomWithMouse(zoomIn: Bool) -> Void;

  protected final native func SetMousePanEnabled(enabled: Bool) -> Void;

  protected final native func SetMouseRotateEnabled(enabled: Bool) -> Void;

  protected final native func AreDistrictsVisible() -> Bool;

  protected final native func GetCurrentZoom() -> Float;

  protected final native func CanDebugTeleport() -> Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_player = this.GetPlayerControlledObject();
    this.m_journalManager = GameInstance.GetJournalManager(this.m_player.GetGame());
    this.m_mappinSystem = GameInstance.GetMappinSystem(this.m_player.GetGame());
    this.m_tooltipController = inkWidgetRef.GetController(this.tooltipContainer) as WorldMapTooltipContainer;
    this.m_legendController = inkWidgetRef.GetController(this.m_legendWrapper) as WorldMapLegendController;
    inkWidgetRef.SetVisible(this.m_fastTravelInstructions, false);
    this.HideAllTooltips();
    this.m_cameraMode = gameuiEWorldMapCameraMode.TopDown;
    this.RefreshInputHints();
    this.UpdateGameTime();
    this.SetMapView(EWorldMapView.Map);
    this.m_mapDefinition = GetAllBlackboardDefs().UI_Map;
    this.m_mapBlackboard = this.GetBlackboardSystem().Get(this.m_mapDefinition);
    this.m_mapBlackboard.SignalString(this.m_mapDefinition.currentLocation);
    this.m_journalManager.RegisterScriptCallback(this, n"OnTrackedEntryChanges", gameJournalListenerType.Tracked);
    this.UpdateTrackedQuest();
    this.m_mapBlackboard.SetString(this.m_mapDefinition.currentState, "Initialized");
    GameInstance.GetTimeSystem(this.m_player.GetGame()).SetTimeDilation(n"WorldMap", 0.00);
    GameInstance.GetGodModeSystem(this.m_player.GetGame()).AddGodMode(this.m_player.GetEntityID(), gameGodModeType.Invulnerable, n"WorldMap");
    inkWidgetRef.SetVisible(this.m_contentWidget, false);
    this.PlayLibraryAnimation(n"OnShowMenu");
    if this.IsFastTravelEnabled() {
      inkWidgetRef.SetVisible(this.m_questContainer, false);
    };
  }

  protected cb func OnUninitialize() -> Bool {
    GameInstance.GetTimeSystem(this.m_player.GetGame()).UnsetTimeDilation(n"WorldMap");
    GameInstance.GetGodModeSystem(this.m_player.GetGame()).RemoveGodMode(this.m_player.GetEntityID(), gameGodModeType.Invulnerable, n"WorldMap");
    this.DisableFastTravel();
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
    this.m_mapBlackboard.SetString(this.m_mapDefinition.currentState, "Uninitialized");
  }

  protected cb func OnTrackedEntryChanges(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    this.UpdateTrackedQuest();
  }

  private final func UpdateTrackedQuest() -> Void {
    let hasTrackedQuest: Bool;
    let trackedPhase: wref<JournalQuestPhase>;
    ArrayClear(this.m_mappinsPositions);
    if this.IsFastTravelEnabled() {
      return;
    };
    this.m_trackedObjective = this.m_journalManager.GetTrackedEntry() as JournalQuestObjectiveBase;
    if this.m_trackedObjective != null {
      inkTextRef.SetText(this.m_objectiveName, this.m_trackedObjective.GetDescription());
      this.m_mappinSystem.GetQuestMappinPositionsByObjective(Cast(this.m_journalManager.GetEntryHash(this.m_trackedObjective)), this.m_mappinsPositions);
      trackedPhase = this.m_journalManager.GetParentEntry(this.m_trackedObjective) as JournalQuestPhase;
      if trackedPhase != null {
        this.m_trackedQuest = this.m_journalManager.GetParentEntry(trackedPhase) as JournalQuest;
        if this.m_trackedQuest != null {
          inkWidgetRef.SetVisible(this.m_questContainer, true);
          inkTextRef.SetText(this.m_questName, this.m_trackedQuest.GetTitle(this.m_journalManager));
          hasTrackedQuest = true;
        };
      };
    };
    inkWidgetRef.SetVisible(this.m_questContainer, hasTrackedQuest);
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let mapMenuUserData: ref<MapMenuUserData> = userData as MapMenuUserData;
    if IsDefined(mapMenuUserData) {
      this.m_initPosition = mapMenuUserData.m_moveTo;
    };
  }

  protected cb func OnEntityAttached() -> Bool {
    let delayEvent: ref<MapNavigationDelay>;
    let fastTravelEnabled: Bool;
    let mappinSpawnContainer: wref<inkCompoundWidget> = this.GetSpawnContainer();
    mappinSpawnContainer.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverMappin");
    mappinSpawnContainer.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOutMappin");
    inkWidgetRef.RegisterToCallback(this.m_timeSkipBtn, n"OnRelease", this, n"OnPressTimeSkip");
    this.RegisterToGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnPressInput");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnReleaseInput");
    this.RegisterToGlobalInputCallback(n"OnPostOnHold", this, n"OnHoldInput");
    this.m_cameraMode = this.GetEntityPreview().GetCameraMode();
    fastTravelEnabled = this.IsFastTravelEnabled();
    inkWidgetRef.SetVisible(this.m_fastTravelInstructions, fastTravelEnabled);
    if fastTravelEnabled {
      this.UpdateCustomFilter(gamedataWorldMapFilter.FastTravel);
    };
    inkWidgetRef.SetVisible(this.m_questLinkInputHint, !fastTravelEnabled);
    if this.m_initPosition.X != 0.00 && this.m_initPosition.Y != 0.00 && this.m_initPosition.Z != 0.00 {
      delayEvent = new MapNavigationDelay();
      this.QueueEvent(delayEvent);
    };
    this.m_mapBlackboard.SetString(this.m_mapDefinition.currentState, "EntityAttached");
    inkWidgetRef.SetVisible(this.m_contentWidget, true);
    this.PlayLibraryAnimation(n"OnMapLoaded");
    this.RefreshInputHints();
  }

  protected cb func OnMapNavigationDelay(evt: ref<MapNavigationDelay>) -> Bool {
    this.GetEntityPreview().MoveTo(this.m_initPosition);
  }

  protected cb func OnEntityDetached() -> Bool {
    let mappinSpawnContainer: wref<inkCompoundWidget> = this.GetSpawnContainer();
    if IsDefined(mappinSpawnContainer) {
      mappinSpawnContainer.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOverMappin");
      mappinSpawnContainer.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOutMappin");
    };
    inkWidgetRef.UnregisterFromCallback(this.m_timeSkipBtn, n"OnRelease", this, n"OnPressTimeSkip");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnPressInput");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnHold", this, n"OnHoldInput");
  }

  protected cb func OnZoomLevelChanged(oldLevel: Int32, newLevel: Int32) -> Bool {
    let relativePosY: Float;
    let showZoomLevel: Bool = false;
    let containerSize: Vector2 = inkWidgetRef.GetSize(this.m_zoomContainer);
    switch this.m_cameraMode {
      case gameuiEWorldMapCameraMode.Free:
      case gameuiEWorldMapCameraMode.TopDown:
        break;
      case gameuiEWorldMapCameraMode.ZoomLevels:
        relativePosY = (containerSize.Y * Cast(newLevel)) / Cast(this.GetTotalZoomLevels() - 1);
        showZoomLevel = true;
    };
    inkWidgetRef.SetMargin(this.m_zoomLevelContainer, 0.00, relativePosY, 0.00, 0.00);
    inkTextRef.SetText(this.m_zoomLevelText, IntToString(newLevel + 1));
    inkWidgetRef.SetVisible(this.m_zoomContainer, showZoomLevel);
    inkWidgetRef.SetVisible(this.m_zoomLevelContainer, showZoomLevel);
    if IsDefined(this.selectedMappin) && !this.selectedMappin.GetRootWidget().IsInteractive() {
      this.SetSelectedMappin(null);
    };
    this.PlaySound(n"Button", n"OnHover");
  }

  protected cb func OnZoomTransitionFinished() -> Bool {
    this.UpdateSelectedMappinTooltip();
  }

  protected cb func OnZoomToMappinEnabledChanged(flag: Bool) -> Bool {
    this.UpdateSelectedMappinTooltip();
  }

  protected cb func OnCanChangeCustomFilterChanged(flag: Bool) -> Bool {
    inkWidgetRef.SetVisible(this.m_filterContainer, flag);
  }

  protected cb func OnSelectedMappinChanged(oldController: ref<BaseWorldMapMappinController>, newController: ref<BaseWorldMapMappinController>) -> Bool {
    if IsDefined(oldController) {
      oldController.UnselectMappin();
      this.HideMappinTooltip(oldController);
    };
    if IsDefined(newController) {
      newController.SelectMappin();
      this.SetMappinVisited(newController);
      this.ShowMappinTooltip(newController);
    };
    this.RefreshInputHints();
    this.UpdateCursor();
  }

  protected cb func OnSetZoomLevelEvent(eventData: ref<SetZoomLevelEvent>) -> Bool {
    FTLog("OnSetZoomLevelEvent:" + IntToString(eventData.m_value));
    this.GetEntityPreview().JumpToZoomLevel(eventData.m_value);
  }

  protected cb func OnHoverOverMappin(e: ref<inkPointerEvent>) -> Bool {
    let hoveredController: ref<BaseWorldMapMappinController> = e.GetTarget().GetController() as BaseWorldMapMappinController;
    if IsDefined(hoveredController) && hoveredController.CanSelectMappin() {
      this.SetSelectedMappin(hoveredController);
    };
  }

  protected cb func OnHoverOutMappin(e: ref<inkPointerEvent>) -> Bool {
    this.SetSelectedMappin(null);
  }

  private final func GetDistrictAnimation(view: gameuiEWorldMapDistrictView, show: Bool) -> CName {
    switch view {
      case gameuiEWorldMapDistrictView.Districts:
        return show ? n"OnShowDistricts" : n"OnHideDistricts";
      case gameuiEWorldMapDistrictView.SubDistricts:
        return show ? n"OnShowSubDistricts" : n"OnHideSubDistricts";
    };
  }

  protected cb func OnDistrictViewChanged(oldView: gameuiEWorldMapDistrictView, newView: gameuiEWorldMapDistrictView) -> Bool {
    if NotEquals(oldView, IntEnum(0l)) {
      this.PlayLibraryAnimation(this.GetDistrictAnimation(oldView, false));
    };
    if NotEquals(newView, IntEnum(0l)) {
      this.PlayLibraryAnimation(this.GetDistrictAnimation(newView, true));
      this.ShowDistrictTooltip(this.selectedDistrict);
    } else {
      this.HideDistrictTooltip();
    };
  }

  protected cb func OnUpdateHoveredDistricts(district: gamedataDistrict, subdistrict: gamedataDistrict) -> Bool {
    let districtRecord: wref<District_Record> = MappinUIUtils.GetDistrictRecord(district);
    let subdistrictRecord: wref<District_Record> = MappinUIUtils.GetDistrictRecord(subdistrict);
    inkTextRef.SetLocalizedTextString(this.m_districtNameText, IsDefined(districtRecord) ? districtRecord.LocalizedName() : "LocKey#883");
    inkImageRef.SetTexturePart(this.m_districtIconImage, districtRecord.UiIcon());
    inkTextRef.SetLocalizedTextString(this.m_subdistrictNameText, IsDefined(subdistrictRecord) ? subdistrictRecord.LocalizedName() : "LocKey#883");
    inkWidgetRef.SetVisible(this.m_subdistrictNameText, subdistrictRecord != null);
  }

  protected cb func OnSelectedDistrictChanged(oldDistrict: gamedataDistrict, newDistrict: gamedataDistrict) -> Bool {
    if NotEquals(newDistrict, gamedataDistrict.Invalid) {
      if this.AreDistrictsVisible() {
        this.ShowDistrictTooltip(newDistrict);
      };
    } else {
      this.HideDistrictTooltip();
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    this.PlaySound(n"Button", n"OnPress");
    switch this.m_view {
      case EWorldMapView.Map:
        if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
          this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
        };
        break;
      case EWorldMapView.TimeSkip:
        break;
      case EWorldMapView.FloorPlan:
        this.TransitionMapView(EWorldMapView.Map);
    };
  }

  private final func CycleCameraMode() -> Void {
    if this.IsLegendVisible() {
      this.CloseLegend();
    };
    this.m_cameraMode = Equals(this.m_cameraMode, gameuiEWorldMapCameraMode.TopDown) ? gameuiEWorldMapCameraMode.Free : gameuiEWorldMapCameraMode.TopDown;
    this.GetEntityPreview().SetCameraMode(this.m_cameraMode);
    this.RefreshInputHints();
    if Equals(this.m_cameraMode, gameuiEWorldMapCameraMode.Free) {
      this.PlayLibraryAnimation(n"OnEnterFreeCamera");
    } else {
      this.PlayLibraryAnimation(n"OnExitFreeCamera");
    };
    this.PlaySound(n"Button", n"OnPress");
  }

  private final func CycleCustomFilterPrev() -> Void {
    this.UpdateCustomFilter(WorldMapUtils.CycleWorldMapFilter(this.GetCustomFilter(), false));
  }

  private final func CycleCustomFilterNext() -> Void {
    this.UpdateCustomFilter(WorldMapUtils.CycleWorldMapFilter(this.GetCustomFilter(), true));
  }

  private final func OpenSelectedQuest() -> Void {
    let mappin: wref<IMappin>;
    let questEntry: wref<JournalEntry>;
    if this.HasSelectedMappin() {
      mappin = this.selectedMappin.GetMappin();
      if this.CanOpenJournalForMappin(mappin) {
        questEntry = this.GetMappinJournalEntry(mappin);
        this.OpenQuestInJournal(questEntry);
      };
    };
  }

  private final func OpenTrackedQuest() -> Void {
    if this.m_trackedQuest != null {
      this.OpenQuestInJournal(this.m_trackedQuest);
    };
  }

  private final func OpenQuestInJournal(questEntry: wref<JournalEntry>) -> Void {
    let userData: ref<MessageMenuAttachmentData> = new MessageMenuAttachmentData();
    userData.m_entryHash = this.m_journalManager.GetEntryHash(questEntry);
    let evt: ref<OpenMenuRequest> = new OpenMenuRequest();
    evt.m_menuName = n"quest_log";
    evt.m_eventData.userData = userData;
    evt.m_eventData.m_overrideDefaultUserData = true;
    evt.m_isMainMenu = true;
    this.QueueBroadcastEvent(evt);
    this.m_justOpenedQuestJournal = true;
  }

  private final func UpdateCustomFilter(filter: gamedataWorldMapFilter) -> Void {
    this.SetCustomFilter(filter);
    this.PlaySound(n"Button", n"OnPress");
  }

  protected cb func OnCustomFilterChanged(oldFilter: gamedataWorldMapFilter, newFilter: gamedataWorldMapFilter) -> Bool {
    let filterGroup: wref<MappinUIFilterGroup_Record>;
    let filterName: CName;
    let stateName: CName;
    switch newFilter {
      case gamedataWorldMapFilter.NoFilter:
        filterName = n"UI-Menus-WorldMap-Filter-None";
        break;
      case gamedataWorldMapFilter.Quest:
        filterName = n"UI-Menus-WorldMap-Filter-Quest";
        break;
      case gamedataWorldMapFilter.VehiclesForPurchaseFilter:
        filterName = n"UI-Quests-Labels-VehicleQuests";
        break;
      case gamedataWorldMapFilter.Story:
        filterName = n"UI-Menus-WorldMap-Filter-Story";
        break;
      case gamedataWorldMapFilter.FastTravel:
        filterName = n"UI-Menus-WorldMap-Filter-FastTravel";
        break;
      case gamedataWorldMapFilter.ServicePoint:
        filterName = n"UI-Menus-WorldMap-Filter-ServicePoint";
        break;
      case gamedataWorldMapFilter.DropPoint:
        filterName = n"UI-MappinTypes-Dropbox";
        break;
      case gamedataWorldMapFilter.All:
        filterName = n"UI-Menus-WorldMap-Filter-All";
    };
    if Equals(newFilter, gamedataWorldMapFilter.NoFilter) || Equals(newFilter, gamedataWorldMapFilter.All) {
      stateName = n"Default";
    } else {
      filterGroup = MappinUIUtils.GetFilterGroup(newFilter);
      stateName = filterGroup.WidgetState();
    };
    inkTextRef.SetLocalizedTextScript(this.m_filterText, filterName);
    inkWidgetRef.SetState(this.m_filterText, stateName);
    if IsDefined(this.selectedMappin) && !this.selectedMappin.GetRootWidget().IsInteractive() {
      this.SetSelectedMappin(null);
    };
  }

  private final func SetMappinIconsVisible(visible: Bool) -> Void {
    let mappinSpawnContainer: wref<inkCompoundWidget> = this.GetSpawnContainer();
    mappinSpawnContainer.SetVisible(visible);
  }

  private final func ToggleFloorPlan() -> Void {
    this.TransitionMapView(Equals(this.m_view, EWorldMapView.Map) ? EWorldMapView.FloorPlan : EWorldMapView.Map);
  }

  private final func ToggleTimeSkip() -> Void {
    this.TransitionMapView(Equals(this.m_view, EWorldMapView.Map) ? EWorldMapView.TimeSkip : EWorldMapView.Map);
  }

  private final func ToggleLegend() -> Void {
    this.IsLegendVisible() ? this.CloseLegend() : this.OpenLegend();
    this.RefreshInputHints();
  }

  private final func TransitionMapView(newView: EWorldMapView) -> Void {
    switch this.m_view {
      case EWorldMapView.FloorPlan:
        this.CloseFloorPlan();
        break;
      case EWorldMapView.TimeSkip:
        this.CloseTimeSkip();
    };
    switch newView {
      case EWorldMapView.FloorPlan:
        this.OpenFloorPlan();
        break;
      case EWorldMapView.TimeSkip:
        this.OpenTimeSkip();
    };
    this.SetMapView(newView);
  }

  private final func SetMapView(newView: EWorldMapView) -> Void {
    this.m_view = newView;
    this.SetMapCursorEnabled(Equals(this.m_view, EWorldMapView.Map));
    this.RefreshInputHints();
  }

  private final func OpenFloorPlan() -> Void {
    this.SetFloorPlanVisible(true);
    this.SetMappinIconsVisible(false);
  }

  private final func CloseFloorPlan() -> Void {
    this.SetFloorPlanVisible(false);
    this.SetMappinIconsVisible(true);
  }

  private final func OpenLegend() -> Void {
    this.m_legendController.Show();
  }

  private final func CloseLegend() -> Void {
    this.m_legendController.Hide();
  }

  private final func OpenTimeSkip() -> Void {
    let data: ref<TimeSkipPopupData> = new TimeSkipPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\time_skip_popup_new.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    this.m_timeSkipPopupToken = this.ShowGameNotification(data);
    this.m_timeSkipPopupToken.RegisterListener(this, n"OnTimeSkipPopupClosed");
    this.SetMappinIconsVisible(false);
  }

  private final func CloseTimeSkip() -> Void {
    this.SetMappinIconsVisible(true);
    this.UpdateGameTime();
  }

  protected cb func OnTimeSkipPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_timeSkipPopupToken = null;
    this.TransitionMapView(EWorldMapView.Map);
  }

  private final func UpdateGameTime() -> Void {
    GameTimeUtils.UpdateGameTimeText(GameInstance.GetTimeSystem((this.GetOwnerEntity() as GameObject).GetGame()), this.m_gameTimeText, this.m_gameTimeTextParams);
  }

  private final func TryFastTravel() -> Void {
    if !this.HasSelectedMappin() {
      return;
    };
    switch this.selectedMappin.GetMappinVariant() {
      case gamedataMappinVariant.FastTravelVariant:
        this.FastTravel();
        this.PlaySound(n"MapPin", n"OnCreate");
    };
  }

  private final func TryTrackQuestOrSetWaypoint() -> Void {
    if this.IsFastTravelEnabled() {
      return;
    };
    if this.selectedMappin != null {
      if !this.selectedMappin.IsCollection() {
        if this.CanQuestTrackMappin(this.selectedMappin) {
          if !this.IsMappinQuestTracked(this.selectedMappin) {
            this.UntrackCustomPositionMappin();
            this.TrackQuestMappin(this.selectedMappin);
            this.PlaySound(n"MapPin", n"OnEnable");
          };
        } else {
          if this.CanPlayerTrackMappin(this.selectedMappin) {
            if this.selectedMappin.IsCustomPositionTracked() {
              this.UntrackCustomPositionMappin();
              this.SetSelectedMappin(null);
              this.PlaySound(n"MapPin", n"OnDisable");
            } else {
              if this.selectedMappin.IsPlayerTracked() {
                this.UntrackMappin();
                this.PlaySound(n"MapPin", n"OnDisable");
              } else {
                this.UntrackCustomPositionMappin();
                this.TrackMappin(this.selectedMappin);
                this.PlaySound(n"MapPin", n"OnEnable");
              };
            };
          };
        };
        this.UpdateSelectedMappinTooltip();
      };
    } else {
      this.TrackCustomPositionMappin();
    };
    this.PlaySound(n"MapPin", n"OnCreate");
    this.UpdateCursor();
  }

  private final func TrackQuestMappin(controller: ref<BaseMappinBaseController>) -> Void {
    let journalEntry: ref<JournalEntry>;
    if controller == null {
      return;
    };
    journalEntry = this.GetMappinJournalEntry(controller.GetMappin());
    if journalEntry == null {
      return;
    };
    this.m_journalManager.TrackEntry(journalEntry);
  }

  private final func FastTravel() -> Void {
    let mappin: ref<FastTravelMappin>;
    let nextLoadingTypeEvt: ref<inkSetNextLoadingScreenEvent>;
    let player: ref<GameObject>;
    let request: ref<PerformFastTravelRequest>;
    if !this.IsFastTravelEnabled() {
      return;
    };
    mappin = this.selectedMappin.GetMappin() as FastTravelMappin;
    player = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerMainGameObject();
    if player == null {
      return;
    };
    request = new PerformFastTravelRequest();
    request.pointData = mappin.GetPointData();
    request.player = player;
    this.GetFastTravelSystem().QueueRequest(request);
    nextLoadingTypeEvt = new inkSetNextLoadingScreenEvent();
    nextLoadingTypeEvt.SetNextLoadingScreenType(inkLoadingScreenType.FastTravel);
    this.QueueBroadcastEvent(nextLoadingTypeEvt);
    this.m_menuEventDispatcher.SpawnEvent(n"OnBack");
  }

  private final func DisableFastTravel() -> Void {
    let request: ref<ToggleFastTravelAvailabilityOnMapRequest> = new ToggleFastTravelAvailabilityOnMapRequest();
    request.isEnabled = false;
    this.GetFastTravelSystem().QueueRequest(request);
  }

  private final func DEBUG_Teleport() -> Void {
    let player: ref<GameObject>;
    if !this.CanDebugTeleport() {
      return;
    };
    if this.selectedMappin != null {
      player = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerMainGameObject();
      GameInstance.GetTeleportationFacility(this.GetOwner().GetGame()).Teleport(player, this.selectedMappin.GetMappin().GetWorldPosition(), Vector4.ToRotation(player.GetWorldForward()));
      this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
    };
  }

  private final func HandleAxisInput(e: ref<inkPointerEvent>) -> Void {
    let entityPreview: wref<inkWorldMapPreviewGameController> = this.GetEntityPreview();
    let amount: Float = e.GetAxisData();
    let canPanAlternate: Bool = NotEquals(this.m_cameraMode, gameuiEWorldMapCameraMode.Free) && !this.IsLegendVisible();
    if e.IsAction(n"world_map_menu_move_horizontal") {
      entityPreview.Move(new Vector4(1.00, 0.00, 0.00, 0.00), amount);
    } else {
      if e.IsAction(n"world_map_menu_move_horizontal_alt") {
        if canPanAlternate {
          entityPreview.Move(new Vector4(1.00, 0.00, 0.00, 0.00), amount);
        };
      } else {
        if e.IsAction(n"world_map_menu_move_vertical") {
          entityPreview.Move(new Vector4(0.00, 1.00, 0.00, 0.00), amount);
        } else {
          if e.IsAction(n"world_map_menu_move_vertical_alt") {
            if canPanAlternate {
              entityPreview.Move(new Vector4(0.00, 1.00, 0.00, 0.00), amount);
            };
          } else {
            if e.IsAction(n"world_map_menu_rotate_yaw") {
              if !this.IsLegendVisible() {
                if Equals(this.m_cameraMode, gameuiEWorldMapCameraMode.Free) {
                  entityPreview.RotateYaw(amount);
                };
              };
            } else {
              if e.IsAction(n"world_map_menu_rotate_pitch") {
                if !this.IsLegendVisible() {
                  switch this.m_cameraMode {
                    case gameuiEWorldMapCameraMode.Free:
                      entityPreview.RotatePitch(amount);
                      break;
                    case gameuiEWorldMapCameraMode.ZoomLevels:
                      this.HandleAxisZoom(e);
                  };
                };
              } else {
                if e.IsAction(n"left_trigger") {
                  switch this.m_cameraMode {
                    case gameuiEWorldMapCameraMode.Free:
                    case gameuiEWorldMapCameraMode.TopDown:
                      entityPreview.ZoomOut(amount);
                  };
                } else {
                  if e.IsAction(n"right_trigger") {
                    switch this.m_cameraMode {
                      case gameuiEWorldMapCameraMode.Free:
                      case gameuiEWorldMapCameraMode.TopDown:
                        entityPreview.ZoomIn(amount);
                    };
                  } else {
                    if e.IsAction(n"world_map_menu_zoom") {
                      switch this.m_cameraMode {
                        case gameuiEWorldMapCameraMode.Free:
                        case gameuiEWorldMapCameraMode.TopDown:
                          if amount != 0.00 {
                            if amount > 0.00 {
                              entityPreview.ZoomIn(amount);
                            } else {
                              entityPreview.ZoomOut(-amount);
                            };
                          };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  }

  private final func HandleAxisZoom(e: ref<inkPointerEvent>) -> Void {
    let amount: Float = e.GetAxisData();
    if this.m_lastRightAxisYAmount > -this.m_rightAxisZoomThreshold && this.m_lastRightAxisYAmount < this.m_rightAxisZoomThreshold {
      if amount <= -this.m_rightAxisZoomThreshold {
        this.GetEntityPreview().ZoomOut();
      } else {
        if amount >= this.m_rightAxisZoomThreshold {
          this.GetEntityPreview().ZoomIn();
        };
      };
    };
    this.m_lastRightAxisYAmount = amount;
  }

  private final func HandlePressInput(e: ref<inkPointerEvent>) -> Void {
    let inFreeCam: Bool = Equals(this.m_cameraMode, gameuiEWorldMapCameraMode.Free);
    if e.IsAction(n"world_map_menu_cycle_camera_mode") {
      this.PlaySound(n"Button", n"OnPress");
      this.CycleCameraMode();
    } else {
      if e.IsAction(n"world_map_menu_toggle_floorplan") {
      } else {
        if e.IsAction(n"world_map_menu_toggle_legend") {
          if !inFreeCam {
            this.PlaySound(n"Button", n"OnPress");
            this.ToggleLegend();
          };
        } else {
          if e.IsAction(n"world_map_menu_time_skip") {
          } else {
            if e.IsAction(n"world_map_menu_fast_travel") {
              this.TryFastTravel();
            } else {
              if e.IsAction(n"world_map_menu_cycle_filter_prev") {
                if !inFreeCam && this.canChangeCustomFilter {
                  this.PlaySound(n"Button", n"OnHover");
                  this.CycleCustomFilterPrev();
                };
              } else {
                if e.IsAction(n"world_map_menu_cycle_filter_next") {
                  if !inFreeCam && this.canChangeCustomFilter {
                    this.PlaySound(n"Button", n"OnHover");
                    this.CycleCustomFilterNext();
                  };
                } else {
                  if e.IsAction(n"world_map_menu_track_waypoint") {
                    if !inFreeCam {
                      this.TryTrackQuestOrSetWaypoint();
                    };
                  } else {
                    if e.IsAction(n"world_map_menu_jump_to_player") {
                      if !this.m_justOpenedQuestJournal && !inFreeCam {
                        this.PlaySound(n"Button", n"OnPress");
                        if (this.selectedMappin as WorldMapPlayerMappinController) == null {
                          this.MoveToPlayer();
                        } else {
                          if ArraySize(this.m_mappinsPositions) > 0 {
                            this.GetEntityPreview().MoveTo(this.m_mappinsPositions[0]);
                          };
                        };
                      };
                    } else {
                      if e.IsAction(n"world_map_menu_open_quest") {
                        if !this.IsFastTravelEnabled() {
                          this.PlaySound(n"Button", n"OnPress");
                          this.OpenSelectedQuest();
                        };
                      } else {
                        if e.IsAction(n"world_map_menu_open_quest_static") {
                          if !this.IsFastTravelEnabled() {
                            this.PlaySound(n"Button", n"OnPress");
                            this.OpenTrackedQuest();
                          };
                        } else {
                          if e.IsAction(n"world_map_menu_zoom_to_mappin") {
                            if this.HasSelectedMappin() && this.CanZoomToMappin(this.selectedMappin) {
                              this.PlaySound(n"Button", n"OnPress");
                              this.ZoomToMappin(this.selectedMappin);
                            };
                          } else {
                            if e.IsAction(n"world_map_menu_zoom_in_mouse") {
                              switch this.m_cameraMode {
                                case gameuiEWorldMapCameraMode.Free:
                                case gameuiEWorldMapCameraMode.TopDown:
                                  this.ZoomWithMouse(true);
                              };
                            } else {
                              if e.IsAction(n"world_map_menu_zoom_out_mouse") {
                                switch this.m_cameraMode {
                                  case gameuiEWorldMapCameraMode.Free:
                                  case gameuiEWorldMapCameraMode.TopDown:
                                    this.ZoomWithMouse(false);
                                };
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    if e.IsAction(n"world_map_menu_move_mouse") {
      this.SetMousePanEnabled(true);
    } else {
      if e.IsAction(n"world_map_menu_rotate_mouse") {
        if inFreeCam {
          this.SetMouseRotateEnabled(true);
        };
      };
    };
  }

  private final func HandleReleaseInput(e: ref<inkPointerEvent>) -> Void {
    let inFreeCam: Bool = Equals(this.m_cameraMode, gameuiEWorldMapCameraMode.Free);
    if e.IsAction(n"world_map_menu_move_mouse") {
      this.SetMousePanEnabled(false);
    } else {
      if e.IsAction(n"world_map_menu_rotate_mouse") {
        if inFreeCam {
          this.SetMouseRotateEnabled(false);
        };
      };
    };
  }

  private final func HandleHoldInput(e: ref<inkPointerEvent>) -> Void {
    let holdProgress: Float = e.GetHoldProgress();
    if holdProgress < 1.00 {
      return;
    };
    if e.IsAction(n"world_map_menu_debug_teleport") {
      this.DEBUG_Teleport();
    };
  }

  private final func HandlePressInput_FloorPlan(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"world_map_menu_toggle_floorplan") {
    } else {
      if e.IsAction(n"world_map_menu_toggle_legend") {
        this.PlaySound(n"Button", n"OnPress");
        this.ToggleLegend();
      };
    };
  }

  private final func HandlePressInput_TimeSkip(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"world_map_menu_time_skip") {
      this.ToggleTimeSkip();
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnPressInput(e: ref<inkPointerEvent>) -> Bool {
    switch this.m_view {
      case EWorldMapView.Map:
        this.HandlePressInput(e);
        break;
      case EWorldMapView.FloorPlan:
        this.HandlePressInput_FloorPlan(e);
        break;
      case EWorldMapView.TimeSkip:
        this.HandlePressInput_TimeSkip(e);
    };
  }

  protected cb func OnReleaseInput(e: ref<inkPointerEvent>) -> Bool {
    switch this.m_view {
      case EWorldMapView.Map:
        this.HandleReleaseInput(e);
    };
  }

  protected cb func OnHoldInput(e: ref<inkPointerEvent>) -> Bool {
    switch this.m_view {
      case EWorldMapView.Map:
        this.HandleHoldInput(e);
    };
  }

  protected cb func OnAxisInput(e: ref<inkPointerEvent>) -> Bool {
    switch this.m_view {
      case EWorldMapView.Map:
        this.HandleAxisInput(e);
    };
  }

  protected cb func OnPressTimeSkip(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
    };
  }

  private final func IsPoliceTooltip(mappinVariant: gamedataMappinVariant) -> Bool {
    switch mappinVariant {
      case gamedataMappinVariant.FailedCrossingVariant:
      case gamedataMappinVariant.SmugglersDenVariant:
      case gamedataMappinVariant.HuntForPsychoVariant:
      case gamedataMappinVariant.HiddenStashVariant:
      case gamedataMappinVariant.ResourceVariant:
      case gamedataMappinVariant.OutpostVariant:
      case gamedataMappinVariant.GangWatchVariant:
        return true;
    };
    return false;
  }

  private final func ShouldDisplayInHud(mappinVariant: gamedataMappinVariant) -> Bool {
    return this.IsPoliceTooltip(mappinVariant);
  }

  private final func GetTooltipType(mappinVariant: gamedataMappinVariant) -> WorldMapTooltipType {
    if this.IsPoliceTooltip(mappinVariant) {
      return WorldMapTooltipType.Police;
    };
    return WorldMapTooltipType.Default;
  }

  private final func ShowMappinTooltip(controller: wref<BaseWorldMapMappinController>) -> Void {
    let mappinVariant: gamedataMappinVariant;
    let tooltipType: WorldMapTooltipType;
    if controller != null {
      mappinVariant = controller.GetMappinVariant();
      tooltipType = this.GetTooltipType(mappinVariant);
      this.UpdateTooltip(tooltipType, controller);
      this.m_tooltipController.Show(tooltipType);
    };
  }

  private final func HideMappinTooltip(controller: wref<BaseWorldMapMappinController>) -> Void {
    let mappinVariant: gamedataMappinVariant;
    let tooltipType: WorldMapTooltipType;
    if controller != null {
      mappinVariant = controller.GetMappinVariant();
      tooltipType = this.GetTooltipType(mappinVariant);
      this.m_tooltipController.Hide(tooltipType);
    };
  }

  private final func ShowDistrictTooltip(district: gamedataDistrict) -> Void {
    let tooltipType: WorldMapTooltipType = WorldMapTooltipType.District;
    if NotEquals(district, gamedataDistrict.Invalid) {
      this.UpdateTooltip(tooltipType, null);
      this.m_tooltipController.Show(tooltipType);
    };
  }

  private final func HideDistrictTooltip() -> Void {
    this.m_tooltipController.Hide(WorldMapTooltipType.District);
  }

  private final func HideAllTooltips() -> Void {
    this.m_tooltipController.HideAll();
  }

  private final func UpdateTooltip(tooltipType: WorldMapTooltipType, controller: wref<BaseWorldMapMappinController>) -> Void {
    let toolTipData: WorldMapTooltipData;
    if controller != null {
      toolTipData.controller = controller;
      toolTipData.mappin = controller.GetMappin();
      toolTipData.journalEntry = this.GetMappinJournalEntry(toolTipData.mappin);
      toolTipData.readJournal = this.CanOpenJournalForMappin(toolTipData.mappin);
      toolTipData.isCollection = controller.IsCollection();
      toolTipData.collectionCount = Cast(controller.collectionCount);
    };
    toolTipData.fastTravelEnabled = this.IsFastTravelEnabled();
    toolTipData.district = this.selectedDistrict;
    this.m_tooltipController.SetData(tooltipType, toolTipData, this);
  }

  private final func UpdateSelectedMappinTooltip() -> Void {
    if IsDefined(this.selectedMappin) {
      this.UpdateTooltip(this.GetTooltipType(this.selectedMappin.GetMappinVariant()), this.selectedMappin);
    };
  }

  private final func CanOpenJournalForMappin(mappin: wref<IMappin>) -> Bool {
    let mappinQuest: wref<JournalQuest>;
    if this.HasSelectedMappin() && !this.IsFastTravelEnabled() {
      mappinQuest = questLogGameController.GetTopQuestEntry(this.m_journalManager, this.GetMappinJournalEntry(mappin));
      return mappinQuest != null;
    };
    return false;
  }

  private final func RefreshInputHints() -> Void {
    let canToggleLegend: Bool;
    let canTrackWaypoint: Bool;
    let hasSelectedMappin: Bool;
    let isFastTravelEnabled: Bool;
    let isFreeCamera: Bool;
    let isLegendVisible: Bool;
    let isTopDownCamera: Bool;
    let priority: Int32 = 1;
    let evt: ref<UpdateInputHintMultipleEvent> = new UpdateInputHintMultipleEvent();
    evt.targetHintContainer = n"WorldMapInputHints";
    this.AddInputHintUpdate(evt, true, n"back", "Common-Access-Close", priority);
    if this.IsEntitySetup() {
      isTopDownCamera = Equals(this.m_cameraMode, gameuiEWorldMapCameraMode.TopDown);
      isFreeCamera = Equals(this.m_cameraMode, gameuiEWorldMapCameraMode.Free);
      isFastTravelEnabled = this.IsFastTravelEnabled();
      hasSelectedMappin = this.HasSelectedMappin();
      isLegendVisible = this.IsLegendVisible();
      this.AddInputHintUpdate(evt, true, n"world_map_menu_cycle_camera_mode", isTopDownCamera ? "UI-ScriptExports-FreeCamera" : "UI-ScriptExports-FixedCamera0", priority);
      canToggleLegend = !isFreeCamera;
      this.AddInputHintUpdate(evt, canToggleLegend, n"world_map_menu_toggle_legend", isLegendVisible ? "UI-ScriptExports-CloseLegend0" : "UI-ScriptExports-Legend0", priority);
      if isFreeCamera {
        this.AddInputHintUpdate(evt, false, n"world_map_menu_jump_to_player", "UI-ScriptExports-JumpToPlayer0", priority);
      } else {
        if (this.selectedMappin as WorldMapPlayerMappinController) == null {
          this.AddInputHintUpdate(evt, true, n"world_map_menu_jump_to_player", "UI-ScriptExports-JumpToPlayer0", priority);
        } else {
          if ArraySize(this.m_mappinsPositions) > 0 {
            this.AddInputHintUpdate(evt, true, n"world_map_menu_jump_to_player", "UI-UserActions-JumpToObjective", priority);
          } else {
            this.AddInputHintUpdate(evt, false, n"world_map_menu_jump_to_player", "UI-UserActions-JumpToObjective", priority);
          };
        };
      };
      this.AddInputHintUpdate(evt, true, n"world_map_menu_zoom_in", "UI-ScriptExports-ZoomIn0", priority);
      this.AddInputHintUpdate(evt, true, n"world_map_menu_zoom_out", "UI-ScriptExports-ZoomOut0", priority);
      this.AddInputHintUpdate(evt, isFreeCamera, n"world_map_fake_rotate", "UI-ScriptExports-Rotate0", priority);
      this.AddInputHintUpdate(evt, true, n"world_map_fake_move", "Gameplay-Player-ButtonHelper-Move", priority);
      canTrackWaypoint = !hasSelectedMappin && !isFreeCamera && !isFastTravelEnabled;
      this.AddInputHintUpdate(evt, canTrackWaypoint, n"world_map_menu_track_waypoint", "UI-Settings-ButtonMappings-Actions-MapTrack", priority);
    };
    this.QueueEvent(evt);
  }

  protected final func AddInputHintUpdate(out evt: ref<UpdateInputHintMultipleEvent>, show: Bool, action: CName, locKey: String, out priority: Int32) -> Void {
    let data: InputHintData;
    data.action = action;
    data.source = n"WorldMap";
    data.localizedLabel = GetLocalizedText(locKey);
    data.sortingPriority = priority;
    data.queuePriority = priority;
    evt.AddInputHint(data, show);
    priority += 1;
  }

  public final func UpdateCursor() -> Void {
    if this.HasSelectedMappin() {
      this.SetCursorContext(n"Hover");
    } else {
      this.SetCursorContext(n"Default");
    };
  }

  public func CreateMappinUIProfile(mappin: wref<IMappin>, mappinVariant: gamedataMappinVariant, customData: ref<MappinControllerCustomData>) -> MappinUIProfile {
    let widgetResource: ResRef = r"base\\gameplay\\gui\\fullscreen\\world_map\\mappins\\default_mappin.inkwidget";
    if IsDefined(customData) {
      if customData.IsA(n"gameuiWorldMapPlayerInitData") {
        widgetResource = r"base\\gameplay\\gui\\fullscreen\\world_map\\mappins\\player_mappin.inkwidget";
      };
    };
    return MappinUIProfile.Create(widgetResource, t"MappinUISpawnProfile.Always", t"MapMappinUIProfile.Default");
  }

  public final const func GetPlayer() -> wref<GameObject> {
    return this.m_player;
  }

  public final const func GetJournalManager() -> wref<JournalManager> {
    return this.m_journalManager;
  }

  private final func GetTotalZoomLevels() -> Int32 {
    let levels: array<wref<WorldMapZoomLevel_Record>>;
    let settings: ref<WorldMapSettings_Record> = this.GetSettings();
    if settings != null {
      settings.ZoomLevels(levels);
      return ArraySize(levels);
    };
    return 0;
  }

  private final func GetFastTravelSystem() -> ref<FastTravelSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetOwner().GetGame()).Get(n"FastTravelSystem") as FastTravelSystem;
  }

  public final func IsFastTravelEnabled() -> Bool {
    return this.GetFastTravelSystem().IsFastTravelEnabledOnMap();
  }

  private final const func IsLegendVisible() -> Bool {
    return this.m_legendController.IsVisible();
  }

  private final func GetOwner() -> ref<GameObject> {
    return this.GetOwnerEntity() as GameObject;
  }

  private final func HasSelectedMappin() -> Bool {
    return this.selectedMappin != null;
  }

  private final const func GetMappinJournalEntry(mappin: ref<IMappin>) -> ref<JournalEntry> {
    let journalPathHash: Uint32 = this.GetMappinJournalPathHash(mappin);
    if journalPathHash != 0u && IsDefined(this.m_journalManager) {
      return this.m_journalManager.GetEntry(journalPathHash);
    };
    return null;
  }

  private final const func GetMappinJournalPathHash(mappin: ref<IMappin>) -> Uint32 {
    let poiMappin: ref<PointOfInterestMappin>;
    let questMappin: ref<QuestMappin>;
    if IsDefined(mappin) {
      questMappin = mappin as QuestMappin;
      if IsDefined(questMappin) {
        return questMappin.GetJournalPathHash();
      };
      poiMappin = mappin as PointOfInterestMappin;
      if IsDefined(poiMappin) {
        return poiMappin.GetJournalPathHash();
      };
    };
    return 0u;
  }

  public final const func CanQuestTrackMappin(mappin: wref<IMappin>) -> Bool {
    let filterGroup: wref<MappinUIFilterGroup_Record>;
    let journalEntry: ref<JournalEntry>;
    let mappinVariant: gamedataMappinVariant;
    if mappin != null {
      mappinVariant = mappin.GetVariant();
      journalEntry = this.GetMappinJournalEntry(mappin);
      filterGroup = MappinUIUtils.GetFilterGroup(mappinVariant);
      if filterGroup != null {
        return journalEntry != null && Equals(filterGroup.WidgetState(), n"Quest");
      };
    };
    return false;
  }

  public final const func CanQuestTrackMappin(controller: wref<BaseWorldMapMappinController>) -> Bool {
    if controller != null {
      return this.CanQuestTrackMappin(controller.GetMappin());
    };
    return false;
  }

  public final const func IsMappinQuestTracked(mappin: wref<IMappin>) -> Bool {
    let journalEntry: ref<JournalEntry>;
    if mappin != null {
      journalEntry = this.GetMappinJournalEntry(mappin);
      if journalEntry != null {
        this.m_journalManager.IsEntryTracked(journalEntry);
      };
    };
    return false;
  }

  public final const func IsMappinQuestTracked(controller: wref<BaseWorldMapMappinController>) -> Bool {
    return this.IsMappinQuestTracked(controller.GetMappin());
  }

  public final const func CanPlayerTrackMappin(mappin: wref<IMappin>) -> Bool {
    return !this.CanQuestTrackMappin(mappin);
  }

  public final const func CanPlayerTrackMappin(controller: wref<BaseWorldMapMappinController>) -> Bool {
    return this.CanPlayerTrackMappin(controller.GetMappin());
  }

  public final func CanZoomToMappin(controller: wref<BaseWorldMapMappinController>) -> Bool {
    return this.isZoomToMappinEnabled;
  }
}

public native class BaseWorldMapMappinController extends BaseInteractionMappinController {

  public native let selected: Bool;

  public native let inZoomLevel: Bool;

  public native let inCustomFilter: Bool;

  public native let hasCustomFilter: Bool;

  public native let isFastTravelEnabled: Bool;

  public native let isVisibleInFilterAndZoom: Bool;

  private native let groupContainerWidget: inkWidgetRef;

  private native let groupCountTextWidget: inkTextRef;

  private native const let groupState: gameuiMappinGroupState;

  public native const let collectionCount: Uint8;

  private edit let m_isNewContainer: inkWidgetRef;

  private let m_mappin: wref<IMappin>;

  @default(BaseWorldMapMappinController, false)
  private let m_isCompletedPhase: Bool;

  private let m_fadeAnim: ref<inkAnimProxy>;

  private let m_selectAnim: ref<inkAnimProxy>;

  public final native func IsGrouped() -> Bool;

  public final native func IsCollection() -> Bool;

  public final native func IsInCollection() -> Bool;

  protected cb func OnInitialize() -> Bool {
    let rootWidget: wref<inkWidget> = this.GetRootWidget();
    rootWidget.SetOpacity(0.00);
    rootWidget.SetInteractive(false);
    inkWidgetRef.SetVisible(this.m_isNewContainer, false);
    inkWidgetRef.SetVisible(this.groupContainerWidget, false);
  }

  protected cb func OnIntro() -> Bool {
    this.m_mappin = this.GetMappin();
    this.Update();
    this.OnFiltersChanged();
  }

  protected cb func OnUpdate() -> Bool {
    this.Update();
  }

  protected final func Update() -> Void {
    this.UpdateVisibility();
    this.UpdateIcon();
    this.UpdateRootState();
    this.UpdateTrackedState();
  }

  protected func UpdateVisibility() -> Void {
    let wasVisible: Bool;
    let questMappin: ref<QuestMappin> = this.m_mappin as QuestMappin;
    this.m_isCompletedPhase = Equals(this.m_mappin.GetPhase(), gamedataMappinPhase.CompletedPhase);
    if IsDefined(questMappin) {
      wasVisible = this.GetRootWidget().IsVisible();
      this.GetRootWidget().SetVisible(questMappin.IsActive());
      if !wasVisible && questMappin.IsActive() {
        this.GetRootWidget().SetOpacity(0.01);
      };
    };
  }

  protected func UpdateIcon() -> Void {
    let mappinVariant: gamedataMappinVariant = this.m_mappin.GetVariant();
    let mappinPhase: gamedataMappinPhase = this.m_mappin.GetPhase();
    let texturePart: CName = MappinUIUtils.MappinToTexturePart(mappinVariant, mappinPhase);
    inkImageRef.SetTexturePart(this.iconWidget, texturePart);
    if inkWidgetRef.IsValid(this.playerTrackedWidget) {
      inkWidgetRef.SetVisible(this.playerTrackedWidget, this.IsTracked());
    };
    this.UpdateIsNew();
  }

  protected final func UpdateIsNew() -> Void {
    let isNew: Bool = !this.m_mappin.IsVisited() && !this.IsCollection();
    inkWidgetRef.SetVisible(this.m_isNewContainer, isNew);
  }

  public func CanSelectMappin() -> Bool {
    return true;
  }

  private final func GetDesiredOpacityAndInteractivity(out opacity: Float, out interactive: Bool) -> Void {
    let visibleInGroup: Bool;
    if this.hasCustomFilter {
      interactive = this.inCustomFilter && !this.m_isCompletedPhase || this.IsTracked();
    } else {
      interactive = this.inZoomLevel && !this.m_isCompletedPhase || this.IsTracked();
    };
    this.isVisibleInFilterAndZoom = interactive;
    visibleInGroup = NotEquals(this.groupState, gameuiMappinGroupState.GroupedHidden);
    if !visibleInGroup {
      interactive = false;
    };
    opacity = interactive ? 1.00 : 0.00;
  }

  protected cb func OnFiltersChanged() -> Bool {
    let interactive: Bool;
    let opacity: Float;
    let rootWidget: wref<inkWidget> = this.GetRootWidget();
    this.GetDesiredOpacityAndInteractivity(opacity, interactive);
    rootWidget.SetOpacity(opacity);
    rootWidget.SetInteractive(interactive);
  }

  protected cb func OnGroupStateChanged(oldState: gameuiMappinGroupState, newState: gameuiMappinGroupState) -> Bool {
    let interactive: Bool;
    let opacity: Float;
    let rootWidget: wref<inkWidget> = this.GetRootWidget();
    this.GetDesiredOpacityAndInteractivity(opacity, interactive);
    rootWidget.SetOpacity(opacity);
    rootWidget.SetInteractive(interactive);
  }

  protected func ComputeRootState() -> CName {
    let filterGroup: wref<MappinUIFilterGroup_Record>;
    let stateName: CName;
    if this.m_isCompletedPhase {
      stateName = n"QuestComplete";
    } else {
      if this.m_mappin != null {
        if this.m_mappin.IsQuestMappin() {
          stateName = n"Quest";
        } else {
          filterGroup = MappinUIUtils.GetFilterGroup(this.m_mappin.GetVariant());
          if IsDefined(filterGroup) {
            stateName = filterGroup.WidgetState();
          };
        };
      };
    };
    return stateName;
  }

  private final func PlayFadeAnimation(opacity: Float) -> Void {
    let animDef: ref<inkAnimDef>;
    let animInterp: ref<inkAnimTransparency>;
    let widget: wref<inkWidget>;
    this.StopFadeAnimation();
    widget = this.GetRootWidget();
    if widget.GetOpacity() == opacity {
      return;
    };
    animDef = new inkAnimDef();
    animInterp = new inkAnimTransparency();
    animInterp.SetEndTransparency(opacity);
    animInterp.SetDuration(0.25);
    animInterp.SetDirection(inkanimInterpolationDirection.To);
    animInterp.SetUseRelativeDuration(true);
    animDef.AddInterpolator(animInterp);
    this.m_fadeAnim = widget.PlayAnimation(animDef);
  }

  private final func StopFadeAnimation() -> Void {
    if this.m_fadeAnim != null {
      this.m_fadeAnim.Stop(true);
      this.m_fadeAnim = null;
    };
  }

  public final func SelectMappin() -> Void {
    if this.m_selectAnim != null {
      this.m_selectAnim.Stop();
    };
    this.m_selectAnim = this.PlayLibraryAnimation(n"OnSelect");
  }

  public final func UnselectMappin() -> Void {
    if this.m_selectAnim != null {
      this.m_selectAnim.Stop();
    };
    this.m_selectAnim = this.PlayLibraryAnimation(n"OnUnselect");
  }

  public final func GetMappinVariant() -> gamedataMappinVariant {
    return this.m_mappin.GetVariant();
  }
}

public native class WorldMapPlayerMappinController extends BaseWorldMapMappinController {

  protected cb func OnInitialize() -> Bool {
    let rootWidget: wref<inkWidget> = this.GetRootWidget();
    rootWidget.SetVisible(true);
  }

  protected cb func OnFiltersChanged() -> Bool;

  protected func UpdateIcon() -> Void;

  protected func ComputeRootState() -> CName {
    return n"Player";
  }

  public func CanSelectMappin() -> Bool {
    return false;
  }
}

public class WorldMapLegendController extends inkLogicController {

  private edit let m_list: inkCompoundRef;

  @default(WorldMapLegendController, false)
  private let m_initialized: Bool;

  @default(WorldMapLegendController, false)
  private let m_visible: Bool;

  public final func Show() -> Void {
    if !this.m_initialized {
      this.PopulateList();
      this.m_initialized = true;
    };
    this.PlayLibraryAnimation(n"ShowLegend");
    this.m_visible = true;
  }

  public final func Hide(opt instant: Bool) -> Void {
    this.PlayLibraryAnimation(n"HideLegend");
    this.m_visible = false;
  }

  public final func IsVisible() -> Bool {
    return this.m_visible;
  }

  private final func PopulateList() -> Void {
    this.AddFilterGroup(t"WorldMap.CommonFilterGroup");
    this.AddFilterGroup(t"WorldMap.FastTravelFilterGroup");
    this.AddUndiscoveredItem();
    this.AddFilterGroup(t"WorldMap.QuestFilterGroup");
    this.AddFilterGroup(t"WorldMap.VehiclesForPurchaseFilterGroup");
    this.AddFilterGroup(t"WorldMap.StoryFilterGroup");
    this.AddFilterGroup(t"WorldMap.DropPointFilterGroup");
    this.AddFilterGroup(t"WorldMap.ServicePointFilterGroup");
  }

  private final func SpawnListItem() -> wref<WorldMapLegendListItemController> {
    return this.SpawnFromLocal(inkWidgetRef.Get(this.m_list), n"LegendListItem").GetController() as WorldMapLegendListItemController;
  }

  private final func AddFilterGroup(recordID: TweakDBID) -> Void {
    let i: Int32;
    let listItem: wref<WorldMapLegendListItemController>;
    let mappinVariant: gamedataMappinVariant;
    let mappins: array<wref<MappinVariant_Record>>;
    let widgetState: CName;
    let record: ref<MappinUIFilterGroup_Record> = TweakDBInterface.GetMappinUIFilterGroupRecord(recordID);
    if record == null {
      return;
    };
    widgetState = record.WidgetState();
    record.Mappins(mappins);
    i = 0;
    while i < ArraySize(mappins) {
      mappinVariant = mappins[i].Type();
      listItem = this.SpawnListItem();
      listItem.SetData(mappinVariant, widgetState);
      i += 1;
    };
  }

  private final func AddUndiscoveredItem() -> Void {
    let listItem: wref<WorldMapLegendListItemController> = this.SpawnListItem();
    listItem.SetData(n"undiscovered", n"UI-MappinTypes-Undiscovered", n"Quest");
  }
}

public class WorldMapLegendListItemController extends inkLogicController {

  private edit let m_icon: inkImageRef;

  private edit let m_label: inkTextRef;

  private let m_variant: gamedataMappinVariant;

  public final func SetData(variant: gamedataMappinVariant, widgetState: CName) -> Void {
    this.m_variant = variant;
    this.SetData(MappinUIUtils.MappinToTexturePart(this.m_variant), MappinUIUtils.MappinToString(this.m_variant), widgetState);
  }

  public final func SetData(iconTexturePart: CName, mappinName: CName, widgetState: CName) -> Void {
    inkImageRef.SetTexturePart(this.m_icon, iconTexturePart);
    inkTextRef.SetText(this.m_label, NameToString(mappinName));
    this.GetRootWidget().SetState(widgetState);
  }
}

public native class WorldMapDistrictLogicController extends inkLogicController {

  protected native let record: wref<District_Record>;

  protected native let type: gamedataDistrict;

  protected native let iconWidget: inkImageRef;

  protected native let selected: Bool;

  private let m_selectAnim: ref<inkAnimProxy>;

  protected cb func OnInitDistrict() -> Bool {
    if this.IsSubDistrict() {
      this.GetRootWidget().SetState(this.GetParentDistrictRecord().UiState());
      inkWidgetRef.SetVisible(this.iconWidget, false);
    } else {
      this.GetRootWidget().SetState(this.record.UiState());
      inkImageRef.SetTexturePart(this.iconWidget, this.record.UiIcon());
    };
  }

  protected cb func OnSetSelected(inSelected: Bool) -> Bool {
    if IsDefined(this.m_selectAnim) {
      this.m_selectAnim.Stop();
      this.m_selectAnim = null;
    };
    if inSelected {
      this.m_selectAnim = this.PlayLibraryAnimation(n"OnSelectDistrict");
    } else {
      this.m_selectAnim = this.PlayLibraryAnimation(n"OnDeselectDistrict");
    };
  }

  private final func GetParentDistrictRecord() -> wref<District_Record> {
    return this.record.ParentDistrict();
  }

  private final func IsSubDistrict() -> Bool {
    return this.GetParentDistrictRecord() != null;
  }
}
