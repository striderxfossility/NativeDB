
public class LoopAnimationLogicController extends inkLogicController {

  private edit let m_defaultAnimation: CName;

  @default(LoopAnimationLogicController, inkSelectionRule.Single)
  private edit let m_selectionRule: inkSelectionRule;

  protected cb func OnInitialize() -> Bool {
    let animationOptions: inkAnimOptions = new inkAnimOptions();
    animationOptions.loopInfinite = true;
    animationOptions.loopType = inkanimLoopType.Cycle;
    this.PlayLibraryAnimationOnTargets(this.m_defaultAnimation, SelectWidgets(this.GetRootWidget(), this.m_selectionRule), animationOptions);
  }
}
