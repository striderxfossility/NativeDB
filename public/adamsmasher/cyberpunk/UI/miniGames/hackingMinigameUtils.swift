
public native class TrapTooltipDisplayer extends inkLogicController {

  public native let trap: wref<MiniGame_Trap_Record>;

  private edit let m_delayDuration: Float;

  private let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    let delayAnim: ref<inkAnimDef>;
    let delayInterpolator: ref<inkAnimTranslation>;
    if IsDefined(this.trap) {
      delayAnim = new inkAnimDef();
      delayInterpolator = new inkAnimTranslation();
      delayInterpolator.SetDuration(this.m_delayDuration);
      delayAnim.AddInterpolator(delayInterpolator);
      this.m_animationProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
      this.m_animationProxy = this.GetRootWidget().PlayAnimation(delayAnim);
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnDelayedTooltipRequest");
    };
  }

  protected cb func OnDelayedTooltipRequest(e: ref<inkAnimProxy>) -> Bool {
    let evt: ref<MinigameTooltipShowRequest> = new MinigameTooltipShowRequest();
    evt.data = new MessageTooltipData();
    evt.data.Title = LocKeyToString(this.trap.TrapName());
    evt.data.Description = LocKeyToString(this.trap.TrapDescription());
    this.QueueEvent(evt);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<MinigameTooltipHideRequest> = new MinigameTooltipHideRequest();
    this.m_animationProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
    this.QueueEvent(evt);
  }
}

