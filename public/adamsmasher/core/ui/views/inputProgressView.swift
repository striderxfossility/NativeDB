
public class InputProgressView extends inkLogicController {

  private let m_TargetImage: wref<inkImage>;

  private let m_ProgressPercent: Int32;

  @default(InputProgressView, icon_circle_anim_)
  private edit let m_PartName: String;

  protected cb func OnInitialize() -> Bool {
    this.m_TargetImage = this.GetRootWidget() as inkImage;
    if !IsDefined(this.m_TargetImage) {
      LogUIError("[InputProgressView] Not on an image widget!");
    };
    this.m_ProgressPercent = -1;
    this.Reset();
  }

  public final func SetProgress(progress: Float) -> Void {
    this.SetProgress(Cast(progress * 100.00));
  }

  public final func SetProgress(percentProgress: Int32) -> Void {
    percentProgress = Clamp(percentProgress, 0, 99);
    if this.m_ProgressPercent != percentProgress {
      this.m_ProgressPercent = percentProgress;
      if IsDefined(this.m_TargetImage) {
        this.m_TargetImage.SetTexturePart(StringToName(this.m_PartName + IntToString(percentProgress)));
      };
    };
  }

  public final func Reset() -> Void {
    this.SetProgress(0);
  }
}
