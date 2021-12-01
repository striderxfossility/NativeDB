
public class InteractionsInputView extends inkLogicController {

  private edit let m_TopArrowRef: inkWidgetRef;

  private edit let m_BotArrowRef: inkWidgetRef;

  private edit let m_InputImage: inkImageRef;

  @default(InteractionsInputView, true)
  private let m_ShowArrows: Bool;

  private let m_HasAbove: Bool;

  private let m_HasBelow: Bool;

  private let m_CurrentNum: Int32;

  private let m_AllItemsNum: Int32;

  private edit let m_DefaultInputPartName: CName;

  public final func Setup(visible: Bool, currentNum: Int32, allItemsNum: Int32, hasAbove: Bool, hasBelow: Bool) -> Void {
    this.SetVisible(visible);
    this.Setup(currentNum, allItemsNum, hasAbove, hasBelow);
  }

  public final func Setup(currentNum: Int32, allItemsNum: Int32, hasAbove: Bool, hasBelow: Bool) -> Void {
    this.m_CurrentNum = currentNum;
    this.m_AllItemsNum = allItemsNum;
    this.m_HasAbove = hasAbove;
    this.m_HasBelow = hasBelow;
    this.RefreshView();
  }

  public final func SetVisible(visible: Bool) -> Void {
    this.GetRootWidget().SetVisible(visible);
  }

  public final func ShowArrows(show: Bool) -> Void {
    this.m_ShowArrows = show;
    this.RefreshView();
  }

  private final func RefreshView() -> Void {
    inkWidgetRef.SetVisible(this.m_TopArrowRef, (this.m_CurrentNum != 0 || this.m_HasAbove) && this.m_ShowArrows);
    inkWidgetRef.SetVisible(this.m_BotArrowRef, (this.m_CurrentNum != this.m_AllItemsNum - 1 || this.m_HasBelow) && this.m_ShowArrows);
  }

  public final func SetInputButton(inputPartName: CName) -> Void {
    inkImageRef.SetTexturePart(this.m_InputImage, inputPartName);
  }

  public final func ResetInputButton() -> Void {
    inkImageRef.SetTexturePart(this.m_InputImage, this.m_DefaultInputPartName);
  }
}
