
public class ChattersGameController extends BaseSubtitlesGameController {

  @default(ChattersGameController, 150)
  private let c_DisplayRange: Float;

  @default(ChattersGameController, 20)
  private let c_CloseDisplayRange: Float;

  @default(ChattersGameController, 5.f)
  private let c_TimeToUnblockSec: Float;

  private let m_rootWidget: wref<inkCompoundWidget>;

  private let m_AllControllers: array<ChatterKeyValuePair>;

  private let m_targetingSystem: ref<TargetingSystem>;

  private let m_broadcastBlockingLines: array<CRUID>;

  @default(ChattersGameController, false)
  private let m_playerInDialogChoice: Bool;

  private let m_lastBroadcastBlockingLineTime: EngineTime;

  private let m_lastChoiceTime: EngineTime;

  private let m_bbPSceneTierEventId: ref<CallbackHandle>;

  private let m_sceneTier: Int32;

  private let m_OnNameplateEntityChangedCallback: ref<CallbackHandle>;

  private let m_OnNameplateOffsetChangedCallback: ref<CallbackHandle>;

  private let m_OnNameplateVisibilityChangedCallback: ref<CallbackHandle>;

  private let m_OnScannerModeChangedCallback: ref<CallbackHandle>;

  private let m_OnOnDialogsDataCallback: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    let blackboard: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    let blackboardUI: ref<IBlackboard>;
    let blackboardUIInteractions: ref<IBlackboard>;
    super.OnInitialize();
    this.m_rootWidget = this.GetRootWidget() as inkCompoundWidget;
    blackboardSystem = this.GetBlackboardSystem();
    blackboard = blackboardSystem.Get(GetAllBlackboardDefs().UI_NameplateData);
    this.m_OnNameplateEntityChangedCallback = blackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_NameplateData.EntityID, this, n"OnNameplateEntityChanged");
    this.m_OnNameplateOffsetChangedCallback = blackboard.RegisterListenerFloat(GetAllBlackboardDefs().UI_NameplateData.HeightOffset, this, n"OnNameplateOffsetChanged");
    this.m_OnNameplateVisibilityChangedCallback = blackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_NameplateData.IsVisible, this, n"OnNameplateVisibilityChanged");
    this.m_targetingSystem = GameInstance.GetTargetingSystem(this.GetPlayerControlledObject().GetGame());
    blackboardUI = blackboardSystem.Get(GetAllBlackboardDefs().UI_Scanner);
    this.m_OnScannerModeChangedCallback = blackboardUI.RegisterListenerVariant(GetAllBlackboardDefs().UI_Scanner.ScannerMode, this, n"OnScannerModeChanged");
    this.m_lastBroadcastBlockingLineTime = EngineTime.FromFloat(-this.c_TimeToUnblockSec);
    this.m_lastChoiceTime = EngineTime.FromFloat(-this.c_TimeToUnblockSec);
    blackboardUIInteractions = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UIInteractions);
    this.m_OnOnDialogsDataCallback = blackboardUIInteractions.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UIInteractions.DialogChoiceHubs, this, n"OnDialogsData");
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerGameObject);
      if IsDefined(playerStateMachineBlackboard) {
        this.m_bbPSceneTierEventId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.SceneTier, this, n"OnSceneTierChange");
        this.m_sceneTier = playerStateMachineBlackboard.GetInt(playerSMDef.SceneTier);
      };
    };
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerGameObject);
      if IsDefined(playerStateMachineBlackboard) {
        playerStateMachineBlackboard.UnregisterListenerInt(playerSMDef.SceneTier, this.m_bbPSceneTierEventId);
      };
    };
  }

  protected cb func OnSceneTierChange(argTier: Int32) -> Bool {
    this.m_sceneTier = argTier;
  }

  protected func GetTextSizeSettigId() -> CName {
    return n"ChattersTextSize";
  }

  protected func SetChattersVisibilitySetting(value: Bool) -> Void {
    this.DisableBySettings(!value);
  }

  protected func SetChattersForeignLinesVisibilitySetting(value: Bool) -> Void {
    this.ForceForeignLinesBySettings(value);
  }

  protected func ShowKiroshiSettings(value: Bool) -> Void {
    let configVar: ref<ConfigVarBool> = this.m_settings.GetVar(this.m_groupPath, n"OverheadsForceKiroshiTexts") as ConfigVarBool;
    configVar.SetVisible(value);
  }

  protected func OnSubCreated(controller: wref<BaseSubtitleLineLogicController>) -> Void {
    let isNameplateVisible: Bool;
    let nameplateEntityId: EntityID;
    let blackboardSystem: ref<BlackboardSystem> = this.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_NameplateData);
    let tmpVariant: Variant = blackboard.GetVariant(GetAllBlackboardDefs().UI_NameplateData.EntityID);
    if VariantIsValid(tmpVariant) {
      nameplateEntityId = FromVariant(tmpVariant);
    };
    isNameplateVisible = blackboard.GetBool(GetAllBlackboardDefs().UI_NameplateData.IsVisible);
    (controller as ChatterLineLogicController).SetNameplateData(isNameplateVisible, nameplateEntityId);
    this.OnSubCreated(controller);
  }

  private final func OnNameplateOffsetChanged(vrt: Float) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_AllControllers) {
      this.m_AllControllers[i].Value.SetNameplateOffsetValue(vrt);
      i = i + 1;
    };
  }

  private final func OnNameplateEntityChanged(vrt: Variant) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_AllControllers) {
      this.m_AllControllers[i].Value.SetNameplateEntity(vrt);
      i = i + 1;
    };
  }

  private final func OnNameplateVisibilityChanged(visibility: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_AllControllers) {
      this.m_AllControllers[i].Value.SetNameplateVisibility(visibility);
      i = i + 1;
    };
  }

  private final func OnNameplateChanged() -> Void {
    let blackboardSystem: ref<BlackboardSystem> = this.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_NameplateData);
    let nameplateEntityId: EntityID = FromVariant(blackboard.GetVariant(GetAllBlackboardDefs().UI_NameplateData.EntityID));
    let isNameplateVisible: Bool = blackboard.GetBool(GetAllBlackboardDefs().UI_NameplateData.IsVisible);
    this.UpdateChattersNameplateData(nameplateEntityId, isNameplateVisible);
  }

  protected cb func OnDialogsData(value: Variant) -> Bool {
    let data: DialogChoiceHubs = FromVariant(value);
    let inDialogChoice: Bool = ArraySize(data.choiceHubs) > 0;
    if !inDialogChoice && this.m_playerInDialogChoice {
      this.m_lastChoiceTime = GameInstance.GetSimTime(this.GetGame());
    };
    this.m_playerInDialogChoice = inDialogChoice;
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  private final func AddBroadcastBlockingLine(lineData: scnDialogLineData) -> Void {
    if !ArrayContains(this.m_broadcastBlockingLines, lineData.id) {
      ArrayPush(this.m_broadcastBlockingLines, lineData.id);
    };
  }

  private final func IsBroadcastBlockedByMainDialogue() -> Bool {
    return this.m_playerInDialogChoice || ArraySize(this.m_broadcastBlockingLines) > 0 || EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()) - this.m_lastBroadcastBlockingLineTime) < this.c_TimeToUnblockSec || EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()) - this.m_lastChoiceTime) < this.c_TimeToUnblockSec;
  }

  private final func IsLineTypeConditionFulfilled(lineData: scnDialogLineData) -> Bool {
    let player: wref<PlayerPuppet>;
    let speakerVehicle: wref<VehicleObject>;
    if Equals(lineData.type, scnDialogLineType.OverHead) || Equals(lineData.type, scnDialogLineType.OverHeadAlwaysVisible) {
      return true;
    };
    if Equals(lineData.type, scnDialogLineType.Radio) {
      player = this.GetPlayerControlledObject() as PlayerPuppet;
      speakerVehicle = lineData.speaker as VehicleObject;
      return speakerVehicle == null && lineData.speaker != player && !this.IsBroadcastBlockedByMainDialogue();
    };
    if Equals(lineData.type, scnDialogLineType.GlobalTV) {
      return !this.IsBroadcastBlockedByMainDialogue();
    };
    return false;
  }

  private final func IsDistanceConditionFulfilled(lineData: scnDialogLineData) -> Bool {
    let range: Float = this.m_sceneTier < EnumInt(GameplayTier.Tier2_StagedGameplay) ? this.c_DisplayRange : this.c_CloseDisplayRange;
    return Vector4.DistanceSquared(this.GetPlayerControlledObject().GetWorldPosition(), lineData.speaker.GetWorldPosition()) < range * range;
  }

  protected func ShouldDisplayLine(lineData: scnDialogLineData) -> Bool {
    if this.IsMainDialogLine(lineData) {
      this.AddBroadcastBlockingLine(lineData);
      return false;
    };
    if Equals(lineData.type, scnDialogLineType.OverHeadAlwaysVisible) {
      return true;
    };
    return lineData.speaker != null && this.m_sceneTier < EnumInt(GameplayTier.Tier3_LimitedGameplay) && this.IsLineTypeConditionFulfilled(lineData) && this.IsDistanceConditionFulfilled(lineData);
  }

  private func OnRemovalFailure(lineId: CRUID) -> Void {
    if ArrayRemove(this.m_broadcastBlockingLines, lineId) && ArraySize(this.m_broadcastBlockingLines) == 0 {
      this.m_lastBroadcastBlockingLineTime = GameInstance.GetSimTime(this.GetGame());
    };
  }

  protected func CreateLine(lineSpawnData: ref<LineSpawnData>) -> Void {
    this.AsyncSpawnFromLocal(this.m_rootWidget, n"Line", this, n"OnLineSpawned", lineSpawnData);
  }

  protected func SetupLine(lineWidget: ref<inkWidget>, lineSpawnData: ref<LineSpawnData>) -> Void {
    let currKeyValuePair: ChatterKeyValuePair;
    let gameObject: wref<GameObject> = lineSpawnData.m_lineData.speaker;
    let isDevice: Bool = IsDefined(gameObject) && gameObject.IsDevice();
    this.StartScreenProjection(lineWidget, isDevice);
    currKeyValuePair.Key = lineSpawnData.m_lineData.id;
    currKeyValuePair.Value = lineWidget.GetController() as ChatterLineLogicController;
    currKeyValuePair.Owner = lineSpawnData.m_lineData.speaker;
    ArrayPush(this.m_AllControllers, currKeyValuePair);
  }

  protected func OnHideLineByData(lineData: subtitleLineMapEntry) -> Void {
    let i: Int32;
    this.OnHideLineByData(lineData);
    this.StopScreenProjection(lineData.widget);
    this.m_rootWidget.RemoveChild(lineData.widget);
    i = 0;
    while i < ArraySize(this.m_AllControllers) {
      if !IsDefined(this.m_AllControllers[i].Owner) || IsDefined(lineData.owner) && Equals(this.m_AllControllers[i].Owner.GetPersistentID(), lineData.owner.GetPersistentID()) {
        ArrayErase(this.m_AllControllers, i);
        i -= 1;
      };
      i = i + 1;
    };
  }

  protected func OnHideLine(lineData: subtitleLineMapEntry) -> Void {
    let i: Int32;
    this.OnHideLine(lineData);
    this.StopScreenProjection(lineData.widget);
    this.m_rootWidget.RemoveChild(lineData.widget);
    i = 0;
    while i < ArraySize(this.m_AllControllers) {
      if Equals(this.m_AllControllers[i].Key, lineData.id) {
        ArrayErase(this.m_AllControllers, i);
      };
      i = i + 1;
    };
  }

  private final func StartScreenProjection(lineWidget: wref<inkWidget>, isDevice: Bool) -> Void {
    let controller: wref<ChatterLineLogicController> = lineWidget.GetController() as ChatterLineLogicController;
    let projection: ref<inkScreenProjection> = this.RegisterScreenProjection(controller.CreateProjectionData(isDevice));
    controller.SetProjection(projection);
  }

  private final func StopScreenProjection(lineWidget: wref<inkWidget>) -> Void {
    let controller: wref<ChatterLineLogicController> = lineWidget.GetController() as ChatterLineLogicController;
    this.UnregisterScreenProjection(controller.GetProjection());
  }

  protected cb func OnScreenProjectionUpdate(projections: ref<gameuiScreenProjectionsData>) -> Bool {
    let X: Float;
    let Y: Float;
    let controller: wref<ChatterLineLogicController>;
    let distance: Float;
    let projection: ref<inkScreenProjection>;
    let screenSize: Vector2;
    let target: EntityID;
    let closestDistance: Float = 100000.00;
    let count: Int32 = ArraySize(projections.data);
    let i: Int32 = 0;
    while i < count {
      projection = projections.data[i];
      controller = projection.GetUserData() as ChatterLineLogicController;
      screenSize = this.m_rootWidget.GetSize();
      X = projection.currentPosition.X;
      Y = projection.currentPosition.Y;
      X -= screenSize.X / 2.00;
      Y -= screenSize.Y / 2.00;
      distance = SqrtF(X * X + Y * Y);
      if distance < closestDistance && projection.IsInScreen() {
        closestDistance = distance;
        target = controller.GetOwnerID();
      };
      i += 1;
    };
    i = 0;
    while i < count {
      projection = projections.data[i];
      controller = projection.GetUserData() as ChatterLineLogicController;
      controller.UpdateProjection(target, this);
      i += 1;
    };
  }

  protected cb func OnNameplateVisibleEvent(evt: ref<NameplateVisibleEvent>) -> Bool {
    this.UpdateChattersNameplateData(evt.entityID, evt.isNameplateVisible);
  }

  private final func UpdateChattersNameplateData(entID: EntityID, isVisible: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_AllControllers) {
      this.m_AllControllers[i].Value.SetNameplateData(isVisible, entID);
      i = i + 1;
    };
  }

  protected cb func OnScannerModeChanged(val: Variant) -> Bool {
    let evt: ref<ScanningModeEvent> = FromVariant(val);
    this.m_rootWidget.SetVisible(Equals(evt.mode, gameScanningMode.Inactive));
  }
}

