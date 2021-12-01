
public class TutorialMainController extends inkGameController {

  private edit let m_instructionPanel: inkWidgetRef;

  private edit let m_instructionDesc: inkTextRef;

  private edit let m_pointer: inkWidgetRef;

  private let m_tutorialActive: Bool;

  private let m_currentTutorialStep: TutorialStep;

  protected cb func OnInitialize() -> Bool {
    this.m_tutorialActive = false;
  }

  protected cb func OnUnitialize() -> Bool;

  public final func StartTutorial() -> Void {
    this.m_tutorialActive = true;
  }

  public final func UpdateTutorialStep(step: TutorialStep) -> Void {
    let pointerPos: inkMargin;
    this.m_currentTutorialStep = step;
    if NotEquals(this.m_currentTutorialStep.description, "") {
      inkWidgetRef.SetVisible(this.m_instructionPanel, true);
      inkTextRef.SetText(this.m_instructionDesc, this.m_currentTutorialStep.description);
    } else {
      inkWidgetRef.SetVisible(this.m_instructionPanel, false);
    };
    if this.m_currentTutorialStep.showPointer {
      inkWidgetRef.SetVisible(this.m_pointer, true);
      inkWidgetRef.SetRotation(this.m_pointer, this.m_currentTutorialStep.pointerRotation);
      pointerPos.left = this.m_currentTutorialStep.pointerXPos;
      pointerPos.top = this.m_currentTutorialStep.pointerYPos;
      inkWidgetRef.SetMargin(this.m_pointer, pointerPos);
    } else {
      inkWidgetRef.SetVisible(this.m_pointer, false);
    };
  }

  public final func CompleteTutorial() -> Void {
    this.m_tutorialActive = false;
  }

  public final func IsTutorialActive() -> Bool {
    return this.m_tutorialActive;
  }
}
