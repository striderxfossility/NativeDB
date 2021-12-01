
public class WorldMapTooltipContainer extends inkLogicController {

  protected edit let m_defaultTooltip: inkWidgetRef;

  protected edit let m_policeTooltip: inkWidgetRef;

  protected edit let m_districtTooltip: inkWidgetRef;

  protected let m_defaultTooltipController: wref<WorldMapTooltipBaseController>;

  protected let m_policeTooltipController: wref<WorldMapTooltipBaseController>;

  protected let m_districtTooltipController: wref<WorldMapTooltipBaseController>;

  protected let m_tooltips: array<wref<WorldMapTooltipBaseController>; 3>;

  @default(WorldMapTooltipContainer, -1)
  protected let m_currentVisibleIndex: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_defaultTooltipController = inkWidgetRef.GetController(this.m_defaultTooltip) as WorldMapTooltipBaseController;
    this.m_policeTooltipController = inkWidgetRef.GetController(this.m_policeTooltip) as WorldMapTooltipBaseController;
    this.m_districtTooltipController = inkWidgetRef.GetController(this.m_districtTooltip) as WorldMapTooltipBaseController;
    this.m_tooltips[0] = this.m_districtTooltipController;
    this.m_tooltips[1] = this.m_policeTooltipController;
    this.m_tooltips[2] = this.m_defaultTooltipController;
    this.HideAll(true);
  }

  public final func Show(target: WorldMapTooltipType) -> Void {
    let oldController: wref<WorldMapTooltipBaseController>;
    let newController: wref<WorldMapTooltipBaseController> = this.GetTooltipController(target);
    let priority: Int32 = this.GetControllerPriorityIndex(newController);
    if priority == this.m_currentVisibleIndex {
      return;
    };
    if newController.m_active || newController.m_visible {
      return;
    };
    newController.m_active = true;
    if this.m_currentVisibleIndex != -1 {
      oldController = this.m_tooltips[this.m_currentVisibleIndex];
      if this.m_currentVisibleIndex < priority {
        oldController.HideInstant();
        newController.Show();
        this.m_currentVisibleIndex = priority;
      };
    } else {
      newController.Show();
      this.m_currentVisibleIndex = priority;
    };
  }

  public final func Hide(target: WorldMapTooltipType) -> Void {
    let newController: wref<WorldMapTooltipBaseController>;
    let shouldHideInstant: Bool = false;
    let oldController: wref<WorldMapTooltipBaseController> = this.GetTooltipController(target);
    let priority: Int32 = this.GetControllerPriorityIndex(oldController);
    oldController.m_active = false;
    if oldController.m_visible {
      if this.m_currentVisibleIndex != -1 && this.m_currentVisibleIndex == priority {
        this.m_currentVisibleIndex = this.m_currentVisibleIndex - 1;
        while this.m_currentVisibleIndex >= 0 {
          newController = this.m_tooltips[this.m_currentVisibleIndex];
          if newController.m_active {
            newController.Show();
            shouldHideInstant = true;
          } else {
            this.m_currentVisibleIndex -= 1;
          };
        };
      };
      if shouldHideInstant {
        oldController.HideInstant();
      } else {
        oldController.Hide();
      };
    };
  }

  public final func HideAll(opt force: Bool) -> Void {
    let total: Int32 = ArraySize(this.m_tooltips);
    let i: Int32 = 0;
    while i < total {
      this.m_tooltips[i].m_active = false;
      this.m_tooltips[i].HideInstant(force);
      i += 1;
    };
  }

  public final func SetData(target: WorldMapTooltipType, data: WorldMapTooltipData, menu: ref<WorldMapMenuGameController>) -> Void {
    this.GetTooltipController(target).SetData(data, menu);
  }

  private final func GetTooltipController(type: WorldMapTooltipType) -> wref<WorldMapTooltipBaseController> {
    switch type {
      case WorldMapTooltipType.Police:
        return this.m_policeTooltipController;
      case WorldMapTooltipType.District:
        return this.m_districtTooltipController;
      default:
        return this.m_defaultTooltipController;
    };
  }

  private final func GetControllerPriorityIndex(controller: wref<WorldMapTooltipBaseController>) -> Int32 {
    let total: Int32 = ArraySize(this.m_tooltips);
    let i: Int32 = 0;
    while i < total {
      if this.m_tooltips[i] == controller {
        return i;
      };
      i += 1;
    };
    return -1;
  }
}

