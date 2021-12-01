
public class NetworkMinigameVisualController extends inkLogicController {

  protected edit let m_gridContainer: inkCompoundRef;

  protected edit let m_middleVideoContainer: inkVideoRef;

  protected edit let m_sidesAnimContainer: inkWidgetRef;

  protected edit let m_sidesLibraryPath: ResRef;

  protected edit let m_introAnimationLibraryName: CName;

  protected edit let m_gridOutroAnimationLibraryName: CName;

  protected edit let m_endScreenIntroAnimationLibraryName: CName;

  protected edit let m_programsContainer: inkWidgetRef;

  protected edit let m_bufferContainer: inkWidgetRef;

  protected edit let m_endScreenContainer: inkWidgetRef;

  protected edit const let m_FluffToHideContainer: array<inkWidgetRef>;

  protected edit const let m_DottedLinesList: array<inkWidgetRef>;

  protected edit let m_basicAccessContainer: inkWidgetRef;

  protected edit let m_animationCallbackContainer: inkWidgetRef;

  protected edit let m_dotMask: inkWidgetRef;

  protected edit let m_linesToGridOffset: Float;

  protected edit let m_linesSeparationDistance: Float;

  protected let m_animationCallback: wref<NetworkMinigameAnimationCallbacksTransmitter>;

  protected let m_grid: wref<NetworkMinigameGridController>;

  private edit let m_gridController: inkWidgetRef;

  private edit let m_programListController: inkWidgetRef;

  private edit let m_bufferController: inkWidgetRef;

  private edit let m_endScreenController: inkWidgetRef;

  protected let m_programList: wref<NetworkMinigameProgramListController>;

  protected let m_buffer: wref<NetworkMinigameBufferController>;

  protected let m_endScreen: wref<NetworkMinigameEndScreenController>;

  protected let m_basicAccess: wref<NetworkMinigameBasicProgramController>;

  protected let m_sidesAnim: wref<inkWidget>;

  private let m_bufferFillCount: Int32;

  private let m_bufferAnimProxy: ref<inkAnimProxy>;

  private let m_fillProgress: ref<inkAnimDef>;

  protected cb func OnInitialize() -> Bool {
    this.m_sidesAnim = this.SpawnFromExternal(inkWidgetRef.Get(this.m_sidesAnimContainer), this.m_sidesLibraryPath, n"Root");
    this.m_grid = this.SpawnFromLocal(inkWidgetRef.Get(this.m_gridContainer), n"Grid").GetController() as NetworkMinigameGridController;
    this.m_programList = inkWidgetRef.Get(this.m_programListController).GetController() as NetworkMinigameProgramListController;
    this.m_buffer = inkWidgetRef.Get(this.m_bufferController).GetController() as NetworkMinigameBufferController;
    this.m_endScreen = inkWidgetRef.Get(this.m_endScreenController).GetController() as NetworkMinigameEndScreenController;
    this.m_animationCallback = inkWidgetRef.GetController(this.m_animationCallbackContainer) as NetworkMinigameAnimationCallbacksTransmitter;
    this.m_basicAccess = this.SpawnFromLocal(inkWidgetRef.Get(this.m_basicAccessContainer), n"BasicAccessProgram").GetController() as NetworkMinigameBasicProgramController;
    this.m_grid.RegisterToCallback(n"OnCellSelected", this, n"OnCellSelectCallback");
    this.m_animationCallback.RegisterToCallback(n"OnStartSidesAnimation", this, n"OnStartSidesAnimation");
    this.m_animationCallback.RegisterToCallback(n"OnStartMinigameBGIntroAnimation", this, n"OnStartMinigameBGIntroAnimation");
    this.m_animationCallback.RegisterToCallback(n"OnIntroAnimationFinished", this, n"OnIntroAnimationFinished");
    this.PlaySound(n"MiniGame", n"OnOpen");
  }

  protected cb func OnUninitialize() -> Bool {
    this.PlaySound(n"MiniGame", n"OnClose");
  }

