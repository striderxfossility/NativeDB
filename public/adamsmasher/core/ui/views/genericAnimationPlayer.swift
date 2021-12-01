
public class animationPlayer extends inkLogicController {

  public edit let animName: CName;

  @default(animationPlayer, inkanimLoopType.Cycle)
  public edit let loopType: inkanimLoopType;

  @default(animationPlayer, 0.f)
  public edit let delay: Float;

  @default(animationPlayer, true)
  public edit let playInfinite: Bool;

  @default(animationPlayer, 1)
  public edit let loopsAmount: Uint32;

  @default(animationPlayer, false)
  public edit let playReversed: Bool;

  public edit let animTarget: inkWidgetRef;

  @default(animationPlayer, true)
  public edit let autoPlay: Bool;

  private let m_anim: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    if this.autoPlay {
      this.Play();
    };
  }

  public final func PlayOrPause(flag: Bool) -> Void {
    if flag {
      this.Play();
    } else {
      this.Pause();
    };
  }

  public final func PlayOrStop(flag: Bool) -> Void {
    if flag {
      this.Play();
    } else {
      this.Stop();
    };
  }

  public final func Play() -> Void {
    if this.m_anim == null {
      this.m_anim = this.CreateAndPlayAnimation();
    } else {
      this.m_anim.Resume();
    };
  }

  public final func Pause() -> Void {
    if this.m_anim != null {
      this.m_anim.Pause();
    };
  }

  public final func Stop() -> Void {
    if this.m_anim != null {
      this.m_anim.Stop();
      this.m_anim = null;
    };
  }

  private final func CreateAndPlayAnimation() -> ref<inkAnimProxy> {
    let options: inkAnimOptions;
    options.loopType = this.loopType;
    options.executionDelay = this.delay;
    options.loopInfinite = this.playInfinite;
    options.loopCounter = this.loopsAmount;
    options.playReversed = this.playReversed;
    let widgetSet: ref<inkWidgetsSet> = SelectWidgets(inkWidgetRef.Get(this.animTarget));
    if inkWidgetRef.Get(this.animTarget) != null {
      return this.PlayLibraryAnimationOnTargets(this.animName, widgetSet, options);
    };
    return this.PlayLibraryAnimation(this.animName, options);
  }
}