public class WorldMapTooltipBaseController extends inkLogicController {

  protected edit let m_root: inkWidgetRef;

  private let m_showHideAnim: ref<inkAnimProxy>;

  @default(WorldMapTooltipBaseController, false)
  public let m_visible: Bool;

  @default(WorldMapTooltipBaseController, false)
  public let m_active: Bool;

  protected func GetShowAnimation() -> CName {
    return n"ShowTooltip";
  }

  protected func GetHideAnimation() -> CName {
    return n"HideTooltip";
  }

  public func Show() -> Void {
    if !this.m_visible {
      if IsDefined(this.m_showHideAnim) {
        this.m_showHideAnim.Stop();
      };
      this.m_showHideAnim = this.PlayLibraryAnimation(this.GetShowAnimation());
      this.m_visible = true;
    };
  }

  public func HideInstant(opt force: Bool) -> Void {
    if this.m_visible || force {
      if IsDefined(this.m_showHideAnim) {
        this.m_showHideAnim.Stop();
      };
      inkWidgetRef.SetOpacity(this.m_root, 0.00);
      this.m_visible = false;
    };
  }

  public func Hide() -> Void {
    if this.m_visible {
      if IsDefined(this.m_showHideAnim) {
        this.m_showHideAnim.Stop();
      };
      this.m_showHideAnim = this.PlayLibraryAnimation(this.GetHideAnimation());
      this.m_visible = false;
    };
  }

  public func SetData(data: WorldMapTooltipData, menu: ref<WorldMapMenuGameController>) -> Void;
}

public class WorldMapTooltipController extends WorldMapTooltipBaseController {

  protected edit let m_titleText: inkTextRef;

  protected edit let m_descText: inkTextRef;

  protected edit let m_trackedQuestContainer: inkWidgetRef;

  protected edit let m_requiredLevelCanvas: inkWidgetRef;

  protected edit let m_requiredLevelText: inkTextRef;

  protected edit let m_requiredLevelValue: inkTextRef;

  protected edit let m_inputSetWaypointContainer: inkCompoundRef;

  protected edit let m_inputSetWaypointText: inkTextRef;

  protected edit let m_inputTrackQuestContainer: inkCompoundRef;

  protected edit let m_inputTrackQuestText: inkTextRef;

  protected edit let m_inputInteractContainer: inkCompoundRef;

  protected edit let m_inputInteractText: inkTextRef;

  protected edit let m_inputOpenJournalContainer: inkCompoundRef;

  protected edit let m_inputOpenJournalText: inkTextRef;

  protected edit let m_inputZoomToContainer: inkCompoundRef;

  protected edit let m_inputZoomToText: inkTextRef;

  protected edit let m_threatLevelCaption: inkTextRef;

  protected edit let m_threatLevelValue: inkTextRef;

  protected edit let m_collectionCountContainer: inkCompoundRef;

  protected edit let m_collectionCountText: inkTextRef;

  protected cb func OnInitialize() -> Bool {
    this.Reset();
  }

