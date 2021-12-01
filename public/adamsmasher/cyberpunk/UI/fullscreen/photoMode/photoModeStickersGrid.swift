
public class PhotoModeGridList extends inkRadioGroupController {

  private edit let m_ScrollArea: inkScrollAreaRef;

  private edit let m_ContentRoot: inkWidgetRef;

  private edit let m_SliderWidget: inkWidgetRef;

  private edit let m_rowOffset: Int32;

  private edit let m_firstOffset: Int32;

  private edit let m_rowLibraryId: CName;

  private edit let m_buttonLibraryId: CName;

  private let parentListItem: wref<PhotoModeMenuListItem>;

  private let m_buttons: array<wref<PhotoModeGridButton>>;

  private let m_rows: array<wref<inkWidget>>;

  private let m_sliderController: wref<inkSliderController>;

  private let m_ItemsInRow: Int32;

  private let m_RowsCount: Int32;

  private let m_SelectedIndex: Int32;

  private let m_PreviousSelectedIndex: Int32;

  private let m_visibleSize: Float;

  private let m_visibleRows: Int32;

  private let m_scrollRow: Int32;

  private let m_isVisibleOnscreen: Bool;

  public final func Setup(listItem: ref<PhotoModeMenuListItem>, rows: Int32, itemsInRow: Int32) -> Float {
    let i: Int32;
    let j: Int32;
    let row: wref<inkWidget>;
    let size: Vector2;
    this.parentListItem = listItem;
    if ArraySize(this.m_buttons) == 0 {
      i = 0;
      while i < rows {
        row = this.AddRow();
        j = 0;
        while j < itemsInRow {
          this.AddButton(row);
          j += 1;
        };
        i += 1;
      };
    };
    this.m_isVisibleOnscreen = false;
    this.m_ItemsInRow = itemsInRow;
    this.m_RowsCount = rows;
    this.m_PreviousSelectedIndex = -1;
    this.m_SelectedIndex = 0;
    this.m_visibleRows = this.m_RowsCount >= 5 ? 5 : this.m_RowsCount;
    this.m_visibleSize = Cast(this.m_firstOffset + this.m_rowOffset * this.m_visibleRows);
    this.m_scrollRow = 0;
    size = this.GetRootWidget().GetSize();
    inkWidgetRef.SetSize(this.m_ContentRoot, size.X, Cast(this.m_firstOffset + this.m_rowOffset * this.m_RowsCount));
    this.m_sliderController.Setup(0.00, Cast(this.m_RowsCount - this.m_visibleRows), 0.00, 1.00);
    this.Toggle(0);
    return this.m_visibleSize;
  }

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnValueChanged", this, n"OnValueChanged");
    this.m_sliderController = inkWidgetRef.GetControllerByType(this.m_SliderWidget, n"inkSliderController") as inkSliderController;
    this.m_sliderController.RegisterToCallback(n"OnSliderValueChanged", this, n"OnSliderValueChanged");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnValueChanged", this, n"OnValueChanged");
    this.m_sliderController.UnregisterFromCallback(n"OnSliderValueChanged", this, n"OnSliderValueChanged");
  }

  protected cb func OnValueChanged(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    this.m_SelectedIndex = selectedIndex;
    this.OnGridButtonSelected(this.m_SelectedIndex);
    this.UpdateSelectedState();
  }

  public final func OnVisbilityChanged(visible: Bool) -> Void {
    this.m_isVisibleOnscreen = visible;
    this.UpdateButtonsVisibility();
  }

  protected cb func OnSliderValueChanged(sliderController: wref<inkSliderController>, progress: Float, value: Float) -> Bool {
    this.ScrollToRow(Cast(value));
  }

  public final func OnGridButtonAction(buttonindex: Int32) -> Void {
    this.parentListItem.GridElementAction(buttonindex, this.m_buttons[buttonindex].GetData());
  }

  public final func OnGridButtonSelected(buttonindex: Int32) -> Void {
    this.parentListItem.GridElementSelected(buttonindex);
  }

  public final func HandleReleasedInput(e: ref<inkPointerEvent>, opt gameCtrl: wref<inkGameController>) -> Void {
    if e.IsAction(n"PhotoMode_SaveSettings") {
      this.OnGridButtonAction(this.GetCurrentIndex());
    } else {
      if e.IsAction(n"PhotoMode_ScrollUp") {
        this.m_sliderController.ChangeValue(Cast(this.m_scrollRow - 1));
      } else {
        if e.IsAction(n"PhotoMode_ScrollDown") {
          this.m_sliderController.ChangeValue(Cast(this.m_scrollRow + 1));
        };
      };
    };
  }

  public final func SetGridData(gridData: array<PhotoModeOptionGridButtonData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(gridData) {
      if i >= ArraySize(this.m_buttons) {
      } else {
        this.SetGridButtonImage(Cast(i), gridData[i].atlasResource, gridData[i].imagePart, gridData[i].optionData);
        i += 1;
      };
    };
  }

  public final func SetGridButtonImage(buttonIndex: Uint32, atlasPath: ResRef, imagePart: CName, buttonData: Int32) -> Void {
    let i: Int32 = Cast(buttonIndex);
    if i < ArraySize(this.m_buttons) {
      this.m_buttons[i].SetImage(atlasPath, imagePart);
      this.m_buttons[i].SetData(buttonData);
    };
  }

  private final func GetSelectedRow() -> Int32 {
    let selectedIndex: Int32 = this.GetCurrentIndex();
    return this.GetRow(selectedIndex);
  }

  private final func GetRow(buttonIndex: Int32) -> Int32 {
    if buttonIndex == -1 {
      return -1;
    };
    return buttonIndex / this.m_ItemsInRow;
  }

  public final func TrySelectLeft() -> Bool {
    let selectedIndex: Int32 = this.GetCurrentIndex();
    if selectedIndex % this.m_ItemsInRow > 0 {
      this.SelectButton(selectedIndex - 1);
      return true;
    };
    return false;
  }

  public final func TrySelectRight() -> Bool {
    let selectedIndex: Int32 = this.GetCurrentIndex();
    if selectedIndex % this.m_ItemsInRow < this.m_ItemsInRow - 1 {
      this.SelectButton(selectedIndex + 1);
      return true;
    };
    return false;
  }

  public final func TrySelectDown() -> Bool {
    let selectedIndex: Int32 = this.GetCurrentIndex();
    if this.GetSelectedRow() < this.m_RowsCount - 1 {
      this.SelectButton(selectedIndex + this.m_ItemsInRow);
      return true;
    };
    return false;
  }

  public final func TrySelectUp() -> Bool {
    let selectedIndex: Int32 = this.GetCurrentIndex();
    if this.GetSelectedRow() > 0 {
      this.SelectButton(selectedIndex - this.m_ItemsInRow);
      return true;
    };
    return false;
  }

  public final func SelectButton(index: Int32) -> Void {
    if index != this.GetCurrentIndex() || index != this.m_SelectedIndex {
      this.m_SelectedIndex = index;
      this.Toggle(index);
      this.UpdateScroll();
      this.UpdateSelectedState();
    };
  }

  public final func OnSelected() -> Void {
    if this.m_PreviousSelectedIndex >= 0 {
      this.SelectButton(this.m_PreviousSelectedIndex);
    } else {
      this.SelectButton(0);
    };
  }

  public final func OnDeSelected() -> Void {
    this.m_PreviousSelectedIndex = this.GetCurrentIndex();
    this.SelectButton(-1);
  }

  protected final func AddRow() -> wref<inkWidget> {
    let newRow: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_ContentRoot), this.m_rowLibraryId);
    newRow.SetAnchorPoint(0.00, 0.00);
    newRow.SetAnchor(inkEAnchor.TopFillHorizontaly);
    newRow.SetMargin(0.00, Cast(this.m_firstOffset + ArraySize(this.m_rows) * this.m_rowOffset), 0.00, 0.00);
    ArrayPush(this.m_rows, newRow);
    return newRow;
  }

  protected final func AddButton(parentWidget: wref<inkWidget>) -> Void {
    let gridButtonLogic: ref<PhotoModeGridButton>;
    let newButton: wref<inkWidget> = this.SpawnFromLocal(parentWidget, this.m_buttonLibraryId);
    newButton.SetAnchorPoint(0.50, 0.50);
    newButton.SetAnchor(inkEAnchor.Centered);
    newButton.SetSize(146.00, 146.00);
    gridButtonLogic = newButton.GetControllerByType(n"PhotoModeGridButton") as PhotoModeGridButton;
    gridButtonLogic.Setup(this, ArraySize(this.m_buttons));
    ArrayPush(this.m_buttons, gridButtonLogic);
    this.AddToggle(gridButtonLogic);
  }

  public final func UpdateScroll() -> Void {
    let oldScroll: Int32 = this.m_scrollRow;
    let selectedRow: Int32 = this.GetSelectedRow();
    while selectedRow >= this.m_scrollRow + this.m_visibleRows {
      this.m_scrollRow += 1;
    };
    while selectedRow < this.m_scrollRow {
      this.m_scrollRow -= 1;
    };
    this.UpdateButtonsVisibility();
    if oldScroll != this.m_scrollRow {
      this.m_sliderController.ChangeValue(Cast(this.m_scrollRow));
    };
  }

  private final func ScrollToRow(row: Int32) -> Void {
    let scrollValue: Float;
    if row < 0 || row > this.m_RowsCount - this.m_visibleRows {
      return;
    };
    this.m_scrollRow = row;
    this.UpdateButtonsVisibility();
    scrollValue = Cast(this.m_scrollRow) / Cast(this.m_RowsCount - this.m_visibleRows);
    inkScrollAreaRef.ScrollVertical(this.m_ScrollArea, scrollValue);
  }

  private final func GetRowClamped(row: Int32) -> Int32 {
    return row < 0 ? 0 : row;
  }

  public final func UpdateButtonsVisibility() -> Void {
    let row: Int32;
    let firstRow: Int32 = this.GetRowClamped(this.m_scrollRow);
    let i: Int32 = 0;
    while i < ArraySize(this.m_buttons) {
      row = this.GetRow(i);
      if this.m_isVisibleOnscreen && row >= firstRow && row < firstRow + this.m_visibleRows {
        this.m_buttons[i].OnVisibilityOnGridChanged(true);
      } else {
        this.m_buttons[i].OnVisibilityOnGridChanged(false);
      };
      i += 1;
    };
  }

  public final func UpdateSelectedState() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_buttons) {
      if i == this.m_SelectedIndex {
        if !this.m_buttons[i].IsToggledVisually() {
          this.m_buttons[i].ButtonStateChanged(true);
        };
      } else {
        if this.m_buttons[i].IsToggledVisually() {
          this.m_buttons[i].ButtonStateChanged(false);
        };
      };
      i += 1;
    };
  }

  public final func UpdateSize(timeDelta: Float) -> Void {
    let row: Int32;
    let firstRow: Int32 = this.GetRowClamped(this.m_scrollRow);
    let i: Int32 = 0;
    while i < ArraySize(this.m_buttons) {
      row = this.GetRow(i);
      if row >= firstRow && row < firstRow + this.m_visibleRows {
        this.m_buttons[i].UpdateSize(timeDelta);
      };
      i += 1;
    };
  }

  public final func Update(timeDelta: Float) -> Void {
    this.UpdateSize(timeDelta);
    this.UpdateSelectedState();
  }
}