  public final func SetUp(data: NetworkMinigameData) -> Void {
    let startingScale: Vector2;
    startingScale.X = 0.00;
    startingScale.Y = 1.00;
    inkWidgetRef.SetVisible(this.m_gridContainer, true);
    inkWidgetRef.SetVisible(this.m_programsContainer, true);
    inkWidgetRef.SetVisible(this.m_bufferContainer, true);
    inkWidgetRef.SetVisible(this.m_endScreenContainer, false);
    inkWidgetRef.SetVisible(this.m_basicAccessContainer, true);
    this.SetFluffVisibility(true);
    this.m_sidesAnim.SetVisible(false);
    this.m_grid.SetUp(data.gridData);
    this.m_buffer.Spawn(data.playerBufferSize);
    this.m_programList.Spawn(data.playerPrograms);
    this.m_basicAccess.Spawn(data.basicAccess);
    this.StartIntroAnimation();
    inkWidgetRef.SetScale(this.m_dotMask, startingScale);
    this.m_bufferFillCount = 0;
    this.InitializeFluffLines();
  }

  public final func SetGridElementPicked(newData: NewTurnMinigameData) -> Void {
    let basicData: ProgramData;
    let newScale: Vector2;
    let oldScale: Vector2;
    let scaleInterpolator: ref<inkAnimScale>;
    let selectedCell: CellData;
    if newData.doConsume {
      selectedCell = this.m_grid.FindCellData(newData.position);
      selectedCell.assignedCell.Consume();
    };
    if newData.doRegenerateGrid {
      this.m_grid.SetGridData(newData.regeneratedGridData);
    };
    this.m_grid.SetCurrentActivePosition(newData.position, Equals(newData.nextHighlightMode, HighlightMode.Row));
    this.m_buffer.SetEntries(newData.newPlayerBufferContent);
    this.m_programList.ProcessListModified(newData.playerProgramsChange, newData.playerProgramsAdded, newData.playerProgramsRemoved);
    basicData = this.m_basicAccess.GetData();
    if newData.basicAccessCompletionState.isComplete && !basicData.wasCompleted {
      this.m_basicAccess.ShowCompleted(newData.basicAccessCompletionState.revealLocalizedName);
      this.m_programList.PlaySideBarAnim();
    };
    this.m_programList.UpdatePartialCompletionState(newData.playerProgramsCompletionState);
    this.m_basicAccess.UpdatePartialCompletionState(newData.basicAccessCompletionState);
    this.m_bufferFillCount += 1;
    newScale.X = 0.18 * Cast(this.m_bufferFillCount);
    newScale.Y = 1.00;
    oldScale = inkWidgetRef.GetScale(this.m_dotMask);
    this.m_fillProgress = new inkAnimDef();
    scaleInterpolator = new inkAnimScale();
    scaleInterpolator.SetDuration(0.20);
    scaleInterpolator.SetStartScale(oldScale);
    scaleInterpolator.SetEndScale(newScale);
    scaleInterpolator.SetType(inkanimInterpolationType.Linear);
    scaleInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_fillProgress.AddInterpolator(scaleInterpolator);
    this.m_bufferAnimProxy = inkWidgetRef.PlayAnimation(this.m_dotMask, this.m_fillProgress);
  }

  public final func SetProgramCompleted(id: String, revealLocalizedName: Bool) -> Void;

  public final func ShowEndScreen(endData: EndScreenData) -> Void {
    let animproxy: ref<inkAnimProxy>;
    this.m_endScreen.SetUp(endData);
    animproxy = this.PlayLibraryAnimation(this.m_gridOutroAnimationLibraryName);
    animproxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnGridOutroOver");
  }

  protected cb func OnGridOutroOver(e: ref<inkAnimProxy>) -> Bool {
    let closeButton: wref<inkLogicController>;
    let closeButtonRef: inkWidgetRef;
    this.PlayLibraryAnimation(this.m_endScreenIntroAnimationLibraryName);
    inkWidgetRef.SetVisible(this.m_gridContainer, false);
    inkWidgetRef.SetVisible(this.m_programsContainer, false);
    inkWidgetRef.SetVisible(this.m_bufferContainer, false);
    inkWidgetRef.SetVisible(this.m_basicAccessContainer, false);
    inkWidgetRef.SetVisible(this.m_endScreenContainer, true);
    this.SetFluffVisibility(false);
    closeButtonRef = this.m_endScreen.GetCloseButtonRef();
    closeButton = inkWidgetRef.GetController(closeButtonRef);
    closeButton.RegisterToCallback(n"OnRelease", this, n"OnCloseClicked");
  }