  public func SetData(data: WorldMapTooltipData, menu: ref<WorldMapMenuGameController>) -> Void {
    let contentID: TweakDBID;
    let contentRecord: wref<ContentAssignment_Record>;
    let curveModifier: wref<CurveStatModifier_Record>;
    let descStr: String;
    let fastTravelmappin: ref<FastTravelMappin>;
    let inputInteractStr: String;
    let inputOpenJournalStr: String;
    let inputSetWaypointStr: String;
    let inputTrackQuestStr: String;
    let inputZoomToStr: String;
    let journalID: String;
    let levelState: CName;
    let m_mappin: ref<JournalQuestMapPin>;
    let m_objective: ref<JournalQuestObjective>;
    let m_phase: ref<JournalQuestPhase>;
    let m_quest: ref<JournalQuest>;
    let mappinPhase: gamedataMappinPhase;
    let mappinVariant: gamedataMappinVariant;
    let pointData: ref<FastTravelPointData>;
    let prefix: String;
    let suffix: String;
    let threatString: String;
    let titleStr: String;
    let vehicleMappin: ref<VehicleMappin>;
    let vehicleObject: wref<VehicleObject>;
    let isTrackedQuest: Bool = false;
    let recommendedLvlVisible: Bool = false;
    let recommendedLvl: Uint32 = 0u;
    let inputSetWaypoint: Bool = false;
    let inputTrackQuest: Bool = false;
    let inputInteract: Bool = false;
    let inputZoomTo: Bool = false;
    let inputOpenJournal: Bool = false;
    let journalManager: ref<JournalManager> = menu.GetJournalManager();
    let player: wref<GameObject> = menu.GetPlayer();
    let playerLevel: Int32 = RoundMath(GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Level));
    if data.controller != null && data.mappin != null && journalManager != null && player != null {
      mappinVariant = data.mappin.GetVariant();
      mappinPhase = data.mappin.GetPhase();
      fastTravelmappin = data.mappin as FastTravelMappin;
      vehicleMappin = data.mappin as VehicleMappin;
      if IsDefined(vehicleMappin) {
        vehicleObject = vehicleMappin.GetVehicle();
        titleStr = IsDefined(vehicleObject) ? vehicleObject.GetDisplayName() : GetLocalizedText("UI-MappinTypes-PersonalVehicle");
        descStr = GetLocalizedText("UI-MappinTypes-PersonalVehicleDescription");
      } else {
        if IsDefined(fastTravelmappin) {
          pointData = fastTravelmappin.GetPointData();
          titleStr = GetLocalizedText("UI-MappinTypes-FastTravel");
          descStr = data.isCollection ? GetLocalizedText("UI-MappinTypes-FastTravelDescription") : pointData.GetPointDisplayName();
          inputInteract = data.fastTravelEnabled;
          inputInteractStr = GetLocalizedText("UI-ResourceExports-FastTravel");
          inputSetWaypoint = !menu.IsFastTravelEnabled();
        } else {
          if Equals(mappinPhase, gamedataMappinPhase.UndiscoveredPhase) {
            titleStr = "UI-MappinTypes-Undiscovered";
            descStr = "UI-MappinTypes-UndiscoveredDescription";
          } else {
            m_mappin = data.journalEntry as JournalQuestMapPin;
            if m_mappin != null {
              m_objective = journalManager.GetParentEntry(m_mappin) as JournalQuestObjective;
              if m_objective != null {
                m_phase = journalManager.GetParentEntry(m_objective) as JournalQuestPhase;
                if m_phase != null {
                  m_quest = journalManager.GetParentEntry(m_phase) as JournalQuest;
                  if m_quest != null {
                    titleStr = m_quest.GetTitle(journalManager);
                    descStr = m_objective.GetDescription();
                  };
                };
              };
            };
            if Equals(titleStr, "") {
              titleStr = NameToString(MappinUIUtils.MappinToString(mappinVariant, mappinPhase));
            };
            if Equals(descStr, "") {
              descStr = NameToString(MappinUIUtils.MappinToDescriptionString(mappinVariant));
            };
          };
          if !menu.IsFastTravelEnabled() {
            if menu.CanQuestTrackMappin(data.mappin) {
              isTrackedQuest = data.controller.IsTracked();
              if !isTrackedQuest {
                inputTrackQuest = true;
                inputTrackQuestStr = GetLocalizedTextByKey(n"UI-Menus-WorldMap-TrackQuest");
              };
            } else {
              if menu.CanPlayerTrackMappin(data.mappin) {
                inputSetWaypoint = true;
              };
            };
          };
          if data.journalEntry != null {
            recommendedLvl = journalManager.GetRecommendedLevel(data.journalEntry);
            if IsDefined(m_quest) {
              contentID = m_quest.GetRecommendedLevelID();
            } else {
              journalID = data.journalEntry.GetId();
              if StrBeginsWith(journalID, "mq") || StrBeginsWith(journalID, "sq") || StrBeginsWith(journalID, "q") {
                StrSplitFirst(journalID, "_", prefix, suffix);
                journalID = prefix;
              };
              contentID = TDBID.Create("DeviceContentAssignment." + journalID);
            };
            contentRecord = TweakDBInterface.GetContentAssignmentRecord(contentID);
            if IsDefined(contentRecord) {
              curveModifier = contentRecord.PowerLevelMod() as CurveStatModifier_Record;
              if IsDefined(curveModifier) {
                recommendedLvl = Cast(RoundF(GameInstance.GetStatsDataSystem(player.GetGame()).GetValueFromCurve(StringToName(curveModifier.Id()), Cast(playerLevel), StringToName(curveModifier.Column()))));
              } else {
                recommendedLvl = Cast(GameInstance.GetLevelAssignmentSystem(player.GetGame()).GetLevelAssignment(contentID));
              };
            };
            recommendedLvlVisible = Cast(recommendedLvl) > 0;
          };
          levelState = QuestLogUtils.GetLevelState(playerLevel, Cast(recommendedLvl));
          switch levelState {
            case n"ThreatVeryLow":
              threatString = GetLocalizedText("UI-Tooltips-ThreatVeryLow");
              break;
            case n"ThreatLow":
              threatString = GetLocalizedText("UI-Tooltips-Low");
              break;
            case n"ThreatMedium":
              threatString = GetLocalizedText("UI-Tooltips-ThreatMedium");
              break;
            case n"ThreatHigh":
              threatString = GetLocalizedText("UI-Tooltips-ThreatHigh");
              break;
            case n"ThreatVeryHigh":
              threatString = GetLocalizedText("UI-Tooltips-ThreatVeryHigh");
              break;
            default:
              threatString = GetLocalizedText("UI-Tooltips-ThreatMedium");
          };
          inkWidgetRef.SetState(this.m_threatLevelCaption, levelState);
          inkWidgetRef.SetState(this.m_threatLevelValue, levelState);
          inkTextRef.SetText(this.m_threatLevelValue, threatString);
        };
      };
      if inputSetWaypoint {
        inputSetWaypointStr = data.controller.IsPlayerTracked() ? GetLocalizedText("UI-ScriptExports-Untrack0") : GetLocalizedText("UI-ResourceExports-Track");
      };
      inputOpenJournal = data.readJournal;
      inputOpenJournalStr = GetLocalizedText("UI-PanelNames-JOURNAL");
      inputZoomTo = menu.CanZoomToMappin(data.controller);
      inputZoomToStr = GetLocalizedText("Gameplay-InputHints-DeviceControl-ZoomIn");
    };
    inkWidgetRef.SetVisible(this.m_collectionCountContainer, data.isCollection);
    if data.isCollection {
      inkTextRef.SetText(this.m_collectionCountText, IntToString(data.collectionCount));
      inputSetWaypoint = false;
      inputTrackQuest = false;
      inputOpenJournal = false;
      inputInteract = false;
      isTrackedQuest = false;
      recommendedLvlVisible = false;
    };
    inkTextRef.SetText(this.m_titleText, titleStr);
    inkTextRef.SetText(this.m_descText, descStr);
    inkWidgetRef.SetVisible(this.m_trackedQuestContainer, isTrackedQuest);
    inkTextRef.SetText(this.m_requiredLevelValue, IntToString(Cast(recommendedLvl)));
    inkWidgetRef.SetState(this.m_requiredLevelValue, this.GetLevelState(playerLevel, Cast(recommendedLvl)));
    inkWidgetRef.SetState(this.m_requiredLevelText, this.GetLevelState(playerLevel, Cast(recommendedLvl)));
    inkWidgetRef.SetVisible(this.m_requiredLevelCanvas, recommendedLvlVisible);
    inkWidgetRef.SetVisible(this.m_inputSetWaypointContainer, inputSetWaypoint);
    inkTextRef.SetText(this.m_inputSetWaypointText, inputSetWaypointStr);
    inkWidgetRef.SetVisible(this.m_inputTrackQuestContainer, inputTrackQuest);
    inkTextRef.SetText(this.m_inputTrackQuestText, inputTrackQuestStr);
    inkWidgetRef.SetVisible(this.m_inputInteractContainer, inputInteract);
    inkTextRef.SetText(this.m_inputInteractText, inputInteractStr);
    inkWidgetRef.SetVisible(this.m_inputOpenJournalContainer, inputOpenJournal);
    inkTextRef.SetText(this.m_inputOpenJournalText, inputOpenJournalStr);
    inkWidgetRef.SetVisible(this.m_inputZoomToContainer, inputZoomTo);
    inkTextRef.SetText(this.m_inputZoomToText, inputZoomToStr);
  }

  protected final func GetLevelState(playerLevel: Int32, recommendedLvl: Int32) -> CName {
    return QuestLogUtils.GetLevelState(playerLevel, recommendedLvl);
  }

  protected final func Reset() -> Void {
    this.SetData(new WorldMapTooltipData(), null);
  }
}