public class ChatterLineLogicController extends BaseSubtitleLineLogicController {

  private edit let m_TextContainer: inkWidgetRef;

  private edit let m_speachBubble: inkWidgetRef;

  private edit let m_background: inkRectangleRef;

  private edit let m_container_normal: inkWidgetRef;

  private edit let m_container_wide: inkWidgetRef;

  private edit let m_text_normal: inkTextRef;

  private edit let m_text_wide: inkTextRef;

  private let m_kiroshiAnimationCtrl_Normal: wref<inkTextKiroshiAnimController>;

  private let m_kiroshiAnimationCtrl_Wide: wref<inkTextKiroshiAnimController>;

  private let m_motherTongueCtrl_Normal: wref<inkTextMotherTongueController>;

  private let m_motherTongueCtrl_Wide: wref<inkTextMotherTongueController>;

  private let m_isNameplateVisible: Bool;

  private let m_nameplateEntityId: EntityID;

  private let m_nameplatHeightOffset: Float;

  private let m_ownerId: EntityID;

  @default(ChatterLineLogicController, 110)
  private let c_ExtraWideTextWidth: Int32;

  private let m_rootWidget: wref<inkWidget>;

  private let m_projection: ref<inkScreenProjection>;

  private let m_subtitlesMaxDistance: Float;