public native class HackingMinigameGameController extends inkGameController {

  private let m_miniGameRecord: wref<Minigame_Def_Record>;

  private let m_dimension: Int32;

  private let m_isTutorialActive: Bool;

  public let m_isOfficerBreach: Bool;

  public let m_isRemoteBreach: Bool;

  public let m_isItemBreach: Bool;

  public let m_numberAttempts: Int32;

  private edit let m_tooltipsManagerRef: inkWidgetRef;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_uiSystem: ref<UISystem>;

  private let m_contextHelpOverlay: Bool;

  private let m_bbMinigame: wref<IBlackboard>;

  private let m_bbMinigameStateListener: ref<CallbackHandle>;

  private let m_bbUiData: wref<IBlackboard>;

  private let m_bbControllerStateListener: ref<CallbackHandle>;

  public final native func GetProgramsChains() -> array<CharactersChain>;

  public final native func GetUnlockablePrograms() -> array<UnlockableProgram>;

  public final native func GetRarity(rarityValue: Float) -> Int32;

  public final native func GetTrapByProbability(probabilityValue: Float) -> ref<MiniGame_Trap_Record>;

  public final native func GetPlayerPrograms() -> array<MinigameProgramData>;

  public final native func SetTrapIconAtCell(cellCoordinates: Vector2, trap: CName) -> Void;

  public final native func AddUnlockableProgram(program: UnlockableProgram, instruction: array<Uint32>) -> Void;

  public final native func PauseTheTimer() -> Void;

  public final native func ResumeTheTimer() -> Void;

  public final native func EnableWhitelist(enable: Bool) -> Void;

  public final native func IsWhitelistEnabled() -> Bool;

  public final native func WhitelistPosition(position: Vector2) -> Void;

  public final native func RemoveWhitelistedPosition(position: Vector2) -> Void;

  protected cb func OnInitialize() -> Bool {
    let bbNetwork: ref<IBlackboard>;
    let bufferSize: Float;
    let characterRecord: ref<Character_Record>;
    let entity: ref<Entity>;
    let extraDifficulty: Float;
    let gridSymbols: array<wref<RowSymbols_Record>>;
    let gridTraps: array<wref<RowTraps_Record>>;
    let itemRecord: ref<Item_Record>;
    let minigameData: MinigameData;
    let minigameDef: TweakDBID;
    let minigameRules: array<ref<MinigameGenerationRule>>;
    let networkID: TweakDBID;
    let overrideProgramList: array<wref<Program_Record>>;
    let overrideProgramsRule: ref<MinigameGenerationRuleOverridePrograms>;
    let ownerObject: ref<GameObject>;
    let player: wref<PlayerPuppet>;
    let powerLevel: Float;
    let predefBoardRule: ref<MinigameGenerationRulePredefinedBoard>;
    let predefBoardTrapsRule: ref<MinigameGenerationRulePredefinedBoardWithTraps>;
    let scalingProgramsRule: ref<MinigameGenerationRuleScalingPrograms>;
    let symbolsToUse: ref<MiniGame_AllSymbols_Record>;
    let trapProb: Float;
    this.PrepareTooltips();
    this.m_bbMinigame = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().HackingMinigame);
    bbNetwork = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().NetworkBlackboard);
    this.m_bbMinigameStateListener = this.m_bbMinigame.RegisterDelayedListenerInt(GetAllBlackboardDefs().HackingMinigame.State, this, n"OnGameStateChanged");
    this.m_bbUiData = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    this.m_bbControllerStateListener = this.m_bbUiData.RegisterListenerBool(GetAllBlackboardDefs().UIGameData.Controller_Disconnected, this, n"OnDisconnectController");
    ownerObject = this.GetPlayerControlledObject();
    player = ownerObject as PlayerPuppet;
    entity = GameInstance.FindEntityByID(ownerObject.GetGame(), bbNetwork.GetEntityID(GetAllBlackboardDefs().NetworkBlackboard.DeviceID));
    networkID = FromVariant(bbNetwork.GetVariant(GetAllBlackboardDefs().NetworkBlackboard.NetworkTDBID));
    this.m_isRemoteBreach = bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.RemoteBreach);
    this.m_isItemBreach = bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.ItemBreach);
    this.m_uiSystem = GameInstance.GetUISystem(player.GetGame());
    powerLevel = GameInstance.GetStatsSystem((entity as GameObject).GetGame()).GetStatValue(Cast(entity.GetEntityID()), gamedataStatType.PowerLevel);
    this.m_numberAttempts = bbNetwork.GetInt(GetAllBlackboardDefs().NetworkBlackboard.Attempt);
    extraDifficulty = this.m_miniGameRecord.ExtraDifficulty();
    this.m_isOfficerBreach = bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.OfficerBreach);
    if bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.ItemBreach) {
      itemRecord = TweakDBInterface.GetItemRecord(networkID);
      this.m_miniGameRecord = itemRecord.MinigameInstance();
    } else {
      if bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.SuicideBreach) {
        this.m_miniGameRecord = TweakDBInterface.GetMinigame_DefRecord(t"minigame_v2.SuicideMinigame");
      } else {
        if this.m_isOfficerBreach {
          characterRecord = TweakDBInterface.GetCharacterRecord((entity as ScriptedPuppet).GetRecordID());
          this.m_miniGameRecord = characterRecord.MinigameInstance();
        } else {
          minigameDef = FromVariant(bbNetwork.GetVariant(GetAllBlackboardDefs().NetworkBlackboard.MinigameDef));
          if TDBID.IsValid(minigameDef) {
            this.m_miniGameRecord = TweakDBInterface.GetMinigame_DefRecord(minigameDef);
          } else {
            this.m_miniGameRecord = TweakDBInterface.GetMinigame_DefRecord(t"minigame_v2.DefaultMinigame");
          };
        };
      };
    };
    if this.m_miniGameRecord.GetID() == t"minigame_v2.VrTutorialMinigame" {
      this.EnableWhitelist(true);
      this.WhitelistPosition(new Vector2(0.00, 0.00));
    };
    this.m_miniGameRecord.GridSymbols(gridSymbols);
    this.m_miniGameRecord.GridTraps(gridTraps);
    minigameData.timerWaitsForInteraction = true;
    if this.m_miniGameRecord.GridSize() != 0 {
      this.m_dimension = this.m_miniGameRecord.GridSize();
      minigameData.gridSize = Cast(this.m_dimension);
    } else {
      this.ScaleBoard(entity, this.m_dimension, powerLevel + extraDifficulty, symbolsToUse);
      minigameData.gridSize = Cast(this.m_dimension);
    };
    minigameData.symbolsToUse = symbolsToUse;
    if this.m_miniGameRecord.TimeLimit() > 0.00 {
      minigameData.timeLimit = this.m_miniGameRecord.TimeLimit();
      this.ScaleTimer(player, entity, minigameData.timeLimit, powerLevel + extraDifficulty, minigameData.timerWaitsForInteraction);
    };
    if this.m_miniGameRecord.BufferSize() != 0 {
      minigameData.bufferSize = Cast(this.m_miniGameRecord.BufferSize());
    } else {
      this.ScaleBuffer(entity, bufferSize, powerLevel + extraDifficulty, player);
      minigameData.bufferSize = Cast(bufferSize);
    };
    if ArraySize(gridSymbols) > 0 {
      if ArraySize(gridTraps) > 0 {
        predefBoardTrapsRule = new MinigameGenerationRulePredefinedBoardWithTraps();
        predefBoardTrapsRule.SetBlackboard(this.GetBlackboardSystem());
        predefBoardTrapsRule.SetRecord(this.m_miniGameRecord);
        ArrayPush(minigameRules, predefBoardTrapsRule);
      } else {
        predefBoardRule = new MinigameGenerationRulePredefinedBoard();
        predefBoardRule.SetRecord(this.m_miniGameRecord);
        ArrayPush(minigameRules, predefBoardRule);
        if !this.m_miniGameRecord.NoTraps() {
          this.ScaleTraps(entity, player, trapProb, powerLevel + extraDifficulty);
          ArrayPush(minigameRules, new TrapsGenRule());
        };
      };
    } else {
      ArrayPush(minigameRules, new GridNoiseGenRule());
      if !this.m_miniGameRecord.NoTraps() {
        this.ScaleTraps(entity, player, trapProb, powerLevel + extraDifficulty);
        ArrayPush(minigameRules, new TrapsGenRule());
      };
    };
    this.m_miniGameRecord.OverrideProgramsList(overrideProgramList);
    if ArraySize(overrideProgramList) > 0 {
      overrideProgramsRule = new MinigameGenerationRuleOverridePrograms();
      overrideProgramsRule.SetRecord(this.m_miniGameRecord);
      overrideProgramsRule.SetIsItemBreach(this.m_isItemBreach);
      ArrayPush(minigameRules, overrideProgramsRule);
    } else {
      scalingProgramsRule = new MinigameGenerationRuleScalingPrograms();
      scalingProgramsRule.SetBlackboard(this.GetBlackboardSystem());
      scalingProgramsRule.SetEntity(entity);
      scalingProgramsRule.SetPlayer(player);
      scalingProgramsRule.SetBufferSize(Cast(minigameData.bufferSize));
      ArrayPush(minigameRules, scalingProgramsRule);
    };
    if ArraySize(gridSymbols) <= 0 {
      ArrayPush(minigameRules, new ProgramsGridGenRule());
    };
    if ArraySize(minigameRules) > 0 {
      minigameData.rules = minigameRules;
    };
    this.m_bbMinigame.SetVariant(GetAllBlackboardDefs().HackingMinigame.MinigameDefaults, ToVariant(minigameData));
    if this.ProcessMinigameTutorialFact(player) {
      this.m_isTutorialActive = true;
    } else {
      this.m_isTutorialActive = false;
    };
    bbNetwork.SetVariant(GetAllBlackboardDefs().NetworkBlackboard.SelectedMinigameDef, ToVariant(this.m_miniGameRecord.GetID()));
    bbNetwork.SignalVariant(GetAllBlackboardDefs().NetworkBlackboard.SelectedMinigameDef);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleInput");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_bbMinigame.UnregisterDelayedListener(GetAllBlackboardDefs().HackingMinigame.State, this.m_bbMinigameStateListener);
    this.m_bbUiData.UnregisterDelayedListener(GetAllBlackboardDefs().UIGameData.Controller_Disconnected, this.m_bbControllerStateListener);
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleInput");
    if this.m_contextHelpOverlay {
      this.ToggleTutorialOverlay(false);
    };
  }

  protected cb func OnGameStateChanged(value: Int32) -> Bool {
    let state: HackingMinigameState = IntEnum(value);
    if NotEquals(state, HackingMinigameState.InProgress) && this.m_contextHelpOverlay {
      this.ToggleTutorialOverlay(false);
    };
  }

  protected cb func OnHandleInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"context_help") || (evt.IsAction(n"click") || evt.IsAction(n"select") || evt.IsAction(n"cancel")) && this.m_contextHelpOverlay {
      this.ToggleTutorialOverlay(!this.m_contextHelpOverlay);
      this.m_contextHelpOverlay = !this.m_contextHelpOverlay;
    };
  }

  protected cb func OnDisconnectController(isDisconnected: Bool) -> Bool {
    if isDisconnected {
      this.PauseTheTimer();
    } else {
      this.ResumeTheTimer();
    };
  }

  protected cb func OnPositionSelected(position: Vector2) -> Bool {
    let step1: Vector2 = new Vector2(0.00, 0.00);
    let step2: Vector2 = new Vector2(4.00, 0.00);
    let step3: Vector2 = new Vector2(4.00, 1.00);
    let step4: Vector2 = new Vector2(2.00, 1.00);
    if Equals(position, step1) {
      this.RemoveWhitelistedPosition(step1);
      this.WhitelistPosition(step2);
    } else {
      if Equals(position, step2) {
        this.RemoveWhitelistedPosition(step2);
        this.WhitelistPosition(step3);
      } else {
        if Equals(position, step3) {
          this.RemoveWhitelistedPosition(step3);
          this.WhitelistPosition(step4);
        };
      };
    };
  }

  private final func ToggleTutorialOverlay(value: Bool) -> Void {
    let data: TutorialOverlayData;
    data.itemName = n"Root";
    data.widgetLibraryResource = r"base\\gameplay\\gui\\widgets\\tutorial\\vr_minigame_tutorial.inkwidget";
    if value {
      this.m_uiSystem.ShowTutorialOverlay(data);
    } else {
      this.m_uiSystem.HideTutorialOverlay(data);
    };
  }

  private final func PrepareTooltips() -> Void {
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_tooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
  }

  protected cb func OnShowTooltipRequest(request: ref<MinigameTooltipShowRequest>) -> Bool {
    this.m_TooltipsManager.ShowTooltip(0, request.data, new inkMargin(60.00, -60.00, 0.00, 0.00));
  }

  protected cb func OnHideTooltipRequest(request: ref<MinigameTooltipHideRequest>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
  }

  protected cb func OnGridCellPressed(wasHorizontalyActive: Bool) -> Bool {
    this.m_TooltipsManager.HideTooltips();
    if this.m_isTutorialActive {
      this.ProcessMinigameGridClickTutorialFacts(!wasHorizontalyActive);
    };
  }

  private final func ProcessMinigameGridClickTutorialFacts(horizontal: Bool) -> Void {
    let ownerObject: ref<GameObject> = this.GetPlayerControlledObject();
    let player: wref<PlayerPuppet> = ownerObject as PlayerPuppet;
    let questSys: ref<QuestsSystem> = GameInstance.GetQuestsSystem(player.GetGame());
    if horizontal {
      if questSys.GetFact(n"minigame_horizontal_input") == 0 {
        questSys.SetFact(n"minigame_horizontal_input", 1);
      } else {
        this.ResumeTheTimer();
      };
    } else {
      if questSys.GetFact(n"minigame_vertical_input") == 0 {
        questSys.SetFact(n"minigame_vertical_input", 1);
      } else {
        this.m_isTutorialActive = false;
      };
    };
  }

  private final func ProcessMinigameTutorialFact(player: ref<PlayerPuppet>) -> Bool {
    let questSys: ref<QuestsSystem> = GameInstance.GetQuestsSystem(player.GetGame());
    if questSys.GetFact(n"minigame_tutorial") == 0 && questSys.GetFact(n"disable_tutorials") == 0 {
      questSys.SetFact(n"minigame_tutorial", 1);
      return true;
    };
    return false;
  }

  public final func ScaleBoard(entity: ref<Entity>, out size: Int32, powerLevel: Float, out symbolsToUse: ref<MiniGame_AllSymbols_Record>) -> Void {
    let maxLevel: Float = TweakDBInterface.GetStatRecord(t"BaseStats.PowerLevel").Max();
    let difficulty: EGameplayChallengeLevel = (entity as Device).GetDevicePS().GetBackdoorAccessPoint().GetSkillCheckContainer().GetHackingSlot().GetDifficulty();
    switch difficulty {
      case EGameplayChallengeLevel.NONE:
        powerLevel -= 10.00;
        break;
      case EGameplayChallengeLevel.EASY:
        powerLevel -= 0.00;
        break;
      case EGameplayChallengeLevel.HARD:
        powerLevel += 10.00;
        break;
      case EGameplayChallengeLevel.IMPOSSIBLE:
        powerLevel += 20.00;
        break;
      default:
    };
    if powerLevel < maxLevel / 4.00 {
      size = 5;
      symbolsToUse = TweakDBInterface.GetMiniGame_AllSymbolsRecord(t"minigame_v2.DefaultMinigameSymbols");
    } else {
      if powerLevel < maxLevel * 0.60 {
        size = 6;
        symbolsToUse = TweakDBInterface.GetMiniGame_AllSymbolsRecord(t"minigame_v2.DefaultMinigameSymbols2");
      } else {
        size = 7;
        symbolsToUse = TweakDBInterface.GetMiniGame_AllSymbolsRecord(t"minigame_v2.DefaultMinigameSymbols3");
      };
    };
  }

  public final func ScaleTraps(entity: ref<Entity>, player: ref<PlayerPuppet>, out prob: Float, powerLevel: Float) -> Void {
    let difficulty: EGameplayChallengeLevel = (entity as Device).GetDevicePS().GetBackdoorAccessPoint().GetSkillCheckContainer().GetHackingSlot().GetDifficulty();
    powerLevel -= GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.PowerLevel);
    switch difficulty {
      case EGameplayChallengeLevel.NONE:
        powerLevel -= 10.00;
        break;
      case EGameplayChallengeLevel.EASY:
        powerLevel -= 0.00;
        break;
      case EGameplayChallengeLevel.HARD:
        powerLevel += 10.00;
        break;
      case EGameplayChallengeLevel.IMPOSSIBLE:
        powerLevel += 20.00;
        break;
      default:
    };
    if powerLevel != 0.00 {
      prob *= 1.00 + powerLevel / 100.00;
    };
  }

  public final func ScaleTimer(player: ref<PlayerPuppet>, entity: ref<Entity>, out time: Float, powerLevel: Float, out waitInteraction: Bool) -> Void {
    let statValue: Float;
    let tempMultiplier: Float;
    let timerNotRemoteMultiplier: Float = 1.50;
    let difficulty: EGameplayChallengeLevel = (entity as Device).GetDevicePS().GetBackdoorAccessPoint().GetSkillCheckContainer().GetHackingSlot().GetDifficulty();
    switch difficulty {
      case EGameplayChallengeLevel.NONE:
        powerLevel -= 20.00;
        break;
      case EGameplayChallengeLevel.EASY:
        powerLevel -= 0.00;
        break;
      case EGameplayChallengeLevel.HARD:
        powerLevel += 10.00;
        break;
      case EGameplayChallengeLevel.IMPOSSIBLE:
        powerLevel += 20.00;
        break;
      default:
    };
    statValue = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.MinigameTimeLimitExtension);
    if statValue != 0.00 {
      time *= statValue;
    };
    if !this.m_isRemoteBreach && this.m_isOfficerBreach {
      time *= timerNotRemoteMultiplier;
    };
    if this.m_numberAttempts > 1 {
      tempMultiplier = 1.00 / (Cast(this.m_numberAttempts - 1) * 1.33);
      if tempMultiplier < 0.20 {
        tempMultiplier = 0.20;
      };
      time *= tempMultiplier;
    };
  }

  public final func FilterTraps(out trapList: array<ref<MiniGame_Trap_Record>>) -> Void {
    let i: Int32 = ArraySize(trapList) - 1;
    while i >= 0 {
      if this.m_isOfficerBreach && Equals(trapList[i].TrapType().EnumName(), n"Device") {
        ArrayRemove(trapList, trapList[i]);
      } else {
        if !this.m_isOfficerBreach && Equals(trapList[i].TrapType().EnumName(), n"NPC") {
          ArrayRemove(trapList, trapList[i]);
        };
      };
      i -= 1;
    };
  }

  public final func ScaleBuffer(entity: ref<Entity>, out size: Float, powerLevel: Float, player: ref<PlayerPuppet>) -> Void {
    let statValue: Float;
    let statValue2: Float;
    let difficulty: EGameplayChallengeLevel = (entity as Device).GetDevicePS().GetBackdoorAccessPoint().GetSkillCheckContainer().GetHackingSlot().GetDifficulty();
    let baseStatValue: Float = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.BufferSize);
    size = baseStatValue;
    statValue += Cast(player.GetBufferModifier());
    statValue2 = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.MinigameBufferExtension);
    player.SetBufferModifier(0);
    size += statValue;
    size += statValue2;
    switch difficulty {
      case EGameplayChallengeLevel.NONE:
        size += 0.00;
        break;
      case EGameplayChallengeLevel.EASY:
        size += 0.00;
        break;
      case EGameplayChallengeLevel.HARD:
        size -= 1.00;
        break;
      case EGameplayChallengeLevel.IMPOSSIBLE:
        size -= 2.00;
        break;
      default:
    };
    if size < 4.00 {
      size = 4.00;
    };
  }
}