  public final func GetLastCellSelected() -> CellData {
    return this.m_grid.GetLastCellSelected();
  }

  public final func Close() -> Void {
    this.GetRootWidget().SetVisible(false);
    this.ClearContainer(inkWidgetRef.Get(this.m_gridContainer) as inkCompoundWidget);
    this.ClearContainer(inkWidgetRef.Get(this.m_bufferContainer) as inkCompoundWidget);
    this.ClearContainer(inkWidgetRef.Get(this.m_programsContainer) as inkCompoundWidget);
    this.ClearContainer(inkWidgetRef.Get(this.m_endScreenContainer) as inkCompoundWidget);
    this.ClearContainer(inkWidgetRef.Get(this.m_basicAccessContainer) as inkCompoundWidget);
  }

  private final func StartIntroAnimation() -> Void {
    inkVideoRef.Play(this.m_middleVideoContainer);
    this.m_sidesAnim.SetVisible(true);
    this.PlayLibraryAnimation(this.m_introAnimationLibraryName);
  }

  protected cb func OnStartSidesAnimation(e: wref<inkWidget>) -> Bool {
    let controller: wref<NetworkMinigameAnimationCallManager> = this.m_sidesAnim.GetController() as NetworkMinigameAnimationCallManager;
    controller.StartReveal();
  }

  protected cb func OnStartMinigameBGIntroAnimation(e: wref<inkWidget>) -> Bool;

  protected cb func OnIntroAnimationFinished(e: wref<inkWidget>) -> Bool;

  private final func InitializeFluffLines() -> Void {
    let lineController: wref<inkLinePattern>;
    let positionalIndex: Float;
    let vertexToAdd: Vector2;
    let gridData: array<CellData> = this.m_grid.GetGrid();
    let cellWidget: wref<inkWidget> = gridData[0].assignedCell.GetRootWidget();
    let cellSize: Vector2 = cellWidget.GetSize();
    let i: Int32 = 0;
    while i < ArraySize(this.m_DottedLinesList) {
      lineController = inkWidgetRef.Get(this.m_DottedLinesList[i]) as inkLinePattern;
      positionalIndex = Cast(FloorF((Cast(i) + 1.00) / 2.00));
      vertexToAdd = new Vector2(this.m_linesToGridOffset + positionalIndex * cellSize.X - this.m_linesSeparationDistance * positionalIndex, -95.00);
      lineController.AddVertex(vertexToAdd);
      i += 1;
    };
  }

  private final func SetFluffVisibility(isVisible: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_FluffToHideContainer) {
      inkWidgetRef.SetVisible(this.m_FluffToHideContainer[i], isVisible);
      i += 1;
    };
  }

  private final func ClearContainer(toClear: ref<inkCompoundWidget>) -> Void {
    toClear = inkWidgetRef.Get(this.m_gridContainer) as inkCompoundWidget;
    toClear.RemoveAllChildren();
  }

  protected cb func OnCellSelectCallback(e: wref<inkWidget>) -> Bool {
    this.CallCustomCallback(n"OnCellSelected");
  }

  protected cb func OnCloseClicked(e: ref<inkPointerEvent>) -> Bool {
    this.CallCustomCallback(n"OnEndClosed");
  }
}

public class NetworkMinigameAnimationCallManager extends inkLogicController {

  public final func StartReveal() -> Void {
    this.PlayLibraryAnimation(n"reveal");
  }
}

public class NetworkMinigameAnimationCallbacksTransmitter extends inkLogicController {

  protected cb func OnStartSidesAnimation() -> Bool {
    this.CallCustomCallback(n"OnStartSidesAnimation");
  }

  protected cb func OnStartMinigameBGIntroAnimation() -> Bool {
    this.CallCustomCallback(n"OnStartMinigameBGIntroAnimation");
  }

  protected cb func OnIntroAnimationFinished() -> Bool {
    this.CallCustomCallback(n"OnIntroAnimationFinished");
  }
}
