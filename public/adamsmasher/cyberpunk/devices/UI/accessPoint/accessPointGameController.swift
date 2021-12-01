
public class NetworkInkGameController extends inkGameController {

  @default(NetworkInkGameController, Initial)
  private let m_turn: String;

  @default(NetworkInkGameController, 5)
  private let m_dimension: Int32;

  @default(NetworkInkGameController, 6)
  private let m_steps: Int32;

  private let m_symbols: array<String>;

  private let m_symbolProbabilities: array<Int32>;

  @default(NetworkInkGameController, false)
  private let m_endGame: Bool;

  @default(NetworkInkGameController, true)
  private let m_initRound: Bool;

  private let m_oldPickX: Int32;

  private let m_oldPickY: Int32;

  private let m_pickX: Int32;

  private let m_pickY: Int32;

  private let m_regenGrid: Bool;

  public let m_trapsDelayed: array<String>;

  private let m_networkData: NetworkMinigameData;

  public let m_visualController: wref<NetworkMinigameVisualController>;

  private let m_miniGameRecord: wref<HackingMiniGame_Record>;

  private let m_officerBreach: Bool;

  private let m_bufferElements: array<ElementData>;

  private let m_enemyBufferElements: array<ElementData>;

  private let m_completedPrograms: array<String>;

  private let m_completedProgramsPD: array<ProgramData>;

  private let m_enemyCompletedPrograms: array<String>;

  private let m_enemyCompletedProgramsPD: array<ProgramData>;

  private let m_playerProgramsCompletion: array<ProgramProgressData>;

  private let m_enemyProgramsCompletion: array<ProgramProgressData>;

  private let m_basicAccessCompletion: ProgramProgressData;

  private let m_appliedViruses: array<ExtraEffect>;

  private let m_onBreachingNetworkListener: ref<CallbackHandle>;