public native class MinigameGenerationRule extends IScriptable {

  public native let minigameController: wref<HackingMinigameGameController>;

  public let m_blackboardSystem: ref<BlackboardSystem>;

  public let m_entity: wref<Entity>;

  public let m_player: wref<PlayerPuppet>;

  public let m_minigameRecord: wref<Minigame_Def_Record>;

  public let m_bufferSize: Int32;

  public let m_isItemBreach: Bool;

  protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    return true;
  }

  public final func SetBlackboard(b: ref<BlackboardSystem>) -> Void {
    this.m_blackboardSystem = b;
  }

  public final func SetEntity(entity: ref<Entity>) -> Void {
    this.m_entity = entity;
  }

  public final func SetPlayer(player: ref<PlayerPuppet>) -> Void {
    this.m_player = player;
  }

  public final func SetRecord(rec: ref<Minigame_Def_Record>) -> Void {
    this.m_minigameRecord = rec;
  }

  public final func SetBufferSize(buffer: Int32) -> Void {
    this.m_bufferSize = buffer;
  }

  public final func SetIsItemBreach(itemBreach: Bool) -> Void {
    this.m_isItemBreach = itemBreach;
  }

  public final func IntToTrap(i: Int32) -> ref<MiniGame_Trap_Record> {
    switch i {
      case 0:
        return TweakDBInterface.GetMiniGame_TrapRecord(t"MinigameTraps.NONE");
      case 1:
        return TweakDBInterface.GetMiniGame_TrapRecord(t"MinigameTraps.VisionReset");
      case 2:
        return TweakDBInterface.GetMiniGame_TrapRecord(t"MinigameTraps.BrokenVision");
      case 3:
        return TweakDBInterface.GetMiniGame_TrapRecord(t"MinigameTraps.MaterialsBonus");
      default:
        return TweakDBInterface.GetMiniGame_TrapRecord(t"MinigameTraps.NONE");
    };
  }
}

