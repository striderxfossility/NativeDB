
public class sampleUIAnimationController extends inkLogicController {

  private let m_rotation_anim: ref<inkAnimDef>;

  private let m_size_anim: ref<inkAnimDef>;

  private let m_color_anim: ref<inkAnimDef>;

  private let m_alpha_anim: ref<inkAnimDef>;

  private let m_rotation_anim_proxy: ref<inkAnimProxy>;

  private let m_size_anim_proxy: ref<inkAnimProxy>;

  private let m_color_anim_proxy: ref<inkAnimProxy>;

  private let m_alpha_anim_proxy: ref<inkAnimProxy>;

  private let m_rotation_widget: wref<inkWidget>;

  private let m_size_widget: wref<inkWidget>;

  private let m_color_widget: wref<inkWidget>;

  private let m_alpha_widget: wref<inkWidget>;

  private let m_iteration_counter: Uint32;

  private let m_is_paused: Bool;

  private let m_is_stoped: Bool;

  private let m_playReversed: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_iteration_counter = 3u;
    this.m_is_paused = false;
    this.m_is_stoped = true;
    this.m_playReversed = false;
    this.PrepareDefinitions();
    this.m_rotation_widget = this.GetWidget(n"simple_animations/simple_rotation_anim/simple_rotation_example");
    this.m_size_widget = this.GetWidget(n"simple_animations/simple_size_anim/simple_size_example");
    this.m_color_widget = this.GetWidget(n"simple_animations/simple_color_anim/simple_color_example");
    this.m_alpha_widget = this.GetWidget(n"simple_animations/simple_alpha_anim/simple_alpha_example");
    this.OnPlayPingPongLoop(this.GetRootWidget());
  }

  public final func OnStopAnimation(widget: wref<inkWidget>) -> Void {
    this.m_is_paused = false;
    this.m_is_stoped = true;
    this.m_rotation_anim_proxy.Stop();
    this.m_size_anim_proxy.Stop();
    this.m_color_anim_proxy.Stop();
    this.m_alpha_anim_proxy.Stop();
  }

  public final func OnPauseResumeAnimation(widget: wref<inkWidget>) -> Void {
    let widgetHandle: ref<inkWidget> = widget;
    let root: ref<inkCompoundWidget> = widgetHandle as inkCompoundWidget;
    let label: ref<inkText> = root.GetWidget(n"pause_button_text") as inkText;
    this.m_is_paused = !this.m_is_paused;
    this.m_is_stoped = false;
    if Equals(this.m_is_paused, true) {
      label.SetText("RESUME");
      this.m_rotation_anim_proxy.Pause();
      this.m_size_anim_proxy.Pause();
      this.m_color_anim_proxy.Pause();
      this.m_alpha_anim_proxy.Pause();
    } else {
      label.SetText("PAUSE");
      this.m_rotation_anim_proxy.Resume();
      this.m_size_anim_proxy.Resume();
      this.m_color_anim_proxy.Resume();
      this.m_alpha_anim_proxy.Resume();
    };
  }

  public final func OnPlay(widget: wref<inkWidget>) -> Void {
    this.m_is_paused = false;
    this.m_is_stoped = false;
    this.m_rotation_widget.PlayAnimation(this.m_rotation_anim);
    this.m_size_widget.PlayAnimation(this.m_size_anim);
    this.m_color_widget.PlayAnimation(this.m_color_anim);
    this.m_alpha_widget.PlayAnimation(this.m_alpha_anim);
  }

  public final func OnPlayCycleLoop(widget: wref<inkWidget>) -> Void {
    let options: inkAnimOptions;
    this.m_is_paused = false;
    this.m_is_stoped = false;
    options.playReversed = this.m_playReversed;
    options.executionDelay = 0.00;
    options.loopType = inkanimLoopType.Cycle;
    options.loopCounter = this.m_iteration_counter;
    this.m_rotation_widget.PlayAnimationWithOptions(this.m_rotation_anim, options);
    this.m_size_widget.PlayAnimationWithOptions(this.m_size_anim, options);
    this.m_color_widget.PlayAnimationWithOptions(this.m_color_anim, options);
    this.m_alpha_widget.PlayAnimationWithOptions(this.m_alpha_anim, options);
  }

  public final func OnPlayPingPongLoop(widget: wref<inkWidget>) -> Void {
    let options: inkAnimOptions;
    this.m_is_paused = false;
    this.m_is_stoped = false;
    options.playReversed = this.m_playReversed;
    options.executionDelay = 0.00;
    options.loopType = inkanimLoopType.PingPong;
    options.loopCounter = this.m_iteration_counter;
    this.m_rotation_widget.PlayAnimationWithOptions(this.m_rotation_anim, options);
    this.m_size_widget.PlayAnimationWithOptions(this.m_size_anim, options);
    this.m_color_widget.PlayAnimationWithOptions(this.m_color_anim, options);
    this.m_alpha_widget.PlayAnimationWithOptions(this.m_alpha_anim, options);
  }

  private final func PrepareDefinitions() -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let blinkEvent: ref<inkAnimToggleVisibilityEvent>;
    let colorInterpolator: ref<inkAnimColor>;
    let sizeInterpolator: ref<inkAnimSize>;
    this.m_rotation_anim = new inkAnimDef();
    let rotationInterpolator: ref<inkAnimRotation> = new inkAnimRotation();
    rotationInterpolator.SetStartRotation(0.00);
    rotationInterpolator.SetEndRotation(180.00);
    rotationInterpolator.SetDuration(3.00);
    rotationInterpolator.SetType(inkanimInterpolationType.Linear);
    rotationInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_rotation_anim.AddInterpolator(rotationInterpolator);
    blinkEvent = new inkAnimToggleVisibilityEvent();
    blinkEvent.SetStartTime(1.50);
    this.m_rotation_anim.AddEvent(blinkEvent);
    this.m_size_anim = new inkAnimDef();
    sizeInterpolator = new inkAnimSize();
    sizeInterpolator.SetStartSize(new Vector2(32.00, 32.00));
    sizeInterpolator.SetEndSize(new Vector2(16.00, 16.00));
    sizeInterpolator.SetDuration(3.00);
    sizeInterpolator.SetType(inkanimInterpolationType.Linear);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_size_anim.AddInterpolator(sizeInterpolator);
    this.m_color_anim = new inkAnimDef();
    colorInterpolator = new inkAnimColor();
    colorInterpolator.SetStartColor(new HDRColor(1.00, 1.00, 1.00, 1.00));
    colorInterpolator.SetEndColor(new HDRColor(1.00, 0.00, 0.00, 1.00));
    colorInterpolator.SetDuration(3.00);
    colorInterpolator.SetType(inkanimInterpolationType.Linear);
    colorInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_color_anim.AddInterpolator(colorInterpolator);
    this.m_alpha_anim = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.20);
    alphaInterpolator.SetDuration(3.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_anim.AddInterpolator(alphaInterpolator);
  }
}
