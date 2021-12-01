
public class InventoryFilterButton extends BaseButtonView {

  private edit let m_Label: inkTextRef;

  private edit let m_InputIcon: inkImageRef;

  @default(InventoryFilterButton, false)
  private let m_IntroPlayed: Bool;

  public final func Setup(text: String, input: CName, framesDelay: Int32) -> Void {
    this.Setup(text, input);
    if !this.m_IntroPlayed {
      this.m_IntroPlayed = true;
      this.PlayIntroAnimation(framesDelay);
    };
  }

  public final func Setup(text: String, input: CName) -> Void {
    inkTextRef.SetLetterCase(this.m_Label, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_Label, text);
    inkImageRef.SetTexturePart(this.m_InputIcon, input);
  }

  private final func PlayIntroAnimation(framesDelay: Int32) -> Void {
    let animaionDef: ref<inkAnimDef> = new inkAnimDef();
    let scaleInterp: ref<inkAnimScale> = new inkAnimScale();
    scaleInterp.SetStartScale(new Vector2(0.00, 0.00));
    scaleInterp.SetEndScale(new Vector2(1.00, 1.00));
    scaleInterp.SetMode(inkanimInterpolationMode.EasyInOut);
    scaleInterp.SetType(inkanimInterpolationType.Sinusoidal);
    scaleInterp.SetDirection(inkanimInterpolationDirection.FromTo);
    scaleInterp.SetDuration(0.25);
    scaleInterp.SetStartDelay(0.03 * Cast(framesDelay));
    animaionDef.AddInterpolator(scaleInterp);
    this.GetRootWidget().PlayAnimation(animaionDef);
  }
}
