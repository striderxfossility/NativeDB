
public class StatsProgressController extends inkLogicController {

  private edit let m_labelRef: inkTextRef;

  private edit let m_currentXpRef: inkTextRef;

  private edit let m_maxXpRef: inkTextRef;

  private edit let m_currentLevelRef: inkTextRef;

  private edit let m_currentPersentageRef: inkTextRef;

  private edit let m_XpWrapper: inkWidgetRef;

  private edit let m_maxXpWrapper: inkWidgetRef;

  private edit let m_progressBarFill: inkWidgetRef;

  private edit let m_progressBar: inkWidgetRef;

  private edit let m_progressMarkerBar: inkWidgetRef;

  private let m_barLenght: Float;

  protected cb func OnInitialize() -> Bool {
    let tempSize: Vector2 = inkWidgetRef.GetSize(this.m_progressBar);
    this.m_barLenght = tempSize.X;
  }

  public final func SetProgress(currentXp: Int32, maxXp: Int32) -> Void {
    let percentage: Float;
    if maxXp == -1 {
      inkWidgetRef.SetVisible(this.m_maxXpWrapper, true);
      inkWidgetRef.SetVisible(this.m_XpWrapper, false);
      percentage = 1.00;
    } else {
      inkWidgetRef.SetVisible(this.m_maxXpWrapper, false);
      inkWidgetRef.SetVisible(this.m_XpWrapper, true);
      inkTextRef.SetText(this.m_currentXpRef, IntToString(currentXp));
      inkTextRef.SetText(this.m_maxXpRef, IntToString(maxXp));
      percentage = Cast(currentXp) / Cast(maxXp);
    };
    inkTextRef.SetText(this.m_currentPersentageRef, IntToString(Cast(percentage * 100.00)) + "%");
    inkWidgetRef.SetScale(this.m_progressBarFill, new Vector2(percentage, 1.00));
    inkWidgetRef.SetMargin(this.m_progressMarkerBar, this.m_barLenght * percentage, 0.00, 0.00, 0.00);
  }

  public final func SetLevel(level: Int32) -> Void {
    inkTextRef.SetText(this.m_currentLevelRef, IntToString(level));
  }

  public final func SetProfiencyLevel(proficiency: ref<ProficiencyDisplayData>) -> Void {
    this.SetProgress(proficiency.m_expPoints, proficiency.m_maxExpPoints);
    this.SetLevel(proficiency.m_level);
    inkTextRef.SetText(this.m_labelRef, proficiency.m_localizedName);
  }
}
