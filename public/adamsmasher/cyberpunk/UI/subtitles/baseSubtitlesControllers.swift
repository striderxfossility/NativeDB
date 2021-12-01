
public class LineSpawnData extends IScriptable {

  public let m_lineData: scnDialogLineData;

  public final func Initialize(lineData: scnDialogLineData) -> Void {
    this.m_lineData = lineData;
  }
}

public class SubtitlesSettingsListener extends ConfigVarListener {

  private let m_ctrl: wref<BaseSubtitlesGameController>;

  public final func RegisterController(ctrl: ref<BaseSubtitlesGameController>) -> Void {
    this.m_ctrl = ctrl;
  }

  public func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    this.m_ctrl.OnVarModified(groupPath, varName, varType, reason);
  }
}

public class BaseSubtitlesGameController extends inkProjectedHUDGameController {

  protected let m_lineMap: array<subtitleLineMapEntry>;

  protected let m_pendingShowLines: array<CRUID>;

  protected let m_pendingHideLines: array<CRUID>;

  protected let m_settings: ref<UserSettings>;

  protected let m_settingsListener: ref<SubtitlesSettingsListener>;

  @default(BaseSubtitlesGameController, /audio/subtitles)
  protected let m_groupPath: CName;

  private let m_gameInstance: GameInstance;

  private let m_uiBlackboard: wref<IBlackboard>;

  private let m_bbCbShowDialogLine: ref<CallbackHandle>;

  private let m_bbCbHideDialogLine: ref<CallbackHandle>;

  private let m_bbCbHideDialogLineByData: ref<CallbackHandle>;

  private let m_bbCbShowBackground: ref<CallbackHandle>;

  @default(BaseSubtitlesGameController, false)
  private let m_showBackgroud: Bool;

  @default(BaseSubtitlesGameController, false)
  private let m_isCreoleUnlocked: Bool;

  private let m_isPlayerJohnny: Bool;

  private let m_disabledBySettings: Bool;

  private let m_forceForeignLines: Bool;

  private let m_backgroundOpacity: Float;

  private let m_fontSize: Int32;

  private let m_factlistenerId: Uint32;