public class MinigameGenerationRuleOverridePrograms extends MinigameGenerationRule {

  protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    let finalChain: array<Uint32>;
    let i: Int32;
    let j: Int32;
    let minigameRecord: ref<MinigameAction_Record>;
    let obj: ref<ObjectAction_Record>;
    let overrideProgramList: array<wref<Program_Record>>;
    let program: UnlockableProgram;
    let programChain: array<Int32>;
    let programRecord: ref<Program_Record>;
    let rand: Float;
    this.m_minigameRecord.OverrideProgramsList(overrideProgramList);
    i = 0;
    while i < ArraySize(overrideProgramList) {
      programRecord = overrideProgramList[i];
      obj = programRecord.Program();
      program.programTweakID = obj.GetID();
      minigameRecord = TweakDBInterface.GetMinigameActionRecord(program.programTweakID);
      program.name = StringToName(LocKeyToString(minigameRecord.ObjectActionUI().Caption()));
      program.note = minigameRecord.ObjectActionUI().Description();
      program.iconTweakID = minigameRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID();
      if !this.m_isItemBreach && i == 0 && GameInstance.GetStatsSystem(this.m_player.GetGame()).GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.AutomaticUploadPerk) >= 1.00 {
        program.isFulfilled = true;
      } else {
        program.isFulfilled = false;
      };
      programChain = programRecord.CharactersChain();
      j = 0;
      while j < ArraySize(programChain) {
        if programChain[j] == -1 {
          rand = RandRangeF(0.00, 1.00);
          ArrayPush(finalChain, Cast(this.minigameController.GetRarity(rand)));
        } else {
          ArrayPush(finalChain, Cast(programChain[j]));
        };
        j += 1;
      };
      this.minigameController.AddUnlockableProgram(program, finalChain);
      ArrayClear(finalChain);
      i += 1;
    };
    return true;
  }

  public final func ConvertToUint(arr: array<Int32>) -> array<Uint32> {
    let arr2: array<Uint32>;
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      ArrayPush(arr2, Cast(arr[i]));
      i += 1;
    };
    return arr2;
  }
}