public class WorldMapPoliceTooltipController extends WorldMapTooltipController {

  protected func GetShowAnimation() -> CName {
    return n"ShowPoliceTooltip";
  }

  protected func GetHideAnimation() -> CName {
    return n"HidePoliceTooltip";
  }

  public func SetData(data: WorldMapTooltipData, menu: ref<WorldMapMenuGameController>) -> Void {
    let contentID: TweakDBID;
    let contentRecord: wref<ContentAssignment_Record>;
    let curveModifier: wref<CurveStatModifier_Record>;
    let descStr: String;
    let inputTrackQuestStr: String;
    let inputZoomToStr: String;
    let journalQuest: ref<JournalQuest>;
    let levelState: CName;
    let mappinPhase: gamedataMappinPhase;
    let mappinVariant: gamedataMappinVariant;
    let playerLevel: Int32;
    let threatString: String;
    let titleStr: String;
    let isTrackedQuest: Bool = false;
    let recommendedLvlVisible: Bool = false;
    let recommendedLvl: Int32 = 0;
    let inputTrackQuest: Bool = false;
    let inputZoomTo: Bool = false;
    let journalManager: ref<JournalManager> = menu.GetJournalManager();
    let player: wref<GameObject> = menu.GetPlayer();
    let powerLevel: Float = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Level);
    if data.controller != null && data.mappin != null && journalManager != null && player != null {
      mappinVariant = data.mappin.GetVariant();
      mappinPhase = data.mappin.GetPhase();
      if Equals(mappinPhase, gamedataMappinPhase.UndiscoveredPhase) {
        titleStr = "UI-MappinTypes-Undiscovered";
        descStr = "UI-MappinTypes-UndiscoveredDescription";
      } else {
        if Equals(mappinPhase, gamedataMappinPhase.CompletedPhase) {
          titleStr = NameToString(MappinUIUtils.MappinToString(mappinVariant, mappinPhase));
          descStr = "UI-Notifications-QuestCompleted";
        } else {
          titleStr = NameToString(MappinUIUtils.MappinToString(mappinVariant, mappinPhase));
          descStr = NameToString(MappinUIUtils.MappinToDescriptionString(mappinVariant));
        };
      };
      if !menu.IsFastTravelEnabled() {
        inputTrackQuest = true;
        inputTrackQuestStr = data.mappin.IsPlayerTracked() ? GetLocalizedText("UI-ScriptExports-Untrack0") : GetLocalizedText("UI-ResourceExports-Track");
      };
      if data.journalEntry != null {
        recommendedLvl = Cast(journalManager.GetRecommendedLevel(data.journalEntry));
        journalQuest = data.journalEntry as JournalQuest;
        if IsDefined(journalQuest) {
          contentID = journalQuest.GetRecommendedLevelID();
        } else {
          contentID = TDBID.Create("DeviceContentAssignment." + data.journalEntry.GetId());
        };
        contentRecord = TweakDBInterface.GetContentAssignmentRecord(contentID);
        if IsDefined(contentRecord) {
          curveModifier = contentRecord.PowerLevelMod() as CurveStatModifier_Record;
          if IsDefined(curveModifier) {
            recommendedLvl = RoundMath(GameInstance.GetStatsDataSystem(player.GetGame()).GetValueFromCurve(StringToName(curveModifier.Id()), powerLevel, StringToName(curveModifier.Column())));
          } else {
            recommendedLvl = GameInstance.GetLevelAssignmentSystem(player.GetGame()).GetLevelAssignment(contentID);
          };
        };
        recommendedLvlVisible = recommendedLvl > 0;
      };
      playerLevel = Cast(GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Level));
      levelState = QuestLogUtils.GetLevelState(playerLevel, recommendedLvl);
      switch levelState {
        case n"ThreatVeryLow":
          threatString = GetLocalizedText("UI-Tooltips-ThreatVeryLow");
          break;
        case n"ThreatLow":
          threatString = GetLocalizedText("UI-Tooltips-Low");
          break;
        case n"ThreatMedium":
          threatString = GetLocalizedText("UI-Tooltips-ThreatMedium");
          break;
        case n"ThreatHigh":
          threatString = GetLocalizedText("UI-Tooltips-ThreatHigh");
          break;
        case n"ThreatVeryHigh":
          threatString = GetLocalizedText("UI-Tooltips-ThreatVeryHigh");
          break;
        default:
          threatString = GetLocalizedText("UI-Tooltips-ThreatMedium");
      };
      inkWidgetRef.SetState(this.m_threatLevelCaption, levelState);
      inkWidgetRef.SetState(this.m_threatLevelValue, levelState);
      inkTextRef.SetText(this.m_threatLevelValue, threatString);
      inputZoomTo = menu.CanZoomToMappin(data.controller);
      inputZoomToStr = GetLocalizedText("Gameplay-InputHints-DeviceControl-ZoomIn");
    };
    inkWidgetRef.SetVisible(this.m_collectionCountContainer, data.isCollection);
    if data.isCollection {
      inkTextRef.SetText(this.m_collectionCountText, IntToString(data.collectionCount));
      inputTrackQuest = false;
      isTrackedQuest = false;
      recommendedLvlVisible = false;
    };
    inkTextRef.SetText(this.m_titleText, titleStr);
    inkTextRef.SetText(this.m_descText, descStr);
    inkWidgetRef.SetVisible(this.m_trackedQuestContainer, isTrackedQuest);
    inkTextRef.SetText(this.m_requiredLevelValue, IntToString(recommendedLvl));
    inkWidgetRef.SetVisible(this.m_requiredLevelCanvas, recommendedLvlVisible);
    inkWidgetRef.SetVisible(this.m_inputTrackQuestContainer, inputTrackQuest);
    inkTextRef.SetText(this.m_inputTrackQuestText, inputTrackQuestStr);
    inkWidgetRef.SetVisible(this.m_inputZoomToContainer, inputZoomTo);
    inkTextRef.SetText(this.m_inputZoomToText, inputZoomToStr);
  }
}