  private let m_limitSubtitlesDistance: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_kiroshiAnimationCtrl_Normal = inkWidgetRef.GetController(this.m_container_normal) as inkTextKiroshiAnimController;
    this.m_kiroshiAnimationCtrl_Wide = inkWidgetRef.GetController(this.m_container_wide) as inkTextKiroshiAnimController;
    this.m_motherTongueCtrl_Normal = inkWidgetRef.GetControllerByType(this.m_container_normal, n"inkTextMotherTongueController") as inkTextMotherTongueController;
    this.m_motherTongueCtrl_Wide = inkWidgetRef.GetControllerByType(this.m_container_wide, n"inkTextMotherTongueController") as inkTextMotherTongueController;
    inkWidgetRef.SetVisible(this.m_speachBubble, false);
  }

  public final func GetOwnerID() -> EntityID {
    return this.m_ownerId;
  }

  public func SetupSettings(textSize: Int32, backgroundOpacity: Float) -> Void {
    inkTextRef.SetFontSize(this.m_text_normal, textSize);
    inkTextRef.SetFontSize(this.m_text_wide, textSize);
    this.m_kiroshiAnimationCtrl_Normal.SetupFontSettings(textSize);
    this.m_kiroshiAnimationCtrl_Wide.SetupFontSettings(textSize);
    inkWidgetRef.SetOpacity(this.m_background, backgroundOpacity / 100.00);
  }

  public func ShowBackground(value: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_background, value);
  }

  public func SetLineData(lineData: scnDialogLineData) -> Void {
    let animCtrl: wref<inkTextKiroshiAnimController>;
    let displayData: scnDialogDisplayString;
    let isWide: Bool;
    let motherTongueCtrl: wref<inkTextMotherTongueController>;
    let gameObject: wref<GameObject> = lineData.speaker;
    if IsDefined(gameObject) && gameObject.IsDevice() {
      this.m_rootWidget.SetAnchorPoint(new Vector2(0.50, 0.00));
      this.m_limitSubtitlesDistance = true;
      this.m_subtitlesMaxDistance = 10.00;
    } else {
      this.m_rootWidget.SetAnchorPoint(new Vector2(0.50, 1.00));
      this.m_limitSubtitlesDistance = false;
      this.m_subtitlesMaxDistance = 0.00;
    };
    this.m_projection.SetEntity(lineData.speaker);
    displayData = scnDialogLineData.GetDisplayText(lineData);
    isWide = StrLen(displayData.translation) >= this.c_ExtraWideTextWidth;
    this.m_ownerId = lineData.speaker.GetEntityID();
    if isWide {
      animCtrl = this.m_kiroshiAnimationCtrl_Wide;
      motherTongueCtrl = this.m_motherTongueCtrl_Wide;
    } else {
      animCtrl = this.m_kiroshiAnimationCtrl_Normal;
      motherTongueCtrl = this.m_motherTongueCtrl_Normal;
    };
    inkWidgetRef.SetVisible(this.m_text_normal, !isWide);
    inkWidgetRef.SetVisible(this.m_text_wide, isWide);
    inkWidgetRef.SetVisible(this.m_container_normal, !isWide);
    inkWidgetRef.SetVisible(this.m_container_wide, isWide);
    inkWidgetRef.SetVisible(this.m_TextContainer, false);
    inkWidgetRef.SetVisible(this.m_speachBubble, true);
    if scnDialogLineData.HasKiroshiTag(lineData) {
      displayData = scnDialogLineData.GetDisplayText(lineData);
      if this.IsKiroshiEnabled() {
        animCtrl.SetPreTranslatedText(displayData.preTranslatedText);
        animCtrl.SetNativeText(displayData.text, displayData.language);
        animCtrl.SetTargetText(displayData.translation);
        animCtrl.SetPostTranslatedText(displayData.postTranslatedText);
        this.SetupAnimation(lineData.duration, animCtrl);
        animCtrl.PlaySetAnimation();
      } else {
        motherTongueCtrl.SetPreTranslatedText("");
        motherTongueCtrl.SetNativeText(displayData.text, displayData.language);
        motherTongueCtrl.SetTranslatedText("");
        motherTongueCtrl.SetPostTranslatedText("");
        motherTongueCtrl.ApplyTexts();
      };
    } else {
      if scnDialogLineData.HasMothertongueTag(lineData) {
        displayData = scnDialogLineData.GetDisplayText(lineData);
        motherTongueCtrl.SetPreTranslatedText(displayData.preTranslatedText);
        motherTongueCtrl.SetNativeText(displayData.text, displayData.language);
        motherTongueCtrl.SetTranslatedText(displayData.translation);
        motherTongueCtrl.SetPostTranslatedText(displayData.postTranslatedText);
        motherTongueCtrl.ApplyTexts();
      } else {
        inkTextRef.SetText(this.m_text_normal, lineData.text);
        inkTextRef.SetText(this.m_text_wide, lineData.text);
      };
    };
  }

  public final func CreateProjectionData(isDevice: Bool) -> inkScreenProjectionData {
    let projectionData: inkScreenProjectionData;
    projectionData.userData = this;
    projectionData.slotComponentName = n"UI_Slots";
    if isDevice {
      projectionData.fixedWorldOffset = new Vector4(0.00, 0.00, 0.00, 0.00);
      projectionData.slotName = n"UI_Subtitles";
      projectionData.slotFallbackName = n"UI_Interaction";
    } else {
      projectionData.fixedWorldOffset = new Vector4(0.00, 0.00, 0.30, 0.00);
      projectionData.slotName = n"UI_Interaction";
      projectionData.slotFallbackName = n"UI_Subtitles";
    };
    return projectionData;
  }

  public final func GetProjection() -> ref<inkScreenProjection> {
    return this.m_projection;
  }

  public final func SetProjection(projection: ref<inkScreenProjection>) -> Void {
    this.m_projection = projection;
  }

  public final func UpdateProjection(targetedObject: EntityID, owner: wref<ChattersGameController>) -> Void {
    let isBubble: Bool;
    let isVisible: Bool;
    let margin: inkMargin;
    let voIsPerceptible: Bool;
    if IsDefined(this.m_projection) {
      voIsPerceptible = this.m_projection.VoIsPerceptible(targetedObject);
      isVisible = true;
      if !this.m_limitSubtitlesDistance {
        isBubble = targetedObject != this.m_ownerId;
      } else {
        isVisible = voIsPerceptible;
        isBubble = targetedObject != this.m_ownerId || this.m_projection.distanceToCamera >= this.m_subtitlesMaxDistance;
      };
      margin.left = this.m_projection.currentPosition.X;
      margin.top = this.m_projection.currentPosition.Y;
      if this.m_isNameplateVisible && this.m_projection.GetEntity().GetEntityID() == this.m_nameplateEntityId {
        margin.top -= 30.00;
      };
      owner.ApplyProjectionMarginOnWidget(this.m_rootWidget, margin);
      if this.m_projection.IsInScreen() {
        inkWidgetRef.SetVisible(this.m_TextContainer, isVisible && !isBubble);
        inkWidgetRef.SetVisible(this.m_speachBubble, isVisible && isBubble);
      };
    };
  }

  public final func SetNameplateData(argNameplateVisible: Bool, argEntityId: EntityID) -> Void {
    this.m_isNameplateVisible = argNameplateVisible;
    this.m_nameplateEntityId = argEntityId;
  }

  public final func SetNameplateOffsetValue(value: Float) -> Void {
    this.m_nameplatHeightOffset = value;
  }

  public final func SetNameplateEntity(blackboardVariant: Variant) -> Void {
    this.m_nameplateEntityId = FromVariant(blackboardVariant);
  }

  public final func SetNameplateVisibility(isVisible: Bool) -> Void {
    this.m_isNameplateVisible = isVisible;
  }
}