  protected cb func OnInitialize() -> Bool {
    this.m_uiBlackboard = this.GetUIBlackboard();
    this.RegisterToDialogBlackboard(true);
    this.m_bbCbShowBackground = this.m_uiBlackboard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UIGameData.ShowSubtitlesBackground, this, n"OnShowBackground");
    if IsDefined(this.GetPlayerControlledObject()) {
      this.m_gameInstance = this.GetPlayerControlledObject().GetGame();
      this.m_factlistenerId = GameInstance.GetQuestsSystem(this.m_gameInstance).RegisterListener(n"creole_translator_unlocked", this, n"OnCreoleFactChanged");
      this.m_isCreoleUnlocked = GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"creole_translator_unlocked") > 0;
    };
    this.CalculateVisibility();
    this.m_settings = this.GetSystemRequestsHandler().GetUserSettings();
    this.m_settingsListener = new SubtitlesSettingsListener();
    this.m_settingsListener.RegisterController(this);
    this.m_settingsListener.Register(this.m_groupPath);
    this.UpdateSubsVisibilitySetting();
    this.UpdateChattersVisibilitySetting();
    this.UpdateSizeSettings();
    this.UpdateBackgroundOpacitySettings();
    this.m_forceForeignLines = true;
    this.ShowPendingSubtitles();
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let controlledPuppetRecordID: TweakDBID;
    let controlledPuppet: wref<gamePuppetBase> = GetPlayer(this.m_gameInstance);
    if controlledPuppet != null {
      controlledPuppetRecordID = controlledPuppet.GetRecordID();
      if controlledPuppetRecordID == t"Character.johnny_replacer" {
        this.m_isPlayerJohnny = true;
      } else {
        this.m_isPlayerJohnny = false;
      };
    } else {
      this.m_isPlayerJohnny = false;
    };
  }

  protected cb func OnUninitialize() -> Bool {
    GameInstance.GetQuestsSystem(this.m_gameInstance).UnregisterListener(n"creole_translator_unlocked", this.m_factlistenerId);
    GameInstance.GetSubtitleHandlerSystem(this.GetGame()).UnregisterSubtitleController(this);
    this.RegisterToDialogBlackboard(false);
    this.m_uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UIGameData.ShowSubtitlesBackground, this.m_bbCbShowBackground);
  }

  protected cb func OnCreoleFactChanged(value: Int32) -> Bool {
    this.m_isCreoleUnlocked = value > 0;
  }

  private final func RegisterToDialogBlackboard(value: Bool) -> Void {
    if value {
      this.m_bbCbShowDialogLine = this.m_uiBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UIGameData.ShowDialogLine, this, n"OnShowDialogLine");
      this.m_bbCbHideDialogLine = this.m_uiBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UIGameData.HideDialogLine, this, n"OnHideDialogLine");
      this.m_bbCbHideDialogLineByData = this.m_uiBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UIGameData.HideDialogLineByData, this, n"OnHideDialogLineByData");
    } else {
      this.m_uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UIGameData.ShowDialogLine, this.m_bbCbShowDialogLine);
      this.m_uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UIGameData.HideDialogLine, this.m_bbCbHideDialogLine);
      this.m_uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UIGameData.HideDialogLineByData, this.m_bbCbHideDialogLineByData);
    };
  }

  protected cb func OnWorldAttached(evt: ref<inkWorldAttachedEvt>) -> Bool {
    this.RegisterToDialogBlackboard(false);
    this.m_uiBlackboard = this.GetUIBlackboard();
    this.RegisterToDialogBlackboard(true);
  }

  protected final func DisableBySettings(value: Bool) -> Void {
    if NotEquals(this.m_disabledBySettings, value) {
      this.m_disabledBySettings = value;
      this.Cleanup();
    };
    RefreshSettings();
  }

  protected final func ForceForeignLinesBySettings(value: Bool) -> Void {
    if NotEquals(this.m_forceForeignLines, value) {
      this.m_forceForeignLines = value;
      this.Cleanup();
    };
  }

  protected final func IsKiroshiEnabled(lineData: scnDialogLineData) -> Bool {
    let lineText: scnDialogDisplayString = scnDialogLineData.GetDisplayText(lineData);
    let lineLangIsCreole: Bool = Equals(lineText.language, scnDialogLineLanguage.Creole);
    return !lineLangIsCreole || this.m_isCreoleUnlocked;
  }

  protected func ShouldDisplayLine(lineData: scnDialogLineData) -> Bool {
    return false;
  }

  protected func CreateLine(lineSpawnData: ref<LineSpawnData>) -> Void;

  protected func SetupLine(lineWidget: ref<inkWidget>, lineSpawnData: ref<LineSpawnData>) -> Void;

  protected func OnHideLine(lineData: subtitleLineMapEntry) -> Void {
    ArrayRemove(this.m_pendingHideLines, lineData.id);
  }

  protected func OnHideLineByData(lineData: subtitleLineMapEntry) -> Void {
    ArrayRemove(this.m_pendingHideLines, lineData.id);
  }

  protected cb func OnShowDialogLine(value: Variant) -> Bool {
    let linesToShow: array<scnDialogLineData> = FromVariant(value);
    this.ShowDialogLines(linesToShow);
  }

  public final func ShowDialogLines(linesToShow: array<scnDialogLineData>) -> Void {
    let currLine: scnDialogLineData;
    let count: Int32 = ArraySize(linesToShow);
    let i: Int32 = 0;
    while i < count {
      currLine = linesToShow[i];
      if this.m_disabledBySettings {
        if scnDialogLineData.HasKiroshiTag(currLine) {
          if !this.m_forceForeignLines {
          } else {
          };
        } else {
        };
      } else {
        if !this.ShouldDisplayLine(currLine) || ArrayContains(this.m_pendingShowLines, currLine.id) {
        } else {
          ArrayPush(this.m_pendingShowLines, currLine.id);
          this.SpawnDialogLine(currLine);
        };
      };
      i += 1;
    };
    this.CalculateVisibility();
  }

  protected cb func OnHideDialogLineByData(value: Variant) -> Bool {
    let linesToHide: array<scnDialogLineData> = FromVariant(value);
    this.HideDialogLinesByData(linesToHide);
    this.TryRemovePendingHideLines();
  }

  public final func HideDialogLinesByData(linesToHide: array<scnDialogLineData>) -> Void {
    let currLine: scnDialogLineData;
    let count: Int32 = ArraySize(linesToHide);
    let i: Int32 = 0;
    while i < count {
      currLine = linesToHide[i];
      this.ResolveShowHidePendingLines(currLine.id);
      this.RemoveLineByData(currLine);
      i += 1;
    };
    this.CalculateVisibility();
  }

  protected cb func OnHideDialogLine(value: Variant) -> Bool {
    let linesToHide: array<CRUID> = FromVariant(value);
    this.HideDialogLine(linesToHide);
    this.TryRemovePendingHideLines();
  }

  public final func HideDialogLine(linesToHide: array<CRUID>) -> Void {
    let currLine: CRUID;
    let count: Int32 = ArraySize(linesToHide);
    let i: Int32 = 0;
    while i < count {
      currLine = linesToHide[i];
      this.ResolveShowHidePendingLines(currLine);
      this.RemoveLine(currLine);
      i += 1;
    };
    this.CalculateVisibility();
  }

  protected cb func OnShowBackground(value: Bool) -> Bool {
    let currLine: ref<BaseSubtitleLineLogicController>;
    this.m_showBackgroud = value;
    let count: Int32 = ArraySize(this.m_lineMap);
    let i: Int32 = 0;
    while i < count {
      currLine = this.m_lineMap[i].widget.GetController() as BaseSubtitleLineLogicController;
      if IsDefined(currLine) {
        currLine.ShowBackground(this.m_showBackgroud);
      };
      i += 1;
    };
  }

  public final func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    switch varName {
      case n"Cinematic":
        this.UpdateSubsVisibilitySetting();
        break;
      case n"CinematicForceKiroshiTexts":
        this.UpdateSubsForeignVisibilitySettings();
        break;
      case n"Overheads":
        this.UpdateChattersVisibilitySetting();
        break;
      case n"OverheadsForceKiroshiTexts":
        this.UpdateChattersForeignVisibilitySettings();
        break;
      case n"TextSize":
      case n"ChattersTextSize":
        this.UpdateSizeSettings();
        this.ForceSettingsUpdate();
        break;
      case n"BackgroundOpacity":
        this.UpdateBackgroundOpacitySettings();
        this.ForceSettingsUpdate();
        break;
      default:
    };
  }

  private final func ForceSettingsUpdate() -> Void {
    let currLine: ref<BaseSubtitleLineLogicController>;
    let count: Int32 = ArraySize(this.m_lineMap);
    let i: Int32 = 0;
    while i < count {
      currLine = this.m_lineMap[i].widget.GetController() as BaseSubtitleLineLogicController;
      if IsDefined(currLine) {
        currLine.SetupSettings(this.m_fontSize, this.m_backgroundOpacity);
      };
      i += 1;
    };
  }

  private final func UpdateSubsVisibilitySetting() -> Void {
    let configVar: ref<ConfigVarBool> = this.m_settings.GetVar(this.m_groupPath, n"Cinematic") as ConfigVarBool;
    this.SetSubsVisibilitySetting(configVar.GetValue());
  }

  private final func UpdateSubsForeignVisibilitySettings() -> Void {
    let configVar: ref<ConfigVarBool> = this.m_settings.GetVar(this.m_groupPath, n"CinematicForceKiroshiTexts") as ConfigVarBool;
    this.SetSubsForeignLinesVisibilitySetting(configVar.GetValue());
  }

  private final func UpdateChattersVisibilitySetting() -> Void {
    let configVar: ref<ConfigVarBool> = this.m_settings.GetVar(this.m_groupPath, n"Overheads") as ConfigVarBool;
    this.SetChattersVisibilitySetting(configVar.GetValue());
  }

  private final func UpdateChattersForeignVisibilitySettings() -> Void {
    let configVar: ref<ConfigVarBool> = this.m_settings.GetVar(this.m_groupPath, n"OverheadsForceKiroshiTexts") as ConfigVarBool;
    this.SetChattersForeignLinesVisibilitySetting(configVar.GetValue());
  }

  private final func UpdateSizeSettings() -> Void {
    let configVar: ref<ConfigVarListInt> = this.m_settings.GetVar(this.m_groupPath, this.GetTextSizeSettigId()) as ConfigVarListInt;
    this.SetSizeSettings(configVar.GetValue());
  }

  private final func UpdateBackgroundOpacitySettings() -> Void {
    let configVar: ref<ConfigVarFloat> = this.m_settings.GetVar(this.m_groupPath, n"BackgroundOpacity") as ConfigVarFloat;
    this.SetBackgroundOpacitySettings(configVar.GetValue());
  }

  private final func ShowPendingSubtitles() -> Void {
    let pendingSubtitles: gamePendingSubtitles = GameInstance.GetSubtitleHandlerSystem(this.GetGame()).RegisterSubtitleController(this);
    this.ShowDialogLines(pendingSubtitles.pendingSubtitles);
  }

  protected func GetTextSizeSettigId() -> CName {
    return n"TextSize";
  }

  protected func SetSubsVisibilitySetting(value: Bool) -> Void;

  protected func SetChattersVisibilitySetting(value: Bool) -> Void;

  protected func ShowKiroshiSettings(value: Bool) -> Void;

  protected func SetSubsForeignLinesVisibilitySetting(value: Bool) -> Void;

  protected func SetChattersForeignLinesVisibilitySetting(value: Bool) -> Void;

  protected func SetSizeSettings(value: Int32) -> Void {
    this.m_fontSize = value;
  }

  protected func SetBackgroundOpacitySettings(value: Float) -> Void {
    this.m_backgroundOpacity = value;
  }

  private final func FindLineWidget(lineID: CRUID) -> wref<inkWidget> {
    let currLine: subtitleLineMapEntry;
    let i: Int32 = 0;
    while i < ArraySize(this.m_lineMap) {
      currLine = this.m_lineMap[i];
      if Equals(currLine.id, lineID) {
        return currLine.widget;
      };
      i += 1;
    };
    return null;
  }

  private final func FindLineController(lineID: CRUID) -> wref<BaseSubtitleLineLogicController> {
    let widget: wref<inkWidget> = this.FindLineWidget(lineID);
    if IsDefined(widget) {
      return widget.GetController() as BaseSubtitleLineLogicController;
    };
    return null;
  }

  private final func SpawnDialogLine(lineData: scnDialogLineData) -> Void {
    let controller: wref<BaseSubtitleLineLogicController>;
    let lineSpawnData: ref<LineSpawnData>;
    if NotEquals(lineData.type, scnDialogLineType.GlobalTV) {
      controller = this.FindLineController(lineData.id);
    };
    if controller == null {
      lineSpawnData = new LineSpawnData();
      lineSpawnData.Initialize(lineData);
      this.CreateLine(lineSpawnData);
    } else {
      this.OnSubCreated(controller);
      controller.SetKiroshiStatus(this.IsKiroshiEnabled(lineData));
      controller.SetLineData(lineData);
      controller.ShowBackground(this.m_showBackgroud);
    };
  }

  protected cb func OnLineSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let controller: wref<BaseSubtitleLineLogicController>;
    let newLineEntry: subtitleLineMapEntry;
    let lineSpawnData: ref<LineSpawnData> = userData as LineSpawnData;
    if IsDefined(widget) {
      this.SetupLine(widget, lineSpawnData);
      controller = widget.GetController() as BaseSubtitleLineLogicController;
      newLineEntry.id = lineSpawnData.m_lineData.id;
      newLineEntry.widget = widget;
      newLineEntry.owner = lineSpawnData.m_lineData.speaker;
      ArrayPush(this.m_lineMap, newLineEntry);
      this.OnSubCreated(controller);
      controller.SetKiroshiStatus(this.IsKiroshiEnabled(lineSpawnData.m_lineData));
      controller.SetLineData(lineSpawnData.m_lineData);
      controller.ShowBackground(this.m_showBackgroud);
    };
    this.TryRemovePendingHideLines();
  }

  protected func OnSubCreated(controller: wref<BaseSubtitleLineLogicController>) -> Void {
    controller.SetupSettings(this.m_fontSize, this.m_backgroundOpacity);
  }

  protected func OnRemovalFailure(lineId: CRUID) -> Void;

  private final func RemoveLineByData(line: scnDialogLineData) -> Bool {
    let currLine: subtitleLineMapEntry;
    let result: Bool = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_lineMap) {
      currLine = this.m_lineMap[i];
      if !IsDefined(currLine.owner) || IsDefined(line.speaker) && Equals(currLine.owner.GetPersistentID(), line.speaker.GetPersistentID()) {
        this.OnHideLineByData(currLine);
        ArrayErase(this.m_lineMap, i);
        result = true;
        i -= 1;
      };
      i += 1;
    };
    if !result {
      this.OnRemovalFailure(line.id);
    };
    return result;
  }

  private final func TryRemovePendingHideLines() -> Void {
    let currLine: CRUID;
    let count: Int32 = ArraySize(this.m_pendingHideLines);
    let i: Int32 = 0;
    while i < count {
      currLine = this.m_pendingHideLines[i];
      this.RemoveLine(currLine);
      i += 1;
    };
    this.CalculateVisibility();
  }

  private final func RemoveLine(lineID: CRUID) -> Bool {
    let currLine: subtitleLineMapEntry;
    let result: Bool = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_lineMap) {
      currLine = this.m_lineMap[i];
      if Equals(currLine.id, lineID) {
        this.OnHideLine(currLine);
        ArrayErase(this.m_lineMap, i);
        result = true;
      } else {
        i += 1;
      };
    };
    if !result {
      this.OnRemovalFailure(lineID);
    };
    return result;
  }

  private final func Cleanup() -> Void {
    let currLine: subtitleLineMapEntry;
    let i: Int32 = 0;
    while i < ArraySize(this.m_lineMap) {
      currLine = this.m_lineMap[i];
      this.OnHideLine(currLine);
      ArrayErase(this.m_lineMap, i);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_pendingShowLines) {
      ArrayErase(this.m_pendingShowLines, i);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_pendingHideLines) {
      ArrayErase(this.m_pendingHideLines, i);
      i += 1;
    };
  }

  private final func ResolveShowHidePendingLines(currLine: CRUID) -> Void {
    if ArrayContains(this.m_pendingShowLines, currLine) && !ArrayContains(this.m_pendingHideLines, currLine) {
      ArrayRemove(this.m_pendingShowLines, currLine);
      ArrayPush(this.m_pendingHideLines, currLine);
    };
  }

  protected func CalculateVisibility() -> Void {
    this.GetRootWidget().SetVisible(ArraySize(this.m_lineMap) > 0);
  }

  protected final func IsMainDialogLine(lineData: scnDialogLineData) -> Bool {
    let player: wref<PlayerPuppet>;
    let playerVehicle: wref<VehicleObject>;
    let speakerVehicle: wref<VehicleObject> = lineData.speaker as VehicleObject;
    if speakerVehicle != null && Equals(lineData.type, scnDialogLineType.Radio) {
      player = this.GetPlayerControlledObject() as PlayerPuppet;
      VehicleComponent.GetVehicle(player.GetGame(), player.GetEntityID(), playerVehicle);
      return playerVehicle == speakerVehicle;
    };
    return lineData.speaker != null && NotEquals(lineData.type, scnDialogLineType.Radio) && NotEquals(lineData.type, scnDialogLineType.OverHead) && NotEquals(lineData.type, scnDialogLineType.OverHeadAlwaysVisible) && NotEquals(lineData.type, scnDialogLineType.GlobalTV) && NotEquals(lineData.type, scnDialogLineType.Invisible) || Equals(lineData.type, scnDialogLineType.OwnerlessRegular);
  }

  protected final func GetGame() -> GameInstance {
    return this.m_gameInstance;
  }
}

