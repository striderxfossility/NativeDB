
public class SubtitlesGameController extends BaseSubtitlesGameController {

  private let m_sceneComment: wref<inkText>;

  private let m_subtitlesPanel: wref<inkVerticalPanel>;

  private let m_bbCbShowSceneComment: ref<CallbackHandle>;

  private let m_bbCbHideSceneComment: ref<CallbackHandle>;

  private let m_uiSceneCommentsBlackboard: wref<IBlackboard>;

  protected cb func OnInitialize() -> Bool {
    this.m_sceneComment = this.GetWidget(n"mainPanel/sceneComment") as inkText;
    this.m_subtitlesPanel = this.GetWidget(n"mainPanel/subtitlesPanel") as inkVerticalPanel;
    super.OnInitialize();
    if IsDefined(this.m_sceneComment) {
      this.m_sceneComment.SetVisible(false);
    };
    this.m_uiSceneCommentsBlackboard = this.GetUIBlackboard();
    this.m_bbCbShowSceneComment = this.m_uiSceneCommentsBlackboard.RegisterDelayedListenerString(GetAllBlackboardDefs().UIGameData.ShowSceneComment, this, n"OnShowSceneComment");
    this.m_bbCbHideSceneComment = this.m_uiSceneCommentsBlackboard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UIGameData.HideSceneComment, this, n"OnHideSceneComment");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_uiSceneCommentsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UIGameData.ShowSceneComment, this.m_bbCbShowSceneComment);
    this.m_uiSceneCommentsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UIGameData.HideSceneComment, this.m_bbCbHideSceneComment);
    super.OnUninitialize();
  }

  protected func OnSubCreated(controller: wref<BaseSubtitleLineLogicController>) -> Void {
    this.OnSubCreated(controller);
  }

  protected func SetSubsVisibilitySetting(value: Bool) -> Void {
    this.DisableBySettings(!value);
  }

  protected func SetSubsForeignLinesVisibilitySetting(value: Bool) -> Void {
    this.ForceForeignLinesBySettings(value);
  }

  protected func ShowKiroshiSettings(value: Bool) -> Void {
    let configVar: ref<ConfigVarBool> = this.m_settings.GetVar(this.m_groupPath, n"CinematicForceKiroshiTexts") as ConfigVarBool;
    configVar.SetVisible(value);
  }

  protected func ShouldDisplayLine(lineData: scnDialogLineData) -> Bool {
    if Equals(lineData.type, scnDialogLineType.AlwaysCinematicNoSpeaker) || Equals(lineData.type, scnDialogLineType.GlobalTVAlwaysVisible) {
      return true;
    };
    return this.IsMainDialogLine(lineData);
  }

  protected func CreateLine(lineSpawnData: ref<LineSpawnData>) -> Void {
    this.AsyncSpawnFromLocal(this.m_subtitlesPanel, n"Line", this, n"OnLineSpawned", lineSpawnData);
  }

  protected func OnHideLine(lineData: subtitleLineMapEntry) -> Void {
    this.OnHideLine(lineData);
    this.m_subtitlesPanel.RemoveChild(lineData.widget);
  }

  protected func OnHideLineByData(lineData: subtitleLineMapEntry) -> Void {
    this.OnHideLineByData(lineData);
    this.m_subtitlesPanel.RemoveChild(lineData.widget);
  }

  protected cb func OnShowSceneComment(value: String) -> Bool {
    this.m_sceneComment.SetText(value);
    this.m_sceneComment.SetVisible(true);
  }

  protected cb func OnHideSceneComment(value: Bool) -> Bool {
    this.m_sceneComment.SetVisible(false);
  }
}

public class SubtitleLineLogicController extends BaseSubtitleLineLogicController {

  private edit let m_speakerNameWidget: inkTextRef;

  private edit let m_subtitleWidget: inkTextRef;

  private edit let m_radioSpeaker: inkTextRef;

