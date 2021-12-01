
public class ProgressBarAnimationChunkController extends inkLogicController {

  private edit let m_rootCanvas: inkWidgetRef;

  private edit let m_barCanvas: inkWidgetRef;

  private let m_hitAnim: ref<inkAnimProxy>;

  private let m_fullbarSize: Float;

  private let m_isNegative: Bool;

  public final func SetAnimation(widght: Float, height: Float, fullbarSize: Float, isNegative: Bool) -> Void {
    let animName: CName;
    this.m_fullbarSize = fullbarSize;
    this.m_isNegative = isNegative;
    inkWidgetRef.SetSize(this.m_rootCanvas, new Vector2(widght, height));
    inkWidgetRef.SetSize(this.m_barCanvas, new Vector2(widght, height));
    this.GetRootWidget().SetMargin(fullbarSize, 0.00, 0.00, 0.00);
    inkWidgetRef.SetVisible(this.m_rootCanvas, true);
    animName = isNegative ? n"hit_chunk_with_bracket" : n"heal_chunk_with_bracket";
    if this.m_hitAnim.IsPlaying() {
      this.m_hitAnim.Stop();
      this.OnAnimationEnd(this.m_hitAnim);
    };
    this.m_hitAnim = this.PlayLibraryAnimation(animName);
    this.m_hitAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationEnd");
  }

  protected cb func OnAnimationEnd(e: ref<inkAnimProxy>) -> Bool {
    let evt: ref<OnProgressBarAnimFinish> = new OnProgressBarAnimFinish();
    evt.FullbarSize = this.m_fullbarSize;
    evt.IsNegative = this.m_isNegative;
    this.QueueEvent(evt);
    inkWidgetRef.SetVisible(this.m_rootCanvas, false);
  }

  public final func IsProgressAnimationPlaying() -> Bool {
    return this.m_hitAnim.IsPlaying();
  }
}