public class BaseSubtitleLineLogicController extends inkLogicController {

  private let m_root: wref<inkWidget>;

  private let m_isKiroshiEnabled: Bool;

  @default(BaseSubtitleLineLogicController, 0.5)
  private let c_tier1_duration: Float;

  @default(BaseSubtitleLineLogicController, 5)
  private let c_tier2_duration: Float;

  public func SetupSettings(textSize: Int32, backgroundOpacity: Float) -> Void;

  protected final func SetupAnimation(duration: Float, animCtrl: wref<inkTextKiroshiAnimController>) -> Void {
    if duration < this.c_tier1_duration {
      animCtrl.SetDuration(0.20);
      animCtrl.SetDelay(0.20);
      animCtrl.SetStart(0.00);
    } else {
      if duration < this.c_tier2_duration {
        animCtrl.SetDuration(0.50 + duration * 0.10);
        animCtrl.SetDelay(0.25);
        animCtrl.SetStart(0.00);
      } else {
        animCtrl.SetDuration(0.50 + duration * 0.10);
        animCtrl.SetDelay(0.00);
        animCtrl.SetStart(0.05);
      };
    };
  }

  protected final func SetupAnimation(duration: Float, animCtrl: wref<inkTextReplaceController>) -> Void {
    if duration < this.c_tier1_duration {
      animCtrl.SetDuration(0.20);
      animCtrl.SetDelay(0.20);
      animCtrl.SetStart(0.00);
    } else {
      if duration < this.c_tier2_duration {
        animCtrl.SetDuration(0.50 + duration * 0.10);
        animCtrl.SetDelay(0.25);
        animCtrl.SetStart(0.00);
      } else {
        animCtrl.SetDuration(0.50 + duration * 0.10);
        animCtrl.SetDelay(0.00);
        animCtrl.SetStart(0.05);
      };
    };
  }

  public func SetLineData(lineData: scnDialogLineData) -> Void {
    this.GetRootWidget().SetOpacity(lineData.isPersistent ? 1.00 : 0.50);
  }

  public final func SetKiroshiStatus(kiroshiStatus: Bool) -> Void {
    this.m_isKiroshiEnabled = kiroshiStatus;
  }

  public final func IsKiroshiEnabled() -> Bool {
    return this.m_isKiroshiEnabled;
  }

  public func ShowBackground(value: Bool) -> Void;
}