  private let m_onDevicesCountChangedListener: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_visualController = this.GetRootWidget().GetController() as NetworkMinigameVisualController;
    this.RegisterBlackboardCallbacks();
    this.m_officerBreach = this.GetBlackboard().GetBool(this.GetBlackboardDef().OfficerBreach);
    this.StartBreaching(this.GetBlackboard().GetString(this.GetBlackboardDef().NetworkName));
    this.GetPlayerControlledObject().RegisterInputListener(this, n"UI_Cancel");
  }

  protected cb func OnUninitialize() -> Bool {
    this.GetPlayerControlledObject().UnregisterInputListener(this);
  }

  private final func GetBlackboard() -> ref<IBlackboard> {
    return this.GetBlackboardSystem().Get(this.GetBlackboardDef());
  }

  private final func RegisterBlackboardCallbacks() -> Void {
    this.m_onBreachingNetworkListener = this.GetBlackboard().RegisterListenerString(this.GetBlackboardDef().NetworkName, this, n"OnBreachingNetwork");
    this.m_onDevicesCountChangedListener = this.GetBlackboard().RegisterListenerInt(this.GetBlackboardDef().DevicesCount, this, n"OnDevicesCountChanged");
  }

  private final func UnregisterBlackboardCallbacks() -> Void {
    this.GetBlackboard().UnregisterListenerString(this.GetBlackboardDef().NetworkName, this.m_onBreachingNetworkListener);
    this.GetBlackboard().UnregisterListenerInt(this.GetBlackboardDef().DevicesCount, this.m_onDevicesCountChangedListener);
  }

  private final func SetPlayerBlackboardInformation(value: Bool) -> Void {
    let ownerEntity: ref<Entity> = this.GetPlayerControlledObject();
    let playerStateMachineBlackboard: ref<IBlackboard> = this.GetBlackboardSystem().GetLocalInstanced(ownerEntity.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInMinigame, value);
  }

  private final func GetBlackboardDef() -> ref<NetworkBlackboardDef> {
    return GetAllBlackboardDefs().NetworkBlackboard;
  }

  private final func StartMinigame() -> Void {
    let playerPuppet: wref<GameObject>;
    this.SetActiveMiniGameRecord();
    playerPuppet = this.GetPlayerControlledObject() as PlayerPuppet;
    GameInstance.GetTimeSystem(playerPuppet.GetGame()).SetTimeDilation(n"minigame", 0.00);
    switch this.m_miniGameRecord.GameType() {
      case 1:
        break;
      case 2:
        this.PlayGame();
        break;
      case 3:
        break;
      default:
    };
  }

  private final func StartBreaching(networkName: String) -> Void {
    this.StartMinigame();
    LogUI("############ START BREACHING");
  }

  private final func SetActiveMiniGameRecord() -> Void {
    if this.m_officerBreach {
      this.m_miniGameRecord = TweakDBInterface.GetHackingMiniGameRecord(t"MiniGame.DefaultGame");
    } else {
      this.m_miniGameRecord = TweakDBInterface.GetHackingMiniGameRecord(t"MiniGame.DefaultGame");
    };
  }

  protected cb func OnDevicesCountChanged(value: Int32) -> Bool;

  protected cb func OnStopBreaching(target: wref<inkWidget>) -> Bool {
    this.StartMinigame();
  }

  private final func PlayGame() -> Void {
    let basicAccess: ProgramData;
    let enemyProgramList: array<ProgramData>;
    let grid: array<CellData>;
    let gridArr: array<String>;
    let i: Int32;
    let pEffect: ProgramEffect;
    let pType: ProgramType;
    let programArr: array<String>;
    let programList: array<ProgramData>;
    let rand: Int32;
    this.m_dimension = this.m_miniGameRecord.Dimension();
    this.ReserveSymbols(this.m_symbols);
    this.SetSymbolProbabilities(this.m_symbolProbabilities, this.m_miniGameRecord.SymbolProbabilities());
    pType = ProgramType.BasicAccess;
    pEffect = ProgramEffect.GrantAccess;
    if !this.GetPredefinedBasicAccess(basicAccess, pType, pEffect) {
      basicAccess = this.MakeProgram("Basic Access", 2, this.m_symbols, this.m_symbolProbabilities, pType, pEffect);
    };
    pType = ProgramType.ExtraPlayerProgram;
    pEffect = ProgramEffect.UnlockQuestFact;
    if !this.GetPredefinedProgram(programList, pType, pEffect, true) {
      ArrayPush(programList, this.MakeProgram("Camera Malfunction", 3, this.m_symbols, this.m_symbolProbabilities, pType, pEffect));
      ArrayPush(programList, this.MakeProgram("Officer tracing", 3, this.m_symbols, this.m_symbolProbabilities, pType, pEffect));
    };
    pType = ProgramType.ExtraServerProgram;
    pEffect = ProgramEffect.UnlockQuestFact;
    if !this.GetPredefinedProgram(programList, pType, pEffect, false) {
      ArrayPush(programList, this.MakeProgram("Network Cache", 2, this.m_symbols, this.m_symbolProbabilities, pType, pEffect));
      ArrayPush(programList, this.MakeProgram("Encrypted Data Package", 4, this.m_symbols, this.m_symbolProbabilities, pType, pEffect));
    };
    if this.m_miniGameRecord.HasEnemyNetrunner() {
      pType = ProgramType.EnemyProgram;
      pEffect = ProgramEffect.BlockAccess;
      if !this.GetPredefinedProgram(enemyProgramList, pType, pEffect, false) {
        ArrayPush(enemyProgramList, this.MakeProgram("Shuffle Buffer", 2, this.m_symbols, this.m_symbolProbabilities, pType, pEffect));
        ArrayPush(enemyProgramList, this.MakeProgram("Increment Complexity", 4, this.m_symbols, this.m_symbolProbabilities, pType, pEffect));
        ArrayPush(enemyProgramList, this.MakeProgram("Network Lock", 4, this.m_symbols, this.m_symbolProbabilities, pType, pEffect));
      };
    };
    this.SetPlayerBlackboardInformation(true);
    this.m_visualController.RegisterToCallback(n"OnCellSelected", this, n"OnPressCell");
    this.m_visualController.RegisterToCallback(n"OnEndClosed", this, n"OnCloseGame");
    if !this.GetPredefinedGrid(grid) {
      this.GenerateGrid(grid);
    };
    gridArr = this.m_miniGameRecord.PredefinedGrid();
    if ArraySize(gridArr) == 0 {
      rand = RandRange(0, ArraySize(programList));
      i = 0;
      while i < ArraySize(programList) {
        this.InsertProgram(grid, programList[i], i == rand);
        i += 1;
      };
    };
    this.GenerateTraps(grid);
    gridArr = this.m_miniGameRecord.PredefinedGrid();
    programArr = this.m_miniGameRecord.PredefinedBasicAccess();
    if ArraySize(gridArr) == 0 || ArraySize(programArr) == 0 {
      this.InsertProgram(grid, basicAccess, false);
    };
    grid[0].element.id = "--";
    this.m_oldPickX = 0;
    this.m_oldPickY = 0;
    this.m_networkData.gridData = grid;
    this.m_networkData.basicAccess = basicAccess;
    this.m_networkData.playerPrograms = programList;
    this.m_networkData.playerBufferSize = this.m_steps;
    this.m_visualController.SetUp(this.m_networkData);
    this.ExecuteTurn();
  }

  private final func ExecuteTurn() -> Void {
    let end: Bool;
    let endScreen: EndScreenData;
    if !this.m_endGame && this.m_steps > 0 {
      if this.m_initRound {
        this.m_initRound = false;
      };
      this.m_steps -= 1;
    } else {
      end = true;
    };
    if end {
      endScreen.unlockedPrograms = this.m_completedProgramsPD;
      if ArrayContains(this.m_completedPrograms, "Basic Access") {
        endScreen.outcome = OutcomeMessage.Success;
      } else {
        endScreen.outcome = OutcomeMessage.Failure;
      };
      this.m_visualController.ShowEndScreen(endScreen);
    };
  }

  public final func NewTurn(placementX: Int32, placementY: Int32, opt grid: array<CellData>) -> Void {
    let hMode: HighlightMode;
    let newTurn: NewTurnMinigameData;
    let tempEnemyPrograms: array<ProgramData>;
    let tempPrograms: array<ProgramData>;
    if Equals(this.m_turn, "Initial") {
      if this.m_oldPickY == placementY {
        this.m_turn = "Column";
      } else {
        this.m_turn = "Row";
      };
    };
    if Equals(this.m_turn, "Column") {
      hMode = HighlightMode.Row;
    } else {
      hMode = HighlightMode.Column;
    };
    newTurn.position = new Vector2(Cast(placementX), Cast(placementY));
    newTurn.doConsume = true;
    newTurn.nextHighlightMode = hMode;
    if this.m_regenGrid {
      newTurn.doRegenerateGrid = true;
      newTurn.regeneratedGridData = grid;
    };
    newTurn.newPlayerBufferContent = this.m_bufferElements;
    newTurn.newEnemyBufferContent = this.m_enemyBufferElements;
    tempPrograms = this.m_networkData.playerPrograms;
    ArrayPush(tempPrograms, this.m_networkData.basicAccess);
    this.KeepTrackPrograms(tempPrograms, false);
    if this.m_miniGameRecord.HasEnemyNetrunner() {
      tempEnemyPrograms = this.m_networkData.enemyPrograms;
      this.KeepTrackPrograms(tempEnemyPrograms, true);
    };
    newTurn.basicAccessCompletionState = this.m_basicAccessCompletion;
    newTurn.playerProgramsCompletionState = this.m_playerProgramsCompletion;
    newTurn.enemyProgramsCompletionState = this.m_enemyProgramsCompletion;
    this.m_visualController.SetGridElementPicked(newTurn);
    if Equals(this.m_turn, "Column") {
      this.m_turn = "Row";
    } else {
      this.m_turn = "Column";
    };
    this.ExecuteTurn();
  }

  private final func CloseGame() -> Void {
    let deviceID: EntityID;
    let evt: ref<AccessPointMiniGameStatus>;
    let playerPuppet: wref<GameObject> = this.GetPlayerControlledObject() as PlayerPuppet;
    GameInstance.GetTimeSystem(playerPuppet.GetGame()).UnsetTimeDilation(n"minigame");
    if ArrayContains(this.m_completedPrograms, "Encrypted Data (?)") {
      RPGManager.GiveReward(playerPuppet.GetGame(), t"RPGActionRewards.ProgramPartsAccessPoint");
    };
    this.SetPlayerBlackboardInformation(false);
    deviceID = this.GetBlackboard().GetEntityID(this.GetBlackboardDef().DeviceID);
    if EntityID.IsDefined(deviceID) {
      evt = new AccessPointMiniGameStatus();
      evt.minigameState = HackingMinigameState.Succeeded;
      this.GetPlayerControlledObject().QueueEventForEntityID(deviceID, evt);
    };
  }

  private final func GenerateGrid(out grid: array<CellData>) -> Void {
    let cell: CellData;
    let i: Int32;
    let j: Int32;
    ArrayClear(grid);
    i = 0;
    while i < this.m_dimension {
      j = 0;
      while j < this.m_dimension {
        cell.position = new Vector2(Cast(i), Cast(j));
        cell.element.id = this.GenerateHexNumber2();
        ArrayPush(grid, cell);
        j += 1;
      };
      i += 1;
    };
  }

  private final func RegenerateGrid(out grid: array<CellData>, symbols: array<String>, symbolProbabilities: array<Int32>) -> Void {
    ArrayClear(grid);
    this.GenerateGrid(grid);
    this.GenerateTraps(grid);
  }

  private final func SetSymbolProbabilities(out prob: array<Int32>, arr: array<String>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      ArrayPush(prob, StringToInt(arr[i]));
      i += 1;
    };
  }

  public final func ReserveSymbols(out symbols: array<String>) -> Void {
    let arr: array<String> = this.m_miniGameRecord.Symbols();
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      ArrayPush(symbols, arr[i]);
      i += 1;
    };
  }

  private final func GetPredefinedGrid(out listCells: array<CellData>) -> Bool {
    let cell: CellData;
    let i: Int32;
    let j: Int32;
    let preGrid: array<String> = this.m_miniGameRecord.PredefinedGrid();
    if ArraySize(preGrid) == 0 {
      return false;
    };
    ArrayClear(listCells);
    i = 0;
    while i < this.m_dimension {
      j = 0;
      while j < this.m_dimension {
        cell.position = new Vector2(Cast(i), Cast(j));
        if Equals(preGrid[this.GridPositionToList(i, j, this.m_dimension)], "??") {
          cell.element.id = this.m_symbols[this.ChooseRandomOption(this.m_symbolProbabilities)];
        } else {
          cell.element.id = preGrid[this.GridPositionToList(i, j, this.m_dimension)];
        };
        ArrayPush(listCells, cell);
        j += 1;
      };
      i += 1;
    };
    return true;
  }

  private final func GetPredefinedBasicAccess(out program: ProgramData, programType: ProgramType, programEffect: ProgramEffect) -> Bool {
    let command: array<ElementData>;
    let element: ElementData;
    let i: Int32;
    let arr: array<String> = this.m_miniGameRecord.PredefinedBasicAccess();
    if ArraySize(arr) == 0 {
      return false;
    };
    program.id = "Basic Access";
    i = 0;
    while i < ArraySize(arr) {
      if Equals(arr[i], "??") {
        element.id = this.m_symbols[this.ChooseRandomOption(this.m_symbolProbabilities)];
      } else {
        element.id = arr[i];
      };
      ArrayPush(command, element);
      i += 1;
    };
    ArrayPush(program.commandLists, command);
    program.type = programType;
    ArrayPush(program.effects, programEffect);
    program.startAsUnknown = false;
    return true;
  }

  private final func GetPredefinedProgram(out programList: array<ProgramData>, programType: ProgramType, programEffect: ProgramEffect, cyberdeck: Bool) -> Bool {
    let arr: array<String>;
    let command: array<ElementData>;
    let element: ElementData;
    let i: Int32;
    let program: ProgramData;
    if Equals(programType, ProgramType.EnemyProgram) {
      arr = this.m_miniGameRecord.PredefinedEnemyPrograms();
    } else {
      if cyberdeck {
        arr = this.m_miniGameRecord.PredefinedCyberdeckPrograms();
      } else {
        arr = this.m_miniGameRecord.PredefinedNetworkPrograms();
      };
    };
    if ArraySize(arr) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(arr) {
      if !ArrayContains(this.m_symbols, arr[i]) && NotEquals(arr[i], "??") {
        if NotEquals(program.id, "") {
          ArrayPush(program.commandLists, command);
          program.type = programType;
          ArrayPush(program.effects, programEffect);
          program.startAsUnknown = false;
          ArrayPush(programList, program);
          ArrayClear(command);
          ArrayClear(program.commandLists);
        };
        program.id = arr[i];
      } else {
        if Equals(arr[i], "??") {
          element.id = this.m_symbols[this.ChooseRandomOption(this.m_symbolProbabilities)];
        } else {
          element.id = arr[i];
        };
        ArrayPush(command, element);
      };
      i += 1;
    };
    ArrayPush(program.commandLists, command);
    program.type = programType;
    ArrayPush(program.effects, programEffect);
    program.startAsUnknown = false;
    ArrayPush(programList, program);
    return true;
  }

  public final func MakeProgram(programName: String, num: Int32, symbols: array<String>, probabilities: array<Int32>, programType: ProgramType, programEffect: ProgramEffect) -> ProgramData {
    let command: array<ElementData>;
    let element: ElementData;
    let instruction: String;
    let program: ProgramData;
    program.id = programName;
    let i: Int32 = 0;
    while i < num {
      instruction = symbols[this.ChooseRandomOption(probabilities)];
      element.id = instruction;
      ArrayPush(command, element);
      i += 1;
    };
    ArrayPush(program.commandLists, command);
    program.type = programType;
    ArrayPush(program.effects, programEffect);
    program.startAsUnknown = false;
    return program;
  }

  private final func InsertProgram(out grid: array<CellData>, program: ProgramData, forceFirstRow: Bool) -> Void {
    let columnTurn: Bool;
    let i: Int32;
    let oldX: Int32;
    let oldY: Int32;
    let tempCell: CellData;
    let y: Int32;
    let initial: Bool = true;
    let x: Int32 = RandRange(0, 2);
    if x == 1 || forceFirstRow {
      columnTurn = true;
    } else {
      columnTurn = false;
    };
    i = 0;
    while i < ArraySize(program.commandLists[0]) {
      if initial {
        x = RandRange(0, this.m_dimension);
        y = RandRange(0, this.m_dimension);
        if forceFirstRow {
          x = 0;
        };
        while x == 0 && y == 0 {
          x = RandRange(0, this.m_dimension);
          y = RandRange(0, this.m_dimension);
          if forceFirstRow {
            x = 0;
          };
        };
        oldX = x;
        oldY = y;
        tempCell = this.GetCellFromPosition(grid, x, y);
        tempCell.element.id = program.commandLists[0][i].id;
        grid[this.GridPositionToList(x, y, this.m_dimension)] = tempCell;
        initial = false;
      } else {
        if columnTurn {
          while oldX == x {
            x = RandRange(0, this.m_dimension);
          };
          tempCell = this.GetCellFromPosition(grid, x, oldY);
          tempCell.element.id = program.commandLists[0][i].id;
          grid[this.GridPositionToList(x, oldY, this.m_dimension)] = tempCell;
          oldX = x;
          columnTurn = false;
        } else {
          while oldY == y {
            y = RandRange(0, this.m_dimension);
          };
          tempCell = this.GetCellFromPosition(grid, oldX, y);
          tempCell.element.id = program.commandLists[0][i].id;
          grid[this.GridPositionToList(oldX, y, this.m_dimension)] = tempCell;
          oldY = y;
          columnTurn = false;
        };
      };
      i += 1;
    };
  }

  private final func GenerateTraps(out grid: array<CellData>) -> Void {
    let j: Int32;
    let property: SpecialProperties;
    let traps: array<ETrap>;
    let i: Int32 = 0;
    while i < this.m_dimension {
      j = 0;
      while j < this.m_dimension {
        this.GetRandomTraps(traps);
        property.traps = traps;
        grid[this.GridPositionToList(i, j, this.m_dimension)].properties = property;
        j += 1;
      };
      i += 1;
    };
  }

  private final func GetRandomTraps(out traps: array<ETrap>) -> Bool {
    let i: Int32;
    let rand: Float;
    let trap: ETrap;
    let trapRecords: array<wref<Trap_Record>>;
    if !IsDefined(this.m_miniGameRecord) {
      return false;
    };
    this.m_miniGameRecord.AllowedTraps(trapRecords);
    i = 0;
    while i < ArraySize(trapRecords) {
      rand = RandRangeF(1.00, 100.00);
      if rand < trapRecords[i].Probability() {
        trap = IntEnum(Cast(EnumValueFromString("ETrap", trapRecords[i].Name())));
        if NotEquals(trap, ETrap.Invalid) {
          ArrayPush(traps, trap);
        };
      };
      i += 1;
    };
    return ArraySize(traps) > 0;
  }

  public final func ApplyRandomVirus() -> ExtraEffect {
    switch this.m_miniGameRecord.NetworkLevel() {
      case 0:
        return IntEnum(2l);
      case 1:
        return ExtraEffect.AccuracyVirus;
      case 2:
        return ExtraEffect.PeernoidVirus;
      default:
        return IntEnum(2l);
    };
  }

  private final func KeepTrackPrograms(programs: array<ProgramData>, enemy: Bool) -> Void {
    let basicAccessCompletion: ProgramProgressData;
    let enemyProgramsCompletion: array<ProgramProgressData>;
    let playerProgramsCompletion: array<ProgramProgressData>;
    let tempProgramCompletion: ProgramProgressData;
    let i: Int32 = 0;
    while i < ArraySize(programs) {
      if !programs[i].wasCompleted {
        programs[i].wasCompleted = this.CheckUploaded(programs[i]);
        if programs[i].wasCompleted {
          if !enemy {
            if !ArrayContains(this.m_completedPrograms, programs[i].id) {
              ArrayPush(this.m_completedPrograms, programs[i].id);
              ArrayPush(this.m_completedProgramsPD, programs[i]);
              this.m_visualController.SetProgramCompleted(programs[i].id, false);
            };
          } else {
            if !ArrayContains(this.m_enemyCompletedPrograms, programs[i].id) {
              ArrayPush(this.m_enemyCompletedPrograms, programs[i].id);
              ArrayPush(this.m_enemyCompletedProgramsPD, programs[i]);
              this.m_visualController.SetProgramCompleted(programs[i].id, false);
            };
          };
        };
        if programs[i].wasCompleted {
          if Equals(programs[i].type, ProgramType.BasicAccess) {
            basicAccessCompletion.isComplete = true;
          };
          tempProgramCompletion.isComplete = true;
        } else {
          tempProgramCompletion.isComplete = false;
        };
        tempProgramCompletion.id = programs[i].id;
        ArrayClear(tempProgramCompletion.completionProgress);
        if Equals(programs[i].type, ProgramType.BasicAccess) {
          ArrayPush(basicAccessCompletion.completionProgress, this.FeedbackProgramCompletion(programs[i].commandLists[0], this.m_bufferElements));
        } else {
          if enemy {
            ArrayPush(tempProgramCompletion.completionProgress, this.FeedbackProgramCompletion(programs[i].commandLists[0], this.m_bufferElements));
            ArrayPush(enemyProgramsCompletion, tempProgramCompletion);
          } else {
            ArrayPush(tempProgramCompletion.completionProgress, this.FeedbackProgramCompletion(programs[i].commandLists[0], this.m_bufferElements));
            ArrayPush(playerProgramsCompletion, tempProgramCompletion);
          };
        };
      };
      i += 1;
    };
    if enemy {
      this.m_enemyProgramsCompletion = enemyProgramsCompletion;
    } else {
      this.m_playerProgramsCompletion = playerProgramsCompletion;
      this.m_basicAccessCompletion = basicAccessCompletion;
    };
  }

  private final func FeedbackProgramCompletion(program: array<ElementData>, buffer: array<ElementData>) -> Int32 {
    let appendedBuffer: String;
    let appendedProgram: String;
    let num: Int32 = 0;
    let done: Bool = false;
    let i: Int32 = ArraySize(program);
    while i > 0 {
      appendedBuffer = this.ArrayCellsToString(buffer, i, true);
      appendedProgram = this.ArrayCellsToString(program, i, false);
      if Equals(appendedBuffer, appendedProgram) && !done {
        num = i;
        done = true;
      };
      i -= 1;
    };
    return num;
  }

  private final func CheckUploaded(program: ProgramData) -> Bool {
    let uploaded: Bool = false;
    let appendedBuffer: String = this.ArrayCellsToString(this.m_bufferElements);
    let appendedProgram: String = this.ArrayCellsToString(program.commandLists[0]);
    if StrContains(appendedBuffer, appendedProgram) {
      uploaded = true;
    };
    return uploaded;
  }

  protected cb func OnPressCell(e: wref<inkWidget>) -> Bool {
    let grid: array<CellData>;
    let cell: CellData = this.m_visualController.GetLastCellSelected();
    let placementX: Int32 = Cast(cell.position.X);
    let placementY: Int32 = Cast(cell.position.Y);
    if ArrayContains(cell.properties.traps, ETrap.AppendStart) {
      ArrayInsert(this.m_bufferElements, 0, cell.element);
    } else {
      ArrayPush(this.m_bufferElements, cell.element);
    };
    if cell.properties.enemyMarker {
      ArrayPush(this.m_enemyBufferElements, cell.element);
    };
    if ArrayContains(cell.properties.traps, ETrap.Virus) {
      ArrayPush(this.m_appliedViruses, this.ApplyRandomVirus());
    };
    if ArrayContains(cell.properties.traps, ETrap.GridRegen) {
      this.RegenerateGrid(grid, this.m_symbols, this.m_symbolProbabilities);
      this.m_regenGrid = true;
    } else {
      this.m_regenGrid = false;
    };
    this.m_oldPickX = this.m_pickX;
    this.m_oldPickY = this.m_pickY;
    this.m_pickX = placementX;
    this.m_pickY = placementY;
    this.NewTurn(placementX, placementY, grid);
  }

  protected cb func OnCloseGame(e: wref<inkWidget>) -> Bool {
    this.CloseGame();
  }

  private final func GenerateHexNumber2() -> String {
    let i: Int32 = this.ChooseRandomOption(this.m_symbolProbabilities);
    switch i {
      case 0:
        return "1C";
      case 1:
        return "55";
      case 2:
        return "BD";
      case 3:
        return "E9";
      default:
        return "--";
    };
  }

  public final func GridPositionToList(x: Int32, y: Int32, dimension: Int32) -> Int32 {
    return dimension * x + y;
  }

  public final func CheckDirection(placementX: Int32, placementY: Int32) -> String {
    if placementX == this.m_oldPickX && placementY > this.m_oldPickY {
      return "right";
    };
    if placementX == this.m_oldPickX && placementY < this.m_oldPickY {
      return "left";
    };
    if placementY == this.m_oldPickY && placementX > this.m_oldPickX {
      return "down";
    };
    if placementY == this.m_oldPickY && placementX < this.m_oldPickX {
      return "up";
    };
    return "";
  }

  public final func AppendListPrograms(arr1: array<ProgramData>, arr2: array<ProgramData>) -> array<ProgramData> {
    let i: Int32 = 0;
    while i < ArraySize(arr2) {
      ArrayPush(arr1, arr2[i]);
      i += 1;
    };
    return arr1;
  }

  private final func ChooseRandomOption(probabilities: array<Int32>) -> Int32 {
    let num: Int32;
    let sum: Int32 = 0;
    let i: Int32 = 0;
    while i < ArraySize(probabilities) {
      sum += probabilities[i];
      i += 1;
    };
    num = RandRange(0, sum + 1);
    i = 0;
    while i < ArraySize(probabilities) {
      if num <= probabilities[i] {
        return i;
      };
      num -= probabilities[i];
      i += 1;
    };
    return -1;
  }

  private final func ArrayCellsToString(arr: array<ElementData>) -> String {
    let str: String = "";
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      str = str + arr[i].id;
      i += 1;
    };
    return str;
  }

  private final func ArrayCellsToString(arr: array<ElementData>, num: Int32, fromNumber: Bool) -> String {
    let i: Int32;
    let str: String;
    str + "";
    if !fromNumber {
      i = 0;
      while i < num {
        str = str + arr[i].id;
        i += 1;
      };
    } else {
      i = ArraySize(arr) - num;
      while i <= ArraySize(arr) {
        if i >= 0 {
          str = str + arr[i].id;
        };
        i += 1;
      };
    };
    return str;
  }

  private final func ArrayCellsToString(arr: array<String>, num: Int32, fromNumber: Bool) -> String {
    let i: Int32;
    let str: String;
    str + "";
    if !fromNumber {
      i = 0;
      while i < num {
        str = str + arr[i];
        i += 1;
      };
    } else {
      i = ArraySize(arr) - num;
      while i <= ArraySize(arr) {
        if i >= 0 {
          str = str + arr[i];
        };
        i += 1;
      };
    };
    return str;
  }

  private final func GetCellFromPosition(arr: array<CellData>, x: Int32, y: Int32) -> CellData {
    let cell: CellData;
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      cell = arr[i];
      if Equals(cell.position, new Vector2(Cast(x), Cast(y))) {
        return cell;
      };
      i += 1;
    };
    return cell;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), n"UI_Cancel") && Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED) {
      this.CloseGame();
    };
  }

  protected cb func OnPressSkip(e: ref<inkPointerEvent>) -> Bool {
    this.CloseGame();
  }
}
