
public class NetworkMinigameElementController extends inkLogicController {

  protected let m_data: ElementData;

  protected edit let m_text: inkTextRef;

  protected edit let m_textNormalColor: Color;

  protected edit let m_textHighlightColor: Color;

  protected edit let m_bg: inkRectangleRef;

  protected edit let m_colorAccent: inkWidgetRef;

  protected edit let m_dimmedOpacity: Float;

  protected edit let m_notDimmedOpacity: Float;

  protected let m_defaultFontSize: Int32;

  protected let m_wasConsumed: Bool;

  private let m_root: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    inkTextRef.SetText(this.m_text, "");
    this.m_wasConsumed = false;
    this.m_defaultFontSize = inkTextRef.GetFontSize(this.m_text);
    this.SetElementActive(false);
  }

  public func SetContent(toSet: ElementData) -> Void {
    this.m_data = toSet;
    inkTextRef.SetText(this.m_text, toSet.id);
    this.RefreshColorAccent();
  }

  public func SetHighlightStatus(doHighlight: Bool) -> Void {
    inkTextRef.SetFontSize(this.m_text, doHighlight ? this.m_defaultFontSize + 4 : this.m_defaultFontSize);
    inkWidgetRef.SetVisible(this.m_bg, doHighlight);
    inkWidgetRef.SetTintColor(this.m_text, doHighlight ? this.m_textHighlightColor : this.m_textNormalColor);
  }

  public final func GetContentWidget() -> inkWidgetRef {
    return this.m_text;
  }

  public final func GetContent() -> ElementData {
    return this.m_data;
  }

  public func Consume() -> Void {
    this.m_wasConsumed = true;
    inkTextRef.SetText(this.m_text, "XX");
    this.m_root.SetOpacity(0.50);
    this.RefreshColorAccent();
  }

  public final func RefreshColorAccent() -> Void {
    let toSet: CName;
    if this.m_wasConsumed {
      toSet = n"Default";
    } else {
      switch this.m_data.id {
        case "1C":
          toSet = n"Instruction1";
          break;
        case "55":
          toSet = n"Instruction2";
          break;
        case "BD":
          toSet = n"Instruction3";
          break;
        case "E9":
          toSet = n"Instruction4";
          break;
        default:
          toSet = n"Default";
      };
    };
    inkWidgetRef.SetState(this.m_colorAccent, toSet);
  }

  public final func SetElementActive(isDimmed: Bool) -> Void {
    this.m_root.SetInteractive(!isDimmed);
    inkWidgetRef.SetOpacity(this.m_bg, isDimmed ? this.m_dimmedOpacity : this.m_notDimmedOpacity);
    inkWidgetRef.SetOpacity(this.m_text, isDimmed ? this.m_dimmedOpacity : this.m_notDimmedOpacity);
    inkWidgetRef.SetOpacity(this.m_colorAccent, isDimmed ? this.m_dimmedOpacity : this.m_notDimmedOpacity);
  }

  public final func SetAsBufferSlot() -> Void {
    inkWidgetRef.SetVisible(this.m_bg, true);
    inkWidgetRef.SetOpacity(this.m_bg, this.m_dimmedOpacity);
  }
}

public class NetworkMinigameAnimatedElementController extends NetworkMinigameElementController {

  protected edit let m_onConsumeAnimation: CName;

  protected edit let m_onSetContentAnimation: CName;

  protected edit let m_onHighlightOnAnimation: CName;

  protected edit let m_onHighlightOffAnimation: CName;

  public func SetContent(toSet: ElementData) -> Void {
    this.SetContent(toSet);
    this.PlayLibraryAnimation(this.m_onSetContentAnimation);
  }

  public func SetHighlightStatus(doHighlight: Bool) -> Void {
    this.SetHighlightStatus(doHighlight);
    this.PlayLibraryAnimation(doHighlight ? this.m_onHighlightOnAnimation : this.m_onHighlightOffAnimation);
  }

  public func Consume() -> Void {
    this.Consume();
    this.PlayLibraryAnimation(this.m_onConsumeAnimation);
  }
}
