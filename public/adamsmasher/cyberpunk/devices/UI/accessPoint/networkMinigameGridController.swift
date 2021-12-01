
public class NetworkMinigameGridController extends inkLogicController {

  protected edit let m_gridContainer: inkWidgetRef;

  protected edit let m_horizontalHoverHighlight: inkWidgetRef;

  protected edit let m_horizontalCurrentHighlight: inkWidgetRef;

  protected edit let m_verticalHoverHighlight: inkWidgetRef;

  protected edit let m_verticalCurrentHighlight: inkWidgetRef;

  protected edit let m_gridVisualOffset: Vector2;

  protected edit let m_gridCellLibraryName: CName;

  public let m_gridData: array<CellData>;

  public let m_lastSelected: CellData;

  public let m_currentActivePosition: Vector2;

  public let m_isHorizontalHighlight: Bool;

  public let m_lastHighlighted: CellData;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_animHighlightProxy: ref<inkAnimProxy>;

  private let m_firstBoot: Bool;

  private let m_isHorizontal: Bool;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetTranslation(this.m_gridContainer, this.m_gridVisualOffset);
    this.m_firstBoot = true;
  }

  private final func Clear() -> Void {
    let toClear: ref<inkCompoundWidget> = inkWidgetRef.Get(this.m_gridContainer) as inkCompoundWidget;
    toClear.RemoveAllChildren();
  }

  public final func SetUp(gridData: array<CellData>) -> Void {
    this.SetGridData(gridData);
    this.m_isHorizontalHighlight = true;
    this.m_lastSelected = this.FindCellData(new Vector2(0.00, 0.00));
    this.m_lastSelected.assignedCell.Consume();
    this.HighlightCellSet(0, false, true);
  }

  public final func SetGridData(gridData: array<CellData>) -> Void {
    let i: Int32;
    this.Clear();
    this.m_gridData = gridData;
    i = 0;
    while i < ArraySize(this.m_gridData) {
      this.m_gridData[i].assignedCell = this.AddCell(gridData[i]).GetController() as NetworkMinigameGridCellController;
      i += 1;
    };
  }

  private final func AddCell(toAdd: CellData) -> wref<inkWidget> {
    let cell: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_gridContainer), this.m_gridCellLibraryName);
    let cellLogic: wref<NetworkMinigameGridCellController> = cell.GetController() as NetworkMinigameGridCellController;
    cellLogic.Spawn(toAdd, this);
    return cell;
  }

  public final func SetCurrentActivePosition(position: Vector2, isHorizontal: Bool) -> Void {
    this.m_currentActivePosition = position;
    this.m_isHorizontalHighlight = isHorizontal;
    this.HighlightCellSet(Cast(this.m_isHorizontalHighlight ? position.X : position.Y), false, this.m_isHorizontalHighlight);
  }

  public final func SetLastCellSelected(cell: CellData) -> Void {
    if !cell.assignedCell.IsConsumed() {
      this.m_lastSelected = cell;
      this.CallCustomCallback(n"OnCellSelected");
    };
  }

  public final func GetLastCellSelected() -> CellData {
    return this.m_lastSelected;
  }

  public final func GetGrid() -> array<CellData> {
    return this.m_gridData;
  }

  public final func FindCellData(position: Vector2) -> CellData {
    let result: CellData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_gridData) {
      if this.m_gridData[i].position.X == position.X && this.m_gridData[i].position.Y == position.Y {
        result = this.m_gridData[i];
        return result;
      };
      i += 1;
    };
    return result;
  }

  public final func HighlightFromCellHover(position: Vector2) -> Void {
    if this.IsOnCurrentCellSet(position) {
      this.HighlightCellSet(Cast(this.m_isHorizontalHighlight ? position.Y : position.X), true, !this.m_isHorizontalHighlight);
    };
  }

  public final func IsOnCurrentCellSet(position: Vector2) -> Bool {
    return this.m_isHorizontalHighlight ? position.X : position.Y == this.m_isHorizontalHighlight ? this.m_lastSelected.position.X : this.m_lastSelected.position.Y;
  }

  public final func RemoveHighlightFromCellHover() -> Void {
    if IsDefined(this.m_lastHighlighted.assignedCell) {
      this.m_lastHighlighted.assignedCell.SetHighlightStatus(false);
    };
  }

  private final func HighlightCellSet(index: Int32, isHover: Bool, isHorizontal: Bool) -> Void {
    let cellSize: Vector2;
    let cellToHighlightPos: Vector2;
    let cellWidget: wref<inkWidget>;
    let fullScale: Vector2;
    let highlightToMove: inkWidgetRef;
    let newHorizontalPivot: Vector2;
    let newVerticalPivor: Vector2;
    if ArraySize(this.m_gridData) == 0 {
      return;
    };
    cellWidget = this.m_gridData[0].assignedCell.GetRootWidget();
    cellSize = cellWidget.GetSize();
    this.m_isHorizontal = isHorizontal;
    if isHorizontal {
      highlightToMove = isHover ? this.m_horizontalHoverHighlight : this.m_horizontalCurrentHighlight;
      inkWidgetRef.SetTranslation(highlightToMove, 0.00, Cast(index) * cellSize.Y + this.m_gridVisualOffset.Y);
      cellToHighlightPos = new Vector2(Cast(index), this.m_lastSelected.position.Y);
    } else {
      highlightToMove = isHover ? this.m_verticalHoverHighlight : this.m_verticalCurrentHighlight;
      inkWidgetRef.SetTranslation(highlightToMove, Cast(index) * cellSize.X + this.m_gridVisualOffset.Y, 0.00);
      cellToHighlightPos = new Vector2(this.m_lastSelected.position.X, Cast(index));
    };
    if !isHover {
      if IsDefined(this.m_lastHighlighted.assignedCell) {
        this.m_lastHighlighted.assignedCell.SetHighlightStatus(false);
      };
    } else {
      this.m_lastHighlighted = this.FindCellData(cellToHighlightPos);
      this.m_lastHighlighted.assignedCell.SetHighlightStatus(true);
    };
    inkWidgetRef.SetSize(highlightToMove, cellSize);
    this.RefreshDimLevels(index, isHorizontal);
    if !isHover && !this.m_firstBoot {
      newHorizontalPivot.X = Cast((650 / 5 * index) / 650);
      newVerticalPivor.Y = Cast((400 / 5 * index) / 400);
      inkWidgetRef.SetRenderTransformPivot(this.m_horizontalHoverHighlight, newHorizontalPivot);
      inkWidgetRef.SetRenderTransformPivot(this.m_verticalHoverHighlight, newVerticalPivor);
      this.m_animProxy.Stop();
      if isHorizontal {
        this.m_animProxy = this.PlayLibraryAnimation(n"AnimationVerticalToHorizontal");
      } else {
        this.m_animProxy = this.PlayLibraryAnimation(n"AnimationHorizontalToVertical");
      };
    };
    if isHover && !this.m_firstBoot {
      if IsDefined(this.m_animHighlightProxy) && this.m_animHighlightProxy.IsPlaying() {
        this.m_animHighlightProxy.Stop();
      };
      fullScale.X = 1.00;
      fullScale.Y = 1.00;
      this.m_animHighlightProxy.Stop();
      if isHorizontal {
        this.m_animHighlightProxy = this.PlayLibraryAnimation(n"horizonal_highlight");
        inkWidgetRef.SetSize(this.m_horizontalCurrentHighlight, cellSize);
        inkWidgetRef.SetScale(this.m_horizontalCurrentHighlight, fullScale);
        inkWidgetRef.SetTranslation(this.m_horizontalCurrentHighlight, 0.00, Cast(index) * cellSize.Y + this.m_gridVisualOffset.Y);
      } else {
        this.m_animHighlightProxy = this.PlayLibraryAnimation(n"vertical_highlight");
        inkWidgetRef.SetSize(this.m_verticalCurrentHighlight, cellSize);
        inkWidgetRef.SetScale(this.m_verticalCurrentHighlight, fullScale);
        inkWidgetRef.SetTranslation(this.m_verticalCurrentHighlight, Cast(index) * cellSize.X + this.m_gridVisualOffset.Y, 0.00);
      };
    };
    this.m_firstBoot = false;
  }

  public final func RefreshDimLevels(index: Int32, isHorizontal: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_gridData) {
      this.m_gridData[i].assignedCell.SetElementActive(!this.IsOnCurrentCellSet(this.m_gridData[i].position));
      i += 1;
    };
  }
}