public class MinigameGenerationRuleScalingPrograms extends MinigameGenerationRule {

  public let m_bbNetwork: wref<IBlackboard>;

  public let m_isOfficerBreach: Bool;

  public let m_isRemoteBreach: Bool;

  public let m_isFirstAttempt: Bool;

  protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    let atStart: Bool;
    let combinedPowerLevel: Float;
    let extraDifficulty: Float;
    let i: Int32;
    let length: Int32;
    let miniGameActionRecord: wref<MinigameAction_Record>;
    let miniGameRecord: wref<Minigame_Def_Record>;
    let overlapInstance: Overlap;
    let overlapProbability: Float;
    let overlappingPrograms: array<Overlap>;
    let powerLevel: Float;
    let program: UnlockableProgram;
    let programComplexity: Float;
    let rand: Float;
    let tempPrograms: array<TweakDBID>;
    let x: Int32;
    this.m_bbNetwork = this.m_blackboardSystem.Get(GetAllBlackboardDefs().NetworkBlackboard);
    this.m_isOfficerBreach = this.m_bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.OfficerBreach);
    this.m_isRemoteBreach = this.m_bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.RemoteBreach);
    this.m_isFirstAttempt = this.m_bbNetwork.GetInt(GetAllBlackboardDefs().NetworkBlackboard.Attempt) == 1;
    let isItemBreach: Bool = this.m_bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.ItemBreach);
    let playerPrograms: array<MinigameProgramData> = this.minigameController.GetPlayerPrograms();
    this.FilterPlayerPrograms(playerPrograms);
    miniGameRecord = TweakDBInterface.GetMinigame_DefRecord(t"minigame_v2.DefaultMinigame");
    powerLevel = GameInstance.GetStatsSystem((this.m_entity as GameObject).GetGame()).GetStatValue(Cast(this.m_entity.GetEntityID()), gamedataStatType.PowerLevel);
    extraDifficulty = miniGameRecord.ExtraDifficulty();
    overlapProbability = miniGameRecord.OverlapProbability();
    this.RandomMode(atStart);
    if ArraySize(playerPrograms) > 0 {
      i = 0;
      while i < ArraySize(playerPrograms) + 1 {
        rand = RandRangeF(0.00, 1.00);
        if rand < overlapProbability {
          overlapInstance.instructionNumber = i;
          x = RandDifferent(i, ArraySize(playerPrograms) + 1);
          rand = RandRangeF(0.00, 1.00);
          overlapInstance.otherInstruction = x;
          overlapInstance.atStart = atStart;
          overlapInstance.rarity = this.minigameController.GetRarity(rand);
          ArrayPush(overlappingPrograms, overlapInstance);
          this.RandomMode(atStart);
        };
        i += 1;
      };
    };
    ArrayClear(tempPrograms);
    i = 0;
    while i < ArraySize(playerPrograms) {
      miniGameActionRecord = TweakDBInterface.GetMinigameActionRecord(playerPrograms[i].actionID);
      programComplexity = miniGameActionRecord.Complexity();
      combinedPowerLevel = programComplexity + powerLevel + extraDifficulty;
      length = this.DefineLength(combinedPowerLevel, this.m_bufferSize, ArraySize(playerPrograms));
      program.name = StringToName(LocKeyToString(miniGameActionRecord.ObjectActionUI().Caption()));
      program.note = miniGameActionRecord.ObjectActionUI().Description();
      program.programTweakID = playerPrograms[i].actionID;
      program.iconTweakID = miniGameActionRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID();
      if !isItemBreach && i == 0 && GameInstance.GetStatsSystem(this.m_player.GetGame()).GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.AutomaticUploadPerk) >= 1.00 {
        program.isFulfilled = true;
      } else {
        program.isFulfilled = false;
      };
      if !ArrayContains(tempPrograms, program.programTweakID) {
        ArrayPush(tempPrograms, program.programTweakID);
        this.minigameController.AddUnlockableProgram(program, this.GenerateRarities(length, overlappingPrograms, i + 1));
      };
      i += 1;
    };
    return true;
  }

  public final func FilterPlayerPrograms(out programs: array<MinigameProgramData>) -> Void {
    let data: ConnectedClassTypes;
    let i: Int32;
    let miniGameActionRecord: wref<MinigameAction_Record>;
    if (this.m_entity as GameObject).IsPuppet() {
      data = (this.m_entity as ScriptedPuppet).GetMasterConnectedClassTypes();
    } else {
      data = (this.m_entity as Device).GetDevicePS().CheckMasterConnectedClassTypes();
    };
    i = ArraySize(programs) - 1;
    while i >= 0 {
      miniGameActionRecord = TweakDBInterface.GetMinigameActionRecord(programs[i].actionID);
      if !IsNameValid(programs[i].programName) || Equals(programs[i].programName, n"") {
        ArrayErase(programs, i);
      } else {
        if !this.m_isRemoteBreach && NotEquals(miniGameActionRecord.Type().EnumName(), n"AccessPoint") {
          ArrayErase(programs, i);
        } else {
          if this.m_isRemoteBreach && Equals(miniGameActionRecord.Type().EnumName(), n"AccessPoint") {
            ArrayErase(programs, i);
          } else {
            if Equals(miniGameActionRecord.Category().EnumName(), n"Camera Access") && !data.surveillanceCamera {
              ArrayErase(programs, i);
            } else {
              if Equals(miniGameActionRecord.Category().EnumName(), n"Turret Access") && !data.securityTurret {
                ArrayErase(programs, i);
              } else {
                if Equals(miniGameActionRecord.Type().EnumName(), n"NPC") && !data.puppet {
                  ArrayErase(programs, i);
                };
              };
            };
          };
        };
      };
      i -= 1;
    };
  }

  public final func GenerateRarities(length: Int32, overlap: array<Overlap>, id: Int32) -> array<Uint32> {
    let rand: Float;
    let rarities: array<Uint32>;
    let i: Int32 = 0;
    while i < length {
      rand = RandRangeF(0.00, 1.00);
      ArrayPush(rarities, Cast(this.minigameController.GetRarity(rand)));
      i += 1;
    };
    i = 0;
    while i < ArraySize(overlap) {
      if overlap[i].instructionNumber == id {
        if overlap[i].atStart {
          rarities[0] = Cast(overlap[i].rarity);
        } else {
          rarities[ArraySize(rarities) - 1] = Cast(overlap[i].rarity);
        };
      };
      if overlap[i].otherInstruction == id {
        if overlap[i].atStart {
          rarities[ArraySize(rarities) - 1] = Cast(overlap[i].rarity);
        } else {
          rarities[0] = Cast(overlap[i].rarity);
        };
      };
      i += 1;
    };
    return rarities;
  }

  public final func DefineLength(combinedPowerLevel: Float, bufferSize: Int32, numPrograms: Int32) -> Int32 {
    let length: Int32;
    let modifier: Float;
    let normalizedLevel: Float;
    let perkModifierLevel: Float;
    let rand: Float;
    let residual: Float;
    let min: Float = 1.00;
    let max: Float = 120.00;
    if numPrograms > 0 {
      combinedPowerLevel = combinedPowerLevel - (3.00 * combinedPowerLevel * Cast(numPrograms)) / max;
    };
    normalizedLevel = 2.00 + ((combinedPowerLevel - min) * (5.00 - 2.00)) / (max - min);
    length = Cast(normalizedLevel);
    residual = normalizedLevel - Cast(length);
    rand = RandRangeF(0.00, 1.00);
    if rand < residual {
      length += 1;
    };
    perkModifierLevel = GameInstance.GetStatsSystem(this.m_player.GetGame()).GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.ShorterChains);
    modifier = perkModifierLevel;
    if modifier > 0.00 && length > 2 {
      length -= 1;
    };
    if length < 2 {
      length = 2;
    };
    if length > 5 {
      length = 5;
    };
    if length > bufferSize {
      return bufferSize;
    };
    return length;
  }

  public final func SwapMode(out b: Bool) -> Void {
    if b {
      b = false;
    } else {
      b = true;
    };
  }

  public final func RandomMode(out b: Bool) -> Void {
    let rand: Float = RandRangeF(0.00, 1.00);
    if rand >= 0.50 {
      b = true;
    } else {
      b = false;
    };
  }
}

