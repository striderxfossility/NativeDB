
public class AnimationsConstructor extends IScriptable {

  private let m_duration: Float;

  private let m_type: inkanimInterpolationType;

  private let m_mode: inkanimInterpolationMode;

  private let m_isAdditive: Bool;

  public final func SetGenericSettings(animDuration: Float, animType: inkanimInterpolationType, animMode: inkanimInterpolationMode, isAdditive: Bool) -> Void {
    this.m_duration = animDuration;
    this.m_type = animType;
    this.m_mode = animMode;
    this.m_isAdditive = isAdditive;
  }

  public final func NewMarginInterpolator(startMargin: inkMargin, endMargin: inkMargin) -> ref<inkAnimMargin> {
    let newInterpolator: ref<inkAnimMargin> = new inkAnimMargin();
    newInterpolator.SetStartMargin(startMargin);
    newInterpolator.SetEndMargin(endMargin);
    newInterpolator.SetDuration(this.m_duration);
    newInterpolator.SetType(this.m_type);
    newInterpolator.SetMode(this.m_mode);
    newInterpolator.SetIsAdditive(this.m_isAdditive);
    return newInterpolator;
  }

  public final func NewSizeInterpolator(startSize: Vector2, endSize: Vector2) -> ref<inkAnimSize> {
    let newInterpolator: ref<inkAnimSize> = new inkAnimSize();
    newInterpolator.SetStartSize(startSize);
    newInterpolator.SetEndSize(endSize);
    newInterpolator.SetDuration(this.m_duration);
    newInterpolator.SetType(this.m_type);
    newInterpolator.SetMode(this.m_mode);
    newInterpolator.SetIsAdditive(this.m_isAdditive);
    return newInterpolator;
  }

  public final func NewRotationInterpolator(startRotation: Float, endRotation: Float) -> ref<inkAnimRotation> {
    let newInterpolator: ref<inkAnimRotation> = new inkAnimRotation();
    newInterpolator.SetStartRotation(startRotation);
    newInterpolator.SetEndRotation(endRotation);
    newInterpolator.SetDuration(this.m_duration);
    newInterpolator.SetType(this.m_type);
    newInterpolator.SetMode(this.m_mode);
    newInterpolator.SetIsAdditive(this.m_isAdditive);
    return newInterpolator;
  }

  public final func NewColorInterpolator(startColor: HDRColor, endColor: HDRColor) -> ref<inkAnimColor> {
    let newInterpolator: ref<inkAnimColor> = new inkAnimColor();
    newInterpolator.SetStartColor(startColor);
    newInterpolator.SetEndColor(endColor);
    newInterpolator.SetDuration(this.m_duration);
    newInterpolator.SetType(this.m_type);
    newInterpolator.SetMode(this.m_mode);
    newInterpolator.SetIsAdditive(this.m_isAdditive);
    return newInterpolator;
  }
}