public class NetworkMinigameGridCellController extends inkButtonController {

  public let m_cellData: CellData;

  private let m_grid: wref<NetworkMinigameGridController>;

  protected edit let m_slotsContainer: inkWidgetRef;

  protected let m_slotsContent: wref<NetworkMinigameElementController>;

  protected edit let m_elementLibraryName: CName;

  private let m_defaultColor: HDRColor;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_slotsContainer, n"OnRelease", this, n"OnReleaseContainer");
  }

  public final func Spawn(setUp: CellData, grid: wref<NetworkMinigameGridController>) -> Void {
    this.m_cellData = setUp;
    this.m_grid = grid;
    let slot: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_slotsContainer), this.m_elementLibraryName);
    this.m_slotsContent = slot.GetController() as NetworkMinigameElementController;
    this.m_slotsContent.SetContent(setUp.element);
    if this.m_cellData.consumed {
      this.m_slotsContent.Consume();
    };
    this.m_defaultColor = slot.GetTintColor();
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    switch newState {
      case inkEButtonState.Normal:
        this.m_grid.RemoveHighlightFromCellHover();
        break;
      case inkEButtonState.Hover:
        this.m_grid.HighlightFromCellHover(this.m_cellData.position);
        break;
      case inkEButtonState.Press:
        this.PlaySound(n"Button", n"OnPress");
        break;
      case inkEButtonState.Disabled:
    };
  }

  public final func SetHighlightStatus(isHighlighted: Bool) -> Void {
    this.m_slotsContent.SetHighlightStatus(isHighlighted && !this.m_cellData.consumed);
  }

  protected cb func OnReleaseContainer(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_cellData.consumed {
      this.m_grid.SetLastCellSelected(this.m_cellData);
      this.m_grid.RemoveHighlightFromCellHover();
    };
  }

  public final func Consume() -> Void {
    this.m_cellData.consumed = true;
    this.m_slotsContent.Consume();
  }

  public final func IsConsumed() -> Bool {
    return this.m_cellData.consumed;
  }

  public final func SetElementActive(isDimmed: Bool) -> Void {
    let root: wref<inkWidget>;
    this.m_slotsContent.SetElementActive(isDimmed);
    root = this.GetRootWidget();
    root.SetInteractive(!isDimmed);
  }
}