  private edit let m_radioSubtitle: inkTextRef;

  private edit let m_background: inkWidgetRef;

  private edit let m_backgroundSpeaker: inkWidgetRef;

  private edit let m_kiroshiAnimationContainer: inkWidgetRef;

  private edit let m_motherTongueContainter: inkWidgetRef;

  private let m_targetTextWidgetRef: inkTextRef;

  private let m_lineData: scnDialogLineData;

  private let m_spekerNameParams: ref<inkTextParams>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetHAlign(inkEHorizontalAlign.Center);
    inkWidgetRef.SetVisible(this.m_background, true);
    inkWidgetRef.SetVisible(this.m_backgroundSpeaker, true);
    this.m_spekerNameParams = new inkTextParams();
    this.m_spekerNameParams.SetAsyncFormat(false);
    this.m_spekerNameParams.AddLocalizedString("NAME", "");
  }

  public func SetupSettings(textSize: Int32, backgroundOpacity: Float) -> Void {
    let kiroshiAnimationCtrl: ref<inkTextKiroshiAnimController>;
    inkTextRef.SetFontSize(this.m_speakerNameWidget, textSize);
    inkTextRef.SetFontSize(this.m_subtitleWidget, textSize);
    inkTextRef.SetFontSize(this.m_radioSpeaker, textSize);
    inkTextRef.SetFontSize(this.m_radioSubtitle, textSize);
    kiroshiAnimationCtrl = inkWidgetRef.GetController(this.m_kiroshiAnimationContainer) as inkTextKiroshiAnimController;
    kiroshiAnimationCtrl.SetupFontSettings(textSize);
    inkWidgetRef.SetOpacity(this.m_background, backgroundOpacity / 100.00);
    inkWidgetRef.SetOpacity(this.m_backgroundSpeaker, backgroundOpacity / 100.00);
  }

  public func ShowBackground(value: Bool) -> Void;

  public func SetLineData(lineData: scnDialogLineData) -> Void {
    let characterRecordID: TweakDBID;
    let displayData: scnDialogDisplayString;
    let isValidName: Bool;
    let kiroshiAnimationCtrl: ref<inkTextKiroshiAnimController>;
    let motherTongueCtrl: ref<inkTextMotherTongueController>;
    let playerPuppet: ref<gamePuppetBase>;
    let speakerName: String;
    let speakerNameDisplayText: String;
    let speakerNameWidgetStateName: CName;
    this.m_lineData = lineData;
    if IsStringValid(lineData.speakerName) {
      speakerName = lineData.speakerName;
    } else {
      speakerName = lineData.speaker.GetDisplayName();
    };
    isValidName = IsStringValid(speakerName);
    speakerNameDisplayText = isValidName ? "LocKey#76968" : "";
    if isValidName {
      this.m_spekerNameParams.UpdateLocalizedString("NAME", speakerName);
    };
    if IsMultiplayer() {
      speakerNameWidgetStateName = n"Default";
      playerPuppet = lineData.speaker as gamePuppetBase;
      if playerPuppet != null {
        characterRecordID = playerPuppet.GetRecordID();
        speakerNameWidgetStateName = TweakDBInterface.GetCharacterRecord(characterRecordID).CpoClassName();
      };
      inkWidgetRef.SetState(this.m_speakerNameWidget, speakerNameWidgetStateName);
    };
    if Equals(lineData.type, scnDialogLineType.Radio) {
      this.m_targetTextWidgetRef = this.m_radioSubtitle;
      inkTextRef.SetLocalizedTextScript(this.m_radioSpeaker, speakerNameDisplayText, this.m_spekerNameParams);
      inkWidgetRef.SetVisible(this.m_speakerNameWidget, false);
      inkWidgetRef.SetVisible(this.m_subtitleWidget, false);
      inkWidgetRef.SetVisible(this.m_radioSpeaker, true);
      inkWidgetRef.SetVisible(this.m_radioSubtitle, true);
    } else {
      if Equals(lineData.type, scnDialogLineType.AlwaysCinematicNoSpeaker) {
        this.m_targetTextWidgetRef = this.m_radioSubtitle;
        inkWidgetRef.SetVisible(this.m_speakerNameWidget, false);
        inkWidgetRef.SetVisible(this.m_subtitleWidget, false);
        inkWidgetRef.SetVisible(this.m_radioSpeaker, false);
        inkWidgetRef.SetVisible(this.m_radioSubtitle, true);
      } else {
        if Equals(lineData.type, scnDialogLineType.GlobalTVAlwaysVisible) {
          this.m_targetTextWidgetRef = this.m_subtitleWidget;
          inkWidgetRef.SetVisible(this.m_speakerNameWidget, false);
          inkWidgetRef.SetVisible(this.m_subtitleWidget, true);
          inkWidgetRef.SetVisible(this.m_radioSpeaker, false);
          inkWidgetRef.SetVisible(this.m_radioSubtitle, false);
        } else {
          this.m_targetTextWidgetRef = this.m_subtitleWidget;
          inkTextRef.SetLocalizedTextScript(this.m_speakerNameWidget, speakerNameDisplayText, this.m_spekerNameParams);
          inkWidgetRef.SetVisible(this.m_speakerNameWidget, true);
          inkWidgetRef.SetVisible(this.m_subtitleWidget, true);
          inkWidgetRef.SetVisible(this.m_radioSpeaker, false);
          inkWidgetRef.SetVisible(this.m_radioSubtitle, false);
        };
      };
    };
    if scnDialogLineData.HasKiroshiTag(lineData) {
      displayData = scnDialogLineData.GetDisplayText(lineData);
      if this.IsKiroshiEnabled() {
        kiroshiAnimationCtrl = inkWidgetRef.GetController(this.m_kiroshiAnimationContainer) as inkTextKiroshiAnimController;
        kiroshiAnimationCtrl.SetPreTranslatedText(displayData.preTranslatedText);
        kiroshiAnimationCtrl.SetPostTranslatedText(displayData.postTranslatedText);
        kiroshiAnimationCtrl.SetNativeText(displayData.text, displayData.language);
        kiroshiAnimationCtrl.SetTargetText(displayData.translation);
        this.SetupAnimation(this.m_lineData.duration, kiroshiAnimationCtrl);
        kiroshiAnimationCtrl.PlaySetAnimation();
      } else {
        motherTongueCtrl = inkWidgetRef.GetControllerByType(this.m_motherTongueContainter, n"inkTextMotherTongueController") as inkTextMotherTongueController;
        motherTongueCtrl.SetPreTranslatedText("");
        motherTongueCtrl.SetNativeText(displayData.text, displayData.language);
        motherTongueCtrl.SetTranslatedText("");
        motherTongueCtrl.SetPostTranslatedText("");
        motherTongueCtrl.ApplyTexts();
      };
    } else {
      if scnDialogLineData.HasMothertongueTag(lineData) {
        displayData = scnDialogLineData.GetDisplayText(lineData);
        motherTongueCtrl = inkWidgetRef.GetControllerByType(this.m_motherTongueContainter, n"inkTextMotherTongueController") as inkTextMotherTongueController;
        motherTongueCtrl.SetPreTranslatedText(displayData.preTranslatedText);
        motherTongueCtrl.SetNativeText(displayData.text, displayData.language);
        motherTongueCtrl.SetTranslatedText(displayData.translation);
        motherTongueCtrl.SetPostTranslatedText(displayData.postTranslatedText);
        motherTongueCtrl.ApplyTexts();
      } else {
        inkTextRef.SetText(this.m_targetTextWidgetRef, this.m_lineData.text);
        this.PlayLibraryAnimation(n"intro");
      };
    };
  }
}