public class MinigameGenerationRulePredefinedBoardWithTraps extends MinigameGenerationRule {

  protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    let i: Int32;
    let j: Int32;
    let recordGrid: array<wref<RowSymbols_Record>>;
    let recordRow: ref<RowSymbols_Record>;
    let recordTrapsGrid: array<wref<RowTraps_Record>>;
    let recordTrapsRow: ref<RowTraps_Record>;
    let row: array<Int32>;
    let rowTraps: array<Int32>;
    let tempArray: array<GridCell>;
    let tempCell: GridCell;
    this.m_minigameRecord.GridSymbols(recordGrid);
    this.m_minigameRecord.GridTraps(recordTrapsGrid);
    i = 0;
    while i < Cast(size) {
      j = 0;
      while j < Cast(size) {
        recordRow = recordGrid[i];
        row = recordRow.Symbols();
        tempCell.rarityValue = row[j];
        recordTrapsRow = recordTrapsGrid[i];
        rowTraps = recordTrapsRow.Traps();
        tempCell.currentTrap = this.IntToTrap(rowTraps[j]);
        ArrayPush(tempArray, tempCell);
        j += 1;
      };
      ArrayPush(grid, tempArray);
      ArrayClear(tempArray);
      i += 1;
    };
    return true;
  }
}

public class MinigameGenerationRulePredefinedBoard extends MinigameGenerationRule {

  protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    let i: Int32;
    let j: Int32;
    let recordGrid: array<wref<RowSymbols_Record>>;
    let recordRow: ref<RowSymbols_Record>;
    let row: array<Int32>;
    let tempArray: array<GridCell>;
    let tempCell: GridCell;
    let trapRecord: wref<MiniGame_Trap_Record> = TweakDBInterface.GetMiniGame_TrapRecord(t"MinigameTraps.NONE");
    this.m_minigameRecord.GridSymbols(recordGrid);
    i = 0;
    while i < Cast(size) {
      j = 0;
      while j < Cast(size) {
        recordRow = recordGrid[i];
        row = recordRow.Symbols();
        tempCell.rarityValue = row[j];
        tempCell.currentTrap = trapRecord;
        ArrayPush(tempArray, tempCell);
        j += 1;
      };
      ArrayPush(grid, tempArray);
      ArrayClear(tempArray);
      i += 1;
    };
    return true;
  }
}
