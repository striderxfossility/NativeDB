
public class TextAnimOnTextChange extends inkLogicController {

  private edit let textField: inkTextRef;

  @default(TextAnimOnTextChange, default)
  private edit let animationName: CName;

  private let m_BlinkAnim: ref<inkAnimDef>;

  private let m_ScaleAnim: ref<inkAnimDef>;

  private let bufferedValue: String;

  protected cb func OnInitialize() -> Bool {
    let scaleInterpolator: ref<inkAnimScale>;
    this.m_BlinkAnim = new inkAnimDef();
    let alphaInterpolator2: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator2.SetDuration(0.50);
    alphaInterpolator2.SetStartTransparency(0.10);
    alphaInterpolator2.SetEndTransparency(1.00);
    this.m_BlinkAnim.AddInterpolator(alphaInterpolator2);
    this.m_ScaleAnim = new inkAnimDef();
    scaleInterpolator = new inkAnimScale();
    scaleInterpolator.SetDuration(0.50);
    scaleInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    scaleInterpolator.SetEndScale(new Vector2(1.20, 1.20));
    this.m_ScaleAnim.AddInterpolator(scaleInterpolator);
    inkWidgetRef.RegisterToCallback(this.textField, n"OnTextChanged", this, n"OnChangeTextToInject");
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.textField, n"OnTextChanged", this, n"OnChangeTextToInject");
  }

  protected cb func OnChangeTextToInject(str: String) -> Bool {
    if NotEquals(this.bufferedValue, str) {
      if Equals(this.animationName, n"default") || Equals(this.animationName, n"") {
        this.GetRootWidget().PlayAnimation(this.m_BlinkAnim);
        this.GetRootWidget().PlayAnimation(this.m_ScaleAnim);
      } else {
        this.PlayLibraryAnimation(this.animationName);
      };
    };
    this.bufferedValue = str;
  }
}