public class WorldMapDistrictTooltipController extends WorldMapTooltipBaseController {

  private edit let m_titleText: inkTextRef;

  private edit let m_levelRangeText: inkTextRef;

  private edit let m_threatText: inkTextRef;

  private edit let m_completionText: inkTextRef;

  private edit let m_gangsContainer: inkWidgetRef;

  private edit let m_gangsList: inkCompoundRef;

  private let m_gangControllers: array<wref<WorldMapGangItemController>>;

  protected cb func OnInitialize() -> Bool {
    this.Reset();
  }

  public func SetData(data: WorldMapTooltipData, menu: ref<WorldMapMenuGameController>) -> Void {
    let gangController: wref<WorldMapGangItemController>;
    let gangRecord: wref<Affiliation_Record>;
    let gangWidget: wref<inkWidget>;
    let gangsRecords: array<wref<Affiliation_Record>>;
    let i: Int32;
    let totalGangs: Int32;
    let districtRecord: wref<District_Record> = MappinUIUtils.GetDistrictRecord(data.district);
    let titleStr: String = districtRecord.LocalizedName();
    inkTextRef.SetLocalizedTextString(this.m_titleText, titleStr);
    totalGangs = districtRecord.GetGangsCount();
    inkWidgetRef.SetVisible(this.m_gangsContainer, totalGangs > 0);
    if totalGangs > 0 {
      inkCompoundRef.RemoveAllChildren(this.m_gangsList);
      districtRecord.Gangs(gangsRecords);
      i = 0;
      while i < totalGangs {
        gangRecord = gangsRecords[i];
        gangWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_gangsList), n"GangListItem");
        if gangWidget != null {
          gangController = gangWidget.GetController() as WorldMapGangItemController;
          if gangController != null {
            gangController.SetData(gangRecord);
          };
        };
        i += 1;
      };
    };
  }

  protected final func Reset() -> Void {
    this.SetData(new WorldMapTooltipData(), null);
  }
}

public class WorldMapGangItemController extends inkLogicController {

  private edit let m_factionNameText: inkTextRef;

  private edit let m_factionIconImage: inkImageRef;

  public final func SetData(affiliationRecord: wref<Affiliation_Record>) -> Void {
    inkTextRef.SetLocalizedText(this.m_factionNameText, affiliationRecord.LocalizedName());
    inkImageRef.SetTexturePart(this.m_factionIconImage, affiliationRecord.IconPath());
  }
}
